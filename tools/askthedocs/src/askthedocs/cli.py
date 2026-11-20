"""askthedocs command-line interface.

skeleton; adds the `corpus` subcommand (inventory writer);
adds `build` (text-rich PDFs -> SQLite chunk store + FTS5);
adds `search` (ranked hits with snippets) and `show` (one chunk
in full). Since both are thin printers over `askthedocs.api` —
the library every face (CLI, MCP, web) shares. has `build`
also emit the per-chunk index-input pages for the web search index.
labels every hit with its cluster and adds `--cluster`.
adds `status`: re-hash the corpus and diff it against the
build manifest stored in the DB (content hashes, never mtimes).
the diff rolls up to per-leg verdicts (current / drifted /
carried) — an absent-but-recorded leg is carried information, never
phantom "removed" drift — and `corpus` gains the first-step gate:
every leg must be on disk or recorded in the current store.
"""

from __future__ import annotations

import argparse
from askthedocs._sqlite import sqlite3
import sys
from pathlib import Path

from askthedocs import __version__
from askthedocs import api
from askthedocs import build as build_mod
from askthedocs import corpus
from askthedocs import floor
from askthedocs import locate
from askthedocs import state
from askthedocs import verdicts
from askthedocs import webindex


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        prog="askthedocs",
        description="Search the SOLPS-ITER documentation corpus with citations.",
    )
    parser.add_argument(
        "--version", action="version", version=f"askthedocs {__version__}"
    )
    sub = parser.add_subparsers(dest="command")

    # the one redirect: every index-holding verb takes --home (the
    # mirror of solps-reader's catalog --home); consumed ONCE in
    # main() so the override is set or cleared per invocation
    home_parent = argparse.ArgumentParser(add_help=False)
    home_parent.add_argument(
        "--home", type=Path, default=None, metavar="PATH",
        help="where the index lives: the database, its build "
             "manifest, and every companion file under one directory "
             "(default: the per-user share; $ASKTHEDOCS_HOME moves it "
             "wholesale; --db still names one file directly and wins)",
    )

    p_setup = sub.add_parser(
        "setup",
        parents=[home_parent],
        help="first-install command: check the floor, build the search "
             "index into the index home, the per-user location by "
             "default (re-runs report freshness instead of "
             "rebuilding; --force rebuilds)",
    )
    p_setup.add_argument(
        "path", type=Path, default=None, nargs="?",
        help="path to the SOLPS-ITER checkout (default: discover via "
             "$ASKTHEDOCS_REPOS_ROOT, the launch directory, ~/SOLPS-ITER)",
    )
    p_setup.add_argument(
        "--force", action="store_true",
        help="rebuild the index even when one exists (a vanished leg "
             "keeps its pinned extraction: carried)",
    )
    p_setup.add_argument(
        "--no-icon", action="store_true",
        help="skip the desktop icon setup installs by default "
             "(installed on every build, refreshed when present; "
             "removable any time with `shortcut --remove`)",
    )

    p_corpus = sub.add_parser(
        "corpus",
        help="write the corpus inventory manifest (out/corpus.json)",
    )
    p_corpus.add_argument(
        "--out", type=Path, default=None,
        help="output JSON path (default: <project>/out/corpus.json)",
    )
    p_corpus.add_argument(
        "--iter", type=Path, default=None,
        help="SOLPS-ITER repo path (default: sibling of this project)",
    )
    p_corpus.add_argument(
        "--gui", type=Path, default=None,
        help="SOLPS-GUI repo path (default: sibling of this project)",
    )

    p_build = sub.add_parser(
        "build",
        help="rebuild the chunk store (out/askthedocs.db) from the corpus manifest",
    )
    p_build.add_argument(
        "--manifest", type=Path, default=None,
        help="corpus manifest to read (default: <project>/out/corpus.json)",
    )
    p_build.add_argument(
        "--db", type=Path, default=None,
        help="chunk-store database to write (default: <project>/out/askthedocs.db)",
    )
    p_build.add_argument(
        "--summary", type=Path, default=None,
        help="build summary JSON to write (default: <project>/out/build_summary.json)",
    )
    p_build.add_argument(
        "--pages", type=Path, default=None,
        help=("per-chunk index-input pages to emit (ONLY when given; "
              "the static web face was archived 2026-10-20, "),
    )
    p_build.add_argument(
        "--carry-from", type=Path, default=None,
        help=("previous store whose recorded legs are carried verbatim "
              "when absent from disk (default: the store being "
              "rebuilt, when it exists)"),
    )

    p_search = sub.add_parser(
        "search",
        parents=[home_parent],
        help="ranked search over the chunk store",
    )
    p_search.add_argument(
        "query", nargs="+",
        help="search terms (joined with a space; full FTS5 syntax allowed)",
    )
    p_search.add_argument(
        "--db", type=Path, default=None,
        help="chunk-store database to read (default: the discovery "
             "ladder, same as every read face: $ASKTHEDOCS_DB, "
             "./askthedocs-db/, the index home)",
    )
    p_search.add_argument(
        "--limit", type=int, default=20,
        help="maximum hits to print (default: 20)",
    )
    p_search.add_argument(
        "--cluster", default=None,
        help=("restrict hits to one cluster (e.g. fortran_source, "
              "source_switch, eirene_manual); default: all clusters "
              "ranked together)"),
    )

    p_show = sub.add_parser(
        "show",
        parents=[home_parent],
        help="print one chunk in full, with its provenance",
    )
    p_show.add_argument("chunk_id", help="chunk ID from a search hit")
    p_show.add_argument(
        "--db", type=Path, default=None,
        help="chunk-store database to read (default: the discovery "
             "ladder, same as every read face: $ASKTHEDOCS_DB, "
             "./askthedocs-db/, the index home)",
    )

    p_status = sub.add_parser(
        "status",
        parents=[home_parent],
        help="diff the corpus against the index's build manifest)",
    )
    p_status.add_argument(
        "--db", type=Path, default=None,
        help="chunk-store database to read (default: the discovery "
             "ladder, same as search: $ASKTHEDOCS_DB, "
             "./askthedocs-db/, the index home, "
             "~/.local/share/askthedocs/ unless --home / "
             "$ASKTHEDOCS_HOME moves it)",
    )
    p_status.add_argument(
        "--iter", type=Path, default=None,
        help="SOLPS-ITER repo path (default: sibling of this project)",
    )
    p_status.add_argument(
        "--gui", type=Path, default=None,
        help="SOLPS-GUI repo path (default: sibling of this project)",
    )

    p_open = sub.add_parser(
        "open",
        help="one click: start the service if it is down, then open "
             "the browser (idempotent: if it is up, just open)",
    )
    p_open.add_argument(
        "--port", type=int, default=8000,
        help="port to serve on / connect to (default: 8000)",
    )
    p_open.add_argument(
        "--host", default="127.0.0.1",
        help="interface to serve on / connect to (default: 127.0.0.1)",
    )
    p_open.add_argument(
        "--restart", action="store_true",
        help="the explicit convergence verb: stop a running service "
             "and start a fresh one with the current context; "
             "REFUSES while a rebuild is in flight (needed only for "
             "env changes: the store swaps live inside a running "
             "service, so a restart is never about the corpus)",
    )

    p_shortcut = sub.add_parser(
        "shortcut",
        help="install the one-click launcher icon for this platform "
             "(.app under ~/Applications on macOS, .desktop on "
             "Linux, .cmd in the Start Menu on Windows; all "
             "user-level, no admin)",
    )
    p_shortcut.add_argument(
        "--remove", action="store_true",
        help="remove the launcher instead of installing it",
    )
    return parser


