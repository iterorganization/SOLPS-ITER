"""The mandatory floor gate: one doctrine, two packages.

The SOLPS-ITER tools refuse to install or answer without the floor: a
SOLPS-ITER checkout with every submodule initialized, except the one
pinned non-public submodule that nobody can initialize. SOLPS-GUI and
SOLPS-Tutorials are optional legs: cloned means indexed by the
documentation search; absent is tolerated and named on every face,
never fatal.

This module is deliberate twins: askthedocs and solps-reader each ship
a byte-identical copy, so the checks, the wording, and the verdicts
are the same wherever the gate fires. Change both files together or
neither.

Discovery ladder, first match wins and never a guess beyond:

1. a path handed to ``setup`` explicitly (the checkout itself);
2. ``$ASKTHEDOCS_REPOS_ROOT``: a directory holding SOLPS-ITER, or a
   checkout itself;
3. the launch directory and each of its parents (running from inside
   a clone finds that clone);
4. the repos root this package's ``setup`` recorded beside the index
   it built (the install-time fact; askthedocs writes it, a record
   that no longer resolves simply falls through);
5. ``~/SOLPS-ITER``.

A checkout is recognized by shape, never by name alone: a
``.gitmodules`` file beside a ``modules/`` directory.
"""

from __future__ import annotations

import configparser
import os
import sys
from dataclasses import dataclass, field
from pathlib import Path

# the shared repos-root variable (a directory holding the sibling
# repos, or a checkout itself); one name so both packages resolve the
# same machine the same way
REPOS_ENV = "ASKTHEDOCS_REPOS_ROOT"

# the mandatory repository and the optional legs
ITER_REPO = "SOLPS-ITER"
OPTIONAL_REPOS = ("SOLPS-GUI", "SOLPS-Tutorials")

# the submodule excepted from the floor: pinned in the tree but its
# repository is not public, so no one can ever initialize it
EXCEPTED_SUBMODULE = "modules/adas"

# the install-time repos root: setup writes it beside the index it
# builds (one plain-text absolute path, one line), every later gate
# or freshness check reads it back - the index knows where it was
# born.  Derived from the package name so the byte-identical twins
# each keep their own share; a record that no longer resolves is
# never trusted, the ladder just falls through.
RECORD_NAME = "repos-root"


def _package_share(home: Path) -> Path:
    """This package's per-user share directory (mirrors the index
    placement the setup verb uses)."""
    package = (__package__ or "askthedocs").split(".")[0]
    return Path(home) / ".local" / "share" / package


def record_root(root: Path, *, share: Path | None = None) -> Path:
    """Write the install-time repos root beside this package's index
    (best effort with a loud note: a share too broken to hold one
    line cannot hold the index either, and the caller's real work
    must still run)."""
    share = (_package_share(Path.home()) if share is None
             else Path(share))
    try:
        share.mkdir(parents=True, exist_ok=True)
        record = share / RECORD_NAME
        record.write_text(f"{Path(root).resolve()}\n", encoding="utf-8")
        return record
    except OSError as exc:
        print(f"note: could not record the repos root in {share}: "
              f"{exc}", file=sys.stderr)
        return share / RECORD_NAME


def _recorded_root(home: Path) -> Path | None:
    """The recorded repos root, or None when no readable record
    holds a path."""
    try:
        text = (_package_share(home) / RECORD_NAME).read_text(
            encoding="utf-8").strip()
    except OSError:
        return None
    return Path(text) if text else None

# checkout shape: these two, together, are what the tools index
_GITMODULES = ".gitmodules"
_MODULES_DIR = "modules"


class FloorError(Exception):
    """A loud discovery or gate refusal; the message is ready to
    print and always names the fix."""


@dataclass
class SubmoduleLeg:
    """One submodule declared by the checkout."""

    path: str          # repo-relative, e.g. modules/B2.5
    initialized: bool  # a .git sits inside the submodule directory
    excepted: bool     # the pinned non-public submodule


