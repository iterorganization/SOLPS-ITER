"""Chunk-store discovery and validation — the delivery ladder.

The chunk store (one database + its build manifest) is built locally,
once, by ``askthedocs setup`` from the repositories on the machine;
nothing ships pre-built. Every read face — CLI, service, MCP —
locates it through the SAME fixed ladder, never through
machine-specific knowledge:

1. ``ASKTHEDOCS_DB`` environment variable — explicit override,
   always wins, honored VERBATIM (an absent path is reported by the
   normal open path, never silently swapped);
2. ``./askthedocs-db/askthedocs.db`` — relative to the launch
   directory;
3. the index home: ``~/.local/share/askthedocs/`` by default,
   where ``setup`` writes it (install once, use from anywhere);
   ``--home`` or ``$ASKTHEDOCS_HOME`` moves that whole directory
   (the database, the manifest, and every companion file together)
   to a filesystem with room, the mirror of solps-reader's
   ``$SOLPS_READER_HOME``.

A path handed in EXPLICITLY by the caller bypasses the ladder and the
validation: the caller owns what it points at (the same per-call
discipline as pointing a reader at one file).

Artifact DISCOVERY (steps 2-3) validates what it finds. Identity: the
file must be an askthedocs chunk store (its ``chunks`` /
``chunks_fts`` tables). Provenance: the build manifest
(``build_summary.json`` beside the database) must be present and
carry the schema id this package expects. A candidate that exists but
fails validation raises immediately — a broken artifact in a ladder
slot is reported, never silently skipped in favor of an older copy
further down. When no candidate exists, the failure is loud, lists
every accepted placement, and names ``setup`` as the fix; when the
home is redirected while an index sits unread in the default
location, the refusal names that index too.
"""

from __future__ import annotations

import json
import os
from askthedocs._sqlite import sqlite3
from pathlib import Path

# Environment variable naming the store explicitly (ladder step 1).
DB_ENV = "ASKTHEDOCS_DB"

# Environment variable moving the index home wholesale (ladder step
# 3's directory): the database, the manifest, and every companion
# file travel together (the mirror of $SOLPS_READER_HOME).
HOME_ENV = "ASKTHEDOCS_HOME"

# File names of the shipped data artifact (db + manifest travel together).
DB_NAME = "askthedocs.db"
SUMMARY_NAME = "build_summary.json"

# Schema id of the build manifest this package reads.
BUILD_SCHEMA = "askthedocs-build/1"

# Tables every chunk store carries (identity check).
_STORE_TABLES = frozenset({"chunks", "chunks_fts"})


class StoreValidationError(ValueError):
    """A ladder candidate exists but is not a valid store artifact."""


def user_share() -> Path:
    """Ladder step 3's default: the per-user install-once location
    (where ``setup`` writes the index it builds)."""
    return Path.home() / ".local" / "share" / "askthedocs"


# The per-process override set once per CLI invocation (the --home
# flag); set OR cleared on every call so nothing leaks between
# in-process callers (the reader's set_catalog_root pattern).
_index_home_override: Path | None = None


def set_index_home(path: Path | str | None) -> None:
    """Set or clear this process's index-home override (``--home``)."""
    global _index_home_override
    _index_home_override = (None if path is None
                            else Path(path).expanduser())


def index_home() -> Path:
    """Ladder step 3's directory: the ``--home`` override, then
    ``$ASKTHEDOCS_HOME`` (an empty value counts as unset), then the
    per-user share.  Everything the index owns derives from here."""
    if _index_home_override is not None:
        return _index_home_override
    env = os.environ.get(HOME_ENV)
    if env:
        return Path(env).expanduser()
    return user_share()


def index_home_redirected() -> bool:
    """True when the index home is not the per-user default (the
    notices and the orphan note key off this)."""
    return index_home() != user_share()


def candidate_paths() -> list[tuple[Path, str]]:
    """The artifact-discovery steps, in resolution order.

    (path, placement description); the environment overrides are NOT
    candidates: ``$ASKTHEDOCS_DB`` is honored verbatim before any
    discovery runs, and ``$ASKTHEDOCS_HOME`` moves step 3's directory
    wholesale.
    """
    return [
        (Path.cwd() / "askthedocs-db" / DB_NAME,
         "./askthedocs-db/ beside your launch directory"),
        (index_home() / DB_NAME,
         "the index home (~/.local/share/askthedocs/ by default; "
         "--home / $ASKTHEDOCS_HOME moves it wholesale)"),
    ]


