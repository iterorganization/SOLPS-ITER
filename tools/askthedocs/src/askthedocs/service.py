"""FastAPI service over the chunk store) — the Group C face.

Structure ≠ deployment (owner decision 2026-09-23): the chunk store +
``askthedocs.api`` are the persistence and domain layers; this module is a
thin HTTP wrapper over them.  Every route maps to exactly one library
call and adds only HTTP concerns — request validation, status codes,
JSON serialization.  Zero domain logic lives here, so search ranking,
provenance and staleness can never disagree between the CLI, the MCP
tools, the web index and this service: they are the same code.

Routes (OpenAPI auto-generated at /openapi.json, docs at /docs):

- ``GET /search?q=&limit=&cluster=``  → :func:`askthedocs.api.search`
- ``GET /chunk/{chunk_id}``           → :func:`askthedocs.api.get`
- ``GET /status`` → staleness
  (:mod:`askthedocs.state` — re-hashes the corpus, ~1 s on the real
  1,954-source input set; content hashes, never mtimes)
- ``GET /switchruns/{name}`` → the catalog join
  (:mod:`askthedocs.switchruns` — reads the sibling catalog's
  ``out/switchsets.json`` artifact at REQUEST time; the askthedocs build
  never touches ../catalog, so the store stays catalog-free and both
  repos keep building independently)

Status-code contract (mirrors the CLI's exit codes 0/1/2):

- 200 OK — success; /status additionally reports ``"current"``
- 404 Not Found — chunk ID unknown to the store
- 409 Conflict — /status found drift (the cron/hook gate: with
  ``curl --fail`` this exits nonzero exactly like ``askthedocs status``
  exit 1; the body carries the full evidence lists)
- 422 Unprocessable — request validation (empty q, limit out of range)
- 400 Bad Request — query invalid even in the quoted-fallback FTS5
  form, or empty after whitespace strip (library ``ValueError``)
- 503 Service Unavailable — the chunk store does not exist / carries
  no build manifest (run ``askthedocs setup`` first); ALSO /status in the
  docker profile), where the reference repos are deliberately
  not mounted (they are host-side build inputs) — without repos the
  re-hash would see an empty corpus and lie "everything removed", so
  the route refuses with a pointer to host-side ``askthedocs status``;
  and /status WHILE A REBUILD JOB RUNS (the rebuild itself runs as a
  dedicated CHILD PROCESS, but the hash stays this process's work:
  a mid-run verdict would describe a store the landing job is about
  to replace, so the hash refuses until the job lands; the end-of-run
  check is then answered from the job's own result, never a re-hash
  racing the boundary)

Run (see README §service)::

    .venv/bin/python -m askthedocs.service            # 127.0.0.1:8000
    .venv/bin/uvicorn askthedocs.service:app          # same, uvicorn-native

``ASKTHEDOCS_DB`` points the uvicorn route at another store; the database
is only ever opened read-only (never-writer doctrine, ``askthedocs.search``).

**Serving the api-mode web build)**: ``--static DIR`` (or the
``ASKTHEDOCS_STATIC`` env) mounts a built web client at ``/`` AFTER the
API routes, so ``npm run build:api`` output and the API answer from
one origin (the api-mode client's same-origin fetch contract — no
CORS, no second server).  Unset by default: the plain service exposes
only the three API routes, and mounts never appear in /openapi.json.
"""

from __future__ import annotations

import asyncio
import json
import logging
import os
from askthedocs._sqlite import sqlite3
import subprocess
import sys
import threading
import time
from pathlib import Path

from fastapi import (FastAPI, HTTPException, Path as PathParam, Query,
                     Request)
from fastapi.encoders import jsonable_encoder
from fastapi.responses import JSONResponse, StreamingResponse
from pydantic import BaseModel, Field
from starlette.staticfiles import StaticFiles

from askthedocs import (__version__, api, floor, locate, state, \
                     switchruns, verdicts)
from askthedocs.reindexjob import write_json_atomic
from askthedocs.search import connect as _connect_ro


def _repos_now(application: FastAPI) -> dict[str, Path] | None:
    """The corpus universe for freshness checks: injected repos win
    (tests — an injected EMPTY dict is the deliberate container
    profile), otherwise the shared discovery ladder — the three known
    legs, on disk or not.  None means the ladder REFUSED: this
    service cannot see any corpus from where it was started, and the
    freshness routes must answer the named refusal, never crash (a
    machine with no checkout anywhere answers every leg carried or
    absent when the empty profile is deliberate, never a phantom
    drift against some package-adjacent directory that is not a
    repository)."""
    if application.state.repos is not None:
        return application.state.repos
    try:
        # the recorded root is read from the index home (it moved with
        # the index when the home is redirected)
        report = floor.check_floor(share=locate.index_home())
    except floor.FloorError:
        return None
    repos = {floor.ITER_REPO: report.iter_path}
    for name in floor.OPTIONAL_REPOS:
        repos[name] = report.root / name
    return repos


def _require_repos(application: FastAPI) -> dict[str, Path]:
    """The corpus universe, or the named 503 when this service cannot
    see one ('is the index stale?' always has an answer)."""
    repos_now = _repos_now(application)
    if repos_now is None:
        recorded = floor.recorded_root(share=locate.index_home())
        where = (f", the root setup recorded ({recorded}) is not "
                 "there anymore" if recorded is not None else "")
        raise HTTPException(
            status_code=503,
            detail="the corpus cannot be found from where this "
                   "service was started (no checkout beside it, no "
                   f"root recorded by setup{where}, no "
                   f"${floor.REPOS_ENV}); freshness cannot be judged. "
                   "Re-run `askthedocs setup` beside the corpus, or "
                   f"export {floor.REPOS_ENV}=/path/to/the/repos "
                   "and restart the service")
    return repos_now

# hard ceiling for ?limit= — the largest golden-query recall set
# measured on the real store is 4,139 chunks report)
MAX_LIMIT = 10_000

# env var the uvicorn route (``askthedocs.service:app``) reads for a
# non-default store; ``python -m askthedocs.service`` takes --db instead
DB_ENV = locate.DB_ENV  # single source of truth; the ladder honors it verbatim

_log = logging.getLogger("askthedocs.service")


def _require_db(application: FastAPI) -> Path:
    """The store path, or a 503 carrying the discovery-ladder failure
    verbatim (a store-less app is BUILT on purpose — see create_app —
    so its routes, not its import, carry the refusal)."""
    db = application.state.db_path
    if db is None:
        raise HTTPException(status_code=503,
                            detail=application.state.db_missing)
    return db

# env var for the optional web-client mount (``--static`` CLI
# flag); absent = API routes only
STATIC_ENV = "ASKTHEDOCS_STATIC"

# env var the uvicorn route reads for a non-default catalog
#``switchsets.json`` artifact (join input)
SWITCHSETS_ENV = "ASKTHEDOCS_SWITCHSETS"


# ------------------------------------------------------------- schemas
# Presentation models only: they shape OpenAPI/JSON, while every value
# comes from the library dataclasses (api.SearchHit / api.Chunk) — the
# provenance semantics are askthedocs.api's, never re-derived here.

class MatchedTermOut(BaseModel):
    """One query term present in the chunk + its occurrence count: the why-this-result panel's raw data."""

    term: str = Field(
        description="query term found in the chunk text (case-folded "
                    "token equality)")
    n: int = Field(
        description="occurrence count in the FULL chunk text: term "
                    "presence + frequency, NOT a per-term bm25 "
                    "decomposition (honesty rule, §Service "
                    "tier)")


