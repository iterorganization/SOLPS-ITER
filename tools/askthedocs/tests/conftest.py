"""Shared synthetic fixtures: a floor-perfect SOLPS-ITER checkout and
a minimal chunk store.

Everything is built under ``tmp_path``: no run data, no network, no
real repositories, no layout assumptions. The submodule paths mirror
the real declaration list so the excepted-submodule logic is exercised
exactly as it runs in production. Exposed as fixture factories (no
cross-module imports: the suites of the two shipped packages run side
by side without module-name collisions).
"""

from __future__ import annotations

from pathlib import Path

import pytest

from askthedocs import state, store

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


def make_store(dir_path: Path, *, source_file: str | None = None,
               text: str = "synthetic chunk text about drifts") -> Path:
    """A minimal but honest chunk store: one chunk plus the build
    manifest rows a real build records. When *source_file* is given,
    its hash is recorded so the freshness path stays current."""
    from askthedocs import corpus
    dir_path.mkdir(parents=True, exist_ok=True)
    db_path = dir_path / "askthedocs.db"
    chunk = store.Chunk(
        chunk_id=store.make_chunk_id("SOLPS-ITER/doc/synthetic.tex", 1, 0),
        source="SOLPS-ITER/doc/synthetic.tex",
        cluster="docs",
        section="Synthetic",
        page=1,
        text=text,
    )
    sha = corpus.sha256_file(source_file) if source_file else "0" * 64
    rows = [(state.KIND_CORPUS, "SOLPS-ITER", "doc/synthetic.tex", sha)]
    conn = store.create(db_path)
    try:
        store.insert_chunks(conn, [chunk])
        store.insert_manifest(conn, rows)
    finally:
        conn.close()
    return db_path


@pytest.fixture
def checkout_factory(tmp_path: Path):
    """make_checkout bound to this test's tmp_path; pass base= to
    place several distinct roots inside one test."""
    return lambda **kw: make_checkout(tmp_path, **kw)


@pytest.fixture
def store_factory(tmp_path: Path):
    """make_store bound to this test's tmp_path."""
    return lambda dir_path=None, **kw: make_store(
        dir_path or (tmp_path / "store"), **kw)


@pytest.fixture
def checkout(tmp_path: Path) -> Path:
    """A floor-perfect repos root with both optional legs present."""
    return make_checkout(tmp_path, optional=("SOLPS-GUI", "SOLPS-Tutorials"))


@pytest.fixture
def live_source(tmp_path: Path) -> Path:
    """The on-disk source the synthetic store records (hashes match)."""
    src = tmp_path / "repos" / "SOLPS-ITER" / "doc" / "synthetic.tex"
    src.parent.mkdir(parents=True, exist_ok=True)
    src.write_text("synthetic documentation source\n", encoding="utf-8")
    return src


def make_indexable_checkout(tmp: Path) -> Path:
    """A floor-perfect checkout carrying minimal REAL indexable
    content: root + module documents, two module sources plus one
    script source, and the switch-inventory XML (one switch)."""
    root = make_checkout(tmp, optional=("SOLPS-GUI",))
    iter_repo = root / "SOLPS-ITER"
    (iter_repo / "doc").mkdir(exist_ok=True)
    (iter_repo / "doc" / "intro.rst").write_text(
        "Intro\n=====\n\nSome prose about drifts.\n", encoding="utf-8")
    eirene_manual = iter_repo / "modules" / "Eirene" / "Manual"
    eirene_manual.mkdir(parents=True, exist_ok=True)
    (eirene_manual / "eirene.tex").write_text(
        "\\section{Eirene}\nManual prose.\n", encoding="utf-8")
    (root / "SOLPS-GUI" / "gui.rst").write_text(
        "GUI doc\n=======\n\nGUI prose.\n", encoding="utf-8")
    b25_src = iter_repo / "modules" / "B2.5" / "src"
    (b25_src / "driver").mkdir(parents=True, exist_ok=True)
    (b25_src / "driver" / "b2x.F").write_text(
        "      SUBROUTINE B2X()\n      RETURN\n      END\n",
        encoding="utf-8")
    (b25_src / "documentation").mkdir(exist_ok=True)
    (b25_src / "documentation" / "b2input.xml").write_text(
        '<b2input><module name="b2mn.dat"><switch><name>b2xflag</name>'
        "<default>.false.</default><type>logical</type>"
        "<description>demo switch</description></switch>"
        '<switch><name>b2yflag</name><default>.true.</default>'
        "<type>logical</type>"
        "<description>second demo switch (plural counts on purpose: "
        "the completion block must prove its plurals)</description>"
        "</switch>"
        "</module></b2input>\n",
        encoding="utf-8")
    triang = iter_repo / "modules" / "Triang" / "src"
    triang.mkdir(parents=True, exist_ok=True)
    (triang / "tria.F").write_text(
        "      SUBROUTINE TRIA()\n      RETURN\n      END\n",
        encoding="utf-8")
    (iter_repo / "scripts").mkdir(exist_ok=True)
    (iter_repo / "scripts" / "tool.F").write_text(
        "      SUBROUTINE TOOL()\n      RETURN\n      END\n",
        encoding="utf-8")
    return root


@pytest.fixture
def indexable_checkout(tmp_path: Path) -> Path:
    """A floor-perfect checkout carrying minimal real indexable
    content (see make_indexable_checkout)."""
    return make_indexable_checkout(tmp_path)


def make_corpus_store(dir_path: Path, rows: list[dict],
                      source_file: str | None = None) -> Path:
    """A store with caller-chosen chunks: each row is a dict of
    section/text/cluster/source/page (source defaults to a synthetic
    docs path; page to None). The discriminating-corpus builder for
    the search-semantics net: tests plant exactly the cases each
    behavior needs."""
    from askthedocs import corpus as corpus_mod
    from askthedocs import state, store
    dir_path = Path(dir_path)
    dir_path.mkdir(parents=True, exist_ok=True)
    db_path = dir_path / "askthedocs.db"
    chunks = []
    sources: dict[str, str] = {}
    for i, row in enumerate(rows):
        source = row.get("source") or "SOLPS-ITER/doc/synthetic.rst"
        page = row.get("page")
        text = row["text"]
        chunks.append(store.Chunk(
            chunk_id=store.make_chunk_id(source, page, i),
            source=source, cluster=row.get("cluster") or "docs",
            section=row["section"], page=page, text=text))
        if source_file:
            sources[source] = corpus_mod.sha256_file(source_file)
    conn = store.create(db_path)
    try:
        store.insert_chunks(conn, chunks)
        manifest = [
            (state.KIND_CORPUS, src.split("/", 1)[0], src.split("/", 1)[1],
             sha if source_file else "0" * 64)
            for src, sha in sources.items()] or [
            (state.KIND_CORPUS, "SOLPS-ITER", "doc/synthetic.rst",
             "0" * 64)]
        store.insert_manifest(conn, manifest)
    finally:
        conn.close()
    return db_path


@pytest.fixture(autouse=True)
def _clean_repos_root_env(monkeypatch):
    """Repos-root ladder hygiene for every test: neither the package
    variable nor $SOLPSTOP leaks in from the launching shell (a
    machine that exports SOLPSTOP must never resolve a test's tree
    through the real one)."""
    from askthedocs import floor
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)
    monkeypatch.delenv("SOLPSTOP", raising=False)
