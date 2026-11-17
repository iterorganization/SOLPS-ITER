"""Library API over the chunk store): data in, dataclasses out.

This is the one search implementation every programmatic face reuses:
the CLI prints it, the MCP tools) and the FastAPI service
) return it. It wraps :mod:`askthedocs.search` — the SQL layer —
with connection management and typed results.  Nothing here prints,
and the database is only ever opened read-only.

Errors (same contracts the CLI maps to exit codes):
- ``FileNotFoundError`` — the chunk store does not exist yet.
- ``ValueError`` — empty query, or ``limit < 1``.
- ``sqlite3.OperationalError`` — the query is invalid even in the
  quoted-fallback form (see ``askthedocs.search.match_expr``).
"""

from __future__ import annotations

from askthedocs._sqlite import sqlite3
from dataclasses import dataclass, field
from pathlib import Path

from askthedocs import locate
from askthedocs import search as search_mod

# hits returned per query when the caller does not ask for more
DEFAULT_LIMIT = 20


@dataclass(frozen=True)
class MatchedTerm:
    """One query term present in the chunk, with its occurrence count. Term presence + frequency — NOT a per-term score
    decomposition; the honesty rule lives in §Service tier.
    """

    term: str
    n: int


@dataclass(frozen=True)
class SearchHit:
    """One ranked match: provenance + highlighted snippet (no full text).

    ``matched_terms`` lists the query terms found in the
    chunk with occurrence counts; ``score`` is the FTS5 ``bm25()`` value
    as returned — the same number as ``rank`` (the v1 field name, kept
    for the frozen contract), never re-derived or decomposed.
    ``phrase_hit`` (is the visible marker of the implicit phrase
    tier: True exactly when the query was plain multi-term AND this
    chunk contains its tokens as one adjacent phrase — the hits that
    rank ahead of all others.  Single-term and explicit-syntax queries
    carry False on every hit (no tier applied).
    """

    chunk_id: str
    source: str
    cluster: str
    section: str | None
    page: int | None
    snippet: str
    rank: float
    matched_terms: list[MatchedTerm]
    score: float
    phrase_hit: bool
    # identity tier: True exactly when this chunk's citation
    # name (section) EQUALS the query — trimmed, case-insensitive.
    # Identity hits sort first (above the phrase tier); the
    # flag is the visible marker of why.  Membership never changes.
    identity: bool = False
    #: True only on type-ahead answers' completion-tier hits —
    # corpus words extending the unfinished last typed word; the
    # committed-search tier carries False everywhere (the default,
    # so every existing constructor keeps its meaning)
    completion: bool = False


@dataclass(frozen=True)
class Facet:
    """One cluster chip: label + live match count)."""

    cluster: str
    count: int


@dataclass(frozen=True)
class Chunk:
    """One chunk in full: provenance + complete text."""

    chunk_id: str
    source: str
    cluster: str
    section: str | None
    page: int | None
    text: str


@dataclass(frozen=True)
class SearchResult:
    """Answer to one query: the total match count + the best hits.

    ``facets``) carries the per-cluster counts over EVERY
    match of the query — the drill-in chips.  It is computed without
    the cluster restriction, so it stays identical whether or not
    ``cluster=`` narrowed the hits.
    """

    query: str
    total: int
    facets: list[Facet]
    hits: list[SearchHit]
    # filled only on the zero-hit boundary (a plain
    # query matching nothing): the corpus words extending the last
    # token that CO-OCCUR with the rest of the query, each as
    #``(word, click-yield count, side-by-side count)`` — side-by-side
    # words first, then same-chunk, each tier by true yield
    completions: list[tuple[str, int, int]] = field(default_factory=list)
    #:  the first completion row, or None off-boundary
    did_you_mean: str | None = None
    #(c) — the escape hatch, only when NO extending word
    # combines: every typed term with a nonzero solo yield as
    #``(term, count)``; empty whenever completions are offered
    separate_terms: list[tuple[str, int]] = field(default_factory=list)
    #: optional corpus legs absent from this machine at build time,
    #: filled on the zero-hit boundary: their content can never answer
    #: here, and the zero-hit card must say so
    absent_legs: list[str] = field(default_factory=list)

    @property
    def sources(self) -> list[str]:
        """Distinct hit sources, first-appearance (best-rank) order."""
        seen: list[str] = []
        for hit in self.hits:
            if hit.source not in seen:
                seen.append(hit.source)
        return seen


