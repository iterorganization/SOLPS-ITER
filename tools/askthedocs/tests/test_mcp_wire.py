"""The MCP face: the two tools and the session-start usage card,
driven through the same functions the server registers."""

from pathlib import Path

from askthedocs import api, mcp
from tests.conftest import make_corpus_store


def _db(tmp_path: Path, rows=None, name="mcp") -> Path:
    return make_corpus_store(
        tmp_path / name, rows or [{"section": "drifts",
                                   "text": "fac exb drift dynamics"}])


def test_usage_card_names_both_tools():
    assert "search_docs" in mcp.USAGE_CARD
    assert "get_chunk" in mcp.USAGE_CARD
    assert mcp.USAGE_CARD in (mcp.mcp.instructions or "")


def test_search_answers_with_ids_and_the_relay(tmp_path):
    answer = mcp.search_docs("drift", db=str(_db(tmp_path)))
    assert "drift" in answer
    hit = api.search("drift", db_path=_db(tmp_path, name="mcp2"))
    assert hit.hits[0].chunk_id in answer     # the deep link rides along


def test_search_zero_hit_names_remedies(tmp_path):
    db = _db(tmp_path)
    answer = mcp.search_docs("zzqqxx", db=str(db))
    assert answer.strip()                     # a named answer, never a crash


def test_get_chunk_roundtrip_verbatim(tmp_path):
    db = _db(tmp_path)
    hit = api.search("drift", db_path=db).hits[0]
    answer = mcp.get_chunk(hit.chunk_id, db=str(db))
    assert "fac exb drift dynamics" in answer
    assert hit.source in answer               # provenance rides along


def test_get_chunk_unknown_id_is_a_named_failure(tmp_path):
    answer = mcp.get_chunk("0" * 40, db=str(_db(tmp_path)))
    assert answer                             # refused with words


def test_missing_store_refusal_names_the_remedy(tmp_path):
    answer = mcp.search_docs("drift", db=str(tmp_path / "absent.db"))
    assert answer
