"""Read path over the chunk store): search + fetch.

``askthedocs build`` is the only writer; every face reads the same
artifact.  These helpers open the database read-only (``mode=ro`` URI)
so the CLI — and later the MCP/API/web faces+) — can never
mutate it.

Ranking is FTS5 ``bm25()`` with ``rowid`` as the deterministic
tie-breaker (insert order is fixed by the build, so equal-score hits
print in a stable order) — PLUS the implicit phrase tier: a query
of two or more PLAIN terms (whitespace-separated letter/digit runs, no
FTS5 syntax) ranks hits containing the query's tokens as ONE ADJACENT
PHRASE ahead of all others, bm25 still ordering within each tier and
``score``/``rank`` still the pure bm25 value (nothing blended, nothing
re-derived).  Single-term and explicit-syntax queries keep the pure
bm25 order.  Each hit carries ``phrase_hit`` — the visible marker of
the tier (honesty rule, §Service tier). Widens
MEMBERSHIP, not ranking: every plain term matches its regular
singular/plural counterpart as an either/or (``expanded_match_expr``),
the matched-terms panel naming the form(s) that hit; non-plain
queries keep exact semantics.  Snippets come from
FTS5 ``snippet()`` with guillemet markers — verified absent from the
corpus text (0 of 39,019 chunks contain ``«`` or ``»``, 2026-09-24),
so a marker in output is always a match highlight, never source
content.
"""

from __future__ import annotations

import itertools
import re
import sqlite3
from pathlib import Path
from typing import Any, Iterable

# highlight markers around matched terms in snippets
HIGHLIGHT_OPEN = "«"
HIGHLIGHT_CLOSE = "»"
SNIPPET_ELLIPSIS = "…"
# snippet window length in tokens (FTS5 snippet() 6th argument)
SNIPPET_TOKENS = 16


def _ascii_lower(s: str) -> str:
    """Lower ASCII letters only — exactly the set SQL ``lower()`` folds.
    Both sides of the identity-tier equality fold identically, so an
    accented heading still matches its accented query."""
    return "".join(c.lower() if "A" <= c <= "Z" else c for c in s)


_COUNT_SQL = "SELECT COUNT(*) FROM chunks_fts WHERE chunks_fts MATCH ?"
# the hit query also reads `text` — occurrence counts are
# computed over the FULL chunk, not the 16-token snippet window.  The
# extra column changes no ordering (ORDER BY/LIMIT untouched).
_SELECT_SQL = (
    "SELECT chunk_id, source, cluster, section, page,"
    " snippet(chunks_fts, 0, ?, ?, ?, ?) AS snippet,"
    " bm25(chunks_fts) AS rank, 0 AS phrase_hit,"
    # identity tier: the hit's citation name IS the query —
    # lower()/lower() ASCII folding both sides (SQL-consistent)
    " COALESCE(lower(section) = ?, 0) AS identity_hit, text"
    " FROM chunks_fts WHERE chunks_fts MATCH ?"
)
_SELECT_TAIL = (" ORDER BY identity_hit DESC, bm25(chunks_fts), rowid"
                " LIMIT ?")
# phrase tier: the plain-form statement joins the set of rowids
# matching the query tokens AS A PHRASE, then sorts tier-first.  The
# join is a SECOND FTS5 MATCH scan (measured ~1–3 ms on the 48,033-
# chunk store); the outer table must stay UN-aliased — FTS5's aux
# functions (bm25/snippet) do not resolve through an alias in this
# join shape ("no such column", verified 2026-10-20).  An explicit
# two-key sort (tier, then bm25) instead of an additive score boost:
# no magic constant to size, mathematically absolute tiering, and the
# per-hit score stays pure bm25 (the frozen v1 contract's wording).
_SELECT_SQL_TIERED = (
    "SELECT chunk_id, source, cluster, section, page,"
    " snippet(chunks_fts, 0, ?, ?, ?, ?) AS snippet,"
    " bm25(chunks_fts) AS rank,"
    " COALESCE(lower(section) = ?, 0) AS identity_hit,"
    " (phrase.rowid IS NOT NULL) AS phrase_hit, text"
    " FROM chunks_fts"
    " LEFT JOIN (SELECT rowid FROM chunks_fts WHERE chunks_fts MATCH ?)"
    " AS phrase ON chunks_fts.rowid = phrase.rowid"
    " WHERE chunks_fts MATCH ?"
)
_SELECT_TAIL_TIERED = (" ORDER BY identity_hit DESC, phrase_hit DESC,"
                       " bm25(chunks_fts), rowid LIMIT ?")
