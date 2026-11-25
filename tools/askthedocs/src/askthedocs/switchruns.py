"""The catalog switch-set join — runs that set a switch.

askthedocs answers "what does this switch do" (the ``source_switch``
cluster); the run catalog (``../catalog``, the sibling project) answers
"which cataloged run sets it to what".  This module is the RUNTIME-ONLY
join between the two: it reads the catalog's ``out/switchsets.json``
artifact (SwitchJoin ) at REQUEST time and never at askthedocs-build
time — the chunk store stays catalog-free and both repos keep building
independently (the gate that held this until 2026-09-28).

The join key is RULED (confirmed by X. Bonnin, publisher of the Zenodo
examples record the catalog browses): a source_switch citation's
``section`` IS the switch name, and the artifact's ``inverted_index``
maps switch name → ``[{"run", "value"}, …]``.  Lookup is therefore an
EXACT dict key — zero fuzzy matching; a miss is the honest zero state
("no cataloged run sets this switch"), never a search problem.

Honest states (the endpoint surfaces all three, the web panel renders
them verbatim):

* artifact missing        → ``catalog="absent"`` ("catalog not built" —
  the gate's spirit, preserved: no catalog, no pretend join)
* switch set by no run    → ``catalog="built"``, ``runs=[]``
* artifact unreadable/corrupt (e.g. mid-rewrite race with the catalog
  builder) → ``ValueError`` — the service answers 503 rather than
  lying "not built" about a file that exists

Everything rendered is taken from the artifact JSON as-is; the ONE
derived field is ``family`` — the run name's prefix before ``/``
(``ITER_2588_drifts/run_with_drifts`` → ``ITER_2588_drifts``), the same
value the catalog's index.json records as ``run_family``.
"""

from __future__ import annotations

import json
import threading
from dataclasses import dataclass
from pathlib import Path

# the artifact schema this join understands (catalog SwitchJoin )
SCHEMA = "catalog-switchsets/1"

# honest catalog-state labels (rendered by the web panel verbatim)
CATALOG_BUILT = "built"
CATALOG_ABSENT = "absent"


@dataclass(frozen=True)
class SwitchRun:
    """One cataloged run setting the switch — artifact values verbatim
    (plus ``family``, the run-name prefix before ``/``)."""

    run: str
    family: str
    value: str


@dataclass(frozen=True)
class SwitchRuns:
    """The join answer for one switch name."""

    switch: str
    catalog: str  # CATALOG_BUILT | CATALOG_ABSENT
    runs: tuple[SwitchRun, ...]


def default_switchsets() -> Path:
    """<ITER workspace>/catalog/out/switchsets.json — the sibling
    catalog project's artifact, next to the askthedocs repo."""
    return (Path(__file__).resolve().parents[2].parent
            / "catalog" / "out" / "switchsets.json")


class Switchsets:
    """mtime-cached reader over one ``switchsets.json`` artifact.

    One ``stat`` per request; the JSON is parsed only when the file's
    ``(st_mtime_ns, st_size)`` stamp changes (or on first read), so a
    rebuilt catalog is picked up live without per-request parse cost.
    Thread-safe: FastAPI runs sync endpoints in a threadpool, and the
    load takes the lock only around the re-read.
    """

    def __init__(self, path: Path | None = None) -> None:
        self.path = Path(path) if path is not None else default_switchsets()
        self._lock = threading.Lock()
        self._stamp: tuple[int, int] | None = None
        self._index: dict[str, list[dict]] | None = None

    def _load(self) -> dict[str, list[dict]] | None:
        """The inverted index, or None when the artifact is absent.

        Raises ``ValueError`` when the file exists but does not parse
        or does not carry the expected schema — the caller-facing
        signal for "unreadable", kept distinct from "absent"."""
        try:
            stat = self.path.stat()
        except OSError:
            with self._lock:
                self._stamp, self._index = None, None
            return None
        stamp = (stat.st_mtime_ns, stat.st_size)
        with self._lock:
            if stamp == self._stamp and self._index is not None:
                return self._index
        try:
            data = json.loads(self.path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as exc:
            raise ValueError(
                f"switchsets artifact unreadable ({self.path}): {exc}"
            ) from exc
        if data.get("schema") != SCHEMA:
            raise ValueError(
                f"switchsets artifact schema {data.get('schema')!r} != "
                f"{SCHEMA!r} ({self.path})")
        index = data.get("inverted_index")
        if not isinstance(index, dict):
            raise ValueError(
                f"switchsets artifact carries no inverted_index "
                f"({self.path})")
        with self._lock:
            self._stamp, self._index = stamp, index
        return index

    def runs_for(self, switch: str) -> SwitchRuns:
        """The join answer for one switch name — an EXACT key lookup
        (verbatim, zero fuzzy matching). Runs are sorted
        by run name so families group and output is deterministic
        across artifact regenerations."""
        index = self._load()
        if index is None:
            return SwitchRuns(switch=switch, catalog=CATALOG_ABSENT,
                              runs=())
        out = []
        for entry in index.get(switch, []):
            run = str(entry.get("run", ""))
            out.append(SwitchRun(
                run=run,
                family=run.split("/", 1)[0],
                value=str(entry.get("value", "")),
            ))
        out.sort(key=lambda r: r.run)
        return SwitchRuns(switch=switch, catalog=CATALOG_BUILT,
                          runs=tuple(out))
