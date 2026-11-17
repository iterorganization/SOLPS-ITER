"""Command-line interface: ``solps_reader <family> <command>``.

Commands per family:

- ``ft44 summary <file>`` — header, species, per-field statistics.
- ``ft44 export <file> --field <key> -o <out>`` — one field to .npz/.csv.
- ``ft44 plot <file> --field <key> -o <out.png>`` — pcolormesh on the
  (ix, iy) index grid, or physical R-Z with ``--geometry``.
- ``ft46 summary`` / ``ft46 export`` — the same treatment for the
  triangle-mesh tallies.
- ``nc summary <file>`` — dimensions + per-variable table.
- ``nc dump <file> --var <name> -o <out.npz>`` — one variable.
- ``nc plot <file> -o <out.png>`` — every 1-D record variable as a
  convergence trace against the record dimension, in the spirit of the
  reference ``scripts/2dt.py`` (which plots b2time.nc variables against
  ``timesa``, scripts/2dt.py:23,34-39).
- ``state summary <b2fstate>`` — with ``--check-grid <b2fgmtry>``
  verifying that the state and geometry files describe the same grid
  (dims + coordinates).
- ``state diff A B`` — a same-grid, same-species A/B comparison deck
  (per-field overlay + difference figures and a summary report) with
  optional b2time.nc convergence annotations — cross-grid regridding is
  a non-goal (mismatch refuses with exit 2).
- ``plasma summary <file>`` — the full plasma solution (binary
  b2fplasma or its ASCII twin b2fplasmf, detected from the bytes):
  header, the seven block inventories, core-field statistics.  Grid
  dims come from the sibling b2fstate (the converter's own source for
  them); ``--b2fstate``/``--dims`` override.
- ``plasma field <file> <name>`` — one record's shape, statistics and
  first values.
- ``plasma export <file> -o <out.npz>`` — every record as arrays
  (npz-only: species-resolved records have no honest csv layout).
- ``setup [path]`` — the floor check plus a status report: where the
  SOLPS-ITER checkout was found, its submodules, and the run-catalog
  snapshot. The same floor gates every analysis command above and the
  MCP server (``--version``/``--help`` stay exempt: refusing a version
  query over a missing repository is theater).
- ``catalog compare <run-a> <run-b> [--remove] [--no-build]`` — record
  any two runs (group-qualified names, cross-group pairs included) as
  an A/B state-diff comparison and rebuild: the pair's deck and page
  land under your built site; a side no group provides, a missing
  b2fstate, or a grid/species mismatch is a named skip, never a failed
  build. Comparisons survive rebuilds (they live in the sources file).
- ``catalog add <path> [--label NAME] [--before GROUP]`` — remember a
  runs folder as a catalog group. New groups sit LAST in display
  order and the position is yours to choose: ``catalog move <group>
  <position>`` repositions one (a 1-based number as ``catalog list``
  numbers them, or first / last / up / down); display order never
  auto-sorts, and the example runs always follow last.
  ``catalog remove <group>`` drops one, ``catalog list`` shows the
  groups with their status. The verbs edit the remembered sources
  file in the per-user share — no checkout needed, nothing is built.
- ``catalog build [--runs PATH]... [--no-examples] [--in-tree]
  [--force] [--prune-cache] [--catalog PATH]`` — rebuild the
  run-catalog site over the catalog groups: the remembered sources in
  list order plus the example runs always last, or a one-shot
  repeatable ``--runs`` set for this build alone. Paths are cataloged
  in the order given. A user build seats in the per-user share and
  never touches the shipped pages; ``--in-tree`` writes beside the
  builders (the maintainer's bump path). Unchanged runs reuse their
  cached analysis (``--force`` recomputes everything, byte-identical
  either way; ``--prune-cache`` drops entries a build did not
  reference). ``catalog open`` opens the built site (yours first,
  else the shipped example pages, named). Every catalog verb also
  takes ``--home PATH`` (and honors ``$SOLPS_READER_HOME``):
  the one redirect moving the whole catalog — sources file, analysis
  cache, built sites, gallery — off the quota-limited per-user share.
"""

from __future__ import annotations

import argparse
import json
import os
import subprocess
import sys
from pathlib import Path

import numpy as np

import solps_reader
from solps_reader import catalog_sources, floor
from solps_reader.ft44 import Ft44, Ft44Field, Ft44FormatError, read_ft44
from solps_reader.ft46 import Ft46, Ft46Field, Ft46FormatError, read_ft46
from solps_reader.gmtry import B2fgmtry, B2fgmtryFormatError, read_b2fgmtry
from solps_reader.nc import NcFile, NcFormatError, load_nc
from solps_reader.plasma import (
    B2fplasma,
    B2fplasmaFormatError,
    read_b2fplasma,
)
from solps_reader.state import B2fstate, B2fstateFormatError, read_b2fstate

#: Width of the label column in the summary header block ("grid", "version",
#: "species", "fields").
_LABEL_W = 13


def _add_ft44_subparser(subparsers: argparse._SubParsersAction) -> None:
    """Attach the ``ft44`` family parser with its ``summary`` command."""
    ft44 = subparsers.add_parser(
        "ft44", help="fort.44: EIRENE → B2.5 source terms (ASCII)"
    )
    commands = ft44.add_subparsers(dest="command", metavar="<command>", required=True)
    summary = commands.add_parser(
        "summary", help="print header, species and a per-field statistics table"
    )
    summary.add_argument("file", help="path to a fort.44 file")
    export = commands.add_parser(
        "export", help="export one field as npz (default) or csv"
    )
    export.add_argument("file", help="path to a fort.44 file")
    export.add_argument(
        "--field",
        required=True,
        metavar="KEY",
        help="field key exactly as the summary table shows it "
        "(disambiguated keys, e.g. 'wldnek_2' for a repeated name)",
    )
    export.add_argument(
        "-o", "--output", required=True, help="output path (.npz or .csv)"
    )
    export.add_argument(
        "--format",
        choices=("npz", "csv"),
        default=None,
        help="output format (default: inferred from the output extension)",
    )
    plot = commands.add_parser(
        "plot",
        help="render one field as a pcolormesh on the (ix, iy) index grid, "
        "or on physical R-Z coordinates with --geometry",
    )
    plot.add_argument("file", help="path to a fort.44 file")
    plot.add_argument(
        "--field",
        required=True,
        metavar="KEY",
        help="field key exactly as the summary table shows it "
        "(disambiguated keys, e.g. 'wldnek_2' for a repeated name)",
    )
    plot.add_argument(
        "--geometry",
        metavar="B2FGMTRY",
        default=None,
        help="b2fgmtry file: paint the field on physical R-Z cell coordinates "
        "(equal aspect, metres); omit for the (ix, iy) index grid",
    )
    plot.add_argument(
        "-o",
        "--output",
        required=True,
        help="output PNG path",
    )


def _add_ft46_subparser(subparsers: argparse._SubParsersAction) -> None:
    """Attach the ``ft46`` family parser with its ``summary``/``export``."""
    ft46 = subparsers.add_parser(
        "ft46", help="fort.46: EIRENE triangle-mesh tallies (ASCII)"
    )
    commands = ft46.add_subparsers(dest="command", metavar="<command>", required=True)
    summary = commands.add_parser(
        "summary", help="print header, species and a per-field statistics table"
    )
    summary.add_argument("file", help="path to a fort.46 file")
    export = commands.add_parser(
        "export", help="export one field as npz (default) or csv"
    )
    export.add_argument("file", help="path to a fort.46 file")
    export.add_argument(
        "--field",
        required=True,
        metavar="KEY",
        help="field key exactly as the summary table shows it "
        "(disambiguated keys, e.g. 'volumes_2' for a repeated name)",
    )
    export.add_argument(
        "-o", "--output", required=True, help="output path (.npz or .csv)"
    )
    export.add_argument(
        "--format",
        choices=("npz", "csv"),
        default=None,
        help="output format (default: inferred from the output extension)",
    )


def _add_nc_subparser(subparsers: argparse._SubParsersAction) -> None:
    """Attach the ``nc`` family parser with its ``summary``/``dump``."""
    nc = subparsers.add_parser(
        "nc", help="b2*.nc: NetCDF-3 output files (b2time, b2batch, ...)"
    )
    commands = nc.add_subparsers(dest="command", metavar="<command>", required=True)
    summary = commands.add_parser(
        "summary", help="print dimensions and a per-variable metadata table"
    )
    summary.add_argument("file", help="path to a NetCDF-3 classic file")
    dump = commands.add_parser("dump", help="export one variable as npz")
    dump.add_argument("file", help="path to a NetCDF-3 classic file")
    dump.add_argument(
        "--var",
        required=True,
        metavar="NAME",
        help="variable name exactly as the summary table shows it",
    )
    dump.add_argument(
        "-o", "--output", required=True, help="output path (npz format)"
    )
    plot = commands.add_parser(
        "plot",
        help="plot every 1-D record variable (convergence traces) vs the "
        "record dimension",
    )
    plot.add_argument("file", help="path to a NetCDF-3 classic file")
    plot.add_argument(
        "-o", "--output", required=True, help="output PNG path"
    )


def _add_state_subparser(subparsers: argparse._SubParsersAction) -> None:
    """Attach the ``state`` family parser with its ``summary`` command."""
    state = subparsers.add_parser(
        "state", help="b2fstate/b2fstati: B2.5 plasma state + fluxes (cf-ASCII)"
    )
    commands = state.add_subparsers(dest="command", metavar="<command>", required=True)
    summary = commands.add_parser(
        "summary", help="print header, species and a per-field statistics table"
    )
    summary.add_argument("file", help="path to a b2fstate/b2fstati file")
    summary.add_argument(
        "--check-grid",
        metavar="B2FGMTRY",
        default=None,
        help="verify grid consistency against a b2fgmtry file (dims, guard "
        "box and coordinates); prints PASS/FAIL and exits 1 on FAIL",
    )
    diff = commands.add_parser(
        "diff",
        help="compare two b2fstate/b2fstati files on the same grid: "
        "overlay + difference figures and a summary report",
    )
    diff.add_argument(
        "file_a", help="path to the A ('before') b2fstate/b2fstati file"
    )
    diff.add_argument(
        "file_b", help="path to the B ('after') b2fstate/b2fstati file"
    )
    diff.add_argument(
        "-o",
        "--output",
        required=True,
        help="output directory: one PNG per catalog field plus "
        "diff_summary.txt (created if absent)",
    )
    diff.add_argument(
        "--geometry",
        metavar="B2FGMTRY",
        default=None,
        help="b2fgmtry file: render on physical R-Z cell coordinates "
        "(equal aspect, metres); omit for the (ix, iy) index grid",
    )
    diff.add_argument(
        "--b2time-a",
        metavar="PATH",
        default=None,
        help="b2time.nc of run A for a convergence annotation "
        "(informational; does not gate the diff)",
    )
    diff.add_argument(
        "--b2time-b",
        metavar="PATH",
        default=None,
        help="b2time.nc of run B for a convergence annotation "
        "(informational; does not gate the diff)",
    )


