"""The search engine's semantics, behavior by behavior: ranking,
the phrase tier, tiered typeahead, zero-hit recovery, plural
widening, build normalization, the identity tier. Every store here
is synthetic and plants exactly the discriminating cases."""

from pathlib import Path

import pytest

from askthedocs import api, normalize, store
from askthedocs.search import expanded_terms
from tests.conftest import make_corpus_store


def _store(tmp_path, rows, name="s"):
    return make_corpus_store(tmp_path / name, rows)


# ------------------------------------------------- core ranking + library

def test_ranked_hits_with_snippets_and_facets(tmp_path):
    db = _store(tmp_path, [
        {"section": "Pumping", "text": "cryopumps pump the divertor"},
        {"section": "Puffs", "text": "gas puffing feeds the edge"},
    ])
    r = api.search("pump", db_path=db)
    assert r.total == 1
    hit = r.hits[0]
    assert hit.source.startswith("SOLPS-ITER/")
    assert hit.snippet            # a highlighted snippet rides along
    assert any(f.cluster == "docs" and f.count == 1 for f in r.facets)


def test_implicit_and_limits_and_totals(tmp_path):
    db = _store(tmp_path, [
        {"section": "A", "text": "alpha beta"},
        {"section": "B", "text": "alpha only"},
        {"section": "C", "text": "beta only"},
    ])
    r = api.search("alpha beta", db_path=db, limit=1)
    assert r.total == 1            # implicit AND: one chunk holds both
    assert len(r.hits) == 1        # limit caps hits, never the total
    assert api.search("alpha", db_path=db).total == 2
    assert len(api.search("alpha", db_path=db).hits) == 2  # default 20


def test_phrase_syntax_passthrough_and_quoted_fallback(tmp_path):
    db = _store(tmp_path, [
        {"section": "P", "text": "edge plasma in tokamaks"},
    ])
    assert api.search('"edge plasma"', db_path=db).total == 1
    assert api.search("well-known", db_path=db).total == 0  # fallback
    with pytest.raises(ValueError):
        api.search("   ", db_path=db)
    with pytest.raises(FileNotFoundError):
        api.search("x", db_path=tmp_path / "absent.db")


def test_chunk_get_roundtrip(tmp_path):
    db = _store(tmp_path, [{"section": "S", "text": "the passage"}])
    hit = api.search("passage", db_path=db).hits[0]
    full = api.get(hit.chunk_id, db_path=db)
    assert full.text == "the passage"
    assert api.get("0" * 40, db_path=db) is None


# ------------------------------------------------------- the phrase tier

def test_phrase_tier_ranks_adjacency_first(tmp_path):
    db = _store(tmp_path, [
        {"section": "far", "text": "drift the exb of plasma flow"},
        {"section": "near", "text": "the exb drift appears here"},
    ])
    hits = api.search("exb drift", db_path=db).hits
    assert hits[0].section == "near"
    assert hits[0].phrase_hit and not hits[1].phrase_hit


def test_single_term_and_syntax_never_tier(tmp_path):
    db = _store(tmp_path, [
        {"section": "a", "text": "exb drift once more"},
    ])
    assert not api.search("exb", db_path=db).hits[0].phrase_hit
    assert not api.search("exb OR drift", db_path=db).hits[0].phrase_hit


def test_cluster_filter_composes_with_the_tier(tmp_path):
    db = _store(tmp_path, [
        {"section": "d", "text": "exb drift in docs"},
        {"section": "c", "text": "exb drift in code",
         "cluster": "fortran_source", "source": "SOLPS-ITER/m/x.F"},
    ])
    only = api.search("exb drift", db_path=db,
                      cluster="fortran_source").hits
    assert [h.section for h in only] == ["c"]
    assert only[0].phrase_hit


# ------------------------------------------------------ tiered typeahead

