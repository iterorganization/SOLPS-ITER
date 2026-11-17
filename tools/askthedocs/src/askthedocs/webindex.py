"""Per-chunk HTML pages — the fragmented-index input).

`askthedocs build` writes, beside the SQLite store, one minimal HTML page
per chunk under ``out/web/pages/<chunk_id>.html``.  These pages are the
input a fragmented static-search engine (Pagefind-class) crawls at
build time; at runtime only the engine's ~100 KB JS+WASM entry loads
up front and KB-scale fragments are fetched over HTTP per query.  The
pages are a disposable projection of the store (rebuilt from it, never
edited) — one chunk store, many faces.

Page contract — every rule below MEASURED against Pagefind 1.5.2 on
probe fixtures, 2026-09-24 (see "Web search architecture
)"; the probe scripts live in tools/pagefind-eval/):

* ``<main data-pagefind-body>`` scopes content indexing to EXACTLY the
  chunk text — recall parity with FTS5 (which indexes text only) is
  the contract, so no other words may enter the index.
* ``data-pagefind-filter`` spans (cluster + coarse facet) live in the
  ``<header>``, OUTSIDE the body: measured — outside-body filter
  values ARE collected (result.filters, ``filters()`` counts) and are
  NOT content-indexed (searching the value returns 0 hits).  In-body
  filter spans leak their text into the index; never do that.
* ``data-pagefind-meta`` is NOT used: measured — meta element values
  are content-indexed in EVERY placement tried (in body, inside
  ``data-pagefind-ignore``, outside body).  Source/section/page
  provenance therefore travels via the citation page itself (the
  result URL is the chunk page; /d fetch it lazily), never via
  the search index.
* ``<title>`` text is content-indexed even in ``<head>`` (measured),
  so the title is a word-truncated PREFIX of the chunk text — it adds
  zero tokens the body does not already carry (ranking boost at most;
  ranking parity is explicitly not the contract).
* The page URL is ``/<chunk_id>.html`` relative to the site root, so a
  result's URL IS the chunk ID — the join key every face shares, with
  no lookup table.
* Header provenance paragraphs carry semantic classes (``source``,
  ``section``, ``page``, ``chunk-id``): the search UI)
  enriches each result row by lazily fetching the result's own page
  and parsing these classes — they are OUTSIDE the body, so the
  classes add zero indexed tokens. citation view styles the
  same elements.
* citation view: the page a search hit lands on shows the
  FULL text + provenance (a ``<dl>`` whose ``<dt>`` labels sit outside
  the value ``<p>``s, so ``textContent`` of ``header p.<class>`` stays
  the bare value for the parser), a top bar with a back link
  to the search page, and a footer cross-link bar to the run catalog
  mirrored at ``<site root>/catalog/`` by assembly.  Measured
  (2026-09-24 probe, tools/pagefind-eval): ``<style>`` content, nav /
  footer text and label words outside the body add ZERO indexed
  tokens — but the FIRST ``<h1>`` on a page becomes the result's meta
  title (``<title>`` is the fallback) and meta titles ARE searchable,
  so the page heading is a styled ``<p>``, never an ``<h1>``.  The
  stylesheet is one shared file at ``_assets/citation.css`` INSIDE the
  pages tree (relative href, so file:// works; Pagefind ignores
  non-HTML files).

Emission is deterministic: chunks are read in rowid order (build-fixed
insert order), the template is fixed, filenames are the stable chunk
IDs — two emissions over the same store produce byte-identical trees.
"""

from __future__ import annotations

import html
import shutil
from askthedocs._sqlite import sqlite3
from pathlib import Path
from typing import Any

from askthedocs import store

# Coarse facet rollup (docs / fortran_source /
# source_switch / log).  Every documentation cluster rolls up to
#`docs`; (switch inventory) and (Fortran source) add
# the `source_switch` and `fortran_source` values. completes
# the planned set: the switch inventory gets its own facet too, so the
# web filter separates manuals (docs) from both code-derived corpora.
FACET_BY_CLUSTER = {
    "log": "log",
    "source_switch": "source_switch",
    "fortran_source": "fortran_source",
}

# title = chunk-text prefix, cut at a word boundary (measured: <title>
# is content-indexed, so the title may not introduce new tokens).
TITLE_MAX = 80

# Shared stylesheet for the citation view, written INSIDE the pages
# tree so the relative href works served (/<site>/pages/) and opened
# from disk (file://) alike; Pagefind ignores non-HTML files.
ASSET_DIR = "_assets"
STYLESHEET = "citation.css"