def _repos_from(args: argparse.Namespace, *,
                allow_missing: bool = False) -> dict[str, Path]:
    """The corpus universe for status/corpus: explicit --iter/--gui
    win; otherwise the shared discovery ladder (environment root,
    launch directory, ~/SOLPS-ITER), falling back to the sibling
    layout beside the project when the ladder finds nothing.

    ``allow_missing`` (corpus/status) keeps absent repo
    paths in the dict — the gate then decides per leg between
    the informational carry notice and the refusal.
    """
    explicit_iter = getattr(args, "iter", None)
    explicit_gui = getattr(args, "gui", None)
    if explicit_iter is not None or explicit_gui is not None:
        repos = corpus.default_repos()
        if explicit_iter is not None:
            repos["SOLPS-ITER"] = explicit_iter
        if explicit_gui is not None:
            repos["SOLPS-GUI"] = explicit_gui
    else:
        from askthedocs import floor
        try:
            # the recorded root is read from the index home (it moved
            # with the index when the home is redirected)
            report = floor.check_floor(share=locate.index_home())
        except floor.FloorError:
            repos = corpus.default_repos()
        else:
            repos = {floor.ITER_REPO: report.iter_path}
            for name in floor.OPTIONAL_REPOS:
                repos[name] = report.root / name
    for name, path in repos.items():
        if not path.is_dir() and not allow_missing:
            raise SystemExit(f"error: repo not found: {name} at {path}")
    return repos


