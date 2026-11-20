"""Shared synthetic fixture: a floor-perfect SOLPS-ITER checkout.

Everything is built under ``tmp_path``: no run data, no network, no
real repositories, no layout assumptions. The submodule paths mirror
the real declaration list so the excepted-submodule logic is exercised
exactly as it runs in production.
"""

from __future__ import annotations

from pathlib import Path

# the real declaration list, order included (the floor reads
# .gitmodules in file order)
GITMODULES = """\
[submodule "B2.5"]
\tpath = modules/B2.5
\turl = ../B2.5.git
[submodule "Carre"]
\tpath = modules/Carre
\turl = ../CARRE.git
[submodule "DivGeo"]
\tpath = modules/DivGeo
\turl = ../DivGeo.git
[submodule "Eirene"]
\tpath = modules/Eirene
\turl = ../EIRENE.git
[submodule "ADAS"]
\tpath = modules/adas
\turl = ssh://git@git.iter.org/imex/amns-adas.git
"""

# every declared submodule except the pinned non-public one
INITIALIZABLE = ("modules/B2.5", "modules/Carre", "modules/DivGeo",
                 "modules/Eirene")


def make_checkout(tmp: Path, *, base: str = "repos",
                  iter_name: str = "SOLPS-ITER",
                  uninitialized: frozenset[str] = frozenset(),
                  optional: tuple[str, ...] = ()) -> Path:
    """A synthetic repos root: a checkout shaped like SOLPS-ITER (named
    *iter_name* — a clone may carry any name), with every
    initializable submodule initialized except *uninitialized*; the
    optional legs named in *optional* exist beside it."""
    root = tmp / base
    iter_repo = root / iter_name
    (iter_repo / "modules").mkdir(parents=True)
    (iter_repo / ".gitmodules").write_text(GITMODULES, encoding="utf-8")
    for sub in INITIALIZABLE:
        leg = iter_repo / sub
        leg.mkdir()
        if sub not in uninitialized:
            (leg / ".git").mkdir()
    # the excepted submodule is declared but never initialized
    (iter_repo / "modules" / "adas").mkdir()
    for name in optional:
        (root / name).mkdir()
    return root


import pytest


@pytest.fixture
def checkout_factory(tmp_path):
    """make_checkout bound to this test's tmp_path."""
    return lambda **kw: make_checkout(tmp_path, **kw)


@pytest.fixture(autouse=True)
def _clean_catalog_root(monkeypatch):
    """Catalog-root hygiene for every test: no process-level override
    and no environment redirect survive INTO a test (the --home flag
    sets a process-level override; one test's redirect must never
    seat another test's catalog), no builders-tree environment var
    leaks in, and the recorded-tree rung stays neutral unless a test
    arms it (the real machine's record must never resolve a test's
    tree)."""
    from solps_reader import catalog_sources
    from solps_reader import floor
    catalog_sources.set_catalog_root(None)
    monkeypatch.delenv(catalog_sources.CATALOG_HOME_ENV, raising=False)
    monkeypatch.delenv("SOLPS_READER_CATALOG", raising=False)
    # repos-root ladder hygiene: neither the package variable nor
    # $SOLPSTOP leaks in from the launching shell
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)
    monkeypatch.delenv("SOLPSTOP", raising=False)
    monkeypatch.setattr(catalog_sources, "recorded_tree", lambda: None)
    yield
    catalog_sources.set_catalog_root(None)
