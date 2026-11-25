"""``askthedocs shortcut`` — one launcher icon per platform.

The per-OS split lives HERE and only here: every writer bakes the
absolute path of the installed ``askthedocs`` console entry point
(resolved at install time — a moved venv needs a re-run, and the
writer says so), is idempotent (re-running overwrites and says so),
and every placement is named loudly.  All user-level, no admin on
any platform:

* macOS  — a minimal generated ``.app`` bundle under
           ``~/Applications`` (no code signing needed for a locally
           created bundle), carrying the wordmark-tick icon;
* Linux  — a ``.desktop`` entry in ``~/.local/share/applications``,
           with the tick icon in the per-user hicolor tree;
* Windows— a ``.lnk`` in the per-user Start Menu Programs folder
           (the one Start-Menu shape that can carry an icon),
           launching a ``.cmd`` kept in ``%LOCALAPPDATA%\\askthedocs``.

The click runs ``askthedocs open`` — the idempotent core that is
byte-identical everywhere (:mod:`askthedocs.launch`).  The icon
assets ship INSIDE the package (``assets/`` beside this module, the
web favicon rendered per platform); a missing asset, or a ``.lnk``
the stock PowerShell cannot build, degrades to an icon-less
launcher with a note — the icon is an enhancement, never a gate.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path

APP_NAME = "Askthedocs"
CMD = ("askthedocs", "open")

# env vars captured at INSTALL time and re-exported by the launcher
# (a clicked icon inherits no shell environment — everything the
# service resolves through env would otherwise be lost)
BAKED_ENV = ("ASKTHEDOCS_HOME", "ASKTHEDOCS_DB", "ASKTHEDOCS_STATIC",
             "ASKTHEDOCS_REPOS_ROOT")


def _baked_values() -> dict[str, str]:
    """The environment the launcher re-exports: every captured var
    present at install time, plus the live index home when a redirect
    is active and nothing was exported (``setup --home`` without an
    export would otherwise bake an icon that cannot find the index it
    just built; an explicit export always wins).  os.environ is read,
    never mutated."""
    from askthedocs import locate
    values = {k: os.environ[k] for k in BAKED_ENV if k in os.environ}
    if locate.index_home_redirected() and locate.HOME_ENV not in values:
        values[locate.HOME_ENV] = str(locate.index_home())
    return values


def _asset(name: str) -> Path | None:
    """A vendored icon asset shipped inside the installed package,
    or None when absent (the writers then install icon-less; the
    icon is an enhancement, never a gate)."""
    p = Path(__file__).resolve().parent / "assets" / name
    return p if p.is_file() else None


def _cli_path() -> Path:
    """Absolute path of the installed console entry point — baked
    into the shortcut at install time.  Resolved from THIS very
    executable first (``.venv/bin/askthedocs shortcut`` runs the
    entry point by absolute path without the venv ever being on
    PATH — the field test bit exactly there), then PATH."""
    argv0 = Path(sys.argv[0])
    if argv0.name == CMD[0] and argv0.is_file():
        return argv0.resolve()
    found = shutil.which(CMD[0])
    if found is None:
        raise SystemExit(
            "error: the askthedocs command was not found; run this "
            "from the installed entry point (e.g. "
            ".venv/bin/askthedocs shortcut) or with its venv "
            "activated")
    return Path(found).resolve()


def _launch_dir() -> Path:
    """The directory the shortcut was created in — the launcher CD-s
    here first, so the cwd ladder (./askthedocs-db/, the unpacked
    web client beside) resolves exactly as the terminal flow does.
    A clicked icon would otherwise start at / and find nothing."""
    return Path.cwd().resolve()


def _env_lines(shell: str) -> str:
    """Export lines for every ASKTHEDOCS_* var present at install
    time (field-earned: without them, the icon loses the db, the
    client, or the repos root the terminal flow had)."""
    present = list(_baked_values().items())
    if not present:
        return ""
    if shell == "sh":
        body = "".join(f"export {k}='{v}'\n" for k, v in present)
    else:  # cmd
        body = "".join(f'set "{k}={v}"\r\n' for k, v in present)
    return body


# ---------------------------------------------------------------- darwin

def install_darwin(cli: Path) -> Path:
    """A minimal .app bundle: Info.plist + a shell launcher.  Locally
    created bundles need no code signing (Gatekeeper's quarantine
    bit only applies to downloaded files).  The launcher CD-s to
    the install-time directory and re-exports the captured env — a
    clicked icon inherits neither cwd nor shell environment."""
    app = Path.home() / "Applications" / f"{APP_NAME}.app"
    macos = app / "Contents" / "MacOS"
    macos.mkdir(parents=True, exist_ok=True)
    icon = _asset("appicon.icns")
    icon_key = ""
    if icon is not None:
        resources = app / "Contents" / "Resources"
        resources.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(icon, resources / "appicon.icns")
        icon_key = ('  <key>CFBundleIconFile</key>'
                    '<string>appicon.icns</string>\n')
    (app / "Contents" / "Info.plist").write_text(
        '<?xml version="1.0" encoding="UTF-8"?>\n'
        '<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" '
        '"http://www.apple.com/DTDs/PropertyList-1.0.dtd">\n'
        '<plist version="1.0"><dict>\n'
        f'  <key>CFBundleName</key><string>{APP_NAME}</string>\n'
        '  <key>CFBundleIdentifier</key><string>local.askthedocs'
        '</string>\n'
        '  <key>CFBundleExecutable</key><string>askthedocs-open'
        '</string>\n'
        '  <key>CFBundlePackageType</key><string>APPL</string>\n'
        + icon_key +
        '</dict></plist>\n', encoding="utf-8")
    exe = macos / "askthedocs-open"
    exe.write_text(
        '#!/bin/sh\n'
        f"cd '{_launch_dir()}'\n"
        + _env_lines("sh")
        + f'exec "{cli}" {" ".join(CMD[1:])}\n', encoding="utf-8")
    exe.chmod(0o755)
    return app


def remove_darwin() -> Path:
    app = Path.home() / "Applications" / f"{APP_NAME}.app"
    shutil.rmtree(app, ignore_errors=True)
    return app


# ---------------------------------------------------------------- linux

def install_linux(cli: Path) -> Path:
    desktop = (Path.home() / ".local" / "share" / "applications"
               / "askthedocs.desktop")
    desktop.parent.mkdir(parents=True, exist_ok=True)
    # .desktop Exec has no cd — the launcher shells out to restore
    # the install-time cwd and captured env before exec-ing open
    exports = "".join(
        f"export {k}='{v}'; " for k, v in _baked_values().items())
    icon = _asset("favicon.svg")
    icon_line = ""
    if icon is not None:
        icon_dest = (Path.home() / ".local" / "share" / "icons"
                     / "hicolor" / "scalable" / "apps"
                     / "askthedocs.svg")
        icon_dest.parent.mkdir(parents=True, exist_ok=True)
        shutil.copyfile(icon, icon_dest)
        icon_line = "Icon=askthedocs\n"
    desktop.write_text(
        "[Desktop Entry]\n"
        "Type=Application\n"
        f"Name={APP_NAME}\n"
        "Comment=SOLPS-ITER knowledge layer\n"
        f"Exec=sh -c \"cd '{_launch_dir()}' && {exports}"
        f"exec '{cli}' {' '.join(CMD[1:])}\"\n"
        "Terminal=false\n"
        "Categories=Science;\n"
        + icon_line, encoding="utf-8")
    return desktop


def remove_linux() -> Path:
    desktop = (Path.home() / ".local" / "share" / "applications"
               / "askthedocs.desktop")
    desktop.unlink(missing_ok=True)
    (Path.home() / ".local" / "share" / "icons" / "hicolor"
     / "scalable" / "apps" / "askthedocs.svg").unlink(missing_ok=True)
    return desktop


# -------------------------------------------------------------- windows

def _ps_quote(value: Path | str) -> str:
    """Single-quote a path for the PowerShell command line."""
    return str(value).replace("'", "''")


def _make_lnk(lnk: Path, target: Path, workdir: Path,
              icon: Path) -> None:
    """Create a .lnk via the stock PowerShell COM wrapper: no admin,
    no script file on disk, safe under the default execution policy
    (``-Command`` is not a script)."""
    ps = (
        "$s = (New-Object -ComObject WScript.Shell)"
        f".CreateShortcut('{_ps_quote(lnk)}'); "
        f"$s.TargetPath = '{_ps_quote(target)}'; "
        f"$s.WorkingDirectory = '{_ps_quote(workdir)}'; "
        f"$s.IconLocation = '{_ps_quote(icon)},0'; "
        "$s.Save()")
    subprocess.run(["powershell", "-NoProfile", "-Command", ps],
                   check=True, capture_output=True)


def install_windows(cli: Path) -> Path:
    """A .lnk in the per-user Start Menu carrying the tick icon and
    launching a real .cmd kept beside the icon in
    ``%LOCALAPPDATA%\\askthedocs`` (the .cmd is the same baked
    launcher the other platforms write).  With no icon asset, or a
    PowerShell that cannot build the .lnk, the writer falls back to
    the icon-less .cmd directly in the menu with a note: the
    launcher always installs, the icon never gates it."""
    home = Path.home()
    menu = (home / "AppData" / "Roaming" / "Microsoft" / "Windows"
            / "Start Menu" / "Programs")
    menu.mkdir(parents=True, exist_ok=True)
    data = home / "AppData" / "Local" / "askthedocs"
    data.mkdir(parents=True, exist_ok=True)
    cmd = data / "askthedocs-launch.cmd"
    cmd.write_text(
        "@echo off\r\n"
        f'cd /d "{_launch_dir()}"\r\n'
        + _env_lines("cmd")
        + f'"{cli}" {" ".join(CMD[1:])}\r\n', encoding="utf-8")
    icon = _asset("appicon.ico")
    if icon is None:
        fallback = menu / "askthedocs.cmd"
        shutil.copyfile(cmd, fallback)
        return fallback
    icon_dest = data / "appicon.ico"
    shutil.copyfile(icon, icon_dest)
    lnk = menu / f"{APP_NAME}.lnk"
    try:
        _make_lnk(lnk, cmd, _launch_dir(), icon_dest)
    except (OSError, subprocess.CalledProcessError) as exc:
        fallback = menu / "askthedocs.cmd"
        shutil.copyfile(cmd, fallback)
        print(f"note: the Start Menu entry installed WITHOUT the "
              f"icon (the .lnk could not be created: {exc}); the "
              f"launcher itself is at {fallback}", file=sys.stderr)
        return fallback
    return lnk


def remove_windows() -> Path:
    menu = (Path.home() / "AppData" / "Roaming" / "Microsoft"
            / "Windows" / "Start Menu" / "Programs")
    lnk = menu / f"{APP_NAME}.lnk"
    lnk.unlink(missing_ok=True)
    # the icon-less fallback (and pre-icon installs) lived here
    (menu / "askthedocs.cmd").unlink(missing_ok=True)
    shutil.rmtree(Path.home() / "AppData" / "Local" / "askthedocs",
                  ignore_errors=True)
    return lnk


# ------------------------------------------------------------- dispatch

def install() -> Path:
    """Write this platform's launcher; returns its path (the caller
    prints it loudly)."""
    cli = _cli_path()
    if sys.platform == "darwin":
        return install_darwin(cli)
    if os.name == "nt":
        return install_windows(cli)
    return install_linux(cli)


def remove() -> Path:
    if sys.platform == "darwin":
        return remove_darwin()
    if os.name == "nt":
        return remove_windows()
    return remove_linux()
