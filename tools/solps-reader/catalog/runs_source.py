#!/usr/bin/env python3
"""One runs-discovery ladder for every consumer of run data.

The manifest builder and the CLI's ``catalog build``
all find the runs tree through THIS module — never a private walk —
so the same command behaves the same on every machine (the retired
single-machine symlink bridge is gone; nothing resolves through a
pointer that exists on one machine only).

Ladder, first match wins:

1. an explicit path handed by the caller (``--runs``); must be an
   existing directory — the caller is trusted to point at a runs
   root (a directory whose subdirectories are run families);
2. the per-user share — ``~/.local/share/solps_reader/runs/examples``
   — where fetched bulk seats (the placement doctrine: generated and
   fetched data lands in the share, never the checkout);
3. the SOLPS-ITER checkout the floor ladder resolves, its
   ``runs/examples`` (the checkout-beside shape; the floor's own ladder —
   ``$ASKTHEDOCS_REPOS_ROOT``, launch parents, the recorded root,
   ``~/SOLPS-ITER`` — does the finding, one checkout-resolution
   definition for both packages).

No rung answering raises :class:`RunsError` naming every rung tried
and the remedy (pass ``--runs``, seat data in the share, or stand a
checkout the floor ladder can find).
"""
from __future__ import annotations

import os
from pathlib import Path

from solps_reader import floor
from solps_reader import catalog_sources
from solps_reader.floor import _package_share

#: run data seats under the share as ``runs/examples`` — mirroring
#: the checkout's own layout so every consumer sees one shape
SHARE_RUNS = ("runs", "examples")


class RunsError(RuntimeError):
    """No rung of the runs ladder answered."""


def resolve_examples(
    explicit: str | Path | None = None, *,
    env: dict[str, str] | None = None,
    home: Path | None = None,
    cwd: Path | None = None,
) -> tuple[Path, str]:
    """Return ``(runs_root, rung)`` — the root whose subdirectories
    are run families, and which ladder rung answered."""
    env = dict(os.environ) if env is None else dict(env)
    home = Path.home() if home is None else Path(home)
    cwd = Path.cwd() if cwd is None else Path(cwd)
    tried: list[str] = []

    if explicit is not None:
        path = Path(explicit).expanduser()
        if path.is_dir():
            return path, "the path given to --runs"
        raise RunsError(
            f"error: not a directory: {path} (the --runs value must be "
            "a runs root: a directory whose subdirectories are run "
            "families)")

    share = _package_share(home).joinpath(*SHARE_RUNS)
    if share.is_dir():
        return share, f"the per-user share ({share})"

    try:
        _root, iter_path, via = floor.discover(
            env=env, home=home, cwd=cwd)
    except floor.FloorError as exc:
        tried.append(f"the floor ladder (no checkout found): {exc}")
    else:
        examples = iter_path / "runs" / "examples"
        if examples.is_dir():
            return examples, f"the checkout the floor ladder resolved ({via})"
        tried.append(
            f"the checkout the floor ladder resolved ({via}) has no "
            f"runs/examples under {iter_path}")

    raise RunsError(_stop(tried))


def _stop(tried: list[str]) -> str:
    lines = [
        "error: no runs tree found: every rung of the ladder was tried:"]
    if tried:
        lines += [f"  - {t}" for t in tried]
    lines += [
        "  - the per-user share runs/examples (fetched data seats there)",
        "remedy: pass --runs <path>, seat run data in the share, or stand",
        "a SOLPS-ITER checkout the floor ladder can find (the package",
        "README, 'The catalog in depth')",
    ]
    return "\n".join(lines)


# ------------------------------------------------------------- the groups

#: the fixed examples group: always LAST in display order, rendered
#: by the ladder above, never a stored source
EXAMPLES_SLUG = "example-runs"
EXAMPLES_LABEL = "Example runs"


def _user_group(path: Path, label: str) -> dict:
    slug = catalog_sources.slugify(label)
    return {"slug": slug, "label": label, "path": path,
            "status": "ok", "via": "a user runs folder"}


