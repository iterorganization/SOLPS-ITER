"""The reindex events stream (the push wire): one Server-Sent
Events connection per page replaces the 2 s poll.  The stream is
driven through the stub-child seam - frames land with test-controlled
timing, so the wire is pinned deterministically; the REAL child is
exercised end to end by the rebuild tests in the wire suite.  Pinned
here: the snapshot-then-delta contract with an exact diff (events vs
the frames actually written), mid-run adoption, the terminal close +
idempotent reconnect, the failed terminal, the keepalive, two streams
on one job (multi-tab) with the once-only verdict, and GET /reindex's
poll shape unchanged beside the stream."""

import json
import sys
import time
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from askthedocs import service
from askthedocs.setup import run_setup
from tests.conftest import make_indexable_checkout


# a stub rebuild child speaking the real child's wire protocol with a
# TEST-SCRIPTED frame sequence: every frame lands atomically, and the
# cadence is chosen so the stream's sampler (4x per second) surely
# observes every frame exactly once - 1.0 s of start-up grace before
# the first write (so the running snapshot serves the supervisor's
# empty frame, deterministically), then one frame per 0.4 s.  With
# --fail the run ends in the failure record instead of the summary
_SCRIPTED_CHILD = """\
import json, os, sys, time
from pathlib import Path

a = sys.argv[1:]

def val(flag):
    return Path(a[a.index(flag) + 1]) if flag in a else None

def write(path, doc):
    tmp = path.with_name(path.name + ".tmp")
    tmp.write_text(json.dumps(doc), encoding="utf-8")
    os.replace(tmp, path)

time.sleep(1.0)
for frame in json.loads(val("--frame-script").read_text(encoding="utf-8")):
    write(val("--frame-file"), frame)
    time.sleep(0.4)
if "--fail" in a:
    write(val("--result-file"),
          {"ok": False, "error": "the named failure (doc/broken.rst)"})
    sys.exit(1)
write(val("--result-file"),
      {"ok": True, "duration_s": 0.1, "chunks": {"total": 7},
       "db_sha256": "0" * 64, "carry": {"legs": []}})
"""


def _built(tmp_path: Path) -> tuple[TestClient, object]:
    """A service over a REAL mini-build (gate + build + store)."""
    root = make_indexable_checkout(tmp_path / "tree")
    share = tmp_path / "share"
    run_setup(root / "SOLPS-ITER", share=share, install_icon=False)
    repos = {"SOLPS-ITER": root / "SOLPS-ITER"}
    app = service.create_app(db_path=share / "askthedocs.db", repos=repos)
    return TestClient(app), app


def _scripted_child(monkeypatch, tmp_path: Path, frames: list[list[str]],
                    *, fail: bool = False) -> None:
    """Swap the reindex child for the frame-scripted stub (the same
    spawn seam the real child goes through; the protocol is
    identical)."""
    script = tmp_path / "scripted-child.py"
    script.write_text(_SCRIPTED_CHILD, encoding="utf-8")
    frames_file = tmp_path / "frames.json"
    frames_file.write_text(json.dumps(frames), encoding="utf-8")
    extra = ["--fail"] if fail else []

    def argv(legs, build_dir, final_dir, carry_from, frame_file,
             result_file):
        return [sys.executable, str(script),
                "--frame-file", str(frame_file),
                "--result-file", str(result_file),
                "--frame-script", str(frames_file), *extra]

    monkeypatch.setattr(service, "_child_argv", argv)


# the scripted frame sequence: an in-place change (the category row
# and the counters), growth (the current-file/page line a slow PDF
# shows), and a shrink back (the stage settles, the line folds away)
_FRAMES = [
    ["Askthedocs indexation in progress", "----",
     "queued    SOLPS-ITER documents 9 files",
     "total: 0/9 files indexed, elapsed 1s",
     "  indexing SOLPS-ITER 1/9 files [####------] 11%"],
    ["Askthedocs indexation in progress", "----",
     "indexing  SOLPS-ITER documents 9 files",
     "total: 4/9 files indexed, elapsed 5s",
     "  indexing SOLPS-ITER 4/9 files [########---] 44%",
     "  reading doc/manual.pdf (1.2 MB) [####------] 45/812 pages"],
    ["Askthedocs indexation in progress", "----",
     "indexed   SOLPS-ITER documents 9 files",
     "total: 9/9 files indexed, elapsed 9s",
     "  indexing SOLPS-ITER 9/9 files [##########] 100%"],
    ["Askthedocs indexation in progress", "----",
     "indexed   SOLPS-ITER documents 9 files",
     "settled: the store write"],
]


def _read_event(lines) -> tuple[str, dict | None]:
    """Consume one SSE message from the response's line iterator: the
    event name and the parsed data payload.  Keepalive comment lines
    (": keepalive") may interleave and are skipped - they must never
    reach a consumer."""
    name, data = None, None
    for line in lines:
        if line.startswith(":"):
            continue
        if line.startswith("event: "):
            name = line[len("event: "):]
        elif line.startswith("data: "):
            data = json.loads(line[len("data: "):])
        elif line == "" and name is not None:
            return name, data
    raise AssertionError("stream ended before an event arrived")


