"""The compare verb: recorded A/B comparisons, their decks, their
pages, and the honest skips.

Everything synthetic: two runs folders whose runs carry full-record
b2fstate (the 16 unconditional records of read_b2fstate.m:59-78 — the
minimal file the state diff accepts), a copied catalog tree, and the
CLI driven end to end: add the groups, compare across them, open the
built site's pair page.
"""

from __future__ import annotations

import json
import shutil
import sys
from pathlib import Path

import numpy as np
import pytest

from solps_reader import catalog_sources as src
from solps_reader import cli
from solps_reader import floor

CATALOG = Path(__file__).resolve().parents[1] / "catalog"
sys.path.insert(0, str(CATALOG))


# ---------------------------------------------------------------- fixtures

NX, NY, NS = 4, 6, 2
N2 = (NX + 2) * (NY + 2)
_STATE_RECORDS = (
    ("na", N2 * NS), ("ne", N2), ("ua", N2 * NS), ("uadia", 2 * N2 * NS),
    ("te", N2), ("ti", N2), ("po", N2), ("fna", 2 * N2 * NS),
    ("fhe", 2 * N2), ("fhi", 2 * N2), ("fch", 2 * N2), ("fch_32", 2 * N2),
    ("fch_52", 2 * N2), ("kinrgy", N2 * NS), ("time", 1), ("fch_p", N2),
)


def _write_b2time(path: Path) -> None:
    from solps_reader._vendor.pupynere import NetCDFFile
    nc = NetCDFFile(str(path), "w")
    nc.createDimension("time", None)
    t = nc.createVariable("timesa", "d", ("time",))
    t[:] = np.linspace(0.0, 1.0, 8)
    m = nc.createVariable("tmne", "d", ("time",))
    m[:] = np.array([1.0] * 7 + [1.001])
    nc.close()


def _write_state_run(family: Path, name: str, *, te: float = 100.0,
                     nx: int = NX,
                     git: str = "eirenehash00000000000000000000000000000"
                     ) -> Path:
    """One synthetic run carrying a FULL-record b2fstate (16
    unconditional records) plus the catalog's other required files —
    the minimal run the state diff can deck against.  ``git`` is the
    fort.44 code stamp (the recorded pair page's code-delta line
    reads it)."""
    n2 = (nx + 2) * (NY + 2)
    counts = {"na": n2 * NS, "ne": n2, "ua": n2 * NS,
              "uadia": 2 * n2 * NS, "te": n2, "ti": n2, "po": n2,
              "fna": 2 * n2 * NS, "fhe": 2 * n2, "fhi": 2 * n2,
              "fch": 2 * n2, "fch_32": 2 * n2, "fch_52": 2 * n2,
              "kinrgy": n2 * NS, "time": 1, "fch_p": n2}
    run = family / name
    run.mkdir(parents=True)
    (run / "fort.44").write_text(
        f"2 3 20170328 {git}\n"
        "1 0 0\n"
        "H\n",
        encoding="ascii")
    _write_b2time(run / "b2time.nc")
    (run / "b2mn.dat").write_text(
        "* synthetic deck\n*endphy\n'b2eirene'   '.true.'\n",
        encoding="latin-1")
    with open(run / "b2fstate", "w", encoding="ascii") as fh:
        fh.write("VERSION03.000.010 synth\n")
        fh.write(f"*cf:    {'int':<8}{3:>12}    {'nx,ny,ns':<32}\n")
        fh.write(f" {nx} {NY} {NS}\n")
        fh.write(f"*cf:    {'char':<8}{5:>12}    {'label':<32}\n synth\n")
        for nm, vals in (("zamin", [0.0, 1.0]), ("zamax", [1.0, 1.0]),
                         ("zn", [1.0, 1.0]), ("am", [2.0, 2.0])):
            fh.write(f"*cf:    {'real':<8}{len(vals):>12}    {nm:<32}\n")
            fh.write(" " + " ".join(f"{float(v):.17E}" for v in vals)
                     + "\n")
        for nm, n in counts.items():
            v = te if nm == "te" else (1.5 if nm == "time" else 300.0)
            fh.write(f"*cf:    {'real':<8}{n:>12}    {nm:<32}\n")
            for i in range(0, n, 6):
                fh.write(" " + " ".join(
                    f"{float(v):.17E}" for _ in range(min(6, n - i)))
                    + "\n")
    return run


