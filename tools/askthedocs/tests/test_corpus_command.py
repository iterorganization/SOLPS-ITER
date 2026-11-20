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


def test_the_non_public_submodule_never_blocks_a_real_clone(
        tmp_path: Path, capsys, monkeypatch) -> None:
    """The field shape the git-less fixtures cannot reach: a REAL git
    parent whose tree declares the adas gitlink, never initialized —
    the state of every actual clone (the submodule is non-public;
    nobody can initialize it).  The verb lists the corpus; the
    excepted submodule is neither a leg nor a demand."""
    import subprocess
    _hermetic_db(tmp_path, monkeypatch)
    root = make_indexable_checkout(tmp_path / "tree")
    iter_repo = root / "SOLPS-ITER"

    def git(*argv: str, stdin: bytes | None = None) -> str:
        return subprocess.run(["git", *argv], cwd=iter_repo, input=stdin,
                              capture_output=True, check=True
                              ).stdout.decode().strip()

    git("init", "-q")
    git("config", "user.email", "t@example.org")
    git("config", "user.name", "t")
    branch = git("symbolic-ref", "--short", "HEAD")
    # a tree carrying ONLY the adas gitlink (the working files stay
    # untracked; the walk reads the disk, the declaration reads HEAD)
    git("update-index", "--add", "--cacheinfo",
        "160000,1e570490ecb34136bf995ca3b8e2068c00ae2fac,modules/adas")
    tree = git("write-tree")
    commit = git("commit-tree", tree, "-m", "gitlink declaration")
    git("update-ref", f"refs/heads/{branch}", commit)

    rc = cli.main(["corpus", "--iter", str(iter_repo),
                   "--gui", str(root / "SOLPS-GUI"),
                   "--out", str(tmp_path / "corpus.json")])

    out = capsys.readouterr().out
    assert rc == 0
    assert "cannot produce a complete index" not in out
    assert "modules/adas" not in out
    assert (tmp_path / "corpus.json").is_file()
