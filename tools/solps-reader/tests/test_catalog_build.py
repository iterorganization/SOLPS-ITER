"""The run catalog's one build path: the runs ladder + the build verb.

Everything is synthetic and standalone: a copied catalog tree (the
package's own builders, no run data), a one-run family whose files are
written by hand (a minimal fort.44 header, a b2time.nc through the
vendored writer, a b2mn.dat deck), and a floor-perfect checkout from
the shared factory. No network, no real repositories, no layout
assumptions.
"""

from __future__ import annotations

import importlib.util
import json
import os
import shutil
import sys
from pathlib import Path

import numpy as np
import pytest

import solps_reader
from solps_reader import floor
from solps_reader import cli

CATALOG = Path(__file__).resolve().parents[1] / "catalog"
sys.path.insert(0, str(CATALOG))
import runs_source  # noqa: E402


# ---------------------------------------------------------------- fixtures

def _catalog_copy(tmp: Path) -> Path:
    """The builders + data + fonts + figures + the committed release
    joins, WITHOUT the generated outputs — the recipe's start shape."""
    dst = tmp / "pkg" / "catalog"
    shutil.copytree(
        CATALOG, dst,
        ignore=shutil.ignore_patterns("out", "__pycache__", "*.pyc"))
    joins = dst / "out" / "deltarun_pages"
    joins.mkdir(parents=True)
    for j in sorted((CATALOG / "out" / "deltarun_pages").glob("*.json")):
        shutil.copy2(j, joins / j.name)
    return dst


def _write_b2time(path: Path) -> None:
    """A tiny valid b2time.nc through the vendored writer: one time
    base (timesa, strictly increasing) and one settled monitor."""
    from solps_reader._vendor.pupynere import NetCDFFile
    nc = NetCDFFile(str(path), "w")
    nc.createDimension("time", None)
    t = nc.createVariable("timesa", "d", ("time",))
    t[:] = np.linspace(0.0, 1.0, 8)
    m = nc.createVariable("tmne", "d", ("time",))
    m[:] = np.array([1.0] * 7 + [1.001])
    nc.close()


def _write_run(family: Path, name: str = "run1") -> Path:
    """One synthetic run: marker + the hard-required b2time.nc + a
    deck with one switch. Everything else stays honestly absent."""
    run = family / name
    run.mkdir(parents=True)
    (run / "fort.44").write_text(
        "2 3 20170328 eirenehash00000000000000000000000000000\n"
        "1 0 0\n"
        "H\n",
        encoding="ascii")
    _write_b2time(run / "b2time.nc")
    (run / "b2mn.dat").write_text(
        "* synthetic deck\n"
        "*endphy\n"
        "'b2eirene'   '.true.'\n",
        encoding="latin-1")
    return run


def _synthetic_runs(tmp: Path) -> Path:
    root = tmp / "myruns"
    _write_run(root / "SYNTH1_demo")
    return root


def _share_out(home: Path) -> Path:
    """The user build's seat: the per-user share beside the sources
    file (the placement doctrine — never the checkout)."""
    return (home / ".local" / "share" / "solps_reader" / "catalog"
            / "out")


def _scrub_built_at(tree: dict[str, bytes]) -> dict[str, bytes]:
    """Normalize the user-seat build moment out of a seat snapshot.

    The determinism rule: the 'built at' wall-clock line rides ONLY
    user-seat builds that carry user groups (no proof covers user
    bytes); the deterministic GENERATION is still pinned by blanking
    that one line before comparing two builds.
    """
    import re
    return {
        k: re.sub(rb'<p class="built-at">built at [^<]*</p>\n',
                  b"", v)
        for k, v in tree.items()}


def _floorless(monkeypatch, tmp_path: Path) -> None:
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)


# ------------------------------------------------------------- ladder units

def test_ladder_explicit_beats_everything(tmp_path: Path) -> None:
    explicit = _synthetic_runs(tmp_path)
    share = tmp_path / "nohome" / ".local" / "share" / "solps_reader" \
        / "runs" / "examples"
    share.mkdir(parents=True)
    root, rung = runs_source.resolve_examples(
        str(explicit), env={}, home=tmp_path / "nohome", cwd=tmp_path)
    assert root == explicit
    assert rung == "the path given to --runs"


def test_ladder_share_beats_checkout(
        tmp_path: Path, checkout_factory) -> None:
    share = tmp_path / "home" / ".local" / "share" / "solps_reader" \
        / "runs" / "examples"
    share.mkdir(parents=True)
    repos = checkout_factory()
    (repos / "SOLPS-ITER" / "runs" / "examples").mkdir(parents=True)
    root, rung = runs_source.resolve_examples(
        env={}, home=tmp_path / "home", cwd=repos)
    assert root == share
    assert "per-user share" in rung


