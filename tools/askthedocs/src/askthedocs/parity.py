"""parity contract — two engines, one truth.

The SQLite chunk store is canonical; the Pagefind index is a compiled
projection of it (owner doctrine 2026-09-23).  Content/citation parity
is absolute by construction: only chunk text is indexed).
This module enforces the remaining contract — RECALL parity: for a
fixed golden-query set, the FTS5 face and the Pagefind face must
return the same chunk-ID set.  Ranking parity is explicitly NOT part
of the contract (different scoring algorithms; documented in
"Parity contract)").

Engine tokenizers are fundamentally different (all measured on the
real 43,825-chunk corpus + 43,675-page index, 2026-09-24):

=== FTS5 unicode61 ===
- token = one run of Unicode L*/N* characters: ``b2news_potok`` →
  ``b2news`` ``potok`` (underscore is a separator), ``extrab25`` is
  ONE token, case-folded
- no stemming, no prefix matching unless the query says ``term*``

=== Pagefind 1.5.2 (English wasm) ===
- splits words at letter↔digit boundaries at INDEX time:
  ``extrab25`` → ``extrab`` ``25``; splits camelCase: ``BoRiS`` in
  text never matches query ``boris``
- STEMS queries: ``detach``/``detached``/``detachment`` all return
  the identical 86-chunk stem family
- fuzzy/prefix fallbacks for short or near words (``mn`` → 1,458
  hits; ``geometryy`` → the ``geometry`` family)

Neither engine can be configured to the other's semantics (pagefind
1.5.2 CLI exposes no stemming/tokenizer toggle — verified against
``pagefind --help``; FTS5 tokenizers are C code, out of scope).  The
contract therefore normalizes every golden query to a CANONICAL FORM
applied to both engines, chosen so the engines' recall coincides:

1. lowercase; split on non-alphanumeric runs
2. FTS5 side: each word (len ≥ 2, not pure digits) becomes a
   ``word*`` PREFIX term — prefix expansion reproduces pagefind's
   stem-family recall because every member of an English stem family
   starts with the stem (measured: ``detach*`` == pf(``detach``) ==
   86 exactly; ``drift*`` == pf(``drifts``) == 494)
3. Pagefind side: each word is split at letter↔digit boundaries
   (mirroring its index-time splitting), pure-digit and 1-char
   fragments dropped (numbers and short fragments are measured
   divergent: pf(``44``) = 1,186 vs FTS5 200)
4. per-query stem overrides live in ``tests/golden_queries.json``
   (``detachment`` → ``detach``): the file IS the documented
   divergent-vocabulary mapping the contract asks to record

Divergence rule: per query, chunk-ID set equality is
asserted; a query may instead pass with Jaccard ≥ 0.95 only when the
symmetric difference is recorded as evidence in the report.  Queries
that cannot reach 0.95 (BoRiS — pagefind camelCase index splitting;
``b2mn`` — 2-letter fuzzy explosion) are NOT in the gated suite; they
are listed under ``known_divergent`` with their measured cause.
"""

from __future__ import annotations

import json
import re
import shutil
from askthedocs._sqlite import sqlite3
import subprocess
import tempfile
from pathlib import Path

# project root (src/askthedocs/parity.py → ../../..)
ROOT = Path(__file__).resolve().parents[2]
GOLDEN_DEFAULT = ROOT / "tests" / "golden_queries.json"
PF_SEARCH_MJS = ROOT / "tools" / "parity" / "pf_search.mjs"
REPORT_DEFAULT = ROOT / "out" / "web" / "parity_report.json"

# minimum Jaccard similarity for a non-equal query to pass
JACCARD_FLOOR = 0.95

_WORD_SPLIT = re.compile(r"[^0-9a-z]+")
_ALNUM_PARTS = re.compile(r"[a-z]+|[0-9]+")


def canonical_forms(query: str) -> tuple[str, str]:
    """Canonical parity form of *query*: ``(fts_expr, pf_query)``.

    Rule 1-3 of the module docstring.  Numeric-only queries yield
    ``("", "")`` — documented divergent vocabulary, not contractable.
    """
    words = [w for w in _WORD_SPLIT.split(query.lower()) if w]
    fts_terms = [w for w in words if len(w) >= 2 and not w.isdigit()]
    pf_terms: list[str] = []
    for w in words:
        pf_terms.extend(p for p in _ALNUM_PARTS.findall(w)
                        if len(p) >= 2 and not p.isdigit())
    if not pf_terms:
        pf_terms = fts_terms
    return " ".join(t + "*" for t in fts_terms), " ".join(pf_terms)


