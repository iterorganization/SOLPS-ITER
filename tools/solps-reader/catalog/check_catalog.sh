#!/bin/bash
# check_catalog.sh — golden determinism + structural test for the catalog.
#
# Stage 1 (golden): snapshot catalog/out, re-run build_manifests.py,
#   build_switchsets.py, then build_catalog.py (switchsets BEFORE the
#   site — the site consumes out/switchsets.json,), diff -r.
#   PASS = manifests JSON + switchsets + static site rebuild
#   byte-identically.
# Stage 2 (structural): index table rows align with the manifest count,
#   every manifest has a page, and the ITER_2275 page carries its verdict,
#   code git hash, wall-load rows, traceability note and figure.
#
# On FAIL the catalog holds the NEW outputs; the snapshot is kept at the
# printed path for deliberate diff/restore (check_deck.sh convention).
# On PASS the snapshot and the diff scratch are removed — a green run
# leaves nothing behind (the /tmp accumulation was the old behavior).
#
# Usage: catalog/check_catalog.sh
set -u
# CDPATH='' : an exported CDPATH makes cd PRINT its resolved
# destination, which would leak into HERE as a second line
HERE="$(CDPATH='' cd "$(dirname "$0")" && pwd)"
# interpreter override: any Python with the reader library importable
# interpreter override: any Python with the reader library importable;
# default resolves the venv of either tree shape — the folded repo
# (tools/.venv, two levels up) or the standalone package (one level up)
if [ -n "${CATALOG_PYTHON:-}" ]; then
  PY="$CATALOG_PYTHON"
elif [ -x "$HERE/../../.venv/bin/python" ]; then
  PY="$HERE/../../.venv/bin/python"
else
  PY="$HERE/../.venv/bin/python"
fi
OUT="$HERE/out"

SNAP_ROOT="$(mktemp -d)"
SNAP="$SNAP_ROOT/golden"
DIFF="$(mktemp -t check_catalog_diff)"
# success cleans up; a failure KEEPS both for deliberate diff/restore
trap 'rc=$?; if [ $rc -eq 0 ]; then rm -rf "$SNAP_ROOT" "$DIFF"; fi' EXIT
mkdir -p "$SNAP"
rsync -a --exclude .DS_Store "$OUT/" "$SNAP/"

# --examples-only: the certified set, whatever this
# machine's remembered sources hold (the maintainer's personal
# groups and comparisons never enter the gate proof)
if ! SOLPS_SHELL=1 "$PY" "$HERE/build_manifests.py" --examples-only >/dev/null; then
  echo "FAIL: build_manifests.py exited nonzero (snapshot kept: $SNAP)"; exit 1
fi
if ! SOLPS_SHELL=1 "$PY" "$HERE/build_switchsets.py" --examples-only >/dev/null; then
  echo "FAIL: build_switchsets.py exited nonzero (snapshot kept: $SNAP)"; exit 1
fi
if ! SOLPS_SHELL=1 "$PY" "$HERE/build_catalog.py" >/dev/null; then
  echo "FAIL: build_catalog.py exited nonzero (snapshot kept: $SNAP)"; exit 1
fi
if ! diff -r --exclude .DS_Store "$SNAP" "$OUT" >"$DIFF" 2>&1; then
  echo "FAIL: rebuild differs — out/ now holds NEW outputs (snapshot: $SNAP)"
  echo "diff kept at: $DIFF"
  cat "$DIFF"
  exit 1
fi
echo "PASS stage 1: manifests + switchsets + site rebuild byte-identical"

if ! SOLPS_SHELL=1 "$PY" - "$OUT" <<'EOF'
import json, re, sys
from pathlib import Path
from urllib.parse import quote

out = Path(sys.argv[1])
runs = json.loads((out / "index.json").read_text())["runs"]
idx = (out / "site" / "index.html").read_text()
# the name IS the path: group/family/run as real directories
def _page(name):
    return out.joinpath("site", *name.split("/")) / "index.html"
# index alignment, shape-proof under the per-family tables: every
# manifest run renders a landing row and owns a page
for r in runs:
    assert r["name"] in idx, f"index missing run row: {r['name']}"
    assert _page(r["name"]).is_file(), f"missing page: {r['name']}"
