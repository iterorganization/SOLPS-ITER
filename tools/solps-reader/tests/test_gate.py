"""The floor gate as this package ships it: the twinned module's
checks, wording, verdicts, and the discovery ladder over synthetic
trees; the CLI analysis gate and the MCP startup gate."""

from __future__ import annotations

from pathlib import Path

import pytest

from solps_reader import floor
from solps_reader import mcp as mcp_mod

def test_floor_complete(checkout_factory):
    root = checkout_factory(optional=("SOLPS-GUI",))
    report = floor.check_floor(root / "SOLPS-ITER")
    assert report.ok
    assert "floor: complete" in floor.format_report(report)


def test_missing_submodule_refused_with_remedy(checkout_factory):
    root = checkout_factory(uninitialized={"modules/B2.5"})
    report = floor.check_floor(root / "SOLPS-ITER")
    assert not report.ok
    refusal = floor.format_refusal(report)
    assert "remedy: git submodule update --init modules/B2.5" in refusal
    assert "nothing was built or changed" in refusal


def test_discovery_env_and_ladder_stop(checkout_factory, tmp_path: Path, monkeypatch):
    root = checkout_factory()
    monkeypatch.setenv(floor.REPOS_ENV, str(root))
    assert floor.check_floor().iter_path == root / "SOLPS-ITER"
    # with the variable gone and no checkout anywhere near, the loud
    # stop names every rung and the fix
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)
    empty = tmp_path / "empty"
    empty.mkdir()
    with pytest.raises(floor.FloorError) as exc:
        floor.discover(cwd=empty, home=tmp_path / "nohome")
    text = str(exc.value)
    assert floor.REPOS_ENV in text and "~/SOLPS-ITER" in text
    assert "git clone --recurse-submodules" in text


def _floorless(monkeypatch, tmp_path: Path) -> None:
    # no env rung, no home clone, and a cwd whose ancestor chain holds
    # no checkout (the synthetic tree nests under tmp_path/repos)
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)


def test_cli_analysis_gated_without_floor(tmp_path: Path, monkeypatch,
                                          capsys):
    _floorless(monkeypatch, tmp_path)
    with pytest.raises(SystemExit) as exc:
        from solps_reader import cli
        cli.main(["ft44", "summary", str(tmp_path / "no-such-file")])
    assert "no SOLPS-ITER checkout found" in str(exc.value)


def test_cli_analysis_passes_gate_with_floor(checkout_factory,
                                             tmp_path: Path, monkeypatch,
                                             capsys):
    root = checkout_factory()
    monkeypatch.setenv(floor.REPOS_ENV, str(root))
    from solps_reader import cli
    # the gate passes; the command proceeds to its own file error
    with pytest.raises(SystemExit) as exc:
        cli.main(["ft44", "summary", str(tmp_path / "no-such-file")])
    assert exc.value.code == 2
    assert "cannot read" in capsys.readouterr().err


def test_cli_version_and_help_stay_ungated(tmp_path: Path, capsys,
                                           monkeypatch):
    _floorless(monkeypatch, tmp_path)
    from solps_reader import cli
    with pytest.raises(SystemExit) as exc:
        cli.main(["--version"])
    assert exc.value.code == 0
    with pytest.raises(SystemExit) as exc:
        cli.main(["--help"])
    assert exc.value.code == 0


def test_setup_verb_status_report(checkout_factory, capsys, tmp_path,
                                  monkeypatch):
    # home isolation is LOAD-BEARING: setup records the root into the
    # per-user share, and this test once overwrote the real machine's
    # record with a pytest path (surfaced 2026-11-09)
    root = checkout_factory(optional=("SOLPS-Tutorials",))
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    from solps_reader import cli
    code = cli.main(["setup", str(root / "SOLPS-ITER")])
    out = capsys.readouterr().out
    assert code == 0
    assert "SOLPS-ITER checkout:" in out
    assert "initialized" in out and "excepted" in out
    assert "SOLPS-Tutorials" in out
    assert "floor: complete" in out
    assert "run catalog snapshot:" in out
    assert "next:" in out


def test_setup_verb_refuses_incomplete_floor(checkout_factory, capsys,
                                             tmp_path, monkeypatch):
    root = checkout_factory(uninitialized={"modules/Carre"})
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    from solps_reader import cli
    with pytest.raises(SystemExit):
        cli.main(["setup", str(root / "SOLPS-ITER")])


def test_mcp_startup_gate(checkout_factory, tmp_path: Path, monkeypatch):
    root = checkout_factory()
    monkeypatch.setenv(floor.REPOS_ENV, str(root))
    mcp_mod.startup_gate()  # passes with the floor in place
    _floorless(monkeypatch, tmp_path)
    with pytest.raises(SystemExit) as exc:
        mcp_mod.startup_gate()
    assert "no SOLPS-ITER checkout found" in str(exc.value)


def test_discovery_differently_named_checkout_resolves_to_itself(
        checkout_factory, tmp_path: Path):
    """The twinned-module field bug, pinned against THIS copy: a clone
    named anything but SOLPS-ITER resolved to a phantom standard-named
    sibling that does not exist (vacuous floor pass, raw crash deep
    inside).  The checkout resolves to ITSELF, whatever its name."""
    root = checkout_factory(iter_name="SOLPS-ITER_GitHub")
    clone = root / "SOLPS-ITER_GitHub"
    r, i, via = floor.discover(cwd=clone / "modules" / "B2.5")
    assert (r, i) == (root, clone)
    assert via.startswith("the launch directory")
    assert not (root / "SOLPS-ITER").exists()


def test_discovery_solpstop_rung(checkout_factory, tmp_path: Path):
    # the SOLPS-ITER session pointer is a ladder rung in this copy
    # too, below the package variable, above directory-shape guessing
    root = checkout_factory()
    r, i, via = floor.discover(env={"SOLPSTOP": str(root)},
                               cwd=tmp_path / "empty")
    assert (r, i, via) == (root, root / "SOLPS-ITER", "$SOLPSTOP")


def test_floor_refuses_a_phantom_checkout_path(checkout_factory):
    # the vacuous-pass guard: a non-checkout path reports the missing
    # shape instead of reading as zero declared submodules
    root = checkout_factory()
    report = floor.check(root, root / "phantom", "test")
    assert not report.ok
    assert report.missing[0][0] == "SOLPS-ITER checkout"
    assert "point at a checkout" in floor.format_refusal(report)
