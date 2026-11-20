"""The two-level ASCII progress display: settled lines when piped,
the moving pair when interactive, ASCII everywhere, counts
right-aligned, elapsed but never an estimate."""

from __future__ import annotations

import io

from askthedocs.progress import Progress


def _piped() -> tuple[Progress, io.StringIO]:
    stream = io.StringIO()
    return Progress(stream, interactive=False), stream


def _tty() -> tuple[Progress, io.StringIO]:
    stream = io.StringIO()
    return Progress(stream, interactive=True), stream


def test_piped_prints_settled_lines_only():
    bar, out = _piped()
    bar.start(files_total=30, legs_total=2)
    bar.begin_stage("SOLPS-ITER", verb="scan", unit="files", total=20,
                    counts_files=True)
    for _ in range(20):
        bar.tick()
    bar.end_stage()
    bar.leg_done()
    bar.begin_stage("switch index", verb="build", unit="entries")
    bar.set_total(892)
    bar.tick(892)
    bar.finish()
    text = out.getvalue()
    assert text == (
        "indexed SOLPS-ITER: 20 files in 0s\n"
        "built switch index: 892 entries in 0s\n"
    )
    # nothing that repositions a cursor ever reaches a pipe
    assert "\x1b" not in text and "\r" not in text


def test_interactive_draws_the_moving_pair():
    bar, out = _tty()
    bar.start(files_total=10, legs_total=1)
    bar.begin_stage("SOLPS-ITER", verb="scan", unit="files", total=10,
                    counts_files=True)
    bar.tick(7)
    bar._repaint(force=True)
    text = out.getvalue()
    assert "total: 7/10 files indexed, elapsed" in text
    assert "  indexing SOLPS-ITER  7/10 files" in text
    assert "[" + "#" * 15 + "-" * 7 + "]" in text  # 22-wide ASCII track
    assert "70%" in text
    bar.finish()


def test_global_line_bare_with_separator_and_settled_under_pair():
    # the global line states only the totals (owner verdict: the
    # per-leg counter is noise); a dashed rule separates the pending
    # list from what is happening now; a settled stage settles
    # DIRECTLY UNDER the moving pair
    bar, out = _tty()
    bar.start(files_total=100, legs_total=2)
    bar.set_pending([("SOLPS-ITER documents       190 files",
                      "SOLPS-ITER documents")])
    bar.begin_stage("SOLPS-GUI", verb="scan", unit="files", total=78,
                    counts_files=True)
    bar.tick(78)
    bar.end_stage()
    bar.leg_done()
    bar.begin_stage("SOLPS-ITER", verb="scan", unit="files", total=190,
                    counts_files=True)
    bar.tick(49)
    bar._repaint(force=True)
    import re as _re2
    frames = [f for f in _re2.split(r"\x1b\[\d+A", out.getvalue())
              if f.strip()]
    frame = _re2.sub(r"\x1b\[[0-9]*[A-Za-z]|\r", "", frames[-1])
    assert "total: 127/100 files indexed, elapsed" in frame
    assert any(set(line) == {"-"} for line in frame.split("\n"))
    assert "done +" not in frame  # the breakdown is gone
    stage_at = frame.index("indexing SOLPS-ITER")
    settled_at = frame.index("indexed SOLPS-GUI: 78 files")
    assert stage_at < settled_at, frame
    bar.finish()


def test_interactive_output_stays_ascii_beyond_controls():
    bar, out = _tty()
    bar.start(files_total=5, legs_total=1)
    bar.begin_stage("fortran source", verb="scan", unit="files",
                    total=5, counts_files=True)
    for _ in range(5):
        bar.tick()
    bar.finish()
    text = out.getvalue()
    printable = text.replace("\x1b", "").replace("\r", "").replace("\n", "")
    printable.encode("ascii")  # raises if any non-ASCII glyph slipped in


def test_elapsed_never_an_estimate():
    bar, out = _piped()
    bar.start(files_total=1, legs_total=1)
    bar.begin_stage("SOLPS-ITER", verb="scan", unit="files", total=1,
                    counts_files=True)
    bar.tick()
    bar.finish()
    text = out.getvalue()
    assert "in 0s" in text      # elapsed, always shown
    assert "eta" not in text.lower()


def test_global_files_span_scan_and_fortran_stages():
    bar, out = _tty()
    bar.start(files_total=6, legs_total=1)
    bar.begin_stage("SOLPS-ITER", verb="scan", unit="files", total=2,
                    counts_files=True)
    bar.tick(2)
    bar.end_stage()
    bar.leg_done()
    # a non-file stage (the switch census) never moves the global count
    bar.begin_stage("switch index", verb="build", unit="entries",
                    total=4)
    bar.tick(4)
    bar._repaint(force=True)
    assert "total: 2/6 files indexed, elapsed" in out.getvalue()
    bar.finish()