CITATION_CSS = """\
/* askthedocs citation view) — pages/_assets/citation.css.
   One shared stylesheet: 39k pages reference it by relative href. */
:root { color-scheme: light; }
* { box-sizing: border-box; }
body { margin: 0; font: 15px/1.6 system-ui, -apple-system, "Segoe UI",
       Roboto, sans-serif; color: #1a202c; background: #fbfcfd; }
.topbar, header, main, footer.crosslinks { max-width: 46rem;
  margin-left: auto; margin-right: auto; }
.topbar { display: flex; justify-content: space-between;
  align-items: baseline; padding: 0.9rem 1rem 0; }
.topbar a { color: #2d3748; text-decoration: none; font-weight: 600; }
.topbar a:hover { text-decoration: underline; }
.topbar .brand { color: #718096; font-size: 0.85rem; }
header, main { padding: 0 1rem; }
/* a styled <p>, NOT an <h1>: pagefind lifts the first h1 into the
   result meta title and meta titles are searchable (measured,
   2026-09-24) — a heading word outside the body would leak */
.view-title { font-size: 1.1rem; font-weight: 700; margin: 1.1rem 0 0.6rem; }
dl.provenance { display: grid; grid-template-columns: max-content 1fr;
  gap: 0.3rem 0.9rem; background: #fff; border: 1px solid #e2e8f0;
  border-radius: 8px; padding: 0.8rem 1rem; margin: 0; font-size: 0.9rem; }
dl.provenance dt { color: #718096; font-weight: 600; font-size: 0.68rem;
  letter-spacing: 0.05em; text-transform: uppercase; padding-top: 0.2rem; }
dl.provenance dd { margin: 0; min-width: 0; }
dl.provenance p { margin: 0; }
p.source, p.chunk-id { font-family: ui-monospace, "SF Mono", Menlo,
  Consolas, monospace; font-size: 0.85rem; word-break: break-all;
  color: #2d3748; }
p.section, p.page { color: #4a5568; }
p.facets { margin: 0.6rem 0 0; }
p.facets span { display: inline-block; font-family: ui-monospace,
  monospace; font-size: 0.72rem; padding: 0.05rem 0.45rem;
  border-radius: 999px; margin-right: 0.3rem; }
p.facets [data-pagefind-filter="cluster"] { background: #ebf8ff;
  border: 1px solid #bee3f8; color: #2a4365; }
p.facets [data-pagefind-filter="facet"] { background: #f0fff4;
  border: 1px solid #c6f6d5; color: #22543d; }
main .text { background: #fff; border: 1px solid #e2e8f0;
  border-radius: 8px; padding: 1rem 1.2rem; margin-top: 1rem; }
main .text p { margin: 0 0 0.85rem; white-space: pre-wrap; }
main .text p:last-child { margin-bottom: 0; }
footer.crosslinks { padding: 1.3rem 1rem 3rem; font-size: 0.9rem; }
footer.crosslinks .xlabel { text-transform: uppercase; font-size: 0.68rem;
  letter-spacing: 0.05em; color: #718096; font-weight: 600;
  margin: 0 0 0.4rem; }
footer.crosslinks ul { margin: 0; padding: 0; list-style: none; }
footer.crosslinks a { color: #0969da; text-decoration: none; }
footer.crosslinks a:hover { text-decoration: underline; }
footer.crosslinks .verify { margin: 1rem 0 0; color: #718096;
  font-size: 0.8rem; }
footer.crosslinks code { font-family: ui-monospace, monospace;
  background: #edf2f7; padding: 0.05rem 0.3rem; border-radius: 4px;
  word-break: break-all; }
"""


def default_pages_dir() -> Path:
    return Path(__file__).resolve().parents[2] / "out" / "web" / "pages"


def facet_for(cluster: str) -> str:
    """Coarse facet of a fine-grained cluster (docs by default)."""
    return FACET_BY_CLUSTER.get(cluster, "docs")


def _title_from_text(text: str) -> str:
    """Word-truncated prefix of *text* — no tokens beyond the body's."""
    prefix = " ".join(text.split())[:TITLE_MAX]
    if len(prefix) == TITLE_MAX:  # cut back to the last word boundary
        cut = prefix.rfind(" ")
        if cut > 0:
            prefix = prefix[:cut]
    return prefix