def build_parser() -> argparse.ArgumentParser:
    """Build the top-level argument parser."""
    parser = argparse.ArgumentParser(
        prog="solps-reader",
        description="Readers & CLI for SOLPS-ITER output files",
    )
    parser.add_argument(
        "--version", action="version", version=f"%(prog)s {solps_reader.__version__}"
    )
    subparsers = parser.add_subparsers(dest="family", metavar="<family>")
    _add_setup_subparser(subparsers)
    _add_catalog_subparser(subparsers)
    _add_ft44_subparser(subparsers)
    _add_ft46_subparser(subparsers)
    _add_nc_subparser(subparsers)
    _add_state_subparser(subparsers)
    _add_plasma_subparser(subparsers)
    return parser


def _add_plasma_subparser(subparsers: argparse._SubParsersAction) -> None:
    """Attach the ``plasma`` family parser (summary / field / export)."""
    plasma = subparsers.add_parser(
        "plasma",
        help="b2fplasma/b2fplasmf: the full plasma solution (binary "
        "Fortran records or the formatted twin, auto-detected)",
    )
    commands = plasma.add_subparsers(
        dest="command", metavar="<command>", required=True
    )

    def _dims_options(cmd):
        cmd.add_argument(
            "--b2fstate", metavar="PATH", default=None,
            help="b2fstate to take nx,ny,ns from (default: the sibling "
            "b2fstate beside the file; the converter's own source)",
        )
        cmd.add_argument(
            "--dims", metavar="NX,NY,NS", default=None,
            help="explicit grid dims when no b2fstate is available",
        )

    summary = commands.add_parser(
        "summary",
        help="print header, the seven block inventories and core-field "
        "statistics",
    )
    summary.add_argument("file", help="path to a b2fplasma/b2fplasmf file")
    _dims_options(summary)
    field = commands.add_parser(
        "field", help="print one record's shape, statistics, first values"
    )
    field.add_argument("file", help="path to a b2fplasma/b2fplasmf file")
    field.add_argument(
        "name", metavar="RECORD",
        help="record name exactly as the summary's block inventory "
        "shows it (e.g. te, na, csigin)",
    )
    _dims_options(field)
    export = commands.add_parser(
        "export", help="write every record to one .npz (arrays keyed by name)"
    )
    export.add_argument("file", help="path to a b2fplasma/b2fplasmf file")
    export.add_argument(
        "-o", "--output", required=True, help="output path (npz format)"
    )
    _dims_options(export)


def _add_setup_subparser(subparsers: argparse._SubParsersAction) -> None:
    setup = subparsers.add_parser(
        "setup",
        help="floor check + status report: where the SOLPS-ITER "
             "checkout is, its submodules, the run-catalog snapshot",
    )
    setup.add_argument(
        "path", type=Path, default=None, nargs="?",
        help="path to the SOLPS-ITER checkout (default: discover via "
             "$ASKTHEDOCS_REPOS_ROOT, the launch directory, ~/SOLPS-ITER)",
    )


def _add_catalog_subparser(subparsers: argparse._SubParsersAction) -> None:
    """Attach the ``catalog`` family parser (the one build command)."""
    catalog = subparsers.add_parser(
        "catalog",
        help="the run-catalog site: rebuild it from a runs tree",
    )
    commands = catalog.add_subparsers(dest="command", metavar="<command>")
    # every catalog verb takes --home: the one redirect that moves the
    # whole catalog (sources file, analysis cache, built sites, the
    # gallery) off the quota-limited per-user share; the
    # $SOLPS_READER_HOME environment variable moves it for a
    # whole shell
    catalog_home = argparse.ArgumentParser(add_help=False)
    catalog_home.add_argument(
        "--home", metavar="PATH", default=None,
        help="where this catalog lives: the sources file, the "
             "analysis cache, and every built site seat under one "
             "root (default: the per-user share; "
             "$SOLPS_READER_HOME moves it wholesale)",
    )
    build = commands.add_parser(
        "build", parents=[catalog_home],
        help="rebuild the site (run manifests -> switch sets -> pages)",
    )
    build.add_argument(
        "--runs", metavar="PATH", action="append", default=None,
        help="a runs root, repeatable: the one-shot group set for "
             "THIS build, in display order; paths are cataloged in "
             "the order given and the example runs always follow "
             "last (default: the remembered sources file, "
             "'catalog add')",
    )
    build.add_argument(
        "--no-examples", action="store_true",
        help="omit the example-runs group",
    )
    build.add_argument(
        "--in-tree", action="store_true",
        help="write into the catalog tree's own out/ beside the "
             "builders: the maintainer's bump path; user builds seat "
             "in the per-user share and never touch the shipped pages",
    )
    build.add_argument(
        "--force", action="store_true",
        help="recompute every run's analysis, bypassing the cache "
             "(outputs stay byte-identical either way)",
    )
    build.add_argument(
        "--prune-cache", action="store_true",
        help="after a successful build, drop cache entries it did not "
             "reference (orphans are kept by default so re-adding a "
             "folder stays cheap)",
    )
    build.add_argument(
        "--catalog", metavar="PATH", default=None,
        help="the catalog tree holding the builders (default: "
             "$SOLPS_READER_CATALOG, ./catalog, or the launch directory "
             "itself when it is the catalog tree)",
    )
    add = commands.add_parser(
        "add", parents=[catalog_home],
        help="remember a runs folder as a catalog group (display "
             "order = list order)",
    )
    add.add_argument(
        "path", metavar="PATH",
        help="a runs root: a directory whose subdirectories are run "
             "families",
    )
    add.add_argument(
        "--label", metavar="NAME", default=None,
        help="the group label shown in the site (default: the "
             "folder's name)",
    )
    add.add_argument(
        "--before", metavar="GROUP", default=None,
        help="insert before this group (its label or path); default: "
             "after the last remembered group",
    )
    remove = commands.add_parser(
        "remove", parents=[catalog_home],
        help="drop a group from the remembered list")
    remove.add_argument(
        "group", metavar="GROUP",
        help="the group's label or its path",
    )
    move = commands.add_parser(
        "move", parents=[catalog_home],
        help="reposition a group in display order (the order never "
             "auto-sorts)",
    )
    move.add_argument(
        "group", metavar="GROUP",
        help="the group's label or its path",
    )
    move.add_argument(
        "position", metavar="POSITION",
        help="a 1-based number as 'catalog list' numbers them "
             "(out-of-range lands at the ends), or first / last / "
             "up / down",
    )
    commands.add_parser(
        "list", parents=[catalog_home],
        help="the remembered groups in display order, with "
             "their status")
    commands.add_parser(
        "open", parents=[catalog_home],
        help="open the built catalog site in a browser (your "
             "built site first, else the shipped example site, "
             "named)")
    compare = commands.add_parser(
        "compare", parents=[catalog_home],
        help="record any two runs as an A/B comparison and rebuild "
             "(cross-group pairs included)",
    )
    compare.add_argument(
        "a", metavar="RUN-A",
        help="group-qualified run name, as the site shows it",
    )
    compare.add_argument(
        "b", metavar="RUN-B",
        help="group-qualified run name, as the site shows it",
    )
    compare.add_argument(
        "--remove", action="store_true",
        help="drop the recorded pair instead (either order matches)",
    )
    compare.add_argument(
        "--no-build", action="store_true",
        help="record only; the next 'catalog build' picks it up",
    )
    gallery = commands.add_parser(
        "gallery", parents=[catalog_home],
        help="build the bundled case gallery (two healthy groups, a "
             "family-name collision, two sick folders, one recorded "
             "cross-group comparison) into the share and print its "
             "path: the dev/QA visual surface",
    )
    gallery.add_argument(
        "--catalog", metavar="PATH", default=None,
        help="the catalog tree holding the builders (same ladder as "
             "build)",
    )


def _catalog_tree(parser: argparse.ArgumentParser,
                  explicit: str | None) -> Path:
    """Locate the catalog tree (the directory holding build_catalog.py).

    Ladder: the --catalog path > $SOLPS_READER_CATALOG > ./catalog
    under the launch directory > the launch directory itself.  The
    builders are repo-folder content, so the tree is found where the
    package checkout lives — never inside an installed site-packages.
    """
    candidates: list[tuple[str, Path]] = []
    if explicit:
        candidates.append(("the --catalog path", Path(explicit).expanduser()))
    env_value = os.environ.get("SOLPS_READER_CATALOG")
    if env_value:
        candidates.append(
            ("$SOLPS_READER_CATALOG", Path(env_value).expanduser()))
    cwd = Path.cwd()
    candidates.append(("./catalog under the launch directory", cwd / "catalog"))
    candidates.append(("the launch directory itself", cwd))
    for via, cand in candidates:
        if (cand / "build_catalog.py").is_file():
            return cand
    tried = "\n".join(f"  - {v}: {c}" for v, c in candidates)
    parser.exit(2, "solps-reader: catalog tree not found (no "
                   "build_catalog.py beside it); tried:\n" + tried +
                   "\nrun from the package checkout, or pass --catalog / "
                   "set $SOLPS_READER_CATALOG\n")


