"""The service's corpus-wide gate and its rebuild child: the freshness
hash and a rebuild job never share the process. The rebuild itself
runs as a DEDICATED CHILD PROCESS; while it lives, /status answers the
named refusal instead of racing it; concurrent /status checks share
ONE in-flight hash; the check right after a rebuild lands is answered
from the rebuild's own result (no re-hash at the boundary, served only
to the connection that polled the job - a reloaded page asks from a
new connection and re-hashes); and the child's display frames stream
through the frame file the poll serves."""

import sys
import threading
import time
from pathlib import Path

from fastapi.testclient import TestClient

from askthedocs import service
from askthedocs.setup import run_setup
from tests.conftest import make_indexable_checkout


def _built(tmp_path: Path) -> tuple[TestClient, object]:
    """A service over a REAL mini-build (gate + build + store)."""
    root = make_indexable_checkout(tmp_path / "tree")
    share = tmp_path / "share"
    run_setup(root / "SOLPS-ITER", share=share, install_icon=False)
    repos = {"SOLPS-ITER": root / "SOLPS-ITER"}
    app = service.create_app(db_path=share / "askthedocs.db", repos=repos)
    return TestClient(app), app


def _drain(client: TestClient) -> dict:
    job = None
    for _ in range(240):
        job = client.get("/reindex").json()
        if job["status"] in ("done", "failed"):
            return job
        time.sleep(0.1)
    raise AssertionError(f"job never settled: {job}")


# a stub rebuild child speaking the real child's wire protocol (frames
# to the frame file, one result record, exit 0) with timing the test
# controls exactly; the REAL child is exercised end to end by the
# rebuild and byte-identity tests in the wire suite
_STUB_CHILD = """\
import json, os, sys, time
from pathlib import Path

a = sys.argv[1:]

def val(flag):
    return Path(a[a.index(flag) + 1]) if flag in a else None

def write(path, doc):
    tmp = path.with_name(path.name + ".tmp")
    tmp.write_text(json.dumps(doc), encoding="utf-8")
    os.replace(tmp, path)

write(val("--frame-file"),
      ["  [|] indexing SOLPS-ITER documents 1/5 files"])
if "--two-frames" in a:
    time.sleep(1.5)
    write(val("--frame-file"),
          ["  [-] indexing SOLPS-ITER documents 4/5 files"])
hold = val("--hold-until")
if hold is not None:
    deadline = time.monotonic() + 120
    while not hold.is_file() and time.monotonic() < deadline:
        time.sleep(0.05)
write(val("--result-file"),
      {"ok": True, "duration_s": 0.1, "chunks": {"total": 7},
       "db_sha256": "0" * 64, "carry": {"legs": []}})
"""


def _stub_child(monkeypatch, tmp_path: Path, *, two_frames: bool = False,
                hold: Path | None = None) -> None:
    """Swap the reindex child for the stub (same spawn seam the real
    child goes through; the protocol is identical)."""
    script = tmp_path / "stub-child.py"
    script.write_text(_STUB_CHILD, encoding="utf-8")
    extra = (["--two-frames"] if two_frames else []) + (
        ["--hold-until", str(hold)] if hold is not None else [])

    def argv(legs, build_dir, final_dir, carry_from, frame_file,
             result_file):
        return [sys.executable, str(script),
                "--frame-file", str(frame_file),
                "--result-file", str(result_file), *extra]

    monkeypatch.setattr(service, "_child_argv", argv)


def test_status_refuses_named_while_a_rebuild_runs(tmp_path, monkeypatch):
    client, app = _built(tmp_path)
    release = tmp_path / "release"
    _stub_child(monkeypatch, tmp_path, hold=release)
    assert client.post("/reindex",
                       params={"force": True}).status_code == 202
    # a second trigger while the child lives: the slot's same 409
    again = client.post("/reindex", params={"force": True})
    assert again.status_code == 409
    assert "already running" in again.json()["detail"]
    # while the child holds the corpus, freshness answers the named
    # refusal - the hash must never answer beside a rebuild
    res = client.get("/status")
    assert res.status_code == 503
    assert "a rebuild is running" in res.json()["detail"]
    assert "when it lands" in res.json()["detail"]
    # the poll target keeps answering throughout (it IS the display)
    assert client.get("/reindex").json()["status"] == "running"
    release.touch()
    assert _drain(client)["status"] == "done"
    # landed: freshness is a verdict again, never a standing refusal
    assert client.get("/status").status_code == 200


