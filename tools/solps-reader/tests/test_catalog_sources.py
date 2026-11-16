"""The remembered catalog sources: the share file, the add/remove/
list verbs, and their refusals.

Everything synthetic and standalone: a temporary home (the share
seats under it), runs folders written as bare marker directories,
and the CLI driven through ``cli.main`` with the floor unset — the
group verbs are ungated by design (remembering a folder is not
analysis).
"""

from __future__ import annotations

import json
from pathlib import Path

import pytest

from solps_reader import catalog_sources as src
from solps_reader import cli


# ---------------------------------------------------------------- fixtures

def _home(tmp: Path) -> Path:
    home = tmp / "home"
    home.mkdir()
    return home


def _runs_folder(tmp: Path, name: str, *, with_runs: bool = True) -> Path:
    """A runs root: a directory whose subdirectories are run
    families. One marker file makes a member a run."""
    root = tmp / name
    family = root / "FAM1"
    family.mkdir(parents=True)
    if with_runs:
        (family / "run1" / "b2fstate").parent.mkdir()
        (family / "run1" / "b2fstate").write_text("", encoding="ascii")
    return root


# ------------------------------------------------------------ the module

def test_sources_path_seats_in_the_share(tmp_path: Path) -> None:
    assert src.sources_path(tmp_path) == (
        tmp_path / ".local" / "share" / "solps_reader" / "catalog"
        / "sources.json")


def test_add_stores_absolute_path_and_default_label(
        tmp_path: Path) -> None:
    path = src.sources_path(_home(tmp_path))
    folder = _runs_folder(tmp_path, "archive")
    entry = src.add(path, str(folder / "."))  # a trailing-dot path
    assert entry["path"] == str(folder.resolve())
    assert entry["label"] == "archive"
    data = src.load(path)
    assert [e["label"] for e in data["sources"]] == ["archive"]


def test_add_label_overrides_and_slugs(tmp_path: Path) -> None:
    path = src.sources_path(_home(tmp_path))
    folder = _runs_folder(tmp_path, "My 2024 Archive!")
    entry = src.add(path, str(folder), label="Archive 2024")
    assert entry["label"] == "Archive 2024"
    assert src.slugify(entry["label"]) == "archive-2024"


def test_add_before_inserts_mid_list(tmp_path: Path) -> None:
    path = src.sources_path(_home(tmp_path))
    src.add(path, str(_runs_folder(tmp_path, "alpha")))
    src.add(path, str(_runs_folder(tmp_path, "beta")))
    src.add(path, str(_runs_folder(tmp_path, "gamma")), before="beta")
    labels = [e["label"] for e in src.load(path)["sources"]]
    assert labels == ["alpha", "gamma", "beta"]


def test_add_refuses_a_missing_folder(tmp_path: Path) -> None:
    path = src.sources_path(_home(tmp_path))
    with pytest.raises(src.SourcesError) as ei:
        src.add(path, str(tmp_path / "nope"))
    assert "not a directory" in str(ei.value)
    assert "catalog add" in str(ei.value)


def test_add_refuses_a_reserved_slug(tmp_path: Path) -> None:
    path = src.sources_path(_home(tmp_path))
    folder = _runs_folder(tmp_path, "switches")
    with pytest.raises(src.SourcesError) as ei:
        src.add(path, str(folder))
    assert "the site already uses" in str(ei.value)
    assert "--label" in str(ei.value)


def test_add_refuses_a_duplicate_slug(tmp_path: Path) -> None:
    path = src.sources_path(_home(tmp_path))
    src.add(path, str(_runs_folder(tmp_path, "runs")))
    with pytest.raises(src.SourcesError) as ei:
        src.add(path, str(_runs_folder(tmp_path / "elsewhere", "runs")))
    assert "already held by" in str(ei.value)


def test_add_refuses_a_label_without_address_characters(
        tmp_path: Path) -> None:
    path = src.sources_path(_home(tmp_path))
    folder = _runs_folder(tmp_path, "arch")
    with pytest.raises(src.SourcesError) as ei:
        src.add(path, str(folder), label="***")
    assert "no address characters" in str(ei.value)


def test_remove_by_label_and_by_path(tmp_path: Path) -> None:
    path = src.sources_path(_home(tmp_path))
    a = src.add(path, str(_runs_folder(tmp_path, "alpha")))
    src.add(path, str(_runs_folder(tmp_path, "beta")))
    entry = src.remove(path, "alpha")
    assert entry["path"] == a["path"]
    assert [e["label"] for e in src.load(path)["sources"]] == ["beta"]
    with pytest.raises(src.SourcesError):
        src.remove(path, a["path"])  # gone by label: by path refuses


