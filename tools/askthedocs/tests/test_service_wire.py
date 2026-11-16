"""The service wire: every route's contract over synthetic stores,
plus the freshness library beneath /status. Built stores come from
the real mini-build so freshness sees true inputs."""

from pathlib import Path

import pytest
from fastapi.testclient import TestClient

from askthedocs import api, service
from askthedocs.setup import run_setup
from tests.conftest import make_corpus_store, make_indexable_checkout


def _built(tmp_path: Path, monkeypatch=None) -> tuple[TestClient, Path]:
    """A service over a REAL mini-build (gate + build + store)."""
    root = make_indexable_checkout(tmp_path / "tree")
    share = tmp_path / "share"
    run_setup(root / "SOLPS-ITER", share=share, install_icon=False)
    repos = {"SOLPS-ITER": root / "SOLPS-ITER"}
    client = TestClient(service.create_app(db_path=share / "askthedocs.db",
                                           repos=repos))
    return client, root


def _synthetic(tmp_path: Path, rows: list[dict], name="svc") -> TestClient:
    db = make_corpus_store(tmp_path / name, rows)
    return TestClient(service.create_app(db_path=db, repos={}))


# ------------------------------------------------------- contract surface

def test_openapi_documents_the_routes():
    app = service.create_app(db_path=Path("/dev/null"))
    spec = app.openapi()
    paths = spec["paths"]
    for route in ("/search", "/chunk/{chunk_id}", "/status"):
        assert route in paths, route
    assert spec["info"]["title"]


def test_validation_and_error_mapping(tmp_path):
    client = _synthetic(tmp_path, [{"section": "S", "text": "words"}])
    assert client.get("/search", params={"q": ""}).status_code == 422
    bad = client.get("/search", params={"q": "zzqqxx", "limit": 0})
    assert bad.status_code == 422
    gone = TestClient(service.create_app(
        db_path=tmp_path / "absent.db", repos={}))
    assert gone.get("/search", params={"q": "x"}).status_code == 503


# ------------------------------------------------------------- the routes

def test_search_parity_with_the_library_answer(tmp_path):
    rows = [{"section": "drifts", "text": "fac exb drift dynamics"}]
    client = _synthetic(tmp_path, rows)
    body = client.get("/search", params={"q": "drift"}).json()
    lib = api.search("drift", db_path=make_corpus_store(
        tmp_path / "again", rows))
    assert body["total"] == lib.total == 1
    assert body["hits"][0]["chunk_id"] == lib.hits[0].chunk_id
    assert body["hits"][0]["snippet"]


def test_chunk_roundtrip_and_named_404(tmp_path):
    client = _synthetic(tmp_path, [{"section": "S", "text": "passage"}])
    hit = client.get("/search", params={"q": "passage"}).json()["hits"][0]
    ok = client.get(f"/chunk/{hit['chunk_id']}")
    assert ok.status_code == 200
    assert ok.json()["text"] == "passage"
    assert client.get("/chunk/" + "0" * 40).status_code == 404


def test_status_current_then_drift_then_missing(tmp_path, monkeypatch):
    client, root = _built(tmp_path)
    current = client.get("/status")
    assert current.status_code == 200
    assert current.json()["status"] == "current"
    # a real input change: rewrite a documented source
    doc = root / "SOLPS-ITER" / "doc" / "intro.rst"
    doc.write_text(doc.read_text(encoding="utf-8")
                   + "\nDrifted tail\n", encoding="utf-8")
    drift = client.get("/status")
    assert drift.status_code == 409                  # the gate code
    assert drift.json()["status"] == "drift"
    assert len(drift.json()["drift"]["changed"]) >= 1
    # a store the ladder cannot find anywhere: forced, so the test
    # never depends on what this machine happens to have installed
    def none_found():
        raise FileNotFoundError("no store anywhere")
    monkeypatch.setattr(service.locate, "resolve_db", none_found)
    absent = TestClient(service.create_app(repos={}))
    assert absent.get("/status").status_code == 503


def test_mtime_only_touch_is_never_drift(tmp_path):
    client, root = _built(tmp_path)
    doc = root / "SOLPS-ITER" / "doc" / "intro.rst"
    stat = doc.stat()
    import os
    os.utime(doc, (stat.st_atime + 5, stat.st_mtime + 5))
    assert client.get("/status").json()["status"] == "current"