def _run_catalog_build(parser: argparse.ArgumentParser,
                       args: argparse.Namespace, *,
                       out_override=None, sources_override=None,
                       runs_override=None) -> int:
    """The one-command catalog build: pair decks -> run manifests ->
    switch sets -> the site, over the catalog groups (the remembered
    sources + the example runs, or a one-shot --runs set).

    Seating (the placement doctrine): a user build writes the
    per-user share and never touches the checkout — the shipped pages
    beside the builders stay pristine; ``--in-tree`` is the
    maintainer's bump path (the rebuild that reproduces the shipped
    bytes for the gate).  The overrides serve the gallery verb (its
    own seat, sources, and one-shot group set).
    """
    tree = _catalog_tree(parser, getattr(args, "catalog", None))
    runs = (runs_override if runs_override is not None
            else getattr(args, "runs", None))
    if out_override is not None:
        out = Path(out_override)
        seat = f"{out}"
    elif getattr(args, "in_tree", False):
        out = tree / "out"
        seat = "the catalog tree (--in-tree, the maintainer path)"
    else:
        root = catalog_sources.sources_path().parent
        out = root / "out"
        seat = (f"the per-user share ({out})"
                if root == catalog_sources.default_share_root()
                else f"the catalog home at {out} "
                     "($SOLPS_READER_HOME / --home)")
    sources = (Path(sources_override)
               if sources_override is not None
               else catalog_sources.sources_path())
    runs_args = [flag for p in (runs or [])
                 for flag in ("--runs", str(p))]
    if getattr(args, "no_examples", False):
        runs_args.append("--no-examples")
    out_args = ["--out", str(out)]
    # the cache seats beside the sources file and is handed down
    # explicitly: builder subprocesses never guess a home
    cache_args = ["--cache", str(sources.parent / "cache")]
    if getattr(args, "force", False):
        cache_args.append("--force")
    if getattr(args, "prune_cache", False):
        cache_args.append("--prune-cache")
    # the pair-deck stage: recorded comparisons always; a user build
    # also seats its own family decks (the examples' are committed).
    # The sources path is resolved HERE and handed down — builder
    # subprocesses never guess a home.
    sources_args = ["--sources", str(sources)]
    deck_args = ["--recorded", *sources_args, *runs_args]
    if not getattr(args, "in_tree", False):
        deck_args += ["--user-families", "--seat-out", str(out)]
    # the user-seat build moment (the determinism rule): a wall
    # clock rides ONLY the per-user share build — the maintainer
    # --in-tree path and the gallery's override seat stay clock-free
    # (the site renders the line only when user groups stand, so an
    # examples-only user build stays clean too)
    from datetime import datetime
    site_args = list(out_args)
    if (not getattr(args, "in_tree", False)
            and out_override is None):
        site_args += ["--built-at",
                      datetime.now().isoformat(timespec="seconds")]
    steps = (
        ("pair decks",
         [sys.executable, str(tree / "build_diff_decks.py"), *deck_args]),
        ("run manifests",
         [sys.executable, str(tree / "build_manifests.py"),
          *runs_args, *out_args, *cache_args, *sources_args]),
        ("switch sets",
         [sys.executable, str(tree / "build_switchsets.py"),
          *runs_args, *out_args, *sources_args]),
        ("the site",
         [sys.executable, str(tree / "build_catalog.py"), *site_args]),
    )
    for label, cmd in steps:
        proc = subprocess.run(cmd, cwd=str(tree))
        if proc.returncode != 0:
            print(f"solps-reader: catalog build failed at {label} "
                  f"(exit {proc.returncode})", file=sys.stderr)
            return 2
    site = out / "site" / "index.html"
    print(f"catalog site: {site}")
    print(f"seated in {seat}")
    print("open it in a browser or 'solps-reader catalog open'; the "
          "recipe and the maintainer contract live in the package "
          "README, 'The catalog in depth'")
    return 0


def _run_catalog_gallery(parser: argparse.ArgumentParser,
                         args: argparse.Namespace) -> int:
    """The case gallery: the bundled synthetic fixtures through the
    REAL build path, into the share's own gallery seat — two healthy
    groups (one carrying an automatic family-pair deck), the same
    family name in both (the collision case), two sick folders
    (named + skipped), and one recorded cross-group comparison.  A
    dev/QA surface: open it to see every display case at once; it
    never touches the user's own sources, site, or cache."""
    tree = _catalog_tree(parser, getattr(args, "catalog", None))
    fixtures = tree.parent / "tests" / "fixtures" / "gallery"
    groups = [fixtures / "alpha", fixtures / "beta",
              fixtures / "sick-empty", fixtures / "sick-junk"]
    missing = [str(g) for g in groups if not g.is_dir()]
    if missing:
        parser.exit(2, "solps-reader: gallery fixtures missing: "
                      + ", ".join(missing) + "\n(run from the package "
                      "checkout; the fixtures ship in its tests)\n")
    seat = catalog_sources.sources_path().parent / "gallery"
    sources = seat / "sources.json"
    sources.parent.mkdir(parents=True, exist_ok=True)
    sources.write_text(
        '{\n  "comparisons": [\n    {"a": "alpha/FAM_X/run_a",'
        '\n     "b": "beta/FAM_X/run_c"}\n  ],\n'
        '  "sources": []\n}\n',
        encoding="utf-8")
    print("gallery: building the bundled case fixtures "
          "(two healthy groups, a family-name collision, two sick "
          "folders, one recorded cross-group comparison)")
    rc = _run_catalog_build(
        parser, args, out_override=seat / "out", sources_override=sources,
        runs_override=[str(g) for g in groups])
    if rc == 0:
        print("gallery site: " + str(seat / "out" / "site" / "index.html"))
        print("open it in a browser: every display case on one page")
    return rc


def _run_catalog_open(parser: argparse.ArgumentParser) -> int:
    """Open the built site: the user's share build first, else the
    shipped example pages beside the builders — each named."""
    import webbrowser
    share = (catalog_sources.sources_path().parent / "out" / "site"
             / "index.html")
    if share.is_file():
        webbrowser.open(share.resolve().as_uri())
        print(f"opened your built catalog site: {share}")
        return 0
    try:
        tree = _catalog_tree(parser, None)
    except SystemExit:
        tree = None
    shipped = tree / "out" / "site" / "index.html" if tree else None
    if shipped is not None and shipped.is_file():
        webbrowser.open(shipped.resolve().as_uri())
        print(f"opened the shipped example site: {shipped}")
        print("your own runs: 'solps-reader catalog add <path>', then "
              "'solps-reader catalog build'")
        return 0
    print("error: no catalog site found: build one first "
          "('solps-reader catalog build'; it seats in "
          f"{catalog_sources.sources_path().parent / 'out'})",
          file=sys.stderr)
    return 2


def _run_catalog_groups(args: argparse.Namespace) -> int:
    """The remembered-group verbs: add / remove / list. Pure
    share-file work — no checkout, no build (the floor gates
    analysis, not remembering a folder; refusing an 'add' over a
    missing checkout would be theater)."""
    path = catalog_sources.sources_path()
    # ONE catch for the whole verb family: every branch (list included
    # — its load once escaped as a raw traceback) and every post-verb
    # re-print answers a corrupt sources file with the named one-line
    # remedy and exit 2, the refusal doctrine the file's own errors
    # promise
    try:
        # name the redirected seat whenever the catalog lives away
        # from the default share (quota-limited homes): the verbs
        # that read and write here should say WHERE here is
        if path.parent != catalog_sources.default_share_root():
            print(f"catalog home: {path.parent} "
                  "(--home / $SOLPS_READER_HOME)")
        if args.command == "add":
            entry = catalog_sources.add(path, args.path,
                                        label=args.label,
                                        before=args.before)
            data = catalog_sources.load(path)
            entries = data["sources"]
            at = next(i for i, e in enumerate(entries)
                      if e["path"] == entry["path"]
                      and e["label"] == entry["label"]) + 1
            # the post-add position hint : the group
            # sits where it sits, the position is the user's to choose
            where = ("last" if at == len(entries)
                     else f"position {at} of {len(entries)}")
            print(f"{entry['label']} sits {where} in display order: "
                  "the position is yours to choose ('solps-reader "
                  "catalog move <group> <position>'; the example runs "
                  "always follow last)")
            _print_groups(data)
            print("next: solps-reader catalog build")
            return 0
        if args.command == "move":
            entry, at = catalog_sources.move(path, args.group,
                                             args.position)
            n = len(catalog_sources.load(path)["sources"])
            print(f"moved {entry['label']} to position {at} of {n}")
            _print_groups(catalog_sources.load(path))
            return 0
        if args.command == "remove":
            entry = catalog_sources.remove(path, args.group)
            print(f"removed {entry['label']} ({entry['path']})")
            _print_groups(catalog_sources.load(path))
            return 0
        _print_groups(catalog_sources.load(path))
        return 0
    except catalog_sources.SourcesError as exc:
        print(str(exc), file=sys.stderr)
        return 2


def _print_groups(data: dict) -> None:
    """The groups in display order with an honest status each; the
    header names the fixed last group the ladder renders (the
    examples are never a stored source)."""
    print("catalog groups (display order; the example runs always "
          "follow last):")
    entries = data.get("sources", [])
    if not entries:
        print("  none remembered: 'solps-reader catalog add <path>'")
    for i, entry in enumerate(entries, 1):
        root = Path(entry["path"])
        if not root.is_dir():
            status = "absent"
        elif catalog_sources.has_runs(root):
            status = "ok"
        else:
            status = "no runs found"
        print(f"  {i}. {entry['label']}  [{status}]  {entry['path']}")
    comps = data.get("comparisons", [])
    if comps:
        print("recorded comparisons:")
        for c in comps:
            print(f"  {c.get('a', '?')} vs {c.get('b', '?')}")


def _run_catalog_compare(args: argparse.Namespace,
                         parser: argparse.ArgumentParser) -> int:
    """The compare verb: record (or remove) an A/B pair — pure
    share-file work, ungated like the other group verbs — then, unless
    --no-build, rebuild through the gated path so the pair's deck and
    page land in the same command."""
    path = catalog_sources.sources_path()
    try:
        if args.remove:
            entry = catalog_sources.remove_comparison(path, args.a, args.b)
            print(f"removed comparison {entry['a']} vs {entry['b']}")
            print("the next 'solps-reader catalog build' drops its page")
            return 0
        entry = catalog_sources.add_comparison(path, args.a, args.b)
    except catalog_sources.SourcesError as exc:
        print(str(exc), file=sys.stderr)
        return 2
    print(f"recorded {entry['a']} vs {entry['b']}")
    if args.no_build:
        print("next: solps-reader catalog build")
        return 0
    _gate_floor()
    build_args = argparse.Namespace(
        family="catalog", command="build", runs=None, no_examples=False,
        in_tree=False, force=False, prune_cache=False, catalog=None)
    return _run_catalog_build(parser, build_args)


def _gate_floor() -> None:
    """The floor gate before any analysis command: no SOLPS-ITER
    checkout with initialized submodules, no reader. Discovery uses
    the shared ladder; the refusal names each missing piece with its
    remedy."""
    try:
        report = floor.check_floor()
    except floor.FloorError as exc:
        raise SystemExit(str(exc)) from None
    if not report.ok:
        raise SystemExit(floor.format_refusal(report))


def _run_setup(args: argparse.Namespace) -> int:
    """The setup verb: the gate's status report, never a refusal
    alone; plus the run-catalog snapshot line."""
    try:
        report = floor.check_floor(args.path)
    except floor.FloorError as exc:
        print(str(exc), file=sys.stderr)
        return 1
    print(floor.format_report(report))
    if not report.ok:
        raise SystemExit(floor.format_refusal(report))
    # the install-time fact every later gate and ladder rung reads
    # back (the same doctrine as the askthedocs setup): the floor and
    # the runs ladder resolve the checkout from any directory
    floor.record_root(report.root)

    catalog_root = Path(__file__).resolve().parents[2] / "catalog" / "out"
    index_path = catalog_root / "index.json"
    if index_path.is_file():
        try:
            n_runs = len(json.loads(
                index_path.read_text(encoding="utf-8"))["runs"])
        except (ValueError, KeyError, OSError):
            n_runs = None
        count = f"{n_runs} runs" if n_runs is not None else "present"
        print(f"run catalog snapshot: {catalog_root} ({count})")
        print(f"  site: {catalog_root / 'site' / 'index.html'} "
              "(open in a browser)")
    else:
        print("run catalog snapshot: not found beside this install")
        print("  (it ships in the repository clone under "
              "solps-reader/catalog/)")
    print("next: solps-reader ft44 summary <path/to/fort.44>")
    print("      solps-mcp                     (the MCP face, gated the "
          "same way)")
    return 0


