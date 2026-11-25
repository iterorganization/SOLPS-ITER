"""One-click launch: ``askthedocs open``.

Idempotent: when the port already answers, the browser simply opens;
when it does not, the service is spawned DETACHED (the same db
ladder and static resolution the service itself uses — the log's
location named, never a silent hang), the port is awaited with a
generous timeout, and then the browser opens.  Pure standard
library, byte-identical behavior on macOS, Linux, Windows — the
per-OS split lives only in :mod:`askthedocs.shortcut`'s writers and
in the two one-line platform branches here (browser opener, detach
flags).
"""

from __future__ import annotations

import os
import socket
import subprocess
import sys
import time
from pathlib import Path

# the detached service's log — created beside the LAUNCH DIRECTORY
# (wherever `askthedocs open` runs), its path printed loudly
SERVICE_LOG = "askthedocs-service.log"


def port_answers(port: int, host: str = "127.0.0.1",
                 timeout: float = 1.0) -> bool:
    """True when something already listens — the idempotence probe
    (a plain connect: cheaper than HTTP, and enough to decide)."""
    try:
        with socket.create_connection((host, port), timeout=timeout):
            return True
    except OSError:
        return False


def wait_port(port: int, host: str = "127.0.0.1",
              timeout: float = 60.0) -> bool:
    """Await the port, polling; False on timeout (the caller reports
    loudly — a launch never hangs silently)."""
    deadline = time.monotonic() + timeout
    while time.monotonic() < deadline:
        if port_answers(port, host, timeout=1.0):
            return True
        time.sleep(0.2)
    return False


def open_browser(url: str) -> None:
    """The one platform branch the click-path needs.

    The browser's own console noise never lands in the user's
    terminal: on a headless cluster the browser may complain for
    minutes about a missing system bus it will never find, and none
    of it is ours to show.  The child gets the null streams; the
    address is already printed by the caller."""
    if sys.platform == "darwin":
        subprocess.run(["open", url], check=False,
                       stdout=subprocess.DEVNULL,
                       stderr=subprocess.DEVNULL)
    elif os.name == "nt":
        os.startfile(url)  # type: ignore[attr-defined]
    else:
        subprocess.run(["xdg-open", url], check=False,
                       stdout=subprocess.DEVNULL,
                       stderr=subprocess.DEVNULL)


def resolve_static() -> Path | None:
    """The certified web client, wherever this install can find one.

    1. ``ASKTHEDOCS_STATIC`` — an explicit directory, honored
       verbatim (the service reads the same env at its own boot);
    2. ``<cwd>/askthedocs/web/build`` — a source checkout beside
       the launch directory (its fresh build outranks the packaged
       copy, so client development needs no reinstall);
    3. the packaged copy — ``web/`` inside the installed package
       itself (the pip install carries the certified client,
       so the one-click works from any directory; kept in lockstep
       with ``web/build`` by the byte-identity test);
    4. absent — the service boots API-only; ``open`` explains and
       never opens the browser onto a bare 404 page.
    """
    env = os.environ.get("ASKTHEDOCS_STATIC")
    if env:
        return Path(env)
    beside = Path.cwd() / "askthedocs" / "web" / "build"
    if beside.is_dir():
        return beside
    packaged = Path(__file__).resolve().parent / "web"
    if (packaged / "index.html").is_file():
        return packaged
    return None


def spawn_service(port: int, host: str = "127.0.0.1") -> Path:
    """Start the service detached; returns the log path (printed by
    the caller).  The db resolves through the service's own ladder
    (env, launch-dir artifact, user share) — nothing is duplicated
    here."""
    log_path = Path.cwd() / SERVICE_LOG
    cmd = [sys.executable, "-m", "askthedocs.service",
           "--host", str(host), "--port", str(port)]
    static = resolve_static()
    if static is not None:
        cmd += ["--static", str(static)]
    kwargs: dict = {}
    if os.name == "nt":
        kwargs["creationflags"] = (
            getattr(subprocess, "CREATE_NEW_PROCESS_GROUP", 0)
            | getattr(subprocess, "DETACHED_PROCESS", 0))
    else:
        kwargs["start_new_session"] = True
    with open(log_path, "ab") as log:
        subprocess.Popen(cmd, stdout=log, stderr=log,
                         stdin=subprocess.DEVNULL, **kwargs)
    return log_path


def _http_json(url: str, timeout: float = 3.0) -> dict | None:
    """One GET, JSON-decoded; None on any failure (an older service
    without /reindex simply answers nothing the guard needs)."""
    import json as _json
    import urllib.request
    try:
        with urllib.request.urlopen(url, timeout=timeout) as res:
            return _json.loads(res.read().decode("utf-8"))
    except Exception:  # noqa: BLE001 — the guard degrades to absent
        return None


def _http_status(url: str, timeout: float = 3.0) -> int | None:
    """Status code of one GET, or None on any failure. HTTPError is
    a real answer (a 404 at the page root is how an API-only
    service says it has no web client mounted)."""
    import urllib.error
    import urllib.request
    try:
        with urllib.request.urlopen(url, timeout=timeout) as res:
            return int(res.status)
    except urllib.error.HTTPError as exc:
        return int(exc.code)
    except Exception:  # noqa: BLE001 — the probe degrades to unknown
        return None


def _probe_search(url: str, timeout: float = 3.0) -> tuple[int, str] | None:
    """One cheap search against the running service: (status, detail),
    where detail is the service's own refusal text when it answered
    one (its 503s carry the full named reason: the accepted index
    placements and the fix).  None when the probe itself got no
    answer - nothing is concluded from silence."""
    import json as _json
    import urllib.error
    import urllib.request
    try:
        with urllib.request.urlopen(
                f"{url}search?q=solver&limit=1", timeout=timeout) as res:
            return int(res.status), ""
    except urllib.error.HTTPError as exc:
        detail = ""
        try:
            detail = str(_json.loads(
                exc.read().decode("utf-8")).get("detail", ""))
        except Exception:  # noqa: BLE001 — the body is best-effort
            pass
        return int(exc.code), detail
    except Exception:  # noqa: BLE001 — the probe degrades to unknown
        return None


