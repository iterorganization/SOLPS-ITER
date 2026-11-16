"""SQLite chunk store).

One database, three tables:

  * ``chunks``   — provenance + text, ``chunk_id TEXT PRIMARY KEY``
  * ``chunks_fts`` — FTS5 over the same text, with the provenance
    columns carried UNINDEXED so one MATCH query returns a full hit
    (search itself lands in ; the table exists from day one so
    every face queries the same artifact).
  * ``build_manifest`` — the input state the DB was built from
): one (kind, repo, path, sha256) row per corpus/code
    source consumed by the build.  ``askthedocs status`` re-hashes the
    repos and diffs against it — content hashes only, never mtimes.

``askthedocs build`` is the only writer and always recreates the database
from scratch doctrine: full deterministic rebuild, no
incremental indexing).  Insertion order is fixed — manifest order
(repo, path), then page, then paragraph — so rowids and file bytes are
reproducible; PRAGMA page_size is pinned for the sha256 golden.

chunk_id contract ("sha1(source + page + para-index)"):
sha1 over the three fields joined by U+001F unit separators, so plain
concatenation cannot alias (source "a1" page 2 vs source "a" page 12).
Page is 1-based; para-index is the 0-based position of the paragraph
in the page's paragraph list.  IDs are the join key across every face
(CLI, MCP, web) — stable across rebuilds by construction.
"""

from __future__ import annotations

import hashlib
import sqlite3
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable, Sequence

# pinned for reproducible file bytes sha256 golden)
PAGE_SIZE = 4096

SCHEMA_STATEMENTS = (
    """
    CREATE TABLE chunks (
        chunk_id TEXT PRIMARY KEY,
        source   TEXT NOT NULL,
        cluster  TEXT NOT NULL,
        section  TEXT,
        page     INTEGER,
        text     TEXT NOT NULL
    )
    """,
    """
    CREATE VIRTUAL TABLE chunks_fts USING fts5(
        text, source UNINDEXED, cluster UNINDEXED,
        section UNINDEXED, page UNINDEXED, chunk_id UNINDEXED
    )
    """,
    """
    CREATE TABLE build_manifest (
        kind   TEXT NOT NULL,
        repo   TEXT NOT NULL,
        path   TEXT NOT NULL,
        sha256 TEXT NOT NULL,
        PRIMARY KEY (kind, repo, path)
    )
    """,
)


@dataclass(frozen=True)
class Chunk:
    """One citable unit of corpus text with its provenance."""

    chunk_id: str
    source: str
    cluster: str
    section: str | None
    page: int | None
    text: str


def make_chunk_id(source: str, page: int | None, para_index: int) -> str:
    """Stable chunk ID: sha1(source \x1f page \x1f para-index)."""
    key = "\x1f".join((source, "" if page is None else str(page), str(para_index)))
    return hashlib.sha1(key.encode("utf-8")).hexdigest()


def create(path: Path) -> sqlite3.Connection:
    """Fresh chunk-store database at *path* (existing file replaced)."""
    path = Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    if path.exists():
        path.unlink()
    conn = sqlite3.connect(str(path))
    conn.row_factory = sqlite3.Row
    conn.execute(f"PRAGMA page_size = {PAGE_SIZE}")
    for statement in SCHEMA_STATEMENTS:
        conn.execute(statement)
    return conn


def insert_chunks(conn: sqlite3.Connection, chunks: Sequence[Chunk],
                  on_batch=None) -> None:
    """Insert chunks in the given (fixed) order into both tables.
    *on_batch*, when given, is called after every inserted batch with
    the batch's chunk count (the write stage's heartbeat). Batching
    never reorders anything: each table receives the same rows in the
    same order inside the same single transaction, so the store's
    bytes are exactly what the unbatched insert produced."""
    batch_size = 1000
    for start in range(0, len(chunks), batch_size):
        batch = chunks[start:start + batch_size]
        conn.executemany(
            "INSERT INTO chunks (chunk_id, source, cluster, section, page, text)"
            " VALUES (?, ?, ?, ?, ?, ?)",
            [(c.chunk_id, c.source, c.cluster, c.section, c.page, c.text)
             for c in batch],
        )
        conn.executemany(
            "INSERT INTO chunks_fts (text, source, cluster, section, page, chunk_id)"
            " VALUES (?, ?, ?, ?, ?, ?)",
            [(c.text, c.source, c.cluster, c.section, c.page, c.chunk_id)
             for c in batch],
        )
        if on_batch is not None:
            on_batch(len(batch))
    conn.commit()


def count_chunks(conn: sqlite3.Connection) -> int:
    return int(conn.execute("SELECT COUNT(*) FROM chunks").fetchone()[0])


def insert_manifest(conn: sqlite3.Connection,
                    rows: Sequence[tuple[str, str, str, str]]) -> None:
    """Insert the build-manifest rows — (kind, repo, path,
    sha256) tuples — in sorted order (fixed, so the file bytes stay
    reproducible)."""
    conn.executemany(
        "INSERT INTO build_manifest (kind, repo, path, sha256)"
        " VALUES (?, ?, ?, ?)",
        sorted(rows),
    )
    conn.commit()


def chunk_id_set(conn: sqlite3.Connection) -> set[str]:
    """All chunk_ids (order-independent rebuild comparison)."""
    return {row[0] for row in conn.execute("SELECT chunk_id FROM chunks")}


def sources(conn: sqlite3.Connection) -> set[str]:
    return {row[0] for row in conn.execute("SELECT DISTINCT source FROM chunks")}


def iter_chunks(conn: sqlite3.Connection) -> Iterable[sqlite3.Row]:
    return conn.execute(
        "SELECT chunk_id, source, cluster, section, page, text"
        " FROM chunks ORDER BY rowid"
    )


def read_carry_chunks(path: Path, legs: set[str]
                      ) -> tuple[dict[str, list[Chunk]], list[Chunk]]:
    """A previous store's chunks under ABSENT legs, for a carried
    rebuild.

    Corpus and Fortran chunks are grouped by source with the stored
    rowid order preserved — the order a fresh extraction of the same
    bytes produced, which the A/B identity assertion relies on.  The
    synthesized switch inventory (cluster ``source_switch``) names no
    repository, so its chunks are returned whole; the caller decides
    whether they belong (B2.5 leg carried)."""
    from askthedocs import verdicts
    conn = sqlite3.connect(f"file:{path}?mode=ro", uri=True)
    conn.row_factory = sqlite3.Row
    try:
        by_source: dict[str, list[Chunk]] = {}
        switch_chunks: list[Chunk] = []
        for row in conn.execute(
                "SELECT chunk_id, source, cluster, section, page, text"
                " FROM chunks ORDER BY rowid"):
            chunk = Chunk(chunk_id=row["chunk_id"], source=row["source"],
                          cluster=row["cluster"], section=row["section"],
                          page=row["page"], text=row["text"])
            if row["cluster"] == "source_switch":
                switch_chunks.append(chunk)
                continue
            repo, _, rel = row["source"].partition("/")
            if verdicts.leg_name(repo, rel) in legs:
                by_source.setdefault(row["source"], []).append(chunk)
        return by_source, switch_chunks
    finally:
        conn.close()
