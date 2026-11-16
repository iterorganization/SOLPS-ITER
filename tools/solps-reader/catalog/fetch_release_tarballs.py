#!/usr/bin/env python3
"""Selective release-tarball fetch + three-way md5 verify .

Consumes a release-diff JSON (catalog-deltarun-diff/1) and fetches ONLY the
changed tarballs from the Zenodo version axis pinned, into a local
cache, verified three ways, extracted per the Makefile rule.

Authorities (cited where used):
- Zenodo axis (FORMATS.md "Zenodo version axis", measured 2026-09-29):
  concept 19238168, 18 records; the version LISTING endpoint itself carries
  per-file {key, size, checksum} for every record (one request = the axis);
  file bytes at https://zenodo.org/records/<id>/files/<key> (the Makefile's
  own URL form, runs/examples/Makefile:4,:17 — raw '+' needs no encoding).
  OQ-DR2a-1: key fetches by RECORD ID, never version-string inference.
  OQ-DR2a-2: an md5 no record carries is Zenodo-leg-absent — an honest
  skip, never a mismatch (the golden pair's old side predates the concept).
  Rate limit: pace requests (~0.6 s) and back off on HTTP 429 — a 429 is
  NEVER evidence a file is gone.
- Makefile fetch/publish rules (runs/examples/Makefile:14-19,:28-40): the
  repo pin is the bare md5 the publish rule writes; extraction is
  `tar -xhmzf` into a fresh dir expecting exactly one top entry.

Cache layout under --cache (default out/deltarun/, gitignored, never
committed): records/listing.json (the cached axis), tarballs/<md5>/<name>
(the bytes, keyed by content identity so re-uploads dedupe), extract/<md5>/
(the extracted run dir).

Size guards: a tarball over --per-tarball-budget (default 1 GiB; e.g.
ITER_2588_drifts at 3.25 GB and ITER_Be-W at 1.85 GB are flagged) is an
honest skip with the reason; a plan whose total download exceeds
--total-budget (default 256 MiB, so only cheap comparisons proceed
unattended) is refused BEFORE any download; a plan that would (re)assemble
EVERY file of one record is a full-record pull and requires
--force-full-record.

Three-way md5 (repo pin per commit <-> Zenodo files[].checksum <-> local
hashlib.md5 of the bytes, equivalent to the Makefile check rule's md5sum):
any mismatch is a hard ValueError printing all three values.

Warm cache: an existing tarball whose size and md5 match the pin is never
re-downloaded (verified by size first, then md5); a corrupt cache file
(wrong size or md5) is re-downloaded and recorded as repaired.

Extraction: `tar -xhmzf` verbatim (Makefile:18).  bsdtar 3.5.3 (this Mac)
rejects -h in -x mode — -h is a creation-side dereference flag, inert on
extraction — so on flag-rejection with an untouched target the fallback
drops only -h (`tar -xmzf`); the flags that actually ran are recorded in
the report.  After extraction the target must hold EXACTLY ONE entry named
<tarball base> (Makefile:19 `[ echo $*.tmp/* | wc -w == 1 ]` + the mv) —
deviations are errors.

Report (stdout or -o): JSON schema catalog-deltarun-fetch/1 — per side
{outcome fetched|warm-cache|skipped, skip_kind, record_id, size, verify
{repo, zenodo, local}, extraction {...}, repo-relative cache paths};
deterministic for a given cache+axis state (no timestamps, sorted).

Run with the SOLPS-Reader venv interpreter (house rule):
    ../.venv/bin/python fetch_release_tarballs.py <diff.json> [--only NAME ...]
"""
from __future__ import annotations

import argparse
import hashlib
import json
import ssl
import subprocess
import sys
import time
import urllib.error
import urllib.request
from collections import Counter
from pathlib import Path

HERE = Path(__file__).resolve().parent
DEFAULT_CACHE = HERE / "out" / "deltarun"

# --- Zenodo axis (FORMATS.md; read-only consumer) -------------
CONCEPT = "19238168"
LISTING_URL = ("https://zenodo.org/api/records?q=conceptrecid:"
               f"{CONCEPT}&all_versions=true&size=25")
FILE_URL = "https://zenodo.org/records/{record}/files/{key}"

