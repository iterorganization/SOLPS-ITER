"""The dual-role folder: a family directory that is itself a run.

The field shape (iter/123273, PR #61): a folder carrying its own run
output AND containing runs.  The walk catalogs both truths; the page
scheme once died on the second mkdir.  Ruled 2026-11-20 (D-172): the
family page keeps the address and carries BOTH zones - the members
table and base deck as always, the folder's own dossier as the closing
section.  These tests pin the combined page and the unchanged plain
family page.
"""

from __future__ import annotations

import json
import shutil
import sys
from pathlib import Path

import numpy as np

from solps_reader import floor
from solps_reader import cli

CATALOG = Path(__file__).resolve().parents[1] / "catalog"
sys.path.insert(0, str(CATALOG))


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


def _share_out(home: Path) -> Path:
    return (home / ".local" / "share" / "solps_reader" / "catalog"
            / "out")


def _build(checkout_factory, tmp_path: Path, monkeypatch, capfd,
           root: Path):
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    rc = cli.main(["catalog", "build",
                   "--runs", str(root), "--catalog", str(cat)])
    return rc, capfd.readouterr(), _share_out(tmp_path / "nohome")


# ------------------------------------------------------------------ tests

def test_both_folder_builds_one_page_with_both_zones(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """The field shape exactly: the family folder carries its own run
    output AND holds a nested run.  One page carries the members
    table, the base deck absence, and the folder's own dossier as the
    closing section; the nested run keeps its own page; the landing
    lists both runs; the build completes."""
    root = tmp_path / "myruns"
    _write_run(root, "SYNTH1_demo")                # the family folder IS a run
    _write_run(root / "SYNTH1_demo", "run1")       # the nested run
    rc, captured, out = _build(checkout_factory, tmp_path, monkeypatch,
                               capfd, root)
    assert rc == 0, captured.err
    index = json.loads((out / "index.json").read_text(encoding="utf-8"))
    assert sorted(r["name"] for r in index["runs"]) == [
        "myruns/SYNTH1_demo",
        "myruns/SYNTH1_demo/run1"]
    fam_pg = (out / "site" / "myruns" / "SYNTH1_demo"
              / "index.html").read_text(encoding="utf-8")
    assert "<h2>Members</h2>" in fam_pg
    assert "myruns/SYNTH1_demo/run1" in fam_pg
    assert "This folder is itself a run" in fam_pg
    assert "myruns/SYNTH1_demo</h1>" in fam_pg
    # the zones in the ruled order: base deck, members, self-run
    a = fam_pg.index("base deck")
    b = fam_pg.index("<h2>Members</h2>")
    c = fam_pg.index("This folder is itself a run")
    assert a < b < c
    # the nested run keeps its own page; the landing lists both runs
    assert (out / "site" / "myruns" / "SYNTH1_demo" / "run1"
            / "index.html").is_file()
    landing = (out / "site" / "index.html").read_text(encoding="utf-8")
    assert "myruns/SYNTH1_demo/run1" in landing
    # the dual run's landing link resolves to its own address, which
    # IS the family page
    assert 'href="myruns/SYNTH1_demo/index.html"' in landing
    assert "folder-as-run section" in captured.out


def test_plain_family_renders_without_the_section(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """A family that is not a run renders exactly as it always did:
    no self-run section, no summary clause."""
    root = tmp_path / "myruns"
    _write_run(root / "SYNTH1_demo", "run1")
    rc, captured, out = _build(checkout_factory, tmp_path, monkeypatch,
                               capfd, root)
    assert rc == 0, captured.err
    fam_pg = (out / "site" / "myruns" / "SYNTH1_demo" / "index.html"
              ).read_text(encoding="utf-8")
    assert "<h2>Members</h2>" in fam_pg
    assert "This folder is itself a run" not in fam_pg
    assert "folder-as-run section" not in captured.out