run = _page("example-runs/ITER_2275_Donly_20MW/run_restart").read_text()
for needle in ("plateaued", "68af8ded", "181, 182", "FORMATS.md"):
    assert needle in run, f"2275 page missing: {needle}"
# the deck marker lives on the FAMILY PAGE since checkpoint B (the
# base deck renders once per family — baserun-data-once); the run
# page carries the vs-base delta instead
fam_pg = _page("example-runs/ITER_2275_Donly_20MW").read_text()
assert "example-runs__ITER_2275_Donly_20MW__baserun.json" in fam_pg, \
    "2275 family page missing deck marker"
assert "<h2>Family base deck</h2>" in fam_pg, "family page missing base anchor"
assert _page("example-runs/ITER_2275_Donly_20MW/run_restart") \
    .parent.joinpath("wall_loads.png").is_file()
# the multi-species ITER_2171 run carries the same wall-load figure
assert _page("example-runs/ITER_2171_D+He+Be+Ne/run") \
    .parent.joinpath("wall_loads.png").is_file()
# one deck manifest per run family; run input_deck links resolve
families = {r["run_family"] for r in runs}
deck_files = sorted((out / "manifests").glob("*__baserun.json"))
assert len(deck_files) == len(families), \
    f"deck manifests {len(deck_files)} != run families {len(families)}"
for r in runs:
    m = json.loads((out / r["manifest"]).read_text())
    if m.get("input_deck"):
        assert (out / m["input_deck"]).is_file(), \
            f"unresolved input_deck: {r['name']} -> {m['input_deck']}"
# every classifiable run's page renders its sparkline strip —
# one inline SVG per active monitor, count == the manifest's monitors
# (JSON-driven geometry, no staged assets); the guard-skipped run carries
# the honest absence note instead — never a blank.  The convergence PNGs
# are RETIRED: no run page references convergence.png, none is staged.
n_spark = 0
for r in runs:
    m = json.loads((out / r["manifest"]).read_text())
    page = _page(r["name"]).read_text()
    sp = ((m.get("convergence") or {}).get("sparklines")) or {}
    if (m.get("convergence") or {}).get("verdict"):
        mons = sp.get("monitors") or {}
        assert mons, f"classifiable run without sparklines: {r['name']}"
        n_svg = page.count('<svg class="spark"')
        assert n_svg == len(mons), \
            f"{r['name']}: sparklines {n_svg} != manifest monitors {len(mons)}"
        assert "convergence.png" not in page, f"{r['name']}: retired PNG referenced"
        assert not _page(r["name"]).parent.joinpath("convergence.png").exists(), \
            f"{r['name']}: retired convergence.png still staged"
        n_spark += 1
    else:
        assert "convergence sparklines not generated" in page, \
            f"skip note missing: {r['name']}"
        assert '<svg class="spark"' not in page, \
            f"stray sparkline on skipped run: {r['name']}"
# the ramping_drifts page FLIPPED note -> sparkline strip when
# the guard repeal let its one 2.44 GB b2time.nc through — 9/9 strips,
# the physical span over its 100,001 records, and the classifier's
# actual verdict (evolving; an early preview said near-plateau — pinned
# is what _classify_trace computes, never the preview).
ramp = _page("example-runs/ITER_2588_drifts/ramping_drifts").read_text()
assert "2.5e-07 s -&gt; 2.5e-01 s over 100001 records" in ramp, \
    "ramping_drifts physical-span line missing"
assert ramp.count('<svg class="spark"') == 3, "ramping_drifts sparklines != 3"
assert ">evolving</span>" in ramp, "ramping_drifts verdict badge missing"
assert "Not assessed" not in ramp, "ramping_drifts still carries the old skip note"
assert n_spark == 9, f"sparkline strips {n_spark} != 9 (9/9 coverage)"
# the wall gate: every run page states its wall figure or exactly why there
# is none — decided from the manifest's wall_geometry JSON ONLY (the
# has_fig filesystem check retired).  A recorded figure entry
# (pass only,) must be embedded + staged; every other verdict
# renders the honest note — and NO page references a wall PNG the
# manifest does not record.
n_wallfig = n_wallnote = 0
for r in runs:
    m = json.loads((out / r["manifest"]).read_text())
    page = _page(r["name"]).read_text()
    if (m.get("wall_geometry") or {}).get("figure"):
        n_wallfig += 1
        assert '<img src="wall_loads.png"' in page, f"{r['name']}: figure not embedded"
        assert _page(r["name"]).parent.joinpath("wall_loads.png").is_file(), \
            f"{r['name']}: recorded figure not staged"
    else:
        n_wallnote += 1
        assert "wall figure not generated" in page, f"{r['name']}: wall note missing"
        assert '<img src="wall_loads.png"' not in page, \
            f"{r['name']}: unrecorded wall PNG referenced"
        assert not _page(r["name"]).parent.joinpath("wall_loads.png").exists(), \
            f"{r['name']}: unrecorded wall PNG staged"
