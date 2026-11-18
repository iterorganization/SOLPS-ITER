"""The status verb rides the store discovery ladder.

Regression: bare ``askthedocs status`` used to fall back to the
two-step developer default (``out/`` beside the package), which
inside an installed package resolves into the venv and refuses a
perfectly good per-user index.  The verb must resolve exactly like
search and show: ``--db`` verbatim, then ``ASKTHEDOCS_DB``, then
the accepted placements, with the ladder's own loud refusal.
"""

from __future__ import annotations

import json
from pathlib import Path

from tests.conftest import make_store

from askthedocs.cli import build_parser, cmd_status
from askthedocs.locate import BUILD_SCHEMA, SUMMARY_NAME


def _make_valid_store(directory: Path) -> Path:
    """A valid index (database + manifest) inside *directory*."""
    db = make_store(directory)
    (directory / SUMMARY_NAME).write_text(
        json.dumps({"schema": BUILD_SCHEMA}), encoding="utf-8")
    return db


def _make_share_store(home: Path) -> Path:
    """A valid store in the per-user share under *home*."""
    return _make_valid_store(home / ".local" / "share" / "askthedocs")


def _isolate(monkeypatch, tmp_path: Path, home: Path) -> None:
    monkeypatch.chdir(tmp_path)  # no ./askthedocs-db beside the launch
    monkeypatch.setenv("HOME", str(home))
    monkeypatch.delenv("ASKTHEDOCS_DB", raising=False)
    monkeypatch.delenv("ASKTHEDOCS_REPOS_ROOT", raising=False)


def test_status_finds_the_user_share(tmp_path: Path, monkeypatch,
                                      capsys):
    home = tmp_path / "home"
    _make_share_store(home)
    _isolate(monkeypatch, tmp_path, home)
    rc = cmd_status(build_parser().parse_args(["status"]))
    out = capsys.readouterr().out
    assert rc == 0
    assert "index built from" in out


def test_status_refuses_loud_when_no_store_anywhere(tmp_path: Path,
                                                     monkeypatch,
                                                     capsys):
    _isolate(monkeypatch, tmp_path, tmp_path / "home")
    rc = cmd_status(build_parser().parse_args(["status"]))
    err = capsys.readouterr().err
    assert rc == 2
    assert "no askthedocs index on this machine" in err
    assert "Accepted placements" in err


def test_status_honors_explicit_db_verbatim(tmp_path: Path,
                                             monkeypatch, capsys):
    elsewhere = tmp_path / "elsewhere"
    db = make_store(elsewhere)
    (elsewhere / SUMMARY_NAME).write_text(
        json.dumps({"schema": BUILD_SCHEMA}), encoding="utf-8")
    _isolate(monkeypatch, tmp_path, tmp_path / "home")
    rc = cmd_status(build_parser().parse_args(
        ["status", "--db", str(db)]))
    out = capsys.readouterr().out
    assert rc == 0
    assert "index built from" in out


def test_status_follows_the_home_env(tmp_path: Path, monkeypatch,
                                      capsys):
    # $ASKTHEDOCS_HOME moves the share step: the index in the
    # redirected home answers, the (empty) per-user share never does
    scratch = tmp_path / "scratch" / "atd"
    _make_valid_store(scratch)
    _isolate(monkeypatch, tmp_path, tmp_path / "home")
    monkeypatch.setenv("ASKTHEDOCS_HOME", str(scratch))
    rc = cmd_status(build_parser().parse_args(["status"]))
    out = capsys.readouterr().out
    assert rc == 0
    assert "index built from" in out


def test_status_home_flag_beats_the_env(tmp_path: Path, monkeypatch,
                                        capsys):
    # --db beats --home beats $ASKTHEDOCS_HOME: the flag's home holds
    # the index, the variable points at an empty directory, and the
    # flag still wins (had it lost, discovery would refuse)
    from askthedocs.cli import main
    env_home = tmp_path / "env-home"          # empty on purpose
    flag_home = tmp_path / "flag-home"
    _make_valid_store(flag_home)
    _isolate(monkeypatch, tmp_path, tmp_path / "home")
    monkeypatch.setenv("ASKTHEDOCS_HOME", str(env_home))
    rc = main(["status", "--home", str(flag_home)])
    out = capsys.readouterr().out
    assert rc == 0
    assert "index built from" in out