def test_ladder_checkout_rung_via_floor_env(
        tmp_path: Path, checkout_factory) -> None:
    repos = checkout_factory()
    examples = repos / "SOLPS-ITER" / "runs" / "examples"
    examples.mkdir(parents=True)
    root, rung = runs_source.resolve_examples(
        env={floor.REPOS_ENV: str(repos)},
        home=tmp_path / "nohome", cwd=tmp_path)
    assert root == examples
    assert floor.REPOS_ENV in rung


def test_ladder_refusal_names_the_remedy(tmp_path: Path) -> None:
    with pytest.raises(runs_source.RunsError) as ei:
        runs_source.resolve_examples(env={}, home=tmp_path / "nohome",
                                     cwd=tmp_path)
    assert "--runs" in str(ei.value)
    assert "per-user share" in str(ei.value)


def test_ladder_rejects_a_non_directory(tmp_path: Path) -> None:
    with pytest.raises(runs_source.RunsError) as ei:
        runs_source.resolve_examples(str(tmp_path / "nope"))
    assert "not a directory" in str(ei.value)


def test_manifest_module_imports_without_run_data(
        monkeypatch, tmp_path: Path) -> None:
    """Importing the builder on a data-less machine never walks the
    ladder; only resolving does (the lazy-EXAMPLES contract)."""
    _floorless(monkeypatch, tmp_path)
    spec = importlib.util.spec_from_file_location(
        "bm_dataless", CATALOG / "build_manifests.py")
    bm = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(bm)  # must not raise
    with pytest.raises(runs_source.RunsError):
        bm.default_examples()


# ------------------------------------------------------------- the verb

