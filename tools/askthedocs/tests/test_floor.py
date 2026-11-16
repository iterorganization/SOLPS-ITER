"""The floor gate: checks, wording, verdicts, and the discovery
ladder, all over synthetic trees.

The gate module is twinned byte-identical with solps-reader's; these
tests pin THIS copy's behavior (the ship-time audit diffs the twins).
"""

from __future__ import annotations

from pathlib import Path

import pytest

from askthedocs import floor


def test_floor_complete(checkout: Path):
    report = floor.check_floor(checkout / "SOLPS-ITER")
    assert report.ok
    assert not report.missing
    assert report.repos == {
        "SOLPS-ITER": checkout / "SOLPS-ITER",
        "SOLPS-GUI": checkout / "SOLPS-GUI",
        "SOLPS-Tutorials": checkout / "SOLPS-Tutorials",
    }
    text = floor.format_report(report)
    assert "floor: complete" in text
    assert "modules/B2.5" in text and "initialized" in text
    assert "excepted" in text  # adas


def test_missing_submodule_refused_with_remedy(checkout_factory):
    root = checkout_factory(uninitialized={"modules/Eirene"})
    report = floor.check_floor(root / "SOLPS-ITER")
    assert not report.ok
    refusal = floor.format_refusal(report)
    assert "modules/Eirene" in refusal
    assert "remedy: git submodule update --init modules/Eirene" in refusal
    assert "nothing was built or changed" in refusal


def test_excepted_submodule_never_required(checkout_factory):
    # adas carries no .git in every synthetic checkout; the floor
    # still passes
    root = checkout_factory()
    assert floor.check_floor(root / "SOLPS-ITER").ok


def test_optional_legs_reported_not_refused(checkout_factory):
    root = checkout_factory()  # neither optional leg exists
    report = floor.check_floor(root / "SOLPS-ITER")
    assert report.ok
    assert report.optional == [("SOLPS-GUI", False),
                               ("SOLPS-Tutorials", False)]
    assert set(report.repos) == {"SOLPS-ITER"}


def test_discovery_explicit_wins(checkout_factory, tmp_path: Path,
                                 monkeypatch):
    first = checkout_factory(optional=("SOLPS-GUI",))
    second = checkout_factory(base="repos2")
    monkeypatch.setenv(floor.REPOS_ENV, str(second))
    root, iter_path, via = floor.discover(first / "SOLPS-ITER",
                                          cwd=tmp_path / "unrelated")
    assert root == first
    assert via == "the path given to setup"


def test_discovery_env_as_root_and_as_checkout(checkout_factory,
                                               tmp_path: Path,
                                               monkeypatch):
    root = checkout_factory(optional=("SOLPS-Tutorials",))
    monkeypatch.setenv(floor.REPOS_ENV, str(root))
    r, i, via = floor.discover(cwd=tmp_path / "elsewhere")
    assert (r, via) == (root, f"${floor.REPOS_ENV}")
    # the same variable pointing directly at the checkout also answers
    monkeypatch.setenv(floor.REPOS_ENV, str(root / "SOLPS-ITER"))
    r2, i2, _ = floor.discover(cwd=tmp_path / "elsewhere")
    assert r2 == root and i2 == root / "SOLPS-ITER"


def test_discovery_launch_directory_ancestors(checkout_factory,
                                              monkeypatch):
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)
    root = checkout_factory()
    deep = root / "SOLPS-ITER" / "modules" / "B2.5" / "src"
    deep.mkdir(parents=True, exist_ok=True)
    r, i, via = floor.discover(cwd=deep)
    assert r == root and i == root / "SOLPS-ITER"
    assert via.startswith("the launch directory")


def test_discovery_home_clone(checkout_factory, tmp_path: Path,
                              monkeypatch):
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)
    root = checkout_factory()
    # the home rung answers when the clone sits directly under the
    # (fake) home directory
    r, i, via = floor.discover(home=root, cwd=tmp_path / "empty")
    assert (r, via) == (root, "~/SOLPS-ITER")
    assert i == root / "SOLPS-ITER"