def _catalog_copy(tmp: Path) -> Path:
    dst = tmp / "pkg" / "catalog"
    shutil.copytree(
        CATALOG, dst,
        ignore=shutil.ignore_patterns("out", "__pycache__", "*.pyc"))
    joins = dst / "out" / "deltarun_pages"
    joins.mkdir(parents=True)
    for j in sorted((CATALOG / "out" / "deltarun_pages").glob("*.json")):
        shutil.copy2(j, joins / j.name)
    return dst


def _home(tmp: Path) -> Path:
    home = tmp / "home"
    home.mkdir(exist_ok=True)
    return home


def _share_out(home: Path) -> Path:
    return (home / ".local" / "share" / "solps_reader" / "catalog"
            / "out")


# ------------------------------------------------------------ the module

def test_comparison_record_roundtrip(tmp_path: Path) -> None:
    path = src.sources_path(_home(tmp_path))
    entry = src.add_comparison(path, "alpha/FAM/run1", "beta/FAM/run1")
    assert entry == {"a": "alpha/FAM/run1", "b": "beta/FAM/run1"}
    with pytest.raises(src.SourcesError) as ei:   # either order
        src.add_comparison(path, "beta/FAM/run1", "alpha/FAM/run1")
    assert "already recorded" in str(ei.value)
    removed = src.remove_comparison(path, "beta/FAM/run1",
                                    "alpha/FAM/run1")
    assert removed["a"] == "alpha/FAM/run1"
    with pytest.raises(src.SourcesError) as ei:
        src.remove_comparison(path, "a/F/r", "b/F/r")
    assert "none recorded" in str(ei.value)


def test_comparison_record_refuses_bad_selectors(tmp_path: Path) -> None:
    path = src.sources_path(_home(tmp_path))
    with pytest.raises(src.SourcesError) as ei:
        src.add_comparison(path, "run1", "alpha/FAM/run2")
    assert "group-qualified" in str(ei.value)
    with pytest.raises(src.SourcesError) as ei:
        src.add_comparison(path, "a/F/r", "a/F/r")
    assert "DIFFERENT" in str(ei.value)


# ------------------------------------------------------ the verb, end to end

