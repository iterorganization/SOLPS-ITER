"""The setup progress display: a pending list, a live pair, history
beneath.

The PENDING list opens the display: one line per category and
content class the run will index (repository documents, module
sources, the switch inventory), with true counts; a line leaves the
list the moment its stage settles. One GLOBAL line tracks the whole
pipeline: total files indexed n/N (with its own on-screen addition
while a file-counting stage runs), corpus legs x of X, elapsed time
(elapsed only: an estimate would be a guess, and the pipeline has no
business guessing). One CURRENT-STAGE line tracks the active stage,
gerund-first with the counted noun ("indexing B2.5 source 384/808
files", "building B2.5 switch index 611/892 entries"), counts
right-aligned, ASCII fill on an ASCII track.

Completed stages settle as permanent lines DIRECTLY UNDER the moving
pair, in completion order: what is running sits on top, what just
finished lands right beneath it (cause and effect adjacent), older
stages flow downward. Piped output (not a terminal) prints the
pending list once and the settled lines chronologically: no control
characters ever reach a pipe, a log file, or a terminal that cannot
reposition the cursor.
"""

from __future__ import annotations

import shutil
import sys
import threading
import time
from typing import IO

# preferred width of the [####----] track on the stage line; narrower
# terminals shrink it to fit, down to this floor
_TRACK = 22
_TRACK_MIN = 6

# the between-stages busy spinner: braille rotation where
# UTF-8 is provable, ASCII rotation as the fallback - the same
# doctrine as the bar glyphs
_SPIN_UNICODE = "⠋⠙⠹⠸⠼⠴⠦⠧⠇⠏"
_SPIN_ASCII = "-\\|/"


def _stream_is_utf8(stream: IO[str]) -> bool:
    """True only when the stream PROVABLY carries UTF-8: its declared
    encoding normalizes to utf-8. No declaration (a plain StringIO,
    tests) or any other encoding means NOT proven - the ASCII glyphs
    answer (the fallback IS the guarantee: ASCII is what renders
    whenever UTF-8 is not proven)."""
    import codecs
    enc = getattr(stream, "encoding", None)
    if not enc:
        return False
    try:
        return codecs.lookup(enc).name == "utf-8"
    except LookupError:
        return False
# redraw at most this often while ticks pour in (fast stages tick
# thousands of times per second; the eye needs ten frames)
_REDRAW_S = 0.10

# the moving line reads in the gerund, the settled line in the past
# tense ("indexing ..." / "indexed ...")
_GERUND = {"scan": "indexing", "build": "building",
          "read": "reading", "write": "writing"}
_PAST = {"scan": "indexed", "build": "built", "read": "read",
        "write": "wrote"}


def elapsed_str(seconds: float) -> str:
    """Elapsed time, compact: 41s / 2m04s / 1h03m."""
    s = int(seconds)
    if s < 60:
        return f"{s}s"
    if s < 3600:
        return f"{s // 60}m{s % 60:02d}"
    return f"{s // 3600}h{(s % 3600) // 60:02d}"


def _row_line(row: dict) -> str:
    """One table row: state column, then the category text (its
    count for queued/indexing rows, the result and duration once
    indexed)."""
    state = row["state"] if row["label"] else ""
    if row["done"] is not None:
        # replace the trailing count with the result + duration
        body = row["text"].rstrip()
        head, _, counts = body.rpartition("  ")
        body = f"{head}  {row['done']}" if counts else body
    else:
        body = row["text"]
    return f"{state:<9} {body}"


def _size_str(size_bytes: int) -> str:
    """Human file size: 840 B / 12.4 KB / 1.2 MB / 2.1 GB."""
    if size_bytes < 1024:
        return f"{size_bytes} B"
    for unit, factor in (("KB", 1024), ("MB", 1024 ** 2),
                         ("GB", 1024 ** 3)):
        if size_bytes < 1024 * factor:
            return f"{size_bytes / factor:.1f} {unit}"
    return f"{size_bytes / 1024 ** 3:.1f} GB"