def page_html(chunk_id: str, source: str, cluster: str,
              section: str | None, page: int | None, text: str) -> str:
    """Render one chunk as its citation-view page (pure, byte-stable).

    : full text + provenance, a back link to the search page,
    and the cross-link bar to the run catalog.  Everything added over
    the bare index-input page lives OUTSIDE ``<main data-pagefind-body>``
    (measured: zero indexed tokens).  The ``<dt>`` labels sit outside
    the value ``<p>``s so ``header p.<class>`` textContent — what the
    search-UI parser reads — stays the bare value. Rows for
    null provenance are omitted entirely (the parser's ``?.`` chain
    maps an absent node to '').
    """
    esc = html.escape
    title = _title_from_text(text)
    header_pg = f"p. {page}" if page is not None else ""

    fields = [
        ("source", f'<p class="source">{esc(source)}</p>' if source else ""),
        ("section", f'<p class="section">{esc(section)}</p>'
         if section is not None else ""),
        ("page", f'<p class="page">{header_pg}</p>' if header_pg else ""),
        ("chunk id", f'<p class="chunk-id">{chunk_id}</p>'),
    ]
    rows = "".join(f"    <dt>{dt}</dt><dd>{dd}</dd>\n"
                   for dt, dd in fields if dd)

    # One <p> per non-blank line: the engine tokenizes text content and
    # ignores markup, so this renders reasonably while indexing exactly
    # the chunk's words (pre-wrap in CSS keeps table-row alignment).
    paras = "\n".join(f"      <p>{esc(line)}</p>"
                      for line in text.split("\n") if line.strip())

    return (
        "<!doctype html>\n"
        '<html lang="en">\n'
        "<head>\n"
        '<meta charset="utf-8">\n'
        f'<link rel="stylesheet" href="{ASSET_DIR}/{STYLESHEET}">\n'
        f"<title>{esc(title)}</title>\n"
        "</head>\n"
        "<body>\n"
        '<nav class="topbar">\n'
        '  <a class="back" href="../index.html">&#8592; askthedocs search</a>\n'
        '  <span class="brand">askthedocs &#183; citation</span>\n'
        "</nav>\n"
        "<header>\n"
        '  <p class="view-title">Citation</p>\n'
        '  <dl class="provenance">\n'
        f"{rows}"
        "  </dl>\n"
        '  <p class="facets">\n'
        f'    <span data-pagefind-filter="cluster">{esc(cluster)}</span>\n'
        f'    <span data-pagefind-filter="facet">{facet_for(cluster)}</span>\n'
        "  </p>\n"
        "</header>\n"
        '<main data-pagefind-body="">\n'
        '  <div class="text">\n'
        f"{paras}\n"
        "  </div>\n"
        "</main>\n"
        '<footer class="crosslinks">\n'
        '  <p class="xlabel">Cross-references</p>\n'
        "  <ul>\n"
        '    <li><a href="../catalog/index.html">'
        "SOLPS-ITER run catalog &#8599;</a></li>\n"
        "  </ul>\n"
        '  <p class="verify">Verify from the terminal: '
        f"<code>askthedocs show {chunk_id}</code></p>\n"
        "</footer>\n"
        "</body>\n"
        "</html>\n"
    )


def write_pages(db_path: Path, pages_dir: Path,
                limit: int | None = None) -> dict[str, Any]:
    """Emit one page per chunk into *pages_dir* (replaced wholesale).

    Reads the store read-only in rowid order; returns a small summary
    dict for the build summary.  *limit* caps emission at the first N
    chunks (rowid order) — smoke-test convenience only.  The shared
    citation stylesheet is written to ``<pages_dir>/_assets/`` beside
    the pages (replaced with the tree).
    """
    pages_dir = Path(pages_dir)
    if pages_dir.exists():
        shutil.rmtree(pages_dir)
    pages_dir.mkdir(parents=True)
    assets = pages_dir / ASSET_DIR
    assets.mkdir()
    (assets / STYLESHEET).write_text(CITATION_CSS, encoding="utf-8")

    conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    conn.row_factory = sqlite3.Row
    try:
        count = 0
        empty = 0
        for row in store.iter_chunks(conn):
            if not row["text"].strip():
                empty += 1  # nothing to index — counted, never guessed
                continue
            if limit is not None and count >= limit:
                break
            page = page_html(row["chunk_id"], row["source"], row["cluster"],
                             row["section"], row["page"], row["text"])
            (pages_dir / f"{row['chunk_id']}.html").write_text(
                page, encoding="utf-8")
            count += 1
    finally:
        conn.close()
    return {"dir": str(pages_dir), "pages": count, "empty_skipped": empty}
