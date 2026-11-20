"""The remembered catalog sources: the user's own runs folders, in
display order, plus the recorded run comparisons.

One JSON file in the catalog root — the per-user share by default
(the placement doctrine: remembered and generated data seats in the
share, never the checkout).  The file is the single authority for
``catalog build`` run without ``--runs``: groups appear in the order
they are listed here; the example runs always follow last and are
rendered by the runs ladder, never stored in this file.

The catalog root moves wholesale (the sources file, the analysis
cache seated beside it, every built site seat) when home filesystems
are quota-limited: every catalog verb takes ``--home PATH``, and
``$SOLPS_READER_HOME`` moves it for a whole shell — see
:func:`catalog_root`.

Every refusal names its remedy.  Labels slug to ``[a-z0-9-]``; a
slug that would collide with the site's own namespaces or with
another group is refused, never silently uniquified — two folders
may share a basename, the second one must take ``--label``.
"""
from __future__ import annotations

import json
import os
import re
import sys
from pathlib import Path

#: the site's own address namespaces and the fixed examples label —
#: a group slug may never take any of these (run pages and the
#: site's own sections live under them)
RESERVED_SLUGS = frozenset({
    "example-runs",   # the fixed examples group (rendered, never stored)
    "comparisons",    # site/comparisons/ — the family pair pages
    "compare",        # site/compare/ — the compare verb's decks
    "switches",       # site/switches/ — the switch join page
    "deltarun",       # site/deltarun/ — the release axis
    "fonts",          # site/fonts/ — the vendored typefaces
})

#: run-discovery markers, single-sourced here: a directory holding
#: any of these files is a run (the catalog tree's
#: build_manifests.find_run_dirs walks on the same triple)
RUN_MARKERS = ("fort.44", "b2fstate", "b2time.nc")

_SLUG_STRIP = re.compile(r"[^a-z0-9]+")

#: where the whole catalog lives, moved wholesale for quota-limited
#: home filesystems (shared clusters): the remembered sources file,
#: the analysis cache seated beside it, and every built site seat
#: derive from this one root
CATALOG_HOME_ENV = "SOLPS_READER_HOME"

_catalog_root_override: Path | None = None


class SourcesError(RuntimeError):
    """A sources-file operation refused; the message names the remedy."""


def set_catalog_root(path: str | os.PathLike | None) -> None:
    """Process-level catalog-root override (the CLI's ``--home``
    flag).  ``None`` clears it; the environment variable and the
    default share remain in force below it."""
    global _catalog_root_override
    _catalog_root_override = (None if path is None
                              else Path(path).expanduser())


def default_share_root(home: Path | None = None) -> Path:
    """The pure default catalog root, ignoring any override: the
    per-user share (what the seat wording names when nothing
    redirected it)."""
    home = Path.home() if home is None else Path(home)
    return home / ".local" / "share" / "solps_reader" / "catalog"


def catalog_root(home: Path | None = None) -> Path:
    """The catalog root, one resolution for every consumer (the
    sources file, the cache, the build/open/gallery seats).

    Ladder: the ``--home`` process override >
    ``$SOLPS_READER_HOME`` > the per-user share under
    *home*.  An empty environment value counts as unset.
    """
    if _catalog_root_override is not None:
        return _catalog_root_override
    env_value = os.environ.get(CATALOG_HOME_ENV)
    if env_value:
        return Path(env_value).expanduser()
    return default_share_root(home)


def sources_path(home: Path | None = None) -> Path:
    """The sources file: ``<catalog root>/sources.json`` — the
    per-user share by default, wherever the catalog home points
    otherwise (see :func:`catalog_root`)."""
    return catalog_root(home) / "sources.json"


#: the builders tree's recorded location, one absolute path under
#: the catalog root; the verbs' last-resort rung so they work from
#: any directory after one setup (the same doctrine as the recorded
#: repos root)
_TREE_RECORD = "catalog-tree"


def recorded_tree() -> Path | None:
    """The catalog tree ``setup`` recorded (the builders folder
    inside the package checkout).  None when never recorded or the
    record went stale (the folder no longer holds the builders)."""
    try:
        line = (catalog_root() / _TREE_RECORD).read_text(
            encoding="utf-8").strip()
    except OSError:
        return None
    tree = Path(line)
    return tree if (tree / "build_catalog.py").is_file() else None


def record_tree(tree: Path) -> None:
    """Record the catalog tree location (setup does this once when
    the tree stands beside the install or under the launch
    directory); one absolute path, written atomically."""
    root = catalog_root()
    root.mkdir(parents=True, exist_ok=True)
    tmp = root / (_TREE_RECORD + ".tmp")
    tmp.write_text(str(Path(tree).resolve()) + "\n", encoding="utf-8")
    tmp.replace(root / _TREE_RECORD)