# joined retrieval: optional cluster restriction bolted onto the
# same two statements (`cluster` is an UNINDEXED column of chunks_fts, so
# the filter is a plain WHERE term — no join, one query shape).  In the
# SELECT it must sit BEFORE the ORDER BY/LIMIT tail — appended after
# LIMIT the term parses inside the LIMIT expression ("no such column:
# cluster").
_CLUSTER_TERM = " AND cluster = ?"
# facets: one GROUP BY over the same MATCH expression the hit
# query uses — no join, no second index.  Equal counts (measured:
# wall_geometry ties fortran_source/gui_docs at 5) would make a bare
# count-desc order unstable across scans, so cluster ASC is the
# deterministic tie-breaker.
_FACET_SQL = ("SELECT cluster, COUNT(*) AS count FROM chunks_fts"
              " WHERE chunks_fts MATCH ?"
              " GROUP BY cluster ORDER BY count DESC, cluster")
_GET_SQL = ("SELECT chunk_id, source, cluster, section, page, text"
            " FROM chunks WHERE chunk_id = ?")


def connect(db_path: Path) -> sqlite3.Connection:
    """Open the chunk store READ-ONLY (raises if the file is absent)."""
    conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    conn.row_factory = sqlite3.Row
    return conn


def quote_query(query: str) -> str:
    """Every whitespace-separated term double-quoted (implicit AND,
    punctuation literal — internal quotes doubled per FTS5 syntax)."""
    return " ".join('"' + term.replace('"', '""') + '"'
                    for term in query.split())


def match_expr(conn: sqlite3.Connection, query: str) -> str:
    """Validated FTS5 MATCH expression for a user query.

    The raw input is tried first so power users keep full FTS5 syntax
    (phrases, OR, NEAR, ``term*`` prefixes).  Queries the tokenizer
    cannot parse — measured failure: a bare hyphen token like
    ``wall-geometry`` parses as column-filter syntax and raises
    ``no such column: geometry`` — fall back to every term quoted.
    Raises ValueError on an empty query; re-raises OperationalError
    when even the quoted form is invalid.
    """
    expr = query.strip()
    if not expr:
        raise ValueError("empty query")
    try:
        conn.execute(_COUNT_SQL, (expr,)).fetchone()
        return expr
    except sqlite3.OperationalError:
        quoted = quote_query(expr)
        conn.execute(_COUNT_SQL, (quoted,)).fetchone()
        return quoted


# FTS5 operator words, UPPERCASE only — lowercase ``or`` is a plain
# term to FTS5, so only the exact uppercase forms disqualify a query
# from the phrase tier (they carry explicit syntax meaning)
_FTS5_OPERATORS = {"OR", "AND", "NOT", "NEAR"}


def _plain_tokens(query: str) -> list[str] | None:
    """All whitespace tokens as maximal letter/digit runs, none an
    uppercase FTS5 operator — the plainness test the phrase tier
    and the completion tier share. None when the query carries
    any syntax (operators, punctuation, quotes — power users have
    expressed their own intent and keep exact semantics).
    """
    tokens = query.split()
    if not tokens:
        return None
    for token in tokens:
        if _TERM_RE.fullmatch(token) is None or token in _FTS5_OPERATORS:
            return None
    return tokens


def _partner(token: str) -> str:
    """The regular singular/plural counterpart (— the word plus
    ``s``, or the word minus its trailing ``s``.  ONLY the regular
    pair: the es/ies families and every other morphology stay out
    (the measured dirty merges — limiter/limit, average/averaged —
    are excluded by construction; a nonexistent partner simply matches
    nothing)."""
    if token.endswith("s") and len(token) > 1:
        return token[:-1]
    return token + "s"