assert n_wallfig == 2, f"wall figures {n_wallfig} != 2 (the wall gate pass set)"
assert n_wallnote == 7, f"wall notes {n_wallnote} != 7"
# every recorded diff deck has a comparison page staging the
# whole deck, and each member run page links to its family's page.
comps = json.loads((out / "index.json").read_text()).get("comparisons", [])
n_diff = 0
for c in comps:
    if not c.get("deck"):
        continue
    n_diff += 1
    fam = c["run_family"]
    cdir = out / "site" / "comparisons" / fam
    assert (cdir / "index.html").is_file(), f"missing comparison page: {fam}"
    assert (cdir / "diff_summary.txt").is_file(), f"summary not staged: {fam}"
    for name, entry in sorted(c["files"].items()):
        staged = cdir / name
        assert staged.is_file(), f"{fam}/{name}: deck file not staged"
        assert staged.stat().st_size == entry["bytes"], f"{fam}/{name}: size drift"
    for member in c["pair"]:
        # members are group-relative; the page identity is the group-
        # qualified name (run pages sit at depth 3)
        group = fam.split("/")[0]
        page = _page(f"{group}/{member}").read_text()
        # hrefs are percent-encoded with explicit index.html ('+' slugs
        # and bare directory URLs both break file:// navigation)
        assert f'href="../../../comparisons/{quote(fam)}/index.html"' in page, \
            f"{member}: comparison link missing"
assert n_diff == 3, f"diff decks {n_diff} != 3 (pair count)"
# the switchsets join artifact exists, declares its schema, and
# covers exactly the manifest run set (goldens untouched — the
# file is additive to out/, manifests themselves unchanged).
ss_path = out / "switchsets.json"
assert ss_path.is_file(), "out/switchsets.json missing "
ss = json.loads(ss_path.read_text())
assert ss.get("schema") == "catalog-switchsets/1", "switchsets schema key wrong"
assert set(ss["runs"]) == {r["name"] for r in runs}, \
    "switchsets run coverage != manifest run set"
# every run page carries its Switches section — the FULL
# artifact table (row count == switch_count, the Files-table
# no-truncation rule) + one pinned value per run (the b2mndr_ntim
# final, set by all 9 runs).
for r in runs:
    name = r["name"]
    page = _page(name).read_text()
    assert "<h2>Switches" in page, f"switches section missing: {name}"
    # the section heading links the switch index (back-link half
    # of the site linkage; run pages sit at depth 3)
    assert 'href="../../../switches/index.html"' in page, \
        f"switch index link missing: {name}"
    entry = ss["runs"][name]
    tbl = page.split('<table class="switches">', 1)[1].split("</table>", 1)[0]
    assert tbl.count("<tr>") == entry["switch_count"] + 1, \
        f"{name}: switch rows {tbl.count('<tr>')} != switch_count {entry['switch_count']} + header"
    ntim = entry["switches"]["b2mndr_ntim"]["value"]
    assert f'<td class="mono">{ntim}</td>' in tbl, \
        f"{name}: b2mndr_ntim final {ntim!r} not rendered verbatim"
    # the documented-default column — header wording + one pinned
    # default per run page (b2mndr_ntim, set by all 9 runs, default '1')
    assert '<th scope="col">documented default</th>' in tbl, \
        f"{name}: documented-default column header missing"
    d_ntim = entry["switches"]["b2mndr_ntim"]["default"]
    assert f'<td class="ddef ddef-val">{d_ntim}</td>' in tbl, \
        f"{name}: b2mndr_ntim documented default {d_ntim!r} not rendered"