def _apply(state: list[str], delta: dict) -> list[str]:
    """Apply one delta the client's way: set every changed line, then
    resize to the delta's length (the reconstruction the diff pin
    compares against the frames actually written)."""
    out = list(state)
    for change in delta["lines"]:
        while len(out) <= change["i"]:
            out.append("")
        out[change["i"]] = change["text"]
    del out[delta["length"]:]
    return out


_POLL_SHAPE = {"status", "started_at", "finished_at", "duration_s",
               "error", "chunks_total", "db_sha256_8", "carried_legs",
               "skipped_sources", "drifted_legs", "frame"}


def test_snapshot_then_deltas_then_terminal_and_the_diff_is_exact(
        tmp_path, monkeypatch):
    client, app = _built(tmp_path)
    _scripted_child(monkeypatch, tmp_path, _FRAMES)
    # the stream attaches while idle: push replaces poll for the chip
    # too, so a job started anywhere announces itself on this stream
    with client.stream("GET", "/reindex/events") as response:
        assert response.headers["content-type"].startswith(
            "text/event-stream")
        lines = response.iter_lines()
        name, payload = _read_event(lines)
        assert name == "snapshot" and payload["status"] == "idle"
        assert payload["frame"] == []
        assert set(payload) == _POLL_SHAPE   # the snapshot is the poll
        #                                     shape verbatim
        started = client.post("/reindex", params={"force": True})
        assert started.status_code == 202
        name, payload = _read_event(lines)
        assert name == "snapshot" and payload["status"] == "running"
        assert payload["frame"] == []        # the supervisor's empty
        #                                      first frame
        states: list[list[str]] = [[]]
        while True:
            name, payload = _read_event(lines)
            if name == "done":
                break
            assert name == "delta"
            states.append(_apply(states[-1], payload))
        # every frame the child wrote is reproduced by the deltas,
        # exactly and in order, none skipped, none invented - the diff
        # pin: the events ARE the frame file
        assert states == [[], *_FRAMES]
        # the terminal carries the closing summary: the job state in
        # the poll shape plus the post-job verdict this connection
        # earned (the verdict, now the closing event)
        assert payload["status"] == "done"
        assert payload["chunks_total"] == 7
        assert payload["frame"] == _FRAMES[-1]
        assert payload["verdict"]["status"] == "current"
        assert (payload["verdict"]["build_corpus_state"]
                == payload["verdict"]["current_corpus_state"])
        # after the terminal the stream is CLOSED - the browser's
        # auto-reconnect can never resurrect the finished job from
        # THIS connection
        with pytest.raises(StopIteration):
            next(lines)


def test_mid_run_connect_adopts_the_running_job(tmp_path, monkeypatch):
    client, app = _built(tmp_path)
    _scripted_child(monkeypatch, tmp_path, _FRAMES)
    assert client.post("/reindex",
                       params={"force": True}).status_code == 202
    # a page opened while the job runs: the FIRST thing the stream
    # says is a running snapshot carrying a true frame, and it follows
    # the same job to the same terminal
    with client.stream("GET", "/reindex/events") as response:
        lines = response.iter_lines()
        name, payload = _read_event(lines)
        assert name == "snapshot" and payload["status"] == "running"
        assert payload["frame"] in ([], *_FRAMES)
        last = payload["frame"]
        while True:
            name, payload = _read_event(lines)
            if name == "done":
                break
            last = _apply(last, payload)
        assert payload["frame"] == last == _FRAMES[-1]


def test_reconnect_at_a_settled_slot_answers_the_terminal_again(
        tmp_path, monkeypatch):
    client, app = _built(tmp_path)
    _scripted_child(monkeypatch, tmp_path, _FRAMES)
    assert client.post("/reindex",
                       params={"force": True}).status_code == 202
    # watch one job land on a stream of its own
    with client.stream("GET", "/reindex/events") as response:
        lines = response.iter_lines()
        while True:
            name, first = _read_event(lines)
            if name == "done":
                break
    # a fresh connection at the settled slot: the SAME terminal event,
    # once more, idempotent - and the stream closes again.  The
    # verdict is not replayed (consumed by the terminal that earned
    # it), and the browser's auto-reconnect loop dies here because the
    # event says finished, never restarted
    with client.stream("GET", "/reindex/events") as response:
        lines = response.iter_lines()
        name, again = _read_event(lines)
        assert name == "done"
        assert again["chunks_total"] == first["chunks_total"]
        assert again["frame"] == first["frame"]
        assert again["verdict"] is None
        with pytest.raises(StopIteration):
            next(lines)
    # a SECOND job claimed while a page has no stream: the next stream
    # to connect sees it running (the chip never needs the poll), and
    # a failing child crosses the boundary as the named error on the
    # failed terminal
    _scripted_child(monkeypatch, tmp_path, _FRAMES[:1], fail=True)
    assert client.post("/reindex",
                       params={"force": True}).status_code == 202
    with client.stream("GET", "/reindex/events") as response:
        lines = response.iter_lines()
        name, payload = _read_event(lines)
        assert name == "snapshot" and payload["status"] == "running"
        while True:
            name, payload = _read_event(lines)
            if name == "failed":
                break
            assert name == "delta"
        assert "broken.rst" in payload["error"]
        assert payload["verdict"] is None    # no verdict on failure -
        #                                       the next check re-hashes
        with pytest.raises(StopIteration):
            next(lines)


