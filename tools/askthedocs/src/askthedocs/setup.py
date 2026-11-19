"""First-install setup: the floor gate, the index build, the bar.

One verb, run once after install (and safe to re-run): it checks the
floor, then builds the search index from the repositories on this
machine into the per-user location. The display opens with the
pending list: one line per category and content class (repository
documents, module sources, the switch inventory) with true counts,
each line leaving as its stage settles. The built index never lands
inside a checkout: it lives in the per-user share, found from any
directory, surviving re-clones and moves; the same doctrine seats any
fetched bulk later.

Second runs never rebuild silently: an existing index is reported
with its freshness verdict (current, or drifted and on what) and the
explicit rebuild path. ``--force`` is that path; a forced rebuild
carries legs that vanished since the last build (their recorded
sources keep their pinned extraction) and builds into a temporary
location that swaps in only on success.
"""

from __future__ import annotations

import os
from askthedocs import _sqlite  # the seam module (has_fts5)
from askthedocs._sqlite import sqlite3
from pathlib import Path

from askthedocs import build as build_mod
from askthedocs import corpus, floor, fortran, locate, state, switches, \
    verdicts
from askthedocs.progress import Progress, elapsed_str


def _display(path: Path) -> str:
    """Compact display form: the home directory reads as ``~``."""
    try:
        return "~/" + str(path.relative_to(Path.home()))
    except ValueError:
        return str(path)


def _require_fts5() -> None:
    """The build creates FTS5 tables; refuse before any work when
    neither the stdlib SQLite nor the pip-provided fallback carries
    the extension (the seam module chose the best binding already)."""
    if _sqlite.has_fts5:
        return
    raise SystemExit(
        "error: this Python's SQLite lacks the FTS5 extension; the "
        "index needs an SQLite with FTS5. Without any administrator: "
        "'pip install pysqlite3-binary' provides one (a complete "
        "SQLite; it installs automatically with askthedocs on Linux "
        "x86_64). Alternatively use a Python built with FTS5 "
        "(standard python.org installers have it). Nothing was built")


def _merge_manifests(parts: list[dict], repos: dict[str, Path]) -> dict:
    """Merge per-leg scans into the manifest ``build`` consumes.

    Byte-equivalent to one ``corpus.scan`` over the same repository
    set: the files list re-sorts to the same (repo, path) order, the
    heads merge disjointly, and the counts recompute from the merged
    files with the same bucketing.
    """
    files = sorted((record for part in parts for record in part["files"]),
                   key=lambda r: (r["repo"], r["path"]))
    counts: dict[str, dict[str, int]] = {}
    for record in files:
        for key in ("cluster", "text_status", "ext"):
            bucket = counts.setdefault(key, {})
            bucket[record[key]] = bucket.get(record[key], 0) + 1
    heads: dict[str, str] = {}
    for part in parts:
        heads.update(part.get("heads") or {})
    return {
        "schema": corpus.SCHEMA,
        "repos": sorted(repos),
        "heads": heads,
        "counts": {
            "files": len(files),
            "per_repo": {
                repo: sum(1 for r in files if r["repo"] == repo)
                for repo in sorted(repos)
            },
            **counts,
        },
        "files": files,
    }


def _freshness_block(db_path: Path, report: floor.FloorReport) -> int:
    """The idempotent second run: verdict, never a silent rebuild."""
    recorded = state.read_from_db(db_path)
    print(f"index already present: {_display(db_path)}")
    if recorded is None:
        print("  it carries no build manifest (older or foreign "
              "artifact); rebuild it with `askthedocs setup --force`")
        return 0
    # the full known universe, present legs and absent optional legs
    # alike: absent legs surface as "absent: not indexed", recorded
    # legs no longer on disk as carried
    repos = {name: report.root / name
             for name in (floor.ITER_REPO, *floor.OPTIONAL_REPOS)}
    repos[floor.ITER_REPO] = report.iter_path
    roll = verdicts.leg_verdicts(recorded, state.current_inputs(repos),
                                 repos)
    print(f"  built from corpus state "
          f"{state.manifest_sha256(recorded)[:8]} "
          f"({len(recorded)} input sources)")
    if any((roll.new, roll.changed, roll.removed)):
        print(f"  freshness: DRIFT: {len(roll.new)} new, "
              f"{len(roll.changed)} changed, {len(roll.removed)} removed")
    else:
        print("  freshness: current (no drift)")
    print("  legs:")
    for leg in roll.legs:
        print(f"    {leg.label()}")
    print("an existing index is never rebuilt silently; "
          "to rebuild anyway: askthedocs setup --force")
    return 0


