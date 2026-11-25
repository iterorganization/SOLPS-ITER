"""Per-leg staleness verdicts — the truth layer.

:mod:`askthedocs.state` diffs the RECORDED input state against the
ON-DISK one at file granularity; this module rolls that diff up to
LEGS — the same row namespace the corpus modal shows (repository, or
``<repo>/modules/<name>`` for rerouted modules) — and classifies each
leg under the rule:

* **current** — the leg is on disk and every recorded source matches;
* **drifted** — the leg is on disk and disk differs (new / changed /
  REMOVED sources all count: a present leg's disk is the truth, so a
  deletion is drift evidence, never a reason to carry);
* **carried** — the leg is NOT on disk (repository missing, or a
  gitlink-declared submodule never initialized); its recorded sources
  are served verbatim from the index at the pinned commit the row
  already shows.  Carried is an informational state, never drift;
  it KILLS the phantom-drift bug: sources absent because
  their whole leg is absent read carried, not "removed".
* **absent** — an OPTIONAL leg that was not on disk at build time, so
  nothing of it was ever indexed (cloned means indexed; absent means
  named on every face as a place the answer might still be).  Like
  carried it is informational, never drift; unlike carried there is
  nothing recorded under it to serve.

The aggregate keeps the flat evidence lists (``<kind> <repo>/<path>``
labels) but restricted to PRESENT legs — the drift a rebuild can act
on.  Leg-level carry is the Phase-2 build rule's decision input.
"""

from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Iterable, Sequence

from askthedocs import corpus, state

# leg verdicts
CURRENT = "current"
DRIFTED = "drifted"
CARRIED = "carried"
# fourth state: an optional leg that was NOT on disk at build time,
# so nothing of it was ever indexed (informational, never drift, and
# never applicable to the mandatory repository)
ABSENT = "absent"

# the legs whose absence from a machine is tolerated: cloned means
# indexed; absent means named on every face as a place the answer
# might still be
OPTIONAL_LEGS = ("SOLPS-GUI", "SOLPS-Tutorials")

Row = state.Row


def leg_name(repo: str, path: str) -> str:
    """The modal row a source belongs to: the repo itself, or the
    immediate module directory for ``modules/<name>/…`` paths — the
    same namespace ``repo_heads`` keys and the corpus modal render."""
    parts = path.split("/")
    if repo == "SOLPS-ITER" and len(parts) >= 2 and parts[0] == "modules":
        return f"{repo}/modules/{parts[1]}"
    return repo


def _rows_by_leg(rows: Iterable[Row]) -> dict[str, list[Row]]:
    legs: dict[str, list[Row]] = {}
    for kind, repo, path, sha in rows:
        legs.setdefault(leg_name(repo, path), []).append((kind, repo,
                                                          path, sha))
    return legs


def leg_present(name: str, repos: dict[str, Path],
                submodule_states: dict[str, dict[str, bool]]) -> bool:
    """Is this leg's truth on disk?  A repository leg is present when
    its directory exists; a module leg is ABSENT when git declares it
    as a submodule that was never initialized (a gitlink with no
    checkout — stray files under it were never walked), otherwise
    present when its directory exists."""
    repo, _, sub_path = name.partition("/")
    base = repos.get(repo)
    if base is None or not base.is_dir():
        return False
    if not sub_path:
        return True
    declared = submodule_states.get(repo, {})
    if sub_path in declared and not declared[sub_path]:
        return False
    return (base / sub_path).is_dir()


@dataclass
class LegVerdict:
    """One modal row's staleness verdict with its evidence counts."""

    name: str
    verdict: str
    new: int = 0
    changed: int = 0
    removed: int = 0
    carried_sources: int = 0

    def label(self, counts: dict[str, int] | None = None) -> str:
        """One-line rendering for the CLI startup/status lines."""
        if self.verdict == CARRIED:
            return (f"{self.name}  carried: not on disk "
                    f"({self.carried_sources} sources served at the "
                    f"pinned commit)")
        if self.verdict == ABSENT:
            return (f"{self.name}  absent: not indexed on this machine "
                    f"(optional leg; clone it beside SOLPS-ITER and "
                    f"rebuild to index it)")
        if self.verdict == CURRENT:
            return f"{self.name}  current"
        return (f"{self.name}  drifted "
                f"({self.new} new, {self.changed} changed, "
                f"{self.removed} removed)")