def test_reindex_discipline(tmp_path, monkeypatch):
    client, root = _built(tmp_path)
    doc = root / "SOLPS-ITER" / "doc" / "intro.rst"
    doc.write_text(doc.read_text(encoding="utf-8") + "\nNew tail\n",
                   encoding="utf-8")
    # no drift yet? it drifted - but first prove the no-drift refusal
    fresh = TestClient(service.create_app(
        db_path=client.app.state.db_path, repos={
            "SOLPS-ITER": root / "SOLPS-ITER"}))
    # the happy path: a rebuild serves the new state atomically
    started = client.post("/reindex")
    assert started.status_code == 202
    job = None
    for _ in range(120):
        job = client.get("/reindex").json()
        if job["status"] in ("done", "failed"):
            break
        import time; time.sleep(0.1)
    assert job["status"] == "done", job
    assert client.get("/search", params={"q": "tail"}).json()["total"] >= 1
    # the second trigger while nothing drifted: refused with a reason
    again = client.post("/reindex")
    assert again.status_code == 409
    assert "current" in again.json()["detail"]


def test_reindex_failure_leaves_the_world_unchanged(tmp_path):
    client, root = _built(tmp_path)
    doc = root / "SOLPS-ITER" / "doc" / "intro.rst"
    doc.write_text(doc.read_text(encoding="utf-8") + "\nBoom tail\n",
                   encoding="utf-8")
    before = client.get("/search", params={"q": "drifts"}).json()
    # a document the rebuild cannot extract: the child process fails
    # on it with the source named (the review harness's --break
    # state, pinned here) - the failure crosses a process boundary
    # and must still map onto the job's failed record with the served
    # store byte-untouched
    (root / "SOLPS-ITER" / "doc" / "broken.rst").write_bytes(
        b"Broken\n======\n\nnot utf-8 bytes: \x80\xff\n")
    started = client.post("/reindex")
    assert started.status_code == 202
    job = None
    for _ in range(240):
        job = client.get("/reindex").json()
        if job["status"] in ("done", "failed"):
            break
        import time; time.sleep(0.1)
    assert job["status"] == "failed"
    assert "broken.rst" in job["error"]
    after = client.get("/search", params={"q": "drifts"}).json()
    assert after == before            # the served store never changed


def test_reindex_requires_a_store(tmp_path):
    gone = TestClient(service.create_app(
        db_path=tmp_path / "absent.db", repos={}))
    assert gone.post("/reindex").status_code == 503


# ------------------------------------------- the force path + the frames

def _drain(client) -> dict:
    job = None
    for _ in range(240):
        job = client.get("/reindex").json()
        if job["status"] in ("done", "failed"):
            return job
        import time; time.sleep(0.1)
    raise AssertionError(f"job never settled: {job}")


def test_reindex_force_rebuilds_a_current_index_and_serves_frames(
        tmp_path):
    client, root = _built(tmp_path)
    assert client.get("/status").json()["status"] == "current"
    idle = client.get("/reindex").json()
    assert idle["status"] == "idle" and idle["frame"] == []
    started = client.post("/reindex", params={"force": True})
    assert started.status_code == 202
    job = _drain(client)
    assert job["status"] == "done", job
    # the closing frame IS the CLI's closing log, line for line
    assert job["frame"][0] == "Askthedocs indexation complete"
    assert any("SOLPS-ITER documents" in line for line in job["frame"])
    assert job["chunks_total"] >= 1
    # the rebuilt store still serves the corpus
    assert client.get("/search", params={"q": "drifts"}).json()["total"] >= 1


def test_service_rebuild_is_byte_identical_to_the_shared_driver(
        tmp_path):
    import io
    import shutil as _shutil

    from askthedocs import setup as setup_mod
    from askthedocs.progress import Progress

    client, root = _built(tmp_path)
    share = client.app.state.db_path.parent
    # the pre-job store, snapshotted: the job rebuild CARRIES from it,
    # so the like-for-like direct run must carry from the same bytes
    # (companions beside the snapshot too - the carry state reads them)
    carried_from = tmp_path / "pre-job.db"
    _shutil.copyfile(share / "askthedocs.db", carried_from)
    for name in ("build_summary.json", "switches.json", "corpus.json"):
        src = share / name
        if src.is_file():
            _shutil.copyfile(src, tmp_path / name)
    started = client.post("/reindex", params={"force": True})
    assert started.status_code == 202
    assert _drain(client)["status"] == "done"
    # the service job's store equals a DIRECT run of the same driver
    # with the same repos and the same carry source: one code path,
    # byte-deterministic (the CLI setup verb ran it too when this
    # store was first built; the service side now runs its rebuild in
    # a dedicated child process, so the equality is process-for-
    # process)
    bar = Progress(io.StringIO())
    setup_mod.run_index_build(
        dict(client.app.state.repos), bar=bar,
        build_dir=tmp_path / "direct-build",
        final_dir=tmp_path / "direct-out", carry_from=carried_from)
    served = (share / "askthedocs.db").read_bytes()
    direct = (tmp_path / "direct-out" / "askthedocs.db").read_bytes()
    assert served == direct


def test_status_names_the_resolved_repos_root(tmp_path):
    client, root = _built(tmp_path)
    body = client.get("/status").json()
    assert body["repos_root"] == str(root)
