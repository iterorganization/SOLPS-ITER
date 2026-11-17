"""Build pipeline: corpus manifest -> chunk-store database).

Reads the manifest (``out/corpus.json``) and extracts every
text-rich PDF), every documentation TeX source
structured manuals; AMdata tables, dg, bc, GUI tutorial),
the GUI reST manuals, the doc/LOG changelog, and the DivGeo HTML
manual) into ``out/askthedocs.db`` (SQLite + FTS5). Sources
the manifest flagged needs_ocr / needs_alt_extractor, the text_poor
figure dumps, and the pinned non-documentation .tex/.log files are
skipped and LISTED in the build summary — never silently dropped
.

The manifest is already sorted by (repo, path) and extraction walks
pages then paragraphs, so the insert order — and therefore the
database — is fully determined by the corpus state. hardens
this into the sha256 golden; records the source manifest.
"""

from __future__ import annotations

import json
from askthedocs._sqlite import sqlite3
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

from askthedocs import corpus, extract, state, store, verdicts

SCHEMA = "askthedocs-build/1"

#.tex sources that are NOT documentation and are never extracted,
# listed by name in the summary (never silently dropped).  Measured
#2026-09-24: thumbdta.tex is hex-encoded \pdfobj thumbnail streams
#(306 KB of binary dumps, no prose); tcilatex.tex is the Scientific
# Word macro-definition file shipped beside bc.tex (preamble macros,
# one \section* header); latex_header.tex is the LyX-generated DivGeo
# equtrn template — 32 words of scaffold (\tableofcontents & co.)
# after \begin{document}.
TEX_NONDOC_PATHS = frozenset({
    ("SOLPS-ITER", "doc/solps/thumbdta.tex"),
    ("SOLPS-ITER", "doc/solps/Mladen_Stanojevic_B2_bc/tcilatex.tex"),
    ("SOLPS-ITER", "modules/DivGeo/equtrn/latex_header.tex"),
})

#.log files that are NOT documentation, skipped by name (measured
#2026-09-24: bc.log is a 2002 TeX compile transcript — format chatter
# like "\\c@part=\\count79" — and pipe_run.log is a csh script despite
# its extension, starting "#! /bin/csh -f").
LOG_NONDOC_PATHS = frozenset({
    ("SOLPS-ITER", "doc/solps/Mladen_Stanojevic_B2_bc/bc.log"),
    ("SOLPS-ITER", "scripts/pipe_run.log"),
})

# the hand-maintained changelog): the only extensionless doc
# source; each dated entry becomes one chunk with the date as section.
# Pinned to the exact path — it is the file the switch census reads.
CHANGELOG_PATH = ("SOLPS-ITER", "doc/LOG")

# manifest text_status -> skip reason recorded in the summary
SKIP_REASONS = {
    "needs_ocr": "needs_ocr",
    "needs_alt_extractor": "needs_alt_extractor",
    "text_poor": "text_poor",
    "not_documentation_tex": "not_documentation_tex",
    "not_documentation_log": "not_documentation_log",
}


def is_documentation_tex(record: dict[str, Any]) -> bool:
    """True for .tex sources carrying extractable documentation text
 manuals + AMdata tables, dg, bc, GUI tutorial)."""
    return (record["ext"] == ".tex"
            and (record["repo"], record["path"]) not in TEX_NONDOC_PATHS)


def default_db() -> Path:
    return Path(__file__).resolve().parents[2] / "out" / "askthedocs.db"


def default_summary() -> Path:
    return Path(__file__).resolve().parents[2] / "out" / "build_summary.json"


