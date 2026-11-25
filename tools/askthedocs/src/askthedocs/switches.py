"""b2mn.dat switch inventory from the B2.5 Fortran source).

"b2mn.dat switches" are the free-format ``'name' 'value'`` pairs that
``b2mnds`` reads from its formatted input unit (the b2mn.dat file) and
stores via ``ipsetc``:

* parser      — SOLPS-ITER/modules/B2.5/src/driver/b2mnds.F:235-242:
  every non-comment line (``is_comment``: blank or first char ``*``,
  ``!``, ``#`` — utility/is_comment.F:5-9) whose space-stripped form
  starts with ``'`` is read as two strings and passed to ``ipsetc``.
* consumption — the values are read back wherever B2.5 calls the
  ``ipgetc``/``ipgeti``/``ipgetr`` wrappers (utility/ipgeti.F,
  utility/ipgetr.F, b2mod_ipmain.F:106).  A census of those call
  sites IS the "Fortran location that reads it" the coverage rule asks for;
  the wrappers return the caller's pre-set variable unchanged when
  the switch is absent (b2mod_ipmain.F:141), so the code-side
  default lives at the call site, not in this table.
* defaults    — documentation/b2input.xml, module ``b2mn.dat``
  (the GUI editor's switch reference): 621 ``<switch>`` elements with
  ``<name>/<default>/<type>/<description>``.  Its DTD pulls external
  entities (xhtml-symbol.ent), so the file is entity-expanded before
  ElementTree parses it.

Universe = union(census names, b2input.xml b2mn.dat names), sorted —
the golden (every switch token of the ITER_2275 run_restart b2mn.dat
appears in switches.json) is covered by both sides.  One chunk per
switch lands in the store under cluster ``source_switch`` so "what
does this switch do" is answerable with the manual default AND the
Fortran read sites in one citation.
"""

from __future__ import annotations

import json
import re
import xml.etree.ElementTree as ET
from pathlib import Path
from typing import Any

from askthedocs import store

SCHEMA = "askthedocs-switches/1"

# the cluster switch chunks are stored under
CLUSTER = "source_switch"

# chunk-store provenance for switch chunks: they describe b2mn.dat
#(every switch can appear there); the file:line citations live in
# the chunk text.  page is None (no page concept) — the para-index
# is the position in the sorted switch list.
SOURCE = "b2mn.dat"

# repo-relative anchors (SOLPS-ITER)
B2_SRC = "modules/B2.5/src"
B2INPUT = "modules/B2.5/src/documentation/b2input.xml"
ENTITIES = "modules/B2.5/src/documentation/xhtml-symbol.ent"
PARSER_CITE = "modules/B2.5/src/driver/b2mnds.F:235-242"

# ipget[cir] call sites carrying a literal switch name.  Case-
# insensitive (Fortran); measured 2026-09-24: 1,916 of 1,921 call
# lines carry the quoted literal on the same line — the other 5 are
# the wrapper definitions themselves, which yield no literal.
READ_CALL = re.compile(r"\bipget[cir]\s*\(\s*'([^']+)'", re.IGNORECASE)

# extensions walked for the census (B2.5 fixed-form .F + .F90)
FORTRAN_EXTS = frozenset({".F", ".F90"})


def census_reads(iter_repo: Path) -> dict[str, list[dict[str, Any]]]:
    """Switch name -> sorted read sites ``[{"file", "line"}, ...]``.

    *iter_repo* is the SOLPS-ITER repo root; files are walked in
    sorted order and reported repo-relative, so the census (and the
    chunks built from it) is deterministic.
    """
    reads: dict[str, list[dict[str, Any]]] = {}
    src_root = iter_repo / B2_SRC
    for path in sorted(p for p in src_root.rglob("*")
                       if p.suffix in FORTRAN_EXTS):
        rel = path.relative_to(iter_repo).as_posix()
        with open(path, encoding="utf-8", errors="replace") as fh:
            for lineno, line in enumerate(fh, 1):
                m = READ_CALL.search(line)
                if m:
                    name = m.group(1).strip().lower()  # ipsetc lowercases
                    reads.setdefault(name, []).append(
                        {"file": rel, "line": lineno})
    for sites in reads.values():
        sites.sort(key=lambda s: (s["file"], s["line"]))
    return reads


def _expand_entities(xml_text: str, ent_text: str) -> str:
    """Drop the DOCTYPE and expand the xhtml-symbol entities inline.

    ElementTree has no external-DTD support (``undefined entity
    &alpha;`` on the raw file, measured 2026-09-24); the entity
    definitions ship beside the XML and are plain ``<!ENTITY n "v">``.
    """
    entmap = dict(re.findall(r'<!ENTITY\s+(\w+)\s+"([^"]*)"\s*>', ent_text))
    text = re.sub(r"<!DOCTYPE[^>]*\[.*?\]>\s*|<!DOCTYPE[^>]*>\s*",
                  "", xml_text, flags=re.S)
    return re.sub(r"&(\w+);",
                  lambda m: entmap.get(m.group(1), m.group(0)), text)


