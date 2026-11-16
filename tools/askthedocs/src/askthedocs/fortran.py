"""Fortran source chunks — B2.5 + EIRENE procedure units).

The code corpus (measured 2026-09-24: 1,684 walked files / 21.25 MB
under the two src roots → 1,602 indexed / 3,914 units / 20.82 MB
indexed) is chunked per procedure: every SUBROUTINE/FUNCTION
declaration starts a unit that runs to the next declaration or EOF,
cluster ``fortran_source``, ``section`` = the unit name as written.
The chunk text carries the unit's source verbatim, headed by the
file:line-range citation — "answers cite the exact Fortran that
implements them" (doctrine ../course/14 §6).

Measured shapes the parser is built on (census 2026-09-24 over both
roots, 4,015 candidate lines → 3,914 real units):

* declarations appear bare (3,736) or behind a type/prefix sequence —
  INTEGER×93, LOGICAL×53, RECURSIVE×11, REAL(DP)×11, ELEMENTAL
  LOGICAL×4, … — so the matcher whitelists those prefix words;
* everything else that mentions the keywords is noise: END
  SUBROUTINE/END FUNCTION (3,788 lines), the word inside a quoted
  WRITE message (``WRITE (IUNOUT,*) ' ERROR IN FUNCTION…'``), and
  free-form ``&`` continuations.  A whitelist prefix + the trailing
  ``(``-or-end-of-line guard (``subroutine name (args)``) rejects
  all of them — a quoted ``'SUBROUTINE FOO'`` can never match because
  the quote trails the name.

Scope (2026-10-21 — supersedes the earlier two-module scope):
EVERY Fortran file in the repository — the whole ``modules/`` tree
(B2.5 and Eirene's solver sources, the grid-tool family Carre /
DivGeo / Triang / Uinp, legacy solps4-5, the fxdr and Sonnet-light
utilities) plus the ``scripts/`` nc2text utilities.  The one-sentence
coverage rule: every Fortran file, as procedure units — plus all
documentation, plus the databases, plus the synthesized switch
inventory (SOLPS-GUI's Python stays out, stated reason in the README:
the GUI enters through its documentation; its code carries no switch
or subroutine joins).  Any path component named "database" is skipped
(same guard as before — the AM/molecular trees enter the corpus as
the amdata cluster instead).  B2.5/Eirene counts are unchanged by the
widening (measured: no Fortran outside their src/ roots beyond the
excluded databases).  Files > 2 MB are skipped
and recorded (none exist today; the guard bounds future generated
blobs).  Files with no procedure (measured 2026-09-24: 82 files —
main PROGRAM drivers like b2co.F, block data, parameter includes)
yield no chunks and are listed in the build summary — never silently
dropped.

Known limitation (documented, 342 files use it): Fortran CONTAINS
nesting is not tracked — a nested procedure declaration starts its
own chunk, truncating the parent at that point, and module-level
declarations (USE/IMPLICIT/variable decls) belong to no chunk.
Procedure bodies are the citation target.
"""

from __future__ import annotations

import re
from pathlib import Path
from typing import Any

from askthedocs import store

# cluster the chunks are stored under
CLUSTER = "fortran_source"

# repo-relative roots walked, in fixed insert order (SOLPS-ITER).
#: the whole modules/ tree plus scripts/ — "every Fortran file
# in the repository, database trees excluded"; the two-module scope
# this replaces was defensible while invisible and indefensible once
# the repository modal made coverage public.
ROOTS = ("modules", "scripts")

# any path component matching this (case-insensitively) is skipped —
# the scope note.  Vacuous for the current tree (the Database
# dirs are siblings of src/, not inside), kept as the guard.
DATABASE_COMPONENT = "database"

# Fortran extensions indexed: fixed-form .F/.f + free-form .F90/.f90
EXTS = frozenset({".F", ".f", ".F90", ".f90"})