def test_finish_settles_the_open_stage():
    bar, out = _piped()
    bar.begin_stage("documentation sources", verb="extract",
                    unit="sources", total=3)
    bar.tick(3)
    bar.finish()
    assert "extracted documentation sources: 3 sources" in out.getvalue()


def _plain(text: str) -> list[str]:
    """Printable lines, frame-safe: frames are delimited by the
    cursor-up that precedes each repaint, so lines from different
    frames never concatenate once the escapes are gone."""
    import re
    out: list[str] = []
    for frame in re.split(r"\x1b\[[0-9]*A", text):
        for line in re.sub(r"\x1b\[[0-9]*[A-Za-z]|\r", "",
                           frame).split("\n"):
            if line:
                out.append(line)
    return out


def test_narrow_terminal_the_track_shrinks_but_never_wraps():
    import io
    out = io.StringIO()
    bar = Progress(out, interactive=True, columns=60)
    bar.start(files_total=2421, legs_total=3)
    bar.begin_stage("SOLPS-Tutorials", verb="scan", unit="files",
                    total=32, counts_files=True)
    bar.tick(15)
    bar._repaint(force=True)
    bar.finish()
    lines = _plain(out.getvalue())
    assert all(len(line) <= 59 for line in lines), lines
    stage = [line for line in lines if "SOLPS-Tutorials" in line
             and "15/32" in line]
    assert stage and "[" in stage[0]  # the track survived, shrunk to fit


def test_very_narrow_terminal_keeps_the_counts():
    import io
    out = io.StringIO()
    bar = Progress(out, interactive=True, columns=40)
    bar.start(files_total=2421, legs_total=3)
    bar.begin_stage("SOLPS-Tutorials", verb="scan", unit="files",
                    total=32, counts_files=True)
    bar.tick(15)
    bar._repaint(force=True)
    bar.finish()
    lines = _plain(out.getvalue())
    # nothing reaches the wrap edge, whatever had to give way
    assert all(len(line) <= 39 for line in lines), lines
    assert any("15/32" in line for line in lines)


def test_wall_clock_repaint_keeps_elapsed_moving():
    # a source can hold its stage for half a minute; the elapsed
    # counter must still move (earned live in the owner's terminal)
    import io
    import time as _time
    out = io.StringIO()
    bar = Progress(out, interactive=True, columns=60)
    bar.start(files_total=10, legs_total=1)
    bar.begin_stage("SOLPS-ITER", verb="scan", unit="files", total=10,
                    counts_files=True)
    bar._repaint(force=True)
    after_first = len(out.getvalue())
    _time.sleep(1.3)  # NO ticks arrive
    bar.finish()
    frames = out.getvalue()[after_first:]
    assert frames, "nothing repainted without a tick"
    assert "elapsed 1s" in frames
    # and the timer is gone: finish stopped it
    assert bar._timer is None


def test_tall_pending_list_windows_to_the_terminal():
    # earned live at full-corpus height: a block taller than the
    # screen makes the cursor-up clamp at the screen top and every
    # redraw then lands one row lower (the list repeated itself line
    # by line). The block must fit the terminal, with "+N" markers
    # naming what the window hides.
    import io
    import re
    out = io.StringIO()
    bar = Progress(out, interactive=True, columns=60, rows=12)
    pending = [(f"category {i:02d} documents       {i} files",
                f"category {i:02d} documents") for i in range(19)]
    bar.set_pending(pending)
    bar.begin_stage("category 00 documents", verb="scan", unit="files",
                    total=5, counts_files=True)
    for _ in range(5):
        bar.tick()
    bar.end_stage()
    bar.begin_stage("category 01 documents", verb="scan", unit="files",
                    total=5, counts_files=True)
    bar.tick(3)
    bar._repaint(force=True)
    frames = re.split(r"\x1b\[\d+A", out.getvalue())
    for frame in frames[1:]:
        lines = [l for l in
                 re.sub(r"\x1b\[[0-9]*[A-Za-z]|\r", "", frame).split("\n")
                 if l]
        assert len(lines) <= 10, lines  # rows(12) - 2, never exceeded
        body = [l for l in lines if set(l) != {"-"}]  # rules may repeat
        assert len(body) == len(set(body)), body  # no repetition
    last = [l for l in
            re.sub(r"\x1b\[[0-9]*[A-Za-z]|\r", "", frames[-1]).split("\n")
            if l]
    assert any("total:" in l for l in last)       # the pair survives
    assert any("more rows" in l for l in last)    # the window is named
    # the finished category lives in the table with its state
    assert any(l.startswith("indexed") and "category 00" in l
               for l in last)
    bar.finish()


