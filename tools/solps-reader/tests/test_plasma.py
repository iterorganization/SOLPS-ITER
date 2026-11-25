"""The b2fplasma/b2fplasmf family reader: layout, twin, dims policy,
refusals, and the CLI/MCP wiring — on synthetic files only (tiny grids,
deterministic values, both encodings written from one model)."""

from __future__ import annotations

import struct
import zlib
from pathlib import Path

import numpy as np
import pytest

from solps_reader.plasma import (
    B2fplasmaFormatError,
    _sequence,
    read_b2fplasma,
)

NX, NY, NS, NSTRA = 2, 3, 2, 2
CURRENT = "03.000.010"
OLD = "01.001.005"

_GX, _GY = NX + 2, NY + 2


def _values(name: str, count: int, *, integer: bool = False) -> np.ndarray:
    """Deterministic per-record values (stable across runs/processes)."""
    rng = np.random.default_rng(zlib.crc32(name.encode()))
    if integer:
        return rng.integers(0, 9, size=count).astype(np.int32)
    return rng.uniform(-1.0, 1.0, size=count) * 1.0e19


def _resolve_shape(shape, nstra=NSTRA):
    dims = {"gx": _GX, "gy": _GY, "ns": NS, "ns1": NS + 1, "nstra": nstra}
    return tuple(dims[s] if isinstance(s, str) else s for s in shape)


def _write_binary(path: Path, *, version=CURRENT, nstra=NSTRA,
                  skip=()) -> dict[str, np.ndarray]:
    """Write a synthetic binary b2fplasma; returns the model by name."""
    model: dict[str, np.ndarray] = {}
    seq = _sequence(version)
    with open(path, "wb") as fh:
        def write_record(payload: bytes) -> None:
            fh.write(struct.pack("<i", len(payload)))
            fh.write(payload)
            fh.write(struct.pack("<i", len(payload)))

        write_record(b"VERSION" + version.encode() + b" "
                     + b"synth".ljust(32))
        for spec in seq:
            if spec.name in skip:
                assert spec.optional, f"cannot skip mandatory {spec.name}"
                continue
            if spec.name in ("sclstra", "sclrtio") and nstra == 0:
                continue
            shape = _resolve_shape(spec.shape, nstra)
            count = int(np.prod(shape)) if shape else 1
            integer = spec.name == "nstra"
            if integer:
                vals = np.array([nstra], dtype=np.int32)
            else:
                vals = _values(spec.name, count)
            model[spec.name] = vals
            typ = b"int     " if integer else b"real    "
            write_record(b"*cf:    " + typ + struct.pack("<i", count)
                         + spec.name.encode().ljust(32))
            if count:
                dtype = "<i4" if integer else "<f8"
                write_record(vals.astype(dtype).tobytes())
    return model


def _write_ascii(path: Path, *, version=CURRENT, nstra=NSTRA,
                 skip=()) -> None:
    """Write the formatted twin: same sequence, header lines + 5-per-line
    reals (any whitespace layout is legal — the parser is token-wise)."""
    with open(path, "w", encoding="ascii") as fh:
        fh.write(f"VERSION{version} synth\n")
        for spec in _sequence(version):
            if spec.name in skip:
                continue
            if spec.name in ("sclstra", "sclrtio") and nstra == 0:
                continue
            shape = _resolve_shape(spec.shape, nstra)
            count = int(np.prod(shape)) if shape else 1
            if spec.name == "nstra":
                vals = [nstra]
                typ = "int"
            else:
                vals = list(_values(spec.name, count))
                typ = "real"
            fh.write(f"*cf:    {typ:<8}{count:>12}    {spec.name:<32}\n")
            fmt = (lambda v: str(int(v))) if typ == "int" \
                else (lambda v: f"{v:.17E}")
            for i in range(0, len(vals), 5):
                fh.write(" " + " ".join(fmt(v) for v in vals[i:i + 5])
                         + "\n")


def _write_b2fstate(path: Path, *, nx=NX, ny=NY, ns=NS,
                    zamin=None) -> None:
    if zamin is None:
        zamin = (0.0, 1.0)
    zamin = tuple(list(zamin) + [zamin[-1]] * (ns - len(zamin)))
    """A minimal but well-formed b2fstate header the state reader accepts
    (VERSION line + the six header records)."""
    with open(path, "w", encoding="ascii") as fh:
        fh.write("VERSION03.000.010 synth\n")

        def rec(name, typ, vals):
            fh.write(f"*cf:    {typ:<8}{len(vals):>12}    {name:<32}\n")
            for i in range(0, len(vals), 6):
                fh.write(" " + " ".join(f"{v!r}" if typ == "int"
                                         else f"{float(v):.17E}"
                                         for v in vals[i:i + 6]) + "\n")

        rec("nx,ny,ns", "int", [nx, ny, ns])
        fh.write(f"*cf:    {'char':<8}{5:>12}    {'label':<32}\n")
        fh.write(" synth\n")
        rec("zamin", "real", list(zamin[:ns]))
        rec("zamax", "real", [1.0] * ns)
        rec("zn", "real", [1.0] * ns)
        rec("am", "real", [2.0] * ns)