SCHEMA = "catalog-deltarun-fetch/1"
DIFF_SCHEMA = "catalog-deltarun-diff/1"

PER_TARBALL_DEFAULT = 1 << 30        # 1 GiB — flags ITER_2588_drifts (3.25
                                      # GB) and ITER_Be-W (1.85 GB)
TOTAL_DEFAULT = 256 * 1024 * 1024    # 256 MiB — a fresh plan downloads at
                                      # most this silently; bigger pulls
                                      # (e.g. all 26 changed tarballs of the
                                      # golden pair, ~3.4 GB under the
                                      # per-tarball cap) demand an explicit
                                      # --total-budget
PACE_S = 0.6                         # pacing: bursts draw HTTP 429
BACKOFF_S = (5, 10, 20, 40)          # 429 backoff ladder
TIMEOUT_S = 60
USER_AGENT = "catalog-deltarun-fetch/1 (read-only Zenodo consumer)"

TAR_FLAGS_MAKEFILE = "-xhmzf"        # runs/examples/Makefile:18
TAR_FLAGS_NO_H = "-xmzf"             # -h is create-side; bsdtar rejects it
MD5_LEN = 32


# --- small helpers ----------------------------------------------------

def md5_of(path: Path) -> str:
    """Streaming md5 hex of a file (== `md5sum`, the Makefile check rule)."""
    h = hashlib.md5()
    with path.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


_NET_LAST = [0.0]


def _ssl_context() -> ssl.SSLContext:
    """Verify context with an OS CA bundle fallback: Homebrew Pythons on
    macOS ship no default verify paths (SSLCertVerificationError "unable
    to get local issuer certificate") while /etc/ssl/cert.pem — the same
    system bundle curl uses — verifies Zenodo fine; it is also the
    standard bundle path on Debian/Ubuntu.  Elsewhere: default paths."""
    cafile = "/etc/ssl/cert.pem"
    if Path(cafile).is_file():
        return ssl.create_default_context(cafile=cafile)
    return ssl.create_default_context()


_SSL_CTX = _ssl_context()


def _paced() -> None:
    """Sleep so consecutive requests keep ~PACE_S spacing (429 rule)."""
    dt = time.monotonic() - _NET_LAST[0]
    if _NET_LAST[0] and dt < PACE_S:
        time.sleep(PACE_S - dt)
    _NET_LAST[0] = time.monotonic()


def _open(url: str) -> bytes:
    """GET url with pacing and 429 backoff (a 429 never means 'gone')."""
    for attempt in range(len(BACKOFF_S) + 1):
        _paced()
        req = urllib.request.Request(url, headers={"User-Agent": USER_AGENT})
        try:
            with urllib.request.urlopen(req, timeout=TIMEOUT_S,
                                        context=_SSL_CTX) as resp:
                return resp.read()
        except urllib.error.HTTPError as err:
            if err.code == 429 and attempt < len(BACKOFF_S):
                time.sleep(BACKOFF_S[attempt])
                continue
            raise
    raise SystemExit(f"unreachable: {url}")   # pragma: no cover


def _http_json(url: str) -> dict:
    return json.loads(_open(url))


def _download(url: str, dest: Path) -> int:
    """Download to <dest>.part then atomically rename (no half files)."""
    data = _open(url)
    part = dest.with_name(dest.name + ".part")
    dest.parent.mkdir(parents=True, exist_ok=True)
    part.write_bytes(data)
    part.replace(dest)
    return len(data)


# --- the Zenodo axis ---------------------------------------------------

def fetch_listing(cache: Path, refresh: bool = False) -> tuple[dict, bool]:
    """The version listing, cached under <cache>/records/listing.json.

    Returns (listing, from_cache).  Warm cache never re-fetches; a failed
    refresh falls back to the cached axis with a warning; offline with no
    cache is a clean SystemExit (the axis is a network artifact).
    """
    path = cache / "records" / "listing.json"
    if path.exists() and not refresh:
        return json.loads(path.read_text(encoding="utf-8")), True
    try:
        listing = _http_json(LISTING_URL)
    except Exception as err:                      # offline / HTTP error
        if path.exists():
            print(f"warning: listing refresh failed ({err}); using the "
                  "cached axis", file=sys.stderr)
            return json.loads(path.read_text(encoding="utf-8")), True
        raise SystemExit(
            f"offline: no cached Zenodo axis at {path} and the listing "
            f"fetch failed ({err}) — run once online, then the cache "
            "serves warm runs")
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(listing, indent=2, sort_keys=True) + "\n",
                    encoding="utf-8")
    return listing, False