def _stat_cells(data) -> list[str]:
    """min/max/mean cells for one field; ``-`` each for zero-size blocks.

    Legacy fixtures may hold zero-size blocks for absent species classes
    (nmol=0 runs, read_ft44.m:69-70), which have no statistics to show.
    Non-finite values (NaN guard cells in unconverged states) are left
    out of the statistics and counted in a trailing note — ``nan`` must
    never print as if it were a number.
    """
    if data.size == 0:
        return [f"{'-':>15}"] * 3
    finite = data[np.isfinite(data)]
    if finite.size == 0:
        return [f"{'non-finite':>15}"] * 3
    cells = [
        f"{finite.min():15.6e}",
        f"{finite.max():15.6e}",
        f"{finite.mean():15.6e}",
    ]
    if finite.size < data.size:
        cells.append(f"[{data.size - finite.size} non-finite]")
    return cells


def _species_label_lines(header) -> list[str]:
    """Per-class species-label lines shared by the summary renderers."""
    lines = []
    for label, group in (
        ("atoms", header.species_atoms),
        ("molecules", header.species_molecules),
        ("ions", header.species_ions),
    ):
        if group:
            lines.append(f"  {label:<{_LABEL_W - 2}}{' '.join(group)}")
    return lines


def _field_table(fields) -> list[str]:
    """Per-field statistics table (name/size/min/max/mean), shared by families.

    The first column is the disambiguated key — the handle ``export
    --field`` accepts — so repeated names stay individually addressable.
    Keys may contain spaces (Fortran padding, stratum indices,
    ``(not computed)`` variants), so the column is rendered positionally.
    """
    name_w = max([len(f.key) for f in fields] + [len("name")])
    lines = [
        f"{'name':<{name_w}}  {'size':>6}  {'min':>15}  {'max':>15}  {'mean':>15}"
    ]
    for f in fields:
        lines.append(f"{f.key:<{name_w}}  {f.size:>6}  " + "  ".join(_stat_cells(f.data)))
    return lines


def format_ft44_summary(ft: Ft44, path: str | None = None) -> str:
    """Render a fort.44 overview: header, species, per-field statistics.

    The table's first column is the disambiguated key — the handle
    ``solps_reader ft44 export --field`` accepts — so repeated field
    names (per-stratum wall tallies) stay individually addressable.
    """
    h = ft.header
    out = [f"fort.44: {path}" if path else "fort.44"]
    out.append(f"{'grid':<{_LABEL_W}}nx={h.nx} ny={h.ny}")
    version = str(h.version)
    if h.git_hash:
        version += f" (git {h.git_hash})"
    out.append(f"{'version':<{_LABEL_W}}{version}")
    counts = f"natm={h.natm} nmol={h.nmol} nion={h.nion}"
    if h.nfla is not None:
        counts += f" nfla={h.nfla}"
    out.append(f"{'species':<{_LABEL_W}}{counts}")
    out.extend(_species_label_lines(h))
    out.append(f"{'fields':<{_LABEL_W}}{len(ft.fields)}")
    out.append("")
    out.extend(_field_table(ft.fields))
    return "\n".join(out) + "\n"


def format_ft46_summary(ft: Ft46, path: str | None = None) -> str:
    """Render a fort.46 overview: header, species, per-field statistics.

    Same layout as the fort.44 summary with the triangle-mesh
    dimension (``ntri``) in place of the grid dimensions; the header has
    no ``nfla`` entry because fort.46's second line never gains one
    (eirmod_extrab25.F90:565).
    """
    h = ft.header
    out = [f"fort.46: {path}" if path else "fort.46"]
    out.append(f"{'mesh':<{_LABEL_W}}ntri={h.ntri}")
    version = str(h.version)
    if h.git_hash:
        version += f" (git {h.git_hash})"
    out.append(f"{'version':<{_LABEL_W}}{version}")
    out.append(f"{'species':<{_LABEL_W}}natm={h.natm} nmol={h.nmol} nion={h.nion}")
    out.extend(_species_label_lines(h))
    out.append(f"{'fields':<{_LABEL_W}}{len(ft.fields)}")
    out.append("")
    out.extend(_field_table(ft.fields))
    return "\n".join(out) + "\n"


#: dtype kinds whose values admit min/max statistics (b/u/i/f/c; NetCDF-3
#: char arrays — kind 'S' — are text and get no statistics).
_NUMERIC_KINDS = "buifc"


def _dims_cell(variable) -> str:
    """Render a variable's dimensions compactly, e.g. ``(time,natm,nybl)``.

    No spaces inside the parens so summary rows stay token-splittable
    (NetCDF variable names cannot contain spaces, unlike fort.44/46 keys).
    """
    return "(" + ",".join(variable.dims) + ")"


def _minmax_cells(variable) -> str:
    """min/max cells for one variable; ``-`` each for text or empty arrays."""
    if variable.data.dtype.kind not in _NUMERIC_KINDS or variable.data.size == 0:
        return f"{'-':>15}  {'-':>15}"
    return f"{variable.data.min():>15.6e}  {variable.data.max():>15.6e}"


def _variable_table(ncf: NcFile) -> list[str]:
    """Per-variable table: name, dims, dtype, min/max when numeric.

    The name column is the handle ``dump --var`` accepts (the file
    order preserved).
    """
    variables = list(ncf.variables.values())
    name_w = max([len(v.name) for v in variables] + [len("name")])
    dims_w = max([len(_dims_cell(v)) for v in variables] + [len("dims")])
    dtype_w = max([len(str(v.dtype)) for v in variables] + [len("dtype")])
    lines = [
        f"{'name':<{name_w}}  {'dims':<{dims_w}}  {'dtype':<{dtype_w}}  "
        f"{'min':>15}  {'max':>15}"
    ]
    for v in variables:
        lines.append(
            f"{v.name:<{name_w}}  {_dims_cell(v):<{dims_w}}  "
            f"{str(v.dtype):<{dtype_w}}  {_minmax_cells(v)}"
        )
    return lines


def format_nc_summary(ncf: NcFile, path: str | None = None) -> str:
    """Render a NetCDF overview: dimensions, then the variable table.

    The unlimited dimension prints its header numrecs as the record count
    (pupynere.py:524-525); files without one simply list fixed lengths.
    """
    label = Path(path).name if path else "netCDF"
    out = [f"{label}: {path}" if path else label]
    out.append(f"{'format':<{_LABEL_W}}NetCDF-3 classic")
    out.append(f"{'dimensions':<{_LABEL_W}}{len(ncf.dimensions)}")
    if ncf.dimensions:
        dim_w = max(len(d.name) for d in ncf.dimensions)
        for d in ncf.dimensions:
            if d.length is None:
                value = f"unlimited ({ncf.num_records} records)"
            else:
                value = str(d.length)
            out.append(f"  {d.name:<{dim_w}}  {value}")
    out.append(f"{'variables':<{_LABEL_W}}{len(ncf.variables)}")
    out.append("")
    out.extend(_variable_table(ncf))
    return "\n".join(out) + "\n"


def _state_species_lines(st: B2fstate) -> list[str]:
    """Per-species lines for the state summary — one per fluid species.

    b2fstate stores NO species labels: the numeric records
    (zamin/zamax/zn/am) are the species set, and the one derived flag the
    Fortran reader itself derives is the neutral/charged split
    (``zamin == 0``, b2ruzd.F:46).  The run's SOLPS_FLUIDS names are not
    part of the file and are not guessed at.
    """
    return [
        f"  #{sp.index}  zamin={sp.zamin:g} zamax={sp.zamax:g} "
        f"zn={sp.zn:g} am={sp.am:g}  "
        f"({'neutral' if sp.is_neutral else 'charged'})"
        for sp in st.species
    ]


def _state_field_table(st: B2fstate) -> list[str]:
    """Per-record statistics table over ``B2fstate.fields`` (dict).

    Same layout as the ft44/46 tables: min/max/mean per numeric record,
    ``-`` cells for unknown-name char records (kept as strings) which
    admit no statistics.
    """
    name_w = max([len(k) for k in st.fields] + [len("name")])
    lines = [
        f"{'name':<{name_w}}  {'size':>6}  {'min':>15}  {'max':>15}  {'mean':>15}"
    ]
    for name, value in st.fields.items():
        if isinstance(value, np.ndarray):
            size, cells = value.size, _stat_cells(value)
        else:
            size, cells = len(value), [f"{'-':>15}"] * 3
        lines.append(f"{name:<{name_w}}  {size:>6}  " + "  ".join(cells))
    return lines


def format_state_summary(st: B2fstate, path: str | None = None) -> str:
    """Render a b2fstate/b2fstati overview: header, species, per-record
    statistics.

    The grid line shows the INTERIOR dims (``nx,ny`` record) and the
    guard-cell box every gridded record is stored over (92x38 on
    ITER_2275 — the NetCDF convention, not fort.44's 90x36; documented in
    the format dictionary, never forced equal).
    """
    label = Path(path).name if path else "b2fstate"
    out = [f"{label}: {path}" if path else label]
    gx, gy = st.grid_shape
    out.append(
        f"{'grid':<{_LABEL_W}}nx={st.nx} ny={st.ny} (interior) -> "
        f"{gx}x{gy} guard cells"
    )
    version = st.version
    if st.git_hash:
        version += f" (git {st.git_hash})"
    out.append(f"{'version':<{_LABEL_W}}{version}")
    if st.label:
        out.append(f"{'label':<{_LABEL_W}}{st.label}")
    out.append(f"{'species':<{_LABEL_W}}ns={st.ns}")
    out.extend(_state_species_lines(st))
    if st.time is not None:
        out.append(f"{'time':<{_LABEL_W}}{st.time:.6e} s")
    out.append(f"{'fields':<{_LABEL_W}}{len(st.fields)}")
    out.append("")
    out.extend(_state_field_table(st))
    return "\n".join(out) + "\n"


def _coordinate_check(gmtry: B2fgmtry) -> tuple[bool, str]:
    """Verify the geometry file's coordinate records against its own grid.

    b2fstate carries no coordinates of its own (record map — the
    54 records are header + state/flux data only), so the "coordinates"
    half of the check is that b2fgmtry provides usable ones:
    ``crx``/``cry`` present, 4 corners per cell over the guard box
    (read_b2fgmtry.m:46-47 dims [nx+2,ny+2,4]), all finite.
    """
    shape = (*gmtry.grid_shape, 4)
    for name in ("crx", "cry"):
        value = gmtry.fields.get(name)
        if not isinstance(value, np.ndarray):
            return False, f"no {name!r} coordinate record in b2fgmtry"
        if value.shape != shape:
            want = f"({shape[0]},{shape[1]},{shape[2]})"
            return (
                False,
                f"{name} shape {value.shape} != {want} (4 corners per cell, "
                f"read_b2fgmtry.m:46-47)",
            )
        if not np.isfinite(value).all():
            bad = int(np.count_nonzero(~np.isfinite(value)))
            return False, f"{name} has {bad} non-finite values"
    return True, f"crx,cry shaped ({shape[0]},{shape[1]},{shape[2]}), all finite"