def _pending_entries(doc_counts: dict[str, int],
                     src_totals: dict[str, int],
                     switch_entries: int) -> list[tuple[str, str | None]]:
    """The pending list in the order the work happens, so lines drain
    strictly top to bottom: documents first (in the store's fixed
    byte order - SOLPS-GUI, then SOLPS-ITER with its module
    documents indented, then SOLPS-Tutorials), then the switch
    inventory, then the sources in walk order (the repository's own
    scripts last). Each entry is (rendered line, stage label); the
    label matches the indexing stage that settles it. The excepted
    submodule never drains and sits at the end."""
    def line(label: str, count: int, unit: str, *,
             indent: str = "") -> tuple[str, str]:
        return f"{indent}{label:<28}{count:>6} {unit}", label

    entries: list[tuple[str, str | None]] = []
    if doc_counts.get("SOLPS-GUI"):
        entries.append(line("SOLPS-GUI documents",
                            doc_counts["SOLPS-GUI"], "files"))
    if doc_counts.get("SOLPS-ITER"):
        entries.append(line("SOLPS-ITER documents",
                            doc_counts["SOLPS-ITER"], "files"))
    for mod in sorted(doc_counts):
        if doc_counts[mod] and mod not in ("SOLPS-ITER", "SOLPS-GUI",
                                           "SOLPS-Tutorials"):
            entries.append(line(f"{mod} documents", doc_counts[mod],
                                "files", indent="  "))
    if doc_counts.get("SOLPS-Tutorials"):
        entries.append(line("SOLPS-Tutorials documents",
                            doc_counts["SOLPS-Tutorials"], "files"))
    entries.append(line("B2.5 switch index", switch_entries, "entries"))
    for mod in sorted(src_totals):
        if mod in ("SOLPS-ITER", "scripts"):
            continue
        entries.append(line(f"{mod} fortran source", src_totals[mod],
                            "files"))
    if src_totals.get("scripts"):
        entries.append(line("scripts fortran source",
                            src_totals["scripts"], "files"))
    entries.append((f"{'adas':<28}excepted (non-public)", None))
    return entries


class _DocStages:
    """Drives one INDEXING stage per documentation category as the
    scan walk crosses category boundaries (categories are contiguous
    in walk order). The single visit extracts and chunks each file;
    the file callback names the file, and the stage counter advances
    only when a file is finished (on_file_done ticks the bar)."""

    def __init__(self, bar: Progress, totals: dict[str, int]):
        self._bar = bar
        self._totals = totals
        self._current: str | None = None

    def __call__(self, repo: str, rel: str, size: int) -> None:
        cat = corpus.doc_category(repo, rel)
        if cat != self._current:
            self._bar.end_stage()
            self._bar.begin_stage(f"{cat} documents", verb="scan",
                                  unit="files", total=self._totals[cat],
                                  counts_files=True)
            self._current = cat
        self._bar.current_file(rel, size)

    def close(self) -> None:
        self._bar.end_stage()