@dataclass
class FloorReport:
    """Everything the gate learned, renderable as status or refusal."""

    root: Path                      # directory holding the sibling repos
    iter_path: Path                 # the SOLPS-ITER checkout itself
    via: str                        # which ladder rung found it
    submodules: list[SubmoduleLeg] = field(default_factory=list)
    optional: list[tuple[str, bool]] = field(default_factory=list)  # (name, present)
    missing: list[tuple[str, Path, str]] = field(default_factory=list)  # (what, where, remedy)

    @property
    def ok(self) -> bool:
        return not self.missing

    @property
    def repos(self) -> dict[str, Path]:
        """SOLPS-ITER plus every optional leg present on disk."""
        out = {ITER_REPO: self.iter_path}
        for name, present in self.optional:
            if present:
                out[name] = self.root / name
        return out


def is_checkout(path: Path) -> bool:
    """Checkout shape: a .gitmodules file beside a modules/ directory."""
    return (path / _GITMODULES).is_file() and (path / _MODULES_DIR).is_dir()


def _repos_root_at(candidate: Path) -> Path | None:
    """The sibling-repos root a candidate resolves to, or None.

    Accepts both shapes: a checkout itself (root is its parent), or a
    directory holding the checkout (root is the directory).
    """
    candidate = Path(candidate)
    if is_checkout(candidate):
        return candidate.parent
    if is_checkout(candidate / ITER_REPO):
        return candidate
    return None


def declared_submodules(iter_path: Path) -> list[str]:
    """Submodule paths in .gitmodules order (the declaration list).

    Read from the file, not from git: the gate must answer on
    machines without git, and the file is the shape marker anyway.
    """
    parser = configparser.ConfigParser(strict=False, interpolation=None)
    parser.read(iter_path / _GITMODULES, encoding="utf-8")
    paths: list[str] = []
    for section in parser.sections():
        if parser.has_option(section, "path"):
            value = parser.get(section, "path").strip()
            if value:
                paths.append(value)
    return paths


def _ladder_stop(tried: list[str]) -> str:
    lines = [
        "error: no SOLPS-ITER checkout found. The gate looked, in "
        "order, at:",
        "",
        "  1. the path given to setup",
        f"  2. ${REPOS_ENV} (a directory holding SOLPS-ITER, or a "
        "checkout itself)",
        "  3. the launch directory and its parents",
        "  4. the repos root this package's setup recorded",
        "  5. ~/SOLPS-ITER",
        "",
    ]
    if tried:
        lines.append("It looked at: " + "; ".join(tried))
        lines.append("")
    lines += [
        "fix: clone the repository with its submodules, then point the "
        "tools at it:",
        "  git clone --recurse-submodules <SOLPS-ITER url>",
        "  <tool> setup /path/to/SOLPS-ITER",
    ]
    return "\n".join(lines)