def test_catalog_build_end_to_end(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """One command over a synthetic runs tree: manifests, switch sets,
    the site — with the stamp naming what it was built from.  The
    one-shot --runs path becomes the only user group; the checkout has
    no runs/examples, so the fixed examples group degrades to a named
    absent entry (never a crash while a user group stands)."""
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    runs = _synthetic_runs(tmp_path)

    rc = cli.main(["catalog", "build",
                   "--runs", str(runs), "--catalog", str(cat)])
    out = capfd.readouterr().out
    assert rc == 0
    assert "catalog site:" in out
    assert "seated in the per-user share" in out
    assert "group 1: myruns [ok]" in out
    assert "Example runs" in out          # the fixed last group, named

    # the user build seats in the share; the checkout's out/ is never
    # written (only the committed release joins were copied there)
    seat = _share_out(tmp_path / "nohome")
    assert (cat / "out" / "index.json").exists() is False
    index = json.loads((seat / "index.json").read_text(encoding="utf-8"))
    assert [r["name"] for r in index["runs"]] == [
        "myruns/SYNTH1_demo/run1"]
    assert index["runs"][0]["verdict"] in (
        "static", "plateaued", "near-plateau", "evolving")
    # the groups block records display order AND the sick examples
    assert [g["slug"] for g in index["groups"]] == [
        "myruns", "example-runs"]
    assert index["groups"][1]["status"] == "absent"
    assert (seat / "manifests" / "myruns__SYNTH1_demo__run1.json"
            ).is_file()
    assert (seat / "switchsets.json").is_file()

    site = (seat / "site" / "index.html").read_text(encoding="utf-8")
    assert "myruns/SYNTH1_demo/run1" in site
    # the landing is the INVENTORY : a group block carries the
    # counts, verdict summary and analysis fingerprint; the family
    # tables are GONE from the landing (they live on the group pages,
    # checkpoint B); the sick examples group is a first-class row
    assert '<h3 class="grp-h"><a href="myruns/index.html">myruns</a> ' in site
    assert '<span class="n">1</span><span class="l">family</span>' in site
    assert '<span class="n">1</span><span class="l">run</span>' in site
    assert 'class="grp-verd"' in site
    assert 'class="grp-fp">analyses' in site
    assert '<div class="grp-dist">' in site
    assert '<h4 class="fam-h">' not in site
    assert "Not cataloged at last build</h3>" in site
    assert "Example runs" in site.split("Not cataloged at last build")[1]
    assert "catalog remove Example runs" in site   # the sick row's remedy
    # the teacher exists ONLY while zero user groups stand: myruns
    # stands, so it is gone; the user-seat build moment renders
    assert "it can carry yours" not in site
    assert 'class="built-at">built at ' in site
    # the verdict-dot legend names the rail palette
    assert 'class="vlegend"' in site
    # the rail tree: CLOSED native disclosure with
    # count-bearing labels; the group label NAVIGATES (an anchor into
    # the landing's inventory block — index.html#g-<slug>), the
    # marker is the toggle; leaves carry the member name with the
    # full name on hover
    assert '<details class="r-grp" data-grp="myruns">' in site
    assert '<details class="r-fam" data-fam="myruns/SYNTH1_demo">' in site
    assert '<details class="r-grp" data-grp="myruns" open>' not in site
    assert '<details class="r-fam" data-fam="myruns/SYNTH1_demo" open>' \
        not in site
    assert '<a class="r-lab" href="myruns/index.html">myruns</a>' in site
    # checkpoint B — the hierarchy pages: the group page (family
    # block + ONE aggregating filter), the family page (the base
    # deck's home; this synthetic family has no baserun dir, so the
    # honest absence + the single member = the degradation shape),
    # the run page's vs-base delta + lineage, the deck retired from
    # run pages
    grp_pg = (seat / "site" / "myruns" / "index.html").read_text(
        encoding="utf-8")
    assert ('class="fam-h"><a href="SYNTH1_demo/index.html">'
            "SYNTH1_demo</a>") in grp_pg
    assert "data-filter-scope" in grp_pg
    fam_pg = (seat / "site" / "myruns" / "SYNTH1_demo" / "index.html"
              ).read_text(encoding="utf-8")
    assert "Family base deck" in fam_pg
    # the family's address is its group-qualified name (owner review
    # of C) — the h1 and the crumb tail carry it like the run pages
    assert "<h1>myruns/SYNTH1_demo</h1>" in fam_pg
    assert 'title="myruns/SYNTH1_demo" aria-current="page"' in fam_pg
    assert "no shared base deck" in fam_pg
    assert 'href="../../myruns/index.html"' in fam_pg
    assert 'href="../../myruns/SYNTH1_demo/run1/index.html"' in fam_pg
    run_pg = (seat / "site" / "myruns" / "SYNTH1_demo" / "run1"
              / "index.html").read_text(encoding="utf-8")
    assert "Vs family base" in run_pg
    assert "no shared base deck" in run_pg
    assert 'href="../index.html">family page' in run_pg
    assert "<h2>Input deck</h2>" not in run_pg
    assert "· 1 family · 1 run</span>" in site
    assert 'title="myruns/SYNTH1_demo/run1"' in site
    # the truncation contract ships in the page's own CSS
    assert "text-overflow: ellipsis" in site
    # the count YIELDS first (owner review 2026-11-10: a count never
    # costs the folder its name): the summary wraps so the count
    # drops under the label before the label may shrink
    assert "flex-wrap: wrap" in site
    # the name IS the path: group/family/run as real directories
    assert (seat / "site" / "myruns" / "SYNTH1_demo" / "run1"
            / "index.html").is_file()
    # the stamp: built-from numbers, the committed lineage date, the
    # package version, and the rebuild command — static HTML
    assert "Catalog stamp:" in site
    assert "1</b> runs across <b>1</b> families" in site
    stamp = json.loads(
        (cat / "data" / "build-stamp.json").read_text(encoding="utf-8"))
    assert stamp["date"] in site
    assert solps_reader.__version__ in site
    assert "solps-reader catalog build" in site


def test_run_page_vs_base_delta(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """The vs-base delta on a synthetic tree with a REAL family base:
    a baserun/b2mn.dat carrying three switches; one child overriding
    one switch, keeping one in a numeric-equivalent spelling (D vs E
    exponent — equal, never an override), unsetting one (absent from
    its own file) and adding one; a second child with NO deck of its
    own (the identity case).  The artifact's family_decks block and
    the run pages' delta render both prove out."""
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    fam = tmp_path / "myruns" / "FAM_D"
    base = fam / "baserun"
    base.mkdir(parents=True)
    (base / "b2mn.dat").write_text(
        "* synthetic base\n"
        "*endphy\n"
        "'synth_a'   '1.0'\n"
        "'synth_b'   '2.5D-07'\n"
        "'synth_c'   '.true.'\n",
        encoding="latin-1")
    child1 = fam / "child1"
    child1.mkdir()
    (child1 / "fort.44").write_text(
        "2 3 20170328 eirenehash00000000000000000000000000000\n"
        "1 0 0\n"
        "H\n",
        encoding="ascii")
    _write_b2time(child1 / "b2time.nc")
    (child1 / "b2mn.dat").write_text(
        "* child deck\n"
        "*endphy\n"
        "'synth_a'   '9.0'\n"
        "'synth_b'   '2.5e-07'\n"
        "'synth_d'   '.false.'\n",
        encoding="latin-1")
    child2 = fam / "child2"
    child2.mkdir()
    (child2 / "fort.44").write_text(
        "2 3 20170328 eirenehash00000000000000000000000000000\n"
        "1 0 0\n"
        "H\n",
        encoding="ascii")
    _write_b2time(child2 / "b2time.nc")

    rc = cli.main(["catalog", "build",
                   "--runs", str(tmp_path / "myruns"),
                   "--catalog", str(cat)])
    assert rc == 0
    capfd.readouterr()
    seat = _share_out(tmp_path / "nohome")

    # the artifact: the family base parsed once, verbatim
    ss = json.loads((seat / "switchsets.json").read_text(encoding="utf-8"))
    fd = ss["family_decks"]["myruns/FAM_D"]
    assert fd["switches"] == {
        "synth_a": "1.0", "synth_b": "2.5D-07", "synth_c": ".true."}

    # child1: one override, one addition, one unsetting — and the
    # numeric-equivalent spelling NEVER renders as an override
    pg = (seat / "site" / "myruns" / "FAM_D" / "child1"
          / "index.html").read_text(encoding="utf-8")
    assert "1 override · 1 addition · 1 unsetting" in pg
    assert ">synth_a</td>" in pg and ">1.0</td>" in pg and ">9.0</td>" in pg
    assert ">synth_d</td>" in pg and "not set</td>" in pg and "added</td>" in pg
    assert ">synth_c</td>" in pg and "unset</td>" in pg
    # the numeric-equivalent spelling (D vs E exponent) NEVER renders
    # as an override — scoped to the delta table (the run's FULL
    # switches section of course still lists it)
    delta_tbl = pg.split('<table class="vsbase"')[1].split("</table>")[0]
    assert "synth_b" not in delta_tbl

    # child2: no deck of its own — the identity case
    pg2 = (seat / "site" / "myruns" / "FAM_D" / "child2"
           / "index.html").read_text(encoding="utf-8")
    assert "switches ARE the" in pg2 and "verbatim" in pg2

    # the family page anchors the base once
    fam_pg = (seat / "site" / "myruns" / "FAM_D" / "index.html"
              ).read_text(encoding="utf-8")
    assert "Family base deck" in fam_pg
    assert "b2mn.dat" in fam_pg


def test_catalog_build_groups_in_display_order(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """Two one-shot groups + a live examples group: display order is
    the order the paths were given, examples always last; every run's
    address is group-qualified, examples included."""
    repos = checkout_factory()
    examples = repos / "SOLPS-ITER" / "runs" / "examples"
    _write_run(examples / "FAM_EX", "run0")
    monkeypatch.setenv(floor.REPOS_ENV, str(repos))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    alpha, beta = tmp_path / "alpha", tmp_path / "beta"
    _write_run(alpha / "FAM_A")
    _write_run(beta / "FAM_B")

    rc = cli.main(["catalog", "build",
                   "--runs", str(alpha), "--runs", str(beta),
                   "--catalog", str(cat)])
    assert rc == 0
    out = capfd.readouterr().out
    assert out.index("group 1: alpha") < out.index("group 2: beta") \
        < out.index("Example runs")

    seat = _share_out(tmp_path / "nohome")
    index = json.loads((seat / "index.json").read_text(encoding="utf-8"))
    assert [r["name"] for r in index["runs"]] == [
        "alpha/FAM_A/run1", "beta/FAM_B/run1",
        "example-runs/FAM_EX/run0"]
    site = (seat / "site" / "index.html").read_text(encoding="utf-8")
    # display order on the landing: group headers in list order,
    # examples always last; the examples carry the fixed caption
    # (byte-determinism: no machine paths in artifacts)
    assert site.index('grp-h"><a href="alpha/index.html">alpha</a>') \
        < site.index('grp-h"><a href="beta/index.html">beta</a>') \
        < site.index('grp-h"><a href="example-runs/index.html">'
                     'Example runs</a>')
    assert "the shipped reference set" in site
    assert 'path": null' not in site   # no path leaks into the page
    for name in [r["name"] for r in index["runs"]]:
        page = seat / "site"
        for part in name.split("/"):
            page = page / part
        assert (page / "index.html").is_file(), name


def test_catalog_teacher_only_while_zero_user_groups(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """The empty-state teacher: an examples-only build carries
    it (the certified shape doubles as the feature's discovery
    surface), a build with any remembered user source retires it —
    and the examples-only user seat carries NO build-moment line (the
    wall clock rides only catalogs with user groups)."""
    repos = checkout_factory()
    examples = repos / "SOLPS-ITER" / "runs" / "examples"
    _write_run(examples / "FAM_EX", "run0")
    monkeypatch.setenv(floor.REPOS_ENV, str(repos))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)

    assert cli.main(["catalog", "build", "--catalog", str(cat)]) == 0
    capfd.readouterr()
    site = (_share_out(tmp_path / "nohome") / "site" / "index.html"
            ).read_text(encoding="utf-8")
    assert "it can carry yours" in site          # the teacher stands
    assert "solps-reader catalog add" in site    # naming its command
    assert 'class="built-at"' not in site        # no clock without
    # user groups — the seat is clean even though the CLI passed one
    assert "the shipped reference set" in site


def test_catalog_build_skips_a_sick_group_named(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """An empty folder among healthy groups is named and skipped —
    the build proceeds, the groups block records the sickness."""
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    sick = tmp_path / "sick"
    (sick / "junk").mkdir(parents=True)
    runs = _synthetic_runs(tmp_path)

    rc = cli.main(["catalog", "build",
                   "--runs", str(sick), "--runs", str(runs),
                   "--catalog", str(cat)])
    out = capfd.readouterr().out
    assert rc == 0
    assert "group 1: sick [no-runs]" in out
    index = json.loads((_share_out(tmp_path / "nohome") / "index.json")
                       .read_text(encoding="utf-8"))
    assert [r["name"] for r in index["runs"]] == [
        "myruns/SYNTH1_demo/run1"]
    assert index["groups"][0]["status"] == "no-runs"


# permission recovery runs as the invoking user; root reads through
# mode-000 directories, so the denial never happens there
_needs_deniable_permissions = pytest.mark.skipif(
    hasattr(os, "geteuid") and os.geteuid() == 0,
    reason="root reads through mode-000 directories")


@_needs_deniable_permissions
def test_catalog_build_skips_an_unreadable_directory(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """The shared-archive shape: a folder the user cannot read names
    itself on stderr and costs only its own contents — the readable
    runs still catalog and the build still exits 0."""
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    root = tmp_path / "myruns"
    _write_run(root / "SYNTH1_demo", "run1")
    locked = root / "SECRET_locked"
    _write_run(locked, "run_x")
    os.chmod(locked, 0)

    try:
        rc = cli.main(["catalog", "build",
                       "--runs", str(root), "--catalog", str(cat)])
    finally:
        os.chmod(locked, 0o755)      # let tmp_path cleanup delete it
    captured = capfd.readouterr()
    assert rc == 0
    assert "cannot read" in captured.err
    assert "SECRET_locked" in captured.err
    assert "Permission denied" in captured.err
    index = json.loads((_share_out(tmp_path / "nohome") / "index.json")
                       .read_text(encoding="utf-8"))
    assert [r["name"] for r in index["runs"]] == [
        "myruns/SYNTH1_demo/run1"]
    site = (_share_out(tmp_path / "nohome") / "site" / "index.html"
            ).read_text(encoding="utf-8")
    assert "SECRET_locked" not in site


@_needs_deniable_permissions
def test_catalog_build_skips_an_unreadable_baserun(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """The field crash shape exactly: a family baserun the user cannot
    read.  The run itself still catalogs; the deck manifest skips
    with one named line (an unread baserun is an honest absence on
    the family page, never an empty zero-file deck)."""
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    root = tmp_path / "myruns"
    _write_run(root / "SYNTH1_demo", "run1")
    base = root / "SYNTH1_demo" / "baserun"
    base.mkdir()
    (base / "b2mn.dat").write_text("* synthetic base\n*endphy\n",
                                   encoding="latin-1")
    os.chmod(base, 0)

    try:
        rc = cli.main(["catalog", "build",
                       "--runs", str(root), "--catalog", str(cat)])
    finally:
        os.chmod(base, 0o755)
    captured = capfd.readouterr()
    assert rc == 0
    assert "cannot read" in captured.err
    assert "baserun" in captured.err
    index = json.loads((_share_out(tmp_path / "nohome") / "index.json")
                       .read_text(encoding="utf-8"))
    assert [r["name"] for r in index["runs"]] == [
        "myruns/SYNTH1_demo/run1"]
    assert index["decks"] == []
    fam_pg = (_share_out(tmp_path / "nohome") / "site" / "myruns"
              / "SYNTH1_demo" / "index.html").read_text(encoding="utf-8")
    assert "no shared base deck" in fam_pg


def test_catalog_build_prints_one_line_per_case(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """The long-build visibility rule: the manifests stage prints ONE
    line per case as work on it starts — group-qualified, with a
    running counter over the known total.  A build stuck on a heavy
    case shows exactly where it stopped."""
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    root = tmp_path / "myruns"
    _write_run(root / "SYNTH1_demo", "run1")
    _write_run(root / "SYNTH2_more", "run2")

    rc = cli.main(["catalog", "build",
                   "--runs", str(root), "--catalog", str(cat)])
    out = capfd.readouterr().out
    assert rc == 0
    assert "case 1/2: myruns/SYNTH1_demo/run1" in out
    assert "case 2/2: myruns/SYNTH2_more/run2" in out
    # one line per case, never more
    case_lines = [ln for ln in out.splitlines()
                  if ln.startswith("case ")]
    assert len(case_lines) == 2


def test_catalog_build_and_open_honor_the_home_redirect(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """The quota-limited-home shape: --home (and the environment
    variable) move the WHOLE catalog — sources seat, analysis cache,
    built site — off the per-user share, `catalog open` follows the
    same root, and with neither given the default share stands
    untouched."""
    import webbrowser
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.delenv("SOLPS_READER_HOME", raising=False)
    monkeypatch.chdir(tmp_path)
    opened = []
    monkeypatch.setattr(webbrowser, "open",
                        lambda uri: opened.append(uri) or True)
    cat = _catalog_copy(tmp_path)
    runs = _synthetic_runs(tmp_path)
    scratch = tmp_path / "scratch-catalog"

    rc = cli.main(["catalog", "build",
                   "--runs", str(runs), "--catalog", str(cat),
                   "--home", str(scratch)])
    out = capfd.readouterr().out
    assert rc == 0
    assert f"seated in the catalog home at {scratch / 'out'}" in out
    assert (scratch / "out" / "index.json").is_file()
    assert (scratch / "cache").is_dir()
    assert not (_share_out(tmp_path / "nohome") / "index.json").exists()

    # open follows the same root (--home) and would browse the
    # redirected site, not the default share's absence
    rc = cli.main(["catalog", "open", "--home", str(scratch)])
    out = capfd.readouterr().out
    assert rc == 0
    assert "opened your built catalog site" in out
    assert str(scratch) in opened[0]

    # the environment variable moves it for a whole shell, no flag
    envroot = tmp_path / "env-catalog"
    monkeypatch.setenv("SOLPS_READER_HOME", str(envroot))
    rc = cli.main(["catalog", "build",
                   "--runs", str(runs), "--catalog", str(cat)])
    out = capfd.readouterr().out
    assert rc == 0
    assert (envroot / "out" / "index.json").is_file()


def test_catalog_build_is_deterministic(
        checkout_factory, tmp_path: Path, monkeypatch, capsys) -> None:
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    runs = _synthetic_runs(tmp_path)
    argv = ["catalog", "build",
            "--runs", str(runs), "--catalog", str(cat)]
    assert cli.main(argv) == 0
    capsys.readouterr()
    seat = _share_out(tmp_path / "nohome")
    first = _scrub_built_at({
        p.relative_to(seat).as_posix(): p.read_bytes()
        for p in sorted(seat.rglob("*")) if p.is_file()
    })
    assert cli.main(argv) == 0
    capsys.readouterr()
    second = _scrub_built_at({
        p.relative_to(seat).as_posix(): p.read_bytes()
        for p in sorted(seat.rglob("*")) if p.is_file()
    })
    # byte-identical rebuild, catalog stamp included; the user seat's
    # one ruled clock (the built-at line) is normalized out
    assert first == second


def test_catalog_build_in_tree_is_the_maintainer_seat(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """--in-tree writes beside the builders: the maintainer's bump
    path, the rebuild the gate compares against the shipped bytes."""
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    runs = _synthetic_runs(tmp_path)

    rc = cli.main(["catalog", "build", "--runs", str(runs),
                   "--in-tree", "--catalog", str(cat)])
    out = capfd.readouterr().out
    assert rc == 0
    assert "seated in the catalog tree (--in-tree" in out
    assert (cat / "out" / "index.json").is_file()
    assert not _share_out(tmp_path / "nohome").exists()


def _cache_dir(home: Path) -> Path:
    return (home / ".local" / "share" / "solps_reader" / "catalog"
            / "cache")


def _cache_line(out: str) -> tuple[int, int]:
    """(reused, computed) from the build's cache summary line."""
    for ln in out.splitlines():
        if "analysis cache:" in ln:
            body = ln.split("analysis cache:")[1].split("(")[0]
            reused = int(body.split("reused")[0].strip())
            computed = int(body.split(",")[1].split("computed")[0].strip())
            return reused, computed
    raise AssertionError(f"no cache line in output:\n{out}")


def test_cache_reuses_and_recomputes_exactly_the_touched_run(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """The stat-fingerprint contract: an unchanged run costs nothing, a
    touched file (mtime alone) recomputes exactly that run."""
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    root = tmp_path / "myruns"
    _write_run(root / "SYNTH1_demo", "run1")
    _write_run(root / "SYNTH1_demo", "run2")
    argv = ["catalog", "build", "--runs", str(root),
            "--catalog", str(cat)]

    assert cli.main(argv) == 0
    assert _cache_line(capfd.readouterr().out) == (0, 2)
    assert cli.main(argv) == 0
    assert _cache_line(capfd.readouterr().out) == (2, 0)

    bt = root / "SYNTH1_demo" / "run1" / "b2time.nc"
    st = bt.stat()
    import os as _os
    _os.utime(bt, ns=(st.st_atime_ns + 1_000_000_000,
                      st.st_mtime_ns + 1_000_000_000))
    assert cli.main(argv) == 0
    assert _cache_line(capfd.readouterr().out) == (1, 1)


def test_cached_and_forced_builds_are_byte_identical(
        checkout_factory, tmp_path: Path, monkeypatch, capsys) -> None:
    """The equivalence guarantee: a full recompute and a fully-cached
    build produce the same site, byte for byte."""
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    runs = _synthetic_runs(tmp_path)

    assert cli.main(["catalog", "build", "--runs", str(runs),
                     "--catalog", str(cat)]) == 0   # warm the cache
    capsys.readouterr()
    assert cli.main(["catalog", "build", "--runs", str(runs),
                     "--force", "--catalog", str(cat)]) == 0
    capsys.readouterr()
    seat = _share_out(tmp_path / "nohome")
    forced = _scrub_built_at({
        p.relative_to(seat).as_posix(): p.read_bytes()
        for p in sorted(seat.rglob("*")) if p.is_file()})
    assert cli.main(["catalog", "build", "--runs", str(runs),
                     "--catalog", str(cat)]) == 0   # fully cached now
    capsys.readouterr()
    cached = _scrub_built_at({
        p.relative_to(seat).as_posix(): p.read_bytes()
        for p in sorted(seat.rglob("*")) if p.is_file()})
    assert forced == cached


def test_cache_orphans_survive_until_pruned(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """Orphaned entries are kept by default (re-adding a folder stays
    cheap); --prune-cache is the explicit tidy."""
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    a, b = tmp_path / "alpha", tmp_path / "beta"
    _write_run(a / "FAM_A")
    _write_run(b / "FAM_B")
    cache = _cache_dir(tmp_path / "nohome")

    assert cli.main(["catalog", "build", "--runs", str(a),
                     "--catalog", str(cat)]) == 0
    capfd.readouterr()
    assert len(list(cache.glob("*.json"))) == 1
    assert cli.main(["catalog", "build", "--runs", str(b),
                     "--catalog", str(cat)]) == 0
    capfd.readouterr()
    assert len(list(cache.glob("*.json"))) == 2   # alpha's kept

    assert cli.main(["catalog", "build", "--runs", str(b),
                     "--prune-cache", "--catalog", str(cat)]) == 0
    out = capfd.readouterr().out
    assert "cache pruned: 1 dropped, 1 kept" in out
    assert len(list(cache.glob("*.json"))) == 1


def test_catalog_open_prefers_the_built_site(
        monkeypatch, tmp_path: Path, capfd) -> None:
    """open takes the share-built site first and names it; no site
    anywhere is a named refusal, never a silent nothing."""
    import webbrowser
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "home")
    (tmp_path / "home").mkdir(exist_ok=True)
    monkeypatch.chdir(tmp_path)
    opened: list[str] = []
    monkeypatch.setattr(webbrowser, "open",
                        lambda uri: opened.append(uri))

    assert cli.main(["catalog", "open"]) == 2   # nothing built yet
    assert "no catalog site found" in capfd.readouterr().err

    site = (_share_out(tmp_path / "home") / "site" / "index.html")
    site.parent.mkdir(parents=True)
    site.write_text("<html></html>", encoding="utf-8")
    assert cli.main(["catalog", "open"]) == 0
    out = capfd.readouterr().out
    assert "opened your built catalog site" in out
    assert opened and opened[0].startswith("file://")


def test_catalog_build_refuses_a_runless_root(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    empty = tmp_path / "empty"
    empty.mkdir()
    rc = cli.main(["catalog", "build",
                   "--runs", str(empty), "--catalog", str(cat)])
    err = capfd.readouterr().err
    assert rc == 2
    assert "no runs found" in err          # the builder names the reason
    assert "failed at pair decks" in err   # the verb names the step
    # (the pair-deck stage resolves groups first; the manifests step
    # would refuse identically on its own)


def test_catalog_build_is_floor_gated(
        monkeypatch, tmp_path: Path) -> None:
    _floorless(monkeypatch, tmp_path)
    with pytest.raises(SystemExit):
        cli.main(["catalog", "build"])


# ------------------------------------------------------- the retired bridge

def test_no_shipped_script_points_at_the_retired_bridge() -> None:
    """The single-machine bridge is retired: no shipped script
    builds the examples path from its own tree position anymore —
    the runs root comes from the ladder and nowhere else."""
    offenders = []
    for p in [*CATALOG.glob("*.py"),
              *(CATALOG.parent / "src" / "solps_reader").glob("*.py")]:
        src = p.read_text(encoding="utf-8")
        if '"SOLPS-ITER" / "runs" / "examples"' in src:
            offenders.append(p.name)
    assert offenders == []


# ------------------------- the user-seat wall figures (the manual pass's finding)

def test_user_group_wall_figure_paints_into_the_seat(
        tmp_path: Path, monkeypatch) -> None:
    """A gate-PASS run under a USER group never demands the
    maintainer's committed-tree step: its figure paints into THIS
    seat's out/figures and the entry says so."""
    import build_manifests as bm
    run = tmp_path / "myruns" / "FAM1" / "run1"
    run.mkdir(parents=True)
    monkeypatch.setattr(bm, "OUT", tmp_path / "seat" / "out")

    def fake_paint(run_dir, root, gate, out_png):
        out_png.parent.mkdir(parents=True, exist_ok=True)
        out_png.write_bytes(b"\x89PNG stub")
        assert gate["mesh"] == "FAM1/baserun/fort.30"
    monkeypatch.setattr(bm, "_paint_wall_figure", fake_paint)

    entry = bm._figure_entry(run, tmp_path / "myruns", "mygrp",
                             {"mesh": "FAM1/baserun/fort.30"})
    assert entry["figures_seat"] == "out"
    assert entry["path"] == "figures/mygrp__FAM1__run1.png"
    assert (tmp_path / "seat" / "out" / "figures"
            / "mygrp__FAM1__run1.png").is_file()


def test_examples_wall_figure_keeps_the_tree_contract(
        tmp_path: Path, monkeypatch) -> None:
    """The examples' figures are committed tree content: a PASS
    without one stays the loud maintainer demand, never a seat
    paint."""
    import build_manifests as bm
    run = tmp_path / "examples" / "FAM1" / "run1"
    run.mkdir(parents=True)
    monkeypatch.setattr(bm, "FIGURES_DIR", tmp_path / "nofigures")
    monkeypatch.setattr(bm, "OUT", tmp_path / "seat" / "out")

    def never_paint(*a, **k):
        raise AssertionError("the examples group must never paint")
    monkeypatch.setattr(bm, "_paint_wall_figure", never_paint)

    with pytest.raises(bm.BuildRefusal,
                       match="run build_wall_figure.py"):
        bm._figure_entry(run, tmp_path / "examples",
                         runs_source.EXAMPLES_SLUG,
                         {"mesh": "FAM1/baserun/fort.30"})


def test_missing_b2time_warns_and_catalogs_without_convergence(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """b2time.nc is optional SOLPS-ITER output (the field ruling that
    reversed the workshop-era hard refusal): a run without it
    catalogs — one warning line names it, the page's convergence
    section states the absence verbatim, and every other section
    stands.  A cached absence warns identically on rebuild."""
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    markers = tmp_path / "markers"
    (markers / "FAM1" / "run1").mkdir(parents=True)
    (markers / "FAM1" / "run1" / "b2fstate").write_text(
        "", encoding="ascii")
    # the run carries its input deck — the b2time.nc absence is its
    # ONLY defect (a run with no b2mn.dat anywhere is a different
    # absence with its own test below)
    (markers / "FAM1" / "run1" / "b2mn.dat").write_text(
        "* synthetic deck\n*endphy\n'b2eirene'   '.true.'\n",
        encoding="latin-1")

    rc = cli.main(["catalog", "build",
                   "--runs", str(markers), "--catalog", str(cat)])
    captured = capfd.readouterr()
    assert rc == 0
    assert ("warning: markers/FAM1/run1: no b2time.nc; "
            "cataloged without convergence") in captured.out
    seat = _share_out(tmp_path / "nohome")
    index = json.loads((seat / "index.json").read_text(encoding="utf-8"))
    assert [r["name"] for r in index["runs"]] == ["markers/FAM1/run1"]
    assert index["runs"][0]["verdict"] is None
    run_pg = (seat / "site" / "markers" / "FAM1" / "run1" / "index.html"
              ).read_text(encoding="utf-8")
    assert ("Not assessed: b2time.nc not present in this run directory"
            in run_pg)
    assert ("convergence sparklines not generated: "
            "b2time.nc not present in this run directory") in run_pg

    # the cached rebuild warns identically (the absence rides the
    # analysis record, not the compute moment)
    rc = cli.main(["catalog", "build",
                   "--runs", str(markers), "--catalog", str(cat)])
    captured = capfd.readouterr()
    assert rc == 0
    assert ("warning: markers/FAM1/run1: no b2time.nc; "
            "cataloged without convergence") in captured.out


def test_missing_b2mn_warns_and_catalogs_without_switch_set(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """A run whose family carries no b2mn.dat anywhere (the reviewer's
    database shape) no longer kills the build at the switch-set stage:
    the deck joins the b2time precedent as a named per-run absence.
    The run catalogs in full, one warning names it, the artifact's
    absent ledger carries the reason, the page's switch section states
    it, and the MCP tool answers the run by name — never a non-match
    and never a KeyError."""
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    markers = tmp_path / "markers"
    (markers / "FAM1" / "run1").mkdir(parents=True)
    (markers / "FAM1" / "run1" / "b2fstate").write_text(
        "", encoding="ascii")
    _write_b2time(markers / "FAM1" / "run1" / "b2time.nc")
    # NO b2mn.dat anywhere: neither the run dir nor a family baserun
    # carries one — the switch set is the run's only absence

    rc = cli.main(["catalog", "build",
                   "--runs", str(markers), "--catalog", str(cat)])
    captured = capfd.readouterr()
    assert rc == 0
    assert ("warning: markers/FAM1/run1: no effective b2mn.dat"
            in captured.out)
    assert "run cataloged without it" in captured.out

    seat = _share_out(tmp_path / "nohome")
    index = json.loads((seat / "index.json").read_text(encoding="utf-8"))
    assert [r["name"] for r in index["runs"]] == ["markers/FAM1/run1"]

    ss = json.loads((seat / "switchsets.json").read_text(encoding="utf-8"))
    assert ss["runs"] == {}
    assert ss["counts"]["absent_runs"] == 1
    assert "no effective b2mn.dat" in ss["absent"]["markers/FAM1/run1"]

    run_pg = (seat / "site" / "markers" / "FAM1" / "run1" / "index.html"
              ).read_text(encoding="utf-8")
    assert ("Not assessed: no effective b2mn.dat"
            in run_pg)
    # the generic entry-less text is gone — the page names the reason
    assert "no entry for this run" not in run_pg

    # the MCP face answers the deck-less run by name (the guard that
    # replaced the KeyError on provenance.effective_b2mn)
    from solps_reader import mcp as mcp_face
    # the artifact read is <root>/out/switchsets.json — the user
    # build's seat root, not the checkout
    answer = mcp_face.run_switches("markers/FAM1/run1", str(seat.parent))
    assert "carries no switch set" in answer
    assert "no effective b2mn.dat" in answer