# the switch index page (switch -> runs) — one row per
# inverted_index key (rows carry anchor ids, so they are counted as
# '<tr id="' plus exactly one bare thead '<tr>' header), and both
# linkage needles.
sw_page_path = out / "site" / "switches" / "index.html"
assert sw_page_path.is_file(), "switch index page missing "
sw_page = sw_page_path.read_text()
n_sw = len(ss["inverted_index"])
sw_tbl = sw_page.split('<table class="switches" data-sort data-filter>', 1)[1].split("</table>", 1)[0]
assert sw_tbl.count('<tr id="') == n_sw, \
    f"switch index id-rows {sw_tbl.count('<tr id=')} != {n_sw} keys"
assert sw_tbl.count("<tr>") == 1, "switch index thead header rows != 1"
assert f'<tr id="b2tfnb_drift_style">' in sw_tbl, "anchor row missing"
# one pinned default per index row kind — the prose golden on
# b2tfnb_drift_style + the numeric b2mndr_ntim default, each ONCE per row
assert "documented default See description" in sw_tbl, \
    "switch index prose default missing (b2tfnb_drift_style)"
ntim_line = [l for l in sw_tbl.split("\n") if l.startswith('<tr id="b2mndr_ntim">')]
assert ntim_line and "documented default 1</span>" in ntim_line[0], \
    "switch index b2mndr_ntim documented default missing"
assert 'href="switches/index.html"' in idx, "catalog index missing switch link"
# + the THREE-SECTION shape: the release axis is DORMANT —
# no Releases section, no deltarun pages anywhere in the site, and
# no run page carries the release-history row (neither link nor the
# honest-absence note — the note would claim an unshipped axis).
# The committed page-data joins under out/deltarun_pages/ stay in
# the tree untouched; the builders too.
assert '<h2><span class="sn">01</span>Runs</h2>' in idx, "runs section missing"
assert '<h2><span class="sn">02</span>Comparisons</h2>' in idx, \
    "comparisons section missing"
assert '<h2><span class="sn">03</span>Switch index</h2>' in idx, \
    "switch section missing"
assert "Release reports" not in idx, "the dormant release section leaked"
assert "deltarun" not in idx, "a deltarun link leaked onto the landing"
assert not (out / "site" / "deltarun").exists(), \
    "deltarun pages still emitted"
for r in runs:
    page = _page(r["name"]).read_text()
    assert "release history" not in page, \
        f"{r['name']}: release-history row on a dormant axis"
# the landing is the INVENTORY: closed count-bearing tree,
# navigating group labels, per-group facts + fingerprint, the dot
# legend, and — the certified shape being examples-only — the
# empty-state teacher.  NO family tables on the landing (they live
# on the group pages, checkpoint B).
assert '<details class="r-grp" data-grp="example-runs">' in idx and \
    '<details class="r-grp" data-grp="example-runs" open>' not in idx, \
    "tree not closed"
assert '<details class="r-fam" data-fam=' in idx and \
    '<details class="r-fam" data-fam=' + '"example-runs/ITER_2588_drifts" open>' \
    not in idx, "families not closed"
# the open state is the USER'S (round 2): the class-based accordion
# ships in the page's own CSS and the persisting store rides the
# script — the exclusive :has(a.here) coupling is gone from the bytes
assert ".r-sec:not(.open) > .r-sub" in idx, "the user-open CSS rule missing"
assert ":has(a.here) > .r-sub" not in idx, \
    "the exclusive accordion CSS leaked back"
assert "catalog-rail-open" in idx, "the persisting open-state store missing"
# round 6 (owner review): the section label NAVIGATES FIRST — the
# jump happens with the tree's state untouched, and only the click
# after the jump (the URL already at the section) closes
assert "the label NAVIGATES FIRST" in idx, \
    "the round-6 label-navigates-first rule missing"
# round 6 (owner review): ARRIVALS ARE QUIET — the load-time opens
# (the store's apply, the here-ancestry, the fragment handoff) land
# without the disclosure animation; the user's own toggles keep it
assert "html.no-anim .rail .r-sub" in idx, \
    "the quiet-arrival CSS rule missing"
assert '<a class="r-lab" href="example-runs/index.html">' in idx, \
    "the group label is not a navigating anchor"