def test_reads_do_not_tally_as_indexed():
    # reading a file does not index it: the global files counter moves
    # only when an indexing stage ticks; no per-leg counter exists
    bar, out = _tty()
    bar.start(files_total=100, legs_total=1)
    bar.set_pending([("SOLPS-GUI documents       78 files",
                      "SOLPS-GUI documents")])
    bar.begin_stage("SOLPS-GUI documents", verb="read", unit="files",
                    total=78)
    bar.tick(78)
    bar.end_stage()
    bar.leg_done()
    bar._repaint(force=True)
    text = out.getvalue()
    assert "total: 0/100 files indexed, elapsed" in text
    bar.begin_stage("SOLPS-GUI documents", verb="scan", unit="files",
                    total=78, counts_files=True)
    bar.tick(78)
    bar.end_stage()
    bar._repaint(force=True)
    assert "total: 78/100 files indexed" in out.getvalue()
    bar.finish()


def test_resize_redraws_fresh_instead_of_trusting_stale_rows():
    # a resized terminal reflows the wrapped history; the redraw must
    # not address stale row offsets (earned live: the pending list
    # repeated itself after a resize)
    bar, out = _tty()
    bar._columns = 80
    bar.set_pending([("SOLPS-GUI documents       78 files",
                      "SOLPS-GUI documents")])
    bar.begin_stage("SOLPS-GUI documents", verb="read", unit="files",
                    total=78)
    bar.tick(78)
    bar._repaint(force=True)
    bar._columns = 60  # the terminal was resized
    bar._repaint(force=True)
    import re as _re
    frames = [f for f in _re.split(r"\x1b\[\d+A", out.getvalue())
              if f.strip()]
    plain = _re.sub(r"\x1b\[[0-9]*[A-Za-z]|\r", "", frames[-1])
    # the reflowed old block stays above as history garbage (that is
    # the terminal's doing); the FRESH block at the tail must be
    # complete and duplicate-free
    tail = [l for l in plain.split("\n") if l][-3:]
    assert any("SOLPS-GUI documents" in l for l in tail)
    assert len(tail) == len(set(tail))
    assert any("total:" in l for l in tail)
    bar.finish()


def test_current_file_names_the_wait():
    # a named wait reads as progress, not a hang: the file the stage
    # is working shows beneath the stage line, in the stage's verb,
    # size beside it, cleared when the stage settles
    bar, out = _tty()
    bar._columns = 80
    bar.set_pending([("SOLPS-ITER documents     140 files",
                      "SOLPS-ITER documents")])
    bar.begin_stage("SOLPS-ITER documents", verb="read", unit="files",
                    total=140)
    bar.tick(8)
    bar.current_file("doc/SOLPS_2002_Course/eirene_publ.pdf", 1_234_567)
    bar._repaint(force=True)
    frame = _last_frame_like(out.getvalue())
    assert "  reading doc/SOLPS_2002_Course/eirene_publ.pdf (1.2 MB)" \
        in frame
    bar.end_stage()
    frame = _last_frame_like(out.getvalue())
    assert "eirene_publ.pdf" not in frame  # cleared with the stage
    bar.finish()


def test_current_file_keeps_the_filename_when_narrow():
    # paths truncate from the LEFT: the filename always survives
    bar, out = _tty()
    bar._columns = 40
    bar.set_pending([("SOLPS-ITER documents     140 files",
                      "SOLPS-ITER documents")])
    bar.begin_stage("SOLPS-ITER documents", verb="read", unit="files",
                    total=140)
    bar.tick(8)
    bar.current_file("doc/SOLPS_2002_Course/"
                     "BRAAMS_-_A_Multi-Fluid_Code_for_the_Simulation_of_"
                     "the_Edge_Plasma_in_Tokamaks_-_NET_Report_1987.pdf",
                     8_000_000)
    bar._repaint(force=True)
    frame = _last_frame_like(out.getvalue())
    file_rows = [l for l in frame.split("\n") if "1987.pdf" in l]
    assert file_rows and file_rows[0].startswith("...")
    assert len(file_rows[0]) <= 39
    bar.finish()


def _last_frame_like(text: str) -> str:
    import re
    frames = [f for f in re.split(r"\x1b\[\d+A", text) if f.strip()]
    return re.sub(r"\x1b\[[0-9]*[A-Za-z]|\r", "", frames[-1])


