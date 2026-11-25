"""Corpus inventory scanner).

Walks the SOLPS-ITER, SOLPS-GUI and SOLPS-Tutorials reference repos
(read-only) and writes ``out/corpus.json`` — the machine-checked
manifest of every corpus source that the extraction stories
..005) consume.

Scope rules (tutorials addition 2026-10-18):
  * extensions, matched case-insensitively: .pdf .tex .rst .log .htm
    plus the extensionless changelog ``doc/LOG`` (matched by basename).
    ``.md`` enters the corpus ONLY via the SOLPS-Tutorials repo
    (REPO_EXTENSIONS): every other repo's markdown (READMEs) stays
    out, so the tutorials addition changes no other repo's scope.
    ``.html`` is deliberately NOT in scope: the scope rule counts exactly one HTML
    manual (dg_manual_1.20.htm); the 8 .html files present (MDSPLUS TCL
    model dumps, a course index page) are not corpus documents.
  * ``runs/`` and ``.git/`` directories are pruned from the walk.

text_status taxonomy:
  * text            — plain-text formats (.tex/.rst/.log/.htm/LOG)
  * text_rich       — PDF with >= RICH_MIN_CHARS extractable chars at
                      >= RICH_MIN_CHARS_PER_PAGE density
  * text_poor       — PDF with extractable text below that bar (the
                      ~120 figure-dump plot PDFs; excluded from corpus)
  * needs_ocr       — the pinned scan-only documents (owner triage,
                      pinned golden; probed 2026-09-23)
  * needs_alt_extractor — pypdf cannot extract the file (constructor
                      failure or any page raising), or the pinned files
                      whose streams are malformed

The 7 specials are pinned by exact repo-relative path — the pinned golden
names them as the exact flagged set.  Three reproduce mechanically with
pypdf 6.18.0 (BRAAMS/Juelich/PhD: 0 chars; Maddison: constructor
TypeError; PFR2016: PdfReadError on a mid-document page).  IDS-PenkoMSc
and eirene_publ extract substantial text on a full-document probe
(332821 / 10927 chars) and are flagged by owner decision,
not by measurement; the measured evidence is kept alongside the
flag in corpus.json (pages/chars/extraction_error fields).

Schema /2): the manifest also records each repo's HEAD commit
at scan time — including each initialized submodule's own checkout —
under ``heads``, so citation links can pin the exact commit the corpus
ingested instead of a drifting branch.
"""

from __future__ import annotations

import hashlib
import json
import logging
import os
import warnings
from pathlib import Path
from typing import Any

# --- pinned specials (pinned golden; probe 2026-09-23, pypdf 6.18.0) ---
SPECIALS: dict[tuple[str, str], str] = {
    ("SOLPS-ITER", "doc/BRAAMS_-_A_Multi-Fluid_Code_for_the_Simulation_of_the_Edge_Plasma_in_Tokamaks_-_NET_Report_1987.pdf"): "needs_ocr",
    ("SOLPS-ITER", "doc/Martine_Baelmans_-_Juelich_Report_1994.pdf"): "needs_ocr",
    ("SOLPS-ITER", "doc/Martine-Baelmans-PhD-thesis.pdf"): "needs_ocr",
    ("SOLPS-ITER", "doc/IDS_visualization_DejanPenkoMSc.pdf"): "needs_ocr",
    ("SOLPS-ITER", "doc/SOLPS_2002_Course/eirene_publ.pdf"): "needs_ocr",
    ("SOLPS-ITER", "doc/Maddison-coupling-report.pdf"): "needs_alt_extractor",
    ("SOLPS-ITER", "doc/PFR2016_11-1403102.pdf"): "needs_alt_extractor",
}

# corpus file extensions, lowercased
EXTENSIONS = frozenset({".pdf", ".tex", ".rst", ".log", ".htm"})
# per-repo scope extensions (2026-10-18): markdown enters the corpus
# ONLY here — the tutorials repo is MkDocs (.md sources); every other
# repo's .md (READMEs, notes) stays out so their scope is unchanged
REPO_EXTENSIONS: dict[str, frozenset[str]] = {
    "SOLPS-Tutorials": EXTENSIONS | {".md"},
}
# extensionless changelog basename
LOG_BASENAME = "LOG"
# directories pruned from the walk
PRUNED_DIRS = frozenset({".git", "runs"})

SCHEMA = "askthedocs-corpus/2"

