"""Index build manifest + staleness detection).

No watchers, no daemons: the DB carries the input state it was built
from, and ``askthedocs status`` re-hashes the repos and diffs the two —
content (sha256) hashes only, never mtimes.  Re-indexing is an
explicit, evidence-based decision; detecting change is cheap.

Two sides, deliberately asymmetric ("Staleness detection
)"):

* **build side** — :func:`build_inputs` records the files the build
  actually CONSUMED: the corpus-manifest entries (corpus.json is the
  gate for documentation sources; a doc not in it was never extracted)
  re-hashed AT BUILD TIME (so the recorded hash is the bytes that were
  extracted, never a stale corpus-scan hash), the Fortran walk,
  and the pinned switch-inventory XMLs. Stored in the
  ``build_manifest`` table inside the DB itself.
* **status side** — :func:`current_inputs` re-walks the repos NOW with
  the same scope rules (corpus walk without the pypdf probe, Fortran
  walk, pinned switch XMLs) and hashes what is on disk.

The diff then reports ``new`` (on disk, not in the build — includes
docs that arrived after the last ``askthedocs corpus``; run it first),
``changed`` (hash mismatch), and ``removed`` (in the build, gone from
disk) — each labeled ``<kind> <repo>/<path>``.

:func:`manifest_sha256` gives one stable identity to an input state
(sha256 over the sorted ``kind\\trepo/path\\tsha256`` lines); its first
8 hex are the "corpus state" the web footer and the status header show.
The switch census) reads only files the Fortran walk already
covers (``modules/B2.5/src`` .F/.F90 ⊂ the walk's .F/.f/.F90/.f90), so
no fourth kind is needed for it.

Doctrine (recorded in the format schema): ``askthedocs build`` is
ALWAYS a full deterministic rebuild — no incremental indexing.
Incremental is where parity drift breeds; revisit only if the corpus
grows ~100x.
"""

from __future__ import annotations

import hashlib
import sqlite3
from pathlib import Path
from typing import Iterable, Sequence

from askthedocs import corpus, fortran, switches

# input families recorded in the build manifest
KIND_CORPUS = "corpus"
KIND_FORTRAN = "fortran"
KIND_SWITCHES = "switches"

# pinned switch-inventory inputs (modules/B2.5/src/documentation/)
SWITCH_INPUTS = (switches.B2INPUT, switches.ENTITIES)

# one build-manifest row: (kind, repo, path, sha256)
Row = tuple[str, str, str, str]


def _hash_if_present(path: Path) -> str | None:
    return corpus.sha256_file(path) if path.is_file() else None


def build_inputs(manifest: dict, repos: dict[str, Path], *,
                 include_fortran: bool = False,
                 include_switches: bool = False) -> list[Row]:
    """The input state a build consumed, hashed at build time.

    The corpus rows follow the corpus manifest's file list — the gate
    every documentation source passes through — but the hashes are
    taken NOW (build time), not copied from the manifest, so the
    recorded state is always the bytes that were actually extracted.
    """
    rows: list[Row] = []
    for record in manifest["files"]:  # sorted (repo, path) — fixed order
        repo, rel = record["repo"], record["path"]
        sha = _hash_if_present(repos[repo] / rel)
        if sha is not None:
            rows.append((KIND_CORPUS, repo, rel, sha))
    if include_switches:
        for rel in SWITCH_INPUTS:
            sha = _hash_if_present(repos["SOLPS-ITER"] / rel)
            if sha is not None:
                rows.append((KIND_SWITCHES, "SOLPS-ITER", rel, sha))
    if include_fortran:
        for path in fortran.walk_paths(repos["SOLPS-ITER"]):
            rows.append((KIND_FORTRAN, "SOLPS-ITER",
                         path.relative_to(repos["SOLPS-ITER"]).as_posix(),
                         corpus.sha256_file(path)))
    rows.sort()
    return rows


def current_inputs(repos: dict[str, Path]) -> list[Row]:
    """The input state on disk NOW — the same scope rules the build
    consumes, walked and hashed fresh (no pypdf probing). A repos
    dict without SOLPS-ITER (the deliberate container profile, or a
    corpus this machine cannot see) contributes no leg inputs — an
    absent leg reads carried by definition, never a crash."""
    rows: list[Row] = []
    for repo, rel, path in corpus.walk_sources(repos):
        rows.append((KIND_CORPUS, repo, rel, corpus.sha256_file(path)))
    iter_repo = repos.get("SOLPS-ITER")
    if iter_repo is not None:
        for rel in SWITCH_INPUTS:
            sha = _hash_if_present(iter_repo / rel)
            if sha is not None:
                rows.append((KIND_SWITCHES, "SOLPS-ITER", rel, sha))
        for path in fortran.walk_paths(iter_repo):
            rows.append((KIND_FORTRAN, "SOLPS-ITER",
                         path.relative_to(iter_repo).as_posix(),
                         corpus.sha256_file(path)))
    rows.sort()
    return rows


def manifest_sha256(rows: Iterable[Row]) -> str:
    """Stable identity of an input state: sha256 over the sorted
    ``kind\\trepo/path\\tsha256`` lines (order-independent input)."""
    digest = hashlib.sha256()
    for kind, repo, path, sha in sorted(rows):
        digest.update(f"{kind}\t{repo}/{path}\t{sha}\n".encode("utf-8"))
    return digest.hexdigest()


def count_by_kind(rows: Iterable[Row]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for kind, *_ in rows:
        counts[kind] = counts.get(kind, 0) + 1
    return dict(sorted(counts.items()))


def read_from_db(db_path: Path) -> list[Row] | None:
    """The DB's own build manifest, or None when there is nothing to
    compare (no DB file, or a pre-DB without the table)."""
    if not Path(db_path).is_file():
        return None
    try:
        conn = sqlite3.connect(f"file:{db_path}?mode=ro", uri=True)
    except sqlite3.Error:
        return None
    try:
        rows = conn.execute(
            "SELECT kind, repo, path, sha256 FROM build_manifest"
        ).fetchall()
    except sqlite3.OperationalError: # no such table — pre-build
        return None
    finally:
        conn.close()
    return [tuple(row) for row in rows]


def diff(recorded: Sequence[Row], current: Sequence[Row]) -> dict[str, list[str]]:
    """Three-way drift report as ``<kind> <repo>/<path>`` labels,
    sorted — content hashes only, never mtimes."""
    rec = {(kind, repo, path): sha for kind, repo, path, sha in recorded}
    cur = {(kind, repo, path): sha for kind, repo, path, sha in current}
    return {
        "new": sorted(f"{kind} {repo}/{path}"
                      for kind, repo, path in cur.keys() - rec.keys()),
        "removed": sorted(f"{kind} {repo}/{path}"
                          for kind, repo, path in rec.keys() - cur.keys()),
        "changed": sorted(f"{kind} {repo}/{path}"
                          for (kind, repo, path), sha in cur.items()
                          if (kind, repo, path) in rec
                          and rec[(kind, repo, path)] != sha),
    }
