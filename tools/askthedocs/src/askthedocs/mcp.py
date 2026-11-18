"""The MCP face of askthedocs — corpus search with citations.

Two tools over the one chunk store, the same engine the CLI prints
from and the service serves: ``search_docs`` and ``get_chunk``. An
MCP answer and a CLI answer can never disagree — both render the
same library results. The store covers the manuals (TeX), text-rich
PDFs, the GUI reST docs, the doc/LOG changelog, the DivGeo HTML
manual, the b2mn.dat switch inventory, and the B2.5 + EIRENE Fortran
source indexed by procedure unit; it is located through the standard
discovery ladder (environment override, launch-directory artifact, the
index home, the per-user share by default, moved wholesale by
ASKTHEDOCS_HOME) and only ever opened read-only.

Run with ``askthedocs-mcp`` (or ``python -m askthedocs.mcp``).
"""

from __future__ import annotations

from askthedocs._sqlite import sqlite3
from pathlib import Path

from mcp.server.mcpserver import MCPServer

from askthedocs import __version__, api, locate

#: Session-start usage card — the initialize handshake carries it and
#: MCP clients inject it into the consuming model's context; the same
#: text is served on demand as the how_to_search prompt.  It states the
#: two-step loop and the relay contract: the chunk id is the deep link,
#: and an answer that drops it strands the reader with a citation they
#: cannot fetch.
USAGE_CARD = """Using askthedocs: the two-step loop.

1. search_docs('<terms>'): ranked, cited hits; EVERY hit carries its
   chunk id (40 hex characters) plus source, cluster and section.
2. get_chunk('<chunk id>'): that exact passage, verbatim, with full
   provenance. One call, no re-search: the id IS the deep link.

Relay contract: include every hit's chunk id in any answer you give;
it is the only handle get_chunk accepts (the web client's copy buttons
produce the same ids). Worked example:

  search_docs('feedback schemes')
    -> [1] SOLPS-Tutorials/docs/feature_blog/Gas_puffing_and_pumping.md
         section: Gas puffing and pumping > Density feedback schemes
         id: ec9ff6572b5dc079bee027db8e9a13311eee061e
  get_chunk('ec9ff6572b5dc079bee027db8e9a13311eee061e')
    -> the exact passage (the NEW/OLD feedback-scheme switch warning),
       ready to quote with its citation."""

mcp = MCPServer("askthedocs", version=__version__, instructions=USAGE_CARD)


@mcp.prompt()
def how_to_search() -> str:
    """The worked example: search, read the hit's chunk id, fetch the
    exact passage: the intended way to hand a citation across."""
    return USAGE_CARD


#: Cap on search_docs' limit.  The hit query reads each row's FULL text
#: (occurrence counts ride along), so a huge limit would pull every
#: matching chunk into one response string; the recovery card and
#: paging exist for exploration.  Clamping is stated in the answer,
#: never silent.
_MCP_LIMIT_CAP = 200