# ------------------------------------------------------ bar glyphs

class _FakeStream(io.StringIO):
    """A StringIO that claims an encoding, the way real streams do."""
    encoding = None

    def __init__(self, encoding):
        super().__init__()
        self.encoding = encoding


def test_utf8_proof_decides_the_glyphs():
    from askthedocs.progress import _stream_is_utf8
    assert _stream_is_utf8(_FakeStream("UTF-8")) is True
    assert _stream_is_utf8(_FakeStream("utf8")) is True
    assert _stream_is_utf8(_FakeStream("US-ASCII")) is False
    assert _stream_is_utf8(_FakeStream("latin-1")) is False
    assert _stream_is_utf8(io.StringIO()) is False   # no claim: ASCII


def test_bars_render_blocks_in_unicode_mode_and_ascii_fallback():
    from askthedocs.progress import Progress
    # forced unicode: solid blocks
    out = io.StringIO()
    bar = Progress(out, interactive=True, columns=100, ascii_only=False)
    bar.set_pending([("GUI documents       78 files", "GUI documents")])
    bar.begin_stage("GUI documents", verb="scan", unit="files",
                    total=78, counts_files=True)
    bar.tick(57)
    bar._repaint(force=True)
    frame = out.getvalue().splitlines()
    stage = next(l for l in reversed(frame)
                 if "indexing GUI documents" in l and "[" in l)
    assert "▰" in stage and "▱" in stage
    assert "#" not in stage
    # the same bar, unprovable stream (StringIO): today's ASCII pair
    out2 = io.StringIO()
    bar2 = Progress(out2, interactive=True, columns=100)
    bar2.set_pending([("GUI documents       78 files", "GUI documents")])
    bar2.begin_stage("GUI documents", verb="scan", unit="files",
                     total=78, counts_files=True)
    bar2.tick(57)
    bar2._repaint(force=True)
    stage2 = next(l for l in reversed(out2.getvalue().splitlines())
                  if "indexing GUI documents" in l and "[" in l)
    assert "#" in stage2 and "-" in stage2
    assert "▰" not in stage2


def test_file_bar_glyphs_follow_the_mode_too():
    from askthedocs.progress import Progress
    out = io.StringIO()
    bar = Progress(out, interactive=True, columns=100, ascii_only=False)
    bar.begin_stage("search index", verb="write", unit="chunks",
                    total=100)
    bar.tick(50)
    bar.current_file("index.db", 1000)
    bar.file_total(1000, "B")
    bar.file_tick(500)
    bar._repaint(force=True)
    line = next(l for l in reversed(out.getvalue().splitlines())
                if "writing search index" in l)
    assert "▰" in line and "▱" in line


# ------------------------------------------------ the busy spinner

def test_busy_line_spins_and_clears():
    from askthedocs.progress import Progress, _SPIN_UNICODE
    out = io.StringIO()
    bar = Progress(out, interactive=True, columns=100, ascii_only=False)
    bar.start(10, 3)
    bar.begin_busy("verifying the index")
    first = [l for l in out.getvalue().splitlines() if "verifying" in l]
    assert first, "the busy line renders"
    assert _SPIN_UNICODE[0] in first[-1]
    bar._spin_step()          # what every timer tick does
    bar._repaint(force=True)
    later = [l for l in out.getvalue().splitlines() if "verifying" in l]
    assert _SPIN_UNICODE[1] in later[-1]     # the glyph advanced
    bar.begin_stage("search index", verb="write", unit="chunks")
    assert "verifying" not in out.getvalue().splitlines()[-1]
    bar.finish()
    assert all("verifying" not in l for l in
               out.getvalue().splitlines()[-3:])


def test_busy_line_ascii_fallback():
    from askthedocs.progress import Progress, _SPIN_ASCII
    out = io.StringIO()
    bar = Progress(out, interactive=True, columns=100)  # no UTF-8 claim
    bar.start(10, 3)
    bar.begin_busy("finishing up")
    line = [l for l in out.getvalue().splitlines() if "finishing up" in l][-1]
    assert any(g in line for g in _SPIN_ASCII)
    assert "█" not in line and "⠋" not in line