def _d88_gate(repos: dict[str, Path], db_path: Path) -> None:
    """First-step gate: every leg must be on disk or
    recorded in the current store.  Absent-but-recorded legs print
    the informational carry notice (exit success — loud, not an
    error); an absent OPTIONAL repository is named and skipped — the
    same rule setup applies (a machine without it simply indexes
    without it); anything else — required legs neither present nor
    carryable — refuses BEFORE any work, naming each leg and its
    expected path with both remedies.  Refusal is the
    transition-and-integrity register: steady-state operation with a
    shipped index cannot reach it."""
    recorded = state.read_from_db(db_path) or []
    recorded_legs = {verdicts.leg_name(r[1], r[2]) for r in recorded}
    present = {name: path for name, path in repos.items()
               if path.is_dir()}
    missing: list[str] = []
    # declared repos
    for name, path in sorted(repos.items()):
        if path.is_dir():
            continue
        if name in recorded_legs:
            print(f"carried: {name} not on disk ({path}); recorded in "
                  f"the current index; it will be carried at its "
                  f"pinned commit")
        elif name in floor.OPTIONAL_REPOS:
            print(f"optional: {name} not on disk ({path}) and not in "
                  f"the current index; it is not required and stays "
                  f"unindexed until cloned")
        else:
            missing.append(f"{name} at {path}")
    # gitlink-declared submodules never initialized (parent present)
    for repo, declared in sorted(corpus.submodule_state(present).items()):
        for sub, initialized in sorted(declared.items()):
            if initialized:
                continue
            if sub == floor.EXCEPTED_SUBMODULE:
                # the non-public submodule nobody can initialize
                # (setup's own excepted line names it): absent on
                # EVERY real clone by design, never a leg, never a
                # demand — demanding it refused this verb on every
                # actual checkout (the hermetic fixture trees carry
                # no git, so no test ever walked this loop)
                continue
            leg = f"{repo}/{sub}"
            if leg in recorded_legs:
                print(f"carried: {leg} declared but not initialized "
                      f"({repos[repo] / sub}); recorded in the current "
                      f"index; it will be carried at its pinned commit")
            else:
                missing.append(f"{leg} at {repos[repo] / sub} "
                               f"(gitlink declared, never initialized)")
    if missing:
        raise SystemExit(
            "error: cannot produce a complete index: these legs are "
            "neither on disk nor recorded in the current store:\n" +
            "".join(f"         {m}\n" for m in missing) +
            "       clone them (or git submodule update), or install "
            "the matching index artifact; ASKTHEDOCS_REPOS_ROOT points "
            "at another corpus root")