def test_remove_refuses_unknown_and_names_the_groups(
        tmp_path: Path) -> None:
    path = src.sources_path(_home(tmp_path))
    src.add(path, str(_runs_folder(tmp_path, "alpha")))
    with pytest.raises(src.SourcesError) as ei:
        src.remove(path, "nope")
    assert "no group matches" in str(ei.value)
    assert "alpha" in str(ei.value)


def test_load_missing_is_the_empty_state(tmp_path: Path) -> None:
    data = src.load(src.sources_path(_home(tmp_path)))
    assert data == {"sources": [], "comparisons": []}


def test_save_load_roundtrip_preserves_comparisons(
        tmp_path: Path) -> None:
    path = src.sources_path(_home(tmp_path))
    src.add(path, str(_runs_folder(tmp_path, "alpha")))
    data = src.load(path)
    data["comparisons"].append({"a": "alpha/FAM1/run1",
                                "b": "beta/FAM1/run1"})
    src.save(path, data)
    assert src.load(path)["comparisons"] == [
        {"a": "alpha/FAM1/run1", "b": "beta/FAM1/run1"}]


def test_has_runs_answers_the_marker_probe(tmp_path: Path) -> None:
    assert src.has_runs(_runs_folder(tmp_path, "full"))
    assert not src.has_runs(_runs_folder(tmp_path, "empty",
                                         with_runs=False))


def test_a_corrupt_file_refuses_with_the_remedy(
        tmp_path: Path) -> None:
    path = src.sources_path(_home(tmp_path))
    path.parent.mkdir(parents=True)
    path.write_text("{not json", encoding="utf-8")
    with pytest.raises(src.SourcesError) as ei:
        src.load(path)
    assert "re-add your folders" in str(ei.value)


# --------------------------------------------------------------- the verbs

def _floorless(monkeypatch, tmp_path: Path) -> Path:
    """No REPOS_ENV, a temporary home, a temporary cwd: the group
    verbs must work with no checkout anywhere in sight."""
    monkeypatch.delenv("ASKTHEDOCS_REPOS_ROOT", raising=False)
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "home")
    (tmp_path / "home").mkdir(exist_ok=True)
    monkeypatch.chdir(tmp_path)
    return src.sources_path()


def test_cli_add_list_remove_roundtrip(
        monkeypatch, tmp_path: Path, capfd) -> None:
    path = _floorless(monkeypatch, tmp_path)
    folder = _runs_folder(tmp_path, "archive")
    assert cli.main(["catalog", "add", str(folder)]) == 0
    out = capfd.readouterr().out
    assert "archive  [ok]" in out
    assert "next: solps-reader catalog build" in out

    folder2 = _runs_folder(tmp_path, "current")
    assert cli.main(["catalog", "add", str(folder2)]) == 0
    capfd.readouterr()
    assert cli.main(["catalog", "list"]) == 0
    out = capfd.readouterr().out
    assert out.index("archive") < out.index("current")
    assert "example runs always follow last" in out

    assert cli.main(["catalog", "remove", "archive"]) == 0
    out = capfd.readouterr().out
    assert "removed archive" in out
    data = json.loads(path.read_text(encoding="utf-8"))
    assert [e["label"] for e in data["sources"]] == ["current"]


def test_cli_list_names_an_absent_folder(
        monkeypatch, tmp_path: Path, capfd) -> None:
    _floorless(monkeypatch, tmp_path)
    folder = _runs_folder(tmp_path, "gone")
    assert cli.main(["catalog", "add", str(folder)]) == 0
    capfd.readouterr()
    import shutil
    shutil.rmtree(folder)
    assert cli.main(["catalog", "list"]) == 0
    assert "[absent]" in capfd.readouterr().out


def test_cli_add_refusal_is_exit_two_with_the_remedy(
        monkeypatch, tmp_path: Path, capfd) -> None:
    _floorless(monkeypatch, tmp_path)
    assert cli.main(["catalog", "add",
                     str(tmp_path / "nope")]) == 2
    err = capfd.readouterr().err
    assert "not a directory" in err


# ------------------------------------------------- the move verb

def _three_groups(tmp_path: Path) -> Path:
    path = src.sources_path(_home(tmp_path))
    for name in ("alpha", "beta", "gamma"):
        src.add(path, str(_runs_folder(tmp_path, name)))
    return path


def test_move_by_ordinal(tmp_path: Path) -> None:
    path = _three_groups(tmp_path)
    entry, at = src.move(path, "gamma", "1")
    assert (entry["label"], at) == ("gamma", 1)
    assert [e["label"] for e in src.load(path)["sources"]] == \
        ["gamma", "alpha", "beta"]