# PDF richness thresholds (calibrated on the 2026-09-23 full-corpus probe:
# 192 PDFs -> 59 files >= 1000 chars, matching the recorded 60 text-rich
# within one; everything below is a figure dump or a title page)
RICH_MIN_CHARS = 1000
RICH_MIN_CHARS_PER_PAGE = 100


def default_repos() -> dict[str, Path]:
    """Sibling reference repos of this checkout (workspace layout).

    ``ASKTHEDOCS_REPOS_ROOT`` (absolute path) overrides the workspace
    root for every repo at once — the fresh-clone corpus set indexes
    latest upstream without touching the pinned siblings, which stay
    the certified data source and are never rebuilt over.  The
    declared-repo-set doctrine is unchanged: a declared repo missing
    under the active root is the caller's fatal, exactly as with the
    default siblings.
    """
    iter_root = Path(__file__).resolve().parents[3]
    root = os.environ.get("ASKTHEDOCS_REPOS_ROOT")
    base = Path(root).expanduser().resolve() if root else iter_root
    return {
        "SOLPS-ITER": base / "SOLPS-ITER",
        "SOLPS-GUI": base / "SOLPS-GUI",
        # 2026-10-18: the MkDocs tutorials (readthedocs
        # solps-tutorials) — pinned like the other siblings
        "SOLPS-Tutorials": base / "SOLPS-Tutorials",
    }


def _git(repo: Path, *args: str) -> str | None:
    """One read-only git query; None when git or the repo is absent
    (synthetic test repos record no heads — the link builder then
    falls back to each repo's default branch, labeled)."""
    import subprocess
    try:
        proc = subprocess.run(["git", "-C", str(repo), *args],
                              capture_output=True, text=True)
    except OSError:
        return None
    if proc.returncode != 0:
        return None
    return proc.stdout.strip() or None


def repo_heads(repos: dict[str, Path]) -> dict[str, str]:
    """HEAD commit of every repo — and of every INITIALIZED submodule
    inside it — at scan time).

    Keys are repo names; submodules are keyed ``<repo>/<submodule
    path>`` — the same namespace chunk ``source`` paths use, so the
    web link builder (web/src/lib/srclink.js) looks a pin up exactly
    the way it resolves a base repo.  A submodule pin is the
    checkout's own HEAD (the bytes the scan walked), never the main
    repo's gitlink pointer read as provenance: the corpus reads the
    working tree, and the two agree only while the checkout is clean.

    An entry is OMITTED whenever git cannot answer (no git, not a
    repo, unborn HEAD) — an absent pin must degrade to the labeled
    default branch, never to a wrong commit.
    """
    heads: dict[str, str] = {}
    for repo in sorted(repos):
        base = Path(repos[repo])
        head = _git(base, "rev-parse", "HEAD")
        if head:
            heads[repo] = head
        # gitlink entries (mode 160000) in the tree ARE the submodules;
        # -r lists them without descending (a gitlink holds no tree)
        listing = _git(base, "ls-tree", "-r", "HEAD") or ""
        for line in listing.splitlines():
            if not line.startswith("160000 commit "):
                continue
            sha, _, path = line[len("160000 commit "):].partition("\t")
            if not path:
                continue
            sub = base / path
            # only an initialized submodule's bytes were walked — pin
            # the checkout itself, exactly like the parent repo
            if (sub / ".git").exists():
                sub_head = _git(sub, "rev-parse", "HEAD")
                if sub_head:
                    heads[f"{repo}/{path}"] = sub_head
    return heads


def submodule_state(repos: dict[str, Path]) -> dict[str, dict[str, bool]]:
    """Every gitlink each repo declares, with its initialized flag.

    ``{repo: {"modules/<name>": initialized}}`` — the declaration list
    is the parent's own tree (``git ls-tree -r HEAD``, mode 160000,
    the same read :func:`repo_heads` uses); a submodule is initialized
    when its working directory carries a ``.git``.  This is the leg
    truth verdicts need: a DECLARED but never-initialized
    submodule is an absent leg (carried), whatever stray files sit in
    its directory — only an initialized checkout's bytes were ever
    walked.  Empty for repos git cannot answer (no git, not a repo):
    honest absence, no guessed declarations.
    """
    out: dict[str, dict[str, bool]] = {}
    for repo in sorted(repos):
        base = Path(repos[repo])
        listing = _git(base, "ls-tree", "-r", "HEAD") or ""
        declared: dict[str, bool] = {}
        for line in listing.splitlines():
            if not line.startswith("160000 commit "):
                continue
            _, _, path = line[len("160000 commit "):].partition("\t")
            if not path:
                continue
            declared[path] = (base / path / ".git").exists()
        if declared:
            out[repo] = declared
    return out