def test_no_ambiguous_or_wide_codepoint_ever_renders():
    # the structural guarantee: East-Asian-AMBIGUOUS (A) and
    # Wide (W) codepoints misalign on wide-locale terminals; nothing
    # the display renders may ever be one, in EITHER mode. This is
    # the invariant that would have caught the U+2588 fill.
    import unicodedata
    from askthedocs.progress import Progress

    def drive(ascii_only):
        out = io.StringIO()
        bar = Progress(out, interactive=True, columns=90,
                       ascii_only=ascii_only)
        bar.set_pending([("GUI documents       78 files",
                          "GUI documents")])
        bar.begin_stage("GUI documents", verb="scan", unit="files",
                        total=78, counts_files=True)
        bar.tick(57)
        bar.current_file("doc/manual.pdf", 1_200_000)
        bar.file_total(1_200_000, "B")
        bar.file_tick(500_000)
        bar._repaint(force=True)
        bar.end_stage()
        bar.begin_busy("verifying the index")
        for _ in range(3):
            bar._spin_step()
            bar._repaint(force=True)
        bar.begin_stage("search index", verb="write", unit="chunks",
                        total=100)
        bar.tick(50)
        bar._repaint(force=True)
        bar.finish()
        return out.getvalue()

    for mode, ascii_only in (("unicode", False), ("ascii", True)):
        text = drive(ascii_only)
        bad = sorted({ch for ch in text
                      if unicodedata.east_asian_width(ch) in ("A", "W")})
        assert not bad, f"{mode} mode rendered ambiguous/wide: {bad}"
        if mode == "unicode":
            assert "▰" in text and "▱" in text   # the premium renders


# ------------------------------------------------------- capture mode
# the service's progress modal: the SAME lines the interactive
# terminal shows, captured as frames instead of ANSI writes (the
# identity is by construction - one renderer, two sinks)

def _captured() -> tuple[Progress, io.StringIO]:
    stream = io.StringIO()
    return Progress(stream, capture=True, columns=73, rows=100_000,
                    ascii_only=False), stream


def test_capture_frames_the_live_block():
    bar, _out = _captured()
    bar.set_pending([("SOLPS-ITER documents       10 files",
                      "SOLPS-ITER documents")])
    bar.start(files_total=10, legs_total=1)
    bar.begin_stage("SOLPS-ITER documents", verb="scan", unit="files",
                    total=10, counts_files=True)
    bar.tick(7)
    bar._repaint(force=True)   # past the 10 Hz tick throttle, like the live timer
    frame = bar.frame()
    # the state table row went queued -> indexing, in place
    assert any(line.startswith("indexing") and
               line.endswith("SOLPS-ITER documents       10 files")
               for line in frame), frame
    # the moving pair: totals line + the stage line with its bar
    assert any(line.startswith("total: 7/10 files indexed, elapsed")
               for line in frame), frame
    stage = [line for line in frame if "7/10 files" in line]
    assert any("  indexing SOLPS-ITER documents  7/10 files" in line
               and "▰" in line and "70%" in line
               for line in stage), frame
    bar.finish()


def test_capture_finish_is_the_closing_log():
    bar, _out = _captured()
    bar.set_pending([("SOLPS-ITER documents       10 files",
                      "SOLPS-ITER documents")])
    bar.start(files_total=10, legs_total=1)
    bar.begin_stage("SOLPS-ITER documents", verb="scan", unit="files",
                    total=10, counts_files=True)
    bar.tick(10)
    bar.end_stage()
    bar.begin_busy("verifying the index")
    bar.end_busy()
    bar.finish()
    frame = bar.frame()
    assert frame[0] == "Askthedocs indexation complete"
    assert frame[1] == "-" * 36
    # every row final, the result written into the row; the moving
    # pair is folded away
    assert any(line.startswith("indexed") and
               "SOLPS-ITER documents" in line and
               line.endswith("10 files") for line in frame), frame
    assert not any("elapsed" in line for line in frame), frame


def test_capture_keeps_read_lines_above_the_block():
    bar, _out = _captured()
    bar.set_pending([("SOLPS-ITER documents       10 files",
                      "SOLPS-ITER documents")])
    bar.start(files_total=10, legs_total=1)
    bar.begin_stage("SOLPS-ITER", verb="read", unit="files", total=3)
    bar.tick(3)
    bar.end_stage()
    bar.begin_stage("SOLPS-ITER documents", verb="scan", unit="files",
                    total=10, counts_files=True)
    frame = bar.frame()
    assert frame[0].startswith("read SOLPS-ITER: 3 files in"), frame
    bar.finish()


def test_capture_never_touches_the_stream():
    bar, stream = _captured()
    bar.set_pending([("a documents        2 files", "a documents")])
    bar.start(files_total=2, legs_total=1)
    bar.begin_stage("a documents", verb="scan", unit="files", total=2,
                    counts_files=True)
    bar.tick()
    bar.tick()
    bar.end_stage()
    bar.begin_busy("verifying the index")
    bar.end_busy()
    bar.finish()
    assert stream.getvalue() == ""   # frames only, never ANSI, never raw
