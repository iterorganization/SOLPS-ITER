"""An unreadable source no longer voids the build: skip-and-name.

One file the reader cannot decode is skipped, named on its own line
in the completion block, recorded with its reason in the summary
beside the index, kept failed through carried rebuilds, and named in
the web rebuild's end-of-run record. Everything else is indexed and
the index installs."""

from __future__ import annotations

import io
import json
import shutil
from pathlib import Path

from tests.conftest import make_indexable_checkout

from askthedocs import api, reindexjob
from askthedocs import setup as setup_mod
from askthedocs.progress import Progress
from askthedocs.setup import run_setup

# real Japanese text in EUC-JP: valid bytes, never valid UTF-8 (the
# encoding of the vendored gnuplot FAQ that met this rule in the
# field)
_JA = "日本語のよくある質問".encode("euc-jp")

_MANUAL = "SOLPS-ITER/modules/Eirene/Manual"


def _plant_unreadable(root: Path, *rels: str) -> None:
    for rel in rels:
        p = root / rel
        p.parent.mkdir(parents=True, exist_ok=True)
        p.write_bytes(_JA)


def _skip_notes(out: str) -> list[str]:
    return [ln for ln in out.splitlines()
            if ln.startswith("note: ")
            and "could not be read" in ln]


def test_unreadable_document_is_skipped_and_named(tmp_path, capsys):
    root = make_indexable_checkout(tmp_path / "tree")
    _plant_unreadable(root, f"{_MANUAL}/faq-ja.tex")
    share = tmp_path / "share"

    code = run_setup(root / "SOLPS-ITER", share=share, install_icon=False)

    out = capsys.readouterr().out
    assert code == 0
    # the note is ONE line of its own (never glued to the elapsed
    # line) and carries the singular wording
    notes = _skip_notes(out)
    assert len(notes) == 1
    assert notes[0].startswith(
        "note: 1 source could not be read and was skipped: ")
    assert f"{_MANUAL}/faq-ja.tex" in notes[0]
    assert "build_summary.json" in notes[0]
    # the reason is recorded beside the index, with the file named
    summary = json.loads((share / "build_summary.json").read_text(
        encoding="utf-8"))
    failed = summary["sources"]["failed"]
    assert [f["source"] for f in failed] == [f"{_MANUAL}/faq-ja.tex"]
    assert "not utf-8" in failed[0]["error"]
    # everything else was indexed and is searchable
    assert api.search("drifts", db_path=share / "askthedocs.db").total >= 1


def test_unreadable_note_wording_plural(tmp_path, capsys):
    root = make_indexable_checkout(tmp_path / "tree")
    _plant_unreadable(root, f"{_MANUAL}/faq-ja.tex",
                      f"{_MANUAL}/faq-de.tex")
    code = run_setup(root / "SOLPS-ITER", share=tmp_path / "share",
                     install_icon=False)
    out = capsys.readouterr().out
    assert code == 0
    notes = _skip_notes(out)
    assert len(notes) == 1
    assert notes[0].startswith(
        "note: 2 sources could not be read and were skipped: ")
    # the first three names ride the line; the rest live in the summary
    assert "faq-ja.tex" in notes[0] and "faq-de.tex" in notes[0]


def test_carried_rebuild_keeps_the_failed_record(tmp_path):
    root = make_indexable_checkout(tmp_path / "tree")
    _plant_unreadable(root, f"{_MANUAL}/faq-ja.tex")
    share = tmp_path / "share"
    run_setup(root / "SOLPS-ITER", share=share, install_icon=False)
    carried_from = share / "askthedocs.db"

    # the module vanishes: its rows (including the unreadable one)
    # carry from the previous store
    shutil.rmtree(root / "SOLPS-ITER" / "modules" / "Eirene")
    out = tmp_path / "carried-out"
    setup_mod.run_index_build(
        {"SOLPS-ITER": root / "SOLPS-ITER",
         "SOLPS-GUI": root / "SOLPS-GUI"},
        bar=Progress(io.StringIO()),
        build_dir=tmp_path / "carried-build", final_dir=out,
        carry_from=carried_from)

    summary = json.loads((out / "build_summary.json").read_text(
        encoding="utf-8"))
    failed = summary["sources"]["failed"]
    # still failed, never relabeled as extracted
    assert [f["source"] for f in failed] == [f"{_MANUAL}/faq-ja.tex"]
    assert f"{_MANUAL}/faq-ja.tex" not in summary["sources"]["extracted"]
    # the module's readable manual carried normally
    assert f"{_MANUAL}/eirene.tex" in summary["sources"]["extracted"]


def test_web_rebuild_record_names_skipped_sources(tmp_path):
    root = make_indexable_checkout(tmp_path / "tree")
    _plant_unreadable(root, f"{_MANUAL}/faq-ja.tex")
    frame = tmp_path / "frames.json"
    result = tmp_path / "result.json"

    code = reindexjob.main([
        "--leg", f"SOLPS-ITER={root / 'SOLPS-ITER'}",
        "--leg", f"SOLPS-GUI={root / 'SOLPS-GUI'}",
        "--build-dir", str(tmp_path / "build"),
        "--final-dir", str(tmp_path / "final"),
        "--frame-file", str(frame),
        "--result-file", str(result)])

    assert code == 0
    record = json.loads(result.read_text(encoding="utf-8"))
    assert record["ok"] is True
    assert record["failed_sources"] == [f"{_MANUAL}/faq-ja.tex"]
    assert frame.is_file()