@dataclass
class Verdicts:
    """The whole rollup: per-leg verdicts plus the flat, present-leg
    drift evidence the script gates keep consuming."""

    legs: list[LegVerdict] = field(default_factory=list)
    new: list[str] = field(default_factory=list)
    changed: list[str] = field(default_factory=list)
    removed: list[str] = field(default_factory=list)
    repos_present: int = 0

    @property
    def drifted_legs(self) -> list[str]:
        return [leg.name for leg in self.legs if leg.verdict == DRIFTED]

    @property
    def carried_legs(self) -> list[str]:
        return [leg.name for leg in self.legs if leg.verdict == CARRIED]

    @property
    def absent_legs(self) -> list[str]:
        return [leg.name for leg in self.legs if leg.verdict == ABSENT]

    def summary(self) -> str:
        """The one-liner: what the startup line and the band
        headline from."""
        carried = len(self.carried_legs)
        absent = len(self.absent_legs)
        tail = ", ".join(s for s, n in (
            (f"{carried} legs carried", carried),
            (f"{absent} legs absent (not indexed here)", absent)) if n)
        if not any((self.new, self.changed, self.removed)):
            return f"index current{'; ' + tail if tail else ''}"
        return (f"drift: {len(self.new)} new, {len(self.changed)} changed, "
                f"{len(self.removed)} removed "
                f"({len(self.drifted_legs)} legs drifted, "
                f"{len(self.carried_legs)} legs carried)")


def leg_verdicts(recorded: Sequence[Row], current: Sequence[Row],
                 repos: dict[str, Path],
                 submodule_states: dict[str, dict[str, bool]] | None = None
                 ) -> Verdicts:
    """Roll the two input states up to per-leg verdicts.

    ``submodule_states`` defaults to a live read via
    :func:`corpus.submodule_state` — pass an explicit mapping to test
    leg logic without git (keys are repo names, values map each
    declared submodule path to its initialized flag).
    """
    if submodule_states is None:
        submodule_states = corpus.submodule_state(repos)
    out = Verdicts(repos_present=sum(
        1 for base in repos.values() if base.is_dir()))
    recorded_legs = _rows_by_leg(recorded)
    current_legs = _rows_by_leg(current)
    for name in sorted(set(recorded_legs) | set(current_legs)):
        if not leg_present(name, repos, submodule_states):
            # absent leg: informational carry, never drift — and the
            # disk rows under it (stray files in an uninitialized
            # submodule dir) are ignored, exactly as the scan walks
            # only initialized checkouts
            out.legs.append(LegVerdict(
                name=name, verdict=CARRIED,
                carried_sources=len(recorded_legs.get(name, ()))))
            continue
        rec = {(r[0], r[1], r[2]): r[3] for r in recorded_legs.get(name, ())}
        cur = {(r[0], r[1], r[2]): r[3] for r in current_legs.get(name, ())}
        leg = LegVerdict(name=name, verdict=CURRENT)
        for key in sorted(set(rec) | set(cur)):
            label = f"{key[0]} {key[1]}/{key[2]}"
            if key not in rec:
                leg.new += 1
                out.new.append(label)
            elif key not in cur:
                leg.removed += 1
                out.removed.append(label)
            elif rec[key] != cur[key]:
                leg.changed += 1
                out.changed.append(label)
        if any((leg.new, leg.changed, leg.removed)):
            leg.verdict = DRIFTED
        out.legs.append(leg)
    # fourth state: an optional leg that neither the recorded state
    # nor the disk walk has anything of — not on disk at build time,
    # never indexed.  Informational: it appears as a place the answer
    # might still be.  (A leg cloned after the build reads DRIFTED via
    # its new on-disk sources instead, which is the actionable truth.)
    seen = {leg.name for leg in out.legs}
    for name in OPTIONAL_LEGS:
        if name in seen:
            continue
        if not leg_present(name, repos, submodule_states):
            out.legs.append(LegVerdict(name=name, verdict=ABSENT))
    out.legs.sort(key=lambda leg: leg.name)
    return out