def _submodule_pointers(repos: dict[str, Path]) -> dict[str, str]:
    """Every gitlink under SOLPS-ITER/modules/ — {name: commit}.

    Read from the parent repo's tree (``git ls-tree HEAD modules/``,
    mode 160000): the revision the PARENT pins for each submodule,
    including submodules the corpus never scans (adas — its repository
    is not public, measured 404 2026-10-21).  Deterministic for a
    given parent checkout; absent ({} — honest) when git is missing.
    """
    import subprocess
    root = repos.get("SOLPS-ITER")
    if root is None or not (root / "modules").is_dir():
        return {}
    try:
        out = subprocess.run(
            ["git", "ls-tree", "HEAD", "modules/"],
            cwd=str(root), capture_output=True, text=True,
            check=True).stdout
    except (OSError, subprocess.CalledProcessError):
        return {}
    pointers: dict[str, str] = {}
    for line in out.splitlines():
        meta, path = (line.split("\t", 1) + [""])[:2]
        mode = meta.split()[0] if meta else ""
        if mode == "160000" and path.startswith("modules/"):
            pointers[f"SOLPS-ITER/{path}"] = meta.split()[2]
    return pointers


class CarryError(Exception):
    """A complete index cannot be produced: a leg is neither on disk
    nor carryable from the previous store (the refusal
    register — the transition-and-integrity guard)."""


@dataclass
class _Carry:
    """Everything a carried rebuild needs from the previous store.

    Rows are the previous build_manifest's rows restricted to ABSENT
    legs (verbatim — same kind/repo/path/sha a full rebuild with those
    legs cloned at the same states would record); chunks are the
    previous store's chunks for those legs, in stored (rowid) order —
    the order a fresh extraction of the same bytes produced."""

    legs: list[str]
    corpus_rows: list[tuple] = field(default_factory=list)
    switch_rows: list[tuple] = field(default_factory=list)
    fortran_rows: list[tuple] = field(default_factory=list)
    chunks_by_source: dict[str, list[store.Chunk]] = field(
        default_factory=dict)
    switch_chunks: list[store.Chunk] = field(default_factory=list)
    heads: dict[str, str] = field(default_factory=dict)
    pointers: dict[str, str] = field(default_factory=dict)
    skipped_labels: set[str] = field(default_factory=set)
    per_source: dict[str, int] = field(default_factory=dict)
    from_sha: str = ""
    inventory_name: str | None = None


def _read_carry(carry_from: Path,
                repos: dict[str, Path],
                substates: dict[str, dict[str, bool]]) -> _Carry:
    """Assemble the carry state; raises CarryError when the previous
    store cannot honestly cover an absent leg."""
    carry_from = Path(carry_from)
    if not carry_from.is_file():
        raise CarryError(f"carry store not found: {carry_from}")
    prev_rows = state.read_from_db(carry_from)
    if prev_rows is None:
        raise CarryError(
            f"no build manifest in the carry store {carry_from}; "
            "nothing to carry from; run a full build with the "
            "reference repos present")
    absent = {name for name in
              {verdicts.leg_name(r[1], r[2]) for r in prev_rows}
              if not verdicts.leg_present(name, repos, substates)}
    carry = _Carry(legs=sorted(absent), from_sha=corpus.sha256_file(
        carry_from))
    for row in prev_rows:
        kind, repo, path, _sha = row
        if verdicts.leg_name(repo, path) not in absent:
            continue
        if kind == state.KIND_CORPUS:
            carry.corpus_rows.append(row)
        elif kind == state.KIND_SWITCHES:
            carry.switch_rows.append(row)
        else:
            carry.fortran_rows.append(row)
    carry.chunks_by_source, carry.switch_chunks = store.read_carry_chunks(
        carry_from, absent)
    summary_path = carry_from.parent / "build_summary.json"
    failed_labels: set[str] = set()
    if summary_path.is_file():
        try:
            prev_summary = json.loads(
                summary_path.read_text(encoding="utf-8"))
        except ValueError:
            prev_summary = {}
        carry.heads = dict(prev_summary.get("repo_heads") or {})
        carry.pointers = dict(prev_summary.get("submodule_pointers") or {})
        carry.inventory_name = (prev_summary.get("switches") or {}).get(
            "json")
        for labels in ((prev_summary.get("sources") or {})
                       .get("skipped") or {}).values():
            carry.skipped_labels.update(labels or [])
        carry.per_source = dict(
            (prev_summary.get("chunks") or {}).get("per_source") or {})
        failed_labels = {f["source"] for f in
                         (prev_summary.get("sources") or {}).get("failed")
                         or []}
    # integrity: every carried corpus row's chunk count in
    # the previous store must EQUAL the count its own summary
    # records.  Zero==zero is legitimate — extraction succeeding with
    # ZERO chunks is a real state (an empty index.rst stub; earned
    # live in the owner's veteran test 2026-10-31, where a too-strict
    # chunks-or-skip predicate refused a healthy carry) — and a count
    # mismatch means a hand-mangled store: refuse, never a silently
    # thinner index
    broken = [f"{r[1]}/{r[2]}" for r in carry.corpus_rows
              if len(carry.chunks_by_source.get(f"{r[1]}/{r[2]}", ()))
              != carry.per_source.get(f"{r[1]}/{r[2]}", 0)]
    if broken:
        raise CarryError(
            "the carry store does not cover its own recorded sources ("
            + ", ".join(broken[:5]) + "); rebuild from clones")
    for row in carry.corpus_rows:
        if f"{row[1]}/{row[2]}" in failed_labels:
            raise CarryError(
                f"the carry store itself failed {row[1]}/{row[2]}; "
                "rebuild from clones for a complete index")
    return carry


