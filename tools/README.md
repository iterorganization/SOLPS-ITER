# SOLPS-ITER tooling: run analysis and documentation search

This folder delivers two self-contained packages from the SOLPS-ITER tooling effort, maintained by Alfonso Sacco. Each folder carries a short landing README plus an illustrated manual; this page is the orientation.

## What is here

| Folder | What it is |
|--------|------------|
| `solps-reader/` | **Run analysis.** Reads the five families of SOLPS-ITER output files (`fort.44`, `fort.46`, NetCDF-3 `b2*.nc`, `b2fstate`/`b2fgmtry`, and the full-solution `b2fplasma`/`b2fplasmf`) with a CLI and a Python API, verified byte-level against real ITER data. Includes a fourteen-tool MCP server for AI-assisted analysis, and the **run catalog**: a static, browsable site recording, for each public example run, which code commit produced it, whether it converged, its wall and target power loads, and the switches its effective input deck sets. It also catalogs your own runs, from as many folders as you work with (`catalog add` each once; new groups sit last and `catalog move` repositions them, display order never auto-sorts; then build; `catalog compare` decks any two runs against each other, across folders included). A short README lands the quick start; `solps-reader-Manual.md` is the deep reference. |
| `askthedocs/` | **Documentation search.** One ranked search over the SOLPS-ITER manuals, the dated changelog, the tutorials, the full `b2mn.dat` switch inventory, and the B2.5 + EIRENE Fortran source indexed by procedure. Two optional documentation repositories, SOLPS-GUI (which joins through its documentation) and SOLPS-Tutorials (the tutorials above), are indexed when cloned beside the SOLPS-ITER checkout; absent, they are named at build time and add nothing. Every answer carries its citation, with a one-click deep link from any hit to the exact passage. Serves a local web app, a CLI, and MCP tools from one install. Its docs are split the same way: a short README plus `askthedocs-Manual.md`. |

Both packages are plain source: nothing here is pre-built beyond each package's certified web artifacts, no database or tarball ships, and the documentation index is built locally, once, on the machine that uses it.

## Quick start

The prerequisite is the repository this folder lives in: a clone of SOLPS-ITER with its submodules initialized (`adas` excepted; it is pinned non-public). Both packages install the same way (Python >= 3.10, a virtual environment, one `pip install` each), from the clone root:

```sh
python3 -m venv .venv

# run analysis + the run catalog site
.venv/bin/pip install tools/solps-reader
.venv/bin/solps-reader setup          # verifies the SOLPS-ITER checkout, 5 seconds
# then open  tools/solps-reader/catalog/out/site/index.html  in a browser

# the same site over your own runs: as many folders as you work
# with (an archive folder and a current folder, or more; display
# order = the order you add them, example runs always last). The
# build commands launch from the package directory: its catalog-tree
# ladder resolves exactly there (from anywhere else, cd in; or pass
# --catalog / set $SOLPS_READER_CATALOG):
cd tools/solps-reader
../../.venv/bin/solps-reader catalog add /path/to/archive
../../.venv/bin/solps-reader catalog add /path/to/current
../../.venv/bin/solps-reader catalog move current 1   # display order is yours
../../.venv/bin/solps-reader catalog build
../../.venv/bin/solps-reader catalog open       # your site, else the shipped pages
../../.venv/bin/solps-reader catalog compare group-a/FAM/run group-b/FAM/run
cd ../..

# documentation search (the index builds from the same clone, once)
.venv/bin/pip install tools/askthedocs
.venv/bin/askthedocs setup            # builds the index, at most 6 minutes
.venv/bin/askthedocs open             # the web version
```

The catalog site needs no server and no network: it is static HTML that works offline. The askthedocs web app starts with a single command and its launcher icon is installed by `setup`; both packages also run as MCP servers for AI-assisted workflows, with the wiring recipes in their READMEs.

## License

Both packages ship under the EUPL-1.1, Copyright 2026 Alfonso Sacco. Font and runtime notices travel inside the folders they apply to.