def test_compare_cross_group_builds_deck_and_page(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """The everyday arc: two groups added, one cross-group comparison
    recorded, the build's pair-deck stage writes the deck into the
    seat, the site stages its page, the landing links it."""
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: _home(tmp_path))
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    arch, curr = tmp_path / "archive", tmp_path / "current"
    _write_state_run(arch / "FAM_A", "run1", te=100.0)
    _write_state_run(curr / "FAM_B", "run1", te=110.0)
    assert cli.main(["catalog", "add", str(arch)]) == 0
    assert cli.main(["catalog", "add", str(curr)]) == 0
    capfd.readouterr()

    rc = cli.main(["catalog", "compare",
                   "archive/FAM_A/run1", "current/FAM_B/run1",
                   "--no-build"])
    out = capfd.readouterr().out
    assert rc == 0
    assert "recorded archive/FAM_A/run1 vs current/FAM_B/run1" in out

    rc = cli.main(["catalog", "build", "--catalog", str(cat)])
    res = capfd.readouterr()
    assert rc == 0, res.err + res.out
    out = res.out
    assert "1 recorded-pair page" in out

    seat = _share_out(_home(tmp_path))
    deck = (seat / "figures" / "compare"
            / "archive__FAM_A__run1__vs__current__FAM_B__run1__diff")
    assert (deck / "diff_summary.txt").is_file()
    assert any(p.suffix == ".png" for p in deck.iterdir())
    page = (seat / "site" / "compare"
            / "archive__FAM_A__run1__vs__current__FAM_B__run1"
            / "index.html").read_text(encoding="utf-8")
    assert "archive/FAM_A/run1" in page
    assert "Diff summary (diff_summary.txt, verbatim)" in page
    # equal code stamps (the fixture default) render NO code-delta
    # line — the line is the differ-case's alone
    assert "rode different code" not in page
    landing = (seat / "site" / "index.html").read_text(encoding="utf-8")
    assert "Recorded pairs (catalog compare)" in landing
    # checkpoint C — the TWO-HOMES contract: the rule is written on
    # the landing's Comparisons section, the family decks are indexed
    # as light link lines (0 here: both synthetic families are
    # single-member skips whose honest notes live on their family
    # pages), and the counts line pluralizes
    assert "Two homes" in landing
    assert ("If you chose the pair, it's here; if the family made it "
            "for you, it's there.") in landing
    assert 'href="comparisons/' not in landing   # no decks to index
    assert "0 family decks · 1 recorded pair" in landing
    fam_pg = (seat / "site" / "archive" / "FAM_A" / "index.html"
              ).read_text(encoding="utf-8")
    assert "<h2>Family A/B comparison</h2>" in fam_pg
    assert "not generated:" in fam_pg
    # backlinks from BOTH member run pages — the pair's "here" half
    pair_href = ('href="../../../compare/archive__FAM_A__run1__vs__'
                 'current__FAM_B__run1/index.html"')
    for side in ("archive/FAM_A/run1", "current/FAM_B/run1"):
        rp = (seat / "site").joinpath(
            *side.split("/"), "index.html").read_text(encoding="utf-8")
        assert pair_href in rp, side
        assert "recorded A/B comparison vs" in rp
    # the switch section's landing line carries the LIVE counts (the
    # artifact's own numbers, pluralized) and the switch page states
    # its every-cataloged-run scope
    ss = json.loads((seat / "switchsets.json").read_text(encoding="utf-8"))
    sc = ss["counts"]
    n_sw, n_r = sc["distinct_switches_set"], sc["runs"]
    assert (f"{n_sw} " + ("switch" if n_sw == 1 else "switches")
            + f" over {n_r} " + ("run" if n_r == 1 else "runs")
            + ",") in landing
    sw_pg = (seat / "site" / "switches" / "index.html"
             ).read_text(encoding="utf-8")
    assert "One ledger over every cataloged run" in sw_pg
    index = json.loads((seat / "index.json").read_text(encoding="utf-8"))
    assert index["recorded_comparisons"][0]["deck"].endswith("__diff")

    # --remove drops it; the next build leaves no ghost page
    assert cli.main(["catalog", "compare", "--remove",
                     "archive/FAM_A/run1", "current/FAM_B/run1"]) == 0
    capfd.readouterr()
    assert cli.main(["catalog", "build", "--catalog", str(cat)]) == 0
    out = capfd.readouterr().out
    assert "0 recorded-pair page" in out
    assert not (seat / "site" / "compare").exists()


def test_compare_pair_page_names_the_code_delta(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """The pair page's CODE-DELTA line (checkpoint C): when the two
    legs' fort.44 git stamps differ, the page names both stamps and
    states the deltas include the code's contribution — the recorded
    pair is the release comparison ."""
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: _home(tmp_path))
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    arch, curr = tmp_path / "archive", tmp_path / "current"
    _write_state_run(arch / "FAM_A", "run1",
                     git="codehashaaaa0000000000000000000000000")
    _write_state_run(curr / "FAM_B", "run1",
                     git="codehashbbbb0000000000000000000000000")
    assert cli.main(["catalog", "add", str(arch)]) == 0
    assert cli.main(["catalog", "add", str(curr)]) == 0
    assert cli.main(["catalog", "compare",
                     "archive/FAM_A/run1", "current/FAM_B/run1",
                     "--no-build"]) == 0
    capfd.readouterr()
    assert cli.main(["catalog", "build", "--catalog", str(cat)]) == 0
    capfd.readouterr()
    seat = _share_out(_home(tmp_path))
    page = (seat / "site" / "compare"
            / "archive__FAM_A__run1__vs__current__FAM_B__run1"
            / "index.html").read_text(encoding="utf-8")
    assert "the legs rode different code" in page
    assert "codehashaaaa0000000000000000000000000" in page
    assert "codehashbbbb0000000000000000000000000" in page