assert ('href="example-runs/ITER_2275_Donly_20MW/index.html">'
        in idx), "the family label is not a navigating anchor"
assert "· 5 families · 9 runs</span>" in idx, "group counts missing"
assert '<span class="n">5</span><span class="l">families</span>' in idx \
    and '<span class="n">9</span><span class="l">runs</span>' in idx, \
    "the inventory stat row missing"
assert 'class="grp-fp">analyses' in idx, "the fingerprint line missing"
assert 'class="vlegend"' in idx, "verdict-dot legend missing"
assert "it can carry yours" in idx, "the teacher missing on the examples-only shape"
assert "built at" not in idx, "a clock leaked into the proven shape"
assert '<h4 class="fam-h">' not in idx, "family tables still on the landing"
# checkpoint B — the hierarchy: one group page per cataloged group
# (family blocks + ONE aggregating filter), one family page per real
# family (the base deck once + the member table), the backlink chain
# (landing <- group <- family <- run), and the vs-base delta's honest
# absence on the examples (their baserun decks carry no b2mn.dat —
# the switch layer is per-run in the shipped reference set)
n_fampg = 0
seen_fams = set()
for r in runs:
    parts = r["name"].split("/")
    gp = out / "site" / parts[0] / "index.html"
    assert gp.is_file(), f"missing group page: {parts[0]}"
    assert 'data-filter-scope' in gp.read_text(), \
        f"group filter missing: {parts[0]}"
    if len(parts) > 2 and "/".join(parts[:2]) not in seen_fams:
        seen_fams.add("/".join(parts[:2]))
        fp = out.joinpath("site", *parts[:2], "index.html")
        assert fp.is_file(), f"missing family page: {'/'.join(parts[:2])}"
        fp_html = fp.read_text()
        assert "<h2>Family base deck</h2>" in fp_html, \
            f"family page missing base anchor: {'/'.join(parts[:2])}"
        assert f'href="../../{parts[0]}/index.html"' in fp_html, \
            f"family page missing group backlink: {'/'.join(parts[:2])}"
        n_fampg += 1
assert n_fampg == 5, f"family pages {n_fampg} != 5"
assert "Vs family base" in run, "run page missing vs-base section"
assert "carries no b2mn.dat for the switch layer" in run, \
    "the examples' honest switch-layer absence missing"
assert "<h2>Input deck</h2>" not in run, \
    "the deck block still renders on run pages (lives on the family page)"
assert 'href="../index.html">family page' in run, "run page family link missing"
# checkpoint C (owner display round 1) — the comparisons' TWO HOMES:
# the landing's Comparisons section carries the counts + the rule +
# a LIGHT DECK INDEX (one link per deck-carrying family, exactly
# n_decks of them) + the recorded pairs; the rail's comparisons
# children stay recorded-pairs-only (none in the certified shape, so
# exactly TWO r-sub blocks stand: runs + switches) while each
# deck-carrying family carries its own A/B ITEM inside the runs tree;
# the family pages state the qualified h1 + their comparison block
# (deck link, or the skipped reason); the deck-carrying comparison
# pages mark their OWN A/B item in the rail and carry the lineage
# crumb; the switch surfaces state their scope and the landing's
# switch line agrees with the artifact's own counts
assert "Two homes" in idx and ("If you chose the pair, it's here; if the "
    "family made it for you, it's there.") in idx, "two-homes rule missing"
n_decks = sum(1 for c in comps if c.get("deck"))
n_pairs = sum(1 for c in json.loads((out / "index.json").read_text())
              .get("recorded_comparisons", []) if c.get("deck"))
assert f"{n_decks} family decks · {n_pairs} recorded pair" in idx, \
    "comparisons counts line missing"
assert idx.count('href="comparisons/') == 2 * n_decks, \
    "deck links on the landing != two per deck (the light deck index + " \
    "the rail's own A/B items)"
assert idx.count(">A/B comparison</a>") == n_decks, \
    "the rail does not carry one A/B item per deck-carrying family"
# the comparisons section's children are the RECORDED pairs alone; the
# reference set carries its own committed pair (data/recorded-
# comparisons.json) so the section demonstrates itself — runs and
# switches always carry children, comparisons exactly when pairs stand
assert idx.count('<div class="r-sub">') == 2 + (1 if n_pairs else 0), \
    "the rail's sub-blocks != runs + switches (+ comparisons when pairs " \
    "stand)"