def check_grid(
    st: B2fstate, gmtry: B2fgmtry, path: str | None = None
) -> tuple[list[str], bool]:
    """Cross-file consistency of a b2fstate against a b2fgmtry.

    Three sub-checks, each reported with its own PASS/FAIL: the interior
    ``nx,ny`` records agree, the derived guard-cell boxes agree (both
    files store gridded records over (nx+2)x(ny+2) — read_b2fstate.m:39-41,
    read_b2fgmtry.m:33), and the geometry file carries finite 4-corner
    coordinates for that box.  Returns the report lines and the overall
    verdict.  A FAIL is a *result* (exit 1), not a usage error (exit 2).
    """
    checks: list[str] = []
    ok = True

    def add(name: str, passed: bool, detail: str) -> None:
        nonlocal ok
        ok = ok and passed
        checks.append(f"  {name:<12}{'PASS' if passed else 'FAIL':<6}{detail}")

    dims_match = (st.nx, st.ny) == (gmtry.nx, gmtry.ny)
    add(
        "dims",
        dims_match,
        f"nx,ny: {st.nx},{st.ny} {'=' if dims_match else '!='} "
        f"{gmtry.nx},{gmtry.ny}",
    )
    box_match = st.grid_shape == gmtry.grid_shape
    sgx, sgy = st.grid_shape
    ggx, ggy = gmtry.grid_shape
    add(
        "guard box",
        box_match,
        f"{sgx}x{sgy} {'=' if box_match else '!='} {ggx}x{ggy}",
    )
    coord_ok, coord_detail = _coordinate_check(gmtry)
    add("coordinates", coord_ok, coord_detail)

    where = f"  (b2fgmtry: {path})" if path else ""
    lines = [f"{'grid check':<{_LABEL_W}}{'PASS' if ok else 'FAIL'}{where}", *checks]
    return lines, ok


def _run_state_summary(
    parser: argparse.ArgumentParser, st: B2fstate, args
) -> int:
    """Execute ``state summary`` against an already-parsed file.

    The summary prints first so the overview stays available even when
    the optional grid check fails; a failed check exits 1 (a result,
    distinct from the exit-2 file/usage errors).
    """
    print(format_state_summary(st, path=args.file), end="")
    if not args.check_grid:
        return 0
    try:
        gmtry = read_b2fgmtry(args.check_grid)
    except OSError as exc:
        parser.exit(
            2, f"solps-reader: cannot read {args.check_grid}: {exc.strerror or exc}\n"
        )
    except B2fgmtryFormatError as exc:
        parser.exit(2, f"solps-reader: {args.check_grid}: {exc}\n")
    lines, ok = check_grid(st, gmtry, args.check_grid)
    print("\n".join(lines))
    return 0 if ok else 1


#: Elementary charge in joules (exact SI defining constant).  b2fstate
#: stores ``te``/``ti`` in joules (README "Grid conventions"; no reader
#: documents otherwise), so the diff catalog converts them to eV.
_J_PER_EV = 1.602176634e-19

#: Convergence classification thresholds — the single definition shared
#: by the CLI diff face and the run-convergence MCP tool (which imports
#: :func:`_classify_trace`, so the two never disagree on the same file):
#: drift = mean(last k) - mean(first k) over k = max(3, 10% of
#: records), normalized by |mean(all)|; < 1e-3 plateaued, < 1e-2
#: near-plateau, else still evolving (zero range = constant).
_TAIL_FRACTION = 0.1
_PLATEAU_DRIFT = 1e-3
_NEAR_DRIFT = 1e-2


def _trace_drift(values: np.ndarray, tail_fraction: float = _TAIL_FRACTION) -> float:
    """Relative tail-vs-head mean shift of a 1-D trace: drift = mean(last k)
    - mean(first k) over k = max(3, tail_fraction * length), normalized by
    |mean(all)|; ``inf`` for an all-zero-mean trace.  Shared by the CLI and
    the run-convergence MCP tool (which passes its own tail fraction)."""
    values = np.asarray(values, dtype=float).ravel()
    k = max(3, int(values.size * tail_fraction))
    drift = float(values[-k:].mean() - values[:k].mean())
    m = abs(float(values.mean()))
    return abs(drift) / m if m else float("inf")


def _classify_trace(values: np.ndarray, tail_fraction: float = _TAIL_FRACTION) -> str:
    """Classify one 1-D monitor trace by its tail-vs-head mean shift
    (see the constant block above — the single definition shared with
    the run-convergence MCP tool, so the two faces never disagree).
    A trace carrying non-finite values classifies as ``non-finite``:
    the drift statistic is meaningless there, and silence would read
    as a verdict."""
    values = np.asarray(values, dtype=float).ravel()
    if values.size and not np.isfinite(values).all():
        return "non-finite"
    if float(values.max() - values.min()) == 0.0:
        return "constant"
    rel = _trace_drift(values, tail_fraction)
    if rel < _PLATEAU_DRIFT:
        return "plateaued"
    if rel < _NEAR_DRIFT:
        return "near-plateau"
    return "evolving"


def _convergence_lines(ncf: NcFile, tag: str) -> list[str]:
    """Report lines for one run's b2time.nc, tagged A or B.

    Every numeric 1-D record variable is classified (the same candidates
    ``nc plot`` draws); strictly-monotonic time bases (``timesa``) report
    honestly as evolving — a physicist reads the name and understands.
    """
    names = [
        n
        for n in ncf.time_traces()
        if ncf.variable(n).data.dtype.kind in _NUMERIC_KINDS
        and ncf.variable(n).data.size > 0
    ]
    if not names:
        return [f"{'convergence':<{_LABEL_W}}{tag}: no numeric 1-D traces"]
    classes = {n: _classify_trace(np.asarray(ncf.variable(n).data)) for n in names}
    counts = {c: sum(1 for v in classes.values() if v == c) for c in
              ("plateaued", "near-plateau", "evolving", "constant", "non-finite")}
    lead = (
        f"{tag}: {counts['plateaued']} plateaued, {counts['near-plateau']} "
        f"near-plateau, {counts['evolving']} evolving"
        + (f", {counts['non-finite']} non-finite" if counts["non-finite"] else "")
        + f" (tail {int(_TAIL_FRACTION * 100)}% of {ncf.num_records} records; "
        f"{_PLATEAU_DRIFT:g}/{_NEAR_DRIFT:g} thresholds)"
    )
    lines = [f"{'convergence':<{_LABEL_W}}{lead}"]
    flagged = {
        c: [n for n, v in classes.items() if v == c]
        for c in ("evolving", "near-plateau", "constant", "non-finite")
        if any(v == c for v in classes.values())
    }
    for klass, flagged_names in flagged.items():
        lines.append(f"{'':<{_LABEL_W}}{tag}: {klass}: " + ", ".join(flagged_names))
    return lines


#: The static comparison catalog: (key, unit), . The core 2-D
#: state records a divertor comparison looks at first — temperatures,
#: electron density, potential — plus the per-species ``na`` entries
#: appended in species order by ``_run_state_diff``.  Interior cells
#: only (the guard ring is solver bookkeeping, not physics); ``te``/
#: ``ti`` are converted joules -> eV, ``ne``/``na``/``po`` are plotted
#: as stored (no reader documents their units).
_DIFF_CATALOG: tuple[tuple[str, str], ...] = (
    ("te", "eV"),
    ("ti", "eV"),
    ("ne", ""),
    ("po", ""),
)


def _catalog_slices(st: B2fstate) -> dict[str, np.ndarray]:
    """Catalog key -> interior-cell array for one state.

    Grid records slice to ``[2:nx+2, 2:ny+2]`` (the guard-cell offset,
    read_b2fstate.m:39-41); the per-species ``na`` additionally picks
    species ``k`` and gains a ``#k (neutral|charged)`` key suffix.
    """
    nx, ny = st.nx, st.ny
    plane = (slice(2, nx + 2), slice(2, ny + 2))
    ev = 1.0 / _J_PER_EV
    out: dict[str, np.ndarray] = {}
    for key in ("te", "ti"):
        out[key] = np.asarray(st[key], dtype=float)[plane] * ev
    for key in ("ne", "po"):
        out[key] = np.asarray(st[key], dtype=float)[plane]
    na = np.asarray(st["na"], dtype=float)
    for k, sp in enumerate(st.species):
        out[f"na_{k}"] = na[plane + (k,)]
    return out


def _diff_precheck(
    parser: argparse.ArgumentParser, st_a: B2fstate, st_b: B2fstate, args
) -> list[str]:
    """Refuse-on-mismatch identity checks; return the provenance lines.

    Two states are comparable only when they describe the same grid
    (guard box, i.e. the same interior nx,ny) and the same species set
    (the four numeric records — b2fstate's only species identity,
    ). Regridding is a non-goal, so a mismatch is a usage
    error (exit 2), not a result.  Version or run-label differences are
    provenance notes: the diff proceeds (records are matched by name).
    """
    if st_a.grid_shape != st_b.grid_shape:
        parser.exit(
            2,
            f"solps-reader: state diff: guard boxes differ: "
            f"A {st_a.grid_shape[0]}x{st_a.grid_shape[1]} "
            f"(nx={st_a.nx},ny={st_a.ny}) vs "
            f"B {st_b.grid_shape[0]}x{st_b.grid_shape[1]} "
            f"(nx={st_b.nx},ny={st_b.ny}); cross-grid regridding is a "
            f"non-goal; compare runs on the same grid\n",
        )
    sig_a = [(sp.zamin, sp.zamax, sp.zn, sp.am) for sp in st_a.species]
    sig_b = [(sp.zamin, sp.zamax, sp.zn, sp.am) for sp in st_b.species]
    if sig_a != sig_b:
        rows = []
        for i in range(max(len(sig_a), len(sig_b))):
            a = sig_a[i] if i < len(sig_a) else None
            b = sig_b[i] if i < len(sig_b) else None
            rows.append(
                f"  #{i}: A zamin={a[0]:g} zamax={a[1]:g} zn={a[2]:g} "
                f"am={a[3]:g}" if a else f"  #{i}: A absent"
            )
            rows[-1] += (
                f"  vs  B zamin={b[0]:g} zamax={b[1]:g} zn={b[2]:g} "
                f"am={b[3]:g}" if b else "  vs  B absent"
            )
        parser.exit(
            2,
            "solps-reader: state diff: species sets differ; the files describe "
            "different plasmas:\n" + "\n".join(rows) + "\n",
        )
    lines = [
        f"{'grid':<{_LABEL_W}}{st_a.grid_shape[0]}x{st_a.grid_shape[1]} guard "
        f"cells (nx={st_a.nx} ny={st_a.ny} interior): MATCH",
        f"{'species':<{_LABEL_W}}ns={st_a.ns}: MATCH",
    ]
    lines.extend(_state_species_lines(st_a))
    version_line = (
        f"{'version':<{_LABEL_W}}A={st_a.version}"
        + (f" (git {st_a.git_hash})" if st_a.git_hash else "")
        + f"  B={st_b.version}"
        + (f" (git {st_b.git_hash})" if st_b.git_hash else "")
    )
    if (st_a.version, st_a.git_hash) != (st_b.version, st_b.git_hash):
        version_line += "  [NOTE: versions differ; records matched by name]"
    lines.append(version_line)
    ta, tb = st_a.time, st_b.time
    time_line = f"{'time':<{_LABEL_W}}"
    if ta is not None and tb is not None:
        time_line += (
            f"A={ta:.6e} s  B={tb:.6e} s  (B-A={tb - ta:.6e} s)"
        )
    else:
        time_line += (
            f"A={'n/a' if ta is None else f'{ta:.6e} s'}  "
            f"B={'n/a' if tb is None else f'{tb:.6e} s'}"
        )
    lines.append(time_line)
    return lines


