"""The reindex child process: the web-triggered rebuild out of the
service process.

POST /reindex spawns this module (``python -m askthedocs.reindexjob``)
instead of running the rebuild on a service thread.  The indexer is
CPU-bound python, so a dedicated interpreter gives it its own GIL (the
service's request loop, the freshness hash and every route keep theirs)
and adds fault isolation: a crash on a pathological document kills this
child alone, and the service reads the failure from the result record
and reports it - the served store and the service survive.  The child
is a THIN wrapper: it builds the same capture display the in-process
job drove, streams the current frame to a file the service tails,
calls the shared display-driven driver
(:func:`askthedocs.setup.run_index_build`) UNCHANGED - the CLI setup
verb runs the same call in its own process, so every face that
rebuilds an index now runs the driver process-for-process identically
- and writes a small result record beside the frame.

Protocol (both files are written atomically: a temp file beside the
target, then os.replace, so a reader never sees a partial document):

- the frame file: one JSON document, the current frame's line list,
  refreshed about once a second while the display lives and once more
  (the closing frame) after the build lands.  GET /reindex serves it,
  so the web progress modal replays the exact CLI lines.
- the result file: one JSON document written once at the end - ok with
  the summary fields the service's job slot reports (chunks, store
  digest, carried legs, duration), or the failure message.  The exit
  code carries the verdict too: 0 on success, nonzero on failure.
"""

from __future__ import annotations

import argparse
import json
import os
import threading
import time
from pathlib import Path
from typing import Any

from askthedocs import setup as setup_mod
from askthedocs.progress import Progress

# the frame refresh cadence (seconds): the display itself repaints at
# up to 10 Hz, but the served wire carries one frame per poll tick
# (about 2 s), so one write per second covers every poll with change
# detection to spare
_FRAME_S = 1.0


def write_json_atomic(path: Path, document: Any) -> None:
    """One JSON document landing whole or not at all (temp file beside
    the target + os.replace: same directory, same filesystem, atomic
    swap).  The service reads these files at poll time, so a reader
    can never observe a half-written frame or record."""
    tmp = path.with_name(path.name + ".tmp")
    tmp.write_text(json.dumps(document), encoding="utf-8")
    os.replace(tmp, path)


def _stream_frames(bar: Progress, frame_file: Path,
                   stop: threading.Event) -> None:
    """Tail the capture bar into the frame file: sample about 1 Hz,
    write ATOMICALLY on change (the elapsed clock ticks every second,
    so a live run writes every tick; a still display costs nothing).
    The closing frame is written by the main thread after the driver
    settles the display."""
    last: list[str] | None = None
    while True:
        lines = bar.frame()
        if lines != last:
            write_json_atomic(frame_file, lines)
            last = lines
        if stop.wait(_FRAME_S):
            return


def main(argv: list[str] | None = None) -> int:
    """Child entry: run the shared display-driven rebuild, streaming
    frames and landing the result record.  The driver call itself is
    the exact call the CLI makes (same bar construction, same
    temporary build directory swapped in only on success)."""
    ap = argparse.ArgumentParser(
        prog="askthedocs.reindexjob",
        description="the reindex child process: the shared "
                    "display-driven rebuild in its own interpreter "
                    "(spawned by the askthedocs service)")
    ap.add_argument("--leg", action="append", required=True,
                    metavar="NAME=PATH",
                    help="one corpus leg to index, as NAME=PATH "
                         "(repeatable): the exact legs the service "
                         "resolved, so the child builds precisely "
                         "what the drift gate measured")
    ap.add_argument("--build-dir", type=Path, required=True,
                    help="the temporary build directory (cleaned by "
                         "the driver on any failure)")
    ap.add_argument("--final-dir", type=Path, required=True,
                    help="the directory the store and its companions "
                         "swap into on success")
    ap.add_argument("--carry-from", type=Path, default=None,
                    help="the served store to carry vanished legs from")
    ap.add_argument("--frame-file", type=Path, required=True,
                    help="where the live display frame is streamed")
    ap.add_argument("--result-file", type=Path, required=True,
                    help="where the end-of-run record is written")
    args = ap.parse_args(argv)

    repos: dict[str, Path] = {}
    for leg in args.leg:
        name, sep, path = leg.partition("=")
        if not sep or not name:
            ap.error(f"--leg expects NAME=PATH, got {leg!r}")
        repos[name] = Path(path)

    # the SAME capture display the service's in-process job drove:
    # identical construction, so the frames the web progress modal
    # replays are the CLI lines by the same code path as before
    bar = Progress(capture=True, columns=73, rows=100_000,
                   ascii_only=False)
    stop = threading.Event()
    streamer = threading.Thread(
        target=_stream_frames, args=(bar, args.frame_file, stop),
        daemon=True, name="askthedocs-reindex-frames")
    streamer.start()
    t0 = time.monotonic()
    try:
        summary, _icon = setup_mod.run_index_build(
            repos, bar=bar, build_dir=args.build_dir,
            final_dir=args.final_dir, carry_from=args.carry_from)
    except BaseException as exc:  # noqa: BLE001 - the failure crosses
        # the process boundary as the record, never as a traceback
        stop.set()
        streamer.join(timeout=5.0)
        import shutil
        shutil.rmtree(args.build_dir, ignore_errors=True)
        write_json_atomic(args.result_file, {
            "ok": False,
            "error": str(exc) or exc.__class__.__name__,
            "duration_s": time.monotonic() - t0})
        return 1
    stop.set()
    streamer.join(timeout=5.0)
    # the closing frame: the driver's finish() settled the display
    # (this is the frame the poll keeps serving after the job lands)
    write_json_atomic(args.frame_file, bar.frame())
    write_json_atomic(args.result_file, {
        "ok": True,
        "duration_s": time.monotonic() - t0,
        # summary-shaped on purpose: the service's job slot reads
        # exactly these keys
        "chunks": summary.get("chunks"),
        "db_sha256": summary.get("db_sha256"),
        "carry": summary.get("carry")})
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