class SearchHitOut(BaseModel):
    """One ranked match: provenance + highlighted snippet (no full text)."""

    chunk_id: str = Field(
        description="stable chunk ID: sha1(source + page + para-index)")
    source: str = Field(description="repo-relative source path: the citation")
    cluster: str = Field(
        description="cluster label, doc vs code: eirene_manual, …, "
                    "source_switch, fortran_source)")
    section: str | None = Field(
        description="manual section / LOG date (YYYY.MM.dd) / Fortran unit")
    page: int | None = Field(description="1-based page for PDF chunks, else null")
    snippet: str = Field(description="match window with «highlight» marks")
    rank: float = Field(description="FTS5 bm25 score (lower = better)")
    matched_terms: list[MatchedTermOut] = Field(
        description="query terms present in this chunk with occurrence "
                    "counts, query order; term presence + frequency, "
                    "never a per-term score breakdown")
    score: float = Field(
        description="FTS5 bm25 as returned, no invented precision; "
                    "identical to rank (the v1 field name, kept); the "
                    "why-this-result panel's score")
    phrase_hit: bool = Field(
        description="implicit phrase tier marker: true exactly when "
                    "q was plain multi-term and this chunk contains its "
                    "tokens as ONE ADJACENT PHRASE: such hits rank "
                    "ahead of all others (bm25 still orders within each "
                    "tier, and rank/score stay pure bm25).  Single-term "
                    "and explicit-FTS5-syntax queries carry false on "
                    "every hit: no tier applied")
    identity: bool = Field(
        default=False,
        description="identity tier marker: true exactly when this "
                    "chunk's citation name (section) EQUALS q: trimmed, "
                    "case-insensitive, the ruled exact-key semantics. "
                    "Identity hits rank FIRST (above the phrase tier); "
                    "membership, totals and facets never change: the "
                    "tier reorders hits q already returned")
    completion: bool = Field(
        default=False,
        description="type-ahead completion tier: true only on hits "
                    "from typeahead=true requests whose match extends the "
                    "unfinished last word of q as a prefix: they ride "
                    "BELOW the exact tier, never displacing it, and "
                    "committing drops them.  false on every committed "
                    "search hit")


class FacetOut(BaseModel):
    """One cluster chip: label + live match count)."""

    cluster: str = Field(
        description="cluster label, e.g. eirene_manual, source_switch, "
                    "fortran_source")
    count: int = Field(
        description="matching chunks in this cluster: equals the total "
                    "of the same query filtered to this cluster")


class CompletionOut(BaseModel):
    """One /zero-hit-boundary completion: a real corpus word
    extending the query's last token that CO-OCCURS with the query's
    other terms, with its exact click-yield count."""

    word: str = Field(
        description="corpus word extending the query's unfinished last "
                    "token (index-enumerated, never guessed)")
    count: int = Field(
        description="exact hit count CHOOSING this word yields: the "
                    "full query with the last word substituted, the "
                    "cluster filter and plural widening included")
    adjacent: int = Field(
        default=0,
        description=": of count, how many hits carry the full term "
                    "sequence side-by-side in typed order (the "
                    "phrase tier): these words are offered first")


class SeparateTermOut(BaseModel):
    """One (c) escape-hatch term: a typed query term that yields
    hits as a one-term search: offered only when no extending word
    combines with the rest of the query."""

    term: str = Field(
        description="the typed term, runnable alone as one click")
    count: int = Field(
        description="exact solo hit count of the term (plural widening "
                    "included, cluster filter in force)")


class SearchOut(BaseModel):
    """Answer to one query: total match count + the best hits."""

    query: str
    total: int = Field(description="every matching chunk; hits may truncate")
    completions_total: int = Field(
        default=0,
        description=": size of the type-ahead completion tier: 0 on "
                    "committed searches and whenever the guard or query "
                    "shape suppresses it")
    facets: list[FacetOut] = Field(
        description="per-cluster match counts over ALL matches of q, "
                    "count-desc: the drill-in chips.  Computed WITHOUT "
                    "the cluster filter, so the chips keep every "
                    "cluster's count while one is selected")
    sources: list[str] = Field(
        description="distinct hit sources, best-rank order")
    did_you_mean: str | None = Field(
        default=None,
        description="+ : the first recovery word on the zero-hit "
                    "boundary (a plain query matching nothing): the "
                    "side-by-side leader when one exists, else the yield "
                    "leader; grounded enumeration only, no fuzzy "
                    "guessing; null everywhere else")
    completions: list[CompletionOut] = Field(
        default=[],
        description=": the corpus words extending the query's "
                    "unfinished last token that co-occur with its other "
                    "terms, with exact click-yield counts: side-by-side "
                    "words first, then same-chunk, each tier by yield; "
                    "present only on the zero-hit boundary")
    separate_terms: list[SeparateTermOut] = Field(
        default=[],
        description="(c): the escape hatch, present only when no "
                    "extending word combines: each typed term with a "
                    "nonzero solo yield, as one-click one-term searches")
    absent_legs: list[str] = Field(
        default=[],
        description="optional corpus legs (SOLPS-GUI, SOLPS-Tutorials) "
                    "that were not on disk when this index was built, "
                    "so their content can never answer here: the "
                    "zero-hit card names them as places the answer "
                    "might still be; empty on every non-empty answer")
    hits: list[SearchHitOut]


class ChunkOut(BaseModel):
    """One chunk in full: provenance + complete text."""

    chunk_id: str = Field(description="stable chunk ID")
    source: str = Field(description="repo-relative source path: the citation")
    cluster: str = Field(description="cluster label, doc vs code")
    section: str | None = Field(description="manual section / LOG date / unit")
    page: int | None = Field(description="1-based page for PDF chunks, else null")
    text: str = Field(description="the complete chunk text")


class SwitchRunOut(BaseModel):
    """One cataloged run setting the switch: values from
    the catalog artifact verbatim; ``family`` is the run name's prefix
    before ``/`` (index.json's ``run_family``)."""

    run: str = Field(
        description="catalog run name, FAMILY/variant: the run whose "
                    "effective b2mn.dat sets the switch")
    family: str = Field(
        description="run family: the run name's prefix before '/'")
    value: str = Field(
        description="the value the run sets, verbatim from the catalog "
                    "artifact (never re-derived)")


class SwitchRunsOut(BaseModel):
    """The catalog join answer for one switch name."""

    switch: str = Field(
        description="the switch name, verbatim as asked: the join is "
                    "an exact key lookup, zero fuzzy matching")
    catalog: str = Field(
        description='"built" | "absent": absent means no switchsets '
                    'artifact (catalog not built), NOT "no runs"')
    runs: list[SwitchRunOut] = Field(
        description="cataloged runs setting this switch, run-name "
                    "order: empty means no cataloged run sets it "
                    "(with catalog=built)")


class DriftOut(BaseModel):
    """drift evidence: ``<kind> <repo>/<path>`` labels, sorted;
    PRESENT legs only (an absent leg's sources are carried
    information, never phantom drift)."""

    new: list[str]
    changed: list[str]
    removed: list[str]


class LegOut(BaseModel):
    """One modal row's staleness verdict: repository or
    rerouted-module leg, in the same namespace the /corpus rows and
    the pinned commits use."""

    name: str = Field(
        description="leg name: a repository, or repo/modules/<name>")
    verdict: str = Field(
        description='"current" (on disk, matches) | "drifted" (on '
                    'disk, differs: see the counts) | "carried" '
                    '(not on disk; served verbatim from the index at '
                    'the pinned commit the corpus row shows) | '
                    '"absent" (an optional leg not on disk at build '
                    'time: never indexed, nothing to serve; the '
                    'zero-hit card names it as a place the answer '
                    'might still be)')
    new: int = Field(default=0, description="on-disk sources the "
                     "index never consumed (drifted legs only)")
    changed: int = Field(default=0, description="sources whose hash "
                         "differs (drifted legs only)")
    removed: int = Field(default=0, description="recorded sources "
                         "deleted from a PRESENT leg: deletions are "
                         "drift, never carry")
    carried_sources: int = Field(default=0, description="recorded "
                                 "sources served from the index "
                                 "(carried legs only)")