def resolve_groups(
    explicit: list[str | Path] | None = None,
    *,
    include_examples: bool = True,
    env: dict[str, str] | None = None,
    home: Path | None = None,
    cwd: Path | None = None,
    sources_file: Path | None = None,
) -> list[dict]:
    # (sources_file: the CLI hands its resolved sources path down so
    # builder subprocesses never guess a home)
    """The display-ordered group list every catalog consumer walks.

    User groups come from the remembered sources file, or from the
    one-shot ``explicit`` paths (each becomes a group labeled by its
    folder name — ``catalog add --label`` is the remembered way to
    name them).  The examples group ALWAYS follows last, resolved
    by the ladder above; when it cannot resolve while user groups
    stand, it degrades to a named absent entry (never a crash);
    when nothing resolves at all, :class:`RunsError` names every
    group and the remedy.

    Each record: ``slug`` (the group's address), ``label`` (shown),
    ``path`` (the runs root; None for an unresolved examples group),
    ``status`` (ok / absent / no-runs), ``via`` (where it came from).
    Sick groups (absent, or present with no recognizable runs) stay
    in the list — named and skipped by the consumers, never hidden.
    """
    env = dict(os.environ) if env is None else dict(env)
    home = Path.home() if home is None else Path(home)
    cwd = Path.cwd() if cwd is None else Path(cwd)
    groups: list[dict] = []
    if explicit is not None:
        # an EXPLICIT list, even empty, is the whole user-group set
        # (the gate's --examples-only passes []; None = remembered)
        for one in explicit:
            path = Path(one).expanduser()
            if not path.is_dir():
                raise RunsError(
                    f"error: not a directory: {path} (the --runs value "
                    "must be a runs root: a directory whose "
                    "subdirectories are run families)")
            groups.append(_user_group(path.resolve(), path.name))
    else:
        data = catalog_sources.load(sources_file)
        for entry in data["sources"]:
            path = Path(entry["path"]).expanduser()
            groups.append(_user_group(
                path, entry.get("label") or path.name))
    # address discipline: slugs must exist, differ, and stay off the
    # site's own namespaces — the one-shot path gets the same refusal
    # the add verb enforces on the remembered list
    seen: dict[str, str] = {}
    for g in groups:
        if not g["slug"]:
            raise RunsError(
                f"error: the folder name {g['label']!r} has no address "
                "characters (a-z, 0-9, '-'); add the folder with "
                "'catalog add <path> --label NAME' instead")
        if g["slug"] in catalog_sources.RESERVED_SLUGS:
            raise RunsError(
                f"error: the folder name {g['label']!r} would take the "
                f"group address '{g['slug']}', a name the site already "
                "uses; add the folder with 'catalog add <path> "
                "--label NAME' instead")
        if g["slug"] in seen:
            raise RunsError(
                f"error: two groups would take the address "
                f"'{g['slug']}' ({seen[g['slug']]}, {g['path']}): "
                "add one of them with 'catalog add <path> --label "
                "NAME' instead")
        seen[g["slug"]] = str(g["path"])
    for g in groups:
        if not g["path"].is_dir():
            g["status"] = "absent"
        elif not catalog_sources.has_runs(g["path"]):
            g["status"] = "no-runs"
    if include_examples:
        try:
            ex_path, rung = resolve_examples(
                None, env=env, home=home, cwd=cwd)
        except RunsError as exc:
            if not groups:
                raise          # no user groups at all: the ladder's own
                # refusal (rungs + remedies) is the honest message
            if any(g["status"] == "ok" for g in groups):
                groups.append({"slug": EXAMPLES_SLUG,
                               "label": EXAMPLES_LABEL,
                               "path": None, "status": "absent",
                               "via": f"unresolved: {exc}"})
        else:
            groups.append({
                "slug": EXAMPLES_SLUG, "label": EXAMPLES_LABEL,
                "path": ex_path,
                "status": ("ok" if catalog_sources.has_runs(ex_path)
                           else "no-runs"),
                "via": rung})
    if not any(g["status"] == "ok" for g in groups):
        raise RunsError(_groups_stop(groups))
    return groups


def _groups_stop(groups: list[dict]) -> str:
    lines = ["error: no catalogable group: every group was absent "
             "or empty:"]
    for g in groups:
        why = ("no runs found under it" if g["status"] == "no-runs"
               else "not a directory")
        lines.append(f"  - {g['label']} ({g['path']}): {why}")
    lines += [
        "remedy: 'solps-reader catalog add <path>' your runs folders ",
        "('catalog list' shows them), or pass --runs <path>; a runs ",
        "root's subdirectories are run families carrying solver ",
        "outputs (the package README, 'The catalog in depth')",
    ]
    return "\n".join(lines)
