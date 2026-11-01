# SOLPS-ITER tooling: run analysis and documentation search

This folder delivers two self-contained packages and one data
artifact from the SOLPS-ITER tooling effort, by Alfonso Sacco. Each
archive carries its own README with full install and usage
instructions; this page is the orientation.

## What is here

| File | What it is |
|------|------------|
| `solps-reader-1.2.0.tar.gz` | **Run analysis.** Reads the four families of SOLPS-ITER output files (`fort.44`, `fort.46`, NetCDF-3 `b2*.nc`, `b2fstate`/`b2fgmtry`) with a CLI and a Python API, verified byte-level against real ITER data. Includes a twelve-tool MCP server for AI-assisted analysis, and the **run catalog**: a static, browsable site recording, for each public example run, which code commit produced it, whether it converged, its wall and target power loads, and the switches its effective input deck sets. Requires numpy and matplotlib only. |
| `askthedocs-1.1.1.tar.gz` | **Documentation search.** One ranked search over the SOLPS-ITER manuals, the dated changelog, the tutorials, the full `b2mn.dat` switch inventory (892 switches), and the B2.5 + EIRENE Fortran source indexed by procedure. Every answer carries its citation, with a one-click deep link from any hit to the exact passage. Serves a local web app, a CLI, and MCP tools from one install. |
| `askthedocs-db-1.1.0.tar.gz` | **The data artifact for askthedocs**: the pinned search index (48,921 chunks across 158 sources). Install it together with the askthedocs package: one code archive, one data archive. |

## Quick start

Both packages install the same way (Python ≥ 3.10, a virtual
environment, one `pip install` each; no other prerequisites):

```sh
python3 -m venv .venv

# run analysis + the run catalog site
.venv/bin/pip install solps-reader-1.2.0.tar.gz
.venv/bin/solps-reader --version
# then open  <unpacked tree>/catalog/out/site/index.html  in a browser

# documentation search (code + data)
tar xzf askthedocs-db-1.1.0.tar.gz
.venv/bin/pip install askthedocs-1.1.1.tar.gz
.venv/bin/askthedocs search detachment
```

The solps-reader catalog site needs no server and no network: it is
static HTML that works offline. The askthedocs web app starts with a
single command (`askthedocs open`) and can be pinned to your
launcher with one more (`askthedocs shortcut`); both packages also
run as MCP servers for AI-assisted workflows, with the wiring
recipes in their READMEs.

## License

All three artifacts ship under the EUPL-1.1, Copyright 2026
Alfonso Sacco. Font and runtime notices travel inside the archives
they apply to.

## Integrity

| File | md5 |
|------|-----|
| `solps-reader-1.2.0.tar.gz` | `45a22e1b04daedf4b47b7746ee9ab83a` |
| `askthedocs-1.1.1.tar.gz` | `fbf2ce94890a0de8b57d0fb7ca7d987a` |
| `askthedocs-db-1.1.0.tar.gz` | `ed729587306bba9a8e99b2fdda206de8` |
