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

def _fake_launch(monkeypatch, tmp_path, *, up, static, status=None):
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
