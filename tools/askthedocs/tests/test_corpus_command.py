"""The corpus command's completeness gate: the optional repositories
are optional here too.

Setup already names an absent optional repository and indexes without
it (the same machine shape the field met: the tutorials never
cloned, so no index records them). The sweep found this command was
the one door missing that rule. An absent optional repository is
named and skipped; a required leg neither on disk nor recorded still
refuses."""

from __future__ import annotations

from pathlib import Path

import pytest

from tests.conftest import make_indexable_checkout

from askthedocs import build as build_mod
from askthedocs import cli


def _hermetic_db(tmp_path: Path, monkeypatch) -> None:
    # the gate reads the package-level default store for its recorded
    # legs; point it at nothing so no machine state leaks in
    monkeypatch.setattr(build_mod, "default_db",
                        lambda: tmp_path / "no-such-index.db")


def test_absent_optional_repository_is_named_never_fatal(
        tmp_path: Path, capsys, monkeypatch) -> None:
    root = make_indexable_checkout(tmp_path / "tree")
    _hermetic_db(tmp_path, monkeypatch)
    # the tutorials repository is absent and no index records it
    assert not (root / "SOLPS-Tutorials").exists()

    rc = cli.main(["corpus", "--iter", str(root / "SOLPS-ITER"),
                   "--gui", str(root / "SOLPS-GUI"),
                   "--out", str(tmp_path / "corpus.json")])

    out = capsys.readouterr().out
    assert rc == 0
    assert "optional: SOLPS-Tutorials not on disk" in out
    assert "not required and stays unindexed until cloned" in out
    assert "cannot produce a complete index" not in out
    assert (tmp_path / "corpus.json").is_file()


def test_a_required_leg_neither_present_nor_recorded_still_refuses(
        tmp_path: Path, monkeypatch) -> None:
    _hermetic_db(tmp_path, monkeypatch)
    vanished = tmp_path / "vanished-checkout"

    with pytest.raises(SystemExit,
                       match=r"cannot produce a complete index"):
        cli.main(["corpus", "--iter", str(vanished),
                  "--out", str(tmp_path / "corpus.json")])