def documented_defaults(iter_repo: Path) -> dict[str, dict[str, Any]]:
    """Switch name -> {"default", "type", "description"} from
    b2input.xml's b2mn.dat module (names lowercased like ipsetc).

    Duplicate names keep their FIRST occurrence (measured 2026-09-24:
    621 elements, 621 distinct names, no conflicting defaults).
    """
    xml_path = iter_repo / B2INPUT
    ent_path = iter_repo / ENTITIES
    expanded = _expand_entities(
        xml_path.read_text(encoding="utf-8"),
        ent_path.read_text(encoding="utf-8") if ent_path.is_file() else "")
    root = ET.fromstring(expanded)
    module = next(m for m in root.findall("module")
                  if m.get("name") == "b2mn.dat")
    out: dict[str, dict[str, Any]] = {}
    for sw in module.findall(".//switch"):
        name = (sw.findtext("name") or "").strip().lower()
        if not name or name in out:
            continue
        out[name] = {
            "default": (sw.findtext("default") or "").strip() or None,
            "type": (sw.findtext("type") or "").strip() or None,
            "description":
                " ".join((sw.findtext("description") or "").split()) or None,
        }
    return out


def inventory(iter_repo: Path, progress=None) -> dict[str, Any]:
    """The switches.json payload: full b2mn.dat switch inventory.

    *progress*, when given, is a display object: it learns the entry
    total once the universe is known (census + defaults union), then
    ticks once per switch entry assembled.
    """
    reads = census_reads(iter_repo)
    docs = documented_defaults(iter_repo)
    names = sorted(set(reads) | set(docs))
    if progress is not None:
        progress.set_total(len(names))
    switches: list[dict[str, Any]] = []
    for name in names:
        if progress is not None:
            progress.tick()
        doc = docs.get(name)
        switches.append({
            "switch": name,
            "default": doc["default"] if doc else None,
            "type": doc["type"] if doc else None,
            "description": doc["description"] if doc else None,
            "documented": doc is not None,
            "reads": reads.get(name, []),
        })
    return {
        "schema": SCHEMA,
        "repo": "SOLPS-ITER",
        "sources": {
            "reads": f"ipget[cir] literal-name call census over {B2_SRC}/**",
            "parser": PARSER_CITE,
            "defaults": f"{B2INPUT} (module b2mn.dat)",
        },
        "counts": {
            "switches": len(switches),
            "documented": sum(1 for s in switches if s["documented"]),
            "with_reads": sum(1 for s in switches if s["reads"]),
            "read_sites": sum(len(s["reads"]) for s in switches),
        },
        "switches": switches,
    }


def write_inventory(inv: dict[str, Any], path: Path) -> None:
    """Deterministic switches.json writer (indent=1, trailing newline)."""
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    with open(path, "w", encoding="utf-8") as fh:
        json.dump(inv, fh, indent=1, sort_keys=False)
        fh.write("\n")


def chunk_text(entry: dict[str, Any]) -> str:
    """Citable text for one switch chunk (self-contained provenance)."""
    lines = [f"b2mn.dat switch {entry['switch']}"]
    default = entry.get("default")
    lines.append(f"default: {default if default is not None else '(not documented)'}")
    if entry.get("type"):
        lines.append(f"type: {entry['type']}")
    if entry.get("description"):
        lines.append(f"description: {entry['description']}")
    sites = ", ".join(f"{r['file']}:{r['line']}" for r in entry["reads"])
    lines.append("Fortran reads (SOLPS-ITER/modules/B2.5/src): "
                 + (sites if sites else "(no ipget read site found)"))
    lines.append(f"parsed by {PARSER_CITE} ('name' 'value' pairs -> ipsetc)")
    return "\n".join(lines)


def chunks(inv: dict[str, Any]) -> list[store.Chunk]:
    """One chunk per switch, sorted by name (fixed insert order)."""
    out: list[store.Chunk] = []
    for index, entry in enumerate(inv["switches"]):
        out.append(store.Chunk(
            chunk_id=store.make_chunk_id(SOURCE, None, index),
            source=SOURCE,
            cluster=CLUSTER,
            section=entry["switch"],
            page=None,
            text=chunk_text(entry),
        ))
    return out


def default_switches() -> Path:
    """<askthedocs project>/out/switches.json."""
    return Path(__file__).resolve().parents[2] / "out" / "switches.json"