def discover(explicit: Path | str | None = None, *,
             env: dict[str, str] | None = None,
             home: Path | None = None,
             cwd: Path | None = None) -> tuple[Path, Path, str]:
    """Resolve (repos root, SOLPS-ITER path, rung) through the ladder.

    Raises :class:`FloorError` with the ladder-stop message when no
    rung answers, or a named-shape refusal when a rung was given but
    does not resolve to a checkout.
    """
    env = dict(os.environ) if env is None else dict(env)
    home = Path.home() if home is None else Path(home)
    cwd = Path.cwd() if cwd is None else Path(cwd)
    tried: list[str] = []

    if explicit is not None:
        path = Path(explicit).expanduser()
        root = _repos_root_at(path)
        if root is not None:
            return root, root / ITER_REPO, "the path given to setup"
        raise FloorError(
            f"error: not a SOLPS-ITER checkout: {path}\n"
            f"       a checkout carries a {_GITMODULES} file beside a "
            f"{_MODULES_DIR}/ directory; the optional sibling repos "
            "sit beside the checkout, not inside it")

    env_value = env.get(REPOS_ENV)
    if env_value:
        path = Path(env_value).expanduser()
        root = _repos_root_at(path)
        if root is not None:
            return root, root / ITER_REPO, f"${REPOS_ENV}"
        tried.append(f"${REPOS_ENV}={path} (not a checkout)")

    # the launch directory and every parent: running from inside a
    # clone (the tools ship inside it) finds that clone
    for candidate in [cwd, *cwd.parents]:
        root = _repos_root_at(candidate)
        if root is not None:
            return root, root / ITER_REPO, f"the launch directory (via {candidate})"

    # the install-time fact: the root setup stood beside when it
    # built this package's index (the index knows where it was born;
    # a moved or deleted corpus falls through, never trusts a stale
    # record)
    recorded = _recorded_root(home)
    if recorded is not None:
        root = _repos_root_at(recorded)
        if root is not None:
            return root, root / ITER_REPO, \
                f"the recorded root {recorded} (setup wrote it)"
        tried.append(f"the recorded root {recorded} (not a checkout)")

    home_clone = home / ITER_REPO
    if is_checkout(home_clone):
        return home, home_clone, "~/SOLPS-ITER"

    raise FloorError(_ladder_stop(tried))


def check(root: Path, iter_path: Path, via: str) -> FloorReport:
    """Run the floor checks over a resolved checkout.

    Every declared submodule must be initialized (a ``.git`` inside
    its directory; stray files never count), except the pinned
    non-public submodule. Optional legs are reported present or
    absent, never refused.
    """
    report = FloorReport(root=Path(root), iter_path=Path(iter_path), via=via)
    for path in declared_submodules(report.iter_path):
        full = report.iter_path / path
        excepted = path == EXCEPTED_SUBMODULE
        initialized = (full / ".git").exists()
        report.submodules.append(
            SubmoduleLeg(path=path, initialized=initialized,
                         excepted=excepted))
        if not excepted and not initialized:
            report.missing.append((
                path, full, f"git submodule update --init {path}"))
    for name in OPTIONAL_REPOS:
        report.optional.append((name, (report.root / name).is_dir()))
    return report


def check_floor(explicit: Path | str | None = None, *,
                env: dict[str, str] | None = None,
                home: Path | None = None,
                cwd: Path | None = None) -> FloorReport:
    """Discover the checkout and run the floor checks in one call."""
    root, iter_path, via = discover(explicit, env=env, home=home, cwd=cwd)
    return check(root, iter_path, via)


def format_report(report: FloorReport) -> str:
    """The status block `setup` prints when the floor holds."""
    lines = [
        f"SOLPS-ITER checkout: {report.iter_path}  (found via {report.via})",
        "submodules:",
    ]
    for leg in report.submodules:
        if leg.excepted:
            lines.append(f"  {leg.path:<18} excepted (pinned non-public "
                         "submodule; nobody can initialize it)")
        else:
            lines.append(f"  {leg.path:<18} "
                         + ("initialized" if leg.initialized else "NOT INITIALIZED"))
    lines.append("optional legs:")
    for name, present in report.optional:
        state = "present" if present else "absent (optional; not indexed on this machine)"
        lines.append(f"  {name:<18} {state}")
    lines.append("floor: complete" if report.ok else "floor: INCOMPLETE")
    return "\n".join(lines)


def format_refusal(report: FloorReport) -> str:
    """The refusal block every gate prints when the floor fails.

    Names each missing piece with its one-line remedy; nothing was
    built or changed.
    """
    lines = [
        "error: the floor is incomplete: the tools refuse to work "
        "without a SOLPS-ITER checkout whose submodules are "
        "initialized. Missing:",
        "",
    ]
    for what, where, remedy in report.missing:
        lines.append(f"  {what} at {where}")
        lines.append(f"         remedy: {remedy}")
    lines += [
        "",
        f"(the pinned non-public submodule {EXCEPTED_SUBMODULE} is "
        "excepted and never required)",
        "nothing was built or changed.",
    ]
    return "\n".join(lines)
