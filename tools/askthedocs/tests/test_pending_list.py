"""The pending list: what the run will index, one line per category
and content class, draining as stages settle."""

from __future__ import annotations

import io
import sys
from pathlib import Path

from askthedocs import corpus, fortran
from askthedocs.progress import Progress
from askthedocs.setup import _pending_entries, run_setup



def test_pending_entries_category_tree():
    entries = _pending_entries(
        {"SOLPS-ITER": 140, "Carre": 1, "DivGeo": 10, "Eirene": 37,
         "amds": 1, "scripts": 1, "SOLPS-GUI": 78,
         "SOLPS-Tutorials": 32},
        {"B2.5": 808, "Carre": 116, "DivGeo": 55, "Eirene": 876,
         "Sonnet-light": 2, "Triang": 121, "Uinp": 52, "fxdr": 5,
         "solps4-5": 84, "scripts": 2},
        892)
    # strict drain order: documents (GUI, SOLPS-ITER with module and
    # scripts documents indented, Tutorials), switch inventory,
    # sources in walk order with scripts last, excepted at the end
    assert entries == [
        ('SOLPS-GUI documents             78 files',
         'SOLPS-GUI documents'),
        ('SOLPS-ITER documents           140 files',
         'SOLPS-ITER documents'),
        ('  Carre documents                  1 files',
         'Carre documents'),
        ('  DivGeo documents                10 files',
         'DivGeo documents'),
        ('  Eirene documents                37 files',
         'Eirene documents'),
        ('  amds documents                   1 files',
         'amds documents'),
        ('  scripts documents                1 files',
         'scripts documents'),
        ('SOLPS-Tutorials documents       32 files',
         'SOLPS-Tutorials documents'),
        ('B2.5 switch index              892 entries',
         'B2.5 switch index'),
        ('B2.5 fortran source            808 files',
         'B2.5 fortran source'),
        ('Carre fortran source           116 files',
         'Carre fortran source'),
        ('DivGeo fortran source           55 files',
         'DivGeo fortran source'),
        ('Eirene fortran source          876 files',
         'Eirene fortran source'),
        ('Sonnet-light fortran source      2 files',
         'Sonnet-light fortran source'),
        ('Triang fortran source          121 files',
         'Triang fortran source'),
        ('Uinp fortran source             52 files',
         'Uinp fortran source'),
        ('fxdr fortran source              5 files',
         'fxdr fortran source'),
        ('solps4-5 fortran source         84 files',
         'solps4-5 fortran source'),
        ('scripts fortran source           2 files',
         'scripts fortran source'),
        ('adas                        excepted (non-public)',
         None),
    ]


def _last_frame(text: str) -> str:
    """The last drawn block: split on the cursor-up that precedes each
    redraw, strip the remaining escapes (a shrinking block appends a
    trailing erase + return, so empty trailing chunks exist)."""
    import re
    frames = [f for f in re.split(r"\x1b\[\d+A", text) if f.strip()]
    return re.sub(r"\x1b\[[0-9]*[A-Za-z]|\r", "", frames[-1])


def test_table_rows_carry_their_state():
    out = io.StringIO()
    bar = Progress(out, interactive=True, columns=80)
    bar.set_pending([
        ("SOLPS-GUI documents       78 files", "SOLPS-GUI documents"),
        ("SOLPS-Tutorials documents      32 files",
         "SOLPS-Tutorials documents"),
        ("  adas              excepted (non-public)", None),
    ])
    bar.begin_stage("SOLPS-GUI documents", verb="scan", unit="files",
                    total=78, counts_files=True)
    bar.tick(20)
    bar._repaint(force=True)
    frame = _last_frame(out.getvalue())
    assert "indexing  SOLPS-GUI documents       78 files" in frame
    assert "queued    SOLPS-Tutorials documents      32 files" in frame
    assert " excepted (non-public)" in frame  # no state: never processed
    bar.tick(58)
    bar.end_stage()
    frame = _last_frame(out.getvalue())
    assert "indexed   SOLPS-GUI documents       78 files" in frame
    assert "78 files in" not in frame  # no duration in rows
    assert "indexing" not in frame  # done is done
    assert "queued    SOLPS-Tutorials" in frame  # others still queued
    bar.finish()
    # the final log is the finished table
    assert "indexed   SOLPS-GUI documents" in out.getvalue()


def test_write_stage_leaves_no_settled_line_interactive():
    # the store-write heartbeat is the LIVE bar only; once
    # the write settles it leaves nothing in the block (the
    # completion block reports the totals)
    out = io.StringIO()
    bar = Progress(out, interactive=True, columns=80)
    bar.begin_stage("search index", verb="write", unit="chunks",
                    total=7)
    bar.tick(7)
    frame_before = _last_frame(out.getvalue())
    assert "writing search index" in frame_before  # live: it shows
    bar.end_stage()
    bar.finish()
    final = out.getvalue()
    assert "wrote search index" not in final  # settled: it does not


