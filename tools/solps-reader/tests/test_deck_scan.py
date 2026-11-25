"""The deck scan: what it reads, what it refuses, what it skips, what
it counts as commented out.

The scan mirrors the solver's own deck read: a switch line carries a
quoted name then a value (quoted keeps its blanks, unquoted runs to
the first blank, the rest of the line is ignored). A line whose quote
never closes, or whose name carries no value, is a line the solver
itself stops on: there is no correct reading to recover, so the scan
skips the line and names it, and the good lines around it still read.
A quoted name starting with '#' is the deck author's commented-out
spelling: the solver stores it under the hashed name and no consumer
ever queries it, so the scan reads it with the same two-token read
and records it in its own group, never as a set switch. A VALUE
starting with '#' is not that spelling: it stays a visible set switch
(a numeric read of it stops the solver at startup, so the line has
diagnostic value). A file with no terminator line at all is a pure
switch list from an older version, not a deck: the scan refuses it by
name and the caller catalogs the run without a switch set.

Everything here is synthetic and standalone. The sweep test walks
every deck file the test tree carries, so a new deck fixture fails
the suite until its expected outcome is ruled on: nothing can look
like a miss by omission.
"""

from __future__ import annotations

import re
import sys
from pathlib import Path

import pytest

CATALOG = Path(__file__).resolve().parents[1] / "catalog"
sys.path.insert(0, str(CATALOG))
from build_switchsets import parse_deck  # noqa: E402

FIXTURES = Path(__file__).resolve().parent / "fixtures"


# ------------------------------------------------------------- line units

def test_quoted_value_keeps_its_blanks_verbatim() -> None:
    switches, skipped, commented = parse_deck("*endphy\n'b2nv' '  1.5  '\n")
    assert switches == {"b2nv": "1.5"}
    assert skipped == []
    assert commented == {}


def test_unquoted_value_runs_to_the_first_blank() -> None:
    switches, skipped, commented = parse_deck(
        "*endphy\n'b2nv' 2.5e-7 # note\n")
    assert switches == {"b2nv": "2.5e-7"}
    assert skipped == []
    assert commented == {}


def test_the_last_occurrence_of_a_switch_wins() -> None:
    switches, skipped, commented = parse_deck(
        "*endphy\n'b2nv' '1'\n'b2nv' '2'\n")
    assert switches == {"b2nv": "2"}
    assert skipped == []
    assert commented == {}


def test_comment_and_non_switch_lines_are_ignored() -> None:
    switches, skipped, commented = parse_deck(
        "* a comment\n"
        "! another\n"
        "# a third\n"
        "\n"
        "*endphy\n"
        "not a switch line\n"
        "'b2nv' '1'\n")
    assert switches == {"b2nv": "1"}
    assert skipped == []
    # a line-INITIAL '#' is a comment the solver never reads: it is
    # not the commented-out switch form (that one is quote-led)
    assert commented == {}


def test_a_value_quote_that_never_closes_is_skipped_and_named() -> None:
    """The shape reported from a several-hundred-run database: the run's
    other switches still read, the unreadable line is named with its
    line number and a plain reason."""
    switches, skipped, _ = parse_deck(
        "*endphy\n"
        "'b2eirene' '.true.'\n"
        "'b2ntde' '.true\n"
        "'b2nreal' '1.0'\n")
    assert switches == {"b2eirene": ".true.", "b2nreal": "1.0"}
    assert skipped == [{"line": 3,
                        "reason": "the value opens with a quote that "
                                  "never closes"}]


def test_a_name_quote_that_never_closes_is_skipped_and_named() -> None:
    switches, skipped, _ = parse_deck(
        "*endphy\n"
        "'b2ntde 1.0\n"
        "'b2eirene' '.true.'\n")
    assert switches == {"b2eirene": ".true."}
    assert skipped == [{"line": 2,
                        "reason": "the switch name opens with a quote "
                                  "that never closes"}]


def test_a_switch_name_with_no_value_is_skipped_and_named() -> None:
    switches, skipped, _ = parse_deck(
        "*endphy\n"
        "'b2eirene'\n"
        "'b2ntde' '1.0'\n")
    assert switches == {"b2ntde": "1.0"}
    assert skipped == [{"line": 2,
                        "reason": "no value after the switch name"}]


def test_several_unreadable_lines_are_each_named() -> None:
    switches, skipped, _ = parse_deck(
        "*endphy\n"
        "'b2one'\n"
        "'b2two' 'ok'\n"
        "'b2three 1\n"
        "'b2four' 'ok'\n"
        "'b2five' 'brok\n")
    assert switches == {"b2two": "ok", "b2four": "ok"}
    assert [s["line"] for s in skipped] == [2, 4, 6]


def test_a_file_without_the_terminator_refuses_by_name() -> None:
    """A pure switch list from an older version is not a deck: the scan
    refuses it (the caller catalogs the run without a switch set)."""
    with pytest.raises(ValueError, match=r"no \*endphy terminator line"):
        parse_deck("'b2nv' '1'\n")


# ------------------------------------------------- the commented-out rule

def test_a_quoted_name_starting_with_hash_is_commented_out() -> None:
    """The field shape, verbatim: the '#' rides inside the name quotes,
    a trailing note follows the value. The line never becomes a set
    switch, a skip, or an unknown name."""
    switches, skipped, commented = parse_deck(
        "*endphy\n"
        "'#b2stbr_eir_src_nhist'           '1'   "
        "running average on nhist(=100) time steps\n"
        "'b2eirene' '.true.'\n")
    assert switches == {"b2eirene": ".true."}
    assert skipped == []
    assert commented == {"#b2stbr_eir_src_nhist": "1"}