def run_index_build(repos: dict[str, Path], *, bar: Progress,
                    build_dir: Path, final_dir: Path,
                    carry_from: Path | None = None,
                    install_icon: bool = False) -> tuple[dict, Path | None]:
    """The display-driven rebuild shared by the CLI setup verb and
    the service's reindex job: the pending table, the single-visit
    per-leg scan, the build, then the atomic swap under the
    "verifying the index" busy line. One sequence of display calls,
    so every face that rebuilds an index shows the same lines (the
    service replays *bar*'s captured frames in the web progress
    modal). Builds into *build_dir* and swaps the store, summary,
    switches and manifest into *final_dir* ONLY on success: any
    failure cleans *build_dir* and leaves the served index
    byte-untouched. Returns ``(summary, icon_path)``; raises
    RuntimeError with the user-facing message when the build did not
    produce its artifacts (the CLI re-raises it as SystemExit)."""
    import shutil

    iter_repo = repos[floor.ITER_REPO]
    carry_from = carry_from if (carry_from and Path(carry_from).is_file()) \
        else None

    # the enumeration is real seconds of silent work (tens of
    # thousands of stat calls on the full corpus): the busy line
    # covers it in BOTH faces - the CLI terminal and the web progress
    # modal's first frames - so the run never reads as stalled before
    # the pending table lands.  Cleared by the first stage.
    bar.begin_busy("counting the corpus")

    # fast pre-scan enumeration, no hashing and no PDF probing: the
    # per-category counts the pending list shows (module attribution
    # mirrors the categories the stages will cross), the switch-entry
    # total from the census universe, and the global file total
    doc_counts: dict[str, int] = {}
    for leg in sorted(repos):
        for repo, rel, _p in corpus.walk_sources({leg: repos[leg]}):
            cat = corpus.doc_category(repo, rel)
            doc_counts[cat] = doc_counts.get(cat, 0) + 1
    src_totals: dict[str, int] = {}
    for p in fortran.walk_paths(iter_repo):
        cat = fortran.source_category(p.relative_to(iter_repo).as_posix())
        src_totals[cat] = src_totals.get(cat, 0) + 1
    switch_entries = len(set(switches.census_reads(iter_repo))
                         | set(switches.documented_defaults(iter_repo)))
    bar.set_pending(_pending_entries(doc_counts, src_totals,
                                     switch_entries))
    bar.start(files_total=sum(doc_counts.values()) + sum(src_totals.values()),
              legs_total=len(repos))

    # the single visit: extract, classify, and chunk each document
    # once, one indexing stage per category; the cache carries the
    # chunks to the build so nothing is extracted twice
    stages = _DocStages(bar, doc_counts)
    preextracted: dict[str, dict] = {}
    parts: list[dict] = []
    for leg in sorted(repos):
        parts.append(corpus.scan({leg: repos[leg]}, progress=stages,
                                 file_bar=bar, preextracted=preextracted,
                                 on_file_done=bar.tick))
    stages.close()
    manifest = _merge_manifests(parts, repos)

    shutil.rmtree(build_dir, ignore_errors=True)
    build_dir.mkdir(parents=True, exist_ok=True)
    corpus.write_manifest(manifest, build_dir / "corpus.json")
    try:
        summary = build_mod.build(
            manifest, repos, build_dir / locate.DB_NAME,
            build_dir / locate.SUMMARY_NAME,
            switches_path=build_dir / "switches.json",
            include_fortran=True, carry_from=carry_from, progress=bar,
            preextracted=preextracted)
    except BaseException:
        shutil.rmtree(build_dir, ignore_errors=True)
        raise
    # an unreadable source no longer voids the build (D-170): the
    # failure is collected with its reason, the summary records it,
    # and the completion block names it. The index swaps as a whole
    # or not at all, exactly as before.
    # every companion lands or none does: the store, its summary, the
    # switches inventory and the manifest swap in together, after the
    # build proved it produced them all
    companions = (locate.DB_NAME, locate.SUMMARY_NAME, "switches.json",
                  "corpus.json")
    for name in companions:
        if not (build_dir / name).is_file():
            shutil.rmtree(build_dir, ignore_errors=True)
            raise RuntimeError(
                f"error: the build did not produce {name}; nothing was "
                "changed (the previous index, if any, still stands)")
    final_dir.mkdir(parents=True, exist_ok=True)
    for name in companions:
        os.replace(build_dir / name, final_dir / name)
    shutil.rmtree(build_dir, ignore_errors=True)

    # the tail between the build's last stage and the summary:
    # swap-in, validation, icon - previously silent seconds
    bar.begin_busy("verifying the index")
    # the artifact names itself: prove the pair validates before
    # announcing completion
    locate.validate_store(final_dir / locate.DB_NAME)

    # the icon is part of initial setup: installed on every
    # build by default, refreshed when already present; refused with
    # --no-icon. Enhancement-never-gate: an icon failure is a note,
    # never a failed setup.
    icon_path = None
    if install_icon:
        try:
            from askthedocs import shortcut
            icon_path = shortcut.install()
        except (SystemExit, OSError) as exc:
            print(f"note: the desktop icon was not installed: {exc}")

    bar.end_busy()
    bar.finish()
    return summary, icon_path