@pytest.fixture
def run_dir(tmp_path: Path) -> Path:
    """A floor-independent synthetic run directory: b2fplasma (binary),
    its ASCII twin, and the sibling b2fstate the dims come from."""
    d = tmp_path / "run"
    d.mkdir()
    _write_b2fstate(d / "b2fstate")
    _write_binary(d / "b2fplasma")
    _write_ascii(d / "b2fplasmf")
    return d


# -- the record stream, both encodings --------------------------------------

def test_binary_reads_every_record_with_shapes(run_dir: Path):
    with read_b2fplasma(run_dir / "b2fplasma") as pl:
        assert pl.encoding == "binary"
        assert pl.version == CURRENT
        assert (pl.nx, pl.ny, pl.ns) == (NX, NY, NS)
        assert pl.nstra == NSTRA
        assert pl["te"].shape == (_GX, _GY)
        assert pl["na"].shape == (_GX, _GY, NS)
        assert pl["fna"].shape == (_GX, _GY, 2, NS)
        assert pl["csigin"].shape == (_GX, _GY, 2, NS, NS)
        assert pl["sclstra"].shape == (NS + 1, NSTRA)
        assert pl["nstra"].shape == ()
        assert int(pl["nstra"]) == NSTRA
        # optional records load when written (the omitted case has its
        # own test below)
        assert "qcb" in pl and "cell_width" in pl and "fht" in pl


def test_ascii_twin_reads_identically(run_dir: Path):
    """The formatted twin parses to the same arrays, and detection is by
    bytes, not name (each file answers under the other's name)."""
    bin_as_twin = run_dir / "renamed-twin"      # binary bytes, twin-ish name
    ascii_as_bin = run_dir / "renamed-binary"   # ascii bytes, binary name
    bin_as_twin.write_bytes((run_dir / "b2fplasma").read_bytes())
    ascii_as_bin.write_bytes((run_dir / "b2fplasmf").read_bytes())
    with read_b2fplasma(run_dir / "b2fplasma") as a, \
            read_b2fplasma(run_dir / "b2fplasmf") as b, \
            read_b2fplasma(bin_as_twin) as c, \
            read_b2fplasma(ascii_as_bin) as d:
        assert (a.encoding, b.encoding) == ("binary", "ascii")
        assert (c.encoding, d.encoding) == ("binary", "ascii")
        for name in a.keys():
            assert np.array_equal(a[name], b[name]), name


def test_values_round_trip_column_major(run_dir: Path):
    """Loaded arrays equal the written model under the Fortran layout:
    element (0, 0, ...) is the record's first value."""
    model = _write_binary(run_dir / "fresh-binary")
    with read_b2fplasma(run_dir / "fresh-binary") as pl:
        for name in ("te", "na", "fna", "csigin"):
            flat = pl[name].ravel(order="F")
            assert np.allclose(flat, model[name].astype(float)), name


# -- the version ladder ------------------------------------------------------

def test_old_version_omits_later_records(run_dir: Path):
    """An old-stamp file is the current sequence minus later records —
    the membership assertions pin the ladder itself."""
    old = run_dir / "old"
    old.mkdir()
    _write_b2fstate(old / "b2fstate")
    _write_binary(old / "b2fplasma", version=OLD)
    with read_b2fplasma(run_dir / "old" / "b2fplasma") as pl:
        assert pl.version == OLD
        # gates INCLUDE from their stamp on: at 01.001.005 the fhet
        # family (> 01.001.003) and rsamo family (> 01.001.003) ARE in
        for absent in ("b2stbc_sna",               # > 01.001.010
                       "fmo", "fna_32",            # >= 01.001.008
                       "csigin",                   # >= 01.001.007
                       "facdrift",                 # >= 01.001.012
                       "fht",                      # >= 03.000.007
                       "nstra", "sclstra"):        # >= 01.001.024 / 023
            assert absent not in pl, absent
        # the anomalous block IS in (read from > 01.001.001), and the
        # fhet family made it in at > 01.001.003
        assert "sig0" in pl and "vla0" in pl and "fhet" in pl and "rsamo" in pl
        assert "te" in pl and "smo" in pl and "b2stbr_sna" in pl
        assert pl.nstra is None