@mcp.tool()
def search_docs(query: str, limit: int = 10, cluster: str = "",
                db: str = "") -> str:
    """Search the SOLPS-ITER documentation corpus: manuals (TeX),
    text-rich PDFs, GUI reST docs, the dated doc/LOG changelog, the DivGeo
    HTML manual, the b2mn.dat switch inventory (cluster `source_switch`)
    and the B2.5 + EIRENE Fortran source indexed by procedure unit
    (cluster `fortran_source`), with BM25 ranking (plain multi-term
    queries rank exact-adjacency phrase hits first, each marked
    `phrase:` on its hit; a hit whose citation IS the query ranks
    first of all) and highlighted citation snippets.  Manual and
    code chunks rank TOGETHER in one result, each hit labeled with
    its cluster, so an answer can cite the documentation AND the
    implementing Fortran line.  Pass `cluster` (e.g. "fortran_source")
    to narrow the result to one corpus; cluster `log` narrows to the
    dated changelog.
    Powered by the askthedocs chunk store, the same engine as the
    askthedocs CLI.

    Call this for any documentation question ('what does X do', 'how do I
    set Y', 'where is Z documented', 'which subroutine implements Z')
    INSTEAD of grepping the repos or reading raw PDFs/TeX: every hit
    cites source + section/page and carries a chunk_id; fetch the full
    passage with get_chunk.

    Output contract: every hit's chunk id must survive into your
    answer: it is the only key get_chunk accepts (one call returns
    that exact passage). Relay the ids; never summarize them away."""
    try:
        clamped = limit > _MCP_LIMIT_CAP
        result = api.search(query, db_path=Path(db) if db else None,
                            limit=min(limit, _MCP_LIMIT_CAP),
                            cluster=cluster or None)
    except FileNotFoundError as exc:
        return f"ERROR: {exc}"
    except (ValueError, sqlite3.OperationalError) as exc:
        return f"ERROR: query failed: {exc}"

    if not result.hits:
        scope = f" in cluster {cluster}" if cluster else ""
        out = [f"no hits for:{scope} {query}"]
        # the zero-hit recovery card — grounded recovery path, the
        # same library enumeration the web zero-state renders: only
        # words that CO-OCCUR with the rest of the query, each with
        # its true click-yield count (side-by-side count riding
        # along), side-by-side tier first; when nothing combines, the
        # escape hatch offers each typed term that yields hits alone
        if result.did_you_mean:
            out.append(f'  did you mean "{result.did_you_mean}"?')
        if result.completions:
            shown = ", ".join(
                f"{w} ({n}, {a} side-by-side)" if a else f"{w} ({n})"
                for w, n, a in result.completions[:8])
            last = query.split()[-1] if query.split() else query
            out.append(f"  words starting with '{last}': {shown}")
        elif result.separate_terms:
            shown = ", ".join(f"{t} ({n})"
                              for t, n in result.separate_terms)
            out.append(f"  but we have results for: {shown}")
        if result.absent_legs:
            named = " / ".join(result.absent_legs)
            out.append(f"  the answer might be in {named}: not indexed "
                       "on this machine")
        return "\n".join(out)
    note = (f" (showing {len(result.hits)} of {result.total}; raise limit for more)"
            if result.total > len(result.hits) else "")
    if clamped:
        note += f" [limit capped at {_MCP_LIMIT_CAP}]"
    scope = f" in cluster {cluster}" if cluster else ""
    out = [f"{result.total} hits for:{scope} {query}{note}"]
    for i, hit in enumerate(result.hits, 1):
        where = hit.source + (f" p.{hit.page}" if hit.page is not None else "")
        out += ["", f"[{i}] {where}"]
        out.append(f"    cluster: {hit.cluster}")
        if hit.section:
            out.append(f"    section: {hit.section}")
        if hit.identity:
            # identity tier: this chunk's citation IS the query — the
            # exact-key equality, ranked ahead of everything
            out.append(f"    exact name: citation is '{hit.section}'"
                       " (ranked first)")
        if hit.phrase_hit:
            # phrase tier: plain multi-term queries rank hits
            # containing the tokens as one adjacent phrase first
            out.append(f"    phrase: query terms adjacent (ranked first)")
        out.append(f"    id: {hit.chunk_id}")
        out.append(f"    {hit.snippet}")
    out += ["", "fetch the full passage with get_chunk(chunk_id).",
            "relay contract: keep every hit's id in your answer: it is "
            "the deep-link key get_chunk needs."]
    return "\n".join(out)


@mcp.tool()
def get_chunk(chunk_id: str, db: str = "") -> str:
    """Fetch one documentation chunk in full by its chunk_id (as returned
    by a search_docs hit): the complete passage plus its provenance:
    source path, section, page. Use it to quote the exact manual text
    behind a search hit before citing it in an answer. The chunk id is
    the deep-link key: paste it verbatim from a search hit (or the web
    client's copy buttons); one call, no re-search."""
    try:
        chunk = api.get(chunk_id, db_path=Path(db) if db else None)
    except FileNotFoundError as exc:
        return f"ERROR: {exc}"
    if chunk is None:
        return f"ERROR: no chunk with id {chunk_id}"
    return "\n".join([
        f"chunk_id:  {chunk.chunk_id}",
        f"source:    {chunk.source}",
        f"cluster:   {chunk.cluster}",
        f"section:   {chunk.section if chunk.section is not None else '-'}",
        f"page:      {chunk.page if chunk.page is not None else '-'}",
        "text:",
        chunk.text,
    ])


def main() -> None:
    """Console entry point (``askthedocs-mcp``)."""
    mcp.run()


if __name__ == "__main__":
    main()