def build_axis(listing: dict) -> dict:
    """{records: {id -> {version, files:{key -> {size, md5}}}},
    index: {(key, md5) -> [record ids, ascending]}.

    Keyed by RECORD ID (OQ-DR2a-1: record 19370666 has no version string —
    never infer by version).  Ascending id == creation order (axis table), so carriers[0] is the first publication of those bytes.
    """
    records: dict[int, dict] = {}
    index: dict[tuple[str, str], list[int]] = {}
    for hit in listing["hits"]["hits"]:
        rid = hit["id"]
        files: dict[str, dict] = {}
        for f in hit.get("files") or []:
            checksum = f.get("checksum") or ""
            md5 = checksum[4:] if checksum.startswith("md5:") else checksum
            files[f["key"]] = {"size": f["size"], "md5": md5}
            if len(md5) == MD5_LEN:
                index.setdefault((f["key"], md5), []).append(rid)
        records[rid] = {"version": hit["metadata"].get("version"),
                        "files": files}
    for carriers in index.values():
        carriers.sort()
    return {"records": dict(sorted(records.items())), "index": index}


# --- the release-diff input ---------------------------------------------

def load_diff(path: Path) -> dict:
    diff = json.loads(path.read_text(encoding="utf-8"))
    if diff.get("schema") != DIFF_SCHEMA:
        raise SystemExit(f"{path}: expected schema {DIFF_SCHEMA}, got "
                         f"{diff.get('schema')!r} — release-diff output required")
    return diff


def wanted_sides(diff: dict, only: list[str] | None = None) -> list[dict]:
    """(name, side, md5) pairs to fetch: changed -> old+new, added -> new,
    removed -> old, identical -> nothing (bytes are the same both sides —
    fetching them would violate 'only the changed tarballs')."""
    out = []
    for t in diff["tarballs"]:
        if only is not None and t["name"] not in only:
            continue
        sides = {"changed": ("old", "new"), "added": ("new",),
                 "removed": ("old",)}.get(t["status"], ())
        for side in sides:
            out.append({"name": t["name"], "side": side,
                        "md5": t[f"{side}_md5"], "status": t["status"]})
    out.sort(key=lambda s: (s["name"], s["side"]))
    return out


# --- verification + extraction ------------------------------------------

def verify_three_way(name: str, repo_md5: str, zenodo_md5: str,
                     local_md5: str) -> None:
    """Hard fail printing ALL THREE values on any disagreement."""
    if not (repo_md5 == zenodo_md5 == local_md5):
        raise ValueError(
            f"{name}: three-way md5 MISMATCH — repo pin {repo_md5} / "
            f"Zenodo checksum {zenodo_md5} / local md5sum {local_md5}")


def verify_size(name: str, expected: int, actual: int) -> None:
    if expected != actual:
        raise ValueError(f"{name}: size MISMATCH after download — Zenodo "
                         f"files[].size {expected} / local bytes {actual}")


def extract_tarball(tarball: Path, target: Path, expected_top: str) -> dict:
    """The Makefile rule (runs/examples/Makefile:18-19): `tar -xhmzf`
    into a fresh dir, EXACTLY ONE top entry named like the tarball base.

    bsdtar 3.5.3 rejects -h in -x mode (creation-side flag, inert on
    extraction); the fallback drops only -h and runs when the flag
    rejection left the target untouched (empty target == no side effects).
    """
    target.mkdir(parents=True, exist_ok=True)
    proc = subprocess.run(["tar", TAR_FLAGS_MAKEFILE, str(tarball),
                           "-C", str(target)],
                          capture_output=True, text=True)
    flags = TAR_FLAGS_MAKEFILE
    if proc.returncode != 0 and not any(target.iterdir()):
        proc = subprocess.run(["tar", TAR_FLAGS_NO_H, str(tarball),
                               "-C", str(target)],
                              capture_output=True, text=True)
        flags = TAR_FLAGS_NO_H
    if proc.returncode != 0:
        raise SystemExit(f"tar {flags} {tarball.name} failed:\n"
                         f"{proc.stderr.strip()}")
    entries = sorted(p.name for p in target.iterdir())
    if len(entries) != 1:
        raise ValueError(
            f"{tarball.name}: expected exactly ONE top-level entry after "
            f"extraction (Makefile:19), found {len(entries)}: {entries}")
    if entries[0] != expected_top:
        raise ValueError(
            f"{tarball.name}: single top entry {entries[0]!r} != tarball "
            f"base name {expected_top!r} (Makefile:19 `mv $*.tmp/$*`)")
    return {"top_dir": entries[0], "n_top_entries": 1, "tar_flags": flags}