def test_optional_records_absent_when_omitted(run_dir: Path):
    _write_binary(run_dir / "opt-binary", skip=("qcb", "cell_width",
                                                "cell_height", "fht"))
    with read_b2fplasma(run_dir / "opt-binary") as pl:
        assert "qcb" not in pl and "fht" not in pl
        assert pl.expected - len(pl.records) == 4


# -- dims policy (the converter's own) ---------------------------------------

def test_dims_from_explicit_b2fstate(tmp_path: Path):
    d = tmp_path / "elsewhere"
    d.mkdir()
    _write_binary(d / "b2fplasma")
    (tmp_path / "state").mkdir()
    _write_b2fstate(tmp_path / "state" / "b2fstate")
    with read_b2fplasma(d / "b2fplasma",
                        b2fstate=tmp_path / "state" / "b2fstate") as pl:
        assert pl.dims_source.startswith("b2fstate")
        assert pl["te"].shape == (_GX, _GY)


def test_dims_explicit_triple(tmp_path: Path):
    d = tmp_path / "solo"
    d.mkdir()
    _write_binary(d / "b2fplasma")
    with read_b2fplasma(d / "b2fplasma", dims=f"{NX},{NY},{NS}") as pl:
        assert pl.dims_source == "explicit dims"
        assert pl.species_zamin is None


def test_missing_dims_refuses_naming_the_remedies(tmp_path: Path):
    d = tmp_path / "orphan"
    d.mkdir()
    _write_binary(d / "b2fplasma")
    with pytest.raises(B2fplasmaFormatError) as exc:
        read_b2fplasma(d / "b2fplasma")
    text = str(exc.value)
    assert "does not carry its own grid dims" in text
    assert "b2fstate" in text and "nx,ny,ns" in text


def test_wrong_dims_refuse_at_the_count_check(tmp_path: Path):
    d = tmp_path / "lying"
    d.mkdir()
    _write_binary(d / "b2fplasma")
    _write_b2fstate(d / "b2fstate", nx=NX, ny=NY, ns=NS + 3,
                    zamin=(0.0, 1.0, 1.0, 1.0, 1.0))
    with pytest.raises(B2fplasmaFormatError) as exc:
        read_b2fplasma(d / "b2fplasma")
    assert "declares" in str(exc.value) and "expected" in str(exc.value)


# -- dynamic nstra -----------------------------------------------------------

def test_nstra_zero_omits_the_scaling_pair(tmp_path: Path):
    d = tmp_path / "zero"
    d.mkdir()
    _write_b2fstate(d / "b2fstate")
    _write_binary(d / "b2fplasma", nstra=0)
    with read_b2fplasma(d / "b2fplasma") as pl:
        assert int(pl["nstra"]) == 0
        assert "sclstra" not in pl and "sclrtio" not in pl
        assert "te" in pl


# -- honest refusals ---------------------------------------------------------

def test_not_a_plasma_file_refuses(run_dir: Path):
    fake = run_dir / "b2fstate"
    with pytest.raises(B2fplasmaFormatError) as exc:
        read_b2fplasma(fake)
    assert "b2fstate" in str(exc.value)  # the hint names what it looks like