@dataclass(frozen=True)
class TypeaheadResult:
    """answer to one TYPING state: committed tier + completion
    tier in one list.

    ``hits`` holds the exact tier first — identical to :func:`search`'s
    order for the same query, so the preview's head IS the committed
    list — then the completion-tier hits, each carrying
    ``completion=True``.  ``total`` stays the committed-semantics
    count; ``completions_total`` counts the completion tier (0 when
    the guard or non-plainness suppressed it).  ``facets`` are the
    committed query's chips — membership never changes with typing.
    """

    query: str
    total: int
    completions_total: int
    facets: list[Facet]
    hits: list[SearchHit]
    # same meaning as SearchResult's (the committed
    # answer's recovery card — uniformity: the SAME card the
    # committed path shows, filled whenever the exact tier is empty);
    # the completion TIER may still carry preview rows in that state
    completions: list[tuple[str, int, int]] = field(default_factory=list)
    did_you_mean: str | None = None
    separate_terms: list[tuple[str, int]] = field(default_factory=list)
    # absent optional legs, named on the same zero-hit boundary as
    # the committed answer (uniformity: ONE card shape; the service
    # builder reads this field on both result types - its absence
    # 500'd every web typeahead keystroke, found live 2026-11-04)
    absent_legs: list[str] = field(default_factory=list)

    @property
    def sources(self) -> list[str]:
        """Distinct hit sources, first-appearance order across tiers."""
        seen: list[str] = []
        for hit in self.hits:
            if hit.source not in seen:
                seen.append(hit.source)
        return seen


def _connect(db_path: Path | None) -> sqlite3.Connection:
    # An explicit path is the caller's own choice (used verbatim, never
    # re-located); no path at all runs the delivery ladder — env
    # override, launch-dir artifact, user share — which validates what
    # it finds or fails loudly naming setup as the fix.
    path = db_path if db_path is not None else locate.resolve_db()
    if not path.is_file():
        raise FileNotFoundError(
            f"chunk store not found: {path} (run `askthedocs setup` first)"
        )
    return search_mod.connect(path)


# the optional corpus legs: cloned means indexed; absent at build time
# means their content can never answer, which zero-hit answers must say
OPTIONAL_LEGS = ("SOLPS-GUI", "SOLPS-Tutorials")


def absent_optional_legs(conn: sqlite3.Connection) -> list[str]:
    """Optional legs the store never indexed (absent from the machine
    at build time): read from the build manifest's recorded repos."""
    try:
        recorded = {row[0] for row in conn.execute(
            "SELECT DISTINCT repo FROM build_manifest")}
    except sqlite3.OperationalError:
        return []
    return [leg for leg in OPTIONAL_LEGS if leg not in recorded]


