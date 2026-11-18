"""The one-click launch arc: web-client resolution and the
no-browser-trip guard. Everything here is synthetic except the
packaged client itself, which the byte-identity test pins against
the repo's certified build."""

import os
from pathlib import Path

import askthedocs
from askthedocs import launch


# ------------------------------------------------- web-client resolution

def test_static_resolves_to_the_packaged_client(tmp_path, monkeypatch):
    # from an empty directory, no env, no checkout beside: the
    # package's own copy answers (the pip install carries it)
    monkeypatch.delenv("ASKTHEDOCS_STATIC", raising=False)
    monkeypatch.chdir(tmp_path)
    static = launch.resolve_static()
    assert static is not None
    assert (static / "index.html").is_file()
    assert static.parent == Path(askthedocs.__file__).resolve().parent


def test_static_env_outranks_everything(tmp_path, monkeypatch):
    custom = tmp_path / "custom-client"
    custom.mkdir()
    (custom / "index.html").write_text("custom", encoding="utf-8")
    monkeypatch.setenv("ASKTHEDOCS_STATIC", str(custom))
    monkeypatch.chdir(tmp_path)
    assert launch.resolve_static() == custom


def test_static_checkout_beside_outranks_the_packaged_copy(
        tmp_path, monkeypatch):
    # a source checkout's fresh build wins over the packaged copy,
    # so client development needs no reinstall
    beside = tmp_path / "askthedocs" / "web" / "build"
    beside.mkdir(parents=True)
    (beside / "index.html").write_text("fresh", encoding="utf-8")
    monkeypatch.delenv("ASKTHEDOCS_STATIC", raising=False)
    monkeypatch.chdir(tmp_path)
    assert launch.resolve_static() == beside


def test_packaged_client_matches_the_certified_build():
    # the vendored copy is the certified build, file for file; a
    # client rebuild that is not re-vendored (or an install that
    # lost the data) fails here, never silently
    repo_build = Path(__file__).resolve().parents[1] / "web" / "build"
    packaged = Path(askthedocs.__file__).resolve().parent / "web"
    files = sorted(p.relative_to(repo_build) for p in repo_build.rglob("*")
                   if p.is_file())
    assert files, "the certified build is absent from the repo tree"
    for rel in files:
        assert (packaged / rel).is_file(), f"vendored copy lost {rel}"
        assert (repo_build / rel).read_bytes() == \
            (packaged / rel).read_bytes(), f"vendored copy drifts: {rel}"


# --------------------------------------------- the no-browser-trip guard

def _fake_launch(monkeypatch, tmp_path, *, up, static, status=None,
                 probe=(200, "")):
    opened = []
    monkeypatch.setattr(launch, "open_browser",
                        lambda url: opened.append(url))
    monkeypatch.setattr(launch, "spawn_service",
                        lambda port, host="127.0.0.1":
                        tmp_path / "service.log")
    monkeypatch.setattr(launch, "wait_port",
                        lambda port, host="127.0.0.1": True)
    monkeypatch.setattr(launch, "port_answers",
                        lambda port, host="127.0.0.1": up)
    monkeypatch.setattr(launch, "_http_status",
                        lambda url, timeout=3.0: status)
    monkeypatch.setattr(launch, "_probe_search",
                        lambda url, timeout=3.0: probe)
    monkeypatch.setattr(launch, "resolve_static", lambda: static)
    return opened


def test_open_with_client_opens_the_browser(tmp_path, monkeypatch,
                                            capsys):
    opened = _fake_launch(monkeypatch, tmp_path, up=False,
                          static=tmp_path)
    assert launch.open_cmd(8990) == 0
    assert opened == ["http://127.0.0.1:8990/"]
    assert "open: http://127.0.0.1:8990/" in capsys.readouterr().out


def test_open_without_client_never_opens_the_browser(tmp_path,
                                                     monkeypatch,
                                                     capsys):
    opened = _fake_launch(monkeypatch, tmp_path, up=False, static=None)
    assert launch.open_cmd(8991) == 0
    assert opened == []
    out = capsys.readouterr().out
    assert "API only" in out
    assert "no page to open" in out


def test_open_api_only_service_running_says_restart(tmp_path,
                                                    monkeypatch,
                                                    capsys):
    # the owner's exact case: a service already up, no page mounted -
    # plain open names it and hands over the convergence verb
    opened = _fake_launch(monkeypatch, tmp_path, up=True, static=None,
                          status=404)
    assert launch.open_cmd(8992) == 0
    assert opened == []
    out = capsys.readouterr().out
    assert "API-only" in out
    assert "open --restart" in out