def test_discovery_loud_stop_lists_the_ladder(checkout_factory,
                                              tmp_path: Path,
                                              monkeypatch):
    checkout_factory()  # exists under tmp_path/repos, never on the cwd chain
    empty_home = tmp_path / "home"
    empty_home.mkdir()
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)
    with pytest.raises(floor.FloorError) as exc:
        floor.discover(cwd=tmp_path / "empty", home=empty_home)
    text = str(exc.value)
    assert str(floor.REPOS_ENV) in text
    assert "~/SOLPS-ITER" in text
    assert "git clone --recurse-submodules" in text


def test_discovery_recorded_root_answers_from_any_directory(
        checkout_factory, tmp_path: Path, monkeypatch):
    # the install-time fact: setup wrote the root beside the index;
    # a service or CLI started anywhere resolves the corpus through it
    root = checkout_factory(optional=("SOLPS-GUI",))
    home = tmp_path / "home"
    floor.record_root(root, share=home / ".local" / "share" / "askthedocs")
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)
    r, i, via = floor.discover(cwd=tmp_path / "unrelated", home=home)
    assert (r, i) == (root, root / "SOLPS-ITER")
    assert via.startswith("the recorded root")


def test_discovery_recorded_root_outranks_home_clone(
        checkout_factory, tmp_path: Path, monkeypatch):
    # the record is the newer install-time fact than ~/SOLPS-ITER
    root = checkout_factory(base="repos")
    home = tmp_path / "home"
    home.mkdir()
    # a DIFFERENT checkout sits directly under the fake home
    home_clone = home / "SOLPS-ITER"
    home_clone.mkdir(parents=True)
    (home_clone / ".gitmodules").write_text("[submodule \"Eirene\"]\n"
                                            "\tpath = modules/Eirene\n",
                                            encoding="utf-8")
    (home_clone / "modules").mkdir()
    floor.record_root(root, share=home / ".local" / "share" / "askthedocs")
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)
    r, _i, via = floor.discover(cwd=tmp_path / "unrelated", home=home)
    assert r == root
    assert via.startswith("the recorded root")


def test_discovery_launch_directory_outranks_the_record(
        checkout_factory, tmp_path: Path, monkeypatch):
    # standing inside a checkout beats the record (dev-world freshness)
    recorded_root = checkout_factory(base="repos-recorded")
    live_root = checkout_factory(base="repos-live")
    home = tmp_path / "home"
    floor.record_root(recorded_root,
                      share=home / ".local" / "share" / "askthedocs")
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)
    r, _i, via = floor.discover(cwd=live_root / "SOLPS-ITER", home=home)
    assert r == live_root
    assert via.startswith("the launch directory")


def test_discovery_stale_record_falls_through(checkout_factory,
                                              tmp_path: Path,
                                              monkeypatch):
    # a record pointing at a moved/deleted corpus is never trusted
    home = tmp_path / "home"
    share = home / ".local" / "share" / "askthedocs"
    share.mkdir(parents=True)
    (share / floor.RECORD_NAME).write_text(
        str(tmp_path / "gone" / "long" / "ago") + "\n", encoding="utf-8")
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)
    with pytest.raises(floor.FloorError) as exc:
        floor.discover(cwd=tmp_path / "empty", home=home)
    assert "the recorded root" in str(exc.value)  # named in the tried list


def test_setup_records_the_repos_root(indexable_checkout, tmp_path: Path,
                                       capsys):
    # the e2e: run_setup writes the install-time fact beside the
    # index it builds (freshness runs refresh it too)
    from askthedocs import setup as setup_mod
    share = tmp_path / "share"
    setup_mod.run_setup(indexable_checkout / "SOLPS-ITER", share=share)
    record = share / floor.RECORD_NAME
    assert record.is_file()
    assert record.read_text(encoding="utf-8").strip() == \
        str(indexable_checkout.resolve())


def test_explicit_path_that_is_not_a_checkout(tmp_path: Path):
    bare = tmp_path / "bare"
    bare.mkdir()
    with pytest.raises(floor.FloorError) as exc:
        floor.discover(bare)
    assert ".gitmodules" in str(exc.value)


def test_check_floor_one_call(checkout_factory):
    root = checkout_factory(optional=("SOLPS-GUI",))
    report = floor.check_floor(root / "SOLPS-ITER")
    assert report.ok
    assert report.via == "the path given to setup"