def _fortran_key(source: str) -> tuple:
    """Order key reproducing the Fortran walk exactly: ROOTS order
    first, then ``sorted(path)`` (component-wise) within each root —
    the order ``fortran.walk_paths`` yields and ``fortran.scan``
    emits.  The carry merge must place carried units into THIS order,
    never into plain string order (string vs component-wise sorting
    diverges on file/dir prefix pairs and silently permutes rowids,
    breaking byte-identity on real trees)."""
    from askthedocs import fortran as fortran_mod
    rel = source.split("/", 1)[1]  # strip the SOLPS-ITER/ namespace
    for i, root_rel in enumerate(fortran_mod.ROOTS):
        prefix = root_rel + "/"
        if rel.startswith(prefix):
            return (i, tuple(rel[len(prefix):].split("/")))
    return (len(fortran_mod.ROOTS), tuple(rel.split("/")))


def build(manifest: dict[str, Any], repos: dict[str, Path],
          db_path: Path, summary_path: Path | None = None,
          pages_dir: Path | None = None,
          switches_path: Path | None = None,
          include_fortran: bool = False,
          carry_from: Path | None = None,
          submodule_states: dict[str, dict[str, bool]] | None = None,
          progress=None,
          preextracted: dict[str, dict[str, Any]] | None = None
          ) -> dict[str, Any]:
    """Full deterministic rebuild; returns the build summary dict.

    *progress*, when given, is a display object driven by the build's
    own stages: documentation extraction (one tick per source), the
    switch census (one tick per entry), and the Fortran walk (one tick
    per file; the stage opens inside :func:`fortran.scan`).

    With *pages_dir* set, also emits the per-chunk index-input pages
) and records them in the summary. With *switches_path*
    set, the b2mn.dat switch inventory is written there and its
    chunks are appended to the store (cluster ``source_switch``,
    after the manifest sources — fixed order, so rowids stay
    reproducible). With *include_fortran* set, the procedure
    units of ``modules/B2.5/src`` + ``modules/Eirene/src`` are
    appended after those (cluster ``fortran_source``), and the summary
    records the code-corpus skips and MB.

    carried rebuild: with *carry_from* set, legs ABSENT from
    disk (missing repo, or a gitlink-declared never-initialized
    submodule) are carried verbatim from that store — their recorded
    input rows and their chunks, byte-for-byte what a full rebuild
    with those legs cloned at the same states would produce (the
    suite's A/B identity assertion enforces it forever).  Under a
    present leg the disk is the truth: deletions propagate, nothing
    carries.  *submodule_states* overrides the git declaration read
    (tests and the service pass their own).
    """
    extracted_sources: list[str] = []
    failed: list[dict[str, str]] = []
    skipped: dict[str, list[str]] = {reason: [] for reason in SKIP_REASONS}
    pending_text = 0
    all_chunks: list[store.Chunk] = []

    # ---- leg truth: carry preparation + disk filtering ----
    from askthedocs import corpus as corpus_mod
    substates = (corpus_mod.submodule_state(repos)
                 if submodule_states is None else submodule_states)

    def present_leg(repo: str, rel: str) -> bool:
        return verdicts.leg_present(verdicts.leg_name(repo, rel),
                                    repos, substates)

    carry: _Carry | None = None
    if carry_from is not None:
        carry = _read_carry(Path(carry_from), repos, substates)
    stray: list[str] = []   # disk files under absent legs — never indexed
    carried_ids: set[int] = set()  # id() of every carried Chunk object

    disk_records = [r for r in manifest["files"]
                    if present_leg(r["repo"], r["path"])]
    stray += [f"{r['repo']}/{r['path']}" for r in manifest["files"]
              if not present_leg(r["repo"], r["path"])]

    # merged doc walk: carried corpus sources + present-leg disk
    # records in ONE sorted (repo, path) order — identical to the
    # full-rebuild order the A/B identity asserts
    merged: list[tuple[str, str, dict[str, Any] | None]] = sorted(
        [("disk", f"{r['repo']}/{r['path']}", r) for r in disk_records]
        + [("carry", f"{r[1]}/{r[2]}", None)
           for r in (carry.corpus_rows if carry else ())],
        key=lambda item: item[1])  # the manifest's own (repo, path) sort

    # single-visit run: the documents were extracted (and shown,
    # category by category) during the scan; this walk is only the
    # fast in-order assembly of already-extracted text - silent by
    # design (owner ruling 2026-11-03: its 0s stage line read as a
    # second processing pass). The two-pass run below has no
    # preextracted cache: its walk IS the indexing pass, one stage
    # per documentation category in the merged (manifest) order -
    # the same name the pending list shows, so each settled stage
    # drains its line. Every source in the walk is visited; those
    # that yield nothing (figure dumps, non-documentation) are
    # skipped and listed, so the stage counts the pass, not the
    # yield.
    if progress is not None and preextracted is None:
        cat_totals: dict[str, int] = {}
        for _kind, source, _record in merged:
            repo, _, rest = source.partition("/")
            cat = corpus_mod.doc_category(repo, rest)
            cat_totals[cat] = cat_totals.get(cat, 0) + 1
        cat_current: str | None = None
    for _kind, _source, record in merged:
        on_page = None
        if progress is not None and preextracted is None:
            repo, _, rest = _source.partition("/")
            cat = corpus_mod.doc_category(repo, rest)
            if cat != cat_current:
                progress.begin_stage(f"{cat} documents", verb="scan",
                                     unit="files",
                                     total=cat_totals[cat],
                                     counts_files=True)
                cat_current = cat
            progress.current_file(
                rest, record["size"] if record else None)
            on_page = None
            if record is not None and record.get("ext") == ".pdf" \
                    and record.get("pages"):
                progress.file_total(record["pages"], "pages")
                on_page = progress.file_tick
            progress.tick()
        if _kind == "carry":
            if _source in carry.skipped_labels:
                skipped["needs_alt_extractor"].append(_source)
                continue
            for _c in carry.chunks_by_source.get(_source, ()):
                carried_ids.add(id(_c))
                all_chunks.append(_c)
            extracted_sources.append(_source)
            continue
        repo, rel = record["repo"], record["path"]
        source = f"{repo}/{rel}"
        status = record["text_status"]
        if status in SKIP_REASONS:
            skipped[status].append(source)
            continue
        if ((repo, rel) in TEX_NONDOC_PATHS
                and record["ext"] == ".tex"):
            skipped["not_documentation_tex"].append(source)
            continue
        if (repo, rel) in LOG_NONDOC_PATHS:
            skipped["not_documentation_log"].append(source)
            continue
        if preextracted is not None and source in preextracted:
            entry = preextracted[source]
            if entry["error"] is not None:
                failed.append({"source": source, "error": entry["error"]})
                continue
            all_chunks.extend(entry["chunks"])
            extracted_sources.append(source)
            continue
        if is_documentation_tex(record):
            try:
                chunks = extract.extract_tex(repo, rel, repos[repo] / rel,
                                             record["cluster"])
            except extract.ExtractionError as exc:
                failed.append({"source": source, "error": str(exc)})
                continue
            all_chunks.extend(chunks)
            extracted_sources.append(source)
            continue
        extractor = None
        if record["ext"] == ".rst":
            extractor = extract.extract_rst
        elif record["ext"] == ".md":
            # tutorials-repo-only scope (corpus.REPO_EXTENSIONS)
            extractor = extract.extract_md
        elif (repo, rel) == CHANGELOG_PATH:
            extractor = extract.extract_log
        elif record["ext"] == ".htm":
            extractor = extract.extract_htm
        if extractor is not None:
            try:
                chunks = extractor(repo, rel, repos[repo] / rel,
                                   record["cluster"])
            except extract.ExtractionError as exc:
                failed.append({"source": source, "error": str(exc)})
                continue
            all_chunks.extend(chunks)
            extracted_sources.append(source)
            continue
        if record["ext"] != ".pdf":
            pending_text += 1 # unhandled text source — none after 
            continue
        if status != "text_rich":  # unknown status: refuse to guess
            failed.append({"source": source,
                           "error": f"unhandled text_status {status!r}"})
            continue
        try:
            chunks = extract.extract_pdf(repo, rel, repos[repo] / rel,
                                         record["cluster"],
                                         on_page=on_page)
        except extract.ExtractionError as exc:
            failed.append({"source": source, "error": str(exc)})
            continue
        all_chunks.extend(chunks)
        extracted_sources.append(source)

    # b2mn.dat switch inventory from the B2.5 Fortran source
    # (census + b2input.xml defaults); appended after the manifest
    # sources in sorted-switch order — the fixed insert order the
    # determinism golden depends on.
    switches_summary: dict[str, Any] | None = None
    b25_present = present_leg("SOLPS-ITER",
                              "modules/B2.5/src/documentation/b2input.xml")
    if switches_path is not None and b25_present:
        from askthedocs import switches as switches_mod
        if progress is not None:
            # the entry total arrives with the census result (the
            # universe is the union the inventory itself computes)
            progress.begin_stage("B2.5 switch index", verb="build",
                                 unit="entries")
        inv = switches_mod.inventory(repos["SOLPS-ITER"],
                                      progress=progress)
        switches_mod.write_inventory(inv, switches_path)
        switch_chunks = switches_mod.chunks(inv)
        all_chunks.extend(switch_chunks)
        switches_summary = {
            "json": switches_path.name if switches_path is not None else None,
            **inv["counts"],
            "chunks": len(switch_chunks),
        }
    elif switches_path is not None and not b25_present:
        # B2.5 leg absent: the switch inventory carries whole from the
        # previous store (cluster source_switch, stored order — the
        # position a fresh inventory would take).  The inventory JSON
        # beside the carry store is copied when resolvable; its bytes
        # are derivable from the carried inputs either way.
        if carry is None or not carry.switch_rows:
            raise CarryError(
                "SOLPS-ITER/modules/B2.5 is neither on disk nor recorded "
                "in the carry store; the switch inventory cannot be "
                "produced; clone the repo or install the matching index "
                "artifact")
        all_chunks.extend(carry.switch_chunks)
        carried_ids.update(id(c) for c in carry.switch_chunks)
        copied_json = None
        if carry.inventory_name:
            prev_json = Path(carry_from).parent / carry.inventory_name
            if prev_json.is_file():
                import shutil
                switches_path.parent.mkdir(parents=True, exist_ok=True)
                shutil.copyfile(prev_json, switches_path)
                copied_json = switches_path.name
        switches_summary = {
            "json": copied_json,
            "carried": True,
            "chunks": len(carry.switch_chunks),
        }

    # Fortran procedure units (B2.5 + EIRENE src roots),
    # appended after the switches — fixed order, so rowids stay
    # reproducible.  The summary records oversize/no-unit skips and
    # the indexed code-corpus MB (the payload measurement).
    fortran_summary: dict[str, Any] | None = None
    if include_fortran:
        from askthedocs import fortran as fortran_mod
        fortran_chunks, fortran_summary = fortran_mod.scan(
            repos["SOLPS-ITER"], progress=progress)
        # leg filter: units under absent legs (stray files inside an
        # uninitialized submodule's directory) are never indexed
        fresh_by_source: dict[str, list[store.Chunk]] = {}
        for chunk in fortran_chunks:
            repo, _, rel = chunk.source.partition("/")
            if present_leg(repo, rel):
                fresh_by_source.setdefault(chunk.source, []).append(chunk)
            else:
                stray.append(f"fortran {chunk.source}")
        carried_sources = {f"{r[1]}/{r[2]}" for r in
                           (carry.fortran_rows if carry else ())}
        for src in sorted(set(fresh_by_source) | carried_sources,
                          key=_fortran_key):
            if src in fresh_by_source:
                all_chunks.extend(fresh_by_source[src])
            elif carry is not None:
                for _c in carry.chunks_by_source.get(src, ()):
                    carried_ids.add(id(_c))
                    all_chunks.append(_c)
        total_units = sum(len(v) for v in fresh_by_source.values()) + sum(
            len(carry.chunks_by_source.get(s, ())) for s in carried_sources
        ) if carry else len(fortran_chunks)
        fortran_summary = {**fortran_summary, "chunks": total_units}
        if carried_sources:
            fortran_summary["carried_files"] = len(carried_sources)

    # the DB stores its own build manifest — the input state
    # (corpus manifest entries + Fortran walk + switch XMLs) hashed at
    # build time, so `askthedocs status` can diff the repos against what
    # this artifact was actually built from.  Collected BEFORE the DB
    # is (re)created so a hashing failure never leaves a half-written
    # store behind.
    from askthedocs import state
    # carried mode: rows come from the FILTERED disk manifest (strays
    # under absent legs are never inputs) + the carried legs' recorded
    # rows, verbatim — the state a full rebuild with those legs cloned
    # at the same commits would record
    if progress is not None:
        # the input re-hash + normalization between the last visible
        # stage and the store write: real seconds, previously silent
        # (a frozen screen reads as a hang)
        progress.begin_busy("finishing up")
    filtered_manifest = {**manifest, "files": disk_records}
    manifest_rows = state.build_inputs(
        filtered_manifest, repos,
        include_switches=switches_path is not None and b25_present,
        include_fortran=include_fortran)
    if include_fortran:
        manifest_rows = [row for row in manifest_rows
                         if present_leg(row[1], row[2])]
    if carry is not None:
        manifest_rows = (manifest_rows + carry.corpus_rows
                         + carry.switch_rows + carry.fortran_rows)

    # build-time text normalization — ligature folding (measured
    # census: 1,243 chunks carry PDF-extraction ligature forms) and
    # evidence-gated hyphenation joins (840 chunks carry end-of-line
    # splits; a split joins only when the corpus itself already holds
    # the joined spelling).  Applied to every FRESH chunk BEFORE the
    # store is written, so all faces read the same normalized bytes;
    # chunk IDs derive from provenance and never change.  Carried
    # chunks skip the pass (they keep the extraction that
    # built them — re-normalizing would tie their bytes to today's
    # normalizer and break the A/B identity the suite asserts).
    from askthedocs import normalize as normalize_mod
    if carry is not None and carried_ids:
        fresh_idx = [i for i, c in enumerate(all_chunks)
                     if id(c) not in carried_ids]
        fresh_list = [all_chunks[i] for i in fresh_idx]
        fresh_list, normalize_stats = normalize_mod.normalize_chunks(
            fresh_list)
        for i, c in zip(fresh_idx, fresh_list):
            all_chunks[i] = c
    else:
        all_chunks, normalize_stats = normalize_mod.normalize_chunks(
            all_chunks)

    if progress is not None:
        # the store write is the one multi-second silent stretch left
        # (every chunk into both tables + the FTS index, one
        # transaction); the stage gives it a heartbeat so the tail
        # never reads as a hang (owner ruling 2026-11-03, paired with
        # dropping the 0s assemble line)
        progress.begin_stage("search index", verb="write",
                             unit="chunks", total=len(all_chunks))
    conn = store.create(db_path)
    try:
        store.insert_chunks(conn, all_chunks,
                            on_batch=(progress.tick if progress
                                      is not None else None))
        store.insert_manifest(conn, manifest_rows)
        total = store.count_chunks(conn)
    finally:
        conn.close()
    if progress is not None:
        progress.end_stage()

    # the artifact names itself — every face (CLI, MCP, web)
    # can prove it queries the exact build the summary describes.
    from askthedocs import corpus
    db_sha256 = corpus.sha256_file(db_path)

    web_pages: dict[str, Any] | None = None
    if pages_dir is not None:
        from askthedocs import webindex
        web_pages = webindex.write_pages(db_path, pages_dir)

    per_cluster: dict[str, int] = {}
    per_source: dict[str, int] = {}
    for chunk in all_chunks:
        per_cluster[chunk.cluster] = per_cluster.get(chunk.cluster, 0) + 1
        per_source[chunk.source] = per_source.get(chunk.source, 0) + 1

    # carried legs keep their pinned commits in the summary (the
    # corpus modal's rows read them); present legs come from this
    # scan's own heads/pointers.  A headless manifest stays headless
    # (None stays None — db_is_current compares identity)
    scanned_heads = manifest.get("heads")
    heads_out = dict(scanned_heads) if scanned_heads else scanned_heads
    pointers_out = _submodule_pointers(repos)
    if carry is not None:
        carried_leg_set = set(carry.legs)
        for k, v in carry.heads.items():
            if k in carried_leg_set:
                heads_out[k] = v
        for k, v in carry.pointers.items():
            if k in carried_leg_set or k.split("/")[0] in carried_leg_set:
                pointers_out.setdefault(k, v)

    summary: dict[str, Any] = {
        "schema": SCHEMA,
        "db": db_path.name,
        "db_sha256": db_sha256,
        "sources": {
            "extracted": extracted_sources,
            "failed": failed,
            "skipped": skipped,
            "pending_text": pending_text,
        },
        "chunks": {
            "total": total,
            "per_cluster": dict(sorted(per_cluster.items())),
            "per_source": dict(sorted(per_source.items())),
        },
        # the normalization pass's own record — what changed in
        # the store's text (counts only, never contents)
        "normalize": {
            "ligature_chunks": normalize_stats.ligature_chunks,
            "hyphen_joins": normalize_stats.hyphen_joins,
            "hyphen_joined_chunks": normalize_stats.hyphen_joined_chunks,
        },
        "build_manifest": {
            "sha256": state.manifest_sha256(manifest_rows),
            "sources": len(manifest_rows),
            "by_kind": state.count_by_kind(manifest_rows),
        },
        # the commit state the manifest pinned at scan time,
        # recorded beside the store it describes — an auditor reads the
        # exact commits without re-running git against the repos.  The
        # DB itself never stores it (heads are link provenance, not
        # chunk data — the store bytes stay byte-identical across the
        # schema bump).
        "repo_heads": heads_out,
        # amendment: EVERY submodule pointer under modules/, read
        # from the parent's tree at build time (gitlink mode 160000).
        # This includes submodules the corpus never scans — adas
        # (non-public repository, measured 404) — so the repository
        # modal can list the module tree COMPLETELY: present, pinned,
        # and honestly linkless where no public repository exists.
        "submodule_pointers": pointers_out,
    }
    if carry is not None and (carry.corpus_rows or carry.switch_rows
                              or carry.fortran_rows):
        # informational loudness, recorded beside the store:
        # every carried leg, the store its bytes came from (its own
        # sha — the honest disclosure that carried legs keep the
        # extraction that built them), and any stray disk files under
        # absent legs that were dropped, never silently indexed
        summary["carry"] = {
            "legs": carry.legs,
            "from_db_sha256": carry.from_sha,
            "corpus_sources": len(carry.corpus_rows),
            "fortran_files": len(carry.fortran_rows),
            "switch_inventory": bool(carry.switch_rows),
            "chunks": len(carried_ids),
            "stray_dropped": stray,
        }
    elif stray:
        summary["stray_dropped"] = stray
    if web_pages is not None:
        summary["web_pages"] = web_pages
    if switches_summary is not None:
        summary["switches"] = switches_summary
    if fortran_summary is not None:
        summary["fortran"] = fortran_summary
    if summary_path is not None:
        summary_path.parent.mkdir(parents=True, exist_ok=True)
        with open(summary_path, "w", encoding="utf-8") as fh:
            json.dump(summary, fh, indent=1, sort_keys=False)
            fh.write("\n")
    return summary


