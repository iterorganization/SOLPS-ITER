# COVERAGE: what happens to every file in a run folder

One row per file family: **consumed by** (which tool reads it) →
**derived into** (what is computed from it) → **displayed** (which
page and section) → **or omitted, with the reason**.  Every file
name observed in the public example corpus matches exactly one
rule below; the test suite enforces this mechanically
(`tests/test_catalog_coverage.py` walks the corpus and fails on any
file the map does not rule on).  If a future run folder grows a new
kind of file, the suite fails until this map rules on it; nothing
can look like a miss by omission.

Two consumption tiers:

- **catalog**: the catalog builders turn it into page content;
- **reader**: the SOLPS-Reader CLI / MCP tools read it on demand
  (14 tools; the catalog is one face of the same package).

Backup/iterate variants (``name.i``, ``name_1``..``name_5``,
``name.<date>``, ``name.<version>``) follow their base file's rule
(the last complete record is the catalog's subject; iterates are
provenance).  `.DS_Store` and `*.md5` sidecars are machine/junk and
skipped everywhere (the manifest's own stability rule).

## The solver's state outputs

| File | Consumed by | Derived into | Displayed |
|---|---|---|---|
| `b2fstate` | reader (`state`), catalog (diff decks) | manifest linkage; the A/B field-diff decks (family pairs + recorded `catalog compare` pairs) | Comparison pages: per-field figures + `diff_summary.txt` verbatim |
| `b2fplasma` (+ ASCII twin `b2fplasmf`) | reader (`plasma`) | on-demand summaries/fields/exports | not a catalog surface: 191 binary records are a working session's material, not a page; one CLI/MCP call answers any slice |
| `b2fmovie` | — | — | omitted: machine-scale movie output (up to GBs per run); no derived view exists and none is planned; the raw file stays in the run folder |
| `b2fparam`, `b2frates`, `b2fpardf`, `b2ftrack`, `b2ftrace` | — | — | omitted: solver bookkeeping streams; their content is provenance already carried by the file inventory + code-version line |
| `b2fgmtry` | reader (`nc`-family geometry reads), catalog (deck inventory) | grid dimensions; geometry file entry | Run page: grid column everywhere + Input deck's geometry line; the mesh itself is VISUALIZED in the wall-load figures |
| `b2batch.nc`, `b2tallies.nc` | reader (`nc`) | on-demand dumps/plots | not a catalog surface; same tier as `b2fplasma`: ask the reader |

## Time histories and convergence

| File | Consumed by | Derived into | Displayed |
|---|---|---|---|
| `b2time.nc` | reader (`nc`), catalog (manifests) | the convergence verdict + one sparkline per active monitor | Run page: verdict badge + inline sparkline strips (the FULL-trace PNGs were retired (sparklines carry the settled verdict); raw traces remain one `nc dump` away) |
| `<field>3d<side>[P][<species>].last10` (`te3da.last10`, `fn3drP1.last10`, …) | — | — | omitted: the last-10-iteration text tails the solver writes beside `b2time.nc`; their information is the same convergence the verdict + sparklines already carry, from the authoritative NetCDF source |
| `vx3d*/vy3d*/vs3d*.last10` (drift monitors) | — | — | same rule as above (drift-flavored tails) |
| `.status`, `.current_status`, `.status.history`, `run.log*` | — | — | omitted: run bookkeeping; the catalog's unit is the finished run |

## EIRENE output and plots

| File | Consumed by | Derived into | Displayed |
|---|---|---|---|
| `fort.44` (+ `.i`) | reader (`ft44`), catalog (manifests) | grid/species/code-version; the wall-load tallies; the wall-gate geometry check | Run page: header block + Wall loads section (figure on gate pass, the recorded cause verbatim otherwise) |
| `fort.46` | reader (`ft46`), catalog (manifests) | provenance (version, git hash, triangle count, species) | Run page: provenance line |
| `fort.30` | catalog (wall gate, via the family deck) | the mesh the wall areas are verified against | visualized inside every wall-load figure; named in the gate's recorded outcome |
| `fort.10/.11/.31/.33/.34/.35` | — | — | omitted: EIRENE's raw atomic/divertor data blocks; specialist input to physics kernels, not page content |
| `*.trc` (+ `.i`): `sources`, `residuals`, `integral`, `intshrt`, `bln*`, `sepdata`, `user*`, `test*` | — | — | omitted: EIRENE trace streams; energy/particle balances exist as derived views on request; none requested so far (a named work item if IO asks) |
| `*.ps`: `residuals`, `energy_balance`, `particle_balance`, `b2time2d_*`, `resall_*`, `rqahereg` | — | — | omitted: the solver's own PostScript snapshots, superseded by the catalog's derived figures |
| `input.dat`, `*.eir`, `eirene*.json`, `user_data.input` (EIRENE inputs) | — | — | omitted: raw input content (the raw-content doctrine); presence + md5 ride the inventory |
| `wlld*.dat`, `wlly*.dat` (wall topology definitions) | catalog, indirectly (they define the wall the fort.44 tallies attribute to) | the wall-load section's structure follows them | omitted as raw files: their RESULT is the wall-load table + figures |
| `fp_tg*`, `ld_tg*`, `peak_power*` (EIRENE target/flux outputs) | — | — | omitted: derived EIRENE output streams; a named work item if anyone asks for target-load views |

## The input deck (family `baserun/` and run-level copies)

| File | Consumed by | Derived into | Displayed |
|---|---|---|---|
| `baserun/` (the folder itself) | catalog (deck manifest) | full file inventory, md5-pinned | Run page: Input deck section; one deck serves every member run of its family (a deck is defined by marker ABSENCE: it is not a run, so it has no page of its own) |
| `b2mn.dat` (effective: the run's own, else the family baserun's) | catalog (switchsets) | the effective switch set, joined to the documented defaults (`same`/`differs`/`no-default`/`unknown`); lines whose quoted name starts with `#` are recorded as commented out, never as set | Run page Switches table + the Switch index page (both directions) |
| `b2.*.parameters` (boundary, neutrals, transport, numerics, user, wall_save, + templates) | — | — | omitted: raw input content (the doctrine above); inventory + md5 only |
| `b2ah/ar/ai/ag.dat` + `.prt`, `b2mn.prt`, `b2y?.dat`, `b2md.dat`, `mesh.extra`, `NREG`, `SOLPS_FLUIDS` | — | — | omitted: deck machinery and switch echoes; the effective switches already render as the joined table |
| grid/triangulation set: `gridue`, `grid*.sno`, `*.trg/.str/.dg/.dgo/.geo/.ogr/.equ`, `tria.*`, `triang.hed/.eir`, `triageom.*`, `triangles.dat`, `template.*`, `contour*`, `carre.*`, `iterm.carre.128`, `Baseline2008*`, `F57*`, `<shot>.*`, `shadow.dat`, `sput_trg.sum` | — | — | omitted: grid-generation inputs and DivGeo/Carre outputs; the RESULTING mesh is what physics reads (via `fort.30`/`b2fgmtry`, both ruled above) |
| `plasmastate.NNNN` (snapshot series) | — | — | omitted: coupled-code state snapshots (40 in one corpus run); no consumer asked; a named work item if coupled-run users appear |
| `structure.dat`, `rzpsi.dat`, `frontier.dat`, `btor.dat`, `.na_feedback` | — | — | omitted: auxiliary machine inputs; inventory + md5 only |
| scripts & docs: `Makefile`, `*.py`, `*.scr`, `README.md`, `COMMENTS`, `ACKNOWLEDGEMENT`, `Instructions.*` | — | — | omitted: family tooling and prose; they live in the repository, not a run catalog |

## Legacy compatibility names

Older SOLPS versions and shared databases carry optional
compatibility names beside the current ones.  None of them is
consumed by either tier; presence and absence are both silent
(`b2.log`/`b2.log.gz` are symlinks to `run.log`/`run.log.gz`; either
name satisfies the solver family — the same content under a legacy
name changes nothing here).

| File | Consumed by | Derived into | Displayed |
|---|---|---|---|
| `b2.log`, `b2.log.gz` (symlinks to `run.log`/`run.log.gz`) | — | — | omitted: `legacy-log`; the content follows the current name's rule, the link itself is provenance |
| `fort.21`, `fort.22` | — | — | omitted: `legacy-input`; superseded transport inputs kept for backward compatibility; inventory + md5 only |
| `H2VIBR`, `AMMONX`, `HYDHEL`, `METHANE`, `SPUTER` | — | — | omitted: `legacy-input`; optional EIRENE namelist files the family may link in; inventory + md5 only |

## Machine-readable rules

The suite test reads THIS block (single source; the table above is
its prose).

Each rule name maps to the prose above: `b2time`, `b2fstate`,
`b2fplasma`, `b2fgmtry`, `fort44`, `fort46`, `fort30`, `b2mn`,
`nc-ondemand` are CONSUMED (catalog and/or reader: see the
tables); `monitor-tail`, `trace`, `ps-snapshot`, `fort-block`,
`stream`, `bookkeeping`, `deck-machinery`, `parameters`,
`grid-input`, `plasmastate`, `aux-input`, `family-tooling`,
`eirene-input`, `wall-def`, `eirene-derived`, `legacy-log`,
`legacy-input` are omitted-with-reason;
`iterate`, `sidecar`, `junk` follow the base-file / skip rules.

```json coverage-rules
[
  {"pattern": "*.DS_Store",                       "rule": "junk"},
  {"pattern": "*.md5",                            "rule": "sidecar"},
  {"pattern": "*.i",                              "rule": "iterate"},
  {"pattern": "*_[0-9]",                          "rule": "iterate"},
  {"pattern": "run.log*",                         "rule": "bookkeeping"},
  {"pattern": "b2.log*",                          "rule": "legacy-log"},
  {"pattern": "fort.21",                          "rule": "legacy-input"},
  {"pattern": "fort.22",                          "rule": "legacy-input"},
  {"pattern": "H2VIBR",                           "rule": "legacy-input"},
  {"pattern": "AMMONX",                           "rule": "legacy-input"},
  {"pattern": "HYDHEL",                           "rule": "legacy-input"},
  {"pattern": "METHANE",                          "rule": "legacy-input"},
  {"pattern": "SPUTER",                           "rule": "legacy-input"},
  {"pattern": "b2time.nc*",                       "rule": "b2time"},
  {"pattern": "b2fstate*",                        "rule": "b2fstate"},
  {"pattern": "b2fplasma*",                       "rule": "b2fplasma"},
  {"pattern": "b2fplasmf",                        "rule": "b2fplasma"},
  {"pattern": "b2fmovie",                         "rule": "b2fmovie"},
  {"pattern": "b2fparam",                         "rule": "stream"},
  {"pattern": "b2frates",                         "rule": "stream"},
  {"pattern": "b2fpardf",                         "rule": "stream"},
  {"pattern": "b2ftrack",                         "rule": "stream"},
  {"pattern": "b2ftrace*",                        "rule": "stream"},
  {"pattern": "b2fgmtry",                         "rule": "b2fgmtry"},
  {"pattern": "b2batch.nc*",                      "rule": "nc-ondemand"},
  {"pattern": "b2tallies.nc*",                    "rule": "nc-ondemand"},
  {"pattern": "fort.44",                          "rule": "fort44"},
  {"pattern": "fort.46",                          "rule": "fort46"},
  {"pattern": "fort.30",                          "rule": "fort30"},
  {"pattern": "fort.1[0-9]",                      "rule": "fort-block"},
  {"pattern": "fort.3[015]",                      "rule": "fort-block"},
  {"pattern": "fort.3[1345]",                     "rule": "fort-block"},
  {"pattern": "*.last10",                         "rule": "monitor-tail"},
  {"pattern": ".status",                          "rule": "bookkeeping"},
  {"pattern": ".current_status",                  "rule": "bookkeeping"},
  {"pattern": ".status.history",                  "rule": "bookkeeping"},
  {"pattern": "*.trc",                            "rule": "trace"},
  {"pattern": "*.ps",                             "rule": "ps-snapshot"},
  {"pattern": "input.dat*",                       "rule": "eirene-input"},
  {"pattern": "b2mn.dat*",                        "rule": "b2mn"},
  {"pattern": "b2mn.drift*",                      "rule": "b2mn"},
  {"pattern": "b2.*.parameters*",                 "rule": "parameters"},
  {"pattern": "b2??.dat*",                        "rule": "deck-machinery"},
  {"pattern": "b2??.prt*",                        "rule": "deck-machinery"},
  {"pattern": "b2y?.dat",                         "rule": "deck-machinery"},
  {"pattern": "b2md.dat",                         "rule": "deck-machinery"},
  {"pattern": "mesh.extra",                       "rule": "deck-machinery"},
  {"pattern": "NREG",                             "rule": "deck-machinery"},
  {"pattern": "*.trg",                            "rule": "grid-input"},
  {"pattern": "*.str",                            "rule": "grid-input"},
  {"pattern": "*.dg",                             "rule": "grid-input"},
  {"pattern": "*.dgo",                            "rule": "grid-input"},
  {"pattern": "*.geo",                            "rule": "grid-input"},
  {"pattern": "*.ogr",                            "rule": "grid-input"},
  {"pattern": "gridue",                           "rule": "grid-input"},
  {"pattern": "grid*",                            "rule": "grid-input"},
  {"pattern": "tria.*",                           "rule": "grid-input"},
  {"pattern": "triang.hed",                       "rule": "grid-input"},
  {"pattern": "template.*",                        "rule": "grid-input"},
  {"pattern": "contour*",                         "rule": "grid-input"},
  {"pattern": "carre.*",                          "rule": "grid-input"},
  {"pattern": "iterm.carre.*",                    "rule": "grid-input"},
  {"pattern": "Baseline2008*",                    "rule": "grid-input"},
  {"pattern": "F57*",                             "rule": "grid-input"},
  {"pattern": "28903.*",                          "rule": "grid-input"},
  {"pattern": "plasmastate.*",                    "rule": "plasmastate"},
  {"pattern": "structure.dat",                    "rule": "aux-input"},
  {"pattern": "rzpsi.dat",                        "rule": "aux-input"},
  {"pattern": "frontier.dat",                     "rule": "aux-input"},
  {"pattern": "btor.dat",                         "rule": "aux-input"},
  {"pattern": ".na_feedback",                     "rule": "aux-input"},
  {"pattern": "b2fstati*",                        "rule": "b2fstate"},
  {"pattern": "b2mn.prt",                         "rule": "deck-machinery"},
  {"pattern": "balance.nc*",                      "rule": "nc-ondemand"},
  {"pattern": "*.eir",                            "rule": "eirene-input"},
  {"pattern": "eirene*.json",                     "rule": "eirene-input"},
  {"pattern": "user_data.input",                  "rule": "eirene-input"},
  {"pattern": "triageom.*",                       "rule": "grid-input"},
  {"pattern": "triangles.dat",                    "rule": "grid-input"},
  {"pattern": "dg.equ",                           "rule": "grid-input"},
  {"pattern": "structures.dat",                   "rule": "grid-input"},
  {"pattern": "shadow.dat",                       "rule": "grid-input"},
  {"pattern": "sput_trg.sum",                     "rule": "grid-input"},
  {"pattern": "wlld*",                            "rule": "wall-def"},
  {"pattern": "wlly*",                            "rule": "wall-def"},
  {"pattern": "fp_tg*",                           "rule": "eirene-derived"},
  {"pattern": "ld_tg*",                           "rule": "eirene-derived"},
  {"pattern": "peak_power*",                      "rule": "eirene-derived"},
  {"pattern": "SOLPS_FLUIDS",                     "rule": "deck-machinery"},
  {"pattern": "*.py",                             "rule": "family-tooling"},
  {"pattern": "*.F",                              "rule": "family-tooling"},
  {"pattern": "*.scr",                            "rule": "family-tooling"},
  {"pattern": "Makefile",                         "rule": "family-tooling"},
  {"pattern": "README.md",                        "rule": "family-tooling"},
  {"pattern": "COMMENTS",                         "rule": "family-tooling"},
  {"pattern": "ACKNOWLEDGEMENT",                  "rule": "family-tooling"},
  {"pattern": "Instructions.*",                   "rule": "family-tooling"},
  {"pattern": "turn_on_drifts.scr",               "rule": "family-tooling"},
  {"pattern": "dsi",                              "rule": "stream"},
  {"pattern": "dsa",                              "rule": "stream"},
  {"pattern": "dsr",                              "rule": "stream"},
  {"pattern": "dsl",                              "rule": "stream"},
  {"pattern": "dsL*",                             "rule": "stream"},
  {"pattern": "dsR*",                             "rule": "stream"},
  {"pattern": "dsT*",                             "rule": "stream"},
  {"pattern": "dst?",                             "rule": "stream"},
  {"pattern": "eirtria.log",                      "rule": "bookkeeping"},
  {"pattern": "vertex_data.out",                  "rule": "bookkeeping"},
  {"pattern": "*.tar.gz",                         "rule": "family-tooling"}
]
```