def run_setup(path: Path | str | None = None, *, force: bool = False,
              share: Path | None = None,
              install_icon: bool = True) -> int:
    """The `setup` verb: gate, pending list, then build (or verdict).

    *install_icon* is the default: every BUILD installs (or
    refreshes) the desktop icon, `--no-icon` refuses, and an icon
    failure never fails setup (enhancement-never-gate). Freshness
    re-runs stay side-effect-free - the icon is born with a build.

    Raises :class:`askthedocs.floor.FloorError` when the floor fails;
    the caller prints it and exits nonzero.
    """
    # the destination resolves BEFORE the gate: the recorded root the
    # gate's ladder reads moved with the index when the home is
    # redirected (--home / $ASKTHEDOCS_HOME; the per-user share
    # otherwise)
    share = locate.index_home() if share is None else Path(share)
    report = floor.check_floor(path, share=share)
    print(f"SOLPS-ITER checkout: {report.iter_path}  "
          f"(found via {report.via})")
    if not report.ok:
        raise SystemExit(floor.format_refusal(report))
    absent = [name for name, present in report.optional if not present]
    if absent:
        print("not on this machine: "
              + ", ".join(f"{name} (optional; not indexed)"
                          for name in absent))
    print("note: some course and plot documents contain dense vector "
          "figures; a single page of those can take tens of seconds "
          "(the line under the stage names the file being worked)")

    db_path = share / locate.DB_NAME
    # the install-time fact every later gate and freshness check
    # reads back: the index knows where it was born, so the
    # service and the CLI resolve the corpus from ANY directory
    floor.record_root(report.root, share=share)
    if db_path.is_file() and not force:
        return _freshness_block(db_path, report)
    _require_fts5()
    # a redirected build names the default-location index it leaves
    # untouched (the move recipe keeps that one instead of paying a
    # fresh build)
    if locate.index_home_redirected():
        share_db = locate.user_share() / locate.DB_NAME
        if share_db.is_file():
            print(f"note: the index at {share_db} stays untouched; "
                  f"this build writes the index home {share} (the "
                  "README tells how to move an index without "
                  "rebuilding)")

    repos = report.repos
    bar = Progress()
    # the shared display-driven rebuild (the service's reindex job
    # runs the same driver, so both faces show the same lines); the
    # forced rebuild carries from the index it replaces and lands in
    # a temporary directory that swaps in only on success
    try:
        summary, icon_path = run_index_build(
            repos, bar=bar, build_dir=share / "build-tmp",
            final_dir=share, carry_from=db_path,
            install_icon=install_icon)
    except RuntimeError as exc:
        raise SystemExit(str(exc)) from None
    print("=" * 72)
    # the completion block speaks chunks, classified by where each
    # chunk was extracted from (one vocabulary everywhere -
    # documents, switch entries, procedures - never "sources" or
    # "units"; the visitor-vs-extracted distinction lives in the
    # table above, this block counts what became searchable)
    chunks = summary["chunks"]
    per_cluster = chunks["per_cluster"]
    per_source = chunks["per_source"]
    extracted = summary["sources"]["extracted"]
    switch_total = per_cluster.get("source_switch", 0)
    proc_total = per_cluster.get("fortran_source", 0)
    fortran_files_n = ((summary.get("fortran") or {}).get("files")
                       or {}).get("indexed", 0)

    def _n(count: int, noun: str) -> str:
        # pluralize the LAST word only ("switch entry" -> "switch
        # entries", never "switch entrys"); irregulars by map
        if count == 1:
            return f"1 {noun}"
        head, _, last = noun.rpartition(" ")
        plural = {"entry": "entries"}.get(last, last + "s")
        return f"{count:,} {head + ' ' if head else ''}{plural}"

    docs_by_leg: dict[str, int] = {}
    for src in extracted:
        leg = src.split("/", 1)[0]
        docs_by_leg[leg] = docs_by_leg.get(leg, 0) + per_source.get(src, 0)
    doc_chunks = sum(docs_by_leg.values())
    parts = [f"{doc_chunks:,} from {_n(len(extracted), 'document')}"]
    if switch_total:
        parts.append(_n(switch_total, "switch entry"))
    if proc_total:
        parts.append(f"{_n(proc_total, 'procedure')} from "
                     f"{_n(fortran_files_n, 'fortran file')}")
    print(f"setup complete: {_n(chunks['total'], 'chunk')} "
          f"({', '.join(parts)})")
    print("legs:")
    for name, present in [(floor.ITER_REPO, True), *report.optional]:
        if not present:
            print(f"  {name:<16} absent: not indexed on this machine")
            continue
        doc_n = sum(1 for src in extracted
                    if src.split("/", 1)[0] == name)
        doc_c = docs_by_leg.get(name, 0)
        leg_switches = switch_total if name == floor.ITER_REPO else 0
        leg_procs = proc_total if name == floor.ITER_REPO else 0
        leg_total = doc_c + leg_switches + leg_procs
        parts = [f"{doc_c:,} from {_n(doc_n, 'document')}"]
        if leg_switches:
            parts.append(_n(leg_switches, "switch entry"))
        if leg_procs:
            parts.append(f"{_n(leg_procs, 'procedure')} from "
                         f"{_n(fortran_files_n, 'fortran file')}")
        # ONE line per leg, however long - the same convention the
        # headline, the index path and the remove command already
        # follow (no wrap-at-the-frame: the frame was never a
        # uniform bound, so only some legs obeying it was arbitrary)
        print(f"  {name:<16} indexed: {leg_total:,} chunks "
              f"({', '.join(parts)})")
    failed_srcs = summary["sources"]["failed"]
    if failed_srcs:
        # D-170 skip-and-name: ONE line, however long (the legs'
        # own convention), first three names, the summary file holds
        # every name with its reason
        names = ", ".join(f["source"] for f in failed_srcs[:3])
        more = len(failed_srcs) - 3
        verb = "was" if len(failed_srcs) == 1 else "were"
        extra = f", and {more} more" if more > 0 else ""
        print(f"note: {_n(len(failed_srcs), 'source')} could not be "
              f"read and {verb} skipped: {names}{extra} "
              f"(each recorded in {locate.SUMMARY_NAME} beside the "
              f"index)")
    import shutil
    import sys
    console = shutil.which("askthedocs") or str(
        Path(sys.executable).with_name("askthedocs"))
    print(f"Total time: {elapsed_str(bar.elapsed)}")
    print("=" * 72)
    print(f"index can be found here: {db_path}")
    if locate.index_home_redirected():
        print("  (the index home: outside every checkout, found from "
              "any directory, survives re-clones)")
        print(f"  index home: {share} (--home / $ASKTHEDOCS_HOME)")
        print(f"  export ASKTHEDOCS_HOME={share} once and every face "
              "finds it")
    else:
        print("  (the per-user location: outside every checkout, found from "
              "any directory, survives re-clones)")
    print("=" * 72)
    print("what's next:")
    print("  1. the web version: ranked search with citations, in "
          "your browser")
    print(f"     CLI startup: {console} open")
    if icon_path is not None:
        # the icon IS the same launch one gesture away; the line names
        # the click target, omitted when no icon was installed
        print(f"     Icon startup: {icon_path}")
    print("  2. a search from the terminal")
    print(f'       {console} search "drifts"')
    print("  3. ask an AI assistant: connect it through MCP and it "
          "searches for you")
    print("     (the README's MCP section is the wiring recipe)")
    print("=" * 72)
    return 0