def search(query: str, *, db_path: Path | None = None,
           limit: int = DEFAULT_LIMIT,
           cluster: str | None = None) -> SearchResult:
    """Ranked hits for *query* as data — the library face of .

    Opens the chunk store read-only, runs the same ranking the CLI
    uses (bm25 + rowid tie-break, with the phrase tier first for
    plain multi-term queries), and returns typed results.  ``total``
    counts every matching chunk; ``hits`` holds at most ``limit`` of
    them, best first. ``cluster``) restricts the result to one
    cluster (`fortran_source`, `source_switch`, any documentation
    cluster) — by default manual and code chunks rank together, each
    hit carrying its ``cluster`` label so an answer can cite both.
    ``result.facets``) is always the FULL per-cluster
    breakdown of the query: the count for cluster C equals the
    ``total`` of ``search(q, cluster=C)`` — the invariant the chips
    rely on.
    """
    conn = _connect(db_path)
    try:
        total, rows = search_mod.search(conn, query, limit, cluster=cluster)
        facet_rows = search_mod.facets(conn, query)
        # + : the zero-hit boundary — a plain query matching
        # nothing gets the grounded recovery card (co-occurrence-gated
        # words with click-yield counts, side-by-side tier first; the
        # separate-term escape hatch when nothing combines).  Off-
        # boundary zero hits and every non-empty answer carry the
        # empty defaults.
        words, did_you_mean, separate = ([], None, [])
        absent: list[str] = []
        if total == 0:
            words, did_you_mean, separate = search_mod.boundary_completions(
                conn, query, cluster=cluster)
            absent = absent_optional_legs(conn)
    finally:
        conn.close()
    # terms come from the RAW query (not the validated FTS5
    # expression) and counts from the hit's full text.
    terms = search_mod.expanded_terms(query)
    hits = [
        SearchHit(
            chunk_id=row["chunk_id"], source=row["source"],
            cluster=row["cluster"], section=row["section"],
            page=row["page"], snippet=row["snippet"], rank=row["rank"],
            matched_terms=[
                MatchedTerm(term=term, n=n)
                for term, n in search_mod.matched_terms(row["text"], terms)
            ],
            score=row["rank"],
            phrase_hit=bool(row["phrase_hit"]),
            identity=bool(row["identity_hit"]),
        )
        for row in rows
    ]
    facets = [
        Facet(cluster=row["cluster"], count=int(row["count"]))
        for row in facet_rows
    ]
    return SearchResult(query=query, total=total, facets=facets, hits=hits,
                        completions=words, did_you_mean=did_you_mean,
                        separate_terms=separate, absent_legs=absent)


def typeahead(query: str, *, db_path: Path | None = None,
              limit: int = DEFAULT_LIMIT,
              cluster: str | None = None) -> TypeaheadResult:
    """tiered answer for one typing state, as data.

    The same :func:`search` call commits would run (tier 1, byte
    identical order), plus the completion tier: corpus words extending
    the unfinished last word, prefix-adjacency first, every hit marked
    ``completion=True``.  Single engine, one query shape per tier —
    the CLI/MCP faces simply never call this (committed queries only).
    """
    conn = _connect(db_path)
    try:
        total, tier1, comp_total, tier2 = search_mod.typeahead_search(
            conn, query, limit, cluster=cluster)
        facet_rows = search_mod.facets(conn, query)
        # + on the typing path too (uniformity: the
        # typing answer and the committed answer carry the SAME card —
        # amendment 2026-10-21): the committed semantics may sit
        # on the zero-hit boundary while the completion tier previews
        words, did_you_mean, separate = ([], None, [])
        absent: list[str] = []
        if total == 0:
            words, did_you_mean, separate = search_mod.boundary_completions(
                conn, query, cluster=cluster)
            absent = absent_optional_legs(conn)
    finally:
        conn.close()
    terms = search_mod.expanded_terms(query)

    def _hit(row, completion: bool) -> SearchHit:
        return SearchHit(
            chunk_id=row["chunk_id"], source=row["source"],
            cluster=row["cluster"], section=row["section"],
            page=row["page"], snippet=row["snippet"], rank=row["rank"],
            matched_terms=[
                MatchedTerm(term=term, n=n)
                for term, n in search_mod.matched_terms(row["text"], terms)
            ],
            score=row["rank"],
            phrase_hit=bool(row["phrase_hit"]),
            identity=bool(row["identity_hit"]),
            completion=completion,
        )

    hits = [_hit(row, False) for row in tier1] + \
           [_hit(row, True) for row in tier2]
    facets = [
        Facet(cluster=row["cluster"], count=int(row["count"]))
        for row in facet_rows
    ]
    return TypeaheadResult(query=query, total=total,
                           completions_total=comp_total, facets=facets,
                           hits=hits, completions=words,
                           did_you_mean=did_you_mean,
                           separate_terms=separate, absent_legs=absent)


def get(chunk_id: str, *, db_path: Path | None = None) -> Chunk | None:
    """One chunk in full by ID, or ``None`` when the ID is unknown."""
    conn = _connect(db_path)
    try:
        row = search_mod.get_chunk(conn, chunk_id)
    finally:
        conn.close()
    if row is None:
        return None
    return Chunk(
        chunk_id=row["chunk_id"], source=row["source"],
        cluster=row["cluster"], section=row["section"],
        page=row["page"], text=row["text"],
    )