def test_move_clamps_out_of_range_positions(tmp_path: Path) -> None:
    path = _three_groups(tmp_path)
    _, at = src.move(path, "alpha", "99")
    assert at == 3
    _, at = src.move(path, "alpha", "0")
    assert at == 1
    assert [e["label"] for e in src.load(path)["sources"]] == \
        ["alpha", "beta", "gamma"]


def test_move_words_first_last_up_down(tmp_path: Path) -> None:
    path = _three_groups(tmp_path)
    _, at = src.move(path, "beta", "first")
    assert at == 1
    _, at = src.move(path, "beta", "down")
    assert at == 2
    _, at = src.move(path, "beta", "last")
    assert at == 3
    _, at = src.move(path, "beta", "up")
    assert at == 2
    assert [e["label"] for e in src.load(path)["sources"]] == \
        ["alpha", "beta", "gamma"]


def test_move_holding_the_position_changes_nothing(
        tmp_path: Path) -> None:
    path = _three_groups(tmp_path)
    _, at = src.move(path, "beta", "2")
    assert at == 2
    assert [e["label"] for e in src.load(path)["sources"]] == \
        ["alpha", "beta", "gamma"]


def test_move_refuses_an_unknown_group(tmp_path: Path) -> None:
    path = _three_groups(tmp_path)
    with pytest.raises(src.SourcesError, match="no group matches"):
        src.move(path, "delta", "1")


def test_move_refuses_an_ambiguous_reference(
        tmp_path: Path) -> None:
    path = src.sources_path(_home(tmp_path))
    folder = _runs_folder(tmp_path, "shared")
    src.add(path, str(folder), label="one")
    src.add(path, str(folder), label="two")
    with pytest.raises(src.SourcesError, match="more than one group"):
        src.move(path, str(folder), "1")


def test_move_refuses_without_two_groups(tmp_path: Path) -> None:
    path = src.sources_path(_home(tmp_path))
    # empty list: the unknown-group refusal fires first (it names the
    # groups, which is the more honest answer for a phantom name)
    with pytest.raises(src.SourcesError, match="no group matches"):
        src.move(path, "alpha", "1")
    src.add(path, str(_runs_folder(tmp_path, "solo")))
    with pytest.raises(src.SourcesError, match="nothing to move"):
        src.move(path, "solo", "1")


def test_move_refuses_a_non_position(tmp_path: Path) -> None:
    path = _three_groups(tmp_path)
    with pytest.raises(src.SourcesError, match="not a position"):
        src.move(path, "alpha", "banana")


def test_cli_move_and_the_post_add_hint(
        monkeypatch, tmp_path: Path, capfd) -> None:
    _floorless(monkeypatch, tmp_path)
    folder = _runs_folder(tmp_path, "archive")
    assert cli.main(["catalog", "add", str(folder)]) == 0
    out = capfd.readouterr().out
    assert "sits last in display order" in out
    assert "catalog move" in out

    folder2 = _runs_folder(tmp_path, "current")
    assert cli.main(["catalog", "add", str(folder2)]) == 0
    capfd.readouterr()
    assert cli.main(["catalog", "move", "current", "1"]) == 0
    out = capfd.readouterr().out
    assert "moved current to position 1 of 2" in out
    assert cli.main(["catalog", "list"]) == 0
    out = capfd.readouterr().out
    assert out.index("current") < out.index("archive")

    assert cli.main(["catalog", "move", "current", "up"]) == 0
    out = capfd.readouterr().out
    assert "moved current to position 1 of 2" in out
    assert cli.main(["catalog", "move", "nope", "1"]) == 2
    assert "no group matches" in capfd.readouterr().err


def test_cli_corrupt_file_refuses_cleanly_for_every_verb(
        monkeypatch, tmp_path: Path, capfd) -> None:
    """The manual pass's finding: `catalog list` let the corrupt-file
    refusal escape as a raw traceback with exit 1 — every group verb
    must answer it with the one-line remedy and exit 2."""
    _floorless(monkeypatch, tmp_path)
    path = src.sources_path()
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text("garbage", encoding="utf-8")
    for argv in (["catalog", "list"], ["catalog", "add", "/tmp"],
                 ["catalog", "move", "x", "1"], ["catalog", "remove", "x"]):
        assert cli.main(argv) == 2, argv
        captured = capfd.readouterr()
        assert "cannot read the sources file" in captured.err
        assert "re-add your folders" in captured.err
        assert "Traceback" not in captured.err + captured.out