def slugify(label: str) -> str:
    """The group's address slug: lowercase, ``[a-z0-9-]``, runs of
    non-address characters folded to one dash."""
    return _SLUG_STRIP.sub("-", label.strip().lower()).strip("-")


def load(path: Path | None = None) -> dict:
    """The remembered state; a missing file IS the empty state (a
    fresh machine is not an error).  Unknown keys pass through."""
    path = sources_path() if path is None else Path(path)
    if not path.is_file():
        return {"sources": [], "comparisons": []}
    try:
        data = json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError) as exc:
        raise SourcesError(
            f"error: cannot read the sources file {path}: {exc} "
            "(fix or remove the file, then re-add your folders with "
            "'solps-reader catalog add')") from None
    if not isinstance(data, dict):
        raise SourcesError(
            f"error: the sources file {path} is not a JSON object "
            "(fix or remove the file, then re-add your folders with "
            "'solps-reader catalog add')")
    data.setdefault("sources", [])
    data.setdefault("comparisons", [])
    return data


def save(path: Path | None, data: dict) -> None:
    """Write the state atomically (a half-written sources file would
    silently drop groups)."""
    path = sources_path() if path is None else Path(path)
    path.parent.mkdir(parents=True, exist_ok=True)
    tmp = path.with_name(path.name + ".tmp")
    tmp.write_text(
        json.dumps(data, indent=2, sort_keys=True) + "\n",
        encoding="utf-8")
    tmp.replace(path)


def _entry_slug(entry: dict) -> str:
    return slugify(entry.get("label", ""))


def _match(entry: dict, ref: str) -> bool:
    """A group reference matches by slug, exact label, or path."""
    if _entry_slug(entry) == ref or entry.get("label") == ref:
        return True
    try:
        return Path(entry["path"]) == Path(ref).expanduser().resolve()
    except (KeyError, OSError):
        return False


def add(path: Path | None, folder: str, *, label: str | None = None,
        before: str | None = None) -> dict:
    """Remember one runs folder as a group; returns the stored entry.
    ``before`` inserts ahead of the referenced group (default: after
    the last remembered group — the examples always follow anyway)."""
    root = Path(folder).expanduser()
    try:
        root = root.resolve()
    except OSError as exc:
        raise SourcesError(
            f"error: cannot resolve {folder}: {exc}") from None
    if not root.is_dir():
        raise SourcesError(
            f"error: not a directory: {root} (create or mount the "
            "folder, then 'solps-reader catalog add' it again — a "
            "runs root's subdirectories are run families)")
    label = label if label else root.name
    slug = slugify(label)
    if not slug:
        raise SourcesError(
            f"error: the label {label!r} has no address characters "
            "(a-z, 0-9, '-') — pass --label with a name that keeps "
            "at least one of them")
    data = load(path)
    if slug in RESERVED_SLUGS:
        raise SourcesError(
            f"error: the label {label!r} would take the group "
            f"address '{slug}', a name the site already uses — "
            "pass --label with another word")
    for entry in data["sources"]:
        if _entry_slug(entry) == slug:
            raise SourcesError(
                f"error: the label {label!r} would take the group "
                f"address '{slug}', already held by {entry['path']} — "
                "pass --label with another word")
    entry = {"path": str(root), "label": label}
    if before is None:
        data["sources"].append(entry)
    else:
        at = next((i for i, e in enumerate(data["sources"])
                   if _match(e, before)), None)
        if at is None:
            current = ", ".join(e["label"] for e in data["sources"]) \
                or "none yet"
            raise SourcesError(
                f"error: --before matched no group: {before} "
                f"(current groups: {current})")
        data["sources"].insert(at, entry)
    save(path, data)
    return entry


def remove(path: Path | None, ref: str) -> dict:
    """Drop one group; returns the removed entry.  The reference may
    be the group's label or its path; an ambiguous or unknown
    reference is refused with the current groups named."""
    data = load(path)
    hits = [e for e in data["sources"] if _match(e, ref)]
    if not hits:
        current = ", ".join(e["label"] for e in data["sources"]) \
            or "none remembered"
        raise SourcesError(
            f"error: no group matches {ref} (current groups: "
            f"{current})")
    if len(hits) > 1:
        names = ", ".join(sorted(e["label"] for e in hits))
        raise SourcesError(
            f"error: {ref} matches more than one group ({names}) — "
            "name one exactly")
    entry = hits[0]
    data["sources"] = [e for e in data["sources"] if e is not entry]
    save(path, data)
    return entry


#: the positional words ``catalog move`` accepts beside an ordinal
MOVE_WORDS = ("first", "last", "up", "down")