def expanded_match_expr(conn: sqlite3.Connection, query: str) -> str:
    """membership expression for *query*.

    Plain queries (see :func:`_plain_tokens`) match every term as an
    either/or with its regular plural partner — ``limiter
    configurations`` becomes ``("limiter" OR "limiters")
    ("configurations" OR "configuration")`` — widening recall
    (measured: boundary conditions 407 -> 657 chunks) while the
    totals, facets and hits all flow from this one expression.
    Non-plain queries keep the raw/quoted-fallback path: exact
    semantics for power syntax, unchanged.
    """
    tokens = _plain_tokens(query)
    if tokens is None:
        return match_expr(conn, query)

    def group(token: str) -> str:
        partner = _partner(token)
        if partner == token:
            return f'"{token}"'
        return f'("{token}" OR "{partner}")'

    # explicit AND: FTS5's implicit AND binds bare phrases only — a
    # parenthesized group juxtaposed with anything else is a syntax
    # error (measured 2026-10-21)
    return " AND ".join(group(t) for t in tokens)


def expanded_terms(query: str) -> list[str]:
    """The matched-terms panel's term list under : each plain
    query token followed by its plural partner, first-seen order —
    the panel names which FORM(S) actually matched.  Non-plain queries
    keep :func:`query_terms` (the typed tokens only)."""
    tokens = _plain_tokens(query)
    if tokens is None:
        return query_terms(query)
    terms: list[str] = []
    for token in tokens:
        for form in (token, _partner(token)):
            if form not in terms:
                terms.append(form)
    return terms


def phrase_expr(query: str) -> str | None:
    """The phrase-tier MATCH expression for *query*, or None.

    The tier applies only to PLAIN multi-term queries (see
    :func:`_plain_tokens`), at most four tokens (the form
    combinations are a product — four tokens already span sixteen
    phrase alternatives; beyond that the tier is skipped, pure bm25).
    Single-token queries get no tier (the phrase degenerates to the
    term); queries carrying any other syntax keep pure bm25.
    Punctuation between terms is NOT allowed to form the tier:
    ``limiter, configurations`` is not plain, while ``limiter
    configurations`` is.

    : EITHER FORM satisfies adjacency — the expression is the OR
    of every form combination (``("limiter configurations" OR
    "limiter configuration" OR …)``), so a chunk reading "limiter
    configuration" tiers for the query "limiter configurations".
    Always valid FTS5 by construction, so unlike :func:`match_expr`
    no validation round-trip is needed.
    """
    tokens = _plain_tokens(query)
    if tokens is None or not 2 <= len(tokens) <= 4:
        return None
    combos = itertools.product(*[(t, _partner(t)) for t in tokens])
    phrases = ['"' + " ".join(c) + '"' for c in combos]
    return "(" + " OR ".join(phrases) + ")"


# term extraction: maximal runs of letters/digits — the
# character classes FTS5's default unicode61 tokenizer treats as token
# characters (punctuation and separators split tokens, so the hyphen
# or underscore in ``wall_geometry`` yields the two tokens wall +
# geometry, exactly as the index sees them).  Case is folded to match
# unicode61's case-folding.  FTS5 operators (OR, NEAR, ``*``) are NOT
# special-cased — the honesty rule in §Service tier.
_TERM_RE = re.compile(r"[^\W_]+", re.UNICODE)


def query_terms(query: str) -> list[str]:
    """Unique letter/digit runs of *query*, case-folded, first-seen order."""
    terms: list[str] = []
    for term in (t.casefold() for t in _TERM_RE.findall(query)):
        if term not in terms:
            terms.append(term)
    return terms