def _diff_figure(
    key: str,
    unit: str,
    data_a: np.ndarray,
    data_b: np.ndarray,
    *,
    title_a: str,
    title_b: str,
    gmtry: "B2fgmtry | None",
    nx: int,
    ny: int,
    annotation: str,
):
    """Build (do not save) one catalog field's A | B | B-A figure.

    A and B share one color scale so the eye compares like with like; the
    difference panel uses a diverging colormap on symmetric limits so
    zero difference reads as neutral. R-Z mode reuses the 
    per-cell-quad approach: interior cells drawn from their OWN four
    corners in perimeter order 0,1,3,2 (the stored order crosses the
    quad), guard ring skipped, equal aspect.  Index mode mirrors
    ``ft44 plot`` (cells on integer coordinates, flat shading).
    """
    import matplotlib

    matplotlib.use("Agg")
    from matplotlib import pyplot as plt

    label = f"{key} ({unit})" if unit else key
    diff = data_b - data_a
    vmin = float(min(data_a.min(), data_b.min()))
    vmax = float(max(data_a.max(), data_b.max()))
    if vmin == vmax:  # constant on both sides: give the scale a floor
        vmin, vmax = vmin - 1.0, vmax + 1.0
    dlim = max(float(np.abs(diff).max()), 1e-30)

    fig, axes = plt.subplots(
        1, 3, figsize=(13.5, 5.4), layout="constrained"
    )
    from matplotlib.colors import Normalize

    panels = ((axes[0], data_a, title_a, vmin, vmax, None, label),
              (axes[1], data_b, title_b, vmin, vmax, None, label),
              (axes[2], diff, "B - A", -dlim, dlim, "RdBu_r", label))
    for ax, data, title, lo, hi, cmap, _ in panels:
        if gmtry is None:
            mesh = ax.pcolormesh(
                np.arange(nx + 1) - 0.5,
                np.arange(ny + 1) - 0.5,
                data.T,  # C[iy, ix] = data[ix, iy]
                shading="flat",
                vmin=lo,
                vmax=hi,
                cmap=cmap,
            )
            ax.set_xlabel("ix")
            ax.set_ylabel("iy")
        else:
            from matplotlib.collections import PolyCollection

            crx = np.asarray(gmtry.fields["crx"], dtype=float)[
                2:nx + 2, 2:ny + 2
            ]
            cry = np.asarray(gmtry.fields["cry"], dtype=float)[
                2:nx + 2, 2:ny + 2
            ]
            # Perimeter order 0,1,3,2 — the stored k-order crosses the
            # quad (verified on real geometry).
            polys = np.stack([crx, cry], axis=-1)[
                ..., [0, 1, 3, 2], :
            ].reshape(-1, 4, 2)
            mesh = PolyCollection(
                polys,
                array=data.ravel(),
                edgecolors="none",
                norm=Normalize(vmin=lo, vmax=hi),
                cmap=cmap,
            )
            ax.add_collection(mesh)
            ax.autoscale_view()
            ax.margins(0.02)
            ax.set_xlabel("R (m)")
            ax.set_ylabel("Z (m)")
            ax.set_aspect("equal")
        ax.set_title(title, fontsize=10)
        fig.colorbar(mesh, ax=ax, label=label if cmap is None else "B - A")
    suptitle = f"state diff: {label}   A: {title_a}   B: {title_b}"
    if annotation:
        suptitle += "\n" + annotation
    fig.suptitle(suptitle, fontsize=10)
    if gmtry is not None:
        fig.set_constrained_layout_pads(h_pad=0.08)
    return fig


def _stat_row(key: str, unit: str, a: np.ndarray, b: np.ndarray) -> str:
    """One summary-table row: ranges of A and B, max |B-A|, max relative.

    The relative cell is taken only over cells with |A| >= 1% of max|A|
    (a global relative max would be dominated by near-zero filler);
    ``-`` when nothing qualifies (constant-zero A).  Non-finite values
    (NaN guard cells in unconverged states) are excluded from every
    statistic and counted in a trailing note — ``nan`` must never print
    as if it were a number."""
    finite = np.isfinite(a) & np.isfinite(b)
    n_bad = int((~finite).sum())
    a_f, b_f = a[finite], b[finite]
    if a_f.size == 0 or b_f.size == 0:
        cells = [f"{'non-finite':>15}"] * 5
        rel = f"{'-':>10}"
    else:
        diff = b_f - a_f
        mask = np.abs(a_f) >= 0.01 * float(np.abs(a_f).max())
        rel = (
            f"{float((np.abs(diff)[mask] / np.abs(a_f)[mask]).max()):>10.3e}"
            if mask.any()
            else f"{'-':>10}"
        )
        cells = [
            f"{a_f.min():>15.6e}", f"{a_f.max():>15.6e}",
            f"{b_f.min():>15.6e}", f"{b_f.max():>15.6e}",
            f"{float(np.abs(diff).max()):>15.6e}",
        ]
    row = f"{key:<10}{unit:>5}  " + "  ".join(cells) + f"  {rel}"
    if n_bad:
        row += f"  [{n_bad} non-finite cells]"
    return row


def _run_state_diff(parser: argparse.ArgumentParser, args) -> int:
    """Execute ``state diff``: identity checks, deck, report."""
    states = []
    for which in ("file_a", "file_b"):
        path = getattr(args, which)
        try:
            states.append(read_b2fstate(path))
        except OSError as exc:
            parser.exit(2, f"solps-reader: cannot read {path}: {exc.strerror or exc}\n")
        except B2fstateFormatError as exc:
            parser.exit(2, f"solps-reader: {path}: {exc}\n")
    st_a, st_b = states

    report = [f"state diff: A {args.file_a} -> B {args.file_b}"]
    report.extend(_diff_precheck(parser, st_a, st_b, args))

    gmtry = None
    if args.geometry:
        try:
            gmtry = read_b2fgmtry(args.geometry)
        except OSError as exc:
            parser.exit(
                2, f"solps-reader: cannot read {args.geometry}: {exc.strerror or exc}\n"
            )
        except B2fgmtryFormatError as exc:
            parser.exit(2, f"solps-reader: {args.geometry}: {exc}\n")
        if gmtry.grid_shape != st_a.grid_shape:
            parser.exit(
                2,
                f"solps-reader: {args.geometry}: grid {gmtry.grid_shape[0]}x"
                f"{gmtry.grid_shape[1]} does not match the states' guard box "
                f"{st_a.grid_shape[0]}x{st_a.grid_shape[1]}\n",
            )
    report.append(
        f"{'geometry':<{_LABEL_W}}"
        + (args.geometry if gmtry is not None else "(ix, iy) index grid")
    )

    convergence = []
    leads = {}
    for opt, tag in (("--b2time-a", "A"), ("--b2time-b", "B")):
        path = getattr(args, opt.replace("--", "").replace("-", "_"))
        if not path:
            lines = [
                f"{'convergence':<{_LABEL_W}}{tag}: n/a ({opt} not given)"
            ]
        else:
            try:
                ncf = load_nc(path)
            except NcFormatError as exc:
                parser.exit(2, f"solps-reader: {exc}\n")
            lines = _convergence_lines(ncf, tag)
        convergence.extend(lines)
        leads[tag] = lines[0][_LABEL_W:]  # text past the label column
    report.extend(convergence)

    slices_a = _catalog_slices(st_a)
    slices_b = _catalog_slices(st_b)
    catalog = list(_DIFF_CATALOG)
    # Per-species na entries join the static catalog in species order,
    # slotted after ne so the deck reads te, ti, ne, na_0..., po.
    for k in range(st_a.ns):
        catalog.insert(3 + k, (f"na_{k}", ""))

    annotation = "   ".join(leads[t] for t in ("A", "B"))
    out_dir = Path(args.output)
    try:
        out_dir.mkdir(parents=True, exist_ok=True)
    except OSError as exc:
        parser.exit(
            2, f"solps-reader: cannot create {out_dir}: {exc.strerror or exc}\n"
        )

    report.append(f"{'fields':<{_LABEL_W}}" + " ".join(k for k, _ in catalog))
    report.append("")
    report.append(
        f"{'name':<10}{'unit':>5}  {'min A':>15}  {'max A':>15}  "
        f"{'min B':>15}  {'max B':>15}  {'max|B-A|':>15}  {'max rel':>10}"
        f"   (interior cells; rel over |A| >= 1% max|A|)"
    )
    for key, unit in catalog:
        data_a, data_b = slices_a[key], slices_b[key]
        report.append(_stat_row(key, unit, data_a, data_b))
        fig = _diff_figure(
            key,
            unit,
            data_a,
            data_b,
            title_a=Path(args.file_a).name,
            title_b=Path(args.file_b).name,
            gmtry=gmtry,
            nx=st_a.nx,
            ny=st_a.ny,
            annotation=annotation,
        )
        try:
            fig.savefig(out_dir / f"{key}.png", dpi=_PLOT_DPI)
        except OSError as exc:
            parser.exit(
                2,
                f"solps-reader: cannot write {out_dir / key}.png: "
                f"{exc.strerror or exc}\n",
            )
        finally:
            from matplotlib import pyplot as plt

            plt.close(fig)

    text = "\n".join(report) + "\n"
    summary_path = out_dir / "diff_summary.txt"
    try:
        summary_path.write_text(text, encoding="utf-8")
    except OSError as exc:
        parser.exit(
            2, f"solps-reader: cannot write {summary_path}: {exc.strerror or exc}\n"
        )
    print(text, end="")
    print(
        f"wrote {len(catalog)} figures + diff_summary.txt -> {out_dir}"
    )
    return 0