if n_pairs:
    pair_page = (out / "site" / "compare"
                 / "example-runs__ITER_2588_drifts__run_with_drifts__vs__"
                   "example-runs__ITER_2588_drifts__ramping_drifts"
                 / "index.html")
    assert pair_page.is_file(), "the reference pair's page missing"
    pp = pair_page.read_text()
    assert "run_with_drifts" in pp and "ramping_drifts" in pp
    assert "rode different code" not in pp, \
        "both-None stamps must not render a code-delta line"
    for side in ("run_with_drifts", "ramping_drifts"):
        rp = out.joinpath("site", "example-runs", "ITER_2588_drifts", side,
                          "index.html").read_text()
        assert "recorded A/B comparison vs" in rp, \
            f"the reference pair's member backlink missing: {side}"
    assert ("Recorded pairs (catalog compare)" in idx
            and "example-runs/ITER_2588_drifts/run_with_drifts vs "
            "example-runs/ITER_2588_drifts/ramping_drifts" in idx), \
        "the landing's recorded-pairs table missing the reference pair"
for c in comps:
    fam = c["run_family"]
    group, _, fam_name = fam.partition("/")
    fam_page = out.joinpath("site", group, fam_name, "index.html").read_text()
    assert f"<h1>{fam}</h1>" in fam_page, \
        f"family page h1 is not the group-qualified name: {fam}"
    assert "<h2>Family A/B comparison</h2>" in fam_page, \
        f"family page comparison block missing: {fam}"
    if c.get("deck"):
        cpage = (out / "site" / "comparisons" / fam / "index.html").read_text()
        assert '<span class="c-here" title="A/B comparison" ' \
            'aria-current="page">A/B comparison</span>' in cpage, \
            f"comparison page crumb tail missing: {fam}"
        assert 'class="r-c here" aria-current="page" title=' in cpage, \
            f"comparison page does not mark its own A/B item: {fam}"
        assert 'href="../../comparisons/' in fam_page, \
            f"family page deck link missing: {fam}"
    else:
        assert "not generated:" in fam_page, \
            f"skipped deck's honest note missing from its family page: {fam}"
assert 'href="../../../example-runs/ITER_2171_D%2BHe%2BBe%2BNe/index.html"' \
    in (out / "site" / "comparisons" / "example-runs"
        / "ITER_2171_D+He+Be+Ne" / "index.html").read_text(), \
    "the 2171 comparison page's family backlink missing"
assert "One ledger over every cataloged run" in sw_page, \
    "switch page scope statement missing"
# the switch page sits ONE under the site root: its run links carry
# the depth-1 prefix (the depth-3 run-page prefix climbed two levels
# ABOVE the site — every run link 404'd under file://; caught live by
# checkpoint C's href sweep, shipped broken since the multifolder
# rework)
assert 'href="../example-runs/' in sw_page, \
    "switch page run links lost their depth-1 prefix"
assert 'href="../../../' not in sw_page, \
    "a depth-3 prefix leaked back into the switch page"
sc = ss["counts"]
assert (f"{sc['distinct_switches_set']} switches over {sc['runs']} runs,"
        in idx), "landing switch counts line disagrees with the artifact"
print(f"structural OK: {len(runs)} manifests, pages aligned, 2275 markers present, "
      f"{len(deck_files)} deck manifests linked, {n_wallfig} wall figures + "
      f"{n_wallnote} wall notes, {n_spark} sparkline strips, "
      f"{n_diff} comparison decks, switchsets for {len(ss['runs'])} runs, "
      f"switches sections on {len(runs)} run pages, switch index {n_sw} rows, "
      f"three-section landing (runs/comparisons/switches), closed tree, "
      f"teacher + legend + inventory pinned, release axis dormant, "
      f"hierarchy: 1 group + {n_fampg} family pages + backlinks + delta, "
      f"two homes: {n_decks} decks indexed + railed under their families "
      f"+ rule pinned + {n_pairs} recorded pair(s) incl. the reference "
      f"pair's own")
EOF
then
  echo "FAIL: structural QC failed"
  exit 1
fi

echo "PASS: catalog golden + structural"