def move(path: Path | None, ref: str, position: str) -> tuple[dict, int]:
    """Reposition one remembered group — the display order is the
    user's, never auto-sorted.  ``position`` is a
    1-based ordinal (matching ``catalog list``'s numbering; out-of-
    range lands at the ends) or one of first / last / up / down.
    Returns the entry and its 1-based position AFTER the move; a
    position the group already holds changes nothing (the file is
    still rewritten — the outcome is what was asked)."""
    data = load(path)
    hits = [e for e in data["sources"] if _match(e, ref)]
    if not hits:
        current = ", ".join(e["label"] for e in data["sources"]) \
            or "none remembered"
        raise SourcesError(
            f"error: no group matches {ref} (current groups: "
            f"{current})")
    if len(hits) > 1:
        names = ", ".join(sorted(e["label"] for e in hits))
        raise SourcesError(
            f"error: {ref} matches more than one group ({names}) — "
            "name one exactly")
    if len(data["sources"]) < 2:
        raise SourcesError(
            "error: nothing to move — one group is always first "
            "(add another with 'solps-reader catalog add' first)")
    entry = hits[0]
    at = data["sources"].index(entry)
    word = position.strip().lower()
    n = len(data["sources"])
    if word in MOVE_WORDS:
        want = {"first": 1, "last": n, "up": at, "down": at + 2}[word]
    else:
        try:
            want = int(word)
        except ValueError:
            raise SourcesError(
                f"error: {position!r} is not a position — give a "
                f"number (1-{n}, as 'catalog list' numbers them) or "
                "one of first / last / up / down") from None
        want = max(1, min(n, want))
    data["sources"].pop(at)
    data["sources"].insert(want - 1, entry)
    save(path, data)
    return entry, data["sources"].index(entry) + 1


def has_runs(root: Path) -> bool:
    """True when any directory under ``root`` holds a run marker —
    the same predicate ``find_run_dirs`` walks, answered as a
    first-hit probe (status lines, not manifests).  A tree that
    cannot be read answers False with one named line (the recovery
    doctrine: unreadable folders are named, never fatal)."""
    try:
        for d in root.rglob("*"):
            if d.is_dir() and any((d / m).exists() for m in RUN_MARKERS):
                return True
    except OSError as exc:
        print(f"note: cannot read under {root} "
              f"({exc.strerror or type(exc).__name__}); "
              "treating it as holding no runs", file=sys.stderr)
    return False


# ------------------------------------------------------- the comparisons

def add_comparison(path: Path | None, a: str, b: str) -> dict:
    """Record an A/B run comparison.  Selectors are the
    group-qualified run names the site shows
    (``archive/ITER_2275/run_x``); existence is NOT checked here —
    runs come and go, the BUILD names a skip for a comparison whose
    runs no group provides (the honest-absence pattern).  A pair is
    recorded once regardless of order.  A filesystem PATH is refused
    with the two-step remedy (the field poisoning shape: a path was
    once recorded as a name and no build could ever resolve it)."""
    for side in (a, b):
        p = Path(side)
        # absolute paths and explicit relative-path spellings are the
        # field failure shape; a bare group/family/run name is never
        # refused here even when a like-named folder happens to sit
        # beside the working directory (the name IS the address)
        if p.is_absolute() or side.startswith(("./", "../")):
            raise SourcesError(
                f"error: {side!r} looks like a filesystem path; compare "
                "takes the group-qualified run names the site shows "
                "(group/family/run) - 'solps-reader catalog add <runs "
                "folder>' first, 'solps-reader catalog build' once, then "
                "compare by the names the landing shows")
        if "/" not in side:
            raise SourcesError(
                f"error: {side!r} is not a group-qualified run name - "
                "name both sides as group/family/run, exactly as the "
                "site shows them")
    if a == b:
        raise SourcesError(
            "error: a comparison needs two DIFFERENT runs "
            f"({a} named twice)")
    data = load(path)
    for c in data["comparisons"]:
        if {c.get("a"), c.get("b")} == {a, b}:
            raise SourcesError(
                f"error: {a} vs {b} is already recorded — "
                "'solps-reader catalog compare --remove "
                f"{c['a']} {c['b']}' drops it")
    entry = {"a": a, "b": b}
    data["comparisons"].append(entry)
    save(path, data)
    return entry


def remove_comparison(path: Path | None, a: str, b: str) -> dict:
    """Drop one recorded comparison (either order matches); an
    unknown pair is refused with the recorded ones named."""
    data = load(path)
    hits = [c for c in data["comparisons"]
            if {c.get("a"), c.get("b")} == {a, b}]
    if not hits:
        current = "; ".join(f"{c['a']} vs {c['b']}"
                            for c in data["comparisons"]) or "none recorded"
        raise SourcesError(
            f"error: no recorded comparison matches {a} vs {b} "
            f"({current})")
    entry = hits[0]
    data["comparisons"] = [c for c in data["comparisons"]
                           if c is not entry]
    save(path, data)
    return entry