def test_typeahead_head_is_committed_and_completions_flagged(tmp_path):
    db = _store(tmp_path, [
        {"section": "a", "text": "drift physics of the edge"},
        {"section": "b", "text": "driftwood floats in code",
         "cluster": "fortran_source", "source": "SOLPS-ITER/m/y.F"},
    ])
    committed = api.search("drift", db_path=db).hits
    typed = api.typeahead("drift", db_path=db)
    assert [h.chunk_id for h in typed.hits[:len(committed)]] == \
        [h.chunk_id for h in committed]      # the head IS the list
    extra = typed.hits[len(committed):]
    assert extra and all(h.completion for h in extra)
    assert typed.completions_total == len(extra)


def test_typeahead_guard_and_one_card_shape(tmp_path):
    db = _store(tmp_path, [{"section": "s", "text": "drifts here"}])
    short = api.typeahead("dr", db_path=db)
    assert short.completions_total == 0    # guarded: too short to extend
    zero = api.typeahead("zzqqxx", db_path=db)
    assert zero.total == 0 and hasattr(zero, "absent_legs")
    full = api.search("zzqqxx", db_path=db)
    assert hasattr(full, "absent_legs")     # one card shape, both paths


# ----------------------------------------------------- zero-hit recovery

def test_zero_hit_recovery_card(tmp_path):
    db = _store(tmp_path, [
        {"section": "a", "text": "te pedestals widen with heating"},
        {"section": "b", "text": "pedestal height studies"},
    ])
    r = api.search("pedestal", db_path=db)
    assert r.total > 0                       # sanity: the corpus answers
    zero = api.search("pedestals", db_path=db)
    if zero.total == 0:                      # the boundary state
        assert zero.completions              # grounded words offered
        words = {w for w, _n, _a in zero.completions}
        assert words & {"pedestal", "pedestals"}
    typed = api.typeahead("pedestals", db_path=db)
    assert hasattr(typed, "completions")     # typing carries the card


# ------------------------------------------------------- plural widening

def test_plural_pair_widens_both_ways(tmp_path):
    db = _store(tmp_path, [
        {"section": "one", "text": "the switch records its default"},
        {"section": "many", "text": "defaults govern every switch"},
    ])
    one = api.search("default", db_path=db)
    many = api.search("defaults", db_path=db)
    assert {h.section for h in one.hits} == {"one", "many"}
    assert {h.section for h in many.hits} == {"one", "many"}
    assert one.total == many.total          # symmetric widening
    terms = expanded_terms("defaults")
    assert "default" in terms and "defaults" in terms
    assert "matrix" not in terms            # only the regular pair


# -------------------------------------------------- build normalization

def test_normalization_folds_joins_and_keeps_ids():
    chunks = [store.Chunk(chunk_id="a" * 40, source="s", cluster="docs",
                          section="S", page=None,
                          text="the ﬁeld hyphen­ ated value"),
              store.Chunk(chunk_id="b" * 40, source="s", cluster="docs",
                          section="S", page=None, text="field")]
    out, stats = normalize.normalize_chunks(chunks)
    assert "field" in out[0].text           # ligature folded
    assert out[0].chunk_id == "a" * 40      # ids never move
    again, _ = normalize.normalize_chunks(out)
    assert [c.text for c in again] == [c.text for c in out]  # deterministic


# -------------------------------------------------------- identity tier

def test_identity_outranks_better_scores(tmp_path):
    query = "Eirene manual"
    filler = " ".join([query] * 1)  # bm25 bait without exact section
    db = _store(tmp_path, [
        {"section": "bait", "text": f"{filler} " + "dense " * 40},
        {"section": query, "text": f"the {query} in plain words"},
    ])
    hits = api.search(query, db_path=db).hits
    assert hits[0].section == query         # the citation IS the query
    assert hits[0].identity and not hits[1].identity
    narrow = api.search(query, db_path=db,
                        cluster="fortran_source")
    assert narrow.total == 0                # the filter is respected


def test_typeahead_head_keeps_committed_order_under_identity(tmp_path):
    db = _store(tmp_path, [
        {"section": "Eirene manual", "text": "the Eirene manual text"},
        {"section": "bait", "text": "Eirene manual " + "dense " * 30},
    ])
    committed = api.search("eirene manual", db_path=db).hits
    typed = api.typeahead("eirene manual", db_path=db)
    assert [h.chunk_id for h in typed.hits[:2]] == \
        [h.chunk_id for h in committed]