def test_concurrent_status_checks_share_one_hash(tmp_path, monkeypatch):
    client, app = _built(tmp_path)
    real_hash = service.state.current_inputs
    started = []
    guard = threading.Lock()

    def counting_hash(repos):
        with guard:
            started.append(time.monotonic())
        time.sleep(0.4)  # hold the hash open so the second caller
        #                  surely arrives while it runs
        return real_hash(repos)

    monkeypatch.setattr(service.state, "current_inputs", counting_hash)
    codes: list[int] = []

    def check() -> None:
        codes.append(TestClient(app).get("/status").status_code)

    threads = [threading.Thread(target=check) for _ in range(2)]
    for t in threads:
        t.start()
    for t in threads:
        t.join(timeout=60)
    assert codes == [200, 200]
    assert len(started) == 1  # ONE hash served both callers


def test_the_check_after_a_rebuild_is_answered_from_the_rebuild_itself(
        tmp_path, monkeypatch):
    client, app = _built(tmp_path)
    calls: list[int] = []
    real_hash = service.state.current_inputs

    def counting_hash(repos):
        calls.append(1)
        return real_hash(repos)

    monkeypatch.setattr(service.state, "current_inputs", counting_hash)
    assert client.post("/reindex",
                       params={"force": True}).status_code == 202
    assert _drain(client)["status"] == "done"
    # the immediate after-done check: answered from what the rebuild
    # consumed - current by construction, no hash at the boundary
    first = client.get("/status")
    assert first.status_code == 200
    body = first.json()
    assert body["status"] == "current"
    assert body["current_corpus_state"] == body["build_corpus_state"]
    assert calls == []
    # the NEXT check re-hashes as always (nothing runs at that point)
    assert client.get("/status").status_code == 200
    assert calls == [1]


def test_the_post_job_verdict_serves_only_the_polling_connection():
    # the connection rule (owner-ruled after the race was proven
    # live): the done-branch check rides the polling page's socket,
    # a reloaded page asks from a NEW one - so a done-branch check
    # cancelled by that reload can never leak its "current" into the
    # reloaded page's first verdict.  Any other asker voids the
    # cached answer: fail closed, never serve a maybe-stale current.
    gate = service._CorpusGate()
    out = service.StatusOut(
        status="current", build_corpus_state="x", current_corpus_state="x",
        build_sources=1, build_by_kind={"corpus": 1},
        drift=service.DriftOut(new=[], changed=[], removed=[]))
    gate.note_poll(("127.0.0.1", 55000))
    gate.stash_verdict(out)
    assert gate.take_verdict(("127.0.0.1", 55001)) is None  # new socket
    assert gate.take_verdict(("127.0.0.1", 55000)) is None  # voided above
    gate.stash_verdict(out)
    served = gate.take_verdict(("127.0.0.1", 55000))
    assert served is not None and served.status == "current"
    assert gate.take_verdict(("127.0.0.1", 55000)) is None  # one-shot


def test_the_child_streams_frames_the_poll_serves(tmp_path, monkeypatch):
    # the frames cross the process boundary through the frame file:
    # the poll must observe the display CHANGING while the child
    # runs (a live stream, not a final snapshot), and the child's
    # last frame keeps serving after it lands
    client, app = _built(tmp_path)
    release = tmp_path / "release"
    _stub_child(monkeypatch, tmp_path, two_frames=True, hold=release)
    assert client.post("/reindex",
                       params={"force": True}).status_code == 202
    seen: list[list[str]] = []
    for _ in range(100):
        job = client.get("/reindex").json()
        if job["status"] in ("done", "failed"):
            break
        if job["frame"] and job["frame"] not in seen:
            seen.append(job["frame"])
        if len(seen) >= 2:
            break
        time.sleep(0.1)
    assert len(seen) == 2, "the polled frame never changed mid-run"
    release.touch()
    job = _drain(client)
    assert job["status"] == "done"
    assert job["frame"] == seen[-1]  # the child's last frame persists