def test_open_page_service_running_opens_browser(tmp_path, monkeypatch,
                                                 capsys):
    opened = _fake_launch(monkeypatch, tmp_path, up=True,
                          static=None, status=200)
    assert launch.open_cmd(8993) == 0
    assert opened == ["http://127.0.0.1:8993/"]


# ------------------------------------- a service that cannot search

#: the refusal a store-blind service answers with (its own words; the
#: web client's error card swallows them, the terminal must not)
BLIND_REASON = ("no askthedocs index on this machine yet:\n"
                "1. $ASKTHEDOCS_DB environment variable\n"
                "2. ./askthedocs-db/askthedocs.db beside the launch\n"
                "3. the index home\nfix: run `askthedocs setup`")


def test_open_names_a_service_that_cannot_search(tmp_path, monkeypatch,
                                                 capsys):
    # a running service whose index lookup sees nothing: its 503
    # carries the full named reason - print it, hand over the restart
    # verb, never open a browser onto the failing page
    opened = _fake_launch(monkeypatch, tmp_path, up=True, static=None,
                          status=200, probe=(503, BLIND_REASON))
    assert launch.open_cmd(8994) == 0
    assert opened == []
    out = capsys.readouterr().out
    assert "running but cannot search" in out
    for line in BLIND_REASON.splitlines():
        assert line in out
    assert "open --restart" in out


def test_open_probe_silent_still_opens_the_browser(tmp_path, monkeypatch,
                                                   capsys):
    # nothing is concluded from silence: an unanswered probe keeps
    # the old behavior (open the page; the page shows its own state)
    opened = _fake_launch(monkeypatch, tmp_path, up=True, static=None,
                          status=200, probe=None)
    assert launch.open_cmd(8995) == 0
    assert opened == ["http://127.0.0.1:8995/"]


def test_open_names_a_fresh_service_started_where_no_index_is_visible(
        tmp_path, monkeypatch, capsys):
    # the service was just started from THIS shell and still sees no
    # index: the remedy names the export, not only the restart
    opened = _fake_launch(monkeypatch, tmp_path, up=False,
                          static=tmp_path, probe=(503, BLIND_REASON))
    assert launch.open_cmd(8996) == 0
    assert opened == []
    out = capsys.readouterr().out
    assert "running but cannot search" in out
    assert "THIS shell" in out
    assert "open --restart" in out


def test_the_browser_launch_shares_no_terminal_streams(monkeypatch):
    # on a headless cluster the browser complains for minutes about a
    # missing system bus; none of it is ours to print - the child
    # gets the null streams on every platform that spawns one
    calls = []

    def fake_run(cmd, **kwargs):
        calls.append((cmd, kwargs))

    monkeypatch.setattr(launch.subprocess, "run", fake_run)
    launch.open_browser("http://127.0.0.1:8997/")
    assert len(calls) == 1
    cmd, kwargs = calls[0]
    assert kwargs.get("stdout") is launch.subprocess.DEVNULL
    assert kwargs.get("stderr") is launch.subprocess.DEVNULL
    assert not kwargs.get("check", False)


# ------------------------------------------------------ icon env baking

def test_baked_env_captures_a_redirected_home(tmp_path, monkeypatch):
    # `setup --home` without an export: the icon must still find the
    # index it built, so the live home is captured beside the plain
    # env; an explicit export always wins; os.environ is read, never
    # mutated; no redirect bakes nothing
    from askthedocs import locate, shortcut
    monkeypatch.setenv("HOME", str(tmp_path / "home"))
    scratch = tmp_path / "scratch" / "atd"
    locate.set_index_home(scratch)
    values = shortcut._baked_values()
    assert values[locate.HOME_ENV] == str(scratch)
    assert locate.HOME_ENV not in os.environ      # read, never mutated
    assert (f"export {locate.HOME_ENV}='{scratch}'"
            in shortcut._env_lines("sh"))         # the writer emits it
    exported = tmp_path / "exported"
    monkeypatch.setenv(locate.HOME_ENV, str(exported))
    assert shortcut._baked_values()[locate.HOME_ENV] == str(exported)
    locate.set_index_home(None)
    monkeypatch.delenv(locate.HOME_ENV, raising=False)
    assert locate.HOME_ENV not in shortcut._baked_values()