class StatusOut(BaseModel):
    """Staleness report: the HTTP face of ``askthedocs status``."""

    status: str = Field(description='"current" | "drift"')
    build_corpus_state: str = Field(
        description="sha256[:8] of the input state the index was built from")
    current_corpus_state: str = Field(
        description="sha256[:8] of the on-disk input state, re-hashed now")
    build_sources: int
    build_by_kind: dict[str, int]
    repos_present: int = Field(
        default=0, description="declared repositories with a directory "
        "on this machine: 0 with every leg carried is the decayed "
        "profile - the corpus this index was built from is no longer "
        "on this machine (the not-found state the chip and band show)")
    repos_root: str | None = Field(
        default=None, description="the repos root this check resolved "
        "(the parent of the SOLPS-ITER leg): the location the "
        "not-found band names when every repository has vanished "
        "from it")
    legs: list[LegOut] = Field(
        default_factory=list,
        description="per-leg verdicts, name-ascending: the chips the "
        "corpus modal renders beside its rows")
    drift: DriftOut


class ReindexOut(BaseModel):
    """The reindex job's state: POST /reindex starts it (202), GET
    /reindex reports it. One job per service at a time."""

    status: str = Field(description='"idle" | "running" | "done" | '
                                    '"failed"')
    started_at: str | None = Field(
        default=None, description="ISO 8601 UTC, when this job started")
    finished_at: str | None = Field(
        default=None, description="ISO 8601 UTC, when it finished")
    duration_s: float | None = Field(
        default=None, description="wall-clock seconds (done/failed "
                                  "only): the measured number the "
                                  "confirmation dialog quotes next time")
    error: str | None = Field(
        default=None, description="failure detail, named sources "
                                  "included (failed/only)")
    chunks_total: int | None = Field(
        default=None, description="the rebuilt store's chunk count "
                                  "(done only)")
    db_sha256_8: str | None = Field(
        default=None, description="sha256[:8] of the rebuilt store "
                                  "(done only)")
    carried_legs: list[str] = Field(
        default_factory=list,
        description="legs the rebuild carried at their pinned commits "
                    "(done only)")
    drifted_legs: list[str] = Field(
        default_factory=list,
        description="the on-disk drift this job consumed (running/"
                    "done/failed)")
    frame: list[str] = Field(
        default_factory=list,
        description="the live progress display as text lines - the "
                    "SAME lines the CLI setup verb shows, captured "
                    "from the shared renderer and streamed by the "
                    "rebuild's child process: the current frame "
                    "while running, the closing frame when done, "
                    "empty when idle or before a job ever ran")


class CorpusRepoOut(BaseModel):
    """One indexed repository (: name in the chunk-source
    namespace (repo, or repo/submodule for rerouted modules), the
    commit the corpus scan pinned, and its chunk count."""

    name: str = Field(
        description="repository (or repository/submodule) in the "
                    "chunk-source namespace")
    commit: str | None = Field(
        default=None,
        description="the commit the corpus scan pinned (None when no "
                    "build summary sits beside the store: the honest "
                    "absence, never a guessed ref)")
    chunks: int = Field(description="chunks indexed from this repository")
    linkable: bool = Field(
        default=True,
        description="false when NO public repository exists for this "
                    "row (a non-public submodule: adas, whose repo "
                    "answers 404): the row shows its pinned commit but "
                    "never renders a link")


class CorpusOut(BaseModel):
    """what the landing's corpus line and repository modal show:
    when this index was built and exactly what it holds."""

    built_at: str = Field(
        description="when the store file was written (ISO 8601 UTC): "
                    "the artifacts are deliberately timestamp-free "
                    "for byte reproducibility, so this is the FILE's "
                    "build time, never baked into artifact bytes")
    repos: list[CorpusRepoOut] = Field(
        description="every indexed repository with its pinned commit "
                    "and chunk count, name-ascending")


class ErrorResponse(BaseModel):
    detail: str


# ---------------------------------------------------------------- app

class _ReindexJob:
    """One rebuild job's mutable state. The lock guards the
    double-trigger; fields are written only by the supervision thread
    (under the lock) and read without it — simple attribute reads.
    The rebuild itself runs as a DEDICATED CHILD PROCESS the
    supervision thread spawns and watches; the child's display frames
    cross through the frame file it streams, which GET /reindex
    serves."""

    def __init__(self) -> None:
        self.lock = threading.Lock()
        self.status = "idle"
        self.started_at: str | None = None
        self.finished_at: str | None = None
        self.duration_s: float | None = None
        self.error: str | None = None
        self.chunks_total: int | None = None
        self.db_sha256_8: str | None = None
        self.carried_legs: list[str] = []
        self.drifted_legs: list[str] = []
        # where the child streams its display frames (None until the
        # app resolves a store): GET /reindex serves this file's
        # content so the web progress modal replays the exact CLI
        # lines
        self.frame_file: Path | None = None
        self._t0: float | None = None

    def begin(self, drifted: list[str]) -> bool:
        """Claim the job slot; False when one is already running."""
        with self.lock:
            if self.status == "running":
                return False
            self.status = "running"
            self.started_at = _utcnow()
            self.finished_at = None
            self.duration_s = None
            self.error = None
            self.chunks_total = None
            self.db_sha256_8 = None
            self.carried_legs = []
            self.drifted_legs = list(drifted)
            self._t0 = time.monotonic()
            return True

    def finish(self, summary: dict) -> None:
        with self.lock:
            self.status = "done"
            self.finished_at = _utcnow()
            self.duration_s = time.monotonic() - (self._t0 or
                                                  time.monotonic())
            self.chunks_total = summary.get("chunks", {}).get("total")
            self.db_sha256_8 = (summary.get("db_sha256") or "")[:8]
            self.carried_legs = list((summary.get("carry") or {})
                                     .get("legs") or [])

    def fail(self, message: str) -> None:
        with self.lock:
            self.status = "failed"
            self.finished_at = _utcnow()
            self.duration_s = time.monotonic() - (self._t0 or
                                                  time.monotonic())
            self.error = message

    def out(self) -> ReindexOut:
        frame: list[str] = []
        # the frame file serves only after a job has begun in THIS
        # process: before that (idle at boot) it may not exist, or may
        # hold a closing frame an earlier service generation left -
        # the honest idle answer is empty
        if self.frame_file is not None and self.started_at is not None:
            try:
                frame = list(json.loads(
                    self.frame_file.read_text(encoding="utf-8")))
            except (OSError, ValueError):
                frame = []  # not written yet, or mid-replace: the next
                # poll serves it
        return ReindexOut(
            status=self.status, started_at=self.started_at,
            finished_at=self.finished_at, duration_s=self.duration_s,
            error=self.error, chunks_total=self.chunks_total,
            db_sha256_8=self.db_sha256_8,
            carried_legs=list(self.carried_legs),
            drifted_legs=list(self.drifted_legs),
            frame=frame)


# ------------------------------------------- corpus-wide operations
# The freshness re-hash and the rebuild were both
# full-corpus, GIL-bound python in this ONE process; run concurrently,
# each halved the other (measured: a 2.6 s hash stretched to 10.2 s
# beside a job, +5 s on the job itself, and the stacked back-to-back
# variant reached 47-93 s).  The rebuild moved
# itself into a DEDICATED CHILD PROCESS (own interpreter, own GIL), so
# the indexer can no longer contend with anything here; what stays
# in-process is the corpus HASH, and the classes below keep it
# single-flight and excluded while a job runs, with the end-of-run
# verdict coming from the rebuild's own result.

class _JobRunning(Exception):
    """Raised inside the gate when a corpus hash is refused because a
    rebuild job holds the corpus (the route answers the named 503)."""


class _InFlightHash:
    """One running corpus hash plus its result: every caller that
    arrives while it runs waits on this holder and shares the SAME
    answer (single-flight — no stacking from any client, ever)."""

    def __init__(self) -> None:
        self.done = threading.Event()
        self.result: list | None = None
        self.error: BaseException | None = None

    def wait(self) -> list:
        self.done.wait()
        if self.error is not None:
            raise self.error
        return self.result  # type: ignore[return-value]