def load_manifest(path: Path) -> dict[str, Any]:
    """Read a corpus manifest, checking its schema tag."""
    manifest = json.loads(Path(path).read_text(encoding="utf-8"))
    from askthedocs import corpus
    if manifest.get("schema") != corpus.SCHEMA:
        raise ValueError(f"{path}: unknown corpus schema "
                         f"{manifest.get('schema')!r}")
    return manifest


def db_is_current(db_path: Path, summary_path: Path,
                  manifest: dict[str, Any]) -> bool:
    """True when an existing DB was built from exactly this manifest's
    text_rich source set AND its bytes still hash to the sha256 recorded
    in the summary (the repos are read-only, so it cannot drift; the
    hash check also rejects summaries from before , and the
    switches/fortran-stage checks below reject pre-/
    builds). Adds the build-manifest contract: the summary's
    ``build_manifest`` block must match the DB's own ``build_manifest``
    table (count AND aggregate hash), which also rejects pre-
    builds that carry no table at all. adds the repo-heads
    contract: the summary must record exactly the manifest's ``heads``
    block, which rejects every pre-summary (one-time rebuild
    after the corpus schema bump)."""
    if not db_path.is_file() or not summary_path.is_file():
        return False
    try:
        summary = json.loads(summary_path.read_text(encoding="utf-8"))
        conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
        try:
            db_count = store.count_chunks(conn)
            # the store must carry the switch cluster, in the
            # count the summary records (absent => stale pre-DB).
            switch_count = int(conn.execute(
                "SELECT COUNT(*) FROM chunks WHERE cluster = 'source_switch'"
            ).fetchone()[0])
            # same contract for the Fortran unit cluster.
            fortran_count = int(conn.execute(
                "SELECT COUNT(*) FROM chunks WHERE cluster = 'fortran_source'"
            ).fetchone()[0])
            # same contract for the build-manifest table.
            bm_rows = conn.execute(
                "SELECT kind, repo, path, sha256 FROM build_manifest"
            ).fetchall()
        finally:
            conn.close()
        from askthedocs import corpus
        from askthedocs import state
        db_sha256 = corpus.sha256_file(db_path)
    except (ValueError, OSError, sqlite3.Error):
        return False
    expected = {f"{r['repo']}/{r['path']}" for r in manifest["files"]
                if (r["text_status"] == "text_rich" and r["ext"] == ".pdf")
                or is_documentation_tex(r)
                or r["ext"] in (".rst", ".htm")
                # 2026-10-18 tutorials corpus: markdown enters ONLY via
                # SOLPS-Tutorials (corpus REPO_EXTENSIONS) — without
                # this arm the extracted set never matches and every
                # session wrongly rebuilds a fresh store
                or r["ext"] == ".md"
                or (r["repo"], r["path"]) == CHANGELOG_PATH}
    switches = summary.get("switches")
    fortran = summary.get("fortran")
    build_manifest = summary.get("build_manifest")
    return (summary.get("schema") == SCHEMA
            and summary.get("db_sha256") == db_sha256
            and set(summary.get("sources", {}).get("extracted", [])) == expected
            and not summary.get("sources", {}).get("failed")
            and summary.get("chunks", {}).get("total") == db_count
            and isinstance(switches, dict)
            and switches.get("chunks") == switch_count
            and isinstance(fortran, dict)
            and fortran.get("chunks") == fortran_count
            and isinstance(build_manifest, dict)
            and build_manifest.get("sources") == len(bm_rows)
            and build_manifest.get("sha256")
            == state.manifest_sha256([tuple(r) for r in bm_rows])
            # the summary's pinned commits must equal the
            # manifest's — a pre-summary (None) is stale
            and summary.get("repo_heads") == manifest.get("heads"))
