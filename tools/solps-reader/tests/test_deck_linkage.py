"""The deck linkage round: one rule for the link and the record.

The field crash shape (iter/DMS_propellant_gas_study, PR #61): a run
nested deeper than its family, sitting next to its OWN baserun, inside
a family whose top level has none.  The run record linked a deck file
nobody wrote; the page stage chased it after the whole build's work.
These tests pin the single rule (the FAMILY's top-level baserun is the
one directory both halves use), the completed-baserun guard (a baserun
carrying run output is a run, never a deck), and the closing check
(a dangling link refuses HERE, named — never at the page stage).
"""

from __future__ import annotations

import json
import shutil
import sys
from pathlib import Path

import numpy as np
import pytest

from solps_reader import floor
from solps_reader import cli

CATALOG = Path(__file__).resolve().parents[1] / "catalog"
sys.path.insert(0, str(CATALOG))
import build_manifests  # noqa: E402
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


def _write_deck(family: Path) -> Path:
    """One synthetic family base deck: a baserun folder WITHOUT run
    markers (the deck definition), carrying only a deck file."""
    base = family / "baserun"
    base.mkdir(parents=True)
    (base / "b2mn.dat").write_text("* synthetic base\n*endphy\n",
                                   encoding="latin-1")
    return base


def _nested_run(root: Path) -> None:
    """The field shape: the run nested one level under the family,
    next to its own baserun, family top level empty of decks."""
    _write_run(root / "SYNTH1_demo" / "sub", "run1")
    _write_deck(root / "SYNTH1_demo" / "sub")


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

def test_nested_run_without_a_family_deck_builds_green(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """The field crash exactly: the run's own sibling baserun must not
    plant a link to a family deck record nobody writes.  The build
    completes; the family page carries its honest no-shared-deck
    absence."""
    root = tmp_path / "myruns"
    _nested_run(root)
    rc, captured, out = _build(checkout_factory, tmp_path, monkeypatch,
                               capfd, root)
    assert rc == 0, captured.err
    m = json.loads((out / "manifests" / "myruns__SYNTH1_demo__sub__run1.json")
                   .read_text(encoding="utf-8"))
    assert m["input_deck"] is None
    assert not (out / "manifests" / "myruns__SYNTH1_demo__baserun.json"
                ).exists()
    fam_pg = (out / "site" / "myruns" / "SYNTH1_demo" / "index.html"
              ).read_text(encoding="utf-8")
    assert "no shared base deck" in fam_pg


def test_nested_run_links_the_family_deck(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """The same nested run once the family's OWN baserun exists: the
    link appears (the family top-level rule), the deck record it names
    exists, and the family page shows the base-deck section."""
    root = tmp_path / "myruns"
    _nested_run(root)
    _write_deck(root / "SYNTH1_demo")
    rc, captured, out = _build(checkout_factory, tmp_path, monkeypatch,
                               capfd, root)
    assert rc == 0, captured.err
    m = json.loads((out / "manifests" / "myruns__SYNTH1_demo__sub__run1.json")
                   .read_text(encoding="utf-8"))
    assert m["input_deck"] == "manifests/myruns__SYNTH1_demo__baserun.json"
    assert (out / "manifests" / "myruns__SYNTH1_demo__baserun.json"
            ).is_file()
    fam_pg = (out / "site" / "myruns" / "SYNTH1_demo" / "index.html"
              ).read_text(encoding="utf-8")
    assert "Family base deck" in fam_pg


def test_dangling_deck_link_refuses_named(tmp_path: Path) -> None:
    """The closing check, unit-pinned: a run record whose link names a
    file the build did not write refuses HERE — named, exit-shaped as
    a BuildRefusal — never as a page-stage crash; a satisfied link
    passes silently."""
    md = tmp_path / "manifests"
    md.mkdir()
    (md / "g__fam__run1.json").write_text(json.dumps(
        {"name": "g/fam/run1",
         "input_deck": "manifests/g__fam__baserun.json"}),
        encoding="utf-8")
    index = [{"name": "g/fam/run1",
              "manifest": "manifests/g__fam__run1.json"}]
    with pytest.raises(build_manifests.BuildRefusal) as exc:
        build_manifests.verify_deck_links(md, index)
    assert "g/fam/run1" in str(exc.value)
    assert "g__fam__baserun.json" in str(exc.value)
    (md / "g__fam__baserun.json").write_text(
        json.dumps({"kind": "input_deck"}), encoding="utf-8")
    build_manifests.verify_deck_links(md, index)      # passes silently