def test_an_idle_stream_keeps_alive_on_comments(tmp_path, monkeypatch):
    client, app = _built(tmp_path)
    monkeypatch.setattr(service, "_EVENT_KEEPALIVE_S", 0.2)
    with client.stream("GET", "/reindex/events") as response:
        assert response.headers["cache-control"] == "no-cache"
        lines = response.iter_lines()
        name, _ = _read_event(lines)
        assert name == "snapshot"
        # comment lines arrive while nothing changes: liveness for
        # proxies and the browser, zero payload for the page (and the
        # reader above skips them silently elsewhere)
        comments = 0
        for line in lines:
            if line.startswith(":"):
                comments += 1
            if comments >= 2:
                break
        assert comments >= 2, "no keepalive comments on an idle stream"


def test_two_streams_one_job_and_one_verdict(tmp_path, monkeypatch):
    client, app = _built(tmp_path)
    frames = _FRAMES[:2]
    _scripted_child(monkeypatch, tmp_path, frames)
    # two tabs, two streams, one job: each connection gets the whole
    # lifecycle independently (no broadcast bookkeeping server-side).
    # The two streams are drained one after the other - the test
    # client advances a stream's generator only while that response is
    # being read (a harness artifact; one event loop serves every
    # stream in deployment) - so what is pinned is each stream's own
    # contract: its running snapshot whenever its generator samples
    # the job, the deltas from there, and the SAME terminal
    with client.stream("GET", "/reindex/events") as a, \
            client.stream("GET", "/reindex/events") as b:
        lines_a, lines_b = a.iter_lines(), b.iter_lines()
        for lines in (lines_a, lines_b):
            name, payload = _read_event(lines)
            assert name == "snapshot" and payload["status"] == "idle"
        assert client.post("/reindex",
                           params={"force": True}).status_code == 202
        verdicts = []
        terminals = []
        for lines in (lines_a, lines_b):
            while True:
                name, payload = _read_event(lines)
                if name in ("done", "failed"):
                    verdicts.append(payload["verdict"])
                    terminals.append(payload)
                    break
        for payload in terminals:
            assert payload["status"] == "done"
            assert payload["chunks_total"] == 7
            assert payload["frame"] == frames[-1]
        # identical summaries, the verdict excepted: both tabs settle
        # on the same job truth
        strip = [{k: v for k, v in t.items() if k != "verdict"}
                 for t in terminals]
        assert strip[0] == strip[1]
        # and the post-job verdict is served ONCE, to exactly one
        # connection (the once-only rule, unchanged under push)
        assert sum(v is not None for v in verdicts) == 1


def test_the_stream_refuses_like_the_poll_and_stands_beside_it(
        tmp_path, monkeypatch):
    # no store anywhere: the stream answers the same named 503 the
    # other data routes carry (never a hang, never a crash)
    def none_found():
        raise FileNotFoundError("no store anywhere")
    monkeypatch.setattr(service.locate, "resolve_db", none_found)
    gone = TestClient(service.create_app(repos={}))
    assert gone.get("/reindex/events").status_code == 503
    # an explicit-but-absent store: the stream follows the poll's own
    # semantics - GET /reindex answers idle because it never touches
    # the db, and so does the stream
    absent = TestClient(service.create_app(
        db_path=tmp_path / "absent.db", repos={}))
    with absent.stream("GET", "/reindex/events") as response:
        name, payload = _read_event(response.iter_lines())
        assert name == "snapshot" and payload["status"] == "idle"
    # and the poll's own shape is untouched by the stream's arrival:
    # mid-run it answers the same ten fields as ever
    client, app = _built(tmp_path)
    _scripted_child(monkeypatch, tmp_path, _FRAMES)
    assert client.post("/reindex",
                       params={"force": True}).status_code == 202
    deadline = time.monotonic() + 30
    job = None
    while time.monotonic() < deadline:
        job = client.get("/reindex").json()
        if job["status"] in ("done", "failed") or job["frame"]:
            break
        time.sleep(0.1)
    assert set(job) == _POLL_SHAPE
    assert job["status"] == "running" and job["frame"] in _FRAMES
