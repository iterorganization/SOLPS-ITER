"""Hostile input shapes for the one build path: every optional run
file may be missing.

A runs folder in the field is whatever the user's database carries:
complete runs, but also runs with pieces absent. The build's contract
is that no single missing file costs the run its page or costs the
other runs their build: each absence is either named in a warning or
honestly stated on the page, and the build always finishes.

Everything here is synthetic and standalone: a copied catalog tree
(the package's own builders, no run data), runs written by hand, a
floor-perfect checkout from the shared factory. No network, no real
repositories.
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
import runs_source  # noqa: E402

FT44_HEADER = ("2 3 20170328 eirenehash00000000000000000000000000000\n"
               "1 0 0\n"
               "H\n")
DECK = "*endphy\n'b2eirene'   '.true.'\n'b2ntde' '1.0'\n"


# ---------------------------------------------------------------- writers

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


def _write_b2fstate(path: Path) -> None:
    """A minimal but well-formed b2fstate header the state reader
    accepts (VERSION line + the six header records)."""
    nx, ny, ns = 2, 3, 2
    with open(path, "w", encoding="ascii") as fh:
        fh.write("VERSION03.000.010 synth\n")

        def rec(name, typ, vals):
            fh.write(f"*cf:    {typ:<8}{len(vals):>12}    {name:<32}\n")
            for i in range(0, len(vals), 6):
                fh.write(" " + " ".join(
                    f"{v!r}" if typ == "int" else f"{float(v):.17E}"
                    for v in vals[i:i + 6]) + "\n")

        rec("nx,ny,ns", "int", [nx, ny, ns])
        fh.write(f"*cf:    {'char':<8}{5:>12}    {'label':<32}\n")
        fh.write(" synth\n")
        rec("zamin", "real", [0.0, 1.0])
        rec("zamax", "real", [1.0, 1.0])
        rec("zn", "real", [1.0, 1.0])
        rec("am", "real", [2.0, 2.0])


def _write_complete_run(family: Path, name: str = "run1") -> Path:
    """Every optional file present: the marker header, the time
    history, the deck, the plasma state."""
    run = family / name
    run.mkdir(parents=True)
    (run / "fort.44").write_text(FT44_HEADER, encoding="ascii")
    _write_b2time(run / "b2time.nc")
    _write_b2fstate(run / "b2fstate")
    (run / "b2mn.dat").write_text(DECK, encoding="latin-1")
    return run


def _catalog_copy(tmp: Path) -> Path:
    dst = tmp / "pkg" / "catalog"
    shutil.copytree(
        CATALOG, dst,
        ignore=shutil.ignore_patterns("out", "__pycache__", "*.pyc"))
    return dst


def _share_out(home: Path) -> Path:
    return (home / ".local" / "share" / "solps_reader" / "catalog"
            / "out")


def _build(checkout_factory, tmp_path: Path, monkeypatch, capfd,
           make_run) -> tuple[int, str, Path]:
    """One build over a one-run family the caller shapes; returns the
    exit code, the captured output, and the seat."""
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)
    markers = tmp_path / "markers"
    make_run(markers / "FAM1")
    rc = cli.main(["catalog", "build",
                   "--runs", str(markers), "--catalog", str(cat)])
    captured = capfd.readouterr()
    return rc, captured.out, _share_out(tmp_path / "nohome")


# ------------------------------------------------------------ the matrix

#: the optional files a complete synthetic run carries; one leg of the
#: matrix removes exactly one of them.
REMOVABLE = ("b2time.nc", "fort.44", "b2mn.dat", "b2fstate")


def test_a_complete_run_builds_every_surface(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """The control leg: nothing missing, the switch set and the
    convergence verdict both exist."""
    rc, out, seat = _build(checkout_factory, tmp_path, monkeypatch,
                           capfd, _write_complete_run)
    assert rc == 0
    index = json.loads((seat / "index.json").read_text(encoding="utf-8"))
    run = index["runs"][0]
    assert run["name"] == "markers/FAM1/run1"
    assert run["verdict"] is not None
    ss = json.loads((seat / "switchsets.json").read_text(encoding="utf-8"))
    assert ss["runs"]["markers/FAM1/run1"]["switches"] == {
        "b2eirene": {"value": ".true.", "source_file": "run",
                     "vs_default": "unknown_to_inventory"},
        "b2ntde": {"value": "1.0", "source_file": "run",
                   "vs_default": "unknown_to_inventory"},
    }


@pytest.mark.parametrize("missing", REMOVABLE)
def test_each_optional_file_may_be_missing(
        checkout_factory, tmp_path: Path, monkeypatch, capfd,
        missing: str) -> None:
    """Removing any one optional file never costs the build, never
    costs the run its page, and the absence is named where a warning
    or a page line exists for it."""
    def make_run(family: Path) -> None:
        run = _write_complete_run(family)
        (run / missing).unlink()

    rc, out, seat = _build(checkout_factory, tmp_path, monkeypatch,
                           capfd, make_run)
    assert rc == 0, out
    index = json.loads((seat / "index.json").read_text(encoding="utf-8"))
    assert [r["name"] for r in index["runs"]] == ["markers/FAM1/run1"]
    run_pg = (seat / "site" / "markers" / "FAM1" / "run1" / "index.html"
              ).read_text(encoding="utf-8")

    if missing == "b2time.nc":
        assert ("warning: markers/FAM1/run1: no b2time.nc; "
                "cataloged without convergence") in out
        assert index["runs"][0]["verdict"] is None
        assert ("Not assessed: b2time.nc not present in this run "
                "directory") in run_pg
    elif missing == "b2mn.dat":
        assert "warning: markers/FAM1/run1: no effective b2mn.dat" in out
        ss = json.loads((seat / "switchsets.json")
                        .read_text(encoding="utf-8"))
        assert ss["runs"] == {}
        assert "no effective b2mn.dat" in \
            ss["absent"]["markers/FAM1/run1"]
        assert "Not assessed: no effective b2mn.dat" in run_pg
    else:
        # fort.44 / b2fstate: the build finishes and the run keeps its
        # page; their surfaces state the absence in their own words
        assert (seat / "site" / "markers" / "FAM1" / "run1"
                / "index.html").is_file()


def test_a_sparse_run_catalogs_with_every_absence_named(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    """The sparsest catalogable run: the marker header and nothing
    else. No convergence verdict, no switch set, no wall section:
    every surface states its honest absence and the build finishes."""
    def make_run(family: Path) -> None:
        run = family / "run1"
        run.mkdir(parents=True)
        (run / "fort.44").write_text(FT44_HEADER, encoding="ascii")

    rc, out, seat = _build(checkout_factory, tmp_path, monkeypatch,
                           capfd, make_run)
    assert rc == 0, out
    assert "warning: markers/FAM1/run1: no b2time.nc" in out
    assert "warning: markers/FAM1/run1: no effective b2mn.dat" in out

    index = json.loads((seat / "index.json").read_text(encoding="utf-8"))
    assert [r["name"] for r in index["runs"]] == ["markers/FAM1/run1"]
    assert index["runs"][0]["verdict"] is None

    ss = json.loads((seat / "switchsets.json").read_text(encoding="utf-8"))
    assert ss["runs"] == {}
    assert "no effective b2mn.dat" in \
        ss["absent"]["markers/FAM1/run1"]
    assert ss["counts"]["absent_runs"] == 1

    run_pg = (seat / "site" / "markers" / "FAM1" / "run1" / "index.html"
              ).read_text(encoding="utf-8")
    assert "Not assessed: b2time.nc not present" in run_pg
    assert "Not assessed: no effective b2mn.dat" in run_pg
