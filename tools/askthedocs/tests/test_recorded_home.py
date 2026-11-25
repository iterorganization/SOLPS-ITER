"""A moved index home is recorded, and every face finds it without
the variable.

The failure this closes: an index built into a moved home, a service
started from a shell without the variable, and searches that refuse
because nothing wrote down where the index went. The record is one
line in the default location; the variable still wins; a stale
record falls through to the default; a build back into the default
clears it."""

from __future__ import annotations

import shutil
from pathlib import Path

from tests.conftest import make_indexable_checkout

from askthedocs import api, locate
from askthedocs.locate import DB_NAME, HOME_POINTER_NAME
from askthedocs.setup import run_setup


def _default_share() -> Path:
    return Path.home() / ".local" / "share" / "askthedocs"


def test_a_moved_build_records_and_every_face_finds_it(
        indexable_checkout, tmp_path: Path, monkeypatch):
    monkeypatch.chdir(tmp_path)          # the launch-dir rung sees nothing
    moved = tmp_path / "moved-home"

    code = run_setup(indexable_checkout / "SOLPS-ITER", share=moved,
                     install_icon=False)

    assert code == 0
    pointer = _default_share() / HOME_POINTER_NAME
    assert pointer.is_file()
    assert pointer.read_text(encoding="utf-8").strip() == str(moved)
    # a clean shell — no variable, no override, fresh process state:
    # the ladder resolves the MOVED store and searches it
    locate.set_index_home(None)
    assert locate.index_home() == moved
    assert locate.resolve_db() == moved / DB_NAME
    assert api.search("drifts").total >= 1


def test_the_variable_still_beats_the_record(
        indexable_checkout, tmp_path: Path, monkeypatch):
    moved = tmp_path / "moved-home"
    run_setup(indexable_checkout / "SOLPS-ITER", share=moved,
              install_icon=False)
    elsewhere = tmp_path / "elsewhere"

    monkeypatch.setenv(locate.HOME_ENV, str(elsewhere))

    assert locate.index_home() == elsewhere


def test_a_stale_record_falls_through_to_the_default(
        indexable_checkout, tmp_path: Path, monkeypatch):
    monkeypatch.chdir(tmp_path)
    moved = tmp_path / "moved-home"
    run_setup(indexable_checkout / "SOLPS-ITER", share=moved,
              install_icon=False)
    shutil.rmtree(moved)                 # the record now points at nothing

    assert locate.index_home() == _default_share()


def test_a_build_back_into_the_default_clears_the_record(
        indexable_checkout, tmp_path: Path):
    moved = tmp_path / "moved-home"
    run_setup(indexable_checkout / "SOLPS-ITER", share=moved,
              install_icon=False)
    assert (_default_share() / HOME_POINTER_NAME).is_file()

    code = run_setup(indexable_checkout / "SOLPS-ITER",
                     share=_default_share(), install_icon=False,
                     force=True)

    assert code == 0
    assert not (_default_share() / HOME_POINTER_NAME).exists()
    assert (_default_share() / DB_NAME).is_file()