def test_category_attribution():
    assert corpus.doc_category("SOLPS-ITER", "doc/manual.tex") == "SOLPS-ITER"
    assert corpus.doc_category("SOLPS-ITER",
                               "modules/Eirene/Manual/eirene.tex") == "Eirene"
    assert corpus.doc_category("SOLPS-ITER", "modules/amds/data.txt") == "amds"
    assert corpus.doc_category("SOLPS-GUI", "doc/source/x.rst") == "SOLPS-GUI"
    assert fortran.source_category("modules/B2.5/src/driver/b2x.F") == "B2.5"
    assert fortran.source_category("modules/solps4-5/src/b2sxdr.F") == "solps4-5"
    assert fortran.source_category("scripts/nc2text.F") == "scripts"
    assert corpus.doc_category("SOLPS-ITER",
                               "scripts/pipe_run.log") == "scripts"


def test_fortran_scan_opens_one_stage_per_category(indexable_checkout):
    out = io.StringIO()
    bar = Progress(out, interactive=True, columns=80)
    chunks, summary = fortran.scan(indexable_checkout / "SOLPS-ITER",
                                    progress=bar)
    bar.finish()
    text = out.getvalue()
    assert summary["files"]["walked"] == 3 and len(chunks) == 3
    for label in ("B2.5 fortran source", "Triang fortran source",
                  "scripts fortran source"):
        assert f"indexing {label}" in text
        assert f"indexed {label}: 1 files in" in text


def test_setup_build_end_to_end(indexable_checkout, tmp_path: Path,
                                 capsys, monkeypatch):
    root = indexable_checkout
    # the icon lands under a FAKE home (setup installs it by
    # default) with a fake console path baked in; the build itself
    # goes into that home's DEFAULT location (this is the
    # non-redirected completion block's pin)
    fake_home = tmp_path / "home"
    fake_home.mkdir()
    share = fake_home / ".local" / "share" / "askthedocs"
    monkeypatch.setattr(Path, "home", lambda: fake_home)
    from askthedocs import shortcut
    monkeypatch.setattr(shortcut, "_cli_path",
                        lambda: tmp_path / "bin" / "askthedocs")
    code = run_setup(root / "SOLPS-ITER", share=share)
    out = capsys.readouterr().out
    assert code == 0
    # the pending list opened the run, category-grouped
    assert "SOLPS-ITER documents" in out
    assert "B2.5 switch index" in out
    assert "excepted (non-public)" in out
    # one pass, one verb: no read settles exist; the single visit's
    # indexing stages drain the pending lines; the in-order assembly
    # of the already-extracted text is silent (its 0s stage line read
    # as a second processing pass - dropped 2026-11-03), and the
    # store write itself carries the heartbeat instead
    assert "read " not in out
    assert "assemble" not in out
    assert "note: some course and plot documents" in out
    assert "indexed SOLPS-GUI documents: 1 files in" in out
    assert "indexed SOLPS-ITER documents: 1 files in" in out
    assert "indexed Eirene documents: 1 files in" in out
    assert "built B2.5 switch index: 2 entries in" in out
    assert "indexed B2.5 fortran source: 1 files in" in out
    assert "indexed Triang fortran source: 1 files in" in out
    assert "indexed scripts fortran source: 1 files in" in out
    assert "wrote search index: 8 chunks in" in out
    assert "=" * 72 in out  # the completion block is framed    # the index landed in the share and validates as the real artifact
    from askthedocs import locate
    assert locate.validate_store(share / locate.DB_NAME) == "current"
    assert "setup complete:" in out
    assert "2 switch entries" in out      # the plural that bit twice
    assert "entrys" not in out
    assert "index can be found here: " in out
    # the icon installed by default, announced with its
    # remove command; and the three doors close the block
    if sys.platform == "darwin":
        assert (fake_home / "Applications" / "Askthedocs.app"
                / "Contents" / "MacOS" / "askthedocs-open").is_file()
    # separators around the index placement, the icon block is
    # gone, door 1 carries the two startup forms
    lines = out.splitlines()
    tt = next(i for i, l in enumerate(lines)
              if l.startswith("Total time:"))
    assert lines[tt + 1] == "=" * 72
    per_user = next(i for i, l in enumerate(lines)
                    if l.lstrip().startswith("(the per-user location"))
    assert lines[per_user + 1] == "=" * 72
    assert "icon: " not in out
    assert "shortcut --remove" not in out
    assert "CLI startup: " in out and " open" in out
    assert "Icon startup: " in out
    assert "what's next:" in out
    assert "1. the web version" in out
    assert "2. a search from the terminal" in out
    assert "3. ask an AI assistant" in out
    assert "README's MCP section" in out
    assert 'search "drifts"' in out
    # the store answers
    from askthedocs import api
    result = api.search("drifts", db_path=share / locate.DB_NAME)
    assert result.total >= 1
    switch = api.search("b2xflag", db_path=share / locate.DB_NAME,
                        cluster="source_switch")
    assert switch.total == 1