def test_recorded_pairs_merge_the_reference_set(tmp_path: Path) -> None:
    """The recorded-pair list every build decks and inventories: the
    user's own pairs first, the reference set's committed pair after
    (marked), --examples-only keeping the reference pair alone, and no
    standing examples group dropping it."""
    import build_diff_decks
    path = src.sources_path(_home(tmp_path))
    src.add_comparison(path, "alpha/FAM/run1", "beta/FAM/run1")
    ex_ok = [{"slug": "example-runs", "status": "ok"}]
    pairs = build_diff_decks.recorded_pairs(path, ex_ok)
    assert pairs[0] == {"a": "alpha/FAM/run1", "b": "beta/FAM/run1"}
    assert len(pairs) == 2 and pairs[1].get("reference") is True \
        and pairs[1]["a"].startswith("example-runs/")
    only_ref = build_diff_decks.recorded_pairs(
        path, ex_ok, examples_only=True)
    assert only_ref == [pairs[1]]
    no_ex = build_diff_decks.recorded_pairs(
        path, [{"slug": "alpha", "status": "ok"}])
    assert no_ex == [pairs[0]]
    # a sick examples group is no standing reference set either
    assert build_diff_decks.recorded_pairs(
        path, [{"slug": "example-runs", "status": "absent"}]) == [pairs[0]]