def matched_terms(text: str,
                  terms: Iterable[str]) -> list[tuple[str, int]]:
    r"""Per-term occurrence counts in *text*: ``[(term, n)]`` for the
    terms PRESENT (``n ≥ 1``), absent terms omitted, *terms* order kept.

    Counts are token-equality counts under the same tokenizer as
    :func:`query_terms` — term presence + frequency, never a per-term
    score decomposition.

    Implementation note: the count equals ``findall(r"[^\W_]+",
    text.casefold()).count(term)`` but is computed WITHOUT materializing
    every token of the text: one ``casefold`` pass, then per term a
    ``str.find`` loop (C-speed) that counts only occurrences flanked by
    non-token characters — a term, itself a maximal token run
    (:func:`query_terms` output), occurs as a whole token exactly there.
    Same numbers, far cheaper on the ~0.5 MB fortran chunks whose
    full tokenization was the /search p95 tail.
    """
    folded = text.casefold()
    counts: list[tuple[str, int]] = []
    for term in terms:
        n = _count_token(folded, term)
        if n:
            counts.append((term, n))
    return counts


# a token character as the tokenizer sees it ([^\W_]): Python's \w is
# defined as isalnum() plus underscore, so minus the underscore the
# test is exactly str.isalnum — no regex needed per occurrence
def _is_token_char(ch: str) -> bool:
    return ch.isalnum()


def _count_token(folded: str, term: str) -> int:
    """Occurrences of *term* (already case-folded) as a whole token in
    *folded* (already case-folded) — token-equality, never substring."""
    if not term:
        return 0
    n = 0
    start = 0
    while True:
        i = folded.find(term, start)
        if i < 0:
            return n
        end = i + len(term)
        if ((i == 0 or not folded[i - 1].isalnum())
                and (end == len(folded) or not folded[end].isalnum())):
            n += 1
        start = i + 1


def search(conn: sqlite3.Connection, query: str, limit: int = 20,
           cluster: str | None = None) -> tuple[int, list[sqlite3.Row]]:
    """Ranked hits for *query*: ``(total_matching, rows)``.

    ``total_matching`` counts every matching chunk; ``rows`` is at most
    ``limit`` of them, best first — bm25, except that a PLAIN
    multi-term query (ranks its phrase-adjacent hits ahead of
    all others (bm25 still ordering within each tier; ``rank`` stays
    the pure bm25 value either way), and the IDENTITY tier ranks
    ahead of both: a hit whose citation name (section) EQUALS the
    query — trimmed, case-insensitive, the exact-key discipline —
    sorts first, whatever its bm25 (identity leads results, never
    creates them: membership, ``total`` and facets are unchanged).
    Row fields: chunk_id, source, cluster, section, page, snippet,
    rank, identity_hit, phrase_hit, text — ``identity_hit`` is 1
    exactly when this chunk's section equals the query;
    ``phrase_hit`` is 1 exactly when the tier applied and this chunk
    matched the query tokens as an adjacent phrase.  ``cluster``
) restricts both the total and the rows to one cluster —
    manual, switch and Fortran chunks live in one ranked result by
    default, and the caller can narrow it without a second query
    shape.  An unknown cluster is a valid answer: 0 hits, not an
    error.
    """
    if limit < 1:
        raise ValueError(f"limit must be >= 1, got {limit}")
    expr = expanded_match_expr(conn, query)
    tier = phrase_expr(query)
    # the identity comparison value — the query as typed, trimmed,
    # ASCII-lowered to match SQL lower() on the section: SQL folds
    # ASCII only, so the bind value must too (a full-Unicode Python
    # lower() would fold accented capitals on one side of the
    # equality but not the other and silently miss the identity tier)
    identity_q = _ascii_lower(query.strip())
    term = _CLUSTER_TERM if cluster is not None else ""
    total = int(conn.execute(_COUNT_SQL + term,
                             (expr, cluster) if cluster is not None
                             else (expr,)).fetchone()[0])
    if tier is not None:
        rows = conn.execute(
            _SELECT_SQL_TIERED + term + _SELECT_TAIL_TIERED,
            (HIGHLIGHT_OPEN, HIGHLIGHT_CLOSE, SNIPPET_ELLIPSIS,
             SNIPPET_TOKENS, identity_q, tier, expr,
             *((cluster,) if cluster is not None else ()), limit),
        ).fetchall()
    else:
        rows = conn.execute(
            _SELECT_SQL + term + _SELECT_TAIL,
            (HIGHLIGHT_OPEN, HIGHLIGHT_CLOSE, SNIPPET_ELLIPSIS,
             SNIPPET_TOKENS, identity_q, expr,
             *((cluster,) if cluster is not None else ()), limit),
        ).fetchall()
    return total, rows