class _CorpusGate:
    """Mutual exclusion of corpus-wide operations, one per app.

    - :meth:`hash` runs the caller's compute as the ONE shared corpus
      hash: concurrent callers share the in-flight result; a hash
      STARTING while a job holds the corpus raises :class:`_JobRunning`
      (the mid-run named 503).
    - :meth:`claim_job` / :meth:`release_job` bracket a rebuild job
      (from the successful double-trigger claim to the child process
      landing): no hash may start under it — a mid-run verdict would
      describe a store the landing job is about to replace.
    - the post-job verdict (:meth:`stash_verdict` / :meth:`take_verdict`)
      answers the immediate after-done freshness check from what the
      just-finished rebuild consumed, so no hash ever races the
      boundary.  Served ONCE, briefly, and only to the connection
      that watched the job (owner ruling, 2026-11-09: the done-branch
      check rides the polling page's keep-alive socket; a reloaded
      page always asks from a NEW socket, so it re-hashes and a
      cancelled done-branch check can never leak its "current" into a
      later page-load verdict — the race was proven live).  Under push
      the watcher is an ATTACHED event stream, and the stash
      prefers it BY ATTACHMENT — not by sample phase, so even a job
      shorter than one stream sample lands its verdict on the stream
      that will carry the terminal.  Any other check, or any check
      after the window, re-hashes as always.
    """

    # how long the post-job verdict answers (seconds): comfortably
    # more than the client's 2 s poll tick between the job landing and
    # its verdict refresh, and far less than any human-paced re-open
    VERDICT_VALID_S = 10.0

    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._inflight: _InFlightHash | None = None
        self._job = False
        self._verdict: StatusOut | None = None
        self._verdict_peer: tuple | None = None
        self._verdict_until = 0.0
        self._poll_peer: tuple | None = None
        self._stream_peer: tuple | None = None

    def hash(self, compute):
        """Run *compute* (the corpus re-hash) as the one shared
        in-flight hash; waiters share its result.  Never holds the
        lock while computing."""
        with self._lock:
            if self._job:
                raise _JobRunning()
            if self._inflight is not None:
                inflight = self._inflight
                wait = True
            else:
                inflight = _InFlightHash()
                self._inflight = inflight
                wait = False
        if wait:
            return inflight.wait()
        try:
            inflight.result = compute()
        except BaseException as exc:
            inflight.error = exc
            raise
        finally:
            with self._lock:
                self._inflight = None
            inflight.done.set()
        return inflight.result

    def claim_job(self) -> None:
        """The corpus is held by a rebuild job: hashes starting now
        refuse until it lands.  A new job also voids any leftover
        post-job verdict — its "built just now" would describe the
        previous build."""
        with self._lock:
            self._job = True
            self._verdict = None

    def release_job(self) -> None:
        with self._lock:
            self._job = False

    def job_running(self) -> bool:
        with self._lock:
            return self._job

    def note_poll(self, peer: tuple | None) -> None:
        """Remember the peer (host, port) of a /reindex request: the
        polling page's keep-alive socket is the connection the
        done-branch freshness check arrives on, which is the one
        connection the post-job verdict may be served to."""
        with self._lock:
            self._poll_peer = tuple(peer) if peer is not None else None

    def note_stream(self, peer: tuple | None) -> None:
        """The push face's note_poll: an ATTACHED event stream is the
        job's watcher, and the last stream to sample wins -
        the same last-writer rule the poll obeys beside it."""
        with self._lock:
            self._stream_peer = tuple(peer) if peer is not None else None

    def end_stream(self, peer: tuple | None) -> None:
        """Clear the stream binding when THIS stream ends, leaving a
        newer stream's claim intact (the disconnect/cancel path of
        the events generator)."""
        with self._lock:
            if peer is not None and self._stream_peer == tuple(peer):
                self._stream_peer = None

    def stash_verdict(self, out: StatusOut) -> None:
        """Stash the post-job verdict bound to the job's watcher: an
        attached event stream when one exists (its terminal carries
        the verdict), else the peer that last polled the job (None
        when neither ever did — then it is served to nobody and
        simply expires)."""
        with self._lock:
            self._verdict = out
            self._verdict_peer = self._stream_peer or self._poll_peer
            self._verdict_until = time.monotonic() + self.VERDICT_VALID_S

    def take_verdict(self, peer: tuple | None) -> StatusOut | None:
        """Consume the post-job verdict if the asking peer is the
        polling connection and the window holds; None means the
        caller re-hashes (a different connection — a reloaded page —
        the check arrived late, a later job voided it, or no job ever
        landed)."""
        asker = tuple(peer) if peer is not None else None
        with self._lock:
            if (self._verdict is None
                    or time.monotonic() > self._verdict_until
                    or asker != self._verdict_peer):
                self._verdict = None
                return None
            out = self._verdict
            self._verdict = None
            return out


def _utcnow() -> str:
    import datetime
    return datetime.datetime.now(
        tz=datetime.timezone.utc).isoformat(timespec="seconds")


def _status_out(recorded, current, repos_now: dict[str, Path],
                roll: verdicts.Verdicts) -> StatusOut:
    """The /status answer over a rolled verdict — one construction
    shared by the route (a fresh hash) and the post-job derivation
    (the rebuild's own result), so the two can never disagree."""
    return StatusOut(
        status="drift" if any((roll.new, roll.changed, roll.removed))
        else "current",
        build_corpus_state=state.manifest_sha256(recorded)[:8],
        current_corpus_state=state.manifest_sha256(current)[:8],
        build_sources=len(recorded),
        build_by_kind=state.count_by_kind(recorded),
        repos_present=roll.repos_present,
        repos_root=(str(repos_now[floor.ITER_REPO].parent)
                    if floor.ITER_REPO in repos_now else None),
        legs=[LegOut(name=leg.name, verdict=leg.verdict, new=leg.new,
                     changed=leg.changed, removed=leg.removed,
                     carried_sources=leg.carried_sources)
              for leg in roll.legs],
        drift=DriftOut(new=roll.new, changed=roll.changed,
                       removed=roll.removed),
    )


def _post_job_verdict(db_path: Path,
                      repos: dict[str, Path]) -> StatusOut:
    """The end-of-run verdict derived from the rebuild's own
    result, service-side only.  The build IS a full-content hash of
    the corpus it consumed, so the fresh store manifest doubles as
    the on-disk state: current by construction, legs carried as
    carried, absent as absent.  The immediate after-done check is
    answered from this — no re-hash racing the boundary — and the
    next normal check re-hashes as always (at that point no job
    runs)."""
    recorded = state.read_from_db(db_path)
    if recorded is None:
        # cannot happen past a successful swap; if it ever does, the
        # caller skips the cache and the next check re-hashes
        raise RuntimeError(f"no build manifest in {db_path} after the "
                           "rebuild landed")
    roll = verdicts.leg_verdicts(recorded, recorded, repos)
    return _status_out(recorded, recorded, repos, roll)


def _child_argv(legs: dict[str, Path], build_dir: Path,
                final_dir: Path, carry_from: Path, frame_file: Path,
                result_file: Path) -> list[str]:
    """The reindex child command: this same interpreter running the
    child entry module with the EXACT legs the service resolved (so
    the child builds precisely what the drift gate measured).  Tests
    substitute a stub child here - the child's wire protocol is what
    the stub-driven tests pin; the real child is exercised end to end
    by the rebuild and byte-identity tests."""
    argv = [sys.executable, "-m", "askthedocs.reindexjob",
            "--build-dir", str(build_dir),
            "--final-dir", str(final_dir),
            "--carry-from", str(carry_from),
            "--frame-file", str(frame_file),
            "--result-file", str(result_file)]
    for name, path in legs.items():
        argv += ["--leg", f"{name}={path}"]
    return argv


