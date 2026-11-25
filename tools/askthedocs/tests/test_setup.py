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


def test_setup_resolves_a_differently_named_clone_from_within(
        indexable_checkout, tmp_path: Path, monkeypatch, capsys):
    """The reviewer's shape, end to end: setup launched from inside a
    clone whose folder is NOT named SOLPS-ITER resolves THAT clone.
    Previously the ladder answered with a phantom standard-named
    sibling that does not exist, the floor passed vacuously, and the
    build crashed deep inside on a raw missing-file error."""
    clone = indexable_checkout / "SOLPS-ITER"
    renamed = clone.parent / "SOLPS-ITER_GitHub"
    clone.rename(renamed)
    monkeypatch.chdir(renamed)
    from askthedocs import setup as setup_mod
    share = tmp_path / "share"
    setup_mod.run_setup(None, share=share, install_icon=False)
    out = capsys.readouterr().out
    assert f"SOLPS-ITER checkout: {renamed}" in out
    assert "found via the launch directory" in out
    # the build completed, and the phantom sibling never existed
    assert "what's next:" in out
    assert not (renamed.parent / "SOLPS-ITER").exists()


def test_setup_home_flag_builds_into_the_chosen_home(
        indexable_checkout, tmp_path: Path, monkeypatch, capsys):
    """--home moves the whole build: the database, the manifest, and
    every companion file land in the chosen directory, the per-user
    share is untouched, an index left in the default location is
    named as untouched, and the completion block names the home."""
    from askthedocs import cli
    from askthedocs.locate import DB_NAME, SUMMARY_NAME
    home = tmp_path / "home"
    share_db = home / ".local" / "share" / "askthedocs" / DB_NAME
    share_db.parent.mkdir(parents=True)
    share_db.write_bytes(b"planted default-location index")
    planted = share_db.read_bytes()
    scratch = tmp_path / "scratch" / "atd"
    monkeypatch.setenv("HOME", str(home))

    code = cli.main(["setup", str(indexable_checkout / "SOLPS-ITER"),
                     "--home", str(scratch), "--no-icon"])
    out = capsys.readouterr().out
    assert code == 0
    # the whole index moved: database + manifest + companions + the
    # recorded corpus root
    for name in (DB_NAME, SUMMARY_NAME, "switches.json", "corpus.json",
                 "repos-root"):
        assert (scratch / name).is_file(), name
    # the default-location index was neither read nor written
    assert share_db.read_bytes() == planted
    assert "stays untouched" in out
    assert str(share_db) in out
    # the completion block names the home and the export
    assert f"index home: {scratch}" in out
    assert f"export ASKTHEDOCS_HOME={scratch}" in out
    assert "what's next:" in out  # the build completed


def test_setup_env_var_builds_into_the_home(
        indexable_checkout, tmp_path: Path, monkeypatch, capsys):
    """$ASKTHEDOCS_HOME alone redirects the build; the per-user share
    under the isolated home carries ONLY the one-line record of the
    moved home (never an index)."""
    from askthedocs import setup as setup_mod
    from askthedocs.locate import DB_NAME, HOME_POINTER_NAME
    home = tmp_path / "home"
    scratch = tmp_path / "scratch" / "atd"
    monkeypatch.setenv("HOME", str(home))
    monkeypatch.setenv("ASKTHEDOCS_HOME", str(scratch))
    code = setup_mod.run_setup(indexable_checkout / "SOLPS-ITER",
                               install_icon=False)
    out = capsys.readouterr().out
    assert code == 0
    assert (scratch / DB_NAME).is_file()
    assert f"index home: {scratch}" in out
    default = home / ".local" / "share" / "askthedocs"
    assert not (default / DB_NAME).exists()
    assert [p.name for p in default.iterdir()] == [HOME_POINTER_NAME]
    assert (default / HOME_POINTER_NAME).read_text(
        encoding="utf-8").strip() == str(scratch)


def test_setup_second_run_reads_the_redirected_home(
        checkout: Path, live_source: Path, store_factory, capsys,
        tmp_path: Path, monkeypatch):
    """Freshness follows the redirect too: with $ASKTHEDOCS_HOME set,
    the second run reads the index in that home (never rebuilds it,
    never touches the default share), and the recorded corpus root
    lands in the redirected home."""
    scratch = tmp_path / "scratch" / "atd"
    db = store_factory(scratch, source_file=live_source)
    before = db.read_bytes()
    monkeypatch.setenv("HOME", str(tmp_path / "home"))
    monkeypatch.setenv("ASKTHEDOCS_HOME", str(scratch))

    code = run_setup(checkout / "SOLPS-ITER", install_icon=False)

    out = capsys.readouterr().out
    assert code == 0
    assert "index already present" in out
    assert "freshness: current" in out
    assert db.read_bytes() == before      # nothing was rebuilt
    assert (scratch / "repos-root").is_file()  # the record moved too
    assert not (tmp_path / "home" / ".local" / "share" /
                "askthedocs").exists()