def test_setup_no_icon_refusal(indexable_checkout, tmp_path: Path,
                                capsys, monkeypatch):
    # --no-icon is the opt-out; nothing lands, nothing prints
    fake_home = tmp_path / "home"
    fake_home.mkdir()
    monkeypatch.setattr(Path, "home", lambda: fake_home)
    code = run_setup(indexable_checkout / "SOLPS-ITER",
                     share=tmp_path / "share", install_icon=False)
    out = capsys.readouterr().out
    assert code == 0
    assert "icon: " not in out
    assert not (fake_home / "Applications").exists()


def test_read_settles_stay_out_of_the_table():
    # reading is a first pass: its settles leave the block (the
    # history below the pair is for indexed work only) and a pending
    # line drains only when its INDEXING stage settles
    import io
    import re
    out = io.StringIO()
    bar = Progress(out, interactive=True, columns=80)
    pending_line = "SOLPS-GUI documents       78 files"
    bar.set_pending([(pending_line, "SOLPS-GUI documents")])
    bar.begin_stage("SOLPS-GUI documents", verb="read", unit="files",
                    total=78, counts_files=True)
    bar.tick(78)
    bar.end_stage()
    frame = _last_frame(out.getvalue())
    assert "read SOLPS-GUI documents: 78 files" not in frame
    assert "queued    SOLPS-GUI documents" in frame  # read is not index
    bar.begin_stage("SOLPS-GUI documents", verb="scan", unit="files",
                    total=78)
    bar.tick(78)
    bar.end_stage()
    frame = _last_frame(out.getvalue())
    assert "indexed   SOLPS-GUI documents       78 files" in frame
    assert "78 files in" not in frame  # no duration in rows
    # the read line did print, above the block
    assert "read SOLPS-GUI documents: 78 files" in out.getvalue()
    bar.finish()


def test_single_pass_and_two_pass_builds_are_byte_identical(
        indexable_checkout, tmp_path: Path):
    # the single visit must not change one byte of the store: the
    # same extractor, same files, same order - only the duplicate
    # extraction disappears
    import shutil
    from askthedocs import build as build_mod
    from askthedocs import corpus as corpus_mod, locate

    # A: the setup run (single pass, cached assembly)
    share_a = tmp_path / "a"
    run_setup(indexable_checkout / "SOLPS-ITER", share=share_a)

    # B: the two-pass run (plain scan manifest, plain build)
    repos = {"SOLPS-ITER": indexable_checkout / "SOLPS-ITER",
             "SOLPS-GUI": indexable_checkout / "SOLPS-GUI"}
    manifest = corpus_mod.scan(repos)
    dir_b = tmp_path / "b"
    build_mod.build(manifest, repos, dir_b / "askthedocs.db",
                    dir_b / "build_summary.json",
                    switches_path=dir_b / "switches.json",
                    include_fortran=True)

    a = (share_a / locate.DB_NAME).read_bytes()
    b = (dir_b / "askthedocs.db").read_bytes()
    assert a == b, "single-pass store differs from two-pass store"


def test_legs_section_one_logical_line_per_leg(indexable_checkout,
                                               tmp_path: Path,
                                               capsys, monkeypatch):
    # every leg is ONE logical line, however long - no continuation
    # rows, no floating class lines, never a wrapped legs row
    fake_home = tmp_path / "home"
    fake_home.mkdir()
    monkeypatch.setattr(Path, "home", lambda: fake_home)
    from askthedocs import shortcut
    monkeypatch.setattr(shortcut, "_cli_path",
                        lambda: tmp_path / "bin" / "askthedocs")
    run_setup(indexable_checkout / "SOLPS-ITER", share=tmp_path / "share")
    out = capsys.readouterr().out
    lines = out.splitlines()
    start = next(i for i, l in enumerate(lines) if l == "legs:")
    end = next(i for i, l in enumerate(lines)
               if i > start and l.startswith("Total time:"))
    legs = [l for l in lines[start + 1:end] if l.strip()]
    # ONE line per leg, however long - no continuation rows
    # (deep-indented lines), every present leg closes with the paren
    for l in legs:
        assert not l.startswith(" " * 8), f"wrapped leg row: {l!r}"
    named = [l for l in legs if "indexed:" in l]
    assert named, "the present legs are named"
    for l in named:
        assert l.rstrip().endswith(")"), l
    assert any("SOLPS-GUI" in l and " from " in l for l in named)