def test_truncated_file_refuses(tmp_path: Path):
    d = tmp_path / "trunc"
    d.mkdir()
    _write_b2fstate(d / "b2fstate")
    _write_binary(d / "b2fplasma")
    raw = (d / "b2fplasma").read_bytes()
    (d / "b2fplasma").write_bytes(raw[: len(raw) // 2])
    with pytest.raises(B2fplasmaFormatError) as exc:
        read_b2fplasma(d / "b2fplasma")
    text = str(exc.value)
    assert "ended before required record" in text or "truncated" in text


def test_marker_corruption_refuses(tmp_path: Path):
    d = tmp_path / "corrupt"
    d.mkdir()
    _write_b2fstate(d / "b2fstate")
    _write_binary(d / "b2fplasma")
    raw = bytearray((d / "b2fplasma").read_bytes())
    # VERSION record spans bytes 0..58 (4+50+4); the first array header
    # record then runs 58..118 -- its trailing marker is at 114:118
    raw[114:118] = struct.pack("<i", 51)
    (d / "b2fplasma").write_bytes(bytes(raw))
    with pytest.raises(B2fplasmaFormatError) as exc:
        read_b2fplasma(d / "b2fplasma")
    assert "disagree" in str(exc.value) or "truncated" in str(exc.value)


def test_big_endian_markers_refuse_by_name(tmp_path: Path):
    d = tmp_path / "be"
    d.mkdir()
    _write_b2fstate(d / "b2fstate")
    payload = b"*cf:    real    " + struct.pack("<i", 4) + b"bb".ljust(32)
    with open(d / "b2fplasma", "wb") as fh:
        n = len(payload)
        fh.write(struct.pack(">i", n))     # big-endian marker
        fh.write(payload)
        fh.write(struct.pack(">i", n))
    with pytest.raises(B2fplasmaFormatError) as exc:
        read_b2fplasma(d / "b2fplasma")
    assert "big-endian" in str(exc.value)


def test_text_garbage_refuses(tmp_path: Path):
    d = tmp_path / "garbage"
    d.mkdir()
    _write_b2fstate(d / "b2fstate")
    (d / "b2fplasma").write_text("hello plasma\nnothing here\n")
    with pytest.raises(B2fplasmaFormatError) as exc:
        read_b2fplasma(d / "b2fplasma")
    assert "expected record" in str(exc.value)


# -- CLI wiring (floor-gated like every analysis command) --------------------

def _floored(monkeypatch, checkout_factory) -> None:
    root = checkout_factory()
    from solps_reader import floor
    monkeypatch.setenv(floor.REPOS_ENV, str(root))


def test_cli_summary_and_field(run_dir: Path, checkout_factory,
                               monkeypatch, capsys):
    _floored(monkeypatch, checkout_factory)
    from solps_reader import cli
    assert cli.main(["plasma", "summary", str(run_dir / "b2fplasma")]) == 0
    out = capsys.readouterr().out
    assert f"nx={NX} ny={NY} (interior) -> {_GX}x{_GY} guard cells" in out
    assert "dims from sibling b2fstate" in out
    assert CURRENT in out and "binary" in out
    assert "core fields" in out and " te " in out
    assert "blocks:" in out and "neutral source scaling" in out
    assert cli.main(["plasma", "field",
                     str(run_dir / "b2fplasmf"), "te"]) == 0
    out = capsys.readouterr().out
    assert "te: shape" in out and "first values" in out


def test_cli_field_unknown_name_exits_two(run_dir: Path, checkout_factory,
                                          monkeypatch, capsys):
    _floored(monkeypatch, checkout_factory)
    from solps_reader import cli
    with pytest.raises(SystemExit) as exc:
        cli.main(["plasma", "field", str(run_dir / "b2fplasma"), "nosuch"])
    assert exc.value.code == 2
    assert "available" in capsys.readouterr().err


def test_cli_export_writes_every_record(run_dir: Path, checkout_factory,
                                        monkeypatch, capsys, tmp_path):
    _floored(monkeypatch, checkout_factory)
    from solps_reader import cli
    out_npz = tmp_path / "exported.npz"
    assert cli.main(["plasma", "export", str(run_dir / "b2fplasma"),
                     "-o", str(out_npz)]) == 0
    assert "records" in capsys.readouterr().out
    z = np.load(out_npz)
    assert len(z.files) == len(_sequence(CURRENT))
    assert z["te"].shape == (_GX, _GY)


def test_cli_analysis_still_gated_without_floor(run_dir, monkeypatch,
                                                tmp_path):
    monkeypatch.chdir(tmp_path)
    from solps_reader import floor
    monkeypatch.delenv(floor.REPOS_ENV, raising=False)
    monkeypatch.setattr(Path, "home", lambda: tmp_path / "nohome")
    from solps_reader import cli
    with pytest.raises(SystemExit) as exc:
        cli.main(["plasma", "summary", str(run_dir / "b2fplasma")])
    assert "no SOLPS-ITER checkout found" in str(exc.value)


# -- MCP wiring --------------------------------------------------------------

def test_mcp_plasma_tools(run_dir: Path):
    from solps_reader import mcp
    need = mcp.plasma_summary(path="")
    assert "pass `path` explicitly" in need
    answer = mcp.plasma_summary(path=str(run_dir / "b2fplasma"))
    assert "guard cells" in answer and "core fields" in answer
    field = mcp.plasma_field(path=str(run_dir / "b2fplasma"), field="na")
    assert "na: shape" in field and "first values" in field
    missing = mcp.plasma_field(path=str(run_dir / "b2fplasma"),
                               field="nosuch")
    assert "ERROR" in missing and "available" in missing
    absent = mcp.plasma_summary(path="/no/such/file")
    assert "ERROR" in absent


def test_scan_glossary_knows_the_family():
    from solps_reader import mcp
    assert "read natively" in mcp.FILE_GLOSSARY["b2fplasma"]
    assert "not yet verified" not in mcp.FILE_GLOSSARY["b2fplasma"]
    assert "b2fplasmf" in mcp.FILE_GLOSSARY
