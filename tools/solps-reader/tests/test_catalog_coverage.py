"""COVERAGE.md is pinned to the corpus: every file the example runs
carry is ruled on by the map — consumed, displayed, or omitted with
a reason.  A new kind of file in a run folder fails this test until
the map rules on it, so nothing can look like a miss by omission.
"""

from __future__ import annotations

import fnmatch
import json
import re
from pathlib import Path

import pytest

CATALOG = Path(__file__).resolve().parents[1] / "catalog"


def _rules() -> list[dict]:
    text = (CATALOG / "COVERAGE.md").read_text(encoding="utf-8")
    m = re.search(r"```json coverage-rules\n(.*?)```", text, re.S)
    assert m, "COVERAGE.md lost its coverage-rules block"
    rules = json.loads(m.group(1))
    assert rules and all("pattern" in r and "rule" in r for r in rules)
    return rules


def _examples_root() -> Path | None:
    """The real public corpus in the launch-parent shape; None on a
    machine without it (the test then skips — honestly named)."""
    for parent in Path(__file__).resolve().parents:
        cand = parent / "SOLPS-ITER" / "runs" / "examples"
        if cand.is_dir():
            return cand
    return None


def test_the_rules_block_parses_and_is_unique() -> None:
    rules = _rules()
    pats = [r["pattern"] for r in rules]
    assert len(pats) == len(set(pats)), "duplicate patterns in COVERAGE.md"


@pytest.mark.skipif(_examples_root() is None,
                    reason="no example corpus beside the repo")
def test_every_corpus_file_is_ruled_on() -> None:
    rules = _rules()
    unruly = set()
    for p in sorted(_examples_root().rglob("*")):
        if p.is_dir() or p.name == ".DS_Store":
            continue
        if not any(fnmatch.fnmatchcase(p.name, r["pattern"])
                   for r in rules):
            unruly.add(p.name)
    assert not unruly, (
        "files COVERAGE.md does not rule on (add a rule or a family "
        f"row): {sorted(unruly)}")


def test_every_rule_name_is_explained_in_the_prose() -> None:
    """The machine block and the human tables must speak with one
    voice: each rule name appears in the prose section."""
    text = (CATALOG / "COVERAGE.md").read_text(encoding="utf-8")
    prose = text.split("```json coverage-rules")[0]
    for r in _rules():
        assert r["rule"] in prose or r["rule"] in (
            "iterate", "sidecar", "junk"), (
            f"rule {r['rule']!r} has no prose explanation")


def test_legacy_compatibility_names_are_ruled_on() -> None:
    """The reviewer's field list: the legacy log symlinks and the
    optional compatibility inputs must never look like a miss when a
    database carries them — absence is silent, presence stays ruled
    (the whole list, including the names today's globs happen to
    cover: a future glob narrowing must not reopen the hole)."""
    rules = _rules()
    names = ["b2.log", "b2.log.gz", "fort.21", "fort.22", "fort.33",
             "fort.34", "fort.35", "H2VIBR", "AMMONX", "HYDHEL",
             "METHANE", "SPUTER", "param.dg", "uinput.dg",
             "uinput.trg", "dg.trg", "dg.dgo", "dg.equ", "dg.str"]
    unruly = [n for n in names
              if not any(fnmatch.fnmatchcase(n, r["pattern"])
                         for r in rules)]
    assert not unruly, f"legacy names without a rule: {unruly}"