# --- the fetch run -------------------------------------------------------

def _rel(path: Path) -> str:
    """Repo-relative path when inside the repo (manifest convention)."""
    try:
        return path.resolve().relative_to(HERE).as_posix()
    except ValueError:
        return str(path)


def run(diff_path: Path, cache: Path, only: list[str] | None = None,
        per_tarball_budget: int = PER_TARBALL_DEFAULT,
        total_budget: int = TOTAL_DEFAULT,
        force_full_record: bool = False,
        refresh_records: bool = False) -> dict:
    diff = load_diff(diff_path)
    sides = wanted_sides(diff, only)
    if only is not None:
        known = {t["name"] for t in diff["tarballs"]}
        unknown = [n for n in only if n not in known]
        if unknown:
            print(f"warning: --only names not in the diff: {unknown}",
                  file=sys.stderr)
    listing, listing_cached = fetch_listing(cache, refresh_records)
    axis = build_axis(listing)

    entries: list[dict] = []
    plan: list[dict] = []
    for s in sides:
        carriers = axis["index"].get((s["name"], s["md5"]), [])
        if not carriers:
            entries.append({**s, "outcome": "skipped",
                            "skip_kind": "zenodo-absent",
                            "skip_reason": "md5 not carried by any record "
                            "of the concept (OQ-DR2a-2: pre-Zenodo publish "
                            "state) — Zenodo leg honestly absent"})
            continue
        rid = carriers[0]                       # earliest = first publication
        rec = axis["records"][rid]
        finfo = rec["files"][s["name"]]
        base = {"name": s["name"], "side": s["side"], "md5": s["md5"],
                "status": s["status"], "record_id": rid,
                "record_version": rec["version"], "size": finfo["size"]}
        if finfo["size"] > per_tarball_budget:
            entries.append({**base, "outcome": "skipped",
                            "skip_kind": "over-budget",
                            "skip_reason": f"size {finfo['size']} > "
                            f"per-tarball budget {per_tarball_budget}"})
            continue
        tarball = cache / "tarballs" / s["md5"] / s["name"]
        warm = (tarball.exists()
                and tarball.stat().st_size == finfo["size"]
                and md5_of(tarball) == s["md5"])
        entry = {**base, "outcome": None, "_tarball": tarball, "_warm": warm,
                 "_zenodo_md5": finfo["md5"]}
        entries.append(entry)
        plan.append(entry)

    # --- pre-flight guards: refuse BEFORE any download -------------------
    to_download = [e for e in plan if not e["_warm"]]
    total_bytes = sum(e["size"] for e in to_download)
    if total_bytes > total_budget:
        largest = max(to_download, key=lambda e: e["size"])
        raise SystemExit(
            f"planned download {total_bytes} B over {len(to_download)} "
            f"tarballs exceeds --total-budget {total_budget} B (largest: "
            f"{largest['name']} {largest['size']} B) — raise the budget "
            "or narrow with --only")
    per_record: dict[int, set[str]] = {}
    for e in plan:
        per_record.setdefault(e["record_id"], set()).add(e["name"])
    for rid, keys in sorted(per_record.items()):
        n_files = len(axis["records"][rid]["files"])
        if len(keys) > 1 and keys == set(axis["records"][rid]["files"]):
            if not force_full_record:
                raise SystemExit(
                    f"plan would pull EVERY file of record {rid} "
                    f"({n_files} files) — a full-record pull; pass "
                    "--force-full-record to allow it")

    # --- execute: download / verify / extract ----------------------------
    downloaded_bytes = 0
    for e in plan:
        tarball: Path = e.pop("_tarball")
        warm: bool = e.pop("_warm")
        zenodo_md5: str = e.pop("_zenodo_md5")
        expected_top = e["name"][:-len(".tar.gz")]
        url = FILE_URL.format(record=e["record_id"], key=e["name"])
        if warm:
            e["outcome"] = "warm-cache"
            e["repaired"] = False
        else:
            e["repaired"] = tarball.exists()   # corrupt cache: re-download
            downloaded_bytes += _download(url, tarball)
            e["outcome"] = "fetched"
            verify_size(e["name"], e["size"], tarball.stat().st_size)
        local_md5 = md5_of(tarball)
        verify_three_way(e["name"], e["md5"], zenodo_md5, local_md5)
        e["verify"] = {"repo": e["md5"], "zenodo": zenodo_md5,
                       "local": local_md5, "verdict": "green"}
        e["cache_path"] = _rel(tarball)
        extract_dir = cache / "extract" / e["md5"]
        if (extract_dir / expected_top).exists():
            e["extraction"] = {"top_dir": expected_top,
                               "n_top_entries": len(
                                   list(extract_dir.iterdir())),
                               "already_extracted": True}
        else:
            e["extraction"] = extract_tarball(tarball, extract_dir,
                                              expected_top)
            e["extraction"]["already_extracted"] = False
        e["extract_path"] = _rel(extract_dir / expected_top)

    outcomes = Counter(e["outcome"] for e in entries)
    counts = {**{k: outcomes.get(k, 0)
                 for k in ("fetched", "warm-cache", "skipped")},
              "downloaded_bytes": downloaded_bytes}
    return {
        "schema": SCHEMA,
        "diff": {"path": _rel(diff_path), "old": diff["old"]["commit"],
                 "new": diff["new"]["commit"]},
        "axis": {"concept": CONCEPT, "n_records": len(axis["records"]),
                 "listing_cached": listing_cached},
        "budgets": {"per_tarball": per_tarball_budget,
                    "total": total_budget,
                    "force_full_record": force_full_record},
        "counts": counts,
        "sides": entries,
    }