def default_out() -> Path:
    """<askthedocs project>/out/corpus.json."""
    return Path(__file__).resolve().parents[2] / "out" / "corpus.json"


def classify_cluster(repo: str, rel: str) -> str:
    """Cluster for a repo-relative posix path (first match wins)."""
    if rel == "doc/LOG" or rel.endswith(".log"):
        return "log"
    if repo == "SOLPS-Tutorials":
        return "tutorials"
    if repo == "SOLPS-GUI":
        return "gui_figures" if rel.endswith(".pdf") else "gui_docs"
    if rel.startswith("modules/Eirene/Manual/"):
        return "eirene_manual"
    if rel.startswith("modules/Eirene/Database/AMdata/"):
        return "amdata"
    if rel.startswith("modules/DivGeo/") or rel == "doc/dg_manual_1.20.htm":
        return "divgeo"
    if rel.startswith("modules/"):
        return "module_docs"
    if rel.startswith("doc/solps/"):
        return "solps_docs"
    if rel.startswith("doc/SOLPS_2002_Course/"):
        return "course"
    if rel.startswith("doc/"):
        return "docs"
    return "misc"


def classify_pdf_status(pages: int | None, chars: int | None,
                        error: str | None) -> str:
    """Measured text_status for a non-special PDF."""
    if error is not None:
        return "needs_alt_extractor"
    if pages is None or chars is None:
        return "needs_alt_extractor"
    if chars >= RICH_MIN_CHARS and chars / max(pages, 1) >= RICH_MIN_CHARS_PER_PAGE:
        return "text_rich"
    return "text_poor"


def probe_pdf(path: Path,
              on_page=None) -> tuple[int | None, int | None, str | None]:
    """Extract (pages, chars, error) with pypdf (thin wrapper over the
    shared single-visit page extractor; the numbers are what the
    richness classification records).

    An error on ANY page marks the whole file: even partial extractability
    means pypdf is not a viable extractor for it (PFR2016 reads fine until
    a malformed mid-document content stream raises PdfReadError).
    """
    from askthedocs import extract
    _texts, pages, chars, error = extract.extract_pdf_pages(path,
                                                            on_page=on_page)
    return pages, chars, error


def sha256_file(path: Path, on_chunk=None) -> str:
    """Content hash; *on_chunk*, when given, is called per 1 MiB block
    with the block length (the read display's per-file byte bar)."""
    h = hashlib.sha256()
    with open(path, "rb") as fh:
        for block in iter(lambda: fh.read(1 << 20), b""):
            h.update(block)
            if on_chunk is not None:
                on_chunk(len(block))
    return h.hexdigest()


def is_corpus_file(name: str, repo: str | None = None) -> bool:
    ext = os.path.splitext(name)[1].lower()
    allowed = REPO_EXTENSIONS.get(repo, EXTENSIONS) if repo else EXTENSIONS
    return ext in allowed or name == LOG_BASENAME


def walk_sources(repos: dict[str, Path]):
    """Yield (repo, rel-path, path) for every corpus file in scope, in
    scan order (sorted repos, sorted walk). ``scan`` and the 
    build manifest share this walk, so the scope is defined once —
    hashing-only consumers never pay the pypdf probe."""
    for repo in sorted(repos):
        base = Path(repos[repo])
        for dirpath, dirnames, filenames in os.walk(base):
            dirnames[:] = sorted(d for d in dirnames if d not in PRUNED_DIRS)
            for name in sorted(filenames):
                if not is_corpus_file(name, repo):
                    continue
                path = Path(dirpath) / name
                yield repo, path.relative_to(base).as_posix(), path


def doc_category(repo: str, rel: str) -> str:
    """The pending-list category of a documentation source: the
    repository, the immediate module directory for files under
    ``modules/<name>/`` (every module directory is a category, git
    submodule or plain directory alike), or ``scripts`` for the
    repository's own scripts directory - the categories mirror the
    directory tree, and each is contiguous in both the walk and the
    manifest order (``scripts`` would otherwise sort after
    ``modules`` and split the repository category in two)."""
    if repo == "SOLPS-ITER":
        parts = rel.split("/")
        if parts[0] == "modules" and len(parts) > 1:
            return parts[1]
        if parts[0] == "scripts":
            return "scripts"
    return repo