def fts_ids(conn: sqlite3.Connection, expr: str) -> set[str]:
    """Chunk-ID set matching an FTS5 expression (read-only store)."""
    if not expr:
        return set()
    return {row[0] for row in
            conn.execute("SELECT chunk_id FROM chunks_fts"
                         " WHERE chunks_fts MATCH ?", (expr,))}


def _pagefind_ids(pf_queries: list[str], node: str, mjs: Path,
                  web_root: Path) -> dict[str, list[str]]:
    """Chunk-ID sets from the real pagefind index, headless (node)."""
    with tempfile.TemporaryDirectory() as tmp:
        qfile = Path(tmp) / "queries.json"
        ofile = Path(tmp) / "out.json"
        qfile.write_text(json.dumps(pf_queries))
        subprocess.run([node, str(mjs), str(qfile), str(ofile)],
                       check=True, capture_output=True, cwd=ROOT)
        return json.loads(ofile.read_text())


def run_parity(db_path: Path, golden_path: Path = GOLDEN_DEFAULT,
               node: str | None = None, report_path: Path | None = None,
               mjs: Path = PF_SEARCH_MJS) -> dict:
    """Run the golden-query suite on both engines; return the report.

    Raises FileNotFoundError when the store, the index runner, or the
    golden file is absent (the caller decides whether that skips or
    fails — the check script fails, the pytest skips).  The report
    carries per-query counts, Jaccard, and the full symmetric
    difference as evidence; ``passed`` is False when any gated query
    is neither set-equal nor Jaccard ≥ 0.95 with recorded evidence.
    """
    node = node or shutil.which("node")
    if node is None:
        raise FileNotFoundError("node executable not found on PATH")
    for p in (db_path, golden_path, mjs):
        if not p.exists():
            raise FileNotFoundError(str(p))

    golden = json.loads(golden_path.read_text())
    conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    try:
        entries = golden["queries"]
        forms = [canonical_forms(e.get("canonical", e["query"]))
                 for e in entries]
        pf_raw = _pagefind_ids([pf for _, pf in forms], node, mjs,
                               db_path.parent / "web")
        results = []
        for entry, (fts_expr, pf_query) in zip(entries, forms):
            fts_set = fts_ids(conn, fts_expr)
            pf_set = set(pf_raw[pf_query]) if pf_query else set()
            union = fts_set | pf_set
            jaccard = (len(fts_set & pf_set) / len(union)) if union else 1.0
            equal = fts_set == pf_set
            evidence = {
                "fts_only": sorted(fts_set - pf_set),
                "pf_only": sorted(pf_set - fts_set),
            }
            results.append({
                "query": entry["query"], "canonical": entry.get("canonical"),
                "fts_expr": fts_expr, "pf_query": pf_query,
                "fts_count": len(fts_set), "pf_count": len(pf_set),
                "jaccard": round(jaccard, 4), "equal": equal,
                "evidence": evidence,
                "passed": equal or bool(
                    jaccard >= JACCARD_FLOOR
                    and (evidence["fts_only"] or evidence["pf_only"])),
            })
    finally:
        conn.close()

    report = {
        "schema": "askthedocs-parity-report/1",
        "db": str(db_path), "jaccard_floor": JACCARD_FLOOR,
        "queries": results,
        "known_divergent": golden.get("known_divergent", []),
        "passed": all(r["passed"] for r in results),
    }
    if report_path is not None:
        report_path.parent.mkdir(parents=True, exist_ok=True)
        report_path.write_text(json.dumps(report, indent=1) + "\n")
    return report


def main(argv: list[str] | None = None) -> int:
    """CLI entry: ``python -m askthedocs.parity [--db PATH] [--report PATH]``."""
    import argparse
    ap = argparse.ArgumentParser(
        prog="askthedocs.parity",
        description="parity suite: FTS5 vs Pagefind recall parity")
    ap.add_argument("--db", type=Path,
                    default=ROOT / "out" / "askthedocs.db")
    ap.add_argument("--report", type=Path, default=REPORT_DEFAULT)
    args = ap.parse_args(argv)
    report = run_parity(args.db, report_path=args.report)
    for r in report["queries"]:
        mark = "==" if r["equal"] else f"jac={r['jaccard']:.3f}"
        print(f"[{'PASS' if r['passed'] else 'FAIL'}] {mark:>9}"
              f" fts={r['fts_count']:5} pf={r['pf_count']:5}"
              f" {r['query']!r}")
    n = len(report["queries"])
    ok = sum(r["passed"] for r in report["queries"])
    print(f"parity: {ok}/{n} queries pass"
          f" (floor Jaccard {JACCARD_FLOOR})")
    print(f"report: {args.report}")
    return 0 if report["passed"] else 1


if __name__ == "__main__":
    raise SystemExit(main())