def validate_store(path: Path) -> str:
    """Validate one store location; return ``"current"`` or raise.

    Raises :class:`FileNotFoundError` when nothing exists at *path*,
    and :class:`StoreValidationError` for a wrong artifact (not a
    chunk store), a missing build manifest (incomplete artifact set),
    or a manifest whose schema id is not what this package reads
    (stale or foreign artifact) — every message names the fix.
    """
    if not path.is_file():
        raise FileNotFoundError(f"chunk store not found: {path}")
    try:
        conn = sqlite3.connect(f"file:{path}?mode=ro", uri=True)
        try:
            tables = {
                row[0] for row in conn.execute(
                    "SELECT name FROM sqlite_master WHERE type = 'table'")
            }
            if not _STORE_TABLES <= tables:
                raise sqlite3.DatabaseError(
                    "missing the chunks/chunks_fts tables; wrong file in "
                    "the askthedocs-db location?")
            # an FTS5-less SQLite opens the file but cannot touch the
            # search tables: fail HERE, named, not at first query
            conn.execute("SELECT chunk_id FROM chunks_fts LIMIT 1")
        finally:
            conn.close()
    except sqlite3.OperationalError as exc:
        raise StoreValidationError(
            f"this Python's SQLite lacks the FTS5 module ({exc}); the "
            "store needs an SQLite with FTS5: without any administrator, "
            "'pip install pysqlite3-binary' provides one (a complete "
            "SQLite, installed automatically with askthedocs on Linux "
            "x86_64); alternatively use a Python built with FTS5 "
            "(standard python.org installers have it); validation "
            f"stopped at {path}") from None
    except sqlite3.DatabaseError as exc:
        raise StoreValidationError(
            f"not an askthedocs chunk store: {path} ({exc})") from None
    manifest_path = path.parent / SUMMARY_NAME
    if not manifest_path.is_file():
        raise StoreValidationError(
            f"incomplete index artifact: {SUMMARY_NAME} is missing "
            f"beside {path.name}; rebuild the index with "
            "`askthedocs setup --force`")
    try:
        manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
    except ValueError as exc:
        raise StoreValidationError(
            f"unreadable build manifest {manifest_path}: {exc}; "
            "rebuild the index with `askthedocs setup --force`") from None
    schema = manifest.get("schema")
    if schema != BUILD_SCHEMA:
        raise StoreValidationError(
            f"wrong or stale index artifact: manifest schema is "
            f"{schema!r}, this askthedocs reads {BUILD_SCHEMA!r}; "
            "rebuild the index with `askthedocs setup --force`")
    return "current"


def resolve_db(explicit: Path | str | None = None) -> Path:
    """Return the chunk-store path per the ladder.

    An explicit *explicit* path, or a set ``ASKTHEDOCS_DB``, wins
    VERBATIM — no discovery, no validation; the caller owns what it
    named (an absent path is used as-is and the normal open path
    reports it, never a silent fallback).  Only when neither is given
    does artifact discovery run: the first existing candidate is
    validated and returned, one that exists but is invalid raises
    immediately (never skipped in favor of an older copy), and no
    candidate at all raises the loud failure listing every accepted
    placement with its copy-paste fix.
    """
    if explicit is not None:
        return Path(explicit)
    env = os.environ.get(DB_ENV)
    if env:
        return Path(env)
    existing = [(path, where)
                for path, where in candidate_paths() if path.is_file()]
    if not existing:
        home = index_home()
        lines = [
            "no askthedocs index on this machine yet: it is built "
            "locally from the repositories, once, at setup time. "
            "Accepted placements, in resolution order:",
            "",
            f"  1. ${DB_ENV} environment variable: export "
            f"{DB_ENV}=/full/path/to/{DB_NAME}",
            f"  2. ./askthedocs-db/{DB_NAME} beside the directory you "
            "launch from",
        ]
        if index_home_redirected():
            lines.append(
                f"  3. {home / DB_NAME} (the index home, moved by "
                f"--home / ${HOME_ENV})")
            share_db = user_share() / DB_NAME
            if share_db.is_file():
                lines += [
                    "",
                    f"note: an index exists at {share_db} and is not "
                    f"read: the index home points at {home}. Drop the "
                    f"redirect (unset {HOME_ENV}, no --home) to read "
                    "that index, or move the index directory into "
                    "the home.",
                ]
            fix = ("fix: run `askthedocs setup` (it builds into the "
                   f"index home {home} while the redirect is active; "
                   "it needs a SOLPS-ITER checkout with initialized "
                   "submodules)")
        else:
            lines.append(
                f"  3. ~/.local/share/askthedocs/{DB_NAME} (where "
                "setup writes it: install once, use from anywhere)")
            fix = ("fix: run `askthedocs setup` (it needs a SOLPS-ITER "
                   "checkout with initialized submodules)")
        lines += ["", fix]
        raise FileNotFoundError("\n".join(lines))
    path, _where = existing[0]
    validate_store(path)  # a broken first candidate is reported, not skipped
    return path