def cmd_corpus(args: argparse.Namespace) -> int:
    repos = _repos_from(args, allow_missing=True)
    _d88_gate(repos, build_mod.default_db())
    out = args.out or corpus.default_out()
    manifest = corpus.scan(repos)
    corpus.write_manifest(manifest, out)

    counts = manifest["counts"]
    print(f"wrote {out}: {counts['files']} sources")
    for repo, n in counts["per_repo"].items():
        print(f"  {repo}: {n}")
    print("  by text_status:", dict(sorted(counts["text_status"].items())))
    print("  by cluster:", dict(sorted(counts["cluster"].items())))
    return 0


def cmd_build(args: argparse.Namespace) -> int:
    manifest_path = args.manifest or corpus.default_out()
    if not manifest_path.is_file():
        raise SystemExit(
            f"error: corpus manifest not found: {manifest_path}\n"
            f"       run `askthedocs corpus` first"
        )
    manifest = build_mod.load_manifest(manifest_path)
    repos = corpus.default_repos()
    db_path = args.db or build_mod.default_db()
    # carried rebuild: absent legs carry from the store being
    # rebuilt (the default when it exists); with no carry store at
    # all, an absent repo refuses before any work — a complete index
    # or a loud nothing
    carry_from = getattr(args, "carry_from", None)
    if carry_from is None and db_path.is_file():
        carry_from = db_path
    if carry_from is None:
        missing = {n: p for n, p in repos.items() if not p.is_dir()}
        if missing:
            raise SystemExit(
                "error: cannot produce a complete index: no carry store "
                "and these repositories are absent:\n" + "".join(
                    f"         {n} at {p}\n"
                    for n, p in sorted(missing.items())) +
                "       clone them, or install the matching index artifact")
    summary_path = args.summary or build_mod.default_summary()
    # pages emit only on explicit request — the static web
    # face is archived (out/archive/), outside the delivery pipeline
    pages_dir = args.pages
    from askthedocs import switches as switches_mod
    try:
        summary = build_mod.build(manifest, repos, db_path, summary_path,
                                  pages_dir=pages_dir,
                                  switches_path=switches_mod.default_switches(),
                                  include_fortran=True,
                                  carry_from=carry_from)
    except build_mod.CarryError as exc:
        print(f"error: {exc}", file=sys.stderr)
        print("       clone the missing legs or install the matching "
              "index artifact; a complete index or a loud nothing",
              file=sys.stderr)
        return 1

    chunks = summary["chunks"]
    src = summary["sources"]
    print(f"wrote {db_path}: {chunks['total']} chunks from "
          f"{len(src['extracted'])} sources")
    print(f"  sha256 {summary['db_sha256']}")
    bm = summary["build_manifest"]
    kinds = ", ".join(f"{n} {kind}" for kind, n in bm["by_kind"].items())
    print(f"  corpus state: {bm['sha256'][:8]} "
          f"({bm['sources']} input sources: {kinds})")
    print("  by cluster:", dict(chunks["per_cluster"]))
    switches = summary.get("switches")
    if switches is not None:
        print(f"  switches: {switches['switches']} in {switches['json']} "
              f"({switches['read_sites']} Fortran read sites)")
    fortran = summary.get("fortran")
    if fortran is not None:
        files = fortran["files"]
        print(f"  fortran source: {fortran['chunks']} procedure units from "
              f"{files['indexed']} files ({fortran['mb_indexed']} MB; "
              f"{files['oversize']} oversize, {files['no_unit']} no-unit "
              f"skips listed in {summary_path})")
    web_pages = summary.get("web_pages")
    if web_pages is not None:
        print(f"  web index input: {web_pages['pages']} pages in "
              f"{web_pages['dir']}")
    skipped = ", ".join(
        f"{len(paths)} {reason}" for reason, paths in src["skipped"].items()
    )
    print(f"  skipped (listed in {summary_path}): {skipped}")
    carried = summary.get("carry")
    if carried:
        # informational loudness — the rebuild's own output
        # names every carried leg with its pinned commit
        print(f"  carried {len(carried['legs'])} legs from store "
              f"{carried['from_db_sha256'][:8]} "
              f"({carried['chunks']} chunks kept at their shipped "
              f"extraction):")
        heads = summary.get("repo_heads") or {}
        for leg in carried["legs"]:
            commit = heads.get(leg)
            print(f"    {leg} @ "
                  f"{commit[:9] if commit else 'pinned commit'}")
        if carried.get("stray_dropped"):
            print(f"  dropped {len(carried['stray_dropped'])} stray disk "
                  f"files under absent legs (never indexed; listed in "
                  f"{summary_path})")
    if src["failed"]:
        print(f"  FAILED to extract {len(src['failed'])} sources "
              f"(details in {summary_path})")
    print(f"  pending other formats: {src['pending_text']} text sources "
          f"/)")
    if src["failed"]:
        return 1
    return 0