# completion-tier guard: the last typed word must be this long
# before prefix suggestions fire (1–2 character prefixes match
# thousands of chunks of pure noise — measured: the worst 2-char stem
# hits 13,376 chunks; the guard is quality, not performance)
_TYPEAHEAD_MIN = 3

# the completion tier's rows — same shape as :func:`search`
# rows, but the MATCH is the prefix form (all tokens except the last
# exact, the last as a prefix) MINUS every rowid the exact expression
# already matches (all of them, not just the displayed page — a hit
# must never appear twice across the tiers), ordered prefix-phrase-
# adjacency first (the tier over the last token as prefix) then
# bm25 of the prefix expression.  Three MATCH scans per keystroke,
# each measured in single-digit milliseconds.
_SELECT_SQL_COMPLETION = (
    "SELECT chunk_id, source, cluster, section, page,"
    " snippet(chunks_fts, 0, ?, ?, ?, ?) AS snippet,"
    " bm25(chunks_fts) AS rank,"
    # a completion row is never an identity hit — suggestions
    # extend a prefix; the constant keeps the row shape uniform
    " 0 AS identity_hit,"
    " (pphrase.rowid IS NOT NULL) AS phrase_hit, text"
    " FROM chunks_fts"
    " LEFT JOIN (SELECT rowid FROM chunks_fts WHERE chunks_fts MATCH ?)"
    " AS pphrase ON chunks_fts.rowid = pphrase.rowid"
    " WHERE chunks_fts MATCH ?"
    " AND chunks_fts.rowid NOT IN"
    " (SELECT rowid FROM chunks_fts WHERE chunks_fts MATCH ?)"
)


def typeahead_search(conn: sqlite3.Connection, query: str, limit: int = 20,
                     cluster: str | None = None
                     ) -> tuple[int, list[sqlite3.Row], int, list[sqlite3.Row]]:
    """tiered answer for one typing state: ``(exact_total,
    exact_rows, completion_total, completion_rows)``.

    Tier 1 is EXACTLY :func:`search` on the query — the committed
    semantics, in the committed order, so the preview's head always
    equals what committing produces.  Tier 2 is the completion tier:
    rows matching every token except the last exactly and the last as
    a PREFIX, minus every exact-match rowid, prefix-adjacency first —
    present only while the query is plain and its last token is at
    least :data:`_TYPEAHEAD_MIN` characters.  Non-plain queries keep
    a one-tier answer (exact only); the cluster filter narrows both
    tiers identically.
    """
    total, tier1 = search(conn, query, limit, cluster=cluster)
    tokens = _plain_tokens(query)
    if tokens is None or len(tokens[-1]) < _TYPEAHEAD_MIN:
        return total, tier1, 0, []
    # head tokens expand to their plural partners (either form
    # satisfies the term); the LAST token is the prefix — which already
    # spans its whole morphology family ("configur"* covers
    # configuration and configurations alike)
    exact_expr = expanded_match_expr(conn, query)
    prefix_expr = " AND ".join(
        [f'("{t}" OR "{_partner(t)}")' if _partner(t) != t else f'"{t}"'
         for t in tokens[:-1]]
        + ['"%s"*' % tokens[-1]])
    phrase_prefix = '"' + " ".join(tokens) + '"*'
    term = _CLUSTER_TERM if cluster is not None else ""
    comp_total = int(conn.execute(
        "SELECT COUNT(*) FROM chunks_fts WHERE chunks_fts MATCH ?"
        " AND rowid NOT IN (SELECT rowid FROM chunks_fts"
        " WHERE chunks_fts MATCH ?)" + term,
        (prefix_expr, exact_expr,
         *((cluster,) if cluster is not None else ())),
    ).fetchone()[0])
    if comp_total == 0:
        return total, tier1, 0, []
    rows = conn.execute(
        _SELECT_SQL_COMPLETION + term + _SELECT_TAIL_TIERED,
        (HIGHLIGHT_OPEN, HIGHLIGHT_CLOSE, SNIPPET_ELLIPSIS,
         SNIPPET_TOKENS, phrase_prefix, prefix_expr, exact_expr,
         *((cluster,) if cluster is not None else ()), limit),
    ).fetchall()
    return total, tier1, comp_total, rows


