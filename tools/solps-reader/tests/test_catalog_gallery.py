"""The case gallery: the bundled fixtures through the real build
path, every display case on one page — pinned so the gallery cannot
silently stop showing a case.
"""

from __future__ import annotations

import shutil
import sys
from pathlib import Path

from solps_reader import floor
from solps_reader import cli

CATALOG = Path(__file__).resolve().parents[1] / "catalog"
sys.path.insert(0, str(CATALOG))


def _catalog_copy(tmp: Path) -> Path:
    dst = tmp / "pkg" / "catalog"
    shutil.copytree(
        CATALOG, dst,
        ignore=shutil.ignore_patterns("out", "__pycache__", "*.pyc"))
    joins = dst / "out" / "deltarun_pages"
    joins.mkdir(parents=True)
    for j in sorted((CATALOG / "out" / "deltarun_pages").glob("*.json")):
        shutil.copy2(j, joins / j.name)
    # the gallery's fixtures ship in tests/fixtures — the copied tree
    # needs them beside it (the checkout shape)
    shutil.copytree(CATALOG.parent / "tests" / "fixtures",
                    dst.parent / "tests" / "fixtures")
    return dst


def test_catalog_gallery_builds_every_case(
        checkout_factory, tmp_path: Path, monkeypatch, capfd) -> None:
    monkeypatch.setenv(floor.REPOS_ENV, str(checkout_factory()))
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    monkeypatch.chdir(tmp_path)
    cat = _catalog_copy(tmp_path)

    rc = cli.main(["catalog", "gallery", "--catalog", str(cat)])
    res = capfd.readouterr()
    assert rc == 0, res.err + res.out
    assert "gallery site:" in res.out

    seat = (tmp_path / "nohome" / ".local" / "share" / "solps_reader"
            / "catalog" / "gallery" / "out")
    site = (seat / "site" / "index.html").read_text(encoding="utf-8")
    # the collision: the same family name in two groups, distinct
    # pages; the examples group is ABSENT in this env (no corpus), so
    # it stays named on the not-cataloged line instead
    assert site.index('grp-h"><a href="alpha/index.html">alpha</a>') \
        < site.index('grp-h"><a href="beta/index.html">beta</a>')
    assert (seat / "site" / "alpha" / "FAM_X" / "run_a"
            / "index.html").is_file()
    assert (seat / "site" / "beta" / "FAM_X" / "run_c"
            / "index.html").is_file()
    # the sick folders: named on the landing, never a failed build
    assert "Not cataloged at last build</h3>" in site
    assert "sick-empty" in site and "sick-junk" in site
    assert "Example runs" in site
    # the automatic family pair (alpha/FAM_X) and the recorded
    # cross-group pair both decked and paged; the landing's light
    # deck index links the family deck and the rail carries its
    # A/B item under the family (owner review of C)
    assert "Recorded pairs (catalog compare)" in site
    assert 'href="comparisons/alpha/FAM_X/index.html"' in site
    assert ">A/B comparison</a>" in site
    assert (seat / "site" / "comparisons" / "alpha" / "FAM_X"
            / "index.html").is_file()
    assert (seat / "site" / "compare"
            / "alpha__FAM_X__run_a__vs__beta__FAM_X__run_c"
            / "index.html").is_file()
    # the gallery never touches the user's own sources or site
    user_seat = (tmp_path / "nohome" / ".local" / "share" / "solps_reader"
                 / "catalog")
    assert not (user_seat / "sources.json").exists()
    assert not (user_seat / "out").exists()