def _run_reindex(job: _ReindexJob, db_path: Path,
                 repos: dict[str, Path], gate: _CorpusGate) -> None:
    """The supervision body: spawn the rebuild as a DEDICATED
    CHILD PYTHON PROCESS - its own interpreter, its own GIL, so the
    service's routes and the freshness hash never share one with the
    indexer - and watch it land.  The child runs the SAME
    display-driven driver the CLI runs (the atomic swap stays inside
    the driver exactly as the CLI performs it) and streams its frames
    to the frame file; GET /reindex serves them under the unchanged
    wire contract.  The gate brackets the child's lifetime: hashes
    refuse while it lives; on success the end-of-run verdict is
    stashed from the swapped-in manifest BEFORE the job reports done,
    so the client's after-done check can never land between the swap
    and the stash.  If this service dies mid-child, the child finishes
    its swap alone (deterministic and atomic, harmless) and the next
    run cleans the stale temporary directory as ever."""
    store_dir = db_path.parent
    frame_file = store_dir / ".reindex-frame.json"
    result_file = store_dir / ".reindex-result.json"
    child_out = store_dir / ".reindex-child.out"
    child_err = store_dir / ".reindex-child.err"
    # an empty frame for the first poll; writing it also resets
    # whatever an earlier job (or an earlier service generation) left
    write_json_atomic(frame_file, [])
    try:
        with open(child_out, "wb") as out_f, \
                open(child_err, "wb") as err_f:
            child = subprocess.Popen(
                _child_argv(repos, store_dir / ".reindex-tmp", store_dir,
                            db_path, frame_file, result_file),
                stdout=out_f, stderr=err_f, stdin=subprocess.DEVNULL)
    except OSError as exc:
        job.fail(f"the rebuild process could not start: {exc}")
        gate.release_job()
        return
    returncode = child.wait()  # blocks here and reaps: no zombie, ever
    record: dict | None = None
    try:
        record = json.loads(result_file.read_text(encoding="utf-8"))
    except (OSError, ValueError):
        record = None
    ok = returncode == 0 and record is not None and bool(record.get("ok"))
    message: str | None = None
    if not ok:
        # the child's own failure report when it managed one; else the
        # exit code plus whatever it printed (a hard kill, a startup
        # crash - the capture display writes nothing to the stream, so
        # anything here is diagnostic gold on the failure path)
        if record is not None and not record.get("ok"):
            message = record.get("error")
        if not message:
            tail = ""
            try:
                tail = child_err.read_text(errors="replace").strip()
            except OSError:
                pass
            message = (f"the rebuild process exited with code "
                       f"{returncode}"
                       + (f": {tail[-1500:]}" if tail else ""))
    gate.release_job()
    if ok:
        # the build landed and swapped: hand the boundary check its
        # answer from the rebuild itself BEFORE the job reports done
        # (diagnostic only on failure - the job has succeeded
        # regardless); then the captured logs are noise and go
        try:
            gate.stash_verdict(_post_job_verdict(db_path, repos))
        except Exception:  # noqa: BLE001
            _log.warning("post-job freshness verdict unavailable; the "
                         "next check re-hashes", exc_info=True)
        job.finish(record or {})
        child_out.unlink(missing_ok=True)
        child_err.unlink(missing_ok=True)
    else:
        job.fail(str(message))


# -------------------------------------------- the events stream
# The progress modal moved from POLL to PUSH (owner ruling, 2026-11-10):
# the page opens ONE long-lived Server-Sent Events stream instead of
# asking GET /reindex every 2 s.  This stream adds NO second state
# machine: the job slot and the child's frame file stay the single
# source of truth (the same file the poll reads), and the stream is a
# tailer that DIFFS the frame - a flat list of display lines, ~1.6 KB,
# rewritten about once a second - and pushes what changed.  The
# indexation triplet (driver / child / store) is untouched by this
# endpoint's existence; GET /reindex keeps its poll shape beside it.

# how often the stream samples the job slot and the frame file
# (seconds): the child writes frames at 1 Hz, so sampling four times
# per frame catches every change with headroom, and one sample is a
# ~1.6 KB read + parse, so an idle stream costs effectively nothing
_EVENT_POLL_S = 0.25

# an attached-but-idle stream's comment cadence (seconds): proof of
# liveness for proxies and the browser at zero payload cost - SSE
# comment lines never reach the page's JavaScript
_EVENT_KEEPALIVE_S = 20.0


def _sse(event: str, payload: dict) -> str:
    """One Server-Sent Events message: a named event plus ONE data
    line.  The JSON is compact and newline-free, so the blank line is
    the event boundary, exactly as the browser's EventSource parses."""
    return (f"event: {event}\n"
            f"data: {json.dumps(payload, separators=(',', ':'))}\n\n")


def _frame_delta(old: list[str], new: list[str]) -> dict:
    """The positional line diff between two frames: every index whose
    text changed, plus the new length (a shorter frame drops its tail
    by implication; a longer one carries every new line in the change
    set), so the client's line state is always fully determined.  The
    frame is a flat list of display lines - 'what changed' is exactly
    this positional diff and nothing more (the anti-goal, ruled: no
    second display model in the service)."""
    changes = [{"i": i, "text": text}
               for i, (was, text) in enumerate(zip(old, new))
               if was != text]
    changes += [{"i": i, "text": text}
                for i, text in enumerate(new[len(old):], start=len(old))]
    return {"length": len(new), "lines": changes}


async def _reindex_event_stream(request: Request,
                                application: FastAPI
                                ) -> asyncio.AsyncGenerator[str, None]:
    """The push stream's body: sample the job slot, emit state and
    frame changes as events, close on the terminal.  Event vocabulary:

    - ``snapshot`` - the full job state in the GET /reindex shape
      (status, started_at, drifted legs, the WHOLE frame): on connect,
      and again on every job-slot transition, so a stream idling since
      page load announces a job started anywhere (a second tab, the
      same one) without any broadcast bookkeeping;
    - ``delta`` - the frame's changed lines while a job runs, at most
      one per frame the child wrote (one per second by construction -
      dense stages batch into counter updates inside single lines,
      never per-file events);
    - ``done``/``failed`` - the terminal: the settled job state plus,
      when THIS connection earned it, the post-job freshness verdict
      (the once-only rule carried over from the poll: an attached
      stream IS the polling connection, and the verdict is consumed
      by exactly one terminal, never replayed).

    After the terminal the stream CLOSES.  A connection arriving at a
    settled slot - the browser's automatic reconnect, a page that
    slept through the job - answers with the same terminal event once
    more, idempotent, and closes again: a finished job can never be
    resurrected by a reconnect.  An idle slot (no job ever claimed in
    this process) holds the stream open on keepalive comments until
    one starts.  Client disconnects end the generator by cancellation;
    the only thing held is the watcher claim, which the exit path
    releases."""
    job: _ReindexJob = application.state.reindex
    gate: _CorpusGate = application.state.gate
    last_status: str | None = None
    last_frame: list[str] = []
    last_keepalive = time.monotonic()
    try:
        while True:
            # under push, an attached stream is the job's watcher: the
            # binding is by ATTACHMENT (asserted every sample, cleared
            # only by this stream's own end), so the POST that starts
            # the job noting ITS own socket cannot steal the verdict
            # from the stream that will carry the terminal - even for
            # a job shorter than one sample tick
            gate.note_stream(request.client)
            out = job.out()
            if out.status != last_status:
                if out.status in ("done", "failed"):
                    # terminal: settle with the summary and, when this
                    # connection holds it, the verdict - then close for
                    # good (the state was sampled AFTER the supervisor
                    # finished the job, so the stash has already
                    # happened)
                    payload = jsonable_encoder(out)
                    payload["verdict"] = jsonable_encoder(
                        gate.take_verdict(request.client))
                    yield _sse(out.status, payload)
                    return
                yield _sse("snapshot", jsonable_encoder(out))
                last_status = out.status
                last_frame = out.frame
            elif out.frame != last_frame:
                yield _sse("delta", _frame_delta(last_frame, out.frame))
                last_frame = out.frame
            now = time.monotonic()
            if now - last_keepalive >= _EVENT_KEEPALIVE_S:
                yield ": keepalive\n\n"
                last_keepalive = now
            await asyncio.sleep(_EVENT_POLL_S)
    finally:
        # the stream ended (terminal sent, client gone, or cancelled):
        # release the watcher claim unless a newer stream took it
        gate.end_stream(request.client)