def test_reference_pair_drops_silently_on_a_partial_reference_set(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """An examples group that stands without the reference pair's runs
    (a synthetic or partial reference set) drops the committed pair
    QUIETLY — never a named skip for content the user never chose."""
    repos = checkout_factory()
    examples = repos / "SOLPS-ITER" / "runs" / "examples"
    _write_state_run(examples / "FAM_EX", "run0")
    monkeypatch.setenv(floor.REPOS_ENV, str(repos))
    monkeypatch.setattr(Path, "home", lambda: _home(tmp_path))
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    assert cli.main(["catalog", "build", "--catalog", str(cat)]) == 0
    res = capfd.readouterr()
    assert "ITER_2588_drifts__run_with_drifts" not in res.out
    index = json.loads((_share_out(_home(tmp_path)) / "index.json")
                       .read_text(encoding="utf-8"))
    assert index["recorded_comparisons"] == []
    landing = (_share_out(_home(tmp_path)) / "site" / "index.html"
               ).read_text(encoding="utf-8")
    assert "no group provides a run named example-runs/ITER_2588" \
        not in landing


def test_compare_names_its_skips(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """A comparison naming a run no group provides, and a grid
    mismatch: both named skips in the build output and the index —
    never a failed build."""
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: _home(tmp_path))
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    arch = tmp_path / "archive"
    _write_state_run(arch / "FAM_A", "run1")
    _write_state_run(arch / "FAM_G", "run_big", nx=8)   # different grid
    assert cli.main(["catalog", "add", str(arch)]) == 0
    capfd.readouterr()
    assert cli.main(["catalog", "compare", "archive/FAM_A/run1",
                     "nowhere/FAM/run1", "--no-build"]) == 0
    assert cli.main(["catalog", "compare", "archive/FAM_A/run1",
                     "archive/FAM_G/run_big", "--no-build"]) == 0
    capfd.readouterr()

    rc = cli.main(["catalog", "build", "--catalog", str(cat)])
    res = capfd.readouterr()
    assert rc == 0, res.err + res.out
    out = res.out
    assert "no group provides a run named nowhere/FAM/run1" in out
    assert "grid (6, 8) != (10, 8)" in out
    index = json.loads((_share_out(_home(tmp_path)) / "index.json")
                       .read_text(encoding="utf-8"))
    skips = {c["a"] + c["b"]: c["skipped"]
             for c in index["recorded_comparisons"] if c.get("skipped")}
    assert "no group provides" in skips["archive/FAM_A/run1nowhere/FAM/run1"]
    assert "grid" in skips["archive/FAM_A/run1archive/FAM_G/run_big"]
    landing = (_share_out(_home(tmp_path)) / "site" / "index.html") \
        .read_text(encoding="utf-8")
    assert "no group provides a run named nowhere/FAM/run1" in landing


def test_recorded_pairs_dedupes_the_reference_pair(tmp_path: Path) -> None:
    """Recording the reference set's own pair yourself decks ONE deck,
    not two: the merge drops the identical reference entry (the user's
    record wins; the manual pass's site-stage crash — the deck stage
    generated twice and the site died on the second mkdir)."""
    import build_diff_decks
    path = src.sources_path(_home(tmp_path))
    ex_ok = [{"slug": "example-runs", "status": "ok"}]
    ref = build_diff_decks.recorded_pairs(path, ex_ok,
                                          examples_only=True)[0]
    src.add_comparison(path, ref["a"], ref["b"])
    assert build_diff_decks.recorded_pairs(path, ex_ok) == [
        {"a": ref["a"], "b": ref["b"]}]
    # either order records the same pair (add_comparison's own rule)
    src.remove_comparison(path, ref["a"], ref["b"])
    src.add_comparison(path, ref["b"], ref["a"])
    assert build_diff_decks.recorded_pairs(path, ex_ok) == [
        {"a": ref["b"], "b": ref["a"]}]


# --------------------------------------- the field shape: paths + the tree

def test_compare_refuses_filesystem_paths(
        tmp_path: Path, monkeypatch, capfd) -> None:
    """The field poisoning shape: a folder path was once recorded as
    a run name and no build could ever resolve it.  Every path-shaped
    selector (existing, absolute, or relative-prefix) is refused with
    the two-step remedy; nothing is recorded."""
    monkeypatch.setattr(Path, "home", lambda: _home(tmp_path))
    monkeypatch.chdir(tmp_path)
    run = tmp_path / "iter" / "2496" / "run5"
    run.mkdir(parents=True)
    bad_pairs = (
        (str(run), "alpha/FAM/run2"),
        (str(tmp_path / "no" / "such" / "dir"), "alpha/FAM/run2"),
        ("./iter/2496/run5", "alpha/FAM/run2"),
    )
    for a, b in bad_pairs:
        rc = cli.main(["catalog", "compare", a, b, "--no-build"])
        captured = capfd.readouterr()
        assert rc == 2, (a, captured.err)
        assert "looks like a filesystem path" in captured.err
        assert "catalog add" in captured.err
    assert src.load(src.sources_path())["comparisons"] == []


def test_compare_records_nothing_when_the_tree_cannot_be_found(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """The ordering rule: the builders tree resolves BEFORE anything
    is recorded.  A compare that would build refuses on the missing
    tree with the plain-language remedy and leaves zero comparisons
    behind (the field shape left a recorded path plus a failed
    build)."""
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: _home(tmp_path))
    monkeypatch.chdir(tmp_path)      # no catalog tree anywhere near
    with pytest.raises(SystemExit) as ei:
        cli.main(["catalog", "compare", "a/FAM/run1", "b/FAM/run1"])
    assert ei.value.code == 2
    captured = capfd.readouterr()
    assert "catalog tree not found" in captured.err
    assert "repository clone" in captured.err
    assert "'solps-reader setup' once" in captured.err
    assert src.load(src.sources_path())["comparisons"] == []


def test_setup_records_the_tree_and_the_ladder_follows(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """Setup, run once from the package folder, records the builders
    tree under the catalog home; the tree ladder then resolves it
    from an unrelated directory (the recorded rung)."""
    import argparse
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: _home(tmp_path))
    pkg = tmp_path / "pkg"
    (pkg / "catalog").mkdir(parents=True)
    (pkg / "catalog" / "build_catalog.py").write_text("", encoding="utf-8")
    monkeypatch.chdir(pkg)

    assert cli.main(["setup"]) == 0
    out = capfd.readouterr().out
    assert "catalog builders recorded" in out
    record = src.catalog_root() / "catalog-tree"
    assert record.is_file()
    # the first rung that holds the builders wins: beside this install
    # (editable installs record the real checkout) or under the launch
    # directory (pip installs record the clone they were run from)
    here_tree = Path(cli.__file__).resolve().parents[2] / "catalog"
    expected = (here_tree if (here_tree / "build_catalog.py").is_file()
                else pkg / "catalog").resolve()
    assert Path(record.read_text(encoding="utf-8").strip()) == expected

    # from an unrelated directory the recorded rung resolves the tree
    monkeypatch.chdir(tmp_path)
    monkeypatch.setattr(
        src, "recorded_tree", lambda: (pkg / "catalog").resolve())
    tree = cli._catalog_tree(argparse.ArgumentParser(), None)
    assert tree == (pkg / "catalog").resolve()