#: the completion walk's probe alphabet — corpus tokens are
# case-folded letter/digit runs, so a-z + 0-9 covers every extension;
# the walk's probe budget (each probe is one indexed prefix COUNT,
# measured single-digit milliseconds — the budget bounds the
# pathological one-letter-prefix case; the display shows the top by
# count either way, and every count shown stays exact)
_COMPLETION_ALPHABET = "abcdefghijklmnopqrstuvwxyz0123456789"
_COMPLETION_PROBE_BUDGET = 1200


def _count_matches(conn: sqlite3.Connection, expr: str,
                   cluster: str | None = None) -> int:
    """Exact COUNT over one validated MATCH expression, under the
    cluster filter in force (the shape every card probe uses)."""
    term = _CLUSTER_TERM if cluster is not None else ""
    params = (expr, cluster) if cluster is not None else (expr,)  # noqa: E731
    return int(conn.execute(_COUNT_SQL + term, params).fetchone()[0])


def completions(conn: sqlite3.Connection, prefix: str,
                max_words: int = 12,
                cluster: str | None = None,
                rest_expr: str = "") -> list[tuple[str, int]]:
    """+ (a): corpus words extending *prefix*, with EXACT
    click-yield counts, count-desc — ``[(word, count)]``, at most
    *max_words*; plural families fold to ONE row labeled by the more
    frequent form.

    A read-only trie walk over the index's own prefix counts, every
    probe gated by *rest_expr* — the validated plural-widened AND of
    the query's OTHER terms. hard rule (never suggest a dead
    end) is structural here: a branch with no co-occurrence under
    *rest_expr* is never descended, so a truncated walk can only omit
    rare tails, never miscount, and no returned word can yield zero.
    A word's count is what CHOOSING it yields: the rest terms AND the
    word's whole morphology family (``scheme``/``schemes`` is one
    outcome), under the cluster filter in force (the facet honesty
    rule).  With no *rest_expr* (single-token query) the count is the
    word's own widened standalone yield.
    """
    prefix = prefix.casefold()

    def gated(expr: str) -> int:
        full = f"{rest_expr} AND {expr}" if rest_expr else expr
        return _count_matches(conn, full, cluster)

    forms: dict[str, int] = {}  # per FORM: chunks matching rest AND form
    probes = 0

    def walk(node: str) -> None:
        nonlocal probes
        for ch in _COMPLETION_ALPHABET:
            if probes >= _COMPLETION_PROBE_BUDGET:
                return
            probes += 1
            child = node + ch
            if not gated(f'"{child}"*'):
                continue
            n = gated(f'"{child}"')
            if n:
                forms[child] = n
            if len(child) < 32:
                walk(child)

    walk(prefix)
    # (a): fold the regular plural pair into one row — either form
    # chosen commits the SAME widened query, so the pair is one outcome
    # (scheme 240 + schemes 74 as two rows was a dishonest difference;
    # the click always delivered both).  Label: the more frequent form
    # under the gate in force, ties to the shorter (singular) form.
    families: dict[str, tuple[str, int]] = {}  # family key -> (label, yield)
    for form, n in forms.items():
        partner = _partner(form)
        key = min(form, partner)
        if key not in families:
            families[key] = (
                form, gated(f'("{form}" OR "{partner}")'))
        else:
            label, _yield = families[key]
            if (n > forms.get(label, 0)
                    or (n == forms.get(label, 0)
                        and len(form) < len(label))):
                families[key] = (form, _yield)
    found = sorted(families.values(), key=lambda wc: (-wc[1], wc[0]))
    return found[:max_words]