def _field_candidates(ft: Ft44 | Ft46, wanted: str) -> list[str]:
    """Keys that a mistyped ``--field`` value most plausibly meant.

    fort.44 names carry Fortran padding and stratum indices
    (``wldnek(  1)``), so both the exact key and a whitespace-insensitive
    comparison are tried before falling back to substring containment —
    a user asking for ``wldnek`` is shown every per-stratum block.
    """
    keys = ft.keys()
    squashed = wanted.replace(" ", "")
    exact = [k for k in keys if k.replace(" ", "") == squashed]
    if exact:
        return exact
    return [k for k in keys if squashed in k.replace(" ", "")]


def _resolve_field(
    parser: argparse.ArgumentParser, ft: Ft44 | Ft46, args, family: str
) -> Ft44Field | Ft46Field:
    """Look up ``args.field``; exit 2 listing candidates on a miss."""
    try:
        return ft.field(args.field)
    except KeyError:
        matches = _field_candidates(ft, args.field)
        if matches:
            hint = "did you mean: " + ", ".join(matches)
        else:
            hint = (
                f"no similar field names; "
                f"`solps_reader {family} summary {args.file}` lists all "
                f"{len(ft.fields)} keys"
            )
        parser.exit(2, f"solps-reader: {args.file}: no field {args.field!r}; {hint}\n")


def _write_export(field: Ft44Field | Ft46Field, args, label: str) -> str:
    """Write ``field`` to ``args.output``; return the format used.

    ``label`` is the file family for the csv header (``fort.44`` /
    ``fort.46``).  The output is opened explicitly so numpy cannot
    silently append an extension (``np.savez`` appends ``.npz`` to any
    other filename) — the file must land at exactly the path the user
    named.
    """
    fmt = args.format or ("csv" if args.output.lower().endswith(".csv") else "npz")
    with open(args.output, "wb") as fh:
        if fmt == "npz":
            np.savez(fh, **{field.key: field.data})
        else:
            np.savetxt(
                fh,
                field.data,
                fmt="%.8e",
                header=f"{label} field {field.name} shape={field.data.shape} "
                f"size={field.size} fortran-order",
            )
    return fmt


def _run_export(
    parser: argparse.ArgumentParser,
    ft: Ft44 | Ft46,
    args,
    family: str,
    label: str,
) -> int:
    """Execute ``<family> export`` against an already-parsed file."""
    field = _resolve_field(parser, ft, args, family)
    fmt = args.format or ("csv" if args.output.lower().endswith(".csv") else "npz")
    if fmt == "csv" and field.data.ndim > 2:
        # csv has no honest layout for species-resolved (nx, ny, k) data —
        # the same reasoning that keeps ``nc dump`` npz-only.
        parser.exit(
            2,
            f"solps-reader: {args.output}: csv is 1-D/2-D only; field "
            f"{field.key!r} has shape {field.data.shape} (species-resolved) "
            f"; write npz instead (--format npz)\n",
        )
    try:
        fmt = _write_export(field, args, label)
    except OSError as exc:
        parser.exit(2, f"solps-reader: cannot write {args.output}: {exc.strerror or exc}\n")
    print(f"wrote {field.key} shape={field.data.shape} as {fmt} -> {args.output}")
    return 0


def _run_nc_dump(parser: argparse.ArgumentParser, ncf: NcFile, args) -> int:
    """Execute ``nc dump`` against an already-parsed file.

    Exports one variable as npz under its own name.  Unlike the ft44/46
    ``export``, dump is npz-only: nc variables are routinely 3-D record
    arrays (``tab3dl(time,natm,nybl)``) for which csv has no honest
    layout.  The output is opened explicitly so numpy cannot silently
    append an extension (``np.savez`` appends ``.npz`` to other names).
    """
    try:
        variable = ncf.variable(args.var)
    except KeyError:
        # NetCDF names are C identifiers — plain substring containment
        # suffices (no Fortran padding like the fort.44/46 keys).
        matches = [n for n in ncf.keys() if args.var in n]
        if matches:
            hint = "did you mean: " + ", ".join(matches)
        else:
            hint = (
                f"no similar variable names; "
                f"`solps_reader nc summary {args.file}` lists all "
                f"{len(ncf.variables)} names"
            )
        parser.exit(2, f"solps-reader: {args.file}: no variable {args.var!r}; {hint}\n")
    try:
        with open(args.output, "wb") as fh:
            np.savez(fh, **{variable.name: variable.data})
    except OSError as exc:
        parser.exit(2, f"solps-reader: cannot write {args.output}: {exc.strerror or exc}\n")
    print(
        f"wrote {variable.name} dims={variable.dims} "
        f"shape={variable.shape} -> {args.output}"
    )
    return 0


def _nc_traces(ncf: NcFile) -> list[str]:
    """Names of the 1-D record variables ``nc plot`` renders, file order.

    :meth:`NcFile.time_traces` already narrows to numeric-shaped
    candidates dimensioned solely along the record dimension; this drops
    the two kinds with nothing to draw — text (NC_CHAR, kind 'S') and
    empty arrays (numrecs == 0).
    """
    return [
        n
        for n in ncf.time_traces()
        if ncf.variable(n).data.dtype.kind in _NUMERIC_KINDS
        and ncf.variable(n).data.size > 0
    ]


def _nc_plot_figure(ncf: NcFile, traces: list[str], path: str):
    """Build the convergence-trace figure for ``nc plot`` (not saved).

    One stacked subplot per trace: the b2time.nc traces span ~25 decades
    (timesa 5e-7 .. tmti 1.4e24), so a shared y-axis cannot serve them —
    unlike the reference script, which overlays user-chosen same-family
    variables in one axes with a legend (scripts/2dt.py:34-39).  Each
    subplot's y label carries the variable name and, when the file
    provides it, its ``units`` attribute; a small left-aligned title
    carries ``long_name`` when present.
    """
    # Import lazily and force the Agg backend before pyplot loads: the
    # plot path must work on headless machines (technical
    # Considerations), and summary/dump stay import-cheap.
    import matplotlib

    matplotlib.use("Agg")
    from matplotlib import pyplot as plt

    record = ncf.record_dimension
    fig, axes = plt.subplots(
        len(traces),
        1,
        sharex=True,
        squeeze=False,
        figsize=(8.0, 1.9 * len(traces) + 1.3),
        layout="constrained",
    )
    for ax, name in zip(fig.axes, traces):
        variable = ncf.variable(name)
        data = variable.data
        ax.plot(np.arange(data.shape[0]), data)
        if variable.units:
            ax.set_ylabel(f"{name} ({variable.units})")
        else:
            ax.set_ylabel(name)
        if variable.long_name:
            ax.set_title(variable.long_name, fontsize=9, loc="left")
    axes[-1, 0].set_xlabel(f"{record} index")
    fig.suptitle(
        f"{Path(path).name}: {len(traces)} 1-D variables vs {record} index"
    )
    return fig


def _run_nc_plot(parser: argparse.ArgumentParser, ncf: NcFile, args) -> int:
    """Execute ``nc plot`` against an already-parsed file."""
    traces = _nc_traces(ncf)
    if ncf.record_dimension is None or not traces:
        parser.exit(
            2,
            f"solps-reader: {args.file}: no numeric 1-D variables along an "
            f"unlimited dimension to plot; `solps_reader nc summary {args.file}` "
            f"lists all {len(ncf.variables)} variables\n",
        )
    fig = _nc_plot_figure(ncf, traces, args.file)
    try:
        fig.savefig(args.output, dpi=_PLOT_DPI)
    except OSError as exc:
        parser.exit(2, f"solps-reader: cannot write {args.output}: {exc.strerror or exc}\n")
    finally:
        from matplotlib import pyplot as plt

        plt.close(fig)
    noun = "trace" if len(traces) == 1 else "traces"
    print(
        f"wrote {len(traces)} {noun} ({ncf.num_records} records) "
        f"vs {ncf.record_dimension} -> {args.output}"
    )
    return 0


#: Resolution of rendered index-grid plots (dpi); governs PNG pixel size.
_PLOT_DPI = 150


def _ft44_plot_figure(ft: Ft44, field, gmtry=None):
    """Build (do not save) the ``ft44 plot`` figure.

    ``gmtry=None`` renders the (ix, iy) index grid: cell (ix, iy)
    centered on integer coordinates, flat shading over -0.5..nx-0.5 /
    -0.5..ny-0.5 edges.

    With a :class:`~solps_reader.gmtry.B2fgmtry`, the field is painted on
    physical R-Z coordinates as one quadrilateral per cell, drawn directly
    from the four stored ``crx``/``cry`` corners (guard box, shape
    (nx+2, ny+2, 4) — ). Per-cell polygons, not an inferred
    edge grid: around the X-point R is not monotonic along a flux ring
    (physically correct for a tokamak edge grid), so matplotlib's
    center-based ``shading="nearest"`` misguesses cell edges there (it
    warns about exactly this).  Corner sharing holds in the bulk
    (corner 1 of cell (i,j) == corner 0 of (i+1,j); corner 2 == corner 0
    of (i,j+1) — verified exactly on ITER_2275) but is not guaranteed at
    seam cells, so each cell renders from its OWN corners.  Only interior
    cells are drawn; the guard ring is skipped.  Aspect is equal — R and
    Z are both metres.
    """
    import matplotlib

    matplotlib.use("Agg")
    from matplotlib import pyplot as plt

    data = field.data
    nx, ny = ft.header.nx, ft.header.ny
    label = field.name.strip()

    # layout="constrained" + suptitle: set_aspect("equal") shrinks the AXES
    # BOX itself (adjustable="box"), so any ax title wider than the narrow
    # box overflows it into the colorbar and its offset text; the suptitle
    # spans the figure instead (the state-diff figure's own precedent).
    fig, ax = plt.subplots(layout="constrained")
    if gmtry is None:
        mesh = ax.pcolormesh(
            np.arange(nx + 1) - 0.5,
            np.arange(ny + 1) - 0.5,
            data.T,  # C[iy, ix] = data[ix, iy]
            shading="flat",
        )
        ax.set_xlabel("ix")
        ax.set_ylabel("iy")
    else:
        from matplotlib.collections import PolyCollection

        crx = np.asarray(gmtry.fields["crx"], dtype=float)[2:nx + 2, 2:ny + 2]
        cry = np.asarray(gmtry.fields["cry"], dtype=float)[2:nx + 2, 2:ny + 2]
        # Corner order in the file is NOT a polygon perimeter: k = (radial
        # inner, poloidal i), (inner, i+1), (outer, i), (outer, i+1) — pairs
        # k0~k2 and k1~k3 nearly coincide (verified on ITER_2275; k2 == the
        # radially-outer neighbour's k0 exactly).  Drawing 0,1,2,3 crosses
        # the quad (bowtie); the perimeter is 0,1,3,2.
        polys = np.stack([crx, cry], axis=-1)[..., [0, 1, 3, 2], :].reshape(-1, 4, 2)
        mesh = PolyCollection(polys, array=data.ravel(), edgecolors="none")
        ax.add_collection(mesh)
        ax.autoscale_view()  # PolyCollection does not autoscale axes
        ax.margins(0.02)
        ax.set_xlabel("R (m)")
        ax.set_ylabel("Z (m)")
        ax.set_aspect("equal")
    fig.colorbar(mesh, ax=ax, label=label)
    fig.suptitle(
        f"fort.44 field {label}  (nx={nx}, ny={ny}, R-Z)"
        if gmtry is not None else f"fort.44 field {label}  (nx={nx}, ny={ny})"
    )
    return fig