def _report_blind_service(url: str, detail: str, *, fresh: bool) -> None:
    """Print why the (running or freshly started) service cannot
    search, in the service's own words, plus the remedy.

    The named-refusal rule holds end to end: the service answers a
    503 that names the accepted index placements and the fix, and
    the web client's error card swallows it (a generic 'may be
    unreachable').  This is the terminal's copy of that reason, so
    a store-blind service is diagnosed at the desktop in one line,
    never through a browser trip onto a failing page."""
    print(f"the service on {url} is running but cannot search:")
    for line in detail.splitlines() or [""]:
        print(f"  {line}")
    if fresh:
        print("the service was just started from THIS shell, and this "
              "shell sees no index: the reason above names the "
              "accepted placements and the variable that points at "
              "one. Export it, then start it again:")
    else:
        print("a service started from a shell that can see the index "
              "finds it; start a fresh one:")
    print(f"  {sys.argv[0]} open --restart")


def _pids_on_port(port: int) -> list[int]:
    """The PID(s) listening on the port — lsof on macOS/Linux,
    netstat on Windows; loud when neither can answer (the manual
    fallback is named, never a silent skip)."""
    try:
        if os.name == "nt":
            out = subprocess.run(["netstat", "-ano"], capture_output=True,
                                 text=True).stdout
            pids = [int(parts[4]) for parts in
                    (line.split() for line in out.splitlines())
                    if len(parts) >= 5 and parts[3] == "LISTENING"
                    and parts[1].endswith(f":{port}")]
        else:
            out = subprocess.run(["lsof", "-ti", f":{port}"],
                                 capture_output=True,
                                 text=True).stdout
            pids = [int(x) for x in out.split()]
        return sorted(set(pids))
    except (OSError, ValueError) as exc:
        raise SystemExit(
            f"error: cannot find the service on port {port} ({exc}); "
            "stop it by hand and re-run without --restart")


def _stop_service(port: int) -> list[int]:
    """Stop the listener(s) by PID; returns the PIDs stopped."""
    pids = _pids_on_port(port)
    if not pids:
        raise SystemExit(
            f"error: nothing identifiable is listening on port {port}: "
            "stop the service by hand and re-run without --restart")
    for pid in pids:
        if os.name == "nt":
            subprocess.run(["taskkill", "/F", "/PID", str(pid)],
                           check=False)
        else:
            subprocess.run(["kill", str(pid)], check=False)
    return pids


def open_cmd(port: int, host: str = "127.0.0.1",
             restart: bool = False) -> int:
    """The ``askthedocs open`` body — returns the exit code.

    With *restart* and a service already up: the explicit
    convergence verb — refuses while a rebuild is in flight (the
    seatbelt: nobody restarts INTO a rebuild on purpose; the guard
    exists for the accident), otherwise stops the server and starts
    a fresh one carrying the current baked context."""
    url = f"http://{host}:{port}/"
    if port_answers(port, host):
        if not restart:
            if _http_status(url) == 404:
                # an API-only service (or a stale one started before a
                # client existed): opening the browser lands on a bare
                # 404 page - name it and hand over the convergence
                # verb instead (no browser trip to nowhere)
                print(f"the service on {url} is API-only: it carries "
                      "no web client, so there is no page to open.")
                print("start a fresh one with the web version:")
                print(f"  {sys.argv[0]} open --restart")
                return 0
            probe = _probe_search(url)
            if probe is not None and probe[0] == 503:
                # a service whose index lookup sees nothing (an index
                # built into a moved home this service's shell never
                # knew, or no index at all): its 503 carries the full
                # named reason. Print it here - the page's error card
                # would swallow it - and skip the browser trip.
                _report_blind_service(url, probe[1], fresh=False)
                return 0
            print(f"askthedocs already running: opening {url}")
            open_browser(url)
            return 0
        job = _http_json(f"http://{host}:{port}/reindex")
        if job and job.get("status") == "running":
            print(
                f"error: a rebuild is running (started "
                f"{job.get('started_at', '?')}); retry --restart when "
                "it lands; its progress is in the service log",
                file=sys.stderr)
            return 1
        pids = _stop_service(port)
        print(f"stopped the running service (pid "
              f"{', '.join(str(p) for p in pids)}); starting fresh "
              "with the current context")
        while port_answers(port, host):
            time.sleep(0.2)  # the port frees asynchronously
    log_path = spawn_service(port, host)
    static = resolve_static()
    print(f"starting askthedocs on {url}"
          + ("" if static is not None else " (API only)"))
    if static is None:
        print("  no web client found for this install (a broken "
              "install - the package ships one); ASKTHEDOCS_STATIC "
              "can point at a client directory. The API works; "
              "there is no page to open.")
    print(f"service log: {log_path}")
    if not wait_port(port, host):
        print(f"error: the service did not answer on {url} within the "
              f"timeout; the log above names why", file=sys.stderr)
        return 1
    probe = _probe_search(url)
    if probe is not None and probe[0] == 503:
        # the just-started service sees no index either (spawned from
        # this shell, which cannot see one): name it now rather than
        # letting the browser land on the failing page
        _report_blind_service(url, probe[1], fresh=True)
        return 0
    if static is not None:
        open_browser(url)
        print(f"open: {url}")
    else:
        print(f"api: {url} (API only)")
    return 0
