"""The setup verb's ruled behaviors: the idempotent second run (an
existing index is never rebuilt silently), the absent-optional-leg
naming on zero-hit answers, and the fourth leg verdict."""

from __future__ import annotations

from pathlib import Path

from askthedocs import api, state, verdicts
from askthedocs.setup import run_setup


def test_second_run_reports_never_rebuilds(checkout: Path,
                                           live_source: Path,
                                           store_factory, capsys,
                                           tmp_path: Path):
    share = tmp_path / "share"
    db = store_factory(share, source_file=live_source)
    before = db.read_bytes()

    code = run_setup(checkout / "SOLPS-ITER", share=share)

    out = capsys.readouterr().out
    assert code == 0
    assert "index already present" in out
    assert "freshness: current" in out
    # both optional legs are on disk: no absence line
    assert "not on this machine" not in out
    assert "never rebuilt silently" in out
    assert "setup --force" in out
    assert db.read_bytes() == before  # nothing was rebuilt


def test_second_run_names_absent_optional_legs(checkout_factory,
                                               live_source: Path,
                                               store_factory, capsys,
                                               tmp_path: Path):
    root = checkout_factory()  # no optional legs on disk
    share = tmp_path / "share"
    store_factory(share, source_file=live_source)
    code = run_setup(root / "SOLPS-ITER", share=share)
    out = capsys.readouterr().out
    assert code == 0
    assert "SOLPS-GUI  absent: not indexed" in out
    assert "SOLPS-Tutorials  absent: not indexed" in out


def test_zero_hit_names_absent_optional_legs(store_factory,
                                             live_source: Path):
    db = store_factory(source_file=live_source)
    result = api.search("zzznothingmatches", db_path=db)
    assert result.total == 0
    assert result.absent_legs == ["SOLPS-GUI", "SOLPS-Tutorials"]


def test_zero_hit_absent_naming_on_cli(store_factory, live_source: Path,
                                       capsys):
    from askthedocs import cli
    db = store_factory(source_file=live_source)
    code = cli.main(["search", "zzznothingmatches", "--db", str(db)])
    out = capsys.readouterr().out
    assert code == 0
    assert ("the answer might be in SOLPS-GUI / SOLPS-Tutorials: "
            "not indexed on this machine") in out


def test_absent_verdict_rollup(checkout_factory):
    root = checkout_factory()  # optional legs absent
    repos = {"SOLPS-ITER": root / "SOLPS-ITER",
             "SOLPS-GUI": root / "SOLPS-GUI",
             "SOLPS-Tutorials": root / "SOLPS-Tutorials"}
    row = (state.KIND_CORPUS, "SOLPS-ITER", "doc/a.tex", "0" * 64)
    roll = verdicts.leg_verdicts([row], [row], repos)
    by_name = {leg.name: leg for leg in roll.legs}
    assert by_name["SOLPS-GUI"].verdict == verdicts.ABSENT
    assert by_name["SOLPS-Tutorials"].verdict == verdicts.ABSENT
    assert by_name["SOLPS-ITER"].verdict == verdicts.CURRENT
    assert "absent: not indexed on this machine" in \
        by_name["SOLPS-GUI"].label()
    assert roll.absent_legs == ["SOLPS-GUI", "SOLPS-Tutorials"]
    # absent legs are information, never drift
    assert not any((roll.new, roll.changed, roll.removed))