def _run_ft44_plot(parser: argparse.ArgumentParser, ft: Ft44, args) -> int:
    """Execute ``ft44 plot`` against an already-parsed file."""
    field = _resolve_field(parser, ft, args, "ft44")
    data = field.data
    if data.shape != (ft.header.nx, ft.header.ny):
        parser.exit(
            2,
            f"solps-reader: {args.file}: field {field.key!r} has shape {data.shape}; "
            f"only ({ft.header.nx}, {ft.header.ny}) grid fields can be plotted; "
            f"anything else (species-resolved stacks, wall/stratum tallies) "
            f"has no single-map geometry; export it instead\n",
        )

    gmtry = None
    if args.geometry:
        try:
            gmtry = read_b2fgmtry(args.geometry)
        except OSError as exc:
            parser.exit(
                2, f"solps-reader: cannot read {args.geometry}: {exc.strerror or exc}\n"
            )
        except B2fgmtryFormatError as exc:
            parser.exit(2, f"solps-reader: {args.geometry}: {exc}\n")
        if gmtry.grid_shape != (ft.header.nx + 2, ft.header.ny + 2):
            parser.exit(
                2,
                f"solps-reader: {args.geometry}: grid {gmtry.grid_shape[0]}x"
                f"{gmtry.grid_shape[1]} does not match fort.44 interior "
                f"{ft.header.nx}x{ft.header.ny} (+2 guard cells expected)\n",
            )

    fig = _ft44_plot_figure(ft, field, gmtry=gmtry)
    try:
        from matplotlib import pyplot as plt

        fig.savefig(args.output, dpi=_PLOT_DPI)
    except OSError as exc:
        parser.exit(2, f"solps-reader: cannot write {args.output}: {exc.strerror or exc}\n")
    finally:
        from matplotlib import pyplot as plt

        plt.close(fig)
    mode = "R-Z geometry" if gmtry is not None else "index grid"
    print(f"wrote {field.key} pcolormesh ({data.shape[0]}x{data.shape[1]}, "
          f"{mode}) -> {args.output}")
    return 0


#: the core physics records every summary shows statistics for (P4:
#: ~190 records do not fit a summary; everything else via ``field``)
_PLASMA_CORE_FIELDS = ("na", "ne", "te", "ti", "ua", "po", "fna", "she", "shi")


def format_plasma_summary(pl: B2fplasma, path: str | None = None) -> str:
    """Render a b2fplasma/b2fplasmf overview: header, the seven block
    inventories, core-field statistics."""
    label = Path(path).name if path else "b2fplasma"
    out = [f"{label}: {path}" if path else label]
    gx, gy = pl.grid_shape
    out.append(
        f"{'grid':<{_LABEL_W}}nx={pl.nx} ny={pl.ny} (interior) -> "
        f"{gx}x{gy} guard cells (dims from {pl.dims_source})"
    )
    version = pl.version
    if pl.git_hash:
        version += f" (git {pl.git_hash})"
    out.append(f"{'version':<{_LABEL_W}}{version}")
    enc = ("binary (Fortran unformatted records)" if pl.encoding == "binary"
           else "ascii (formatted twin)")
    out.append(f"{'encoding':<{_LABEL_W}}{enc}")
    out.append(f"{'species':<{_LABEL_W}}ns={pl.ns}")
    if pl.nstra is not None:
        out.append(f"{'strata':<{_LABEL_W}}nstra={pl.nstra}")
    absent = max(pl.expected - len(pl.records), 0)
    note = f", {absent} optional absent" if absent else ""
    out.append(f"{'records':<{_LABEL_W}}{len(pl.records)} present{note}")

    if pl.species_zamin is not None and "ne" in pl and "na" in pl:
        z = np.asarray(pl.species_zamin)
        residual = float(np.abs(
            pl["ne"] - (pl["na"] * z[None, None, :]).sum(axis=2)).max())
        rel = residual / max(float(np.abs(pl["ne"]).max()), 1.0)
        verdict = "PASS" if rel < 1e-10 else "CHECK"
        out.append(
            f"{'quasineutral':<{_LABEL_W}}ne = sum z*na: max residual "
            f"{residual:.3e} (rel {rel:.1e}): {verdict}"
        )

    out += ["", "core fields (min / max / mean over all cells):"]
    for name in _PLASMA_CORE_FIELDS:
        if name not in pl:
            continue
        cells = _stat_cells(pl[name])
        shape = "x".join(str(d) for d in pl.shape_of(name))
        out.append(f"  {name:<12}{shape:>16}  {' '.join(cells)}")

    out += ["", "blocks:"]
    for block, names in pl.blocks():
        out.append(_plasma_block_line(block, names))
    return "\n".join(out) + "\n"


def _plasma_block_line(block: str, names: list[str]) -> str:
    """One block inventory row: ``name (count): members...`` wrapped at
    78 columns with the continuation indented under the members."""
    head = f"  {block} ({len(names)}): "
    rows = []
    line = ""
    for name in names:
        piece = name if not line else " " + name
        if len(head) + len(line) + len(piece) > 78:
            rows.append(head + line)
            head, line, piece = " " * (len(head)), "", name
        line += piece
    rows.append(head + line)
    return "\n".join(rows)


def _run_plasma_field(parser: argparse.ArgumentParser, pl: B2fplasma,
                      args) -> int:
    """Execute ``plasma field``: one record's shape, stats, first values."""
    try:
        arr = pl[args.name]
    except KeyError as exc:
        parser.exit(2, f"solps-reader: {args.file}: {exc}\n")
    shape = "x".join(str(d) for d in arr.shape) or "scalar"
    out = [
        f"{args.name}: shape ({shape})",
        f"  min / max / mean: {' '.join(_stat_cells(arr))}",
    ]
    flat = np.asarray(arr).ravel(order="F")
    head = ", ".join(f"{v:.6e}" for v in flat[:12])
    out.append(f"  first values (column-major): {head}"
               + (" ..." if flat.size > 12 else ""))
    print("\n".join(out))
    return 0


def _run_plasma_export(parser: argparse.ArgumentParser, pl: B2fplasma,
                       args) -> int:
    """Execute ``plasma export``: every record to one npz.

    npz-only, like ``nc dump``: species-resolved records are 3-D and
    up (csigin is 5-D), for which csv has no honest layout.
    """
    fields = pl.load_all()
    try:
        with open(args.output, "wb") as fh:
            np.savez(fh, **fields)
    except OSError as exc:
        parser.exit(
            2, f"solps-reader: cannot write {args.output}: "
            f"{exc.strerror or exc}\n")
    print(f"wrote {len(fields)} records -> {args.output}")
    return 0


def main(argv: list[str] | None = None) -> int:
    """Entry point for the ``solps_reader`` console script."""
    parser = build_parser()
    args = parser.parse_args(argv)
    if args.family is None:
        parser.print_help()
        return 0
    if args.family == "catalog":
        # the one catalog-root redirect (quota-limited home
        # filesystems), set OR cleared per invocation so no stale
        # override leaks into the next in-process caller
        catalog_sources.set_catalog_root(getattr(args, "home", None))
    if args.family == "setup":
        return _run_setup(args)
    # the remembered-group verbs edit a share file, not analysis —
    # they run ungated like setup (compare gates its own rebuild)
    if args.family == "catalog" and args.command in ("add", "remove",
                                                     "move", "list"):
        return _run_catalog_groups(args)
    if args.family == "catalog" and args.command == "compare":
        return _run_catalog_compare(args, parser)
    if args.family == "catalog" and args.command == "open":
        return _run_catalog_open(parser)
    # the floor gates every analysis command; --version and --help
    # exited inside parse_args already
    _gate_floor()
    if args.family == "catalog":
        if args.command is None:
            parser.error("catalog: a command is required "
                         "(build, add, remove, move, list, compare, "
                         "gallery, open)")
        if args.command == "gallery":
            return _run_catalog_gallery(parser, args)
        return _run_catalog_build(parser, args)
    if args.family == "ft44":
        try:
            ft = read_ft44(args.file)
        except OSError as exc:
            parser.exit(2, f"solps-reader: cannot read {args.file}: {exc.strerror or exc}\n")
        except Ft44FormatError as exc:
            parser.exit(2, f"solps-reader: {args.file}: {exc}\n")
        if args.command == "summary":
            print(format_ft44_summary(ft, path=args.file), end="")
            return 0
        if args.command == "plot":
            return _run_ft44_plot(parser, ft, args)
        return _run_export(parser, ft, args, "ft44", "fort.44")
    if args.family == "ft46":
        try:
            ft = read_ft46(args.file)
        except OSError as exc:
            parser.exit(2, f"solps-reader: cannot read {args.file}: {exc.strerror or exc}\n")
        except Ft46FormatError as exc:
            parser.exit(2, f"solps-reader: {args.file}: {exc}\n")
        if args.command == "summary":
            print(format_ft46_summary(ft, path=args.file), end="")
            return 0
        return _run_export(parser, ft, args, "ft46", "fort.46")
    if args.family == "nc":
        try:
            ncf = load_nc(args.file)
        except NcFormatError as exc:
            # load_nc wraps every open/parse failure (missing file, bad
            # magic, broken header) with the path already in the message.
            parser.exit(2, f"solps-reader: {exc}\n")
        if args.command == "summary":
            print(format_nc_summary(ncf, path=args.file), end="")
            return 0
        if args.command == "plot":
            return _run_nc_plot(parser, ncf, args)
        return _run_nc_dump(parser, ncf, args)
    if args.family == "state":
        if args.command == "diff":
            return _run_state_diff(parser, args)
        try:
            st = read_b2fstate(args.file)
        except OSError as exc:
            parser.exit(2, f"solps-reader: cannot read {args.file}: {exc.strerror or exc}\n")
        except B2fstateFormatError as exc:
            parser.exit(2, f"solps-reader: {args.file}: {exc}\n")
        return _run_state_summary(parser, st, args)
    if args.family == "plasma":
        try:
            pl = read_b2fplasma(
                args.file, b2fstate=args.b2fstate, dims=args.dims)
        except OSError as exc:
            parser.exit(2, f"solps-reader: cannot read {args.file}: {exc.strerror or exc}\n")
        except B2fplasmaFormatError as exc:
            parser.exit(2, f"solps-reader: {args.file}: {exc}\n")
        try:
            if args.command == "summary":
                print(format_plasma_summary(pl, path=args.file), end="")
                return 0
            if args.command == "field":
                return _run_plasma_field(parser, pl, args)
            return _run_plasma_export(parser, pl, args)
        finally:
            pl.close()
    raise AssertionError(f"unhandled family {args.family!r}")