class Progress:
    """The two-level bar, duck-typed into the build pipeline as
    ``progress=None``; every call site is a no-op when absent."""

    def __init__(self, stream: IO[str] | None = None, *,
                 interactive: bool | None = None,
                 columns: int | None = None,
                 rows: int | None = None,
                 ascii_only: bool | None = None,
                 capture: bool = False):
        self.stream = sys.stdout if stream is None else stream
        if interactive is None:
            try:
                interactive = self.stream.isatty()
            except (AttributeError, ValueError):
                interactive = False
        self.interactive = interactive
        # capture mode: the live block renders into an in-memory
        # frame (polled by the service's progress modal) instead of
        # ANSI writes - the SAME lines the interactive terminal
        # shows, by the same code path, so the web replay is the CLI
        # display by construction. A capture bar is live (ticks, file
        # bars, the busy spinner and the elapsed clock all render)
        # but never touches the stream.
        self._capture = capture
        self._live = interactive or capture
        self._frame: list[str] = []
        self._above: list[str] = []  # read-pass lines, above the block
        # bar glyphs: solid blocks when the
        # output PROVABLY carries UTF-8, the long-ruled ASCII pair
        # everywhere else - the fallback IS the guarantee, so an
        # unprovable stream (a plain StringIO, an undeclared locale)
        # renders ASCII. Block elements are single-width in every
        # UTF-8 terminal, so the width math is untouched.
        if ascii_only is None:
            ascii_only = not _stream_is_utf8(self.stream)
        # the unicode pair is measured Narrow (U+25B0/25B1);
        # the former fill U+2588 is East-Asian-AMBIGUOUS and
        # misaligns on wide-locale terminals - the invariant test
        # now forbids every Ambiguous/Wide codepoint in output
        self._fill, self._track_glyph = (
            ("#", "-") if ascii_only else ("▰", "▱"))
        self._spin = _SPIN_ASCII if ascii_only else _SPIN_UNICODE
        # the between-stages busy line: set while silent
        # finishing work runs (manifest re-hash, validation), so the
        # screen never freezes between the last stage and the summary
        self._busy: str | None = None
        self._busy_i = 0
        self._busy_t0 = 0.0
        # the block's title: names what is happening above
        # the table; the tense flips when the run finishes
        self._title: str | None = None
        # terminal geometry: given (tests, forced layouts) or queried
        # per repaint (a resized terminal is picked up live). Every
        # line MUST stay inside the width with a margin: a line that
        # reaches the last column leaves the cursor on the wrap edge,
        # and every later cursor-up then erases the wrong row (earned
        # live: a real terminal at the boundary garbled every frame).
        # And the whole block MUST stay inside the height: a block
        # taller than the screen makes the cursor-up clamp at the
        # screen top instead of the block top, and every later redraw
        # lands one row lower (earned live: the pending list repeated
        # itself line by line). Both lists are windowed to fit.
        self._columns = columns
        self._rows = rows
        self._t0 = time.monotonic()
        self._last_draw = 0.0
        self._files_done = 0
        self._files_total = 0
        self._legs_done = 0
        self._legs_total = 0
        # the open stage: verb key + name + unit ("scan" "SOLPS-ITER"
        # "files")
        self._verb = ""
        self._name = ""
        self._unit = ""
        # the file the stage is currently working (rendered beneath
        # the stage line; users know the documents, and a named wait
        # reads as progress, not a hang), plus its own bar: the
        # within-file work is truly countable (bytes while hashing,
        # pages while probing or extracting), each sub-pass with its
        # own true denominator
        self._file_line: str | None = None
        self._file_done = 0
        self._file_total: int | None = None
        self._file_unit = ""
        self._done = 0
        self._total: int | None = None
        self._counts_files = False
        self._stage_t0 = self._t0
        # settled stage lines, completion order (chronological)
        self._settled: list[str] = []
        # the category table: one row per category and content
        # class, carrying its state - queued, indexing, indexed (with
        # the result and duration written into the row). Rows never
        # leave; the state column tells the story. Entries without a
        # stage label (the excepted submodule) are informational
        self._pending: list[dict] = []
        # rows the live block currently occupies on screen (0 = never
        # drawn); the block is the pair plus the settled lines under it
        self._drawn_rows = 0
        # geometry the block was last drawn at: a resized terminal
        # reflows the wrapped history, so every stored row offset is
        # stale - the next redraw must start fresh rather than trust
        # the cursor-up (earned live: resizing mid-run repeated the
        # pending list)
        self._drawn_geometry: tuple[int, int] | None = None
        # the elapsed counter must move even when work does not: some
        # sources hold their stage for half a minute, and a display
        # frozen between ticks reads as hung. A daemon repaints on the
        # wall clock (ticks keep driving the counters; the clock only
        # refreshes the rendering).
        self._lock = threading.Lock()
        self._timer_stop = threading.Event()
        self._timer: threading.Thread | None = None

    # ------------------------------------------------------- lifecycle

    def start(self, files_total: int, legs_total: int) -> None:
        """Set the global totals, draw the empty display, and start
        the wall-clock repaints (interactive only)."""
        self._files_total = files_total
        self._legs_total = legs_total
        self._title = "Askthedocs indexation in progress"
        self._repaint(force=True)
        if self._live and self._timer is None:
            self._timer = threading.Thread(
                target=self._timer_loop, daemon=True,
                name="askthedocs-progress")
            self._timer.start()

    def _timer_loop(self) -> None:
        while not self._timer_stop.wait(1.0):
            with self._lock:
                self._spin_step()
                self._repaint_locked(force=True)

    def _spin_step(self) -> None:
        """Advance the busy spinner (called on every timer tick; a
        1 Hz rotation - the same clock the elapsed line uses)."""
        if self._busy is not None:
            self._busy_i += 1

    def begin_busy(self, label: str) -> None:
        """Show ONE live line while silent finishing work runs (the
        manifest re-hash, the index validation): spinner + label +
        elapsed, ticking on the wall clock - a frozen screen reads
        as a hang, and these stretches are real seconds.
        Cleared by the next stage or by finish(); invisible when
        piped (the pair never renders there)."""
        self._busy = label
        self._busy_i = 0
        self._busy_t0 = time.monotonic()
        self._repaint(force=True)

    def end_busy(self) -> None:
        self._busy = None
        self._repaint(force=True)

    def finish(self) -> None:
        """Settle any open stage, then leave the settled lines as the
        log (the moving pair is folded away)."""
        self._timer_stop.set()
        if self._timer is not None:
            self._timer.join(timeout=2.0)
            self._timer = None
        with self._lock:
            self._busy = None
            self._settle_open_stage()
            # the final log: the title (tense flipped), the finished
            # table (every row, its state final), any history
            self._title = "Askthedocs indexation complete"
            if self._capture:
                # the captured run's closing frame: exactly the lines
                # the interactive terminal prints as its final log -
                # the frame the progress modal keeps showing after
                # the job lands
                avail = self._term_columns() - 1
                closing: list[str] = []
                if self._title:
                    closing += [self._title[:avail],
                                "-" * min(avail, 36)]
                closing += ([_row_line(row)[:avail]
                             for row in self._pending]
                            + [line[:avail] for line in self._settled])
                self._frame = closing
                return
            if not self.interactive:
                return
            avail = self._term_columns() - 1
            self._move_to_block_top()
            lines = []
            if self._title:
                lines += [self._title[:avail],
                          "-" * min(avail, 36)]
            lines += ([_row_line(row)[:avail] for row in self._pending]
                     + [line[:avail] for line in self._settled])
            for i, line in enumerate(lines):
                self.stream.write("\x1b[2K" + line)
                if i < len(lines) - 1:
                    self.stream.write("\n")
            # the pair is gone: erase the rows it used to occupy
            for _ in range(len(lines), self._drawn_rows):
                self.stream.write("\n\x1b[2K")
            self.stream.write("\r")
            self._drawn_rows = 0
            self.stream.flush()

    # --------------------------------------------------------- pending

    def set_pending(self, entries: list[tuple[str, str | None]]) -> None:
        """The category table: what the run will index, one row per
        category and content class, in the order the work happens.
        Each entry is (rendered line, stage label); the row's state
        column moves queued -> indexing -> indexed as its stage
        runs and settles (matched by label)."""
        self._pending = [{"text": text, "label": label, "state": "queued",
                          "done": None}
                         for text, label in entries]
        if not self._live:
            for row in self._pending:
                self.stream.write(_row_line(row) + "\n")
            self.stream.flush()
            return
        self._repaint(force=True)

    # ---------------------------------------------------------- stages

    def begin_stage(self, name: str, *, verb: str, unit: str,
                    total: int | None = None,
                    counts_files: bool = False) -> None:
        """Open a stage: verb key, name, counted noun; the total may
        arrive later (``set_total``) when only the work itself
        reveals it."""
        if self._verb:
            self.end_stage()
        self._busy = None  # a live stage is its own aliveness
        self._verb = verb
        self._name = name
        self._unit = unit
        self._done = 0
        self._total = total
        self._counts_files = counts_files
        self._stage_t0 = time.monotonic()
        if verb in ("scan", "build"):
            # only indexing verbs move the table; read and write
            # stages are passes, not category states
            for row in self._pending:
                if row["label"] == name:
                    row["state"] = "indexing"
        self._repaint(force=True)

    def set_total(self, total: int) -> None:
        """Give the open stage its total (stages whose size only the
        work itself reveals)."""
        self._total = total
        self._repaint(force=True)

    def end_stage(self) -> None:
        """Settle the open stage as a line directly under the pair."""
        with self._lock:
            self._settle_open_stage()
            self._repaint_locked(force=True)

    def _settle_open_stage(self) -> None:
        if not self._verb:
            return
        past = _PAST.get(self._verb, self._verb + "ed")
        elapsed = elapsed_str(time.monotonic() - self._stage_t0)
        line = f"{past} {self._name}: {self._done} {self._unit} in {elapsed}"
        self._file_line = None
        self._file_done = 0
        self._file_total = None
        self._file_unit = ""
        if self._verb == "read":
            # reading is a first pass, not indexing progress: its
            # lines scroll away above the block (the block's history
            # is for indexed work only) and it never drains a pending
            # line, even though the stage carries the same name
            self._emit_above(line)
            self._verb = ""
            self._name = ""
            self._unit = ""
            self._done = 0
            self._total = None
            self._counts_files = False
            return
        if self._verb == "write":
            # the store-write heartbeat: its value is the LIVE bar
            # over the multi-second write; once the write is done it
            # leaves no trace in the block (the completion
            # block reports the totals).  Piped output keeps the
            # line - a log is exactly where the record belongs.
            if not self._live:
                self.stream.write(line + "\n")
                self.stream.flush()
            self._verb = ""
            self._name = ""
            self._unit = ""
            self._done = 0
            self._total = None
            self._counts_files = False
            return
        # category stages live in the table (state -> indexed, result
        # written into the row); only non-category stages (the
        # assembly) settle into the history below.  The row carries
        # the count only - one clock on screen (the global elapsed
        # line), never a per-stage one.
        row = next((r for r in self._pending
                    if r["label"] == self._name), None)
        if row is not None:
            row["state"] = "indexed"
            row["done"] = f"{self._done} {self._unit}"
        else:
            self._settled.append(line)
        if not self._live:
            # the pipe keeps a plain chronological log: settled lines
            # only, no control characters
            self.stream.write(line + "\n")
            self.stream.flush()
        self._verb = ""
        self._name = ""
        self._unit = ""
        self._done = 0
        self._total = None
        self._counts_files = False

    def _emit_above(self, text: str) -> None:
        """Print *text* as a scrolling line ABOVE the block (the block
        shifts down one row); with no block, or piped, it is a plain
        line."""
        if self._capture:
            # the frame keeps what a tall terminal keeps: the line
            # scrolls above the block and stays on screen
            self._above.append(text)
            return
        if not self.interactive or self._drawn_rows == 0:
            self.stream.write(text + "\n")
            self.stream.flush()
            return
        avail = self._term_columns() - 1
        lines = self._visible_lines(avail)
        self._move_to_block_top()
        parts = ["\x1b[2K" + text[:avail] + "\n"]
        for i, line in enumerate(lines):
            parts.append("\x1b[2K" + line)
            if i < len(lines) - 1:
                parts.append("\n")
        # everything shifted down one row: erase the stale bottom row
        # and return to the last content row
        parts.append("\n\x1b[2K")
        parts.append("\x1b[1A")
        self.stream.write("".join(parts))
        # the block now occupies len(lines) rows starting one lower:
        # the ledger must follow, or every later redraw addresses a
        # stale offset
        self._drawn_rows = len(lines)
        self.stream.flush()

    # ----------------------------------------------------------- ticks

    def current_file(self, path: str, size_bytes: int | None = None,
                     *, verb: str | None = None) -> None:
        """Name the file the open stage is working right now, in the
        stage's own verb ("reading doc/manual.pdf (1.2 MB)"). Ephemeral:
        cleared at the next call or when the stage settles; piped
        output never sees it."""
        if not self._live or not self._verb:
            return
        gerund = _GERUND.get(verb or self._verb, verb or self._verb)
        size = f" ({_size_str(size_bytes)})" if size_bytes is not None else ""
        self._file_line = f"  {gerund} {path}{size}"
        self._file_done = 0
        self._file_total = None
        self._file_unit = ""
        self._repaint()

    def file_total(self, total: int, unit: str) -> None:
        """Give the current file's bar its denominator ("B" for the
        hashing pass, "pages" for the page-wise pass); the count
        restarts with each denominator - each sub-pass is its own
        truth."""
        if not self._live or not self._verb:
            return
        self._file_done = 0
        self._file_total = total
        self._file_unit = unit
        self._repaint()

    def file_tick(self, n: int = 1) -> None:
        """Advance the current file's bar."""
        if not self._live or self._file_total is None:
            return
        self._file_done += n
        self._repaint()

    def tick(self, n: int = 1) -> None:
        """Advance the open stage (and the global files counter when
        the stage counts files)."""
        if not self._verb:
            return
        self._done += n
        if self._counts_files:
            self._files_done += n
        self._repaint()

    def leg_done(self) -> None:
        """One corpus leg finished: the global "corpus x of X" counter."""
        self._legs_done += 1
        self._repaint(force=True)

    @property
    def elapsed(self) -> float:
        return time.monotonic() - self._t0

    # ------------------------------------------------------- rendering

    def _global_line(self) -> str:
        elapsed = elapsed_str(self.elapsed)
        # totals only: the pending list carries the decomposition, and
        # with the single pass a file counts here exactly when it is
        # indexed (a per-leg counter here would duplicate it)
        return (f"total: {self._files_done}/{self._files_total} files "
                f"indexed, elapsed {elapsed}")

    def _term_columns(self) -> int:
        if self._columns is not None:
            return max(self._columns, 20)
        try:
            return max(shutil.get_terminal_size().columns, 20)
        except (ValueError, OSError):
            return 80

    def _term_lines(self) -> int:
        if self._rows is not None:
            return max(self._rows, 4)
        try:
            return max(shutil.get_terminal_size().lines, 4)
        except (ValueError, OSError):
            return 24

    def _stage_line(self, avail: int) -> str:
        """The stage line fitted to *avail* printable columns: the
        track shrinks first, a hard truncate is the last resort (the
        counts lead, so truncation only ever eats the tail)."""
        if not self._verb:
            return ""
        gerund = _GERUND.get(self._verb, self._verb)
        total = self._total
        if total:
            width = len(str(total))
            counted = f"{self._done:>{width}}/{total}"
            pct = f"{100 * self._done // total:>3}%"
            head = f"  {gerund} {self._name} {counted} {self._unit} "
            track = avail - len(head) - len(pct) - 3
            track = min(_TRACK, track)
            if track >= _TRACK_MIN:
                filled = track * self._done // total
                bar = f"[{self._fill * filled}" \
                      f"{self._track_glyph * (track - filled)}]"
                return f"{head}{bar} {pct}"
            return f"{head}{pct}"[:avail]
        return f"  {gerund} {self._name} {self._done} {self._unit}"[:avail]

    def _visible_lines(self, avail: int) -> list[str]:
        """The block as it fits the terminal: the category table
        (windowed around the active row when short), a rule, the
        live pair, and - only for non-category stages - a small
        history below a second rule."""
        table = [_row_line(row)[:avail] for row in self._pending]
        settled = [line[:avail] for line in self._settled]
        stage = self._stage_line(avail)
        pair = [self._global_line()[:avail]]
        if stage:
            pair.append(stage)
        if self._busy is not None and not stage:
            glyph = self._spin[self._busy_i % len(self._spin)]
            pair.append(f"  [{glyph}] {self._busy}  "
                        f"{elapsed_str(time.monotonic() - self._busy_t0)}"
                        [:avail])
        if self._file_line:
            line = self._file_line
            if self._file_total:
                total = self._file_total
                done = min(self._file_done, total)
                filled = _TRACK * done // total if total else 0
                bar = ("[" + self._fill * filled
                       + self._track_glyph * (_TRACK - filled) + "]")
                if self._file_unit == "B":
                    counts = (f"{_size_str(done)}/{_size_str(total)}")
                else:
                    width = len(str(total))
                    counts = (f"{done:>{width}}/{total} "
                              f"{self._file_unit}")
                line = f"{line} {bar} {counts}"
            if len(line) > avail:
                # keep the filename: paths truncate from the left
                line = "..." + line[-(avail - 3):]
            pair.append(line[:avail])
        budget = max(len(pair) + 1, self._term_lines() - 2)
        # rows available for the table and the history, their rules
        # and markers included; the title block costs its two rows
        # first so the window shrinks, never the screen
        title_rows = 2 if self._title else 0
        room = budget - len(pair) - title_rows \
            - (1 if table else 0) - (1 if settled else 0)
        n_t = min(len(table), max(0, room - len(settled)))
        n_s = min(len(settled), max(0, room - n_t))
        # the window centers on the active row so the action stays
        # visible however far down the table it has moved
        active = next((i for i, row in enumerate(self._pending)
                       if row["state"] == "indexing"), 0)
        start = 0
        if len(table) > n_t > 0:
            n_t -= 1  # the trailing "+N more rows" marker costs a row
            start = min(max(0, active - n_t // 2), len(table) - n_t)
        rule = "-" * min(avail, 36)
        lines: list[str] = []
        if self._title:
            lines += [self._title[:avail], rule]
        if table:
            if start > 0:
                lines.append(f"... +{start} earlier rows")
            lines += table[start:start + n_t]
            if start + n_t < len(table):
                lines.append(f"... +{len(table) - start - n_t} more rows")
            # everything below the rule is happening now
            lines.append(rule)
        lines += pair
        if n_s:
            # everything above the rule is finished
            lines.append(rule)
            if len(settled) > n_s:
                lines.append(f"... +{len(settled) - n_s} earlier")
            lines += settled[-n_s:]
        if not lines:
            lines = pair
        # hard cap: the block must never exceed the screen whatever
        # happened - trim from the top rather than garble the redraw
        return lines[-budget:] if len(lines) > budget else lines

    def frame(self) -> list[str]:
        """The current screen as lines (capture mode): everything
        emitted above the block, then the block itself - the same
        lines an interactive terminal is showing right now.
        Snapshot under the lock; safe to poll from another thread."""
        with self._lock:
            return [*self._above, *self._frame]

    def _repaint(self, force: bool = False) -> None:
        if not self._live:
            return
        with self._lock:
            self._repaint_locked(force)

    def _repaint_locked(self, force: bool) -> None:
        if not self._live:
            return  # never bypass the guard: pipes get settled lines only
        if (not self._verb and not self._settled and not self._pending
                and self._busy is None):
            # nothing left to show: erase the block rather than leave
            # its rows stale on screen
            if self._capture:
                self._frame = []
                return
            if self._drawn_rows:
                self._move_to_block_top()
                self.stream.write(
                    "".join("\n\x1b[2K" for _ in range(self._drawn_rows)))
                self.stream.write(f"\x1b[{self._drawn_rows - 1}A\r")
                self._drawn_rows = 0
                self.stream.flush()
            return
        now = time.monotonic()
        if not force and now - self._last_draw < _REDRAW_S:
            return
        self._last_draw = now
        avail = self._term_columns() - 1  # never the last column
        geometry = (avail, self._term_lines())
        if geometry != self._drawn_geometry:
            # the terminal was resized: the reflowed history invalidates
            # every row offset - draw fresh (scroll into view) instead
            # of rewriting at stale positions
            self._drawn_rows = 0
            self._drawn_geometry = geometry
        lines = self._visible_lines(avail)
        if self._capture:
            # the frame IS the draw: same lines the terminal would
            # repaint, stored instead of written
            self._frame = lines
            return
        parts: list[str] = []
        if self._drawn_rows == 0:
            # scroll the block into view: the block occupies the last
            # rows of the screen, so the cursor-up can never clamp
            # above its true top
            parts.append("\n" * (len(lines) - 1))
        else:
            self._move_to_block_top()
        for i, line in enumerate(lines):
            # explicit per-line erases, never padding: no line can
            # reach the wrap edge, so the cursor-up always addresses
            # the block's own first row
            parts.append("\x1b[2K" + line)
            if i < len(lines) - 1:
                parts.append("\n")
        stale = self._drawn_rows - len(lines)
        for _ in range(max(0, stale)):
            parts.append("\n\x1b[2K")
        if stale > 0:
            # return to the last content row
            parts.append(f"\x1b[{stale}A\r")
        self.stream.write("".join(parts))
        self._drawn_rows = len(lines)
        self.stream.flush()

    def _move_to_block_top(self) -> None:
        """Step the cursor from the end of the block's last row to the
        start of its first row (no-op when nothing is drawn)."""
        if self._drawn_rows:
            self.stream.write(f"\x1b[{self._drawn_rows - 1}A\r")
