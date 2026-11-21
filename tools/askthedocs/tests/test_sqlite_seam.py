"""The SQLite binding seam: stdlib when its SQLite carries FTS5,
else the pip-provided pysqlite3 wheel, else the named-remedy
refusal.  The cluster shape this guards: a Python built against an
SQLite without the extension and a user with no administrator
rights (the field report; the wheel is an automatic dependency on
Linux x86_64 exactly for that case).
"""

from __future__ import annotations

import importlib
import sqlite3 as stdlib_sqlite3
import sys
import types
from pathlib import Path

import pytest

from askthedocs import _sqlite
from askthedocs import setup as atd_setup


def test_stdlib_wins_when_it_carries_fts5() -> None:
    """On a normal Python (FTS5 in the stdlib SQLite) the seam binds
    the stdlib module and the flag reads True: no fallback, no
    behavior change anywhere."""
    assert _sqlite.sqlite3 is stdlib_sqlite3
    assert _sqlite.has_fts5 is True


def _break_stdlib_fts5(monkeypatch) -> None:
    """Make the stdlib binding fail the FTS5 probe the way a cluster
    Python does: connect works, the FTS5 virtual-table creation
    raises.  The seam's own (reloaded, unpatched) probe then reads
    the stdlib as FTS5-less."""
    def broken_connect(*_a, **_k):
        class _Conn:
            def execute(self, sql):
                if "fts5" in sql:
                    raise stdlib_sqlite3.OperationalError(
                        "no such module: fts5")
                return None

            def close(self):
                pass
        return _Conn()

    monkeypatch.setattr(stdlib_sqlite3, "connect", broken_connect)


def _fake_pysqlite3() -> types.ModuleType:
    fake = types.ModuleType("pysqlite3")

    def connect(*_a, **_k):
        class _Conn:
            def execute(self, _sql):
                return None

            def close(self):
                pass
        return _Conn()

    fake.connect = connect
    return fake


def test_fallback_binds_pysqlite3_when_stdlib_lacks_fts5(
        monkeypatch) -> None:
    """The cluster shape: the stdlib probe fails, the pip-provided
    wheel is importable, and the seam binds IT (the binding decision
    happens at import time, so the test reloads the seam module over
    a poisoned stdlib)."""
    _break_stdlib_fts5(monkeypatch)
    fake = _fake_pysqlite3()
    monkeypatch.setitem(sys.modules, "pysqlite3", fake)
    try:
        mod = importlib.reload(_sqlite)
        assert mod.sqlite3 is fake
        assert mod.has_fts5 is True      # the wheel's probe passes
    finally:
        monkeypatch.undo()
        importlib.reload(_sqlite)        # restore the real binding
    assert _sqlite.sqlite3 is stdlib_sqlite3
    assert _sqlite.has_fts5 is True


def test_no_fts5_anywhere_stays_on_stdlib(monkeypatch) -> None:
    """Without the wheel the seam stays on the stdlib module (honest
    exception types) and the flag reads False; the refusals then
    carry the remedy."""
    _break_stdlib_fts5(monkeypatch)
    monkeypatch.setitem(sys.modules, "pysqlite3", None)  # ImportError
    try:
        mod = importlib.reload(_sqlite)
        assert mod.sqlite3 is stdlib_sqlite3
        assert mod.has_fts5 is False
    finally:
        monkeypatch.undo()
        importlib.reload(_sqlite)
    assert _sqlite.has_fts5 is True


def test_setup_refusal_names_each_platforms_remedy(
        monkeypatch, capsys) -> None:
    """The setup gate refuses before any work when no binding carries
    FTS5; the platform truth comes first: the wheel installs
    automatically on Linux x86_64, and the elsewhere remedy is a
    Python built with FTS5."""
    monkeypatch.setattr(_sqlite, "has_fts5", False)
    with pytest.raises(SystemExit) as ei:
        atd_setup._require_fts5()
    msg = str(ei.value)
    assert "lacks the FTS5" in msg
    assert "administrator" in msg
    assert ("on Linux x86_64 the wheel pysqlite3-binary installs "
            "automatically with askthedocs") in msg
    assert "Elsewhere use a Python built with FTS5" in msg
    assert "standard python.org installers have it" in msg
    assert "Nothing was built" in msg
    assert msg.index("Linux x86_64") < msg.index("Elsewhere")