def boundary_completions(conn: sqlite3.Connection, query: str,
                         cluster: str | None = None
                         ) -> tuple[list[tuple[str, int, int]], str | None,
                                    list[tuple[str, int]]]:
    """+ + : the zero-hit recovery card as data —
    ``([words], did_you_mean, [separate])``.

    *words* is ``[(word, count, adjacent)]``: corpus words extending
    the last token that CO-OCCUR with the rest of the query (
    hard rule — exclusion, never demotion), each with its true
    click-yield *count* and, of those, how many are *adjacent* (the
    definition: the full term sequence side-by-side in typed
    order, plural form either way satisfying it — the card's tier
    predicts the results' own phrase marker exactly). (b) orders
    side-by-side words first, then same-chunk co-occurrence, each
    tier by true yield; *did_you_mean* is the first row — guaranteed
    nonzero whenever a card shows.  Non-plain queries keep exact
    semantics and their own error surface (everything empty).

    *separate* is the (c) escape hatch, filled ONLY when no
    extending word combines: every typed term as a clickable one-term
    search with its true solo yield — terms that yield nothing solo
    are never offered (a typo'd term must not reappear as a dead
    click), so when even this list is empty the zero is honest and
    bare (dead end). ``cluster`` flows to every probe.
    """
    tokens = _plain_tokens(query)
    if tokens is None or not tokens:
        return [], None, []
    last = tokens[-1].casefold()
    if not last:
        return [], None, []
    others = [t.casefold() for t in tokens[:-1]]
    # the rest gate: plural-widened explicit AND, the same shape the
    # committed query's expression uses for these terms
    rest_expr = ""
    if others:
        rest_expr = " AND ".join(
            f'("{t}" OR "{_partner(t)}")' if _partner(t) != t else f'"{t}"'
            for t in others)
    words = completions(conn, last, cluster=cluster, rest_expr=rest_expr)
    rows: list[tuple[str, int, int]] = []
    for word, count in words:
        adjacent = 0
        pexpr = phrase_expr(" ".join([*others, word]))
        if pexpr is not None:
            adjacent = _count_matches(conn, pexpr, cluster)
        rows.append((word, count, adjacent))
    # (b): side-by-side tier first, each tier by true click-yield
    rows.sort(key=lambda wca: (wca[2] == 0, -wca[1], wca[0]))
    did_you_mean = rows[0][0] if rows else None
    separate: list[tuple[str, int]] = []
    if not rows:
        for token in dict.fromkeys(t.casefold() for t in tokens):
            partner = _partner(token)
            group = (f'("{token}" OR "{partner}")' if partner != token
                     else f'"{token}"')
            n = _count_matches(conn, group, cluster)
            if n:
                separate.append((token, n))
    return rows, did_you_mean, separate


def facets(conn: sqlite3.Connection, query: str) -> list[sqlite3.Row]:
    """Per-cluster match counts for *query*): rows of
    ``(cluster, count)``, count-desc then cluster-asc.

    One ``GROUP BY`` over the same validated MATCH expression
    :func:`search` ranks by, so a chip count is the ``total`` the user
    would get by filtering to that cluster — the drill-in never
    promises a number the filter cannot reproduce.  Deliberately NOT
    restricted by any cluster filter: chips must keep showing every
    cluster's count while one is selected (the filter narrows rows,
    not the facet population).
    """
    expr = expanded_match_expr(conn, query)
    return conn.execute(_FACET_SQL, (expr,)).fetchall()


def get_chunk(conn: sqlite3.Connection, chunk_id: str) -> sqlite3.Row | None:
    """One chunk by ID (chunk_id, source, cluster, section, page, text),
    or None when the ID is unknown."""
    return conn.execute(_GET_SQL, (chunk_id,)).fetchone()


def distinct_sources(conn: sqlite3.Connection, query: str) -> int:
    """Number of distinct sources matching *query* (golden metric)."""
    expr = expanded_match_expr(conn, query)
    row: Any = conn.execute(
        "SELECT COUNT(DISTINCT source) FROM chunks_fts WHERE chunks_fts MATCH ?",
        (expr,),
    ).fetchone()
    return int(row[0])
