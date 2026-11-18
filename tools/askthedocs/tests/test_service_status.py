"""The service's freshness routes: the corpus-universe
question always has an answer. /status and /reindex never crash on a
corpus this service cannot see - they answer the named refusal - and
the deliberate container profile (injected empty) still rolls every
leg carried."""

from pathlib import Path

from fastapi.testclient import TestClient

from askthedocs import floor, service, state, store
from tests.conftest import make_store


def _app_with_store(tmp_path: Path, *, repos) -> TestClient:
    """A service over a synthetic store; *repos* is injected verbatim
    (None = the ladder, {} = the container profile)."""
    db = make_store(tmp_path / "share")
    app = service.create_app(db_path=db, repos=repos)
    return TestClient(app)


def test_status_refuses_named_when_corpus_unresolvable(
        tmp_path: Path, monkeypatch):
    client = _app_with_store(tmp_path, repos=None)
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)

    def refuse(*_a, **_k):
        raise floor.FloorError("no SOLPS-ITER checkout found")

    monkeypatch.setattr(floor, "check_floor", refuse)
    res = client.get("/status")
    assert res.status_code == 503          # never a 500
    assert "cannot be found" in res.json()["detail"]
    assert floor.REPOS_ENV in res.json()["detail"]
    assert "setup" in res.json()["detail"]  # the way out is named


def test_reindex_refuses_named_when_corpus_unresolvable(
        tmp_path: Path, monkeypatch):
    client = _app_with_store(tmp_path, repos=None)
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)

    def refuse(*_a, **_k):
        raise floor.FloorError("no SOLPS-ITER checkout found")

    monkeypatch.setattr(floor, "check_floor", refuse)
    res = client.post("/reindex")
    assert res.status_code == 503
    assert "cannot be found" in res.json()["detail"]


def test_status_container_profile_answers_carried(tmp_path: Path):
    # the deliberate empty corpus universe: recorded legs read
    # carried (nothing on disk to drift against), optional legs with
    # nothing recorded read absent (the fourth-leg verdict),
    # repos_present 0 - the designed consumer answer, now reachable
    client = _app_with_store(tmp_path, repos={})
    res = client.get("/status")
    assert res.status_code == 200
    body = res.json()
    assert body["status"] == "current"
    assert body["repos_present"] == 0
    verdicts = {leg["name"]: leg["verdict"] for leg in body["legs"]}
    assert verdicts == {"SOLPS-ITER": "carried",
                        "SOLPS-GUI": "absent",
                        "SOLPS-Tutorials": "absent"}


def test_current_inputs_tolerates_an_empty_corpus_universe():
    # the crash itself: no SOLPS-ITER key ever raises again
    rows = state.current_inputs({})
    assert rows == []


def test_search_typeahead_answers_never_500(tmp_path: Path):
    # found live: the web typeahead (every keystroke) crashed the
    # service - the shared response builder read a field the typing
    # shape lacked. One card shape now.
    client = _app_with_store(tmp_path, repos=None)
    ok = client.get("/search", params={"q": "drifts", "typeahead": "true"})
    assert ok.status_code == 200
    assert ok.json()["completions_total"] >= 0   # the tier answered
    zero = client.get("/search", params={"q": "zzqqxx",
                                         "typeahead": "true"})
    assert zero.status_code == 200              # never a 500
    body = zero.json()
    assert "absent_legs" in body and isinstance(body["absent_legs"], list)


def test_status_503_names_the_recorded_root_when_the_ladder_refuses(
        tmp_path: Path, monkeypatch):
    # the decay case: the corpus moved or vanished after the build;
    # the refusal names WHERE setup stood, never a guess
    client = _app_with_store(tmp_path, repos=None)
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)

    def refuse(*_a, **_k):
        raise floor.FloorError("no SOLPS-ITER checkout found")

    monkeypatch.setattr(floor, "check_floor", refuse)
    monkeypatch.setattr(floor, "recorded_root",
                        lambda *_a, **_k: Path("/gone/repos-root"))
    res = client.get("/status")
    assert res.status_code == 503
    assert "/gone/repos-root" in res.json()["detail"]
    assert "not there anymore" in res.json()["detail"]


def test_service_follows_the_home_env(tmp_path: Path, monkeypatch):
    # the index home redirect reaches the service process: with
    # $ASKTHEDOCS_HOME pointing at a valid index, the app resolves it
    # through the same ladder and serves it (the isolated home has no
    # index of its own; only the redirected home answers)
    import json
    from askthedocs.locate import BUILD_SCHEMA, SUMMARY_NAME
    scratch = tmp_path / "scratch" / "atd"
    db = make_store(scratch)
    (scratch / SUMMARY_NAME).write_text(
        json.dumps({"schema": BUILD_SCHEMA}), encoding="utf-8")
    monkeypatch.setenv("HOME", str(tmp_path / "home"))
    monkeypatch.setenv("ASKTHEDOCS_HOME", str(scratch))
    client = TestClient(service.create_app())
    res = client.get("/search", params={"q": "drifts"})
    assert res.status_code == 200
    assert res.json()["total"] >= 1