def create_app(db_path: Path | None = None,
               repos: dict[str, Path] | None = None,
               static_dir: Path | None = None,
               switchsets_path: Path | None = None) -> FastAPI:
    """Build the service over one chunk store.

    ``db_path`` defaults to the discovery ladder — ``ASKTHEDOCS_DB``
    (env, honored verbatim), then the ``./askthedocs-db/`` launch-dir
    artifact, then the index home (the per-user share by default;
    ``--home`` / ``ASKTHEDOCS_HOME`` moves it wholesale); when
    nothing resolves the app is
    still built with the store marked MISSING (importing this module
    never crashes) and every data route answers 503 carrying the
    ladder's placements message.  ``repos`` defaults to the sibling
    reference repos (only /status walks them, read-only).
    ``static_dir`` defaults to ``ASKTHEDOCS_STATIC`` (env) and mounts
    a built web client at ``/`` api-mode deployment; API
    routes keep precedence). ``switchsets_path`` defaults
    to ``ASKTHEDOCS_SWITCHSETS`` (env) then the sibling catalog's
    ``out/switchsets.json`` — read at REQUEST time by /switchruns,
    never by the askthedocs build.  Tests inject all four.
    """
    db_missing: str | None = None
    if db_path is None:
        try:
            db_path = locate.resolve_db()
        except FileNotFoundError as exc:
            db_missing = str(exc)
            _log.warning(
                "no chunk store found: every data route answers 503 "
                "until one is placed:\n%s", db_missing)
    if static_dir is None:
        env_static = os.environ.get(STATIC_ENV)
        static_dir = Path(env_static) if env_static else None
    if switchsets_path is None:
        env_switchsets = os.environ.get(SWITCHSETS_ENV)
        switchsets_path = (Path(env_switchsets) if env_switchsets
                           else switchruns.default_switchsets())
    application = FastAPI(
        title="askthedocs service",
        version=__version__,
        description=("Search the SOLPS-ITER documentation corpus with "
                     "citations: manual sections, dated changelog "
                     "entries, b2mn.dat switches and the implementing "
                     "Fortran units, one ranked result). Thin "
                     "wrappers over askthedocs.api: the CLI, MCP tools, web "
                     "index and this service share one implementation."),
    )
    application.state.db_path = Path(db_path) if db_path is not None else None
    application.state.db_missing = db_missing  # placements message or None
    application.state.repos = repos  # None → the discovery ladder at call
    # the catalog join's artifact reader — mtime-cached, so
    # a rebuilt ../catalog is picked up on the next request without a
    # service restart
    application.state.switchsets = switchruns.Switchsets(switchsets_path)
    # the reindex job — one slot per service, double-trigger
    # safe; the first write-capable endpoint on a deliberately local,
    # unauthenticated service (README §runbook).  Its child streams
    # display frames beside the store (the frame file is per-store,
    # so two services on two stores never cross frames)
    application.state.reindex = _ReindexJob()
    if application.state.db_path is not None:
        application.state.reindex.frame_file = (
            application.state.db_path.parent / ".reindex-frame.json")
    # Mutual exclusion of corpus-wide operations (the /status
    # hash, the POST drift gate, the rebuild job) + the post-job
    # verdict cache — see _CorpusGate
    application.state.gate = _CorpusGate()

    @application.get("/search", response_model=SearchOut,
                     responses={400: {"model": ErrorResponse},
                                503: {"model": ErrorResponse}},
                     summary="Ranked search with citations")
    def search(q: str = Query(description="search terms; full FTS5 syntax "
                                          "allowed (phrases, OR, term*)",
                              min_length=1),
               limit: int = Query(default=api.DEFAULT_LIMIT, ge=1,
                                  le=MAX_LIMIT,
                                  description="max hits returned"),
               cluster: str | None = Query(
                   default=None,
                   description="restrict to one cluster (fortran_source, "
                               "source_switch, …)"),
               typeahead: bool = Query(
                   default=False,
                   description=": answer a TYPING state: the exact "
                               "tier keeps committed order and ranking, "
                               "and completion hits (words extending the "
                               "unfinished last word, >= 3 chars) ride "
                               "below it flagged completion=true")) -> SearchOut:
        """The library's ranked answer as JSON: same ranking (bm25 +
        the phrase tier for plain multi-term queries), same
        highlighted snippets as ``askthedocs search``; typeahead=true
        (appends the flagged completion tier below the exact
        tier without touching the committed order."""
        try:
            if typeahead:
                result = api.typeahead(q, db_path=application.state.db_path,
                                       limit=limit, cluster=cluster)
                completions_total = result.completions_total
            else:
                result = api.search(q, db_path=application.state.db_path,
                                    limit=limit, cluster=cluster)
                completions_total = 0
        except FileNotFoundError as exc:
            raise HTTPException(status_code=503, detail=str(exc)) from exc
        except ValueError as exc:
            raise HTTPException(status_code=400, detail=str(exc)) from exc
        except sqlite3.OperationalError as exc:
            raise HTTPException(status_code=400,
                                detail=f"query failed: {exc}") from exc
        return SearchOut(
            query=result.query, total=result.total,
            completions_total=completions_total,
            facets=[FacetOut(cluster=f.cluster, count=f.count)
                    for f in result.facets],
            sources=result.sources,
            did_you_mean=result.did_you_mean,
            completions=[CompletionOut(word=w, count=n, adjacent=a)
                         for w, n, a in result.completions],
            separate_terms=[SeparateTermOut(term=t, count=n)
                            for t, n in result.separate_terms],
            absent_legs=result.absent_legs,
            hits=[SearchHitOut(
                chunk_id=h.chunk_id, source=h.source, cluster=h.cluster,
                section=h.section, page=h.page, snippet=h.snippet,
                rank=h.rank,
                matched_terms=[MatchedTermOut(term=m.term, n=m.n)
                               for m in h.matched_terms],
                score=h.score,
                phrase_hit=h.phrase_hit,
                identity=h.identity,
                completion=h.completion) for h in result.hits],
        )

    @application.get("/chunk/{chunk_id}", response_model=ChunkOut,
                     responses={404: {"model": ErrorResponse},
                                503: {"model": ErrorResponse}},
                     summary="One chunk in full, with provenance")
    def chunk(chunk_id: str = PathParam(
            description="chunk ID from a search hit")) -> ChunkOut:
        """The full text behind a hit: what a citation resolves to."""
        try:
            full = api.get(chunk_id, db_path=application.state.db_path)
        except FileNotFoundError as exc:
            raise HTTPException(status_code=503, detail=str(exc)) from exc
        if full is None:
            raise HTTPException(status_code=404,
                                detail=f"no chunk with id {chunk_id}")
        return ChunkOut(chunk_id=full.chunk_id, source=full.source,
                        cluster=full.cluster, section=full.section,
                        page=full.page, text=full.text)

    @application.get("/status", response_model=StatusOut,
                     responses={409: {"model": StatusOut},
                                503: {"model": ErrorResponse}},
                     summary="Index staleness)")
    def status(request: Request) -> StatusOut:
        """Re-hash the corpus and diff it against the build manifest
        stored in the DB, rolled up to per-leg verdicts:
        200 current (carried legs allowed: informational, never
        drift), 409 drift (curl --fail gate), 503 nothing to compare.
        With no repositories on disk (container/consumer profile) the
        answer is every leg carried, repos_present 0: the old
        refusal guarded against phantom "all removed" drift, which
        the verdict model cannot produce: an absent leg's sources
        read carried by definition.

        The ordering rule (the rebuild itself now runs as a dedicated
        CHILD PROCESS): the check arriving right after a rebuild
        landed is answered from that rebuild's own result (current by
        construction, instant, never a hash racing the boundary —
        served only to the connection that polled the job, so a
        reloaded page's first check re-hashes as always); a check
        arriving while a rebuild runs answers the named 503 — a
        mid-run verdict would describe a store the landing job is
        about to replace; every other check re-hashes, single-flight
        (concurrent callers share the one in-flight hash)."""
        db = _require_db(application)
        gate: _CorpusGate = application.state.gate
        cached = gate.take_verdict(request.client)
        if cached is not None:
            return cached
        if gate.job_running():
            raise HTTPException(
                status_code=503,
                detail="a rebuild is running; freshness is re-checked "
                       "when it lands (poll GET /reindex)")
        repos_now = _require_repos(application)
        try:
            current = gate.hash(lambda: state.current_inputs(repos_now))
        except _JobRunning as exc:
            # a job claimed the corpus between the check above and
            # the hash start — the same named refusal
            raise HTTPException(
                status_code=503,
                detail="a rebuild is running; freshness is re-checked "
                       "when it lands (poll GET /reindex)") from exc
        # the manifest is read AFTER the hash: a rebuild may have
        # swapped the store while the hash ran, and pairing the fresh
        # disk state with the fresh manifest keeps the two sides of
        # the diff from straddling the swap
        recorded = state.read_from_db(db)
        if recorded is None:
            raise HTTPException(
                status_code=503,
                detail=f"no build manifest in {db}; run "
                       "`askthedocs setup` first")
        roll = verdicts.leg_verdicts(recorded, current, repos_now)
        out = _status_out(recorded, current, repos_now, roll)
        if out.status == "drift":
            return JSONResponse(status_code=409,
                                content=jsonable_encoder(out))
        return out

    @application.post("/reindex", response_model=ReindexOut,
                      status_code=202,
                      responses={409: {"model": ErrorResponse},
                                 503: {"model": ErrorResponse}},
                      summary="Rebuild the index now (the carried or "
                              "forced rebuild)")
    def reindex_start(request: Request, force: bool = Query(
            default=False,
            description="rebuild even when the index is current (the "
                        "fresh-index force path; the confirmation "
                        "dialog carries the honesty, the gate lives "
                        "here)")) -> ReindexOut:
        """the reindex control behind the confirmation
        dialog.  Without *force* requires at least one DRIFTED on-disk
        leg (carried legs are information, never a reason to rebuild);
        force=true rebuilds a current index too.  Spawns the shared
        display-driven pipeline as a DEDICATED CHILD PROCESS building
        into a temporary store that swaps in ATOMICALLY ON SUCCESS
        ONLY: search keeps answering from the current index throughout,
        and the indexer never shares this process (its own interpreter,
        its own GIL; a crash on a pathological document fails the job
        alone).  202 started, 409 nothing-actionable or a job
        already running, 503 no store to rebuild from.

        The non-force drift gate re-hash is a corpus-wide
        operation like any other — it shares the single-flight hash
        (a concurrent /status and this gate run ONE hash between
        them) and refuses while a job runs; once the job is claimed
        the corpus is the job's until the child lands (see
        _run_reindex) — the POST answer stays the instant 202 either
        way."""
        db = _require_db(application)
        recorded = state.read_from_db(db)
        if recorded is None:
            raise HTTPException(
                status_code=503,
                detail=f"no build manifest in {db}; nothing to "
                       "rebuild from")
        repos_now = _require_repos(application)
        gate: _CorpusGate = application.state.gate
        drifted: list[str] = []
        if not force:
            # the drift gate re-hashes the corpus (seconds): only the
            # non-force path needs its verdict, so the force path
            # starts the job immediately (the web force flow opens
            # the progress window on this answer)
            try:
                current = gate.hash(
                    lambda: state.current_inputs(repos_now))
            except _JobRunning as exc:
                raise HTTPException(
                    status_code=409,
                    detail="a rebuild is already running: poll "
                           "GET /reindex") from exc
            roll = verdicts.leg_verdicts(recorded, current, repos_now)
            if not roll.drifted_legs:
                raise HTTPException(
                    status_code=409,
                    detail="index is current: no on-disk leg drifted; "
                           "carried legs are information, not drift "
                           "(clone a leg to make it refreshable; "
                           "force=true rebuilds anyway)")
            drifted = roll.drifted_legs
        job = application.state.reindex
        if not job.begin(drifted):
            raise HTTPException(
                status_code=409,
                detail="a rebuild is already running: poll "
                       "GET /reindex")
        gate.claim_job()
        # the confirm's own connection counts as the polling page's
        # (the done-branch check may ride it if no GET poll follows)
        gate.note_poll(request.client)
        threading.Thread(
            target=_run_reindex, args=(job, db, repos_now, gate),
            daemon=True, name="askthedocs-reindex").start()
        return job.out()

    @application.get("/reindex", response_model=ReindexOut,
                     summary="Reindex job state (poll target)")
    def reindex_state(request: Request) -> ReindexOut:
        """What the confirmation dialog polls while a rebuild runs:
        status, duration when finished, the drift consumed, the
        carried legs, or the named failure: the served store never
        changes except on success.  Every poll also notes its
        connection — the done-branch freshness check that follows the
        final poll is the one connection the post-job verdict is
        served to (see _CorpusGate)."""
        _require_db(application)
        application.state.gate.note_poll(request.client)
        return application.state.reindex.out()

    @application.get("/reindex/events",
                     response_class=StreamingResponse,
                     summary="Reindex job events (the push stream)")
    async def reindex_events(request: Request) -> StreamingResponse:
        """The push replacement for the poll: one Server-Sent
        Events stream per page carries the whole job lifecycle - a
        snapshot on connect (reopen mid-job, a page refresh and a
        second tab all adopt the running job), the frame deltas while
        it runs, and one terminal event with the summary and the
        post-job verdict before the stream closes; an idle slot holds
        the stream open on keepalive comments until a job starts.  GET
        /reindex keeps its poll shape untouched beside it
        (compatibility plus the wire tests); this endpoint reads the
        same frame file and adds nothing to the indexation path
        (driver / child / store stay byte-untouched).  Hand-rolled
        over the framework's streaming response: zero new
        dependencies (the ceiling doctrine)."""
        _require_db(application)
        return StreamingResponse(
            _reindex_event_stream(request, application),
            media_type="text/event-stream",
            headers={"Cache-Control": "no-cache",
                     "X-Accel-Buffering": "no"})

    @application.get("/switchruns/{name}", response_model=SwitchRunsOut,
                     responses={503: {"model": ErrorResponse}},
                     summary="Cataloged runs setting a switch)")
    def switchruns_for(name: str = PathParam(
            description="b2mn.dat switch name, VERBATIM: a "
                        "source_switch citation's section; the join is "
                        "an exact key lookup, no fuzzy matching")) \
            -> SwitchRunsOut:
        """The run catalog cross-reference for one switch: which
        cataloged runs set it, to what value: read live from the
        sibling catalog's switchsets.json artifact (request-time,
        mtime-cached; the askthedocs build never touches ../catalog).
        Both zero states are honest 200s: ``catalog="absent"`` when no
        artifact exists ("catalog not built"), ``runs=[]`` when no
        cataloged run sets the switch."""
        try:
            answer = application.state.switchsets.runs_for(name)
        except ValueError as exc:
            # artifact exists but does not parse / wrong schema —
            # distinct from absent, and never answered with a lying
            # "not built"
            raise HTTPException(status_code=503, detail=str(exc)) from exc
        return SwitchRunsOut(
            switch=answer.switch, catalog=answer.catalog,
            runs=[SwitchRunOut(run=r.run, family=r.family, value=r.value)
                  for r in answer.runs],
        )

    @application.get("/corpus", response_model=CorpusOut,
                     responses={503: {"model": ErrorResponse}},
                     summary="Indexed corpus: build time + repositories (")
    def corpus_info() -> CorpusOut:
        """What the landing's corpus line and repository modal show:
        when this store was built and every repository it holds, each
        with the commit the corpus scan pinned and its chunk count.
        Commits come from the build summary beside the store; without
        one (a store bundled alone) they are honestly absent, and the
        repositories are derived from the store's own sources."""
        import datetime as _dt
        import json as _json
        db = _require_db(application)
        if not db.is_file():
            raise HTTPException(status_code=503,
                                detail=f"chunk store not found: {db}")
        built_at = _dt.datetime.fromtimestamp(
            db.stat().st_mtime, tz=_dt.timezone.utc).isoformat()
        summary_path = db.parent / "build_summary.json"
        heads: dict[str, str] = {}
        no_unit_paths: list[str] = []
        pointers: dict[str, str] = {}
        if summary_path.is_file():
            try:
                summary_json = _json.loads(
                    summary_path.read_text(encoding="utf-8"))
                heads = dict(summary_json.get("repo_heads") or {})
                no_unit_paths = list(
                    summary_json.get("fortran", {})
                    .get("no_unit_files", []) or [])
                pointers = dict(
                    summary_json.get("submodule_pointers") or {})
            except (ValueError, OSError):
                heads = {}  # honest absence, not a 500
        if heads:
            names = sorted(heads, key=lambda n: (-len(n), n))
        else:
            conn = _connect_ro(db)
            try:
                names = sorted({r[0] for r in conn.execute(
                    "SELECT DISTINCT substr(source, 1, "
                    "instr(source, '/') - 1) FROM chunks "
                    "WHERE instr(source, '/') > 0")})
            finally:
                conn.close()
        conn = _connect_ro(db)
        try:
            # one grouped read (~158 sources); each source attributes
            # to the MOST SPECIFIC key it starts with — a submodule
            # source counts for the submodule, never again for its
            # parent (the naive LIKE double-counts)
            per_source = dict(conn.execute(
                "SELECT source, COUNT(*) FROM chunks GROUP BY source"))
        finally:
            conn.close()
        keys = sorted(heads or {n: "" for n in names},
                      key=lambda n: -len(n))

        # module-level rows. The modal mirrors the repository
        # tree: every directory under a repo's modules/ that the build
        # TOUCHED (a pinned submodule head, indexed chunks, or a
        # manifest input — so zero-chunk modules still appear) becomes
        # its own row; submodules keep their own commit, plain
        # directories carry the PARENT's pinned commit (the revision
        # that governs their code) and the client links them into the
        # parent repo at that commit and path.  The parent's row shows
        # only its DIRECT chunks — nothing double-counts.
        conn = _connect_ro(db)
        try:
            # immediate module directory only: modules/<name>/…
            manifest_modules = {
                "SOLPS-ITER/" + "/".join(p.split("/")[:2])
                for (p,) in conn.execute(
                    "SELECT DISTINCT path FROM build_manifest "
                    "WHERE repo = 'SOLPS-ITER' AND path LIKE 'modules/%'")
                if len(p.split("/")) >= 2}
        finally:
            conn.close()
        # walked-but-skipped mains also name their module (Sonnet-light:
        # both files are recorded no-unit skips — the row shows 0 with
        # the boundary visible).  adas appears from NO artifact: the
        # build never touches it (pointer module, no Fortran, no docs).
        manifest_modules |= {
            "SOLPS-ITER/" + "/".join(p.split("/")[:2])
            for p in no_unit_paths
            if p.startswith("modules/") and len(p.split("/")) >= 2}
        chunk_modules = {"/".join(s.split("/")[:3]) for s in per_source
                         if s.startswith("SOLPS-ITER/modules/")}
        head_modules = {h for h in heads
                        if h.startswith("SOLPS-ITER/modules/")}
        for child in (manifest_modules | chunk_modules | head_modules):
            parent = child.split("/")[0]
            if child not in heads and parent in heads:
                # plain directory: the parent's commit governs it
                keys.append(child)
                keys.sort(key=lambda n: -len(n))

        def owner(source: str) -> str | None:
            for key in keys:
                if source == key or source.startswith(key + "/"):
                    return key
            return None

        counts: dict[str, int] = {}
        leftovers: dict[str, int] = {}
        for source, n in per_source.items():
            key = owner(source)
            if key is not None:
                counts[key] = counts.get(key, 0) + n
            else:
                # not under any pinned repository — e.g. the
                # synthesized b2mn.dat switch-inventory source: it is
                # part of the corpus, shown under its own name with
                # the commit honestly absent
                leftovers[source] = leftovers.get(source, 0) + n

        def commit_for(name: str) -> str | None:
            if name in heads:
                return heads[name]
            parent = name.split("/")[0]
            return heads.get(parent)

        # every derived module row appears even at 0 chunks — the
        # boundary stays visible (Sonnet-light: both files are
        # recorded no-unit skips). Amendment: submodule
        # pointers the corpus never scanned list TOO — pinned at
        # their gitlink commit, LINKLESS when no public repository
        # exists (adas answers 404, measured 2026-10-21) — MERGED
        # into the sorted set so they take their place inside the
        # parent's block, never appended at the bottom
        linkless = {n for n in pointers if n not in heads}
        row_names = (set(counts) | {k for k in keys if "/modules/" in k}
                     | set(heads) | set(pointers))

        def row(name: str) -> CorpusRepoOut:
            commit = (heads.get(name) or pointers.get(name)
                      or commit_for(name))
            return CorpusRepoOut(name=name, commit=commit,
                                 chunks=counts.get(name, 0),
                                 linkable=name not in linkless)

        repos = [row(name) for name in sorted(row_names)]
        repos += [CorpusRepoOut(name=name, commit=None, chunks=n)
                  for name, n in sorted(leftovers.items())]
        return CorpusOut(built_at=built_at, repos=repos)

    # optional web-client mount — AFTER the API routes so
    # /search, /chunk and /status keep precedence; html=True serves
    # index.html at "/".  Mounts are not part of the OpenAPI schema,
    # so /openapi.json still documents exactly the three API routes.
    if static_dir is not None:
        application.mount("/", StaticFiles(directory=str(static_dir),
                                           html=True), name="web")

    return application


