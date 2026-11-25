"""The index home: one redirect moves discovery's share step wholesale.

The mirror of solps-reader's $SOLPS_READER_HOME: the --home override
beats $ASKTHEDOCS_HOME, which beats the per-user share; an empty
environment value counts as unset; discovery and validation follow the
home; the launch-directory artifact keeps its place above it; --db and
$ASKTHEDOCS_DB still name one file directly and win; and the refusal
names an index the redirect leaves unread in the default location.
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from tests.conftest import make_store

from askthedocs import locate
from askthedocs.locate import BUILD_SCHEMA, DB_NAME, SUMMARY_NAME


def _index_at(directory: Path) -> Path:
    """A valid index (database + build manifest) inside *directory*."""
    db = make_store(directory)
    (directory / SUMMARY_NAME).write_text(
        json.dumps({"schema": BUILD_SCHEMA}), encoding="utf-8")
    return db


def _isolate(monkeypatch, tmp_path: Path, home: Path) -> None:
    monkeypatch.chdir(tmp_path)  # no ./askthedocs-db/ beside the launch
    monkeypatch.setenv("HOME", str(home))


def test_index_home_default_is_the_user_share(tmp_path: Path,
                                              monkeypatch):
    home = tmp_path / "home"
    _isolate(monkeypatch, tmp_path, home)
    assert locate.index_home() == home / ".local" / "share" / "askthedocs"
    assert not locate.index_home_redirected()


def test_index_home_env_moves_the_root(tmp_path: Path, monkeypatch):
    home = tmp_path / "home"
    scratch = tmp_path / "scratch" / "atd"
    _isolate(monkeypatch, tmp_path, home)
    monkeypatch.setenv(locate.HOME_ENV, str(scratch))
    assert locate.index_home() == scratch
    assert locate.index_home_redirected()
    # an empty value counts as unset, never as the empty string path
    monkeypatch.setenv(locate.HOME_ENV, "")
    assert locate.index_home() == home / ".local" / "share" / "askthedocs"
    assert not locate.index_home_redirected()


def test_override_beats_env_and_clearing_falls_through(tmp_path: Path,
                                                       monkeypatch):
    home = tmp_path / "home"
    via_env = tmp_path / "env-home"
    via_flag = tmp_path / "flag-home"
    _isolate(monkeypatch, tmp_path, home)
    monkeypatch.setenv(locate.HOME_ENV, str(via_env))
    locate.set_index_home(via_flag)
    assert locate.index_home() == via_flag          # flag beats env
    locate.set_index_home(None)
    assert locate.index_home() == via_env           # cleared falls to env


def test_discovery_follows_the_home(tmp_path: Path, monkeypatch):
    home = tmp_path / "home"            # nothing under this home
    scratch = tmp_path / "scratch" / "atd"
    db = _index_at(scratch)
    _isolate(monkeypatch, tmp_path, home)
    monkeypatch.setenv(locate.HOME_ENV, str(scratch))
    assert locate.resolve_db() == db    # found there, and validated


def test_launch_dir_artifact_outranks_the_redirected_home(
        tmp_path: Path, monkeypatch):
    launch = tmp_path / "launch"
    launch.mkdir()
    beside = _index_at(launch / "askthedocs-db")
    scratch = tmp_path / "scratch" / "atd"
    _index_at(scratch)
    _isolate(monkeypatch, tmp_path, tmp_path / "home")
    monkeypatch.setenv(locate.HOME_ENV, str(scratch))
    monkeypatch.chdir(launch)
    assert locate.resolve_db() == beside


def test_explicit_db_wins_over_the_redirected_home(tmp_path: Path,
                                                   monkeypatch):
    elsewhere = _index_at(tmp_path / "elsewhere")
    scratch = tmp_path / "scratch" / "atd"      # empty on purpose
    _isolate(monkeypatch, tmp_path, tmp_path / "home")
    monkeypatch.setenv(locate.HOME_ENV, str(scratch))
    assert locate.resolve_db(elsewhere) == elsewhere   # verbatim, no
    # discovery: an empty home never refused the explicit path


def test_refusal_lists_the_redirected_home(tmp_path: Path, monkeypatch):
    scratch = tmp_path / "scratch" / "atd"      # nothing there
    _isolate(monkeypatch, tmp_path, tmp_path / "home")
    monkeypatch.setenv(locate.HOME_ENV, str(scratch))
    with pytest.raises(FileNotFoundError) as exc:
        locate.resolve_db()
    text = str(exc.value)
    assert f"3. {scratch / DB_NAME}" in text
    assert "the index home" in text
    assert "Accepted placements" in text


def test_refusal_names_the_unread_default_share_index(
        tmp_path: Path, monkeypatch):
    home = tmp_path / "home"
    share_db = _index_at(home / ".local" / "share" / "askthedocs")
    scratch = tmp_path / "scratch" / "atd"      # empty on purpose
    _isolate(monkeypatch, tmp_path, home)
    monkeypatch.setenv(locate.HOME_ENV, str(scratch))
    with pytest.raises(FileNotFoundError) as exc:
        locate.resolve_db()
    text = str(exc.value)
    assert str(share_db) in text               # the unread index, named
    assert "not read" in text
    assert f"points at {scratch}" in text
    assert "unset ASKTHEDOCS_HOME" in text