def cmd_search(args: argparse.Namespace) -> int:
    if args.limit < 1:
        raise SystemExit(f"error: --limit must be >= 1, got {args.limit}")
    query = " ".join(args.query)
    try:
        result = api.search(query, db_path=args.db, limit=args.limit,
                            cluster=args.cluster)
    except FileNotFoundError as exc:
        raise SystemExit(f"error: {exc}")
    except ValueError as exc:
        raise SystemExit(f"error: {exc}")
    except sqlite3.OperationalError as exc:
        raise SystemExit(f"error: query failed: {exc}")

    if not result.hits:
        scope = f" in cluster {args.cluster}" if args.cluster else ""
        print(f"no hits for:{scope} {query}")
        # + : the zero-hit recovery card — only words that
        # CO-OCCUR with the rest of the query, each with its true
        # click-yield count (side-by-side count riding along), the
        # side-by-side tier first; when nothing combines, the (c)
        # escape hatch offers each typed term that yields hits alone
        if result.did_you_mean:
            print(f'  did you mean "{result.did_you_mean}"?')
        if result.completions:
            shown = ", ".join(
                f"{w} ({n}, {a} side-by-side)" if a else f"{w} ({n})"
                for w, n, a in result.completions[:8])
            last = query.split()[-1] if query.split() else query
            print(f"  words starting with '{last}': {shown}")
        elif result.separate_terms:
            shown = ", ".join(f"{t} ({n})"
                              for t, n in result.separate_terms)
            print(f"  but we have results for: {shown}")
        if result.absent_legs:
            named = " / ".join(result.absent_legs)
            print(f"  the answer might be in {named}: not indexed on "
                  "this machine")
        return 0
    note = (f" (showing {len(result.hits)}; --limit for more)"
            if result.total > len(result.hits) else "")
    scope = f" in cluster {args.cluster}" if args.cluster else ""
    print(f"{result.total} hits for:{scope} {query}{note}")
    for i, hit in enumerate(result.hits, 1):
        where = hit.source
        if hit.page is not None:
            where += f" p.{hit.page}"
        print()
        print(f"[{i}] {where}")
        print(f"    cluster: {hit.cluster}")
        if hit.section:
            print(f"    section: {hit.section}")
        if hit.identity:
            # identity tier: this chunk's citation IS the query —
            # the exact-key equality, ranked ahead of everything
            print(f"    exact name: citation is '{hit.section}' (ranked first)")
        if hit.phrase_hit:
            # phrase tier: the hit contains the plain query's
            # tokens as one adjacent phrase and ranks ahead of all
            # non-phrase hits (bm25 still orders within the tier)
            print(f"    phrase: query terms adjacent (ranked first)")
        print(f"    id: {hit.chunk_id}")
        print(f"    {hit.snippet}")
    return 0


def cmd_show(args: argparse.Namespace) -> int:
    try:
        chunk = api.get(args.chunk_id, db_path=args.db)
    except FileNotFoundError as exc:
        raise SystemExit(f"error: {exc}")
    if chunk is None:
        raise SystemExit(f"error: no chunk with id {args.chunk_id}")

    print(f"chunk_id:  {chunk.chunk_id}")
    print(f"source:    {chunk.source}")
    print(f"cluster:   {chunk.cluster}")
    print(f"section:   {chunk.section if chunk.section is not None else '-'}")
    print(f"page:      {chunk.page if chunk.page is not None else '-'}")
    print("text:")
    print(chunk.text)
    return 0