def main(argv: list[str]) -> int:
    p = argparse.ArgumentParser(
        prog="fetch_release_tarballs.py",
        description="Selective fetch + three-way md5 verify of the changed "
                    "tarballs of a release diff ")
    p.add_argument("diff", help="release-diff JSON (catalog-deltarun-diff/1)")
    p.add_argument("--cache", default=str(DEFAULT_CACHE),
                   help="cache dir (default out/deltarun)")
    p.add_argument("--only", nargs="+", metavar="NAME",
                   help="restrict to these tarball names")
    p.add_argument("--per-tarball-budget", type=int,
                   default=PER_TARBALL_DEFAULT,
                   help="skip tarballs larger than this many bytes "
                        f"(default {PER_TARBALL_DEFAULT})")
    p.add_argument("--total-budget", type=int, default=TOTAL_DEFAULT,
                   help="refuse plans downloading more than this many bytes "
                        f"(default {TOTAL_DEFAULT})")
    p.add_argument("--force-full-record", action="store_true",
                   help="allow plans that pull every file of one record")
    p.add_argument("--refresh-records", action="store_true",
                   help="re-fetch the Zenodo version listing")
    p.add_argument("-o", "--output",
                   help="write the report JSON here (default stdout)")
    args = p.parse_args(argv)

    report = run(Path(args.diff), Path(args.cache), args.only,
                 args.per_tarball_budget, args.total_budget,
                 args.force_full_record, args.refresh_records)
    text = json.dumps(report, indent=2, sort_keys=True) + "\n"
    if args.output:
        out = Path(args.output)
        out.parent.mkdir(parents=True, exist_ok=True)
        out.write_text(text, encoding="utf-8")
    else:
        sys.stdout.write(text)
    c = report["counts"]
    print(f"deltarun fetch: {c['fetched']} fetched, {c['warm-cache']} warm, "
          f"{c['skipped']} skipped, {c['downloaded_bytes']} B downloaded",
          file=sys.stderr)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