# module-level app for ``uvicorn askthedocs.service:app``
app = create_app()


def main(argv: list[str] | None = None) -> int:
    """CLI entry: ``python -m askthedocs.service [--db PATH] [--host --port]``
    — boot the service with uvicorn on 127.0.0.1:8000.  Kept beside the
    app so the runbook needs no uvicorn import-path knowledge."""
    import argparse

    import uvicorn

    ap = argparse.ArgumentParser(
        prog="askthedocs.service",
        description="FastAPI service over the chunk store")
    ap.add_argument("--db", type=Path, default=None,
                    help="chunk store to serve (default: the discovery "
                         "ladder: ASKTHEDOCS_DB env, the "
                         "./askthedocs-db/ launch-dir artifact, the "
                         "index home, ~/.local/share/askthedocs/ unless "
                         "ASKTHEDOCS_HOME moves it)")
    ap.add_argument("--static", type=Path, default=None,
                    help="optional web-client directory to mount "
                         "at / (api-mode build; default: ASKTHEDOCS_STATIC "
                         "env or API routes only)")
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=8000)
    args = ap.parse_args(argv)
    _startup_verdict(args.db)
    server_app = create_app(args.db, static_dir=args.static)
    uvicorn.run(server_app, host=args.host, port=args.port, log_level="info")
    return 0


def _startup_verdict(db_path: Path | None) -> None:
    """one freshness line at server start: current / drifted
    with counts / skipped (repos absent).  Diagnostic only: a broken
    or missing store, or a slow disk, must never block the boot."""
    from askthedocs import locate
    try:
        db = locate.resolve_db(db_path)  # explicit --db honored
        recorded = state.read_from_db(db)
        if recorded is None:
            print("corpus freshness: unknown; no build manifest in the "
                  "store")
            return
        try:
            report = floor.check_floor(share=locate.index_home())
        except floor.FloorError:
            print("corpus freshness: skipped (no SOLPS-ITER checkout on "
                  "the discovery ladder); the index is complete as "
                  "built; every leg is carried")
            return
        repos = {floor.ITER_REPO: report.iter_path}
        for name in floor.OPTIONAL_REPOS:
            repos[name] = report.root / name
        roll = verdicts.leg_verdicts(recorded, state.current_inputs(repos),
                                     repos)
        print(f"corpus freshness: {roll.summary()}")
    except Exception as exc:  # noqa: BLE001 — the boot must survive
        print(f"corpus freshness: skipped ({exc})")


if __name__ == "__main__":
    raise SystemExit(main())