def cmd_status(args: argparse.Namespace) -> int:
    """re-hash the corpus and diff it against the DB's own
    build manifest.  Exit 0 = index current; 1 = drift (cron/CI/hooks
    gate on this); 2 = nothing to compare (run `askthedocs setup`)."""
    # the same discovery ladder every read face rides (search, show,
    # service): --db verbatim, then ASKTHEDOCS_DB, then the accepted
    # placements with their loud refusal.  The old default (the
    # two-step out/ path beside the package) resolved inside an
    # installed package's venv and refused a perfectly good per-user
    # index.
    try:
        db_path = locate.resolve_db(args.db)
    except (FileNotFoundError, locate.StoreValidationError) as exc:
        print(f"error: {exc}", file=sys.stderr)
        return 2
    recorded = state.read_from_db(db_path)
    if recorded is None:
        print(f"error: no build manifest in {db_path}\n"
              f"       run `askthedocs setup` first", file=sys.stderr)
        return 2
    repos = _repos_from(args, allow_missing=True)
    current = state.current_inputs(repos)
    roll = verdicts.leg_verdicts(recorded, current, repos)

    def describe(rows: list[state.Row]) -> str:
        kinds = ", ".join(f"{n} {kind}" for kind, n
                          in state.count_by_kind(rows).items())
        return f"{len(rows)} input sources ({kinds})"

    print(f"index built from corpus state "
          f"{state.manifest_sha256(recorded)[:8]}: {describe(recorded)}")
    print(f"current corpus state "
          f"{state.manifest_sha256(current)[:8]}: {describe(current)}")
    if roll.repos_present == 0:
        print("no repositories on disk: every leg is carried; the index "
              "is complete as shipped and its freshness cannot be "
              "checked locally")
    print("legs:")
    for leg in roll.legs:
        print(f"  {leg.label()}")
    if not any((roll.new, roll.changed, roll.removed)):
        print(f"no drift: 0 new, 0 changed, 0 removed; {roll.summary()}")
        return 0
    print(f"DRIFT: {len(roll.new)} new, {len(roll.changed)} changed, "
          f"{len(roll.removed)} removed; rebuild with "
          f"`askthedocs setup --force`")
    for label in roll.new:
        print(f"  new      {label}")
    for label in roll.changed:
        print(f"  changed  {label}")
    for label in roll.removed:
        print(f"  removed  {label}")
    return 1


def main(argv: list[str] | None = None) -> int:
    parser = build_parser()
    args = parser.parse_args(argv)
    # the --home override is set OR cleared per invocation, so no
    # stale redirect leaks into the next in-process caller (the
    # reader's set_catalog_root pattern)
    locate.set_index_home(getattr(args, "home", None))
    if args.command == "setup":
        from askthedocs import floor, setup as setup_mod
        try:
            return setup_mod.run_setup(args.path, force=args.force,
                                       install_icon=not args.no_icon)
        except floor.FloorError as exc:
            print(str(exc), file=sys.stderr)
            return 1
    if args.command == "corpus":
        return cmd_corpus(args)
    if args.command == "build":
        return cmd_build(args)
    if args.command == "search":
        return cmd_search(args)
    if args.command == "show":
        return cmd_show(args)
    if args.command == "status":
        return cmd_status(args)
    if args.command == "open":
        from askthedocs import launch
        return launch.open_cmd(args.port, args.host,
                               restart=args.restart)
    if args.command == "shortcut":
        from askthedocs import shortcut
        if args.remove:
            path = shortcut.remove()
            print(f"removed: {path}")
            return 0
        path = shortcut.install()
        print(f"installed: {path}")
        print("  one click starts askthedocs and opens the page "
              "(re-run anytime to refresh; the installed command's "
              "absolute path is baked in; a moved install needs a "
              "re-run)")
        return 0
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