# size guard: larger files are skipped and recorded
MAX_FILE_BYTES = 2 * 1024 * 1024

# a procedure declaration line.  Prefix group = the measured
# type/prefix words (possibly repeated: "ELEMENTAL LOGICAL",
#"DOUBLE PRECISION"); the name must be followed by "(" or the end
# of the line, which is what rejects quoted-string noise.
UNIT_RE = re.compile(
    r"^\s*(?:(?:pure|elemental|impure|recursive|module|integer|real"
    r"|complex|double\s+precision|logical|character|byte"
    r"|type\s*\([^)]*\))(?:[\w\s*(),:]*?)\s+)?"
    r"(subroutine|function)\s+([A-Za-z]\w*)\s*(?:\(|$)",
    re.IGNORECASE)

# first characters a declaration line can never start with:
# free-form & continuations, and the quote/dot shapes of the census
# noise.  (Fixed-form comment/debug markers C c D d * are handled
# column-1-only in :func:`unit_decl` — `double precision function`
# and `character function` are declarations, not noise.)
NOISE_FIRST = frozenset("!#&'\".")


def is_comment(line: str) -> bool:
    """Full-line comment?  Fixed-form markers (C c *) count only in
    column 1 — an indented ``CALL …`` line is CODE, not a banner; the
    free-form ``!`` marker counts at any indentation."""
    if not line:
        return False
    if line[0] in "Cc*":
        return True
    return line.lstrip().startswith("!")


def unit_decl(line: str, stripped: str):
    """Declaration match for *line* (or None).  Fixed-form markers
    (C c D d *) count only in column 1; the NOISE shapes count at
    any indentation of the stripped line."""
    if line[:1] in "CcDd*":
        return None
    if stripped[:1] and stripped[0] in NOISE_FIRST:
        return None
    return UNIT_RE.match(stripped)


def parse_units(lines: list[str]) -> list[dict[str, Any]]:
    """Split one Fortran file's lines into procedure units.

    A unit starts at its declaration line and runs to the next
    declaration or EOF.  A contiguous full-line comment banner
    directly above a declaration is attached to the declaring unit
    (and removed from the tail of the previous one — it is the
    banner's document, not the predecessor's body).  Returns
    ``[{"kind", "name", "start", "end", "lines"}, ...]`` with 1-based
    line numbers covering declaration..last-body-line (the banner
    lines lie above ``start`` and are carried in ``lines``).
    """
    units: list[dict[str, Any]] = []
    pending: list[str] = []  # contiguous comments above the next decl
    current: dict[str, Any] | None = None
    for lineno, raw in enumerate(lines, 1):
        line = raw.rstrip("\n")
        stripped = line.strip()
        comment = is_comment(line)
        decl = None
        if stripped:
            decl = unit_decl(line, stripped)
        if decl is not None:
            if current is not None and pending:
                # the banner is a suffix of the previous unit's body
                # (it was appended there as it occurred) — move it
                del current["lines"][-len(pending):]
                current["end"] -= len(pending)
            current = {
                "kind": decl.group(1).lower(),
                "name": decl.group(2),
                "start": lineno,
                "end": lineno,
                "lines": list(pending),
            }
            units.append(current)
            pending = []
            current["lines"].append(line)
            continue
        if comment:
            pending.append(line)
        else:
            pending = []
        if current is not None:
            current["lines"].append(line)
            current["end"] = lineno
    return units


def chunk_text(source: str, unit: dict[str, Any]) -> str:
    """Citable text: header citation line + the unit's source verbatim."""
    header = (f"{unit['kind']} {unit['name']} — Fortran source unit\n"
              f"source: {source} lines {unit['start']}-{unit['end']}")
    return "\n".join([header, *unit["lines"]])