def test_a_commented_out_name_may_carry_an_unquoted_value() -> None:
    switches, skipped, commented = parse_deck(
        "*endphy\n'#b2ntde' 2.5e-7\n")
    assert switches == {}
    assert skipped == []
    assert commented == {"#b2ntde": "2.5e-7"}


def test_a_value_starting_with_hash_stays_a_set_switch() -> None:
    """The '#' on the VALUE is not a commented-out spelling: the solver
    stores the value, and a numeric read of it stops the run at
    startup, so the line stays visible with its literal value."""
    switches, skipped, commented = parse_deck(
        "*endphy\n"
        "'b2nreal' '#1.5'\n"
        "'b2ntde' #2\n")
    assert switches == {"b2nreal": "#1.5", "b2ntde": "#2"}
    assert skipped == []
    assert commented == {}


def test_the_plain_and_hashed_spellings_are_two_switches() -> None:
    """The solver stores them under different keys: one active, one
    inert. The scan keeps the same split."""
    switches, skipped, commented = parse_deck(
        "*endphy\n'#b2nv' '9'\n'b2nv' '1'\n")
    assert switches == {"b2nv": "1"}
    assert skipped == []
    assert commented == {"#b2nv": "9"}


def test_the_last_occurrence_of_a_commented_out_switch_wins() -> None:
    switches, skipped, commented = parse_deck(
        "*endphy\n'#b2nv' '1'\n'#b2nv' '2'\n")
    assert switches == {}
    assert commented == {"#b2nv": "2"}


def test_a_commented_out_name_with_an_unreadable_value_is_a_skip() -> None:
    """An unreadable line is a defect whatever its name form: the
    solver's own read stops there, so the skip-and-name path wins."""
    switches, skipped, commented = parse_deck(
        "*endphy\n'#b2ntde' 'brok\n")
    assert switches == {}
    assert commented == {}
    assert skipped == [{"line": 2,
                        "reason": "the value opens with a quote that "
                                  "never closes"}]


# ------------------------------------------------------ the fixture sweep

def _deck_name(name: str) -> bool:
    return name.startswith("b2mn.") and (
        name.startswith("b2mn.dat") or name.endswith(".dat"))


#: every deck the test tree carries, pinned to its outcome: switches
#: read, lines skipped, switches commented out, or the named refusal.
#: A deck file that is not listed here fails the sweep; so does a
#: listed deck whose outcome changes.
EXPECTED = {
    "decks/b2mn.dat": (
        {"b2eirene": ".true.", "b2ntde": "2.0", "b2ntab":
         "value with blanks", "b2nnote": "T", "b2nreal": "2.5e-7"},
        [], {}),
    "decks/b2mn.value-quote-never-closes.dat": (
        {"b2eirene": ".true.", "b2nreal": "1.0"},
        [{"line": 5, "reason": "the value opens with a quote that "
                               "never closes"}],
        {}),
    "decks/b2mn.name-quote-never-closes.dat": (
        {"b2eirene": ".true."},
        [{"line": 3, "reason": "the switch name opens with a quote "
                               "that never closes"}],
        {}),
    "decks/b2mn.no-value.dat": (
        {"b2ntde": "1.0"},
        [{"line": 3, "reason": "no value after the switch name"}],
        {}),
    "decks/b2mn.no-endphy.dat": "refused",
    "decks/b2mn.commented-out.dat": (
        {"b2eirene": ".true.", "b2nreal": "2.5e-7"},
        [],
        {"#b2stbr_eir_src_nhist": "1", "#b2ntde": "3.0"}),
    "decks/b2mn.value-hash.dat": (
        {"b2nreal": "#1.5", "b2ntde": "#2"}, [], {}),
    "decks/b2mn.line-initial-hash.dat": (
        {"b2tfhe_mdf": "1", "b2tfhi_mdf": "1", "b2tfnb_mdf": "1"},
        [], {}),
    "gallery/alpha/FAM_X/run_a/b2mn.dat": ({"b2eirene": ".true."}, [], {}),
    "gallery/alpha/FAM_X/run_b/b2mn.dat": ({"b2eirene": ".true."}, [], {}),
    "gallery/beta/FAM_X/run_c/b2mn.dat": ({"b2eirene": ".true."}, [], {}),
}


def test_every_deck_in_the_tree_reads_or_names_its_skips() -> None:
    found = {p.relative_to(FIXTURES).as_posix()
             for p in FIXTURES.rglob("*")
             if p.is_file() and _deck_name(p.name)}
    assert found == set(EXPECTED), (
        "every deck fixture must be pinned here; new fixtures are "
        "ruled on by adding their expected outcome")
    for rel, expected in sorted(EXPECTED.items()):
        text = (FIXTURES / rel).read_bytes().decode("latin-1")
        if expected == "refused":
            with pytest.raises(ValueError,
                               match=r"no \*endphy terminator line"):
                parse_deck(text)
            continue
        want_switches, want_skips, want_commented = expected
        switches, skipped, commented = parse_deck(text)
        assert switches == want_switches, rel
        assert skipped == want_skips, rel
        assert commented == want_commented, rel


def test_skips_carry_nothing_but_line_number_and_reason() -> None:
    """The skip record stays plain data: a line number and a reason a
    person can read. No paths, no raw bytes, nothing else to maintain."""
    text = "*endphy\n'b2nv' 'brok\n"
    _, skipped, _ = parse_deck(text)
    (record,) = skipped
    assert set(record) == {"line", "reason"}
    assert re.fullmatch(r"[ -~]+", record["reason"])
