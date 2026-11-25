"""The SQLite binding this package uses, chosen once at import.

The stdlib module when its SQLite carries the FTS5 extension; else
the pip-provided ``pysqlite3`` wheel (a complete modern SQLite with
FTS5 included) when it is importable.  Why a fallback exists at all:
FTS5 is a compile-time option of SQLite, so some cluster Pythons are
built against an SQLite without it, and installing a different
Python needs an administrator.  The wheel needs none: it lands in
the virtual environment like any package.  The package depends on it
automatically on Linux x86_64; elsewhere the validation layers
refuse with the remedy named.
"""
from __future__ import annotations

import sqlite3 as _stdlib


def _has_fts5(mod) -> bool:
    """True when *mod*'s SQLite can create an FTS5 virtual table."""
    try:
        conn = mod.connect(":memory:")
        try:
            conn.execute("CREATE VIRTUAL TABLE probe USING fts5(x)")
        finally:
            conn.close()
        return True
    except Exception:
        return False


if _has_fts5(_stdlib):
    sqlite3 = _stdlib
else:
    try:
        import pysqlite3 as sqlite3  # type: ignore[no-redef]
    except ImportError:
        # nothing salvageable: stay on the stdlib so the exception
        # types stay honest; the setup gate and the store validation
        # refuse with the named remedy instead
        sqlite3 = _stdlib

#: whether the ACTIVE binding carries FTS5 (drives refusal wording)
has_fts5 = _has_fts5(sqlite3)