def _preextract_text(extract, repo: str, rel: str, path: Path,
                     cluster: str,
                     ext: str | None) -> dict[str, Any]:
    """Chunk one non-PDF source now (the same extractor the build
    dispatch would choose by form); failures cache the error string.
    Skip decisions stay with the build: a skipped source's cached
    chunks are discarded there."""
    extractor = None
    if ext == ".tex":
        extractor = extract.extract_tex
    elif ext == ".rst":
        extractor = extract.extract_rst
    elif ext == ".md":
        extractor = extract.extract_md
    elif ext == ".htm":
        extractor = extract.extract_htm
    elif (repo, rel) == ("SOLPS-ITER", "doc/LOG"):
        extractor = extract.extract_log
    if extractor is None:
        return {"chunks": [], "error": None}
    try:
        return {"chunks": extractor(repo, rel, path, cluster),
                "error": None}
    except extract.ExtractionError as exc:
        return {"chunks": [], "error": str(exc)}


def scan(repos: dict[str, Path],
         progress=None, file_bar=None, preextracted=None,
         on_file_done=None) -> dict[str, Any]:
    """Build the full corpus manifest dict (deterministic order) -
    ONE visit per document: hash, extract the text, classify, and
    (with *preextracted*) chunk from the very same text, so the index
    build never extracts anything twice.

    *progress*, when given, is called at each file's START with
    (repo, repo-relative path, size): the display attributes the file
    to its category and names it. *on_file_done* fires at each file's
    END (a file counts when it is finished, not when it starts).
    *file_bar* receives the within-file progress: bytes while
    hashing, pages while extracting.
    """
    from askthedocs import extract
    files: list[dict[str, Any]] = []
    for repo, rel, path in walk_sources(repos):
        size = path.stat().st_size
        if progress is not None:
            progress(repo, rel, size)
        name = path.name
        ext = os.path.splitext(name)[1].lower() or None
        source = f"{repo}/{rel}"
        cluster = classify_cluster(repo, rel)
        if file_bar is not None:
            file_bar.file_total(size, "B")
        record: dict[str, Any] = {
            "repo": repo,
            "path": rel,
            "ext": ext,
            "size": size,
            "sha256": sha256_file(
                path, on_chunk=file_bar.file_tick if file_bar else None),
            "cluster": cluster,
        }
        special = SPECIALS.get((repo, rel))
        if ext == ".pdf":
            if file_bar is not None:
                state = {"total": None}
                def _on_page(number: int, total: int) -> None:
                    if state["total"] is None:
                        state["total"] = total
                        file_bar.file_total(total, "pages")
                    file_bar.file_tick()
            else:
                _on_page = None
            texts, pages, chars, error = extract.extract_pdf_pages(
                path, on_page=_on_page)
            record["pages"] = pages
            record["chars"] = chars
            record["extraction_error"] = error
            record["text_status"] = special or classify_pdf_status(
                pages, chars, error
            )
            if preextracted is not None:
                if error is None:
                    preextracted[source] = {
                        "chunks": extract.pdf_chunks_from_pages(
                            repo, rel, cluster, texts),
                        "error": None,
                    }
                else:
                    preextracted[source] = {"chunks": [],
                                            "error": error}
        else:
            record["pages"] = None
            record["chars"] = None
            record["extraction_error"] = None
            record["text_status"] = "text"
            if preextracted is not None:
                preextracted[source] = _preextract_text(
                    extract, repo, rel, path, cluster, ext)
        files.append(record)
        if on_file_done is not None:
            on_file_done()

    counts: dict[str, dict[str, int]] = {}
    for record in files:
        for key in ("cluster", "text_status", "ext"):
            bucket = counts.setdefault(key, {})
            bucket[record[key]] = bucket.get(record[key], 0) + 1

    return {
        "schema": SCHEMA,
        "repos": sorted(repos),
        # the exact commit state the scan walked — every
        # repo's HEAD, plus each initialized submodule's own HEAD
        # (keys mirror the chunk-source namespace).  Schema /1
        # manifests carry none, which is why the schema bumped: an
        # old manifest re-scans rather than silently pinning nothing.
        "heads": repo_heads(repos),
        "counts": {
            "files": len(files),
            "per_repo": {
                repo: sum(1 for r in files if r["repo"] == repo)
                for repo in sorted(repos)
            },
            **counts,
        },
        "files": sorted(files, key=lambda r: (r["repo"], r["path"])),
    }


def write_manifest(manifest: dict[str, Any], out_path: Path) -> None:
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with open(out_path, "w", encoding="utf-8") as fh:
        json.dump(manifest, fh, indent=1, sort_keys=False)
        fh.write("\n")