def walk_paths(iter_repo: Path) -> list[Path]:
    """Every Fortran source file in scope, ROOTS order then sorted path
    within each root (the database-component guard applies).  ``scan``
    and the build manifest share this walk, so the code-corpus
    scope is defined exactly once."""
    out: list[Path] = []
    for root_rel in ROOTS:
        root = iter_repo / root_rel
        if not root.is_dir():
            continue
        for path in sorted(root.rglob("*")):
            if path.suffix not in EXTS or not path.is_file():
                continue
            if any(part.lower() == DATABASE_COMPONENT
                   for part in path.relative_to(iter_repo).parts):
                continue
            out.append(path)
    return out


def source_category(rel: str) -> str:
    """The pending-list category of a source file: the immediate
    module directory under ``modules/`` (every module directory, git
    submodule or plain), or ``scripts`` for the repository's own
    scripts directory (its own category, mirroring the tree, and
    contiguous in the walk)."""
    parts = rel.split("/")
    if parts[0] == "modules" and len(parts) > 1:
        return parts[1]
    if parts[0] == "scripts":
        return "scripts"
    return "SOLPS-ITER"


def scan(iter_repo: Path,
         progress=None) -> tuple[list[store.Chunk], dict[str, Any]]:
    """Walk the two src roots (sorted, ROOTS order first) and build one
    chunk per procedure unit.  Returns (chunks, summary) — the summary
    records the size-guard skips and the no-unit files by name, plus
    the code-corpus MB the store now carries (the payload
    measurement input).

    *progress*, when given, is a display object: the walk opens one
    stage per category ("B2.5 fortran source", "Triang fortran
    source", ...; categories are contiguous in walk order) with the
    category's file total, ticking once per file read.
    """
    chunks: list[store.Chunk] = []
    oversize: list[dict[str, Any]] = []
    no_unit: list[str] = []
    walked = 0
    walked_bytes = 0
    indexed_files = 0
    indexed_bytes = 0
    paths = walk_paths(iter_repo)
    totals: dict[str, int] = {}
    for path in paths:
        cat = source_category(path.relative_to(iter_repo).as_posix())
        totals[cat] = totals.get(cat, 0) + 1
    current = None
    if progress is not None and totals:
        current = next(iter(totals))
        progress.begin_stage(f"{current} fortran source", verb="scan",
                             unit="files", total=totals[current],
                             counts_files=True)
    for path in paths:
        rel = path.relative_to(iter_repo).as_posix()
        cat = source_category(rel)
        if progress is not None and cat != current:
            progress.begin_stage(f"{cat} fortran source", verb="scan",
                                 unit="files", total=totals[cat],
                                 counts_files=True)
            current = cat
        size = path.stat().st_size
        walked += 1
        walked_bytes += size
        if progress is not None:
            progress.current_file(rel, size)
            progress.tick()
        if size > MAX_FILE_BYTES:  # size guard: record, never silent
            oversize.append({"file": rel, "mb": round(size / 1e6, 2)})
            continue
        text = path.read_text(encoding="utf-8", errors="replace")
        units = parse_units(text.splitlines())
        if not units:
            no_unit.append(rel)
            continue
        indexed_files += 1
        indexed_bytes += size
        source = f"SOLPS-ITER/{rel}"
        for ordinal, unit in enumerate(units):
            chunks.append(store.Chunk(
                chunk_id=store.make_chunk_id(source, None, ordinal),
                source=source,
                cluster=CLUSTER,
                section=unit["name"],
                page=None,
                text=chunk_text(source, unit),
            ))
    if progress is not None:
        progress.end_stage()
    summary = {
        "roots": list(ROOTS),
        "files": {"walked": walked, "indexed": indexed_files,
                  "no_unit": len(no_unit), "oversize": len(oversize)},
        "units": len(chunks),
        "mb_total": round(walked_bytes / 1e6, 2),
        "mb_indexed": round(indexed_bytes / 1e6, 2),
        "oversize_skipped": oversize,
        "no_unit_files": no_unit,
    }
    return chunks, summary
