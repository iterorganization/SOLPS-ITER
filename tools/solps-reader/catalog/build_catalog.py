#!/usr/bin/env python3
"""Static catalog generator — the publication tier's first pages.

Consumes catalog/out (index.json + manifests from build_manifests.py) and
emits a zero-server static site under catalog/out/site/:

  site/index.html          — the inventory landing : per-group
                              blocks (label, source, family/run counts,
                              verdict summary, the group's analysis
                              fingerprint), sick groups as first-class
                              rows, the empty-state teacher while no
                              user group stands, one-line inventories
                              for comparisons and switches.  THREE
                              sections: Runs / Comparisons / Switches
  site/<slug>/index.html   — per-run page: provenance, input deck (from
                              the linked deck manifest), switches (the
                              effective b2mn.dat switch-set joined to
                              the documented defaults, rendered
                              read-only from out/switchsets.json,
                              the documented-default column
                              ), convergence (verdict badge +
                              ONE physical-time line + an inline SVG
                              sparkline per active monitor from the
                              manifest's sparklines block —
                              the full-trace PNG figures are retired),
                              wall-load summary + figure-or-note from
                              the manifest's wall_geometry record
                              (the wall gate: only a gate pass records a
                              figure — hence paints; every other
                              verdict renders its recorded cause
                              verbatim), file inventory, and a link
                              to the family comparison page when one
                              exists
  site/comparisons/<family>/index.html
                           — family A/B page: the state-diff
                              deck staged as assets (one PNG per catalog
                              field) and diff_summary.txt rendered
                              VERBATIM in a <pre> — a staged artifact,
                              never recomputed
  site/compare/<pair>/index.html
                           — recorded cross-group A/B pair (the
                              compare verb), the same deck shape

  The release axis (report pages, the version-axis index, the case
  screens under site/deltarun/) is DORMANT this delivery : the
  committed page-data joins under out/deltarun_pages/, the builders,
  and their rendering functions below all stay in the tree untouched —
  the site simply stops emitting the pages and the Releases section,
  one restore away from folding the axis back in as a shaped feature.

Deterministic: sorted everything, inline CSS, no timestamps, no external
assets.  The ONE ruled exception (the determinism rule): a
"built at" wall-clock line renders ONLY when the CLI hands one down
(the user-seat build, where a user group stands) — the gate and the
maintainer --in-tree path never pass it, so every proven byte stays
clock-free. Typefaces self-hosted: Sora / Source Serif 4 / IBM Plex
Mono — the askthedocs reference set, vendored under fonts/ at its pins,
staged once at the site root and referenced through each page's depth
prefix (zero network, identical rendering on every OS; the OFL texts
ship in site fonts/).  One
shared inline script per page: client-side
sort/filter only, progressive enhancement — every table and all content
stay fully usable with scripts off. Figures answer where/whether; every
number on these pages comes from the manifest JSON — never re-derived.

Run with the SOLPS-Reader venv interpreter (house rule).
"""
from __future__ import annotations

import hashlib
import html
import json
import re
import shutil
from collections import Counter
from pathlib import Path
from urllib.parse import quote

import solps_reader

# the pinned version axis is single-sourced in the driver
# (build_release_report.py owns the resolver; the driver imports THIS
# module lazily inside its site stage, so no import cycle here).
from build_release_report import RELEASE_VERSIONS

HERE = Path(__file__).resolve().parent
OUT = HERE / "out"
SITE = OUT / "site"

BADGES = {
    # status tints tuned toward the navy hue (no raw pastels); the chip
    # stroke derives from the ink color in CSS — the pairs below carry
    # only bg/fg.  Badge TEXT carries identity — color is never alone.
    "plateaued": ("#e2eee5", "#17572c"),
    "near-plateau": ("#f9efd2", "#6b4700"),   # ITER amber family
    "evolving": ("#f9e2de", "#9e1f16"),
    "static": ("#ebedf3", "#4a5164"),
    # vs_default chips (out/switchsets.json enum) — a FACT
    # palette, not the verdict palette.  same/differs/no-default/
    # unknown are join-distance facts with no good/bad reading, so
    # they get hues the evaluative families never use: blue on-default,
    # pumpkin one-step-off, the absence gray, violet name-unknown.
    # Owner-picked from mock rounds (blue approved 1st, violet 2nd,
    # pumpkin = variant 2).  The badge TEXT still carries identity —
    # color is never alone, and the enum string renders verbatim,
    # never shortened.
    "same": ("#e1ebf8", "#1b4a89"),
    "differs": ("#fdc799", "#7f3c04"),
    "no_default_in_inventory": ("#ebedf3", "#4a5164"),
    "unknown_to_inventory": ("#e9e5f8", "#443a8e"),
    # wall-gate verdicts (the manifests' wall_geometry block,
    # recorded for every run): pass paints, every other
    # verdict notes — same palette language, badge TEXT carries the
    # identity, color never alone.
    "pass": ("#e2eee5", "#17572c"),
    "fail": ("#f9e2de", "#9e1f16"),
    "unsupported": ("#f9efd2", "#6b4700"),
    "unreadable": ("#f9efd2", "#6b4700"),
    "no-wall-data": ("#ebedf3", "#4a5164"),
    # release-pair tarball statuses (the diff's own
    # enum): changed is the headline, identical is fine, added/removed
    # are structural — badge TEXT carries identity as everywhere.
    "changed": ("#f9efd2", "#6b4700"),
    "identical": ("#e2eee5", "#17572c"),
    "added": ("#e1ebf8", "#1b4a89"),
    "removed": ("#f9e2de", "#9e1f16"),
}

#: Neutral pair for any status string outside BADGES — an unexpected
#: verdict must not crash the build; it renders unlabeled-in-color and
#: the TEXT still carries its identity (the badge() fallback, shared
#: by the tally meter and chips so no renderer can KeyError).
BADGES_FALLBACK = ("#eef1f4", "#57606a")

# out/switchsets.json vs_default_values order (catalog-switchsets/1) —
# the artifact's own enum order governs the tally chips.
VS_DEFAULT_ORDER = (
    "same", "differs", "no_default_in_inventory", "unknown_to_inventory")

# the run pages' Switches heading links the switch index (the
# other direction of the join) — one constant so every run page and the
# site tests/check needles agree byte-for-byte.
SWITCHES_HEAD = ('<h2>Switches · <a href="../../../switches/index.html">'
                 "switch index</a></h2>")

# the wall section heading, same one-constant rule — every run
# page carries the section (figure-or-note), so the heading must agree
# byte-for-byte across pages, tests and check needles.
WALL_HEAD = "<h2>Wall loads (fort.44 wall-load section)</h2>"

# the committed page-data join the release pages render from
# (out/deltarun_pages/*.json, written by build_release_page_data.py over
# the four gitignored-cache layer JSONs — adds the impact layer
# and bumps the schema; the pages never read the cache, never
# re-derive).  The public section name is "Release
# reports"; it appears only in the muted traceability line.
RELEASE_PAGE_SCHEMA = "catalog-deltarun-page/2"
RELEASE_PAGES_DIR = "deltarun_pages"

#: the release-axis dormancy switch : the axis (report pages,
#: version-axis index, case screens, the landing's Releases section,
#: the run pages' release-history row) is folded OUT of this
#: delivery's site everywhere — its builders, staging helpers and
#: the committed page-data joins all stay in the tree, one flip +
#: re-wire away from returning as a shaped feature.  The run-page
#: row is the one consumer that reads this switch directly (its
#: honest-absence note must not render against an unshipped axis).
_RELEASE_AXIS_LIVE = False

# the version label lookup over the same pinned resolver (never
# a git read at build time — provenance config, the axis-page pattern).
_VERSION_BY_COMMIT = {c: v for v, c in RELEASE_VERSIONS}

#: the tab icon — the plasma rule as a tile: the three brand
#: chromatics as bars on navy (the brand gesture in miniature, not a
#: drawing of anything).  A data URI is inline and self-contained like
#: everything else here: no network, no extra file.
FAVICON = (
    "data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' "
    "viewBox='0 0 32 32'%3E%3Crect width='32' height='32' rx='6' "
    "fill='%230f1632'/%3E%3Crect x='6' y='21' width='7' height='5' "
    "rx='1' fill='%232c6ecb'/%3E%3Crect x='14' y='21' width='7' "
    "height='5' rx='1' fill='%233ed9fd'/%3E%3Crect x='22' y='21' "
    "width='5' height='5' rx='1' fill='%23fdbb30'/%3E%3C/svg%3E")

#: The ONE shared inline script: progressive enhancement only —
#: client-side sorting for tables marked data-sort, and text/verdict
#: filtering for tables marked data-filter (with a live count).  No
#: src, no network, no framework, no clock, no randomness; every table
#: and all content stay fully usable with scripts off.  The tests pin
#: this constant byte-for-byte (exactly one script element per page).
SCRIPT = """\
// the js flag gates every enhancement below: the page is
// fully usable without scripting, and this class — set BEFORE the
// body parses (the script lives in the head) — lets the CSS apply
// the accordion's initial collapsed state at first layout: no flash
// of the expanded menu on slow pages and no load-time animation —
// sections move only when the user acts
document.documentElement.classList.add("js");
// a deep-linked fragment names the landing's opening section at
// FIRST LAYOUT — the CSS opens it before any script-on-DOM moment
// (engines that fire DOMContentLoaded after the fragment descent
// would otherwise animate the section swap late, post-settle);
// #top maps to runs (home).  The attribute retires inside the
// arrival block's quiet window below — from then on the here-link
// state rules alone.
// LANDING-ONLY (data-frag-stamp rides the landing's script tag): on
// sub-pages the four names are foreign anchors — the switch page's
// #top is its Switches-indexed CHILD, and the stamp would map it to
// runs: an open-but-empty runs menu (visibility-hidden content) that
// the retire path never clears, because no landing toggle ever
// matches a sub-page fragment
(function () {
  if (!document.currentScript.hasAttribute("data-frag-stamp")) return;
  var m = (location.hash || "").match(/^#(top|comparisons|switches)$/);
  if (m) document.documentElement.setAttribute(
    "data-frag", m[1] === "top" ? "runs" : m[1]);
})();
document.addEventListener("DOMContentLoaded", function () {
  "use strict";
  // ---- the rail's open state is the USER'S (owner review, round 2) ----
  // trees open and close ONLY by a click: the amber mark, the
  // scroll-spy and the fragment moves change the HIGHLIGHT, never
  // the tree.  The state persists per browser tab across pages; a
  // page's arrival ADDS its own ancestry (the auto-open rule,
  // additive as before — a navigation never removes anything); and
  // a label click on the page it names toggles that tree in place
  // instead of reloading.  sessionStorage failures (private modes,
  // exotic origins) degrade to the page-local behavior only.
  var railStore = (function () {
    var KEY = "catalog-rail-open";
    var ids = [];
    try {
      ids = JSON.parse(sessionStorage.getItem(KEY)) || [];
    } catch (e) { ids = []; }
    if (!Array.isArray(ids)) ids = [];
    function idOf(el) {
      if (!el) return null;
      if (el.classList.contains("r-sec"))
        return "sec:" + (el.getAttribute("data-sec") || "");
      if (el.classList.contains("r-fam"))
        return "fam:" + (el.getAttribute("data-fam") || "");
      if (el.classList.contains("r-grp"))
        return "grp:" + (el.getAttribute("data-grp") || "");
      return null;
    }
    function save() {
      try { sessionStorage.setItem(KEY, JSON.stringify(ids)); }
      catch (e) {}
    }
    function isOpen(el) {
      return el.tagName === "DETAILS"
        ? el.hasAttribute("open") : el.classList.contains("open");
    }
    return {
      open: function (el) {
        var id = idOf(el);
        if (id && ids.indexOf(id) < 0) { ids.push(id); save(); }
        if (el.tagName === "DETAILS") el.setAttribute("open", "");
        else el.classList.add("open");
      },
      close: function (el) {
        var id = idOf(el), i = id ? ids.indexOf(id) : -1;
        if (i >= 0) { ids.splice(i, 1); save(); }
        if (el.tagName === "DETAILS") el.removeAttribute("open");
        else el.classList.remove("open");
      },
      toggle: function (el) {
        if (isOpen(el)) this.close(el); else this.open(el);
      },
      apply: function () {
        var els = document.querySelectorAll(
          ".rail .r-sec, .rail details");
        els.forEach(function (el) {
          var id = idOf(el);
          if (id && ids.indexOf(id) >= 0) railStore.open(el);
        });
      },
    };
  })();
  // ---- arrivals are QUIET (owner review, round 6) ----
  // the trees the user left open must LAND open on the next page,
  // not replay a collapse-and-expand over 0.28s (measured: every
  // page kind animated its arrival opens — the details' rAF-deferred
  // .d-open always, the sections' class-add whenever the closed
  // state had been computed pre-DOMContentLoaded; webkit showed
  // both).  One synchronous window: html.no-anim kills the rail's
  // grid transitions (the CSS rule above), the arrival opens land
  // below, every open details takes its .d-open GEOMETRY class in
  // the same step (the toggle events that follow asynchronously
  // find both set and animate nothing), the fragment stamp hands
  // its first-layout contract over and retires HERE — a stored-open
  // non-fragment section would otherwise flip when the spy retires
  // the attribute a moment later — a reflow commits the state, and
  // transitions re-arm for the user's own acts
  document.documentElement.classList.add("no-anim");
  railStore.apply();
  document.querySelectorAll(".rail a.here").forEach(function (a) {
    var sec = a.closest(".r-sec");
    if (sec) railStore.open(sec);
    var d = a.closest("details");
    while (d) {
      railStore.open(d);
      d = d.parentElement ? d.parentElement.closest("details") : null;
    }
  });
  // a deep-linked landing fragment opens its section (additive, like
  // every arrival; the CSS [data-frag] rules hold the first layout)
  (function () {
    var df = document.documentElement.getAttribute("data-frag");
    if (!df) return;
    var s = document.querySelector('.r-sec[data-sec="' + df + '"]');
    if (s) railStore.open(s);
  })();
  document.documentElement.removeAttribute("data-frag");
  document.querySelectorAll(".rail details[open]:not(.d-open)")
    .forEach(function (d) { d.classList.add("d-open"); });
  void document.documentElement.offsetWidth;   // commit, then re-arm
  document.documentElement.classList.remove("no-anim");
  // ---- the tree's own disclosure animates like the sections ----
  // (owner round 5b): the [open] attribute stays the semantic state;
  // the .d-open class drives the SAME 0fr<->1fr grid transition on
  // the script's timing — opens animate from the toggle event, closes
  // animate FIRST and drop the attribute at transition end, and a
  // re-click mid-close cancels (the pending drop checks the class)
  function detailsAnimate(d, open) {
    if (open) {
      d.setAttribute("open", "");        // reveal at 0fr; toggle animates
      return;
    }
    var sub = d.querySelector(":scope > .d-sub");
    if (!sub) { d.removeAttribute("open"); return; }
    d.classList.remove("d-open");        // animate to 0fr
    var done = function () {
      sub.removeEventListener("transitionend", done);
      if (!d.classList.contains("d-open")) d.removeAttribute("open");
    };
    sub.addEventListener("transitionend", done);
    setTimeout(done, 340);               // the no-transition fallback
  }
  document.querySelectorAll(".rail details").forEach(function (d) {
    // the toggle listener is the ONE open path: native marker clicks,
    // arrivals, the store's apply — persistence rides it too
    d.addEventListener("toggle", function () {
      if (d.hasAttribute("open")) {
        railStore.open(d);
        requestAnimationFrame(function () {
          void d.offsetWidth;            // flush: start collapsed
          d.classList.add("d-open");     // animate to 1fr
        });
      } else {
        railStore.close(d);
      }
    });
    // a close must animate BEFORE the attribute drops: the summary's
    // own clicks are intercepted (label clicks never reach this —
    // they navigate or toggle themselves)
    var s = d.querySelector(":scope > summary");
    if (s) s.addEventListener("click", function (e) {
      if (e.target.closest("a")) return;
      if (!d.hasAttribute("open")) return;   // native open animates
      e.preventDefault();
      if (d.classList.contains("d-open")) {
        detailsAnimate(d, false);
      } else {
        d.classList.add("d-open");       // mid-close re-click: cancel
      }
    });
  });

  // ---- the toggles ----
  (function () {
    // MARKER TOGGLES, LABEL NAVIGATES (owner review of round 2: the
    // row is a LINK to the landing's section again — the way back
    // home from deep pages; the 12px marker column is the toggle,
    // the same discipline the group and family rows follow).  A
    // childless section hides its marker and keeps the pure link.
    // OWNER ROUND 6: the label is a NAVIGATION first — on its own
    // page it jumps to its section with the tree's state untouched;
    // the toggle fires only once the URL already sits at the section
    // (the click after the jump), closing in place; from any other
    // page the label navigates home
    document.querySelectorAll(".rail .r-sec > a").forEach(function (a) {
      var sec = a.closest(".r-sec");
      if (!sec.querySelector(".r-sub")) return;
      var mark = a.querySelector(".r-mark");
      if (mark) mark.addEventListener("click", function (e) {
        e.preventDefault();
        e.stopPropagation();
        railStore.toggle(sec);
        a.setAttribute("aria-expanded",
          sec.classList.contains("open") ? "true" : "false");
      });
      a.addEventListener("click", function (e) {
        if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;
        var samePage = new URL(a.href).pathname === location.pathname;
        if (!samePage) return;      // the way home: navigate
        e.preventDefault();
        var m = (a.getAttribute("href") || "").match(/#(\\w+)$/);
        var isOpen = sec.classList.contains("open");
        // OWNER ROUND 6: the label NAVIGATES FIRST.  Open and
        // elsewhere -> the jump with the tree untouched; only once
        // the URL already sits at this section — the click AFTER
        // the jump — does the label close the tree, staying put;
        // a closed tree opens and jumps in the one act.  The marker
        // stays the pure toggle at all times
        var there = !!(m && location.hash === "#" + m[1]);
        function jump() {
          if (!m) return;
          if (location.hash === "#" + m[1]) {
            var t = document.getElementById(m[1]);  // same hash: the
            if (t) t.scrollIntoView();              // assignment alone
          } else {                                  // would not move
            location.hash = m[1];
          }
        }
        if (isOpen && !there) {
          jump();
        } else if (isOpen) {
          railStore.close(sec);
        } else {
          railStore.open(sec);
          jump();
        }
        a.setAttribute("aria-expanded",
          sec.classList.contains("open") ? "true" : "false");
      });
    });
    // a group/family label click on the page it names toggles that
    // tree in place instead of reloading — through the animated path
    // (every other label click navigates as always).  The own-page
    // test reads PATHNAMES (the round-6 sweep): a stray fragment on
    // the URL must never turn the toggle into a reload
    document.querySelectorAll(".rail summary a.r-lab").forEach(
      function (a) {
        a.addEventListener("click", function (e) {
          if (new URL(a.href).pathname !== location.pathname) return;
          e.preventDefault();
          var d = a.closest("details");
          if (d) detailsAnimate(d, d.hasAttribute("open") ? false : true);
        });
      });
  })();
  function cellText(row, i) {
    var c = row.cells[i];
    return c ? (c.textContent || "").replace(/[\\s\\u00a0]+/g, " ").trim() : "";
  }
  function numeric(s) {
    var m = s.replace(/,/g, "").match(/-?\\d+(?:\\.\\d+)?(?:e-?\\d+)?/i);
    return m ? parseFloat(m[0]) : null;
  }
  // ---- sort: click a column header, numeric-aware, stable ----
  document.querySelectorAll("table[data-sort]").forEach(function (t) {
    var ths = t.querySelectorAll("thead th");
    var tbody = t.tBodies[0];
    if (!tbody) return;
    ths.forEach(function (th, i) {
      th.setAttribute("scope", "col");
      th.classList.add("sort-key");
      th.addEventListener("click", function () {
        var dir = th.getAttribute("aria-sort") === "ascending" ? -1 : 1;
        ths.forEach(function (o) { o.removeAttribute("aria-sort"); });
        th.setAttribute("aria-sort", dir > 0 ? "ascending" : "descending");
        var rows = Array.prototype.slice.call(tbody.rows);
        rows.forEach(function (r, k) { r._k = k; });
        // numeric vs text mode is decided PER COLUMN, never per
        // pair — a per-pair mix is non-transitive and sorts to
        // garbage (owner-seen: the Run column, where names carry
        // embedded numbers but MAST_U carries none).  A column goes
        // numeric only when EVERY non-missing cell is number-led with
        // no letters after the first number ("96\\u00d736" qualifies,
        // "ITER_2275_..." does not).  "\\u2014"/empty are missing
        // values: ignored for the decision, stable at their slots.
        var numericCol = rows.some(function (r) {
              var s = cellText(r, i);
              return s && s !== "\\u2014" && /^-?\\d/.test(s);
            }) && rows.every(function (r) {
              var s = cellText(r, i);
              if (!s || s === "\\u2014") return true;
              if (!/^-?\\d/.test(s)) return false;
              var m = s.replace(/,/g, "")
                       .match(/^-?\\d+(?:\\.\\d+)?(?:e-?\\d+)?/i);
              return !!m && !/[a-z]/i.test(s.slice(m[0].length));
            });
        rows.sort(function (a, b) {
          var ta = cellText(a, i), tb = cellText(b, i);
          var cv;
          if (numericCol) {
            var na = numeric(ta), nb = numeric(tb);
            cv = (na === null || nb === null) ? 0
              : na < nb ? -1 : na > nb ? 1 : 0;
          } else {
            cv = ta.localeCompare(tb);
          }
          return cv * dir || (a._k - b._k) * dir;
        });
        rows.forEach(function (r) { tbody.appendChild(r); });
      });
    });
  });
  // ---- filter: one search box + contains-chips per marked table ----
  // tables sharing a scope (the landing's per-family run tables under
  // one toolbar) filter TOGETHER and their count aggregates; a lone
  // table behaves exactly as before
  (function () {
    var scopes = new Map();
    document.querySelectorAll("table[data-filter]").forEach(function (t) {
      var scope = t.closest("[data-filter-scope]") || document;
      if (!scopes.has(scope)) scopes.set(scope, []);
      scopes.get(scope).push(t);
    });
    scopes.forEach(function (tables, scope) {
      var input = scope.querySelector("input[data-filter-input]");
      var chips = Array.prototype.slice.call(
        scope.querySelectorAll("button[data-filter-contains]"));
      var count = scope.querySelector("[data-filter-count]");
      var all = [];
      tables.forEach(function (t) {
        if (t.tBodies[0]) all.push.apply(all,
          Array.prototype.slice.call(t.tBodies[0].rows));
      });
      if (!all.length || (!input && chips.length === 0)) return;
      var contains = null;
      function apply() {
        var q = input ? input.value.trim().toLowerCase() : "";
        var n = 0;
        all.forEach(function (r) {
          var txt = (r.textContent || "").toLowerCase();
          var ok = (!q || txt.indexOf(q) !== -1) &&
                   (contains === null || txt.indexOf(contains) !== -1);
          r.hidden = !ok;
          if (ok) n++;
        });
        if (count) count.textContent =
          n + " of " + all.length + " shown";
        chips.forEach(function (c) {
          var on = c.getAttribute("data-filter-contains") === contains;
          c.classList.toggle("on", on);
          c.setAttribute("aria-pressed", on ? "true" : "false");
        });
      }
      if (input) input.addEventListener("input", apply);
      chips.forEach(function (c) {
        c.addEventListener("click", function () {
          contains = c.getAttribute("data-filter-contains") === contains
            ? null : c.getAttribute("data-filter-contains");
          apply();
        });
      });
      apply();
    });
  })();
  // ---- rail + band: the highlight follows fragment AND scroll ----
  // "here" is stamped at build time per PAGE; the in-page sections are
  // anchors INTO the landing page, so clicking them never navigates and
  // the stamp stayed on Runs.  This module moves the highlight to the
  // rail entry whose destination is "index.html" + the current fragment
  // — click or deep link — and back to Runs when the fragment clears.
  // Exact-string href matching scopes it to the landing page: subpage
  // rails render "../index.html#..." and never match, nested
  // sub-entries carry whole-page hrefs (never a landing fragment), and
  // a fragment no rail entry owns (e.g. a bare #footnotes jump) leaves
  // the build stamp as is; adds the BAND SECTION INDICATOR (the
  // landing's crumbs slot reads the same state) and the SCROLL-SPY:
  // on the landing, the current section is the last whose top passed
  // the band — the highlight and the band indicator follow the ONE
  // state; scrolling never touches the URL and NEVER the trees (the
  // open state is the user's, round 2 — only the mark moves).
  (function () {
    // scope: SECTION toggles + their children only.  The run tree's
    // label anchors (class r-lab: marker toggles, label
    // navigates) are deliberately OUTSIDE this set — a label click
    // must never take the amber mark or move the accordion; it is a
    // plain navigation, and the section state rules alone.
    var links = document.querySelectorAll(
      ".rail .r-sec > a, .rail a.r-c");
    if (!links.length) return;
    function refreshAria() {
      document.querySelectorAll(".rail .r-sec").forEach(function (sec) {
        var a = sec.querySelector(":scope > a");
        if (a) a.setAttribute("aria-expanded",
          sec.classList.contains("open") ? "true" : "false");
      });
    }
    // the landing's band slot: "Catalog" + a script-built section
    // link. EVERY active section is named, Runs included —
    // the open accordion already declares the position (children
    // listed, toggle selected), and the indicator agrees with it;
    // the landing's opening state reads "Catalog › Runs"
    var ind = document.querySelector(
      '.topbar .crumbs[aria-label="Section"] .c-here');
    var indSep = null, indLink = null;
    if (ind) {
      indSep = document.createElement("span");
      indSep.className = "c-sep";
      indSep.textContent = "›";
      indSep.hidden = true;
      indLink = document.createElement("a");
      indLink.className = "c-sec";
      indLink.hidden = true;
      ind.after(indSep, indLink);
    }
    var BAND = { runs: ["Runs", "#top"],
                 comparisons: ["Comparisons", "#comparisons"],
                 switches: ["Switch index", "#switches"] };
    function refreshBand() {
      if (!indLink) return;
      var a = document.querySelector(".rail a.here");
      var sec = a && a.closest(".r-sec");
      var m = sec && BAND[sec.dataset.sec];
      if (m) {
        indLink.textContent = m[0];
        indLink.setAttribute("href", m[1]);
        indLink.hidden = false;
        indSep.hidden = false;
      } else {
        indLink.hidden = true;
        indSep.hidden = true;
      }
    }
    // the sub-page trail deepens with the active
    // anchored child.  The switch page's four rail children already
    // drive the child highlight and the body title (fragment AND
    // scroll) — the band trail reads the same ONE state:
    // while a child is here the page crumb yields its slot to the
    // SECTION crumb and the child names the place as the last crumb.
    // EVERY child deepens, the first one included — the open
    // accordion already declares the position, and the trail agrees
    // with it ("Catalog › Switch index › Switches indexed" at the
    // page top too; the two-level stand is retired). The
    // section crumb behaves like every section crumb — it takes the
    // LANDING's section anchor (read from the section toggle's own
    // href, so it stays correct anywhere the site lives); the
    // page-top jump is the rail child's job.  The deep crumbs are
    // script-built and CSS-hidden without the state, so every other
    // page (and scripts-off) renders the ruled static form
    var bnav = document.querySelector(
      '.topbar .crumbs[aria-label="Breadcrumb"]');
    var bHere = bnav && bnav.querySelector(".c-here");
    var bKids = document.querySelectorAll('.rail a.r-c[href^="#"]');
    var bSec = null;
    if (bnav && bHere && bKids.length) {
      var bTop = document.createElement("a");
      bTop.className = "c-top";
      var bSec0 = bKids[0].closest(".r-sec");
      var bTgl = bSec0 && bSec0.querySelector(":scope > a");
      bTop.href = bTgl ? bTgl.getAttribute("href") : "#top";
      bTop.textContent = bHere.textContent;
      var bSep = document.createElement("span");
      // rides the deep slot's own hidden-by-default class too — a
      // bare c-sep would paint a stray "›" beside nothing at rest
      bSep.className = "c-sep c-sec3";
      bSep.textContent = "›";
      bSec = document.createElement("span");
      bSec.className = "c-sec3";
      bnav.append(bTop, bSep, bSec);
    }
    function refreshTrail() {
      if (!bnav || !bSec) return;
      var here = document.querySelector(".rail a.here");
      var href = here && here.classList.contains("r-c")
               ? (here.getAttribute("href") || "") : "";
      if (href.match(/^#([a-z-]+)$/)) {
        bSec.textContent = here.textContent;
        bSec.title = here.textContent;
        bnav.classList.add("deep");
      } else {
        bnav.classList.remove("deep");
      }
    }
    // the current section's TITLE in the body takes the menu's
    // amber treatment — on the landing the section toggle names the
    // body section; on the switch page the current child names an
    // anchored section.  Other pages' links name no body section —
    // no highlight there (owner ruling)
    function refreshHi() {
      var here = document.querySelector(".rail a.here");
      var target = null;
      if (here) {
        var href = here.getAttribute("href") || "";
        if (here.classList.contains("r-c")) {
          var c = href.match(/^#([a-z-]+)$/);
          target = c && document.getElementById(
            c[1] === "top" ? "switches-indexed" : c[1]);
        } else {
          var k = href.match(/^index\\.html#(\\w+)$/);
          target = k && document.getElementById(
            k[1] === "top" ? "runs" : k[1]);
        }
      }
      document.querySelectorAll(".sec-hi").forEach(function (h) {
        h.classList.remove("sec-hi");
      });
      var h2 = target && target.querySelector("h2");
      if (h2) h2.classList.add("sec-hi");
    }
    function moveTo(target) {
      links.forEach(function (a) {
        var on = a === target;
        a.classList.toggle("here", on);
        if (on) a.setAttribute("aria-current", "location");
        else a.removeAttribute("aria-current");
      });
      refreshAria();
      refreshBand();
      refreshTrail();
      refreshHi();
    }
    // fragment-driven moves hold the scroll-spy briefly and
    // GUARD positionally: the click owns the state until the
    // user genuinely scrolls AWAY from where the click landed — the
    // first idle records the rest position, later idles release the
    // guard only past ~90px of displacement. Burst-counting (the
    // single skip) lost to engines whose descent steps over several
    // idle-separated bursts
    var holdUntil = 0, guard = null;
    function apply() {
      var want = "index.html" + (location.hash || "");
      var target = null;
      links.forEach(function (a) {
        if (a.getAttribute("href") === want) target = a;
      });
      if (target) {
        moveTo(target);
        // the section row navigated to OPENS its tree (additive —
        // nothing else moves; owner review of round 2: jumping to a
        // section and opening its list is one act)
        var usec = target.closest(".r-sec");
        if (usec) railStore.open(usec);
        holdUntil = Date.now() + 600;
        guard = { rest: null };
        document.documentElement.removeAttribute("data-frag");
        return;
      }
      if (location.hash) {
        // same-page fragment children (the switch page's section
        // anchors): the CHILD highlight follows the section in
        // view — the toggle keeps the section stamp, the two-level
        // pattern run pages already use; build stamps (aria-current
        // "page") are never stripped, only client moves
        var child = null;
        links.forEach(function (a) {
          if (a.getAttribute("href") === location.hash) child = a;
        });
        if (child) {
          links.forEach(function (a) {
            if (!a.classList.contains("r-c")) return;
            var on = a === child;
            a.classList.toggle("here", on);
            if (on) a.setAttribute("aria-current", "location");
            else a.removeAttribute("aria-current");
          });
          guard = { rest: null };
        } else {
          // a fragment no rail entry owns — the run tree's group-label
          // anchors (index.html#g-… into the inventory blocks)
          // and any bare jump.  The descent's own scroll burst must
          // not let the spy hand the section mark to whatever sits at
          // the midline when the target clamps near a section
          // boundary — the same positional guard the matched moves
          // get: the click owns the state until the user genuinely
          // scrolls away
          holdUntil = Date.now() + 600;
          guard = { rest: null };
        }
      }
      refreshAria();
      refreshBand();
      refreshTrail();
      refreshHi();
    }
    window.addEventListener("hashchange", apply);
    apply();
    // scroll-spy (landing only — subpage toggles are ../-prefixed and
    // never match; rAF-throttled, passive)
    // the spy watches BOTH section kinds — the landing's
    // toggles (index.html#… hrefs) and any same-page anchored
    // children (the switch page's four #… entries); on the switch
    // page the CHILD highlight and the body title follow the scroll
    var spies = [];
    document.querySelectorAll(".rail .r-sec > a").forEach(function (a) {
      var m = (a.getAttribute("href") || "").match(/^index\\.html#(\\w+)$/);
      var id = m && (m[1] === "top" ? "runs" : m[1]);
      var el = id && document.getElementById(id);
      if (el) spies.push({ el: el, a: a });
    });
    document.querySelectorAll(".rail a.r-c[href^='#']").forEach(
      function (a) {
        var id = (a.getAttribute("href") || "").slice(1);
        var el = document.getElementById(
          id === "top" ? "switches-indexed" : id);
        if (el) spies.push({ el: el, a: a });
      });
    if (spies.length) {
      // the spy acts only at scroll-IDLE (debounced past the last
      // scroll event) and SKIPS the first idle after any
      // fragment-driven move: the descent's own scroll burst must
      // not hand the state to whatever section the middle line sits
      // in when the click's target clamps near the page bottom
      // (metric-dependent theft); from the user's next burst
      // on, pure position rules
      var idleTimer = null;
      function spy() {
        var line = window.scrollY + Math.round(window.innerHeight / 2);
        var cur = spies[0];
        for (var i = 0; i < spies.length; i++)
          if (spies[i].el.offsetTop <= line) cur = spies[i];
        // the page EDGE belongs to the last section
        if (window.innerHeight + window.scrollY
            >= document.documentElement.scrollHeight - 40)
          cur = spies[spies.length - 1];
        if (cur && !cur.a.classList.contains("here")) moveTo(cur.a);
      }
      window.addEventListener("scroll", function () {
        if (idleTimer) clearTimeout(idleTimer);
        idleTimer = setTimeout(function () {
          if (Date.now() < holdUntil) return;
          if (guard) {
            if (guard.rest === null) { guard.rest = window.scrollY; return; }
            if (Math.abs(window.scrollY - guard.rest) < 90) return;
            guard = null;
          }
          spy();
        }, 300);
      }, { passive: true });
    }
  })();
  // ---- the narrow-window menu: the band burger, content first ----
  // the responsive-enough ruling (rework; stay-open model):
  // below the breakpoint the CSS turns the menu into the band
  // burger's dropdown panel (html.js agents only).  The menu is a
  // WORKING PANEL, matching the desktop rail it folds — clicking an
  // entry NEVER dismisses it (the band crumb above the panel names
  // the destination; a page navigation lands content-first with the
  // menu closed, which is arrival, not dismissal).  Dismissal is the
  // user's alone: the burger/X, Escape, or an outside click.  Scripts
  // off never runs this: the stacked full menu is the no-js fallback
  // and the burger stays hidden
  (function () {
    var rail = document.querySelector(".rail");
    var btn = document.querySelector(".burger");
    if (!rail || !btn) return;
    function setOpen(on) {
      rail.classList.toggle("menu-open", on);
      btn.setAttribute("aria-expanded", on ? "true" : "false");
    }
    btn.addEventListener("click", function (e) {
      e.stopPropagation();
      setOpen(!rail.classList.contains("menu-open"));
    });
    document.addEventListener("keydown", function (e) {
      if (e.key === "Escape") setOpen(false);
    });
    document.addEventListener("click", function (e) {
      if (!rail.contains(e.target) && !btn.contains(e.target))
        setOpen(false);
    });
  })();
});
"""

CSS = """
:root {
  color-scheme: light;
  /* Brand tokens sampled from iter.org stylesheet
     /themes/custom/intuitiv/assets/css/intuitiv.style.css (2026-09-26):
     ink navy #0f1632 (272x), ITER blue #2c6ecb (112x), plasma cyan
     #3ed9fd (29x), ITER amber #fdbb30 (209x).  All neutrals are tinted
     toward the navy hue — no raw grays.
     The Console: slim navy topbar (identity + the
     plasma rule as the one brand gesture), a sticky paper rail
     (sections + the run list), and a full-width canvas.  Two voices:
     the serif of the publication (names, verdicts, prose) over the
     mono of the instrument (identifiers, numerals, labels). */
  --hue: 262;
  --navy: #0f1632;
  --blue: #2c6ecb;
  --cyan: #3ed9fd;
  --amber: #fdbb30;
  --bronze: #9a6200;
  --bg: oklch(0.978 0.004 var(--hue));
  --bg-rail: color-mix(in oklch, var(--ink) 3.5%, var(--bg));
  --surface: #ffffff;
  --ink: oklch(0.235 0.028 var(--hue));
  --ink-soft: oklch(0.45 0.024 var(--hue));
  --ink-faint: oklch(0.58 0.019 var(--hue));
  --line: color-mix(in oklch, var(--ink) 13%, transparent);
  --line-strong: color-mix(in oklch, var(--ink) 42%, transparent);
  /* the askthedocs families lead; the former system stacks stay
     as the fallback chain (graceful glyph gaps outside the latin
     subsets, exactly as the docs face behaves). */
  --font-serif: "Source Serif 4", "Iowan Old Style", "Palatino Linotype",
                Palatino, Charter, Georgia, serif;
  --font-mono: "IBM Plex Mono", ui-monospace, "SF Mono", Menlo, Consolas,
               monospace;
  --font-sans: "Sora", -apple-system, "Segoe UI", Roboto, Helvetica,
               Arial, sans-serif;
  /* the askthedocs radius ladder, role-for-role — small =
     badges/chips/keys/marks, medium = controls, large = cards/figures/
     code blocks. */
  --r-1: 4px; --r-2: 8px; --r-3: 12px;
  --ease-out: cubic-bezier(0.2, 0.8, 0.2, 1);
  --h1: clamp(1.65rem, 1.15rem + 1.7vw, 2.35rem);
  --topbar-h: 58px;
  --rail-w: 248px;
}
@view-transition { navigation: auto; }
* { box-sizing: border-box; }
html { scroll-behavior: smooth; }
@media (prefers-reduced-motion: reduce) { html { scroll-behavior: auto; } }
body { margin: 0; font: 14px/1.6 var(--font-sans);
       background: var(--bg); color: var(--ink);
       -webkit-font-smoothing: antialiased;
       /* inherited text-level containment (the responsive-enough
          ruling): a machine token longer than its line (run names,
          family/member chips, deck paths in prose) breaks mid-token
          rather than pushing the page wide; fires only when no break
          opportunity exists — normal prose wraps as always.  Elements
          that must never wrap keep their own nowrap (chips, counts),
          which wins over this */
       overflow-wrap: break-word; }
::selection { background: var(--amber); color: var(--navy); }

/* ---- topbar: identity strip; the plasma rule is its bottom edge ---- */
.topbar { position: sticky; top: 0; z-index: 20; background: var(--navy); }
.tb-in { max-width: 1560px; margin: 0 auto; padding: 0 28px;
         min-height: var(--topbar-h); display: flex; align-items: center;
         justify-content: space-between; gap: 0; }
/* the brand occupies the RAIL's column width, so the crumb
   column starts at the CANVAS edge — the same x as the body's first
   text (the kicker); the 44px left margin completes the shell's
   column gap */
.brand { display: flex; align-items: baseline; gap: 14px;
         text-decoration: none; padding: 9px 0;
         flex: none; width: var(--rail-w); }
.brand:hover { text-decoration: none; }
.b-kick { font: 600 10.5px/1 var(--font-mono); letter-spacing: 0.16em;
          text-transform: uppercase; color: #8fa8dc; }
.b-name { font: 400 19px/1 var(--font-serif); color: #ffffff;
          letter-spacing: -0.01em; }
.brand:hover .b-name { color: var(--cyan); }
.tb-meta { font: 500 11.5px/1.5 var(--font-mono); color: #8fa8dc;
           letter-spacing: 0.02em; text-align: right;
           /* the counts are PINNED — one line, never shrunk,
              never wrapped; a long crumb trail yields, not these */
           flex: none; white-space: nowrap; }
.tb-meta b { color: #ffffff; font-weight: 600; }
.tb-meta .sep { color: #8fa8dc; margin: 0 8px; }
.plasma { height: 2px;
  background: linear-gradient(90deg, var(--blue), var(--cyan) 45%, var(--amber)); }

/* ---- shell: sticky rail + canvas ---- */
.shell { max-width: 1560px; margin: 0 auto; padding: 0 28px;
         display: grid; grid-template-columns: var(--rail-w) minmax(0, 1fr);
         gap: 0 44px; }
/* content-driven height: the block is exactly as tall
   as its items, capped at the viewport MINUS PERMANENT SLACK (40px
   beyond the offset) — an exact-fit cap still rides up a few px on
   some viewport metrics (two monitors, two trigger clicks); the
   slack makes the exhaustion zone unreachable on any resolution.
   The vertical rule ends where the content ends — accepted */
.rail { position: sticky; top: calc(var(--topbar-h) + 2px);
        height: auto;
        max-height: calc(100vh - var(--topbar-h) - 42px);
        overflow-y: auto; padding: 26px 24px 26px 0;
        border-right: 1px solid var(--line);
        font: 500 12px/1.5 var(--font-mono); }
.rail .r-h { font: 600 9.5px/1.4 var(--font-mono); letter-spacing: 0.14em;
             text-transform: uppercase; color: var(--ink-faint);
             margin: 18px 0 8px; }
.rail .r-h:first-child { margin-top: 0; }
/* the band's hamburger: dead at desktop (never shown) and
   dead without scripting (the stacked full menu renders instead);
   shown only by the <=1080px + html.js rules below */
.burger { display: none; }
.rail a { display: block; color: var(--ink-soft); text-decoration: none;
          font-weight: 500; /* chrome keeps its own voice under the
                               global 600 link treatment */
          /* the section rows are the LADDER'S ORIGIN (owner review
             2026-11-10 round 4: Runs must sit exactly one step LEFT
             of its groups): border 2 + 12px marker = text at 14 —
             the tree below steps 12 from THERE (26/38/50).  The
             tree rows and the section children override this
             padding-left with their own step */
          padding: 5px 10px 5px 0; border-left: 2px solid transparent;
          transition: color 0.15s var(--ease-out),
                      border-color 0.15s var(--ease-out),
                      background 0.15s var(--ease-out); }
.rail a:hover { color: var(--ink); text-decoration: none;
                background: color-mix(in oklch, var(--ink) 4%, transparent); }
.rail a.here { color: var(--ink); border-left-color: var(--amber);
               background: color-mix(in oklch, var(--amber) 8%, transparent); }
/* the rail's open state (owner review of C, round 2 — the exclusive
   accordion is RETIRED): sections open and close ONLY by the user's
   click, multiple sections may stand open together, and the state
   persists per browser tab; html.js (set by the head script before
   the body parses) closes everything at FIRST layout, then the
   DOMContentLoaded pass restores the tab's remembered opens and ADDS
   the page's own ancestry — a navigation never removes anything.
   Scripts off = no js class = the full expanded menu with hidden
   markers (the no-JS guarantee).
   grid-template-rows 0fr<->1fr animates open/close with no height
   measurement; the inner wrapper carries the overflow/min-height
   the trick needs, and layout containment keeps the per-frame cost
   inside the rail.  Markers ship in the bytes, glyph-swapped by the
   same state (+ closed, − open), hidden entirely without scripting.
   The OPEN state is the USER'S (owner review of C, round 2: trees
   never close but by a click — the amber mark and the scroll-spy
   move the HIGHLIGHT, never the tree): sections carry an .open
   class the script toggles and persists per browser tab; a section
   with nothing to open hides its marker and keeps the row's
   navigation.  Sub-links indent past the marker column */
.r-mark { display: none; }
html.js .r-mark { display: inline-block; width: 12px;
                  text-align: center; color: var(--ink-faint); }
html.js .r-sec.open .rm-c { display: none; }
html.js .r-sec:not(.open) .rm-o { display: none; }
html.js .r-sec:not(:has(.r-sub)) .r-mark { display: none; }
.r-sub { display: grid; grid-template-rows: 1fr;
         transition: grid-template-rows 0.28s var(--ease-out); }
html.js .r-sec:not(.open) > .r-sub { grid-template-rows: 0fr; }
/* a deep-linked fragment opens its section at FIRST LAYOUT — the
   build stamp (Runs) yields until the script moves the highlight;
   the attribute retires in the script's quiet arrival window so
   later moves rule */
html.js[data-frag] .r-sec > .r-sub { grid-template-rows: 0fr; }
html.js[data-frag="runs"] .r-sec[data-sec="runs"] > .r-sub,
html.js[data-frag="comparisons"] .r-sec[data-sec="comparisons"] > .r-sub,
html.js[data-frag="switches"] .r-sec[data-sec="switches"] > .r-sub
  { grid-template-rows: 1fr; }
.r-sub-in { overflow: hidden; min-height: 0; contain: layout;
            visibility: visible; transition: visibility 0s 0s; }
/* closed children leave the tab order + pointer targeting only AFTER
   the collapse finishes (visibility flips with the transition's own
   delay: instant on open, 0.28s on close) */
html.js .r-sec:not(.open) .r-sub-in { visibility: hidden;
                                      transition: visibility 0s 0.28s; }
/* the tree's own disclosure (owner round 5b: the group/family
   details animate EXACTLY like the sections): the wrapper carries
   the same 0fr<->1fr grid transition, the .d-open class drives the
   geometry on the script's timing (the [open] attribute stays the
   semantic state — close animates FIRST, then drops it), and without
   scripting the native details rules alone */
.d-sub { display: grid; grid-template-rows: 1fr;
         transition: grid-template-rows 0.28s var(--ease-out); }
html.js details:not(.d-open) > .d-sub { grid-template-rows: 0fr; }
.d-sub-in { overflow: hidden; min-height: 0; contain: layout; }
html.js details:not(.d-open) > .d-sub .d-sub-in { visibility: hidden; }
/* ARRIVALS ARE QUIET (owner round 6): the load-time opens — the
   per-tab store's apply, the page's own here-ancestry, the fragment
   stamp's handoff — commit WITHOUT the 0.28s disclosure animation:
   the tree lands open where the user left it instead of replaying a
   close-then-reopen on every navigation (the animation belongs to
   the user's own acts).  The class rides <html> for one synchronous
   window around those opens; see the script's arrival block */
html.no-anim .rail .r-sub, html.no-anim .rail .d-sub { transition: none; }
.r-sub-in a { padding: 4px 10px 4px 24px; font-size: 11.5px;
              white-space: nowrap; overflow: hidden;
              text-overflow: ellipsis; }
             /* section children (comparison pairs, switch groups)
                share the GROUP column: one level under a section =
                origin 26, the same step the run tree takes */
/* the run tree (the ruled navigation shape): groups > families >
   runs under the Runs toggle, shipped CLOSED with count-bearing
   labels.  ONE LADDER, uniform 12px steps from the section level
   down (owner review 2026-11-10 round 4: the section row sits at
   origin 14, so Runs is exactly one step LEFT of Example runs):
   sections 14 / groups 26 / families 38 / leaf dots 50 — the
   disclosure marker is a fixed-width inline-block, so the leaf
   step (no marker) is exact at any zoom; family blocks carry the
   faint guide line down their leaves; every name is one line,
   ellipsized, full name on hover (the page bytes always carry it
   — find and copy still work).
   MARKER TOGGLES, LABEL NAVIGATES: the group label is an anchor
   inside the summary — a click follows it (native activation
   behavior, no script), a click on the marker or the row's own
   ground toggles the disclosure.  The count rides BESIDE the
   label (never floating at the rail's far edge) but YIELDS FIRST
   (owner review 2026-11-10: a count must never cost the folder
   its name): the summary wraps, the count drops to its own line
   under the name, and only a name that ALONE cannot hold the
   rail ellipsizes — the count itself never truncates */
.r-sub-in .r-grp > summary,
.r-sub-in .r-fam > summary { display: flex; flex-wrap: wrap;
  align-items: baseline; cursor: pointer;
  font-size: 11.5px; line-height: 1.5; padding: 4px 10px 4px 0;
  list-style: none; }
.r-sub-in summary::-webkit-details-marker { display: none; }
.r-sub-in summary::before { content: "+"; display: inline-block;
  flex: none; width: 12px; color: var(--ink-faint); }
.r-sub-in details[open] > summary::before { content: "\\2212"; }
.r-sub-in .s-lab, .r-sub-in a.r-lab { flex: 0 1 auto; min-width: 0;
  white-space: nowrap; overflow: hidden; text-overflow: ellipsis; }
.r-sub-in a.r-lab { color: inherit; text-decoration: none;
  /* the section-children padding (24px) must NOT ride the group
     label — the group's step comes from its summary's own padding
     (origin 26).  The anchor chrome's 2px here-border is stripped
     too: labels never carry the amber bar (deliberately outside
     the highlight machinery), and with it the group's text would
     sit 2px deep of its column */
  padding: 0; border-left: none; }
.r-sub-in a.r-lab:hover { color: var(--ink); text-decoration: underline; }
/* the group/family label's here state (its own page is the page):
   the UNDERLINE voice — the amber here-bar rides the anchor chrome's
   left border, which the label anchors deliberately strip (the
   ladder's geometry rules), so the bar would break the step rhythm */
.r-sub-in a.r-lab.here { color: var(--ink);
  text-decoration: underline; text-underline-offset: 3px; }
.r-sub-in .s-cnt { flex: none; margin-left: 6px;
  font: 500 10px/1.5 var(--font-mono);
  color: var(--ink-faint); letter-spacing: 0.02em; }
.r-sub-in .r-grp > summary { font-weight: 600; color: var(--ink);
  padding-left: 14px; }   /* + the 12px marker = group text at 26 */
.r-sub-in .r-fam { margin-left: 25px;   /* + the 1px guide border = 26:
  family text at 38, leaf dots at 50 — the ladder's lower steps */
  border-left: 1px dotted var(--line); }
.r-sub-in .r-fam > summary { font-weight: 500; color: var(--ink-soft);
  padding-left: 0; }
/* the leaf keeps the anchor chrome's 2px border (it IS the amber
   here-bar's carrier on the active run) — 22px padding + 2px border
   puts the dot at origin 50, the ladder's fourth step */
.r-sub-in .r-fam a.r-run { padding-left: 22px; }
/* the body's section title takes the menu's amber treatment:
   same marker + tint voice, the band hugging the title's own width
   (this restores the original look — the owner preferred it over
    the full-width band); the bar grows into the gutter and the
   vertical padding is margin-compensated, so the title's text never
   shifts and the page never reflows when the highlight moves */
h2.sec-hi { border-left: 3px solid var(--amber);
            background: color-mix(in oklch, var(--amber) 8%, transparent);
            padding: 5px 12px; margin: 39px 0 9px -15px;
            width: fit-content;
            border-radius: 0 var(--r-1) var(--r-1) 0;
            transition: background 0.2s var(--ease-out); }
/* breadcrumbs: the trail lives IN the sticky band —
   brand | crumbs | counts — visible at every scroll.  The last crumb
   is the FLEX POINT: it ellipsizes (full name on hover) before the
   trail can crowd the counts; the landing's slot carries the section
   indicator instead (script-managed: Catalog › section, scroll-spy) */
.crumbs { display: flex; align-items: center; flex: 1 1 auto;
          min-width: 0; white-space: nowrap; margin: 0 24px 0 44px;
          font: 500 10.5px/1.4 var(--font-mono);
          letter-spacing: 0.02em; }
.crumbs a, .crumbs .c-here { color: #8fa8dc; }
.crumbs a { flex: none; }
.crumbs a:hover { color: #ffffff; text-decoration: none; }
.crumbs .c-sep { flex: none; color: #8fa8dc; margin: 0 7px; }
.crumbs .c-here { flex: 0 1 auto; min-width: 0;
                  overflow: hidden; text-overflow: ellipsis; }
/* the deep trail — while an anchored child (the switch page's
   sections) is the rail's here, the page crumb yields its slot to a
   working #top link and the section crumb names the place, taking
   over the flex point (ancestors never truncate). Hidden
   without the state; phone width keeps the page-crumb-only band the
   ≤720 rules already paint (ancestors hide there — a deep trail with
   dead links would be noise) */
.crumbs .c-top, .crumbs .c-sec3 { display: none; }
/* the section crumb carries the page crumb's own tint — an unclassed
   span inherits the band's ink and vanishes into the navy */
.crumbs .c-sec3 { color: #8fa8dc; flex: 0 1 auto; min-width: 0;
                  overflow: hidden; text-overflow: ellipsis; }
@media (min-width: 721px) {
  .crumbs.deep .c-top, .crumbs.deep .c-sec3 { display: block; }
  .crumbs.deep .c-here { display: none; }
}
/* the verdict dot — one base rule, used in the rail leaves AND the
   landing legend (the legend names the palette the rail paints with;
   same glyph, same size, one meaning) */
.rdot { display: inline-block; width: 7px; height: 7px;
        border-radius: 50%; vertical-align: 0.5px; }
.rail a .rdot { margin-right: 7px; }
.rail .r-run { white-space: nowrap; overflow: hidden;
               text-overflow: ellipsis; }
.rail-foot { margin-top: 20px; padding-top: 12px;
             border-top: 1px solid var(--line);
             color: var(--ink-faint); font-size: 10.5px;
             letter-spacing: 0.04em; }

/* ---- canvas ---- */
.canvas { padding: 34px 0 80px; min-width: 0; }
.kicker { font: 600 10.5px/1.4 var(--font-mono); letter-spacing: 0.16em;
          text-transform: uppercase; color: var(--blue); margin: 0 0 10px; }
h1 { font: 400 var(--h1)/1.12 var(--font-serif); color: var(--ink);
     margin: 0 0 8px; letter-spacing: -0.01em; text-wrap: balance; }
p.meta { font: 500 12px/1.9 var(--font-mono); color: var(--ink-soft);
         letter-spacing: 0.01em; max-width: 80ch; margin: 0 0 6px; }
p.sub { font-family: var(--font-serif); font-size: 15px; line-height: 1.65;
        color: var(--ink-soft); margin: 0 0 18px; max-width: 78ch;
        text-wrap: pretty; }
/* the global rule (superseding the run-links-only carve-out): EVERY link
   carries the one identity treatment — ink + semibold, blue on hover.
   The runs table's run-name look, promoted to the base rule; nav
   chrome pins its own weights/colors where needed. */
a { color: var(--ink); font-weight: 600; text-decoration: none;
    transition: color 0.15s var(--ease-out); }
a:hover { color: var(--blue); text-decoration: none; }
a:focus-visible, summary:focus-visible, button:focus-visible,
input:focus-visible { outline: 2px solid var(--blue); outline-offset: 2px; }
.mono { font-family: var(--font-mono); font-size: 12px; }

h2 { font: 600 11px/1.4 var(--font-mono); letter-spacing: 0.14em;
     color: var(--ink-soft); text-transform: uppercase; margin: 44px 0 14px;
     padding-bottom: 8px; border-bottom: 1px solid var(--line-strong);
     display: flex; align-items: baseline; gap: 12px; }
/* the scroll offset must sit on the ANCHOR TARGET — the section
   (or row/footer) carrying the id — not on the heading inside it;
   on the heading it never fires, and the target lands flush under
   the sticky topbar with its title eaten. */
section[id], tr[id], footer[id] {
  scroll-margin-top: calc(var(--topbar-h) + 16px); }
/* #top (the pagehead) is the Runs destination: a tighter stop
   — the title area right under the band, not a section stop */
#top { scroll-margin-top: calc(var(--topbar-h) + 4px); }
h2 .sn { font-size: 13px; color: var(--bronze); letter-spacing: 0.06em; }
/* scroll-driven section reveal (Baseline CSS, zero JS); static where
   unsupported and under reduced motion */
section.rise { animation: rise both; animation-timeline: view();
               animation-range: entry 0% entry 55%; }
@keyframes rise { from { opacity: 0; translate: 0 14px; } }

/* ---- toolbar: the filter/search strip (progressive enhancement) ---- */
.toolbar { display: flex; flex-wrap: wrap; align-items: center; gap: 10px;
           margin: 4px 0 14px; }
.toolbar input[type="search"] {
  font: 500 12.5px/1.4 var(--font-mono); color: var(--ink);
  background: var(--surface); border: 1px solid var(--line-strong);
  border-radius: var(--r-2); padding: 8px 12px; min-width: 300px; flex: 0 1 340px; }
.toolbar input[type="search"]::placeholder { color: var(--ink-faint); }
.fchip { font: 600 10.5px/1.4 var(--font-mono); letter-spacing: 0.03em;
         color: var(--ink-soft); background: var(--surface);
         border: 1px solid var(--line-strong); border-radius: var(--r-1);
         padding: 6px 11px; cursor: pointer;
         /* the paint properties only — 'all' would animate the focus
            ring in from nothing (a keyboard user must see it at once) */
         transition: color 0.15s var(--ease-out),
                     background-color 0.15s var(--ease-out),
                     border-color 0.15s var(--ease-out); }
.fchip:hover { color: var(--ink); border-color: var(--ink-soft); }
/* an ACTIVE chip paints itself in the color of the thing it
   filters (--fbg/--fik declared per chip from the badge palette);
   chips without a tint keep the neutral navy .on.  The stroke
   derives from the ink, the badge rule. */
.fchip.on { background: var(--fbg, var(--navy));
            color: var(--fik, #ffffff);
            border-color: color-mix(in oklch, var(--fik, var(--navy))
                                    55%, transparent); }
.fcount { font: 500 11px/1.4 var(--font-mono); color: var(--ink-faint);
          margin-left: auto; }

/* ---- verdict distribution strip (a labeled meter over real counts) ---- */
.dist { display: flex; gap: 2px; margin: 2px 0 16px; max-width: 720px; }
.dist .dseg { font: 600 10px/1 var(--font-mono); letter-spacing: 0.02em;
              padding: 6px 8px; white-space: nowrap; overflow: hidden;
              text-overflow: ellipsis; border-radius: var(--r-1);
              min-width: 8px; }

/* ---- tables: the instrument, full canvas width ---- */
/* Contained at EVERY width (the responsive-enough ruling): an over-wide
   table scrolls inside its own box — the PAGE never scrolls sideways,
   not even at desktop (the runs table's ~1184px content only fits the
   canvas above ~1544px, so laptops and projectors scrolled the whole
   page before this).  The trade: sticky headers cannot survive
   containment (sticky tracks one scroll container; a horizontally
   scrollable box swallows the vertical stick) — the header scrolls
   with its table, the price of never losing the page. */
table { border-collapse: collapse; width: 100%; font-size: 13px;
        margin: 4px 0 26px; display: block; overflow-x: auto; }
/* the AFFORDANCE (the containment's missing half): a thin, quiet,
   ALWAYS-VISIBLE scrollbar on every contained surface — a cropped
   column with no signal reads as broken content, not scrollable
   content (owner-reported at 1024px: "the table is cropped and no
   horizontal scrollbar appears").  TWO MECHANISMS, STRICTLY
   SEPARATED — setting the standard scrollbar-width/color on the
   same element CANCELS the webkit pseudo styling in Chromium 121+
   and keeps macOS's auto-hiding overlay (the bug: the thumb
   ghosted after any scroll and the crop read as broken again).
   Chromium + Safari: the bare pseudos below force CLASSIC
   (non-overlay) scrollbars — the thumb permanently painted whenever
   there is something to scroll, absent when the content fits.
   Firefox: the standard pair, gated behind @supports so no
   Chromium parse ever sees it.  Thumb-only on a transparent track:
   fitting tables grow no empty rail */
@supports not selector(::-webkit-scrollbar) {
  table, .unset-names, pre.mono, .rail-body {
    scrollbar-width: thin;
    scrollbar-color: color-mix(in oklch, var(--ink) 45%, transparent)
                     transparent;
  }
}
table::-webkit-scrollbar, .unset-names::-webkit-scrollbar,
pre.mono::-webkit-scrollbar, .rail-body::-webkit-scrollbar {
  height: 8px; width: 8px; -webkit-appearance: none;
}
table::-webkit-scrollbar-track, .unset-names::-webkit-scrollbar-track,
pre.mono::-webkit-scrollbar-track, .rail-body::-webkit-scrollbar-track {
  background: transparent;
}
table::-webkit-scrollbar-thumb, .unset-names::-webkit-scrollbar-thumb,
pre.mono::-webkit-scrollbar-thumb, .rail-body::-webkit-scrollbar-thumb {
  background: color-mix(in oklch, var(--ink) 45%, transparent);
  border-radius: 4px;
}
table::-webkit-scrollbar-thumb:hover, .unset-names::-webkit-scrollbar-thumb:hover,
pre.mono::-webkit-scrollbar-thumb:hover, .rail-body::-webkit-scrollbar-thumb:hover {
  background: color-mix(in oklch, var(--ink) 62%, transparent);
}
th, td { text-align: left; padding: 10px 18px 10px 0;
         border-bottom: 1px solid var(--line); vertical-align: top; }
thead th { font: 600 10.5px/1.4 var(--font-mono); letter-spacing: 0.1em;
           text-transform: uppercase; color: var(--ink-soft);
           white-space: nowrap; padding-top: 0;
           border-bottom: 1px solid var(--line-strong);
           background: var(--bg); }
th.sort-key { cursor: pointer; user-select: none; }
th.sort-key:hover { color: var(--ink); }
th.sort-key[aria-sort]::after { content: "\\2191"; color: var(--bronze);
                                margin-left: 6px; }
th.sort-key[aria-sort="descending"]::after { content: "\\2193"; }
tbody tr { transition: background 0.15s var(--ease-out); }
tbody tr:hover { background: color-mix(in oklch, var(--ink) 2.5%, transparent); }
tr:last-child td { border-bottom: none; }
td.num, th.num { text-align: right; font-variant-numeric: tabular-nums; }
.kv { margin-bottom: 20px; }
.kv th { font: 600 10.5px/1.5 var(--font-mono); letter-spacing: 0.08em;
         text-transform: uppercase; color: var(--ink-faint);
         width: 170px; padding-right: 18px; }
/* the runs ledger: each run is ONE row; the first cell carries the
   strong identity line (name) over the quiet context line (machine) */
td.run-id { padding-top: 12px; padding-bottom: 12px; }
.runname { font: 600 13.5px/1.45 var(--font-mono); letter-spacing: -0.01em;
           display: block; white-space: nowrap; overflow: hidden;
           text-overflow: ellipsis; max-width: 60ch; }
.runctx { display: block; font: 500 11px/1.6 var(--font-mono);
          color: var(--ink-faint); margin-top: 3px;
          letter-spacing: 0.02em; text-transform: uppercase; }
/* the landing's runs section : the INVENTORY — one block per
   group (header with its source named — the examples carry their
   fixed caption).  The block's payload is the STAT ROW (owner
   review 2026-11-10: the counts were fine print; the numbers are
   the inventory's headline): families + runs as large serif
   numerals with small mono labels, the verdict badges baseline-
   right, a compact verdict bar in the legend's own dot palette
   (the global meter's language at group scale — counts ride the
   badges, color never alone), and the analysis fingerprint as the
   quiet provenance line.  The per-family tables live on the group
   pages (checkpoint B) — the fam-h/table rules stay for that
   return */
.run-grp { margin: 30px 0 0; }
/* the type voices (owner review of C, round 4): NAMES carry the
   serif voice (the h1's own — group labels are names, not UI chrome),
   LABELS carry the mono voice (the h2's, a step down), PROSE the
   serif of p.sub.  The sans stays the body/UI voice alone. */
.run-grp h3.grp-h { font: 600 16px/1.35 var(--font-serif);
                    color: var(--ink); margin: 0 0 4px;
                    border-bottom: 2px solid var(--ink);
                    padding-bottom: 5px; letter-spacing: -0.005em; }
.run-grp .grp-src { font: 500 11px/1.4 var(--font-mono);
                    color: var(--ink-faint); font-weight: 400;
                    letter-spacing: 0.01em; }
.run-grp table.runs { margin-top: 0; }
/* the group page's family blocks (checkpoint B): the family NAME in
   the serif voice over its quiet count and verdict chips */
.fam-blk { margin: 30px 0 0; }
.fam-blk h3.fam-h { font: 600 15px/1.4 var(--font-serif);
                    color: var(--ink); margin: 0 0 8px;
                    border-bottom: 1px solid var(--line-strong);
                    padding-bottom: 5px; letter-spacing: -0.005em; }
.fam-blk .fam-h .s-cnt { color: var(--ink-soft); font-weight: 400; }
/* sub-section LABELS — the h2's mono voice a step down (labels, not
   names: never serif) */
h3.rec-h { font: 600 11px/1.4 var(--font-mono); letter-spacing: 0.12em;
           text-transform: uppercase; color: var(--ink-soft);
           margin: 22px 0 10px; }
.sick-grps h3.grp-h { font: 600 11px/1.4 var(--font-mono);
                      letter-spacing: 0.12em; text-transform: uppercase;
                      color: var(--ink-soft);
                      border-bottom: 1px dashed var(--line-strong);
                      padding-bottom: 6px; }
.grp-stats { display: flex; align-items: baseline; flex-wrap: wrap;
             column-gap: 26px; row-gap: 6px; margin: 12px 0 0; }
.grp-stats .stat { display: inline-flex; align-items: baseline;
                   white-space: nowrap; }
.grp-stats .stat .n { font: 600 30px/1 var(--font-serif);
                      color: var(--ink); letter-spacing: -0.01em; }
.grp-stats .stat .l { font: 600 10px/1 var(--font-mono);
                      letter-spacing: 0.14em; text-transform: uppercase;
                      color: var(--ink-faint); margin-left: 7px; }
.grp-stats .grp-verd { margin-left: auto; font-size: 12px;
                       color: var(--ink-soft); }
.grp-stats .grp-verd .badge { margin-left: 2px; }
.grp-dist { display: flex; gap: 2px; height: 6px; max-width: 720px;
            margin: 9px 0 0; border-radius: 2px; overflow: hidden; }
p.grp-fp { margin: 7px 0 0; font: 500 10.5px/1.6 var(--font-mono);
           color: var(--ink-faint); letter-spacing: 0.02em; }
/* the sick-group rows — first-class : one line per group the
   build could not catalog, its reason and remedy on the page, for
   the user who did not read the CLI output */
.sick-grps { margin: 26px 0 0; }
.sick-grps p.ncat { margin: 10px 0 0; }
p.ncat { margin: 18px 0 0; padding: 8px 12px;
         border-left: 3px solid var(--amber);
         background: color-mix(in oklch, var(--amber) 6%, transparent);
         color: var(--ink-soft); font-family: var(--font-serif);
         font-size: 14px; line-height: 1.6; }
/* the empty-state teacher — rendered ONLY while zero user groups
   stand; the moment a real group exists the landing is the plain
   inventory.  Quiet: one hairline panel, the two commands, no paths;
   the PROSE voice (serif, p.sub's own treatment) */
.teacher { margin: 26px 0 0; padding: 14px 16px;
           border: 1px dashed var(--line-strong);
           border-radius: var(--r-1); color: var(--ink-soft); }
.teacher p { font-family: var(--font-serif); font-size: 15px;
             line-height: 1.65; }
/* bold inside serif prose rides the REAL semibold face (the audit's
   rule: no synthesized weights, ever — the vendored 600s make every
   b and every semibold anchor a true face in all three voices) */
.sub b, .teacher b { color: var(--ink); font-weight: 600; }
/* the verdict-dot legend — the rail dots' palette named once on the
   landing, right under the distribution meter that shares it */
p.vlegend { margin: 8px 0 0; font: 500 11px/1.8 var(--font-mono);
            color: var(--ink-soft); letter-spacing: 0.02em; }
p.vlegend .rdot { margin: 0 5px 0 12px; }
p.vlegend .rdot:first-child { margin-left: 0; }
/* the user-seat build moment (the determinism rule): a wall
   clock rides ONLY a build that carries user groups, handed down by
   the CLI — proven bytes never see it */
p.built-at { margin: 14px 0 0; font: 500 11px/1.6 var(--font-mono);
             color: var(--ink-faint); letter-spacing: 0.02em; }
ul.skips { margin: 0 0 20px; padding-left: 20px; color: var(--ink-soft);
           font-size: 13px; }
ul.skips li { margin: 4px 0; }
ul.skips li::marker { color: var(--bronze); }
/* the documented-but-unset block — collapsed by default (the
   ledger above stays the page's business); the names render dense,
   multi-column, inventory order. the summary is a CONTROL —
   the chip button language (border, surface, hover lift), with an
   explicit direction marker that flips when open; tiny quiet text
   read as a label and got missed. */
details.unset { margin: 6px 0 20px; }
details.unset summary {
  display: inline-block; cursor: pointer;
  font: 600 12px/1.4 var(--font-mono); letter-spacing: 0.04em;
  color: var(--ink-soft); background: var(--surface);
  border: 1px solid var(--line-strong); border-radius: var(--r-1);
  padding: 8px 14px; list-style: none;
  transition: all 0.15s var(--ease-out); }
details.unset summary::after { content: "  ▾"; color: var(--ink-faint); }
details.unset[open] summary::after { content: "  ▴"; }
details.unset summary:hover {
  color: var(--ink); border-color: var(--ink-soft);
  background: color-mix(in oklch, var(--ink) 4%, var(--surface)); }
details.unset summary:hover::after { color: var(--ink); }
/* contained like the tables (same ruling): an over-long nowrap name
   scrolls inside the block, never the page */
.unset-names { overflow-x: auto; margin: 10px 0 0;
               columns: 240px 4; column-gap: 28px;
               font-size: 11.5px; line-height: 2.1; }
.unset-names .mono { white-space: nowrap; }

.badge { display: inline-block; padding: 2px 8px; border-radius: var(--r-1);
         font: 600 10.5px/1.5 var(--font-mono); letter-spacing: 0.03em;
         white-space: nowrap;
         border: 1px solid color-mix(in oklch, currentColor 32%, transparent); }
.badge::before { content: ""; display: inline-block; width: 6px; height: 6px;
                 border-radius: 50%; margin-right: 6px; vertical-align: 1px;
                 background: currentColor; }
figure { margin: 18px 0; }
figure img { max-width: 100%; border: 1px solid var(--line);
             border-radius: var(--r-3);
             background: var(--surface); }
figcaption { font: italic 400 12.5px/1.5 var(--font-serif);
             color: var(--ink-soft); margin-top: 7px; max-width: 72ch; }

/* ---- triage: the verdict callout rides the canvas top (Layer 0) ---- */
.verdict { margin: 14px 0 4px; padding: 12px 20px;
           font: italic 400 17px/1.55 var(--font-serif); color: var(--ink);
           background: color-mix(in oklch, var(--amber) 7%, transparent);
           border-left: 3px solid var(--bronze); }
.chips { margin: 10px 0 0; }
.chips .badge { margin-right: 6px; }
.card { background: var(--surface); border: 1px solid var(--line);
        border-radius: var(--r-3); padding: 18px 20px 16px; margin: 16px 0; }
.card > h3 { margin: 0 0 10px; font: 600 13.5px/1.4 var(--font-mono);
             letter-spacing: -0.01em; }
.card > h4 { margin: 16px 0 8px; }
details.audit { border-top: 1px solid var(--line); margin: 0; }
details.audit > summary { cursor: pointer; padding: 13px 2px;
                          font: 600 11px/1.4 var(--font-mono);
                          letter-spacing: 0.12em; text-transform: uppercase;
                          color: var(--ink-soft); list-style: none;
                          display: flex; gap: 10px; align-items: baseline; }
details.audit > summary::before { content: "+"; color: var(--bronze);
                                  font-weight: 700; font-size: 13px; }
details.audit[open] > summary::before { content: "\\2013"; }
details.audit[open] > summary { color: var(--ink);
                                border-bottom: 1px solid var(--line); }
details.audit > .pad { padding: 14px 2px 18px; }
details.case { border-top: 1px solid var(--line); margin: 0; }
details.case > summary { cursor: pointer; padding: 10px 2px;
                         font: 600 12px/1.4 var(--font-mono);
                         list-style: none; display: flex; gap: 10px;
                         align-items: baseline; }
details.case > summary::before { content: "+"; color: var(--bronze);
                                 font-weight: 700; }
details.case[open] > summary::before { content: "\\2013"; }
summary::-webkit-details-marker { display: none; }
details.case > .pad, details.case > div { padding: 4px 2px 14px; }

/* ---- the dossier (run pages): document flow + sticky fact sheet ---- */
.dossier { display: grid; grid-template-columns: minmax(0, 1fr) 292px;
           gap: 0 48px; }
.factsheet { position: sticky; top: calc(var(--topbar-h) + 26px);
             align-self: start; padding: 18px 0 24px;
             border-top: 2px solid var(--navy); }
.factsheet h2 { margin-top: 20px; }
.factsheet .kv { margin-bottom: 12px; }

.spark polyline { fill: none; stroke: var(--ink-soft); stroke-width: 1;
                  stroke-linejoin: round; stroke-linecap: round; }
td.sparkcell { min-width: 128px; }
.ddef { font-size: 12px; }
.ddef-val { font-family: var(--font-mono); }
.ddef-mute { color: var(--ink-soft); }
.ddef-prose { color: var(--ink-soft); font-style: italic;
              font-family: var(--font-serif); font-size: 12.5px; }
pre.mono { overflow-x: auto; background: var(--navy); color: #c9d4e8;
           border-radius: var(--r-3); padding: 16px 18px; margin: 8px 0 6px;
           font-size: 12px; line-height: 1.6; }
footer { font: italic 400 12.5px/1.65 var(--font-serif);
         color: var(--ink-soft); margin-top: 56px;
         border-top: 1px solid var(--line-strong); padding-top: 14px; }
footer p { margin: 0 0 6px; }
footer p:last-child { margin: 0; }
.fnmark { color: var(--ink-soft); }
a.fn { color: inherit; text-decoration: none; font-size: 9px;
       vertical-align: super; line-height: 0; margin-left: 1px; }
a.fn:hover { color: var(--blue); text-decoration: underline; }

/* the switch-index ledger (its rows carry citation anchors — the only
   .switches table with tr[id]): fixed two-column split, wrap header */
table.switches:has(tbody tr[id]) { table-layout: fixed; }
table.switches:has(tbody tr[id]) thead th { white-space: normal; }
table.switches:has(tbody tr[id]) th:first-child { width: 31%; }
table.switches:has(tbody tr[id]) td { padding-right: 14px; }

@media (max-width: 1080px) {
  /* the band's column alignment is meaningless stacked —
     crumbs flow next to the brand again */
  .brand { width: auto; }
  .crumbs { margin-left: 24px; }
  .shell { grid-template-columns: minmax(0, 1fr); }
  .dossier { grid-template-columns: minmax(0, 1fr); }
  .factsheet { position: static; border-top: 2px solid var(--navy); }
  .tb-meta { display: none; }
  /* scripts off (or any non-js agent): the FULL menu stacks above the
     canvas — rule holds verbatim (headers, sections with their
     sub-entries, the run list and the foot all rendered, nothing
     hidden, no internal scroll, the page flows on) */
  .rail { max-height: none; position: static; height: auto;
          overflow: visible; border-right: none;
          border-bottom: 1px solid var(--line); padding: 14px 0 12px; }
  /* with scripting: content comes first — the menu is the band
     burger's dropdown (amending the stacked-always clause
     for js agents): a hamburger at the band's right end (the counts
     slot, hidden at these widths), the menu drops as a panel FIXED
     under the band — an overlay, so content never reflows and begins
     immediately under the band.  The panel is opaque, capped at the
     viewport (internal scroll only when it would otherwise clip).
     STAY-OPEN MODEL: a working panel like the desktop rail —
     menu choices never dismiss it (the band crumb above names the
     destination); dismissal is the user's alone: the burger/X,
     Escape, or an outside click */
  html.js .burger {
    display: inline-flex; align-items: center; justify-content: center;
    width: 44px; align-self: stretch; flex: none; margin-left: 12px;
    background: none; border: none; padding: 0; cursor: pointer;
  }
  html.js .burger-box { display: inline-flex; flex-direction: column;
                        gap: 4px; }
  html.js .burger-line { width: 16px; height: 2px; border-radius: 1px;
                         background: #8fa8dc;
                         transition: transform 0.15s var(--ease-out),
                                     background 0.15s var(--ease-out),
                                     opacity 0.15s var(--ease-out); }
  html.js .burger:hover .burger-line,
  html.js .burger:focus-visible .burger-line { background: #ffffff; }
  /* the open state morphs the three lines into an X (the standard
     hamburger grammar; transform-only, no layout) */
  html.js .burger[aria-expanded="true"] .burger-line { background: #ffffff; }
  html.js .burger[aria-expanded="true"] .burger-line:nth-child(1) {
    transform: translateY(6px) rotate(45deg); }
  html.js .burger[aria-expanded="true"] .burger-line:nth-child(2) {
    opacity: 0; }
  html.js .burger[aria-expanded="true"] .burger-line:nth-child(3) {
    transform: translateY(-6px) rotate(-45deg); }
  /* the panel: fixed under the band, full width, overlaying content
     (z below the band's 20, above the page) */
  html.js .rail {
    position: fixed; top: calc(var(--topbar-h) + 2px);
    right: 0; left: 0; z-index: 19; background: var(--bg);
    border-bottom: 1px solid var(--line-strong);
    box-shadow: 0 14px 30px color-mix(in oklch, var(--ink) 14%,
                                      transparent);
    margin: 0; padding: 0 28px 6px; max-height: none; height: auto;
    overflow: visible; border-right: none; display: none;
  }
  html.js .rail.menu-open { display: block; }
  html.js .rail-body {
    display: block; padding: 4px 0 10px;
    max-height: calc(100vh - var(--topbar-h) - 24px);
    overflow-y: auto;
  }
}
@media (max-width: 720px) {
  .shell, .tb-in { padding-left: 18px; padding-right: 18px; }
  /* the burger panel's side padding follows the shell's narrow
     gutter (28px above) so the menu aligns with the content */
  html.js .rail { padding-left: 18px; padding-right: 18px; }
  /* the trail yields: ancestors never truncate by design, so at
     phone width they hide instead — the current-page crumb (the flex
     point, ellipsizing) is what names the page; the hidden links live
     on in the rail and the landing */
  .crumbs a, .crumbs .c-sep { display: none; }
  .crumbs { margin-left: 18px; }
  .kv th { width: 130px; }
  .toolbar input[type="search"] { min-width: 0; flex: 1 1 100%; }
}
@media print {
  .topbar { position: static; background: #ffffff; }
  .b-kick, .tb-meta { color: #444444; }
  .b-name { color: #000000; }
  .rail { display: none; }
  .shell { grid-template-columns: minmax(0, 1fr); padding: 0; }
  .factsheet { position: static; }
  tbody tr:hover { background: none; }
  section.rise { animation: none; }
}
@media (prefers-reduced-motion: reduce) {
  @view-transition { navigation: none; }
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    transition-duration: 0.01ms !important;
    scroll-behavior: auto !important; }
  section.rise { animation: none; }
}
"""


def chip(status: str, count: int) -> str:
    """A ledger chip: the STATUS palette + the recorded count in the
    text (identity never rides color alone — the same badge rule)."""
    bg, fg = BADGES.get(status, ("#eef0f4", "#57606a"))
    text = f"{status} {count}" if count else status
    return (f'<span class="badge" style="background:{bg};color:{fg}">'
            f"{html.escape(text)}</span>")


def badge(verdict: str | None) -> str:
    v = verdict or "—"
    bg, fg = BADGES.get(verdict, BADGES_FALLBACK)
    return f'<span class="badge" style="background:{bg};color:{fg}">{html.escape(v)}</span>'


def url(path: str) -> str:
    """Percent-encode a href target.  Run-family slugs contain '+' (e.g.
    AUG_28903_D+N_drifts); a raw '+' in a file:// URL is form-decoded to
    a space by the browser, so every generated link must carry %2B."""
    return quote(path)


#: ---- the shell (Console redesign): topbar + rail + canvas ----------
#: rail sections: key, label, href-from-root; this turns the rail
#: into an EXCLUSIVE accordion: each section's sub-menu renders under
#: its link.  The RUN LIST moved under Runs (the old bottom "Runs"
#: block is gone); the comparisons/release children mirror their
#: canvas sections (labels and hrefs from the same data, injected by
#: main() via _RAIL_EXTRA); the switch children are the page's own
#: section anchors (_SWITCH_ANCHORS, same-page form on the switch
#: page).  Sub-menus ship EXPANDED, marker-free (the no-JS guarantee:
#: scripts off = the full menu); the one shared script collapses all
#: but the active section before first paint and draws +/- markers.
_RAIL_SECTIONS = (
    # EVERY toggle anchors INTO the landing page — the header
    # shows you the section on the homepage, the sub-items go to
    # pages.  Runs targets the pagehead top (#top — the title area,
    # not the runs section below it); Switch index targets the
    # landing's own section 03 like comparisons. The
    # bare same-URL href made the browser RELOAD the page — fragments
    # also give the stamp something to follow.
    # THREE sections : the release axis is dormant this
    # delivery — its rail entry and pages fold back with the axis.
    ("runs", "Runs", "index.html#top"),
    ("comparisons", "Comparisons", "index.html#comparisons"),
    ("switches", "Switch index", "index.html#switches"),
)
#: switch-page section anchors (rail sub-menu) — each target is
#: a section[id] on the switches page (scroll offsets apply).
#: "Switches indexed" is the PAGE link (anchor None): it lands at
#: the top of the switch page, not scrolled into the ledger
_SWITCH_ANCHORS = (
    ("Switches indexed", None),
    ("Honest absence", "honest-absence"),
    ("Set by none of the runs", "unset"),
    ("Provenance", "provenance"),
)
_RAIL_RUNS: list[dict] = []
#: the run tree (the ruled navigation shape): [(group_slug,
#: group_label, [(family, [run, ...])])] in display order — first-seen
#: families follow the sorted run walk, so the order is deterministic
#: without a re-sort; the SLUG (the group's address) rides along for
#: the label anchors and the landing inventory block ids
_RAIL_TREE: list[tuple[str, str, list[tuple[str, list[dict]]]]] = []
_RAIL_EXTRA: dict[str, list[tuple[str, str]]] = {}
_RAIL_META = ""
#: the (group, family) pairs that own FAMILY PAGES this build
#: (checkpoint B: every cataloged family with a real family directory
#: gets one — the base-anchored home of its deck and member table;
#: main() fills the set before any page renders)
_FAM_PAGES: set[tuple[str, str]] = set()
#: the deck-carrying families (owner review of C): (group, family) ->
#: (member A, member B), both family-relative — each renders an
#: "A/B comparison" item under its family in the rail tree (the deck
#: is the family's property; the item is its discovery, the tooltip
#: its pair).  main() fills it before any page renders.
_RAIL_AB: dict[tuple[str, str], tuple[str, str]] = {}

#: rail verdict dots — pushed apart for separation (the color
#: difference must be clearly visible), each still >=3:1 against the
#: paper bg (the UI-part contrast bar).  The landing's legend names
#: exactly this palette; the BADGES text inks stay darker (their
#: tinted chip backgrounds demand it) — one verdict, one hue family,
#: two tunings.
_VERDICT_DOT = {
    "plateaued": "#0f7a38", "near-plateau": "#a36a00",
    "evolving": "#c81f14", "static": "#626b7d",
}


def _tree_count(n_fams: int, fam_word: str, fams_word: str,
                n_runs: int, run_word: str, runs_word: str) -> str:
    """The group summary's count span — pluralized, one builder so the
    tree and the inventory never disagree on the words."""
    return (f'<span class="s-cnt">· {n_fams} '
            f'{n_fams == 1 and fam_word or fams_word}'
            f" · {n_runs} {n_runs == 1 and run_word or runs_word}</span>")


def _rail(active: str, root: str, active_run: str | None = None,
          active_child: str = "", active_group: str | None = None,
          active_fam: tuple[str, str] | None = None,
          active_ab: tuple[str, str] | None = None) -> str:
    eff = active
    groups = []
    for key, label, href in _RAIL_SECTIONS:
        # single highlight: when one of the section's CHILDREN is
        # the current destination, ONLY the child is marked — the
        # toggle carries the here marker only when the page IS the
        # section (the landing's sections, a section page top).  The
        # accordion still opens the owning section (:has sees the
        # child); the script module + the spy move toggles on
        # the landing, the r-c child-follow moves children on the
        # switch page — one amber mark anywhere, always.
        kids: list[str] = []
        stamped = False
        if key == "runs":
            # the run tree (the ruled navigation shape): Runs >
            # groups > families > runs — disclosure is native
            # <details>, shipped CLOSED (the closed tree IS the
            # compact inventory: labels carry their counts; the
            # active run's ancestry opens at first layout, and
            # scripts-off keeps every node natively openable).
            # MARKER TOGGLES, LABEL NAVIGATES: the group label anchors
            # the GROUP PAGE (checkpoint B; class r-lab — outside the
            # run-leaf highlight machinery, its own here state when the
            # group page IS the page); family labels anchor the FAMILY
            # PAGES when they exist (every cataloged family with a real
            # family directory owns one — main() fills _FAM_PAGES; the
            # label degrades to the plain span otherwise).  Leaves
            # carry the verdict dot + the MEMBER name with the full
            # group-qualified name on hover; every level steps the same
            # 12px, names never wrap
            for gslug, glabel, fams in _RAIL_TREE:
                fam_html = []
                for fam, fam_rows in fams:
                    leaves = []
                    for r in fam_rows:
                        here = r["name"] == active_run
                        stamped = stamped or here
                        dot = ('<span class="rdot" style="background:'
                               + _VERDICT_DOT.get(
                                   (r.get("verdict") or "").lower(),
                                   "#9aa2b5") + '"></span>')
                        sel = (' class="r-c r-run here" aria-current="page"'
                               if here else ' class="r-c r-run"')
                        leaves.append(
                            f'<a{sel} title="{html.escape(r["name"])}" '
                            f'href="{url(root + r["name"])}/index.html">'
                            f'{dot}{html.escape(r["name"].rsplit("/", 1)[-1])}'
                            "</a>")
                    # the family label: an anchor to the family page
                    # when one stands (marker toggles, label navigates
                    # — the group-label discipline), else the plain span
                    if (gslug, fam) in _FAM_PAGES:
                        fhere = active_fam == (gslug, fam)
                        fsel = (' class="r-lab here" aria-current="page"'
                                if fhere else ' class="r-lab"')
                        fam_lab = (f'<a{fsel} '
                                   f'href="{root}{url(gslug)}/{url(fam)}'
                                   '/index.html">'
                                   f"{html.escape(fam)}</a>")
                    else:
                        fam_lab = (f'<span class="s-lab">'
                                   f"{html.escape(fam)}</span>")
                    # the family's own A/B deck rides as an item UNDER
                    # its family (owner review of C: the tree is the
                    # deck's discovery; the transparent dot keeps the
                    # leaf column — it is not a run and carries no
                    # verdict).  The comparison page marks THIS item.
                    if (gslug, fam) in _RAIL_AB:
                        pa, pb = _RAIL_AB[(gslug, fam)]
                        abhere = active_ab == (gslug, fam)
                        stamped = stamped or abhere
                        absel = (' class="r-c here" aria-current="page"'
                                 if abhere else ' class="r-c"')
                        leaves.append(
                            f'<a{absel} title="{html.escape(pa)} vs '
                            f'{html.escape(pb)}" '
                            f'href="{root}comparisons/{url(f"{gslug}/{fam}")}'
                            '/index.html">'
                            '<span class="rdot" style="background:'
                            'transparent"></span>A/B comparison</a>')
                    fam_html.append(
                        '<details class="r-fam" data-fam="'
                        + html.escape(f"{gslug}/{fam}", quote=True) + '">\n'
                        f'<summary title="{html.escape(fam)}">'
                        + fam_lab
                        + f'<span class="s-cnt">· {len(fam_rows)}</span>'
                        "</summary>\n"
                        + '<div class="d-sub"><div class="d-sub-in">\n'
                        + "\n".join(leaves)
                        + "\n</div></div>\n</details>")
                # the group label anchors the group page; on the group's
                # own page it carries the here state (the underline
                # voice — the amber bar would break the ladder's
                # geometry, so label anchors never carry the border)
                ghere = active_group == gslug
                gsel = (' class="r-lab here" aria-current="page"'
                        if ghere else ' class="r-lab"')
                kids.append(
                    '<details class="r-grp" data-grp="'
                    + html.escape(gslug, quote=True) + '">\n'
                    f'<summary title="{html.escape(glabel)}">'
                    f'<a{gsel} href="{root}{url(gslug)}/index.html">'
                    f"{html.escape(glabel)}</a>"
                    + _tree_count(
                        len(fams), "family", "families",
                        sum(len(fr) for _, fr in fams), "run", "runs")
                    + "</summary>\n"
                    + '<div class="d-sub"><div class="d-sub-in">\n'
                    + "\n".join(fam_html)
                    + "\n</div></div>\n</details>")
        elif key == "comparisons":
            for clab, chref, ctitle in _RAIL_EXTRA.get("comparisons", []):
                here = chref == active_child
                stamped = stamped or here
                sel = (' class="r-c here" aria-current="page"' if here
                       else ' class="r-c"')
                kids.append(f'<a{sel} title="{html.escape(ctitle)}" '
                            f'href="{root + chref}">'
                            f"{html.escape(clab)}</a>")
        elif key == "switches":
            # anchors into the switch page's own sections; same-page
            # form on the switch page itself (a root-prefixed path
            # would resolve to switches/switches/…).  "Switches
            # indexed" (anchor None) is the page link — top of the
            # page, #top in the same-page form — and carries
            # the page's own stamp; the section children follow the
            # fragment client-side
            for clab, anchor in _SWITCH_ANCHORS:
                here = anchor is None and key == eff
                stamped = stamped or here
                if anchor is None:
                    sel = (' class="r-c here" aria-current="page"' if here
                           else ' class="r-c"')
                    chref = ("#top" if key == eff
                             else f"{root}switches/index.html")
                else:
                    sel = ' class="r-c"'
                    chref = (f"#{anchor}" if key == eff
                             else f"{root}switches/index.html#{anchor}")
                kids.append(f'<a{sel} href="{chref}">{html.escape(clab)}</a>')
        cls = (' class="here" aria-current="page"'
               if key == eff and not stamped else "")
        # static hrefs with #fragment anchors render RAW — url() would
        # percent-encode the '#' and kill both the anchor and the
        # site's link-resolution proofs
        sub = ('<div class="r-sub"><div class="r-sub-in">\n'
               + "\n".join(kids) + "\n</div></div>\n") if kids else ""
        groups.append(f'<div class="r-sec" data-sec="{key}">\n'
                      f'<a{cls} href="{root + href}">'
                      '<span class="r-mark"><span class="rm-c">+</span>'
                      '<span class="rm-o">−</span></span>'
                      f'{html.escape(label)}</a>\n'
                      + sub + "</div>\n")
    foot = (f'<div class="rail-foot">{_RAIL_META}</div>\n' if _RAIL_META
            else "")
    # the menu body wrapper (the responsive-enough ruling): below the
    # breakpoint, with scripting, the whole menu is the band burger's
    # dropdown panel; scripts off (or desktop) render the full
    # menu exactly as before
    return ('<nav class="rail" aria-label="Catalog">\n'
            '<div class="rail-body">\n'
            '<p class="r-h">Catalog</p>\n' + "".join(groups) + foot
            + "</div>\n</nav>\n")


#: ---- self-hosted typefaces — the askthedocs reference set ----
#: Same families, same roles: Sora (UI/body), Source Serif 4 (names,
#: prose, verdicts — the catalog's serif voice), IBM Plex Mono
#: (identifiers, labels, machine values).  Vendored under fonts/ at the
#: askthedocs pins (@fontsource 5.3.0, latin subsets), staged ONCE at
#: the site root; __ROOT__ is the page's own depth prefix (the same
#: root the rail links use) — relative url(), zero network, file://
#: proof at every depth, identical rendering on every OS.  Real faces
#: only (sans 400/600, serif 400 + italic + 600, mono 400/500/600/700)
#: — no synthesized weights, ever (the round-5 audit's detector: the
#: 600s for all three voices ship, so every semibold anchor and every
#: bold-in-prose is a true face).
_LATIN_RANGE = ("U+0000-00FF,U+0131,U+0152-0153,U+02BB-02BC,U+02C6,"
                "U+02DA,U+02DC,U+0304,U+0308,U+0329,U+2000-206F,U+20AC,"
                "U+2122,U+2191,U+2193,U+2212,U+2215,U+FEFF,U+FFFD")
_FONT_FACES = (
    ("Sora", "normal", 400, "sora-latin-400-normal.woff2"),
    ("Sora", "normal", 600, "sora-latin-600-normal.woff2"),
    ("Source Serif 4", "normal", 400, "source-serif-4-latin-400-normal.woff2"),
    ("Source Serif 4", "italic", 400, "source-serif-4-latin-400-italic.woff2"),
    ("Source Serif 4", "normal", 600, "source-serif-4-latin-600-normal.woff2"),
    ("IBM Plex Mono", "italic", 400, "ibm-plex-mono-latin-400-italic.woff2"),
    ("IBM Plex Mono", "normal", 400, "ibm-plex-mono-latin-400-normal.woff2"),
    ("IBM Plex Mono", "normal", 500, "ibm-plex-mono-latin-500-normal.woff2"),
    ("IBM Plex Mono", "normal", 600, "ibm-plex-mono-latin-600-normal.woff2"),
    ("IBM Plex Mono", "normal", 700, "ibm-plex-mono-latin-700-normal.woff2"),
)


def fontface_css(root: str) -> str:
    """The @font-face block, root-prefixed for one page's depth."""
    rules = []
    for family, style, weight, fname in _FONT_FACES:
        rules.append(
            '@font-face {\n'
            f'  font-family: "{family}"; font-style: {style};'
            f' font-weight: {weight};\n'
            '  font-display: swap;\n'
            f'  src: url("{root}fonts/{fname}") format("woff2");\n'
            f'  unicode-range: {_LATIN_RANGE};\n'
            '}')
    return "\n".join(rules)


def _crumbs_html(crumbs: tuple[tuple[str, str | None], ...],
                 root: str) -> str:
    """Band breadcrumbs: the trail lives IN the sticky topbar —
    brand | crumbs | counts, visible at every scroll.  Catalog
    prepended (root-prefixed), every crumb but the last a working
    link to its ancestor; the last names the page itself (plain,
    aria-current) and is the FLEX POINT: it ellipsizes when the trail
    would crowd the counts (full name on hover).  Fragment hrefs
    stay RAW (the rail's pinned rule)."""
    if not crumbs:
        return ""
    items = [f'<a href="{url(root + "index.html")}">Catalog</a>']
    for label, href in crumbs:
        # escape AT THE SINK: labels are page names (run-derived in
        # principle) and ride both a double-quoted title attribute and
        # text content — safety must not depend on caller discipline
        if href is None:
            items.append(f'<span class="c-here" '
                         f'title="{html.escape(label)}" '
                         f'aria-current="page">{html.escape(label)}</span>')
        else:
            items.append(f'<a href="{root + href}">'
                         f"{html.escape(label)}</a>")
    return ('<nav class="crumbs" aria-label="Breadcrumb">'
            + '<span class="c-sep">›</span>'.join(items) + "</nav>\n")


def page(title: str, head: str, body: str, root: str = "",
         active: str = "", active_run: str | None = None,
         crumbs: tuple[tuple[str, str | None], ...] = (),
         active_child: str = "", active_group: str | None = None,
         active_fam: tuple[str, str] | None = None,
         active_ab: tuple[str, str] | None = None) -> str:
    brand = ('<a class="brand" href="' + url(root + "index.html") + '">'
             '<span class="b-kick">SOLPS-ITER</span>'
             '<span class="b-name">Run catalog</span></a>')
    meta = (f'<div class="tb-meta">{_RAIL_META}</div>' if _RAIL_META
            else "")
    # the narrow-window menu control (the rework): a hamburger at
    # the band's right end — visible only below the breakpoint AND with
    # scripting (the CSS gates it); the icon is three CSS-drawn lines,
    # no font glyph to go missing in the vendored latin subsets.  It
    # carries the accessible label and the open/closed state; the menu
    # drops as a panel fixed under the band
    burger = ('<button class="burger" type="button" aria-expanded="false" '
              'aria-label="Menu"><span class="burger-box">'
              '<span class="burger-line"></span>'
              '<span class="burger-line"></span>'
              '<span class="burger-line"></span>'
              '</span></button>\n')
    # the band's middle slot: the trail on sub-pages; on the
    # landing the SECTION INDICATOR (script-managed: Catalog ›
    # section, scroll-spy — static "Catalog" without scripting)
    band = (_crumbs_html(crumbs, root) if crumbs
            else '<nav class="crumbs" aria-label="Section">'
                 '<span class="c-here">Catalog</span></nav>\n')
    # the landing's script tag alone carries the data-frag stamp: the
    # four fragment names are the LANDING's toggles — on sub-pages
    # they are foreign anchors (the switch page's #top is its own
    # Switches-indexed child), so the first-layout pre-open must not
    # fire there (the stamp would map #top to runs and never retire)
    script_open = ('<script data-frag-stamp>' if not crumbs else "<script>")
    return (
        "<!DOCTYPE html>\n<html lang=\"en\">\n<head>\n<meta charset=\"utf-8\">\n"
        f"<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\n"
        f'<link rel="icon" href="{FAVICON}">\n'
        f"<title>{html.escape(title)}</title>\n"
        f"<style>{CSS}{fontface_css(root)}</style>\n"
        # the one shared inline script lives in the HEAD: its
        # first act — the js class on <html> — runs BEFORE the body
        # parses, so the CSS applies the accordion's initial state at
        # first layout (no flash of the expanded menu on slow pages);
        # the DOM modules wait for DOMContentLoaded
        f"{script_open}{SCRIPT}</script>\n</head>\n"
        f"<body>\n<header class=\"topbar\"><div class=\"tb-in\">"
        f"{brand}{band}{meta}{burger}"
        '</div><div class="plasma"></div></header>\n'
        f'<div class="shell">\n{_rail(active, root, active_run, active_child, active_group, active_fam, active_ab)}'
        '<main class="canvas">\n'
        + f'<div class="pagehead" id="top">\n{head}\n</div>\n{body}\n'
        '</main>\n</div>\n'
        "</body>\n</html>\n"
    )


def fmt_bytes(n: int) -> str:
    units = ["B", "KB", "MB", "GB"]
    v = float(n)
    for u in units:
        if v < 1024 or u == units[-1]:
            return f"{v:.1f} {u}" if u != "B" else f"{int(v)} B"
        v /= 1024
    return f"{n} B"


def species_cell(species: list[str] | None) -> str:
    if not species:
        return "—"
    return f'{len(species)} <span class="mono">({html.escape(" ".join(species))})</span>'


def catalog_stamp(runs: list[dict]) -> str:
    """The landing's build stamp — static, always visible, no scripts.

    Two honest facts in one paragraph: WHAT this catalog was built
    from (computed per build, so a rebuild over another runs tree
    states that tree's numbers) and WHEN the shipped lineage was cut
    (from the committed data/build-stamp.json, bumped by the
    maintainer's release act — never a wall clock, which would break
    the byte-identical rebuild proof).  The rebuild command named is
    the one-command path (package README, 'The catalog in depth').
    """
    families = sorted({r.get("run_family") or r.get("machine", "?")
                       for r in runs})
    hashes = sorted({r["code_git"] for r in runs if r.get("code_git")})
    code = ", ".join(short_md5(h) for h in hashes) if hashes else "—"
    try:
        stamp = json.loads(
            (HERE / "data" / "build-stamp.json").read_text(encoding="utf-8"))
        shipped = str(stamp.get("date", "unknown"))
    except (OSError, ValueError):
        shipped = "unknown"
    return (
        '<p class="sub">Catalog stamp: built from <b>' + str(len(runs))
        + "</b> runs across <b>" + str(len(families)) + "</b> families · "
        'code git <span class="mono">' + code + "</span> · shipped "
        + html.escape(shipped) + " · solps-reader "
        + solps_reader.__version__ + " · rebuild: "
        '<span class="mono">solps-reader catalog build</span></p>\n'
    )


#: the run-table head — one constant so every family table on the
#: landing (and any future surface) renders the same columns
_RUNS_THEAD = (
    "<thead><tr><th>Run</th>"
    '<th>Convergence<a class="fn" href="#footnotes" '
    'title="Heuristic on active monitors (footnote below)">†</a></th>'
    '<th class="num">Grid</th><th>Species</th><th>Code (fort.44 git)</th>'
    '<th>Wall loads<a class="fn" href="#footnotes" '
    'title="Per-element SI (footnote below)">‡</a></th></tr></thead>\n'
)


def _run_row(r: dict, root: str = "") -> str:
    """One run-table row: the first cell carries the identity line
    (name, strong) over the context line (machine, quiet) — the
    machine column folds into the run cell, freeing width.  The name
    is group-qualified and IS the page's path (url() keeps the
    slashes; each part carries its own %2B-safe quoting); `root` is
    the page's own depth prefix (the landing's tables sit at "")."""
    grid = r.get("grid") or {}
    grid_s = f'{grid.get("nx", "—")}×{grid.get("ny", "—")}' if grid else "—"
    return (
        "<tr>"
        f'<td class="run-id"><span class="runname">'
        f'<a title="{html.escape(r["name"])}" '
        f'href="{url(root + r["name"])}/index.html">{html.escape(r["name"])}'
        "</a></span>"
        f'<span class="runctx">{html.escape(r["machine"])}</span></td>'
        f"<td>{badge(r.get('verdict') or 'unknown')}</td>"
        f'<td class="num">{grid_s}</td>'
        f"<td>{species_cell(r.get('species'))}</td>"
        f'<td class="mono">{html.escape(r.get("code_git") or "—")}</td>'
        f"<td>{'yes' if r.get('has_wall_loads') else '—'}</td>"
        "</tr>"
    )


def _recorded_comps_html(recorded: list[dict]) -> str:
    """The compare verb's recorded pairs: one row per deck-carrying
    pair linking its page, the named skips under the same
    honest-skips list the family decks use."""
    if not recorded:
        return ""
    rows, skips = [], []
    for rc in recorded:
        a, b = rc["a"], rc["b"]
        if rc.get("deck"):
            href = (f'compare/{url(rc["deck"].split("/")[-1].removesuffix("__diff"))}'
                    "/index.html")
            rows.append(
                "<tr>"
                f'<td><a class="mono" href="{href}">'
                f"{html.escape(a)} vs {html.escape(b)}</a></td>"
                f'<td class="mono">{html.escape(a)} -&gt; {html.escape(b)}</td>'
                f'<td class="num">{rc.get("n_figures", "—")}</td>'
                "</tr>")
        else:
            skips.append(f'<span class="mono">{html.escape(a)} vs '
                         f'{html.escape(b)}</span> '
                         f'({html.escape(rc["skipped"])})')
    out = (
        '<h3 class="rec-h">Recorded pairs (catalog compare)</h3>\n'
        '<table class="comps">\n<thead><tr><th>Pair</th><th>A -&gt; B</th>'
        '<th class="num">Figures</th></tr></thead>\n<tbody>\n'
        + "\n".join(rows) + "\n</tbody>\n</table>\n")
    if skips:
        out += ('<p class="sub">Skipped:</p>\n<ul class="skips">\n'
                + "\n".join(f"<li>{s}</li>" for s in skips)
                + "\n</ul>\n")
    return out


def build_index(runs: list[dict], comparisons: list[dict],
                switchsets: dict | None = None,
                groups: list[dict] | None = None,
                recorded: list[dict] | None = None,
                fingerprints: dict[str, str] | None = None,
                built_at: str | None = None) -> str:
    # the verdict tallies feed the distribution meter (one Counter,
    # rendered — counts from the index's own run entries, never
    # re-derived).
    tally = Counter((r.get("verdict") or "unknown").lower() for r in runs)
    # the landing's runs section is the INVENTORY : one block
    # per group — label, named source, family/run counts, the verdict
    # summary, the group's analysis fingerprint.  The per-family
    # tables live on the group pages (checkpoint B); the order here
    # is first-seen over the display-ordered runs — deterministic
    # without a re-sort.
    groups = groups or []
    by_group: dict[str, dict] = {}
    for r in runs:
        parts = r["name"].split("/")
        gslug = r.get("group") or parts[0]
        g = by_group.setdefault(
            gslug, {"label": r.get("group_label") or gslug, "fams": {}})
        g["fams"].setdefault(
            parts[1] if len(parts) > 2 else parts[0], []).append(r)
    grp_meta = {g["slug"]: g for g in groups}
    grp_html = []
    for gslug, g in by_group.items():
        meta = grp_meta.get(gslug, {})
        src = meta.get("path") or "the shipped reference set"
        n_fams, n_runs = len(g["fams"]), sum(
            len(fr) for fr in g["fams"].values())
        gtally = Counter((r.get("verdict") or "unknown").lower()
                         for fr in g["fams"].values() for r in fr)
        verd = " ".join(chip(v, n) for v, n in
                        sorted(gtally.items(), key=lambda kv: -kv[1]))
        # the compact verdict bar — the legend's own dot palette;
        # counts ride the badges beside it (color never alone)
        gdist = "".join(
            f'<span style="flex:{n};background:{_VERDICT_DOT.get(v, "#9aa2b5")}"></span>'
            for v, n in sorted(gtally.items(), key=lambda kv: -kv[1]))
        fp = (fingerprints or {}).get(gslug)
        fp_line = (f'<p class="grp-fp">analyses '
                   f'<span class="mono">{fp}</span></p>\n' if fp else "")
        grp_html.append(
            f'<div class="run-grp" id="g-{html.escape(gslug)}">\n'
            # the block's label OPENS THE GROUP PAGE (checkpoint B):
            # the family tables + the group's filter live there; this
            # landing block stays the orientation (counts, verdicts,
            # fingerprint)
            f'<h3 class="grp-h"><a href="{url(gslug)}/index.html">'
            f"{html.escape(g['label'])}</a> "
            f'<span class="grp-src">{html.escape(src)}</span></h3>\n'
            '<div class="grp-stats">\n'
            f'<span class="stat"><span class="n">{n_fams}</span>'
            f'<span class="l">{n_fams == 1 and "family" or "families"}'
            "</span></span>\n"
            f'<span class="stat"><span class="n">{n_runs}</span>'
            f'<span class="l">{n_runs == 1 and "run" or "runs"}'
            "</span></span>\n"
            f'<span class="grp-verd">{verd}</span>\n'
            "</div>\n"
            f'<div class="grp-dist">{gdist}</div>\n'
            + fp_line
            + "</div>\n")
    # sick groups are FIRST-CLASS rows : the landing keeps
    # every remembered source the build could not catalog named,
    # with its reason and remedy — nothing silently disappears for
    # the user who did not read the CLI output
    sick = [g for g in groups if g.get("status") != "ok"]
    sick_html = ""
    if sick:
        rows = "".join(
            '<p class="ncat">'
            f'<span class="mono">{html.escape(g["label"])}</span>: '
            + ("the folder was not found on this machine"
               if g["status"] == "absent" else
               "the folder holds no recognizable runs")
            + ".  Remedy: check the folder (mounted? renamed?), or "
              "drop it from the catalog with "
              '<span class="mono">solps-reader catalog remove '
            + html.escape(g["label"]) + "</span>.</p>\n"
            for g in sick)
        sick_html = ('<div class="sick-grps">\n'
                     '<h3 class="grp-h">Not cataloged at last build</h3>\n'
                     + rows + "</div>\n")
    # the empty-state teacher — ONLY while zero user groups stand
    # (any remembered user source, sick included, retires it: the
    # inventory is then the user's own landing)
    has_user = any(g.get("slug") != "example-runs" for g in groups)
    teacher_html = ""
    if not has_user:
        teacher_html = (
            '<div class="teacher">\n'
            "<p><b>This catalog carries the shipped reference set, and "
            "it can carry yours.</b>  Remember a runs folder with "
            '<span class="mono">solps-reader catalog add &lt;runs-folder&gt;'
            "</span> (each subfolder is a run family), then rebuild with "
            '<span class="mono">solps-reader catalog build</span>: your '
            "runs join the site beside the examples, which always stay "
            "last in order, labeled as the reference set.</p>\n"
            "</div>\n")
    # the build moment — a wall clock rides ONLY a user-seat build
    # that carries user groups (the determinism rule); the gate
    # and the maintainer --in-tree path never hand one down
    built_line = (f'<p class="built-at">built at '
                  f"{html.escape(built_at)}</p>\n"
                  if built_at and has_user else "")
    # the distribution meter: one labeled segment per verdict, width =
    # count (a rendering of the tally above — counts ride the labels,
    # color never alone).
    dist_segs = "".join(
        f'<span class="dseg" style="flex:{n};background:{BADGES.get(v, BADGES_FALLBACK)[0]};'
        f'color:{BADGES.get(v, BADGES_FALLBACK)[1]}">{n} {v}</span>'
        for v, n in sorted(tally.items(), key=lambda kv: -kv[1]))
    dist = (
        f'<div class="dist" role="img" aria-label="Convergence verdicts: '
        + ", ".join(f"{v} {n}" for v, n in sorted(tally.items()))
        + f'">{dist_segs}</div>\n')
    # the verdict-dot legend : the rail dots' palette, named
    # once — all four verdicts, counts aside (the legend is about the
    # COLOR meaning; the meter above carries the counts)
    legend = ('<p class="vlegend" aria-label="Verdict dot legend">'
              + "".join(
                  f'<span class="rdot" style="background:{_VERDICT_DOT[v]}">'
                  f"</span>{v}"
                  for v in ("plateaued", "near-plateau", "evolving",
                            "static")) + "</p>\n")
    # family comparisons section (checkpoint C, owner display round
    # 1): the heavy deck TABLE stays retired, but the section carries
    # a LIGHT DECK INDEX — one link line per deck-carrying family
    # (the family-qualified name → its comparison page, the pair's
    # member names beside) so the section orients instead of reading
    # empty; the two-homes rule names where the decks LIVE (with
    # their families — under the family in the rail, linked from the
    # family page; skipped decks state their recorded reason there).
    # The recorded pairs' own table follows.  n_decks counts
    # deck-carrying entries from the index (no dir listing).
    deck_items = []
    for c in comparisons:
        if not c.get("deck"):
            continue
        fam = c["run_family"]
        fam_name = fam.partition("/")[2]
        pair_a, pair_b = c["pair"]
        deck_items.append(
            f'<li><a class="mono" href="comparisons/{url(fam)}/index.html">'
            f"{html.escape(fam)}</a>"
            f'<span class="mono"> · {html.escape(pair_a.removeprefix(fam_name + "/"))}'
            f" vs {html.escape(pair_b.removeprefix(fam_name + '/'))}"
            "</span></li>")
    n_decks = len(deck_items)
    n_pairs = sum(1 for rc in (recorded or []) if rc.get("deck"))
    deck_index = (
        f'<p class="sub">Family deck{"s" if n_decks != 1 else ""}:</p>\n'
        '<ul class="skips">\n' + "\n".join(deck_items) + "\n</ul>\n"
    ) if deck_items else ""
    comps_section = (
        '<section id="comparisons" class="rise">\n'
        '<h2><span class="sn">02</span>Comparisons</h2>\n'
        f'<p class="sub">{n_decks} family deck'
        + ("s" if n_decks != 1 else "") + f" · {n_pairs} recorded pair"
        + ("s" if n_pairs != 1 else "") + "</p>\n"
        '<p class="sub">Two homes: pairs you record with '
        '<span class="mono">catalog compare</span> are here (both '
        "member run pages link their pair); each family's own A/B "
        "deck lives with its family: under the family in the rail, "
        "and linked from the family's page.  If you chose the pair, "
        "it's here; if the family made it for you, it's there.</p>\n"
        + deck_index
        + _recorded_comps_html(recorded or [])
        + "</section>\n"
    )
    # section 03 — the citation -> runs direction at section rank
    # ("sections, not columns").  Every number renders from the
    # artifact's own counts block — the same join the switch page's
    # honest-absence ledger renders, never re-derived here.  The
    # release reports section that ranked 03 is DORMANT this delivery
    # the committed page-data joins and the builders stay
    # in the tree; the site stops emitting pages and section.
    switches_section = ""
    if switchsets:
        sc = switchsets["counts"]
        ss_chips = "".join(chip(v, sc.get(v, 0)) for v in VS_DEFAULT_ORDER)
        switches_section = (
            '<section id="switches" class="rise">\n'
            '<h2><span class="sn">03</span>Switch index</h2>\n'
            '<p class="sub">Every switch any cataloged run sets, which runs '
            "set it to what: the citation -&gt; runs direction of the join.  "
            "The <a href=\""
            + url("switches/index.html")
            + '">switch index</a> carries the full ledger: '
            f'{sc["distinct_switches_set"]} '
            + ("switch" if sc["distinct_switches_set"] == 1 else "switches")
            + f' over {sc["runs"]} '
            + ("run" if sc["runs"] == 1 else "runs")
            + ", every value verbatim with its honest-absence and provenance "
            "blocks; the tally below is every entry's stance against its "
            "documented default:</p>\n"
            f'<p class="chips">{ss_chips}</p>\n'
            "</section>\n"
        )
    head = (
        '<p class="kicker">SOLPS-ITER · run catalog</p>\n'
        "<h1>Run catalog</h1>\n"
        + ('<p class="sub">The shipped reference set beside your '
           "cataloged run folders · manifests and verdicts generated "
           "deterministically from the run files · wall-load data read "
           "from the fort.44 section no official tool consumes.</p>\n"
           if has_user else
           '<p class="sub">Public example runs (Zenodo, md5-verified) · '
           "manifests and verdicts generated deterministically from the "
           "run files · wall-load data read from the fort.44 section no "
           "official tool consumes.</p>\n")
        + catalog_stamp(runs)
    )
    body = (
        '<section id="runs" class="rise">\n'
        '<h2><span class="sn">01</span>Runs</h2>\n'
        + dist + legend
        + "".join(grp_html)
        + sick_html
        + teacher_html
        + built_line
        + "</section>\n"
        + comps_section
        + switches_section
        + '<footer id="footnotes">\n'
        '<p><span class="fnmark">†</span> Convergence verdicts: heuristic on '
        "active monitors (time bases and never-computed traces excluded); "
        "always check the physics.</p>\n"
        '<p><span class="fnmark">‡</span> Wall tallies are per-element SI '
        "rates/powers (particles s⁻¹, W; units audited in FORMATS.md), "
        "read from the fort.44 section no official tool consumes.</p>\n"
        '<p>Generated by <span class="mono">catalog/build_catalog.py</span>: '
        "static, zero-server, byte-reproducible.</p>\n"
        "</footer>\n"
    )
    return page("SOLPS-ITER run catalog", head, body, active="runs")


def build_group_page(gslug: str, glabel: str,
                     fams: list[tuple[str, list[dict]]],
                     meta: dict) -> str:
    """The GROUP PAGE (the landing redesign, checkpoint B): the
    group's own home — one block per family with its member table
    and the family-page link, under ONE aggregating filter whose
    scope is the whole group.  Reached from the landing's inventory
    block and the rail's group label; the brand crumb returns to the
    landing (the backlink chain's top).  Every number renders from
    the index's own run entries — nothing re-derived."""
    n_runs = sum(len(fr) for _, fr in fams)
    src = meta.get("path") or "the shipped reference set"
    tally = Counter((r.get("verdict") or "unknown").lower()
                    for _, fr in fams for r in fr)
    chips = " ".join(chip(v, n) for v, n in
                     sorted(tally.items(), key=lambda kv: -kv[1]))
    head = (
        '<p class="kicker">Catalog · group</p>\n'
        f"<h1>{html.escape(glabel)}</h1>\n"
        f'<p class="meta">{html.escape(src)} · {len(fams)} '
        + ("family" if len(fams) == 1 else "families")
        + f" · {n_runs} " + ("run" if n_runs == 1 else "runs") + "</p>\n"
        f'<p class="chips">{chips}</p>\n'
    )
    # one filter, one scope: every family table on the page shares it
    # (the aggregating rule the pre-B landing established — counts and
    # matches pool across tables)
    toolbar = (
        '<div class="toolbar" data-filter-scope>\n'
        '<input type="search" data-filter-input aria-label="Filter runs" '
        'placeholder="Filter runs: name, verdict, grid, species…">\n'
        '<span class="fcount" data-filter-count aria-live="polite"></span>'
        "\n</div>\n")
    blocks = []
    for fam, fam_rows in fams:
        # the family header links the family page when one stands
        # (every cataloged family with a real directory owns one);
        # the count + verdict chips ride beside it
        fam_head = (f'<a href="{url(fam)}/index.html">'
                    f"{html.escape(fam)}</a>") \
            if (gslug, fam) in _FAM_PAGES else html.escape(fam)
        verd = " ".join(chip(v, n) for v, n in sorted(
            Counter((r.get("verdict") or "unknown").lower()
                    for r in fam_rows).items(),
            key=lambda kv: -kv[1]))
        rows = "\n".join(_run_row(r, root="../") for r in fam_rows)
        blocks.append(
            f'<div class="fam-blk" id="f-{url(fam)}">\n'
            f'<h3 class="fam-h">{fam_head} '
            f'<span class="s-cnt">· {len(fam_rows)} '
            + ("run" if len(fam_rows) == 1 else "runs")
            + f'</span> <span class="fam-verd">{verd}</span></h3>\n'
            '<table class="runs" data-sort data-filter>\n'
            "<thead><tr><th>Run</th><th>Convergence</th>"
            '<th class="num">Grid</th><th>Species</th><th>Code</th>'
            "<th>Wall</th></tr></thead>\n"
            f"<tbody>\n{rows}\n</tbody>\n</table>\n</div>\n")
    body = (
        '<section id="runs" class="rise">\n<h2>Runs</h2>\n'
        + toolbar + "".join(blocks)
        + '<p class="sub">Each family block opens the family page: the '
        "base deck lives there once, with every member's own switches "
        "as a delta against it on the run pages.</p>\n</section>\n"
        + '<footer>Generated by <span class="mono">catalog/build_catalog.py'
        "</span>: numbers on this page come from the index JSON, never "
        "re-derived.</footer>\n")
    return page(f"{glabel} · SOLPS-ITER run catalog", head, body,
                root="../", active="runs", active_group=gslug,
                crumbs=((html.escape(glabel), None),))


def _deck_equal(a: str, b: str) -> bool:
    """Value equality for the vs-base delta — the SAME rule the join's
    vs_default uses (build_switchsets.RULES['vs_default']): both sides
    Fortran reals (D/d normalised) compare numerically, everything
    else exactly."""
    ar, br = _as_real(a), _as_real(b)
    if ar is not None and br is not None:
        return ar == br
    return a == b


def _as_real(token: str) -> float | None:
    t = token.strip()
    if not _REAL_RE.match(t):
        return None
    return float(t.replace("D", "E").replace("d", "e"))


_REAL_RE = re.compile(r"^[+-]?(\d+\.?\d*|\.\d+)([eEdD][+-]?\d+)?$")


def vs_base_section(ss_entry: dict | None, fam_deck: dict | None,
                    fam_href: str | None,
                    fam_deck_present: bool = True) -> str:
    """The run page's VS-BASE DELTA (checkpoint B): what this run's
    own deck changes against the family base — overrides (value
    differs), additions (the base does not set it) and unsettings
    (the base sets it, this run's file does not — absent means NOT
    SET, the join's own defaults rule).  Read-only over the
    switchsets artifact: the run's effective switches + the
    family_decks block; never re-parsed from disk.  Honest
    degradations: a run whose deck IS the family base (no b2mn.dat of
    its own) states the identity; a family without a base deck states
    the absence and stops."""
    if ss_entry is None:
        return ""
    fam_link = (f'<a href="{fam_href}">family base deck</a>'
                if fam_href else "family base deck")
    if fam_deck is None:
        absent = ("This family carries no shared base deck"
                  if not fam_deck_present else
                  "The family base deck carries no b2mn.dat")
        tail = ("" if not fam_deck_present else
                " for the switch layer")
        return (
            "<h2>Vs family base</h2>\n"
            f'<p class="sub">{absent}{tail}: every '
            "member runs its own deck whole; there is no base to delta "
            "against.  The run's full switch state is the section "
            "below.</p>\n")
    base = fam_deck["switches"]
    srcs = {e["source_file"] for e in ss_entry["switches"].values()}
    if srcs == {"deck"}:
        return (
            "<h2>Vs family base</h2>\n"
            '<p class="sub">This run carries no deck of its own: its '
            f"switches ARE the {fam_link}, verbatim.</p>\n")
    own = {k: e["value"] for k, e in ss_entry["switches"].items()}
    overrides = sorted(k for k in own
                       if k in base and not _deck_equal(own[k], base[k]))
    added = sorted(k for k in own if k not in base)
    unset = sorted(k for k in base if k not in own)
    if not (overrides or added or unset):
        return (
            "<h2>Vs family base</h2>\n"
            '<p class="sub">This run carries its own deck file, but '
            "every switch matches the family base: an own-file copy "
            "with no change.</p>\n")
    rows = []
    for k in overrides:
        rows.append(
            f'<tr><td class="mono">{html.escape(k)}</td>'
            f'<td class="mono">{html.escape(base[k])}</td>'
            f'<td class="mono">{html.escape(own[k])}</td>'
            '<td>override</td></tr>')
    for k in added:
        rows.append(
            f'<tr><td class="mono">{html.escape(k)}</td>'
            "<td>— not set</td>"
            f'<td class="mono">{html.escape(own[k])}</td>'
            "<td>added</td></tr>")
    for k in unset:
        rows.append(
            f'<tr><td class="mono">{html.escape(k)}</td>'
            f'<td class="mono">{html.escape(base[k])}</td>'
            "<td>— not set</td>"
            "<td>unset</td></tr>")
    n_ov, n_ad, n_un = len(overrides), len(added), len(unset)
    return (
        "<h2>Vs family base</h2>\n"
        f'<p class="sub">Against the {fam_link}: '
        + " · ".join(x for x in (
            f"{n_ov} " + ("override" if n_ov == 1 else "overrides"),
            f"{n_ad} " + ("addition" if n_ad == 1 else "additions"),
            f"{n_un} " + ("unsetting" if n_un == 1 else "unsettings"))
            if x) + ": whole-file shadowing means the run's own deck "
        "replaces the base; absent keys are never set (the join's "
        "defaults rule).</p>\n"
        '<table class="vsbase" data-sort>\n'
        "<thead><tr><th>Switch</th><th>Family base</th><th>This run</th>"
        "<th>Change</th></tr></thead>\n"
        f"<tbody>\n" + "\n".join(rows) + "\n</tbody>\n</table>\n")


def build_family_page(gslug: str, glabel: str, fam: str,
                      fam_rows: list[dict], deck: dict | None,
                      deck_path: str | None, comparison: dict | None,
                      base_deck: dict | None) -> str:
    """The FAMILY PAGE (checkpoint B): the family's own home — the
    BASE ANCHOR (the baserun deck rendered ONCE per family, the
    deck-page role this page inherits) over the member table; the
    A/B comparison deck links from here when one stands.  Single
    members degrade honestly: the base still anchors, the table
    carries its one row.  The backlink chain: brand → the group
    page → this page → each run page."""
    n = len(fam_rows)
    machine = fam_rows[0].get("machine", "—")
    verd = " ".join(chip(v, k) for v, k in sorted(
        Counter((r.get("verdict") or "unknown").lower()
                for r in fam_rows).items(), key=lambda kv: -kv[1]))
    # the family's own address IS its group-qualified name (owner
    # review of C): the run pages show theirs, the family page shows
    # its own — one naming discipline, and the qualified form is what
    # a family colliding across two groups needs to stay distinct
    qualified = f"{gslug}/{fam}"
    head = (
        '<p class="kicker">Catalog · run family</p>\n'
        f"<h1>{html.escape(qualified)}</h1>\n"
        f'<p class="meta">machine {html.escape(str(machine))}'
        f" · {n} " + ("member" if n == 1 else "members") + "</p>\n"
        f'<p class="chips">{verd}</p>\n')
    parts = []
    if deck is not None:
        parts.append(input_deck_section(
            {"input_deck": deck_path}, deck, title="Family base deck"))
    else:
        parts.append(
            "<h2>Family base deck</h2>\n"
            '<p class="sub">This family carries no shared base deck: '
            "every member runs its own deck whole (the honest absence; "
            "each run page's Switches section carries its full "
            "state).</p>\n")
    if comparison is not None and comparison.get("deck"):
        # owner review of C: the deck's presence on the family page is
        # its own BLOCK (an h2, the page's section voice) with a mono
        # link naming the pair — the site's identifier-link voice, an
        # obvious affordance rather than prose with a quiet anchor
        pair_a, pair_b = comparison["pair"]
        parts.append(
            "<h2>Family A/B comparison</h2>\n"
            f'<p class="sub"><a class="mono" href="../../comparisons/'
            + url(comparison["run_family"])
            + '/index.html">'
            + html.escape(pair_a.removeprefix(fam + "/")) + " vs "
            + html.escape(pair_b.removeprefix(fam + "/"))
            + "</a>: the figure deck this family's pair produced "
            "(its state diff; the same comparison stands under this "
            "family in the rail).</p>\n")
    elif comparison is not None:
        # the skipped deck's honest home (checkpoint C): with the deck
        # table retired from the landing's Comparisons section, the
        # family page states its own recorded skip reason, verbatim
        parts.append(
            "<h2>Family A/B comparison</h2>\n"
            '<p class="sub">not generated: '
            + html.escape(str(comparison.get("skipped"))) + ".</p>\n")
    parts.append("<h2>Members</h2>\n")
    rows = "\n".join(_run_row(r, root="../../") for r in fam_rows)
    parts.append(
        '<table class="runs" data-sort>\n'
        "<thead><tr><th>Run</th><th>Convergence</th>"
        '<th class="num">Grid</th><th>Species</th><th>Code</th>'
        "<th>Wall</th></tr></thead>\n"
        f"<tbody>\n{rows}\n</tbody>\n</table>\n")
    parts.append(
        '<footer>Generated by <span class="mono">catalog/build_catalog.py'
        "</span> from the manifest + switchsets JSON, never "
        "re-derived.</footer>\n")
    return page(
        f"{qualified} · SOLPS-ITER run catalog", head, "\n".join(parts),
        root="../../", active="runs", active_fam=(gslug, fam),
        crumbs=((html.escape(glabel), f"{url(gslug)}/index.html"),
                (html.escape(qualified), None)))


def kv_rows(pairs: list[tuple[str, str]]) -> str:
    return "<table class=\"kv\">\n<tbody>\n" + "\n".join(
        f"<tr><th>{k}</th><td>{v}</td></tr>" for k, v in pairs
    ) + "\n</tbody>\n</table>\n"


def short_md5(md5: str | None) -> str:
    if not md5:
        return "—"
    return f"{md5[:12]}…"


#: sparkline geometry ruling: fixed viewBox, hairline stroke in
#: the site's de-emphasis ink (CSS rule on .spark polyline above), y from
#: the series min/max ONLY — presentation-layer scaling of the manifest's
#: JSON values; no hand-written numbers enter the markup.
SPARK_W, SPARK_H, SPARK_PAD = 120, 24, 2


def sparkline_svg(name: str, values: list[float]) -> str:
    """One inline sparkline: a single hairline polyline, nothing else.

    `<title>` = monitor name — the a11y channel (hover text, and the
    SVG's accessible name via role="img").  X maps record index over the
    kept series; Y maps (value - min) / (max - min); a degenerate span
    (all kept values equal) draws the mid-line rather than dividing by
    zero.  An empty series is an honest "—", never fabricated geometry.
    """
    if len(values) < 2:
        return "—"
    vmin, vmax = min(values), max(values)
    vspan = vmax - vmin
    pts = []
    for i, v in enumerate(values):
        fx = i / (len(values) - 1)
        x = SPARK_PAD + (SPARK_W - 2 * SPARK_PAD) * fx
        fy = (1 - (v - vmin) / vspan) if vspan else 0.5
        y = SPARK_PAD + (SPARK_H - 2 * SPARK_PAD) * fy
        pts.append(f"{x:.2f},{y:.2f}")
    return (
        f'<svg class="spark" viewBox="0 0 {SPARK_W} {SPARK_H}" '
        f'width="{SPARK_W}" height="{SPARK_H}" role="img">'
        f"<title>{html.escape(name)}</title>"
        f'<polyline points="{" ".join(pts)}"/></svg>'
    )


def monitor_label(name: str, mon: dict) -> str:
    """Active-monitor cell text: name plus the NC units attribute when
    the file carried one (tmte/tmti are eV; tmne has none)."""
    units = (mon.get("units") or "").strip()
    return f"{html.escape(name)} ({html.escape(units)})" if units else html.escape(name)


def spark_absence_note(conv: dict) -> str:
    """honest-absence note: a run whose manifest carries no
    sparklines block (the guard-skipped ramping_drifts, or a verdict-
    bearing manifest built before sparklines existed) states the absence with the
    skip reason VERBATIM from the manifest — wording follows the dated ruling ("figure" -> "sparklines"); never a blank."""
    reason = (conv.get("skipped") or conv.get("error")
              or "no sparklines block recorded in the manifest")
    return ('<p class="sub">convergence sparklines not generated: '
            f'{html.escape(str(reason))}</p>')


def wall_figure_or_note(wg: dict | None) -> str:
    """the wall gate: the wall section's figure-or-note, decided from the
    manifest's wall_geometry JSON ONLY — the has_fig filesystem
    check on catalog/figures/<slug>.png retires here, so absence becomes
    information instead of silence.

    A figure entry is recorded on a gate PASS only (the gate is
    the only painter's license; the manifest layer enforces it and hard-
    errors on a pass without its figure), so its presence paints and
    every other recorded verdict renders the honest note: the verdict
    badge (TEXT carries identity, color never alone) plus the recorded
    cause VERBATIM.  The four note kinds follow the wall-gate rule — no-wall-data
    (note), mesh unsupported (reason, carries the dims), mesh unreadable
    (error), gate failed (the recorded worst_rel/tol, never re-derived).
    """
    if not wg:
        return ""            # pre-gate manifest: nothing recorded
    if wg.get("figure"):
        return (
            '<figure><img src="wall_loads.png" alt="Wall-loading figure" '
            'loading="lazy" decoding="async">'
            "<figcaption>Wall contour (R–Z) and per-segment loading; every "
            "number on this page comes from the manifest JSON, units per "
            "FORMATS.md (solps.tex :5044-5082).</figcaption></figure>"
        )
    verdict = wg.get("verdict")
    if verdict == "no-wall-data":
        cause = wg.get("note") or "no fort.44 wall-load section recorded"
    elif verdict == "unsupported":
        cause = wg.get("reason") or "mesh not supported"
    elif verdict == "unreadable":
        cause = wg.get("error") or "family mesh unreadable"
    elif verdict == "fail":
        cause = (f"gate failed: worst rel {wg['worst_rel']:.1e} exceeds "
                 f"tol {wg['tol']:.1e} across the six block-3a surfaces "
                 "(computed areas vs the run's own wlareas)")
    else:
        cause = f"verdict {verdict!r} not recognized by the site"
    return ('<p class="sub">wall figure not generated: '
            f"{badge(verdict)} {html.escape(cause)}</p>")


def input_deck_section(m: dict, deck: dict, title: str = "Input deck") -> str:
    """the deck block — since checkpoint B the FAMILY page's base
    anchor (rendered once per family; the run pages carry the
    vs-base delta instead).

    Every value rendered comes from manifest JSON — the deck path from the
    run manifest, everything else from the deck manifest itself; nothing is
    re-derived from the filesystem.  Runs whose input_deck is null never
    render this block (honest absence, not a blank section).
    """
    geom = deck.get("geometry")
    if geom:
        geom_s = (f'present: <span class="mono">b2fgmtry</span>, '
                  f'{fmt_bytes(geom["bytes"])}, md5 '
                  f'<span class="mono">{short_md5(geom["md5"])}</span>')
    else:
        geom_s = "absent (no b2fgmtry in the deck)"
    rows = "\n".join(
        f'<tr><td class="mono">{html.escape(n)}</td>'
        f'<td class="num">{fmt_bytes(v["bytes"])}</td>'
        f'<td class="mono">{short_md5(v["md5"])}</td></tr>'
        for n, v in sorted((deck.get("files") or {}).items())
    )
    return (
        f"<h2>{title}</h2>\n"
        + kv_rows([
            ("family", f'<span class="mono">{html.escape(str(deck.get("run_family") or "—"))}</span>'),
            ("deck", f'<span class="mono">{html.escape(str(deck.get("name") or "—"))} · '
                     f'{html.escape(str(m.get("input_deck") or "—"))}</span>'),
            ("geometry", geom_s),
            ("files", f'{deck.get("file_count", "—")} files, '
                      f'{fmt_bytes(deck.get("total_bytes") or 0)} total'),
            ("linkage", html.escape(str(deck.get("note") or "—"))),
        ])
        + ('<table>\n<thead><tr><th>Deck file</th><th class="num">Size</th>'
           "<th>MD5 (short)</th></tr></thead>\n"
           f"<tbody>\n{rows}\n</tbody>\n</table>" if rows else "")
    )


def default_cell(e: dict) -> str:
    """the documented-default cell for ONE run-page switches row.

    The value renders VERBATIM from the artifact's additive `default`
    key; styling comes from DATA SHAPE, never re-classification (the
    vs_default badge already carries the classification): a usable
    default takes the mono numeric style, MUTED when the row is `same`
    (the value cell already shows the same number — the differs and
    no-default rows stay the visual headline); a prose default
    (`^See description`, the measured forms) renders as prose,
    never number-like; a null default and the unknown names (key
    absent — they sit in the ledger below) both render an em dash,
    never a guess.
    """
    if "default" not in e:
        return '<td class="ddef">—</td>'
    d = e["default"]
    if d is None:
        return '<td class="ddef">—</td>'
    d = str(d)
    if d.startswith("See description"):
        return f'<td class="ddef ddef-prose">{html.escape(d)}</td>'
    cls = "ddef ddef-val" + (" ddef-mute" if e["vs_default"] == "same" else "")
    return f'<td class="{cls}">{html.escape(d)}</td>'


def default_span(d) -> str:
    """the documented default for ONE switches-page row header.

    The default is a per-SWITCH property, so it appears ONCE per row,
    beside the anchor name (run chips unchanged).  Same shape-driven
    styling as default_cell, but NO mute: same-ness is per run-entry and
    this row aggregates many runs — nothing here is redundant with a
    chip.  Wording is "documented default" (owner ruling 2026-09-29:
    the inventory is 3.0.10 while the decks span older code).
    """
    if d is None:
        return '<span class="ddef">documented default —</span>'
    d = str(d)
    if d.startswith("See description"):
        return (f'<span class="ddef ddef-prose">documented default '
                f"{html.escape(d)}</span>")
    return f'<span class="ddef ddef-val">documented default {html.escape(d)}</span>'


def switches_section(entry: dict | None) -> str:
    """the run page's Switches block (run -> switches direction).

    Rendered ONLY from the run's out/switchsets.json entry — nothing is
    re-parsed or re-derived.  Values pass through VERBATIM (the page
    mirrors, never interprets: '1.' stays '1.', quoting never stripped,
    '5.00E-07' keeps its case).  The FULL table ships (the Files-table
    precedent: no truncation at any size), with semantic th/scope
    headers and badge-TEXT identity (color never alone).  adds
    the "documented default" column beside the value (default_cell —
    displayed, never re-compared; the vs_default badges are unchanged).
    The honest-absence ledgers render verbatim too — unknown names and
    the documented:false count + names are never summarized away.  A
    run with no artifact entry renders the not-assessed note instead,
    never an empty table (the honest-absence pattern).
    """
    if entry is None:
        return (SWITCHES_HEAD + "\n"
                '<p class="sub">Not assessed: no entry for this run in '
                '<span class="mono">out/switchsets.json</span>.</p>')
    switches = entry["switches"]
    tallies = Counter(e["vs_default"] for e in switches.values())
    chips = " · ".join(f"{badge(v)} {tallies.get(v, 0)}" for v in VS_DEFAULT_ORDER)
    rows = "\n".join(
        f'<tr><td class="mono">{html.escape(name)}</td>'
        f'<td class="mono">{html.escape(e["value"])}</td>'
        f"{default_cell(e)}"
        f'<td>{html.escape(e["source_file"])}</td>'
        f'<td>{badge(e["vs_default"])}</td></tr>'
        for name, e in switches.items()
    )
    parts = [
        SWITCHES_HEAD,
        '<p class="sub">Switches the run\'s effective <span class="mono">b2mn.dat</span> '
        "sets, joined to the documented defaults: values verbatim from "
        '<span class="mono">out/switchsets.json</span> (schema '
        '<span class="mono">catalog-switchsets/1</span>).</p>',
        kv_rows([
            ("switches set", f'{entry["switch_count"]}'),
            ("vs default", chips),
        ]),
        '<table class="switches">\n<thead><tr><th scope="col">Switch</th>'
        '<th scope="col">Value</th><th scope="col">documented default</th>'
        '<th scope="col">Source</th>'
        '<th scope="col">vs default</th></tr></thead>\n'
        f"<tbody>\n{rows}\n</tbody>\n</table>",
    ]
    unknown = entry.get("unknown_to_inventory") or []
    if unknown:
        parts.append(
            '<p class="sub">Unknown to the documented switch inventory '
            "(value read from the deck, no default to join):</p>\n"
            '<ul class="skips">\n'
            + "\n".join(f'<li><span class="mono">{html.escape(n)}</span></li>'
                        for n in unknown)
            + "\n</ul>")
    df = entry.get("documented_false") or {}
    if df.get("count"):
        parts.append(
            f'<p class="sub">documented:false in the inventory; value read, '
            f'no default recorded ({df["count"]}):</p>\n'
            '<ul class="skips">\n'
            + "\n".join(f'<li><span class="mono">{html.escape(n)}</span></li>'
                        for n in df.get("switches") or [])
            + "\n</ul>")
    return "\n".join(parts)


def build_switches_page(switchsets: dict, artifact_md5: str) -> str:
    """the switch -> runs direction — one page indexing every
    switch any cataloged run sets.

    The row set and their order are the artifact's inverted_index keys
    in the artifact's OWN key order (name-ascending as shipped; the page
    never sorts — by value or count — and never re-derives the index by
    scanning run entries).  Per row, the runs setting the switch render
    as FAMILY/member = value chips in the pairs array's own order, each
    linking its run page (the pinned href rule: %2B slugs + explicit
    index.html); the vs_default badge is a pure LOOKUP into the run
    entries' switches[name].vs_default — a join of two artifact blocks,
    never re-computed.  Values pass through VERBATIM ('1.' stays '1.',
    quoting never stripped).  each row carries the switch's
    documented default ONCE in its header cell (default_span — a
    per-switch property, never per chip), same shape-driven prose/em-
    dash styling as the run-page column.  Anchors carry citation-
    linking: one id per switch name plus a quote()d self-link (the url
    rule applied to fragments, so a future name outside [a-z0-9_] hits
    the rule, never a crash).  The honest-absence footnote and
    provenance footer render from the artifact's own blocks (counts /
    provenance.inventory).
    """
    inv = switchsets["inverted_index"]
    counts = switchsets["counts"]
    rows = []
    for name, pairs in inv.items():
        chips = []
        for p in pairs:
            run = p["run"]
            slug = "__".join(run.split("/"))
            vs = switchsets["runs"][run]["switches"][name]["vs_default"]
            chips.append(
                # the page sits ONE under the site root (switches/);
                # the run pages' depth-3 prefix would climb two levels
                # above the site — caught live by C's href sweep
                f'<a class="mono" href="../{url(run)}/index.html">'
                f"{html.escape(run)}</a>"
                f'<span class="mono"> = {html.escape(p["value"])}</span> {badge(vs)}'
            )
        rows.append(
            f'<tr id="{html.escape(name, quote=True)}">'
            f'<td class="mono">{html.escape(name)} '
            f'<a class="fn" href="#{url(name)}">#</a>'
            f"<br>{default_span(pairs[0].get('default'))}</td>"
            f"<td>{'<br>'.join(chips)}</td></tr>"
        )
    # unknown_to_inventory names are never inverted-index keys; the
    # footnote names them verbatim WITH the runs that set them (runs in
    # artifact order, first-occurrence order for the names themselves).
    unknown: dict[str, list[str]] = {}
    for run, entry in switchsets["runs"].items():
        for n in entry.get("unknown_to_inventory") or []:
            unknown.setdefault(n, []).append(run)
    unknown_items = "\n".join(
        f'<li><span class="mono">{html.escape(n)}</span>: '
        + ", ".join(
            f'<a class="mono" '
            f'href="../{url(r)}/index.html">'
            f"{html.escape(r)}</a>" for r in runs)
        + "</li>"
        for n, runs in unknown.items())
    ledger = " · ".join(f"{badge(v)} {counts.get(v, 0)}" for v in VS_DEFAULT_ORDER)
    prov = switchsets["provenance"]["inventory"]
    rows_html = "\n".join(rows)
    head = (
        '<p class="kicker">Catalog · switch index</p>\n'
        "<h1>Switch index</h1>\n"
        '<p class="sub">Every switch any cataloged run sets, and which runs '
        "set it to what: the switch -&gt; runs direction of the join, rendered "
        "read-only from <span class=\"mono\">out/switchsets.json</span> "
        '(schema <span class="mono">' + html.escape(switchsets["schema"])
        + ").  One ledger over every cataloged run: whichever groups this "
        "build carries (your folders and the shipped reference set alike "
        "), all of their switches sit in the one table below.</p>"
    )
    toolbar = (
        '<div class="toolbar" data-filter-scope>\n'
        '<input type="search" data-filter-input aria-label="Filter switches" '
        'placeholder="Filter switches: name, run, value…">\n'
        # one chip per vs_default value (the homepage toolbar's
        # pattern — value + count, tint declared per chip so the active
        # state paints in its filter's color), in the artifact's enum
        # order — the same order the page's own ledger line uses.
        + "".join(
            f'<button type="button" class="fchip" data-filter-contains="{v}"'
            f' style="--fbg:{BADGES[v][0]};--fik:{BADGES[v][1]}">'
            f"{v} {counts.get(v, 0)}</button>\n"
            for v in VS_DEFAULT_ORDER)
        + '<span class="fcount" data-filter-count aria-live="polite"></span>'
        "\n</div>\n")
    # the documented-but-unset block renders only when the
    # artifact carries the additive keys (synthetic minimal fixtures
    # predate them; the shipped artifact always has them).
    ds = counts.get("documented_switches")
    unset_block = ([
        "<h2>Set by none of the runs</h2>",
        f'<p class="sub">The documented inventory carries '
        f'{ds} switches; '
        f'{counts["distinct_switches_set"]} appear above and the remaining '
        f'{counts["documented_not_set"]} are set by none of the '
        f'{counts["runs"]} cataloged runs: live documented options these '
        "decks never turn on, not obsolete names.  Listed in inventory "
        "order; the documentation face carries their citations:</p>",
        f'<details class="unset"><summary>show the '
        f'{counts["documented_not_set"]} names</summary>'
        '<p class="unset-names">'
        + '<span class="mono"> · </span>'.join(
            f'<span class="mono">{html.escape(n)}</span>'
            for n in switchsets.get("documented_not_set") or [])
        + "</p></details>",
    ]) if ds else []
    # the rail sub-menu anchors — section[id] targets, so the
    # scroll offset clears the sticky topbar on jump-in
    unset_html = ('<section id="unset">\n' + "\n".join(unset_block)
                  + "\n</section>") if unset_block else ""
    return page("SOLPS-ITER switch index", head, "\n".join([
        # the indexed block gains its own title — the four
        # anchored sections now behave identically for the body
        # title highlight
        '<section id="switches-indexed">\n<h2>Switches indexed</h2>\n'
        + kv_rows([
            ("switches indexed", f'{counts["distinct_switches_set"]}'),
            ("runs", f'{counts["runs"]}'),
            ("row order", "switch name ascending: the artifact's own "
                          "inverted_index key order (sorting is client-side)"),
        ]),
        toolbar,
        '<table class="switches" data-sort data-filter>\n'
        '<thead><tr><th scope="col">Switch</th>'
        "<th scope=\"col\">Runs setting it: family/member = value, "
        'vs default</th></tr></thead>\n'
        f"<tbody>\n{rows_html}\n</tbody>\n</table>\n</section>",
        # the honest-absence prose SPLITS — the ledger line stands
        # alone (badges + counts), the never-indexed explanation is its
        # own paragraph; the provenance run-on becomes a kv table (one
        # row per source, md5s in their own cells — the page's own
        # header pattern).
        '<section id="honest-absence">\n<h2>Honest absence</h2>',
        f'<p class="sub">Ledger over all {sum(counts[v] for v in VS_DEFAULT_ORDER)} '
        f"switch entries:<br>{ledger}.</p>",
        '<p class="sub">Names unknown to the documented switch '
        "inventory are never inverted-index keys: index keys are exactly "
        "the documented citation names, so a citation can always name its "
        "switch; these are honest version drift, listed verbatim with the "
        "runs that set them:</p>",
        f'<ul class="skips">\n{unknown_items}\n</ul>' if unknown_items
        else '<p class="sub">none</p>',
        "\n</section>",
        unset_html,
        '<section id="provenance">\n<h2>Provenance</h2>',
        kv_rows([
            ("values", "verbatim from each run's effective "
                       '<span class="mono">b2mn.dat</span>: whole-file '
                       "resolution per the artifact's rules block"),
            ("defaults", "Documented defaults verbatim from the pinned "
                         "inventory below, which documents SOLPS-ITER "
                         "3.0.10; decks from older code may differ"),
            ("artifact", 'documented-switch artifact '
                         f'<span class="mono">out/switchsets.json</span>, '
                         f'md5 <span class="mono">{artifact_md5}</span>'),
            ("inventory", f'<span class="mono">{html.escape(prov["path"])}</span> '
                          f'(schema <span class="mono">'
                          f'{html.escape(prov["schema"])}</span>), md5 '
                          f'<span class="mono">{prov["md5"]}</span>'),
            ("rendering rules", '<span class="mono">catalog/FORMATS.md</span> '
                                "§ “SwitchView switch-view + "
                                "documented-defaults rules”"),
        ]) + "\n</section>",
        '<footer>Generated by <span class="mono">catalog/build_catalog.py</span> '
        "from the inverted_index of <span class=\"mono\">out/switchsets.json</span> "
        ": never recomputed from the run decks.</footer>",
    ]), root="../", active="switches",
        crumbs=(("Switch index", None),))


def build_recorded_compare_page(
        rc: dict, deck_root: Path,
        codes: tuple[str | None, str | None] | None = None) -> str:
    """one recorded A/B comparison page — the compare verb's deck,
    rendered exactly like a family comparison (summary verbatim,
    figures in the summary's own field order, everything from the
    index.json recorded_comparisons entry; the deck is staged, never
    recomputed).  ``codes`` carries the two legs' fort.44 git stamps
    from the runs' index entries (the recorded pair's release-comparison
    role): when they differ, the CODE-DELTA line
    names both — equal stamps render nothing."""
    a, b = rc["a"], rc["b"]
    files = rc.get("files") or {}
    figures = "\n".join(
        f'<figure><img src="{k}.png" alt="state diff field {html.escape(k)}" '
        'loading="lazy" decoding="async">'
        "<figcaption><span class=\"mono\">" + html.escape(k) + "</span>: A "
        "(left) vs B (middle) on a shared color scale, B−A (right) "
        'diverging; staged deck artifact, md5 <span class="mono">'
        + short_md5((files.get(f"{k}.png") or {}).get("md5"))
        + "</span></figcaption></figure>"
        for k in rc.get("fields") or []
    )
    summary = (deck_root / "diff_summary.txt").read_text(encoding="utf-8")
    kv = [
        ("A (before)", f'<span class="mono">{html.escape(a)}</span>'),
        ("B (after)", f'<span class="mono">{html.escape(b)}</span>'),
    ]
    if codes is not None and codes[0] != codes[1]:
        def _stamp(v: str | None) -> str:
            return (f'<span class="mono">{html.escape(v)}</span>'
                    if v else "no code stamp")
        kv.append((
            "code", f"A {_stamp(codes[0])} · B {_stamp(codes[1])}"
            ": the legs rode different code; the state deltas below "
            "include the code's contribution, not only input "
            "differences"))
    kv += [
        ("figures", f'{rc.get("n_figures", "—")} field figures'),
        ("summary", f'{rc.get("summary_lines", "—")} lines: staged '
                    "verbatim below"),
        ("deck", f'<span class="mono">{html.escape(str(rc.get("deck")))}</span>'
                 f": {len(files)} files, md5-pinned in index.json"),
        ("note", html.escape(str(rc.get("note") or "—"))),
    ]
    head = (
        '<p class="kicker">Catalog · recorded A/B comparison</p>\n'
        f'<h1>{html.escape(a)} vs {html.escape(b)}</h1>\n'
        '<p class="sub">A/B plasma-state comparison recorded with '
        '<span class="mono">solps-reader catalog compare</span>: '
        f'<span class="mono">{html.escape(a)}</span> (A) -&gt; '
        f'<span class="mono">{html.escape(b)}</span> (B)</p>'
    )
    return page(f"{a} vs {b} · state comparison", head, "\n".join([
        kv_rows(kv),
        "<h2>Diff summary (diff_summary.txt, verbatim)</h2>",
        f'<pre class="mono">{html.escape(summary)}</pre>',
        f"<h2>Field figures</h2>\n{figures}",
        '<footer>Generated by <span class="mono">catalog/build_catalog.py</span> '
        "from the index.json recorded_comparisons entry: the deck itself "
        'is a staged artifact of <span class="mono">build_diff_decks.py'
        "</span> (SOLPS-Reader state diff), never recomputed.</footer>",
    ]), root="../../", active="comparisons",
        active_child=f"compare/{url(rc['deck'].split('/')[-1].removesuffix('__diff'))}/index.html",
        crumbs=(("Comparisons", "index.html#comparisons"),
                (f"{a} vs {b}", None)))


def build_comparison_page(comp: dict, deck_root: Path,
                          glabel: str | None = None) -> str:
    """one family's A/B state-diff page.

    Structure and every number render from the index.json comparisons
    entry only (pair, deck inventory, figure order — build_manifests
    recorded them); diff_summary.txt renders VERBATIM in a <pre> block,
    read from the staged deck itself — a staged artifact, never
    recomputed.  Figure order follows the summary's own ``fields`` line
    (the CLI's catalog order te, ti, ne, na_k..., po), not filename
    order — na_10 would sort between na_1 and na_2.

    The deck is the FAMILY'S PROPERTY (checkpoint C, the two-homes
    rule): the page marks its own A/B ITEM under its family in the
    rail tree (owner review of C — the tree is the deck's discovery)
    and carries the lineage crumb chain (Catalog > group > family)
    like every other family-owned page.
    """
    fam = comp["run_family"]
    gslug, _, fam_name = fam.partition("/")
    files = comp.get("files") or {}
    pair_a, pair_b = comp["pair"]
    figures = "\n".join(
        f'<figure><img src="{k}.png" alt="state diff field {html.escape(k)}" '
        'loading="lazy" decoding="async">'
        "<figcaption><span class=\"mono\">" + html.escape(k) + "</span>: A "
        "(left) vs B (middle) on a shared color scale, B−A (right) "
        'diverging; staged deck artifact, md5 <span class="mono">'
        + short_md5((files.get(f"{k}.png") or {}).get("md5"))
        + "</span></figcaption></figure>"
        for k in comp.get("fields") or []
    )
    summary = (deck_root / "diff_summary.txt").read_text(encoding="utf-8")
    head = (
        '<p class="kicker">Catalog · family A/B comparison</p>\n'
        f'<h1>{html.escape(fam)}</h1>\n'
        '<p class="sub">A/B plasma-state comparison: '
        f'<span class="mono">{html.escape(pair_a)}</span> (A) -&gt; '
        f'<span class="mono">{html.escape(pair_b)}</span> (B)</p>'
    )
    return page(f"{fam} · state comparison", head, "\n".join([
        kv_rows([
            ("A (before)", f'<span class="mono">{html.escape(pair_a)}</span>'),
            ("B (after)", f'<span class="mono">{html.escape(pair_b)}</span>'),
            ("figures", f'{comp.get("n_figures", "—")} field figures '
                        "(4 + ns: te, ti, ne, po + one na per species)"),
            ("summary", f'{comp.get("summary_lines", "—")} lines: staged '
                        "verbatim below"),
            ("deck", f'<span class="mono">{html.escape(str(comp.get("deck")))}</span>'
                     f": {len(files)} files, md5-pinned in index.json"),
            ("note", html.escape(str(comp.get("note") or "—"))),
        ]),
        "<h2>Diff summary (diff_summary.txt, verbatim)</h2>",
        f'<pre class="mono">{html.escape(summary)}</pre>',
        f"<h2>Field figures</h2>\n{figures}",
        '<footer>Generated by <span class="mono">catalog/build_catalog.py</span> '
        "from the index.json comparisons entry: the deck itself is a staged "
        'artifact of <span class="mono">build_diff_decks.py</span> (SOLPS-Reader '
        "state diff), never recomputed.</footer>",
    ]), root="../../../", active="runs", active_ab=(gslug, fam_name),
        crumbs=((html.escape(glabel or gslug), f"{url(gslug)}/index.html"),
                (html.escape(fam_name), f"{url(gslug)}/{url(fam_name)}/index.html"),
                ("A/B comparison", None)))


def _stamp_line(s: dict) -> str:
    """one header stamp + its resolution as a text line.

    Everything after the em dash renders from the codediff JSON's own
    fields: a resolved stamp names its repo/commit/subject; every other
    state renders the block's `note` VERBATIM (the layer's own honest
    sentence — dirty / unresolved / no-stamp / read-error).
    """
    res = s.get("resolution") or {}
    head = (f'<span class="mono">{html.escape(str(s.get("file")))} '
            f'git {html.escape(str(s.get("git_stamp") or "—"))}</span>')
    if res.get("state") == "resolved":
        hit = res["hit"]
        return (f"{head} — resolved in "
                f'<span class="mono">{html.escape(hit["repo"])}</span> '
                f'({html.escape(hit["commit"][:12])}…, '
                f'“{html.escape(hit["subject"])}”)')
    return f"{head} — {html.escape(str(res.get('note') or res.get('state')))}"


def _codediff_side(which: str, side: dict | None) -> list[str]:
    """one case side's code state as honest <li> lines."""
    if not side:
        return [f"<li>{which} side: no codediff block recorded</li>"]
    st = side.get("side_state")
    if st == "extracted":
        out = [f"<li>{which} side: extracted — stamps read from its "
                "run dir(s), with each stamp's resolution:</li>"]
        for run in side.get("runs") or []:
            out.append(
                f'<li><span class="mono">{html.escape(run["run"])}</span>'
                + "".join(f"<br>&nbsp;&nbsp;{_stamp_line(s)}"
                          for s in run.get("stamps") or [])
                + "</li>")
        return out
    if st == "skipped":
        return [f"<li>{which} side: skipped "
                f'(<span class="mono">{html.escape(str(side.get("skip_kind")))}</span>)'
                f" — {html.escape(str(side.get('reason')))}</li>"]
    return [f"<li>{which} side: {html.escape(str(st))} — "
            f"{html.escape(str(side.get('note')))}</li>"]


def _deck_side(which: str, side: dict | None) -> str:
    """one case side's deck outcome as one honest line."""
    if not side:
        return f"{which} side: no deck block recorded"
    oc = side.get("outcome")
    if oc == "extracted":
        conv = side.get("convergence") or {}
        verdicts = ", ".join(
            f'<span class="mono">{html.escape(run)}</span>: '
            f"{badge((v or {}).get('verdict'))}"
            for run, v in sorted(conv.items()))
        return f"{which} side: extracted — {verdicts or 'no run dirs'}"
    if oc == "skipped":
        return (f"{which} side: skipped "
                f'(<span class="mono">{html.escape(str(side.get("skip_kind")))}</span>)'
                f" — {html.escape(str(side.get('skip_reason')))}")
    return f"{which} side: {html.escape(str(oc))} — {html.escape(str(side.get('note')))}"


def _fmt_stat(v: float | None) -> str:
    """One recorded float as a compact display form (3 significant
    digits — a rendering of the JSON value, never a new number)."""
    return "—" if v is None else f"{v:.3g}"


def _card_code_line(code: dict) -> str:
    """The analyzed card's version-jump line: stamp_pairs where both
    sides resolved (repo, short commits, compare link); else the one
    present side's own stamps, compact — the honest absence rides the
    audit layer's verbatim side sentences."""
    pairs = code.get("stamp_pairs") or []
    if pairs:
        return "\n".join(
            f'<p class="sub"><span class="mono">{html.escape(p["repo"])}</span> '
            f'<span class="mono">{html.escape(p["old"]["commit"][:12])}…</span> → '
            f'<span class="mono">{html.escape(p["new"]["commit"][:12])}…</span>'
            + (f' · <a href="{html.escape(p["compare_url"])}">compare</a>'
               if p.get("compare_url") else "")
            + "</p>"
            for p in pairs)
    # one-sided: the present side's stamps, deduped by repo (first wins)
    for side in ("new", "old"):
        blk = code.get(side) or {}
        seen: dict[str, str] = {}
        for r in blk.get("runs") or []:
            for s in r.get("stamps") or []:
                res = s.get("resolution") or {}
                repo = ((res.get("hit") or res.get("base") or {}).get("repo"))
                label = str(repo or s.get("kind") or s.get("file"))
                seen.setdefault(label, s["git_stamp"])
        if seen:
            other = "old" if side == "new" else "new"
            chips = " · ".join(
                f'<span class="mono">{html.escape(k)}</span> '
                f'<span class="mono">{html.escape(v)}</span>'
                for k, v in seen.items())
            return (f'<p class="sub">{side}-side stamps: {chips}'
                    + f' — {other} side not comparable (see audit)</p>')
    return ""


def _conv_chips(conv: dict | None) -> str:
    """Convergence-at-a-glance: one badge per side, null honest."""
    conv = conv or {}
    out = []
    for side in ("old", "new"):
        v = (conv.get(side) or {}).get("verdict")
        out.append(f"{side} {badge(v)}")
    return " · ".join(out)


def _impact_rows(run: dict) -> list[str]:
    """Per-field rows for one analyzed run: delta stats (two-sided) or
    the says-so side stats (one-sided) — values from the page-data's
    impact block, rendered never re-derived."""
    two = run.get("comparison") == "two-sided"
    rows = []
    for f in run.get("fields") or []:
        name = f["field"]
        if two:
            d = f.get("delta_stats") or {}
            am = d.get("argmax") or {}
            argmax = ((f'({am.get("ix")}, {am.get("iy")})')
                      if am.get("ix") is not None else "—")
            rows.append(
                f'<tr><td class="mono">{html.escape(name)}</td>'
                f'<td class="num">{_fmt_stat(d.get("max_abs_rel"))}</td>'
                f'<td class="num">{_fmt_stat(d.get("mean_abs_rel"))}</td>'
                f'<td class="num">{argmax}</td></tr>')
        else:
            s = f.get("side_stats") or {}
            rows.append(
                f'<tr><td class="mono">{html.escape(name)}</td>'
                f'<td class="num">{_fmt_stat(s.get("min"))}</td>'
                f'<td class="num">{_fmt_stat(s.get("max"))}</td>'
                f'<td class="num">{_fmt_stat(s.get("mean"))}</td></tr>')
    return rows


def _wall_card(c: dict) -> str:
    """Layer 1: the wall-load deck's card block — per-run
    target-load tables (two-sided: flux AND density deltas with area
    changes flagged, never normalized; one-sided: the present side's
    loads + the fetch-to-compare note and driver command) and the case's
    wall figure.  Rendered from the page-data's wall block only."""
    wall = c.get("wall")
    if not wall:
        return ""
    parts = ["<h4>Wall loads — fort.44 target rows</h4>"]
    for r in wall.get("runs") or []:
        if r.get("comparison") == "two-sided":
            parts.append(
                f'<p class="sub"><span class="mono">{html.escape(r.get("run") or "")}</span>'
                " — both sides: per-loaded-row deltas (densities stay "
                "per-side, areas are compared never normalized)</p>"
                '<table class="comps">\n<thead><tr><th>Row</th>'
                '<th class="num">area old→new [m²]</th>'
                '<th class="num">flux old→new [s⁻¹]</th>'
                '<th class="num">Δflux rel</th>'
                '<th class="num">Δdens rel</th></tr></thead>\n<tbody>\n'
                + "\n".join(
                    _wall_delta_row(x) for x in r.get("rows") or [])
                + "\n</tbody>\n</table>")
        elif r.get("comparison") == "one-sided":
            one = r.get("one_sided") or {}
            side = one.get("side")
            side_blk = (r.get("wall") or {}).get(side) or {}
            rows = side_blk.get("loaded_rows_si") or []
            parts.append(
                f'<p class="sub"><span class="mono">{html.escape(r.get("run") or "")}</span>'
                f' — {html.escape(one.get("note") or "")}'
                f' (old side: {html.escape(str(one.get("absent_side_outcome")))})'
                f'; {html.escape(str(one.get("absent_side_reason") or ""))}</p>'
                f'<p class="sub">driver: <code class="mono">'
                f'{html.escape(one.get("driver_command") or "")}</code></p>'
                '<table class="comps">\n<thead><tr><th>Row</th>'
                '<th class="num">area [m²]</th>'
                '<th class="num">flux [s⁻¹]</th>'
                '<th class="num">density [m⁻² s⁻¹]</th></tr></thead>\n'
                "<tbody>\n"
                + "\n".join(_wall_load_row(x) for x in rows)
                + "\n</tbody>\n</table>")
        else:
            parts.append(
                f'<p class="sub"><span class="mono">{html.escape(r.get("run") or "")}</span>'
                f" — {html.escape(r.get('note') or 'no wall data')}</p>")
    fig = wall.get("figure")
    if fig:
        name = Path(fig["path"]).name
        parts.append(
            f'<figure><img src="{url(name)}" alt="wall loads {html.escape(name)}" '
            f'loading="lazy" decoding="async">'
            "<figcaption>target loads per release side — the wall deck's "
            'own figure (existing conventions); staged artifact, md5 '
            f'<span class="mono">{short_md5(fig.get("md5"))}</span></figcaption>'
            "</figure>")
    return "\n".join(parts)


def _wall_delta_row(x: dict) -> str:
    """One two-sided wall row: old→new areas and fluxes VERBATIM from
    the wall block, deltas as recorded rel values; an area change is
    flagged, never normalized away."""
    o, n = x.get("old"), x.get("new")
    area = ("—" if not o or not n else
            f'{o["area_m2"]:.2f}→{n["area_m2"]:.2f}'
            + (" ⚠" if x.get("area_changed") else ""))
    flux = ("—" if not o or not n else
            f'{o["particle_flux_s1"]:.2e}→{n["particle_flux_s1"]:.2e}')
    return (f'<tr><td class="mono">{x.get("row")}'
            f'{" · " + str((o or n or {}).get("isrftype")) if o or n else ""}'
            f'</td><td class="num">{area}</td>'
            f'<td class="num">{flux}</td>'
            f'<td class="num">{_fmt_stat(x.get("flux_rel"))}</td>'
            f'<td class="num">{_fmt_stat(x.get("density_rel"))}</td></tr>')


def _wall_load_row(x: dict) -> str:
    """One one-sided wall row — the present side's own loaded-row
    values, verbatim (density — when the area is unknown/zero)."""
    dens = x.get("particle_flux_density_m2_s1")
    dens_txt = f"{dens:.2e}" if dens is not None else "—"
    return (f'<tr><td class="mono">{x.get("row")} · {x.get("isrftype")}'
            f'</td><td class="num">{x.get("area_m2")}</td>'
            f'<td class="num">{x.get("particle_flux_s1"):.2e}</td>'
            f'<td class="num">{dens_txt}</td></tr>')


def _release_card(c: dict) -> str:
    """Layer 1: one ANALYZED case card — version jump, impact
    numbers, convergence chips per side, one embedded summary figure
    (or the deck record's honest skip lines when none exists)."""
    code, decks = c.get("code") or {}, c.get("decks") or {}
    analysis = c.get("analysis") or {}
    parts = [f'<h3>{html.escape(c["name"])} {badge(c["status"])}</h3>']
    line = _card_code_line(code)
    if line:
        parts.append(line)
    runs = analysis.get("runs") or []
    deck = decks.get("deck")
    for r in runs:
        one_sided = r.get("one_sided")
        if r.get("comparison") == "two-sided":
            head = ("max |Δ|/|A| per field (A = old side) — the summary "
                    "figure field is the most-moved one")
            cols = ("<th>Field</th><th class=\"num\">max rel</th>"
                    '<th class="num">mean rel</th><th class="num">argmax</th>')
        else:
            head = (html.escape(str((one_sided or {}).get("note")
                                   or "one-sided stats"))
                    + f' (old side: {html.escape(str((one_sided or {}).get("absent_side_outcome") or "?"))})'
                    + " — min/max/mean of the present side")
            cols = ("<th>Field</th><th class=\"num\">min</th>"
                    '<th class="num">max</th><th class="num">mean</th>')
        parts.append(
            f'<p class="sub"><span class="mono">{html.escape(r.get("run") or "")}</span>'
            f" — convergence: {_conv_chips(r.get('convergence'))}</p>"
            f'<p class="sub">{head}</p>'
            '<table class="comps">\n<thead><tr>' + cols +
            "</tr></thead>\n<tbody>\n"
            + "\n".join(_impact_rows(r))
            + "\n</tbody>\n</table>")
    # the ONE summary figure (the deck's most-moved field panel, the
    # page-data's recorded selection) — or the honest no-deck lines
    sel = analysis.get("summary_figure") or {}
    if deck and sel.get("field"):
        deck_dir = Path(deck["deck"]).name
        files = deck.get("files") or {}
        k = sel["field"]
        basis = ("most-moved field (max rel "
                 f'{_fmt_stat(sel.get("max_abs_rel"))})'
                 if sel.get("selected_by") == "most_moved"
                 else "deck's first field (no two-sided stats)")
        parts.append(
            f'<figure><img src="{url(deck_dir)}/{url(k)}.png" '
            f'alt="state diff field {html.escape(k)}" loading="lazy" decoding="async">'
            "<figcaption><span class=\"mono\">" + html.escape(k) + "</span> — "
            "old (left) vs new (middle) on a shared color scale, "
            'difference (right) diverging — the pair deck\'s '
            f"{basis}; staged deck artifact, md5 <span class=\"mono\">"
            + short_md5((files.get(f"{k}.png") or {}).get("md5"))
            + "</span>; the full deck rides this case's audit block</figcaption>"
            "</figure>")
    else:
        skips = ([_deck_side("old", decks.get("old")),
                  _deck_side("new", decks.get("new"))]
                 + [f'A/B pair <span class="mono">{html.escape(s["run"])}</span>: '
                    f"{html.escape(s['skipped'])}"
                    for s in decks.get("skipped_pairs") or []]
                 + [f'<span class="mono">{html.escape(u["run"])}</span> ({u["side"]}): '
                    f"{html.escape(u['skipped'])}"
                    for u in decks.get("unmatched") or []])
        parts.append('<p class="sub">No A/B state deck:</p>\n'
                     '<ul class="skips">\n'
                     + "\n".join(f"<li>{l}</li>" for l in skips if l)
                     + "\n</ul>")
    # the wall-load deck's block (tables + figure) — rendered
    # only when the join carries the wall layer (additive key).
    wall_html = _wall_card(c)
    if wall_html:
        parts.append(wall_html)
    return '<div class="card">\n' + "\n".join(parts) + "\n</div>"


def _case_audit(c: dict, deck_base: Path) -> str:
    """Layer 2: one case's full audit, collapsed — the publish
    narrative, the code delta (stamps + diffstats verbatim),
    and the whole deck (summary verbatim + every panel)."""
    code, decks = c.get("code") or {}, c.get("decks") or {}
    parts = []
    pairs = code.get("stamp_pairs") or []
    for p in pairs:
        parts.append(
            kv_rows([
                ("repo", f'<span class="mono">{html.escape(p["repo"])}</span>'),
                ("code", f'<span class="mono">{html.escape(p["old"]["commit"])}</span> '
                         f'({html.escape(str(p["old"].get("version")))}) → '
                         f'<span class="mono">{html.escape(p["new"]["commit"])}</span> '
                         f'({html.escape(str(p["new"].get("version")))})'),
                ("compare", (f'<a href="{html.escape(p["compare_url"])}">'
                             f'{html.escape(p["compare_url"])}</a>')
                            if p.get("compare_url") else "—"),
            ])
            + f'<pre class="mono">{html.escape(p.get("diffstat") or "")}</pre>')
    parts.append('<ul class="skips">\n'
                 + "\n".join(_codediff_side("old", code.get("old"))
                             + _codediff_side("new", code.get("new")))
                 + "\n</ul>")
    deck = decks.get("deck")
    if deck:
        deck_dir = Path(deck["deck"]).name
        files = deck.get("files") or {}
        summary = (deck_base / deck["deck"]
                   / "diff_summary.txt").read_text(encoding="utf-8")
        conv = deck.get("convergence") or {}
        parts.append(
            kv_rows([
                ("decked run", f'<span class="mono">{html.escape(deck["run"])}</span>'),
                ("A (old)", f'<span class="mono">{html.escape(deck["a"])}</span>'),
                ("B (new)", f'<span class="mono">{html.escape(deck["b"])}</span>'),
                ("converged in both releases?",
                 f'old {badge((conv.get("a") or {}).get("verdict"))} · '
                 f'new {badge((conv.get("b") or {}).get("verdict"))}'),
                ("figures", f'{deck.get("n_figures", "—")} field figures '
                            f'({deck.get("summary_lines", "—")}-line summary '
                            "staged verbatim below)"),
            ])
            + f'<pre class="mono">{html.escape(summary)}</pre>\n'
            + "\n".join(
                f'<figure><img src="{url(deck_dir)}/{url(k)}.png" '
                f'alt="state diff field {html.escape(k)}" loading="lazy" decoding="async">'
                "<figcaption><span class=\"mono\">" + html.escape(k) + "</span> — "
                "old (left) vs new (middle) on a shared color scale, "
                'difference (right) diverging; staged deck artifact, md5 '
                '<span class="mono">'
                + short_md5((files.get(f"{k}.png") or {}).get("md5"))
                + "</span></figcaption></figure>"
                for k in deck.get("fields") or []))
    else:
        parts.append('<p class="sub">No A/B state deck — sides recorded '
                     "above.</p>")
    return ('<details class="case">\n'
            f'<summary>{html.escape(c["name"])}</summary>\n'
            '<div class="pad">\n' + "\n".join(parts) + "\n</div>\n</details>")


def build_release_page(rp: dict, deck_base: Path, stem: str | None = None) -> str:
    """+ one release pair's report page as a triage
    instrument — verdict, scorecard, audit one click away.

    Layer 0 (masthead): the publish commit's own subject VERBATIM as
    the one-sentence answer + the changed/identical ledger as chips +
    the publish compare link; 12-char hash prefixes only.
    Layer 1 (scorecard): ANALYZED case cards (version jump, per-field numbers, convergence chips per side, ONE embedded summary
    figure — the deck's most-moved field panel, the page-data's
    recorded selection) and MANIFEST-ONLY cases as one compact table
    (name, short-md5 flip, status — one row each).
    Layer 2 (audit, collapsed <details>, pure HTML): the full md5
    table, per-case code deltas + publish narrative + the whole deck,
    the doc/LOG range, the publish pair — full hashes live ONLY here.

    Rendered ONLY from the committed page-data join
    (out/deltarun_pages/<stem>.json, schema catalog-deltarun-page/2) —
    every value, verdict and honest-absence sentence is that artifact's
    own field rendered verbatim; nothing is recomputed from the git
    history, the Zenodo records or the fetch cache.  The one thing read
    at build time is a RECORDED deck's own diff_summary.txt (staged
    verbatim, the comparison-page pattern — a staged artifact,
    never recomputed) from the deck path the artifact records.
    """
    old, new = rp["old"], rp["new"]
    cases = rp.get("cases") or []
    analyzed = [c for c in cases
                if (c.get("analysis") or {}).get("tier") == "analyzed"]
    manifest_only = [c for c in cases if c not in analyzed]
    c = rp.get("counts") or {}

    # ---- Layer 0: the verdict (masthead)
    subject = rp.get("publish_subject")
    verdict = (f'<p class="verdict">{html.escape(subject)}</p>' if subject
               else '<p class="verdict">publish commit subject not carried '
                    "by any changed tarball's narrative — see the audit "
                    "below</p>")
    chips = "".join(
        chip(k, v)
        for k, v in (("changed", c.get("changed", 0)),
                     ("identical", c.get("identical", 0)),
                     ("added", c.get("added", 0)),
                     ("removed", c.get("removed", 0))))
    compare = (f' · <a href="{html.escape(rp["publish_compare_url"])}">'
               "publish compare</a>"
               if rp.get("publish_compare_url") else "")
    head = (
        # depth-2 page (site/deltarun/<stem>/) — the catalog root is two
        # levels up (a bug repaired by protocol E pass:
        # the old ../index.html pointed at a nonexistent deltarun/index)
        '<p class="kicker">Catalog · release report</p>\n'
        "<h1>Release report</h1>\n"
        f'<p class="sub">Release-to-release regression over the public '
        f'example runs — <span class="mono">{html.escape(old[:12])}…</span> → '
        f'<span class="mono">{html.escape(new[:12])}…</span>{compare}</p>\n'
        f'<p class="chips">{chips}</p>\n{verdict}'
    )

    # ---- Layer 1: scorecard
    score = []
    if analyzed:
        score.append(f"<h2>Analyzed cases ({len(analyzed)})</h2>")
        score.append(
            '<p class="sub">Cases with at least one extracted side — '
            "Per-field impact numbers and per-side convergence "
            "before any figure; one summary figure per case (the deck's "
            "most-moved field panel) when a pair deck exists.</p>")
        score += [_release_card(c) for c in analyzed]
    if manifest_only:
        score.append(f"<h2>Manifest-only changes ({len(manifest_only)})</h2>")
        score.append(
            '<p class="sub">Changed by md5, neither side extracted — one '
            "row each; the full narrative and code state ride the audit "
            "below (12-char md5 prefixes here, full hashes there).</p>")
        row_buf = []
        for x in manifest_only:
            x_t = next((t for t in rp.get("tarballs") or []
                        if t["name"] == x["name"]), None)
            md5_cell = ("—" if x_t is None else
                        f'{short_md5(x_t["old_md5"])} → '
                        f'{short_md5(x_t["new_md5"])}')
            row_buf.append(
                "<tr>"
                f'<td class="mono">{html.escape(x["name"])}</td>'
                f'<td class="mono">{md5_cell}</td>'
                f"<td>{badge(x['status'])}</td>"
                "</tr>")
        rows = "\n".join(row_buf)
        score.append(
            '<table class="comps">\n<thead><tr><th>Tarball</th>'
            "<th>md5 (old → new)</th><th>Status</th></tr></thead>\n"
            f"<tbody>\n{rows}\n</tbody>\n</table>")

    # ---- Layer 2: the audit, collapsed
    audit = []
    audit.append(
        "<details class=\"audit\">\n<summary>Publish pair</summary>\n"
        '<div class="pad">\n'
        + kv_rows([
            ("old", f'<span class="mono">{html.escape(old)}</span>'),
            ("new", f'<span class="mono">{html.escape(new)}</span>'),
            ("publish compare",
             (f'<a href="{html.escape(rp["publish_compare_url"])}">'
              f'{html.escape(rp["publish_compare_url"])}</a>')
             if rp.get("publish_compare_url") else "—"),
            ("md5 files per side",
             f'{rp.get("old_n_md5_files", "—")} → {rp.get("new_n_md5_files", "—")}'),
        ])
        + "\n</div>\n</details>")
    # the driver's selection + budget record, verbatim from the
    # join's `selection` block (absent for pre-driver joins — stated,
    # never synthesized).
    sel = rp.get("selection")
    if sel:
        fc = sel.get("fetch_counts") or {}
        stages = "\n".join(
            f'<li><span class="mono">{html.escape(str(s.get("stage")))}</span> '
            f'{html.escape(str(s.get("script")))} '
            f'<span class="sub">({html.escape(str(s.get("cite")))})</span> → '
            f'<span class="mono">{html.escape(str(s.get("output")))}</span></li>'
            for s in sel.get("stages") or [])
        an = sel.get("analyze") or {}
        audit.append(
            '<details class="audit">\n<summary>Selection &amp; budget '
            "(driver)</summary>\n"
            '<div class="pad">\n'
            + kv_rows([
                ("command", f'<span class="mono">{html.escape(str(sel.get("command")))}</span>'),
                ("old side", f'<span class="mono">{html.escape(str((sel.get("old") or {}).get("input")))}</span>'
                 + (f' — version <span class="mono">{html.escape(str((sel.get("old") or {}).get("version")))}</span>'
                    if (sel.get("old") or {}).get("version") else " — raw sha")),
                ("new side", f'<span class="mono">{html.escape(str((sel.get("new") or {}).get("input")))}</span>'
                 + (f' — version <span class="mono">{html.escape(str((sel.get("new") or {}).get("version")))}</span>'
                    if (sel.get("new") or {}).get("version") else " — raw sha")),
                ("analyze",
                 f'{len(an.get("names") or [])} case(s)'
                 + (" (default: the ITER families)" if an.get("default")
                    else " (explicit)")),
                ("budgets",
                 f'per-tarball {int((sel.get("budgets") or {}).get("per_tarball", 0)) // (1 << 20)} MiB'
                 f' / total {int((sel.get("budgets") or {}).get("total", 0)) // (1 << 20)} MiB'),
                ("fetch", f'{fc.get("fetched", 0)} fetched / {fc.get("warm-cache", 0)} warm'
                 f' / {fc.get("skipped", 0)} skipped'
                 f' ({fc.get("downloaded_bytes", 0)} B downloaded)'),
            ])
            + '<p class="sub">Selected cases:</p>\n<ul class="skips">\n'
            + "\n".join(f'<li><span class="mono">{html.escape(n)}</span></li>'
                        for n in an.get("names") or [])
            + "\n</ul>\n"
            + '<p class="sub">Chain (every stage an existing script, cited):</p>\n'
            + '<ul class="skips">\n' + stages + "\n</ul>\n"
            + "\n</div>\n</details>")
    else:
        audit.append(
            '<details class="audit">\n<summary>Selection &amp; budget '
            "(driver)</summary>\n<div class=\"pad\">\n"
            '<p class="sub">no driver record — this join predates the '
            "one-command driver (built by the piecewise chain); the selection was the fetch script's "
            "own --only</p>\n</div>\n</details>")
    md5_rows = "\n".join(
        "<tr>"
        f'<td class="mono">{html.escape(t["name"])}</td>'
        f"<td>{badge(t['status'])}</td>"
        f'<td class="mono">{html.escape(t["old_md5"] or "—")}</td>'
        f'<td class="mono">{html.escape(t["new_md5"] or "—")}</td>'
        "</tr>"
        for t in rp.get("tarballs") or [])
    audit.append(
        "<details class=\"audit\">\n"
        f"<summary>Tarball md5 table ({len(rp.get('tarballs') or [])})</summary>\n"
        '<div class="pad">\n'
        '<p class="sub">Every published example tarball of the pair, both '
        "side's md5 verbatim from the repo's own "
        '<span class="mono">*.tar.gz.md5</span> pins (the Makefile publish '
        "rule) — unchanged tarballs stay listed: identical is information.</p>"
        '<table class="comps">\n<thead><tr><th>Tarball</th><th>Status</th>'
        "<th>md5 (old)</th><th>md5 (new)</th></tr></thead>\n"
        f"<tbody>\n{md5_rows}\n</tbody>\n</table>\n</div>\n</details>")
    case_audit = []
    for x in cases:
        t = next((y for y in rp.get("tarballs") or []
                  if y["name"] == x["name"]), {})
        subjects = "\n".join(
            f'<li><span class="mono">{html.escape(s["commit"][:12])}…</span> '
            f"{html.escape(s['subject'])}</li>"
            for s in t.get("subjects") or [])
        block = _case_audit(x, deck_base)
        if subjects:
            block = block.replace(
                '<div class="pad">\n',
                '<div class="pad">\n<ul class="skips">\n' + subjects
                + "\n</ul>\n", 1)
        case_audit.append(block)
    audit.append(
        "<details class=\"audit\">\n"
        f"<summary>Per-case code deltas + publish narrative ({len(cases)})"
        "</summary>\n<div class=\"pad\">\n"
        + "\n".join(case_audit)
        + "\n</div>\n</details>")
    ch = rp.get("changelog") or {}
    if ch.get("n_entries"):
        changelog_html = (
            f'<pre class="mono">{html.escape(ch.get("text") or "")}</pre>')
    else:
        changelog_html = (
            f'<p class="sub">none — the publish range carries '
            f'{ch.get("n_entries", 0)} <span class="mono">'
            f'{html.escape(str(ch.get("path")))}</span> entries.</p>')
    audit.append(
        "<details class=\"audit\">\n<summary>doc/LOG changelog range</summary>"
        f"\n<div class=\"pad\">\n{changelog_html}\n</div>\n</details>")

    sources = rp.get("sources") or {}
    join_name = f"out/deltarun_pages/{stem}.json" if stem else \
        "out/deltarun_pages/ (this pair's join)"
    footer = (
        '<footer>Generated by <span class="mono">catalog/build_catalog.py</span> '
        "from the committed page-data join "
        f'<span class="mono">{html.escape(join_name)}</span>'
        + (f' (schema {html.escape(str(rp.get("schema")))})'
           if rp.get("schema") else "")
        + " over the diff + codediff + pairdecks + impact layers "
        f'(<span class="mono">{html.escape(str(sources.get("diff")))}</span> …, '
        "catalog/FORMATS.md) — every value on this page comes "
        "from that artifact, never re-derived.</footer>")
    return page(f"Release report {old[:8]} → {new[:8]}", head,
                "\n".join(score + audit + [footer]),
                root="../../", active="releases",
                # no stem (synthetic fixtures) = no rail child to stamp
                active_child=(f"deltarun/{url(stem)}/index.html"
                              if stem else ""),
                crumbs=(("Release reports", "index.html#releases"),
                        (f"{html.escape(old[:12])}… → "
                         f"{html.escape(new[:12])}…", None)))


def stage_release_decks(rp: dict, pdir: Path, base: Path = HERE) -> int:
    """stage every deck the page-data records into the release
    page's dir — one subdir per deck, named after the deck's own
    directory (per-case subdirs, so same-named field PNGs cannot collide
    across cases).

    The deck source path and the doctrine inventory (bytes +
    md5) both come from the artifact; bytes are verified at copy time —
    a recorded-but-missing or size-drifted source fails loudly (the
    missing-input ruling).  Returns the number of decks staged.
    """
    n = 0
    for c in rp.get("cases") or []:
        deck = (c.get("decks") or {}).get("deck")
        if not deck:
            continue
        deck_root = base / deck["deck"]
        ddir = pdir / Path(deck["deck"]).name
        ddir.mkdir(parents=True, exist_ok=True)
        for name, entry in sorted((deck.get("files") or {}).items()):
            src = deck_root / name
            if not src.is_file() or src.stat().st_size != entry["bytes"]:
                raise SystemExit(
                    f"{src}: does not match the page-data inventory "
                    f"({entry['bytes']} B) — regenerate the release layers "
                    "before building the site")
            shutil.copy2(src, ddir / name)
        n += 1
    return n


def stage_wall_figures(rp: dict, pdir: Path, base: Path = HERE) -> int:
    """stage every wall figure the page-data records into the
    release page's dir (the stage_release_decks doctrine: bytes verified
    at copy time, a drifted or missing source fails loudly).  Returns
    the number of figures staged."""
    n = 0
    for c in rp.get("cases") or []:
        fig = (c.get("wall") or {}).get("figure")
        if not fig:
            continue
        src = base / fig["path"]
        if not src.is_file() or src.stat().st_size != fig["bytes"]:
            raise SystemExit(
                f"{src}: does not match the page-data inventory "
                f"({fig['bytes']} B) — regenerate the release layers "
                "before building the site")
        shutil.copy2(src, pdir / src.name)
        n += 1
    return n


def build_version_axis_page(
        releases: list[tuple[str, dict]],
        case_hist: dict[str, dict] | None = None) -> str:
    """the version-axis index — the pinned resolver axis, every
    BUILT release pair with its verdict line, and every unbuilt axis pair
    as an honest cell carrying the exact driver command for copy.

    Rendered from the resolver table pinned in the driver
    (build_release_report.RELEASE_VERSIONS — provenance config, like
    BADGES; never re-derived from git at build time) + the committed
    page-data joins.  A join matches an axis pair iff its (old, new)
    commits equal the pair's pinned commits — 12-char prefixes on this
    page, full hashes stay inside each report's own audit.  Joins built
    from raw shas the table does not name get their own honest section.

    adds the Case histories section (case_hist = the
    case_history_view output; computed from `releases` when not given):
    one row per tarball in the union of the joins' md5 tables, linking
    its screen with the stability verdict.
    """
    by_commit = {c: v for v, c in RELEASE_VERSIONS}
    joins = {(rp["old"], rp["new"]): (stem, rp) for stem, rp in releases}

    axis_rows = "\n".join(
        "<tr>"
        f'<td><span class="mono">{html.escape(v)}</span></td>'
        f'<td class="mono">{html.escape(c[:12])}…</td>'
        "</tr>"
        for v, c in RELEASE_VERSIONS)

    pair_rows = []
    built_on_axis: set[tuple[str, str]] = set()
    for i, (va, ca) in enumerate(RELEASE_VERSIONS):
        for vb, cb in RELEASE_VERSIONS[i + 1:]:     # axis order: old < new
            hit = joins.get((ca, cb))
            if hit:
                stem, rp = hit
                built_on_axis.add((ca, cb))
                subject = rp.get("publish_subject")
                verdict = (html.escape(subject) if subject
                           else '<span class="sub">publish subject not '
                                "carried by the narrative</span>")
                pair_rows.append(
                    "<tr>"
                    f'<td class="mono">{html.escape(va)} → {html.escape(vb)}</td>'
                    f'<td><a href="{url(stem)}/index.html">report</a></td>'
                    f"<td>{verdict}</td>"
                    "</tr>")
            else:
                cmd = (f"../.venv/bin/python build_release_report.py "
                       f"{va} {vb}")
                pair_rows.append(
                    "<tr>"
                    f'<td class="mono">{html.escape(va)} → {html.escape(vb)}</td>'
                    '<td><span class="sub">not built</span></td>'
                    f'<td><code class="mono">{html.escape(cmd)}</code>'
                    "</td>"
                    "</tr>")
    raw_rows = []
    for (old, new), (stem, rp) in sorted(joins.items()):
        if (old, new) in built_on_axis:
            continue
        subject = rp.get("publish_subject")
        verdict = (html.escape(subject) if subject
                   else '<span class="sub">publish subject not carried '
                        "by the narrative</span>")
        va, vb = by_commit.get(old), by_commit.get(new)
        names = " → ".join(html.escape(x or f"{c[:12]}…")
                           for x, c in ((va, old), (vb, new)))
        raw_rows.append(
            "<tr>"
            f'<td class="mono">{names}</td>'
            f'<td><a href="{url(stem)}/index.html">report</a></td>'
            f"<td>{verdict}</td>"
            "</tr>")

    n_built = len(built_on_axis) + len(raw_rows)
    head = (
        # depth-1 page (site/deltarun/) — the catalog root is one level up
        '<p class="kicker">Catalog · release version axis</p>\n'
        "<h1>Release version axis</h1>\n"
        '<p class="sub">The pinned version axis and every release pair on '
        "it — built reports first (the publish commit's own subject as the "
        "verdict line), the exact one-command build for the rest.  The "
        "driver's --analyze selection defaults to the ITER families; the "
        "fetch budget is decided at selection time.</p>\n"
        f'<p class="chips">{chip("versions", len(RELEASE_VERSIONS))}'
        f'{chip("pairs on axis", len(RELEASE_VERSIONS) * (len(RELEASE_VERSIONS) - 1) // 2)}'
        f'{chip("built reports", n_built)}</p>'
    )
    body = (
        "<h2>Versions</h2>\n"
        '<table class="comps">\n<thead><tr><th>Version</th>'
        "<th>Publish commit</th></tr></thead>\n<tbody>\n"
        + axis_rows
        + "\n</tbody>\n</table>\n"
        + "<h2>Version pairs</h2>\n"
        + '<p class="sub">Not-built cells carry the exact driver command '
        "for copy (default selection = the ITER families of that pair; "
        "narrow with --analyze, widen the budgets deliberately).</p>\n"
        + '<table class="comps">\n<thead><tr><th>Pair</th><th>Report</th>'
        + "<th>Verdict / build</th></tr></thead>\n<tbody>\n"
        + "\n".join(pair_rows)
        + "\n</tbody>\n</table>\n"
        + ("<h2>Reports built off the pinned axis</h2>\n"
           '<p class="sub">Joins whose commits the resolver table does not '
           "name (built from raw shas — e.g. a prep commit inside a "
           "version's window); no version label is invented for "
           "them.</p>\n"
           '<table class="comps">\n<thead><tr><th>Pair</th><th>Report</th>'
           "<th>Verdict</th></tr></thead>\n<tbody>\n"
           + "\n".join(raw_rows)
           + "\n</tbody>\n</table>\n" if raw_rows else "")
        + _axis_case_section(case_hist if case_hist is not None
                             else case_history_view(releases))
        + '<footer>Generated by <span class="mono">catalog/build_catalog.py'
        "</span> from the pinned resolver axis in "
        "<span class=\"mono\">build_release_report.py</span> + the committed "
        "page-data joins (catalog/FORMATS.md) — no git reads at "
        "build time, nothing re-derived.</footer>"
    )
    return page("SOLPS-ITER release version axis", head, body,
                root="../", active="axis",
                crumbs=(("Release reports", "index.html#releases"),
                        ("Release version axis", None)))


def _axis_case_section(case_hist: dict[str, dict]) -> str:
    """the axis page's Case histories section — one row per
    tarball across the committed joins, linking the screen with its
    stability verdict (the timeline-only line).  Empty input renders
    nothing (a site with no joins carries no case layer at all)."""
    if not case_hist:
        return ""
    rows = "\n".join(
        "<tr>"
        f'<td><a class="mono" href="cases/{url(name.removesuffix(".tar.gz"))}/index.html">'
        f"{html.escape(name.removesuffix('.tar.gz'))}</a></td>"
        f"<td>{html.escape(stability_verdict(h))}</td>"
        f'<td class="num">{len(h["transitions"])}</td>'
        "</tr>"
        for name, h in case_hist.items())
    return (
        f"<h2>Case histories ({len(case_hist)})</h2>\n"
        '<p class="sub">One screen per published tarball — its md5 '
        "timeline across every built pair, the analyzed deltas joined "
        "where they exist, one stability verdict (derived from the "
        "timeline only).  Run pages cross-link their family's screen.</p>"
        '\n<table class="comps">\n<thead><tr><th>Tarball</th>'
        "<th>Stability verdict</th>"
        '<th class="num">Observed pairs</th></tr></thead>\n<tbody>\n'
        + rows
        + "\n</tbody>\n</table>\n")


# --------------------- case-centric release history ----------------

def _axis_label(commit: str | None, version: str | None) -> str:
    """One pair side's display label: the version when the pinned
    resolver names the commit, else the 12-char prefix (the hash rule — full shas live only inside audit blocks)."""
    if not commit:
        return "—"
    return version if version else f"{commit[:12]}…"


def _pair_order(stem_rp: tuple[str, dict]) -> tuple[int, str]:
    """Deterministic join order for timelines: by the NEW side's axis
    position (a raw sha the table does not name sorts after every
    version — its pair window sits inside some version), stem-broken."""
    stem, rp = stem_rp
    for i, (_, c) in enumerate(RELEASE_VERSIONS):
        if c == rp.get("new"):
            return (i, stem)
    return (len(RELEASE_VERSIONS), stem)


def case_history_view(
        releases: list[tuple[str, dict]]) -> dict[str, dict]:
    """the per-tarball release history across EVERY committed
    page-data join — the input side of the case screens.

    Returns {tarball_name: {"transitions", "points", "analyses"}} with
    names sorted (screen + axis-row order).  Every value is a verbatim
    field of a join (schema catalog-deltarun-page/2: the embedded
    diff tarballs block, the analysis blocks) or a
    lookup of the pinned resolver — nothing is re-derived from git,
    Zenodo or the fetch cache.

    transitions: one per join carrying the tarball — the pair's sides
    (commits + resolver versions), both md5s, the status, in
    _pair_order sequence.  points: the deduped (commit, version, md5)
    observations in the same sequence, first occurrence winning (a
    commit's repo-pinned md5 is unique by construction, so a commit
    shared by two pairs never disagrees); an added/removed side has no
    md5 and contributes no point.  analyses: the analyzed
    blocks joined where they exist.
    """
    hist: dict[str, dict] = {}
    for stem, rp in sorted(releases, key=_pair_order):
        old_c, new_c = rp.get("old") or "", rp.get("new") or ""
        old_v = _VERSION_BY_COMMIT.get(old_c)
        new_v = _VERSION_BY_COMMIT.get(new_c)
        rows = {t["name"]: t for t in rp.get("tarballs") or []}
        cases = {c["name"]: c for c in rp.get("cases") or []}
        for name, t in rows.items():
            h = hist.setdefault(name,
                                {"transitions": [], "points": [],
                                 "analyses": []})
            h["transitions"].append({
                "stem": stem, "old": old_c, "new": new_c,
                "old_version": old_v, "new_version": new_v,
                "old_md5": t.get("old_md5"), "new_md5": t.get("new_md5"),
                "status": t.get("status"),
                "subjects": t.get("subjects") or []})
            seen = {p["commit"] for p in h["points"]}
            for commit, ver, md5 in ((old_c, old_v, t.get("old_md5")),
                                     (new_c, new_v, t.get("new_md5"))):
                if md5 is None or commit in seen:
                    continue        # one-sided (added/removed) or dedupe
                h["points"].append({"commit": commit, "version": ver,
                                    "md5": md5})
                seen.add(commit)
            c = cases.get(name)
            if c and (c.get("analysis") or {}).get("tier") == "analyzed":
                h["analyses"].append({
                    "stem": stem, "old": old_c, "new": new_c,
                    "old_version": old_v, "new_version": new_v,
                    "analysis": c["analysis"]})
    return {name: hist[name] for name in sorted(hist)}


def stability_verdict(h: dict) -> str:
    """The ONE stability line, derived from the timeline ONLY (never
    from the analysis tier, sizes or any other layer):

      - no observed transition changed the bytes -> "unchanged since
        <first observed point>" (version label when the resolver names
        the commit, else the 12-char prefix);
      - a majority of observed transitions changed -> "changes most
        releases" with the honest count;
      - anything else -> the honest count alone.
    """
    trs = h["transitions"]
    n = len(trs)
    changed = sum(1 for t in trs if (t.get("status") or "") != "identical")
    pairs = f"observed pair" + ("s" if n != 1 else "")
    if n and not changed:
        p = h["points"][0]
        return f"unchanged since {_axis_label(p['commit'], p['version'])}"
    if n and changed * 2 > n:
        return f"changes most releases — changed in {changed} of {n} {pairs}"
    return f"changed in {changed} of {n} {pairs}"


def _case_delta_block(a: dict) -> str:
    """One joined analysis entry as compact HTML: the pair (labelled,
    linked to its full report) + per-run tables — the same
    _impact_rows / _conv_chips rendering the report cards use, never a
    re-derivation."""
    label = " → ".join((_axis_label(a["old"], a["old_version"]),
                        _axis_label(a["new"], a["new_version"])))
    parts = [
        f'<p class="sub">Pair <a href="../../{url(a["stem"])}/index.html">'
        f"{html.escape(label)}</a> — analysis tier "
        '<span class="mono">analyzed</span> (full card on the report '
        "page)</p>"]
    for r in (a["analysis"].get("runs") or []):
        one = r.get("one_sided") or {}
        if r.get("comparison") == "two-sided":
            head = ("max |Δ|/|A| per field (A = old side)")
            cols = ('<th>Field</th><th class="num">max rel</th>'
                    '<th class="num">mean rel</th>'
                    '<th class="num">argmax</th>')
        else:
            head = (html.escape(str(one.get("note") or "one-sided stats"))
                    + f" (old side: {html.escape(str(one.get('absent_side_outcome') or '?'))})"
                    + " — min/max/mean of the present side"
                    + (f"; {html.escape(str(one.get('absent_side_reason')))}"
                       if one.get("absent_side_reason") else ""))
            cols = ('<th>Field</th><th class="num">min</th>'
                    '<th class="num">max</th><th class="num">mean</th>')
        parts.append(
            f'<p class="sub"><span class="mono">{html.escape(str(r.get("run") or ""))}</span>'
            f" — convergence: {_conv_chips(r.get('convergence'))}</p>"
            f'<p class="sub">{head}</p>'
            '<table class="comps">\n<thead><tr>' + cols +
            "</tr></thead>\n<tbody>\n"
            + "\n".join(_impact_rows(r))
            + "\n</tbody>\n</table>")
    return "\n".join(parts)


def build_case_screen(name: str, h: dict, family_runs: list[dict]) -> str:
    """one tarball's release-history screen — the benchmark
    question answered in one URL ("can I benchmark against this
    example?"): which versions changed its bytes, whether its physics
    was analyzed, one stability verdict.

    triage idiom: Layer 0 = the stability verdict + the
    transition ledger chips; Layer 1 = the md5 timeline table + the
    joined analyzed deltas; Layer 2 = the collapsed audit (publish
    narrative VERBATIM + full md5s — full hashes only here).  Rendered
    from case_history_view output only; the reverse cross-links list
    the catalog runs of the family (run family == tarball stem, the
    pinned mapping) or state their absence.
    """
    stem = name.removesuffix(".tar.gz")
    trs = h["transitions"]
    verdict = stability_verdict(h)

    run_links = " · ".join(
        f'<a class="mono" '
        f'href="../../../../../{url(r["name"])}/index.html">'
        f"{html.escape(r['name'])}</a>" for r in family_runs)
    runs_bit = (f"catalog runs: {run_links}" if family_runs
                else "no cataloged run benchmarks this tarball")
    tally = Counter(t["status"] or "?" for t in trs)
    chips = "".join(chip(k, tally.get(k, 0))
                    for k in ("changed", "identical", "added", "removed"))
    head = (
        '<p class="kicker">Catalog · case release history</p>\n'
        f'<h1>{html.escape(name)}</h1>\n'
        f'<p class="sub">Case-centric release history — which versions '
        f"changed this tarball's bytes, whether its physics moved, one "
        f'stability verdict · {runs_bit} · <a href="../../index.html">'
        "release version axis</a></p>\n"
        f'<p class="chips">{chips}</p>\n'
        f'<p class="verdict">{html.escape(verdict)}</p>'
    )

    tl_rows = "\n".join(
        "<tr>"
        f'<td class="mono">{html.escape(_axis_label(t["old"], t["old_version"]))}'
        f' → {html.escape(_axis_label(t["new"], t["new_version"]))}</td>'
        f'<td><a href="../../{url(t["stem"])}/index.html">report</a></td>'
        f'<td class="mono">{short_md5(t["old_md5"])} → {short_md5(t["new_md5"])}</td>'
        f"<td>{badge(t['status'])}</td>"
        "</tr>"
        for t in trs)
    n_points = len(h["points"])
    timeline = (
        "<h2>md5 timeline</h2>\n"
        f'<p class="sub">One row per built release pair carrying this '
        f"tarball ({len(trs)}), in axis order — the pair sides as version "
        "labels (12-char prefixes for raw shas the resolver does not "
        f"name), the md5 flip as short prefixes.  {n_points} distinct "
        "observed point(s); full md5s ride the audit below.</p>"
        + '<table class="comps">\n<thead><tr><th>Release pair</th>'
        "<th>Report</th><th>md5 (old → new)</th><th>Status</th></tr>"
        f"</thead>\n<tbody>\n{tl_rows}\n</tbody>\n</table>")

    if h["analyses"]:
        delta = (f"<h2>Analyzed deltas ({len(h['analyses'])})</h2>\n"
                 '<p class="sub">Per-field impact numbers for every '
                 "pair that analyzed this case — the same tables the "
                 "report cards carry, joined here so the case's own "
                 "history answers \"did its physics move?\" without "
                 "opening pair reports.</p>\n"
                 + "\n".join(_case_delta_block(a) for a in h["analyses"]))
    elif any((t["status"] or "") != "identical" for t in trs):
        delta = ("<h2>Analyzed deltas</h2>\n"
                 '<p class="sub">None — changed by md5 in at least one '
                 "observed pair but never selected for analysis in any "
                 "built pair (manifest-only tier: neither side fetched). "
                 "The driver's --analyze selection decides per pair.</p>")
    else:
        delta = ("<h2>Analyzed deltas</h2>\n"
                 '<p class="sub">None — identical in every observed pair: '
                 "the diff layers carry no case entry for an unchanged "
                 "tarball, so there is no delta to analyze.</p>")

    audit_bits = []
    for t in trs:
        subjects = "\n".join(
            f'<li><span class="mono">{html.escape(s["commit"][:12])}…</span> '
            f"{html.escape(s['subject'])}</li>"
            for s in t["subjects"])
        audit_bits.append(
            f'<p class="sub">Pair <span class="mono">'
            f'{html.escape(_axis_label(t["old"], t["old_version"]))} → '
            f'{html.escape(_axis_label(t["new"], t["new_version"]))}</span>'
            f' — md5 <span class="mono">{html.escape(str(t["old_md5"] or "—"))}</span>'
            f' → <span class="mono">{html.escape(str(t["new_md5"] or "—"))}</span></p>'
            + (f'<ul class="skips">\n{subjects}\n</ul>\n' if subjects else ""))
    audit = (
        '<details class="audit">\n'
        f"<summary>Publish narrative + full md5s ({len(trs)} pair"
        + ("s" if len(trs) != 1 else "")
        + ")</summary>\n<div class=\"pad\">\n"
        '<p class="sub">The commits that touched this tarball between '
        "each pair, subjects VERBATIM from the repo's own publish "
        "narrative (the Makefile publish rule's subjects), plus the full "
        "md5 pins — full hashes live only in this block.</p>\n"
        + "\n".join(audit_bits)
        + "\n</div>\n</details>")

    footer = (
        '<footer>Generated by <span class="mono">catalog/build_catalog.py'
        "</span> from the committed page-data joins under "
        '<span class="mono">out/deltarun_pages/</span> (schema '
        '<span class="mono">catalog-deltarun-page/2</span>: the embedded '
        'diff tarballs + analysis blocks) + the pinned '
        "resolver axis in <span class=\"mono\">build_release_report.py"
        '</span> — the stability verdict is derived from the timeline '
        "only, nothing re-derived.</footer>")
    return page(f"{stem} — release history", head,
                "\n".join([timeline, delta, audit, footer]),
                root="../../../", active="axis",
                crumbs=(("Release reports", "index.html#releases"),
                        ("Release version axis", "deltarun/index.html"),
                        (html.escape(stem), None)))


def build_run_page(
    r: dict, m: dict,
    comparison: dict | None = None, ss_entry: dict | None = None,
    case_href: str | None = None, fam_deck: dict | None = None,
    recorded_pairs: list[dict] | None = None,
) -> str:
    parts = []
    # the lineage (checkpoint B): the page's place in the chain
    # landing ← group ← family ← run; hrefs are depth-relative from
    # the run page (depth = its own name parts), the family link only
    # when its page stands (_FAM_PAGES)
    nm_parts = r["name"].split("/")
    gslug = r.get("group") or nm_parts[0]
    glabel = r.get("group_label") or gslug
    fam = nm_parts[1] if len(nm_parts) > 2 else None
    fam_page = fam is not None and (gslug, fam) in _FAM_PAGES
    fam_href = ("../" * (len(nm_parts) - 2) + "index.html") if fam_page \
        else None
    group_href = "../" * (len(nm_parts) - 1) + "index.html"

    # the meta line is data, not prose — mono (the instrument voice),
    # with the verdict badge inline; the LINKS live in the fact sheet.
    # The family names its PAGE since checkpoint B (the deck's home).
    fam_label = (f'<a href="{fam_href}">'
                 + html.escape(str(r.get("run_family", r["machine"])))
                 + "</a>") if fam_href else \
        (f'<span class="mono">'
         + html.escape(str(r.get("run_family", r["machine"])))
         + "</span>")
    head = (
        '<p class="kicker">Catalog · run entry</p>\n'
        f'<h1>{html.escape(r["name"])}</h1>\n'
        f'<p class="meta">{html.escape(r["machine"])} · run family '
        f"{fam_label} · convergence {badge(r['verdict'])}</p>\n"
    )

    # the sticky fact sheet: the dossier's orientation rail — the
    # provenance facts (moved here wholesale) plus the entry's links.
    # Members of a family with a diff deck link straight to its
    # comparison page; families without one (single member, honest
    # skip) render no link — the absence is real, not a blank to fill.
    # The release-history row (link to the family tarball's case
    # screen, or its honest absence) rides _RELEASE_AXIS_LIVE below.
    f44 = m.get("fort44") or {}
    f46 = m.get("fort46") or {}
    links = []
    # the backlink chain's own rows (checkpoint B): the family page
    # (the base deck's home) and the group page sit beside the
    # comparison link; absent family pages degrade to the group alone
    if fam_href:
        links.append(f'<a href="{fam_href}">family page (the base deck)'
                     "</a>")
    links.append(f'<a href="{group_href}">group page</a>')
    if comparison is not None:
        links.append(
            f'<a href="../../../comparisons/{url(comparison["run_family"])}/index.html">'
            "family A/B state comparison</a>")
    # the recorded pairs' backlinks (checkpoint C, the two-homes
    # rule's "here" half): EVERY member run page of a recorded pair
    # links its pair page — one link per pair, this run's partner
    # named by its member name (the title carries the full
    # group-qualified name; run pages sit at depth 3)
    for rc in recorded_pairs or []:
        other = rc["b"] if rc["a"] == r["name"] else rc["a"]
        stem = rc["deck"].split("/")[-1].removesuffix("__diff")
        links.append(
            f'<a href="../../../compare/{url(stem)}/index.html" '
            f'title="{html.escape(other)}">recorded A/B comparison vs '
            + html.escape(other.rsplit("/", 1)[-1]) + "</a>")
    # the release-history row rides the axis's dormancy switch: while
    # the axis is dormant: NEITHER the link NOR the honest
    # absence note renders — the note would claim an unshipped axis
    # looked at this tarball.  Restore the axis = flip the switch and
    # re-wire main()'s case_href computation (kept in git history)
    if _RELEASE_AXIS_LIVE:
        if case_href:
            links.append(f'<a href="{url(case_href)}">release history</a>')
        else:
            links.append("release history: no built pair covers this tarball")
    factsheet = (
        '<aside class="factsheet">\n'
        "<h2>Provenance</h2>\n"
        + kv_rows([
            ("fort.44", f'version <span class="mono">{f44.get("version", "—")}</span>, '
                        f'git <span class="mono">{html.escape(str(f44.get("git_hash") or "—"))}</span>'),
            ("fort.46", f'version <span class="mono">{f46.get("version", "—")}</span>, '
                        f'git <span class="mono">{html.escape(str(f46.get("git_hash") or "—"))}</span>, '
                        f'{f46.get("ntri", "—")} triangles'),
            ("grid", f'{(f44.get("grid") or {}).get("nx", "—")}×{(f44.get("grid") or {}).get("ny", "—")} '
                     f'({(f44.get("grid") or {}).get("nx", 0) * (f44.get("grid") or {}).get("ny", 0)} cells)'),
            ("species", html.escape(" ".join(f44.get("species") or [])) or "—"),
            ("links", "<br>".join(links)),
        ])
        + "</aside>\n"
    )

    # the vs-base delta (checkpoint B): what this run's own deck
    # changes against the family base — the deck itself lives ONCE
    # on the family page now (baserun-data-once); the deck-present
    # flag distinguishes the two honest absences (no shared deck at
    # all vs a base deck without the b2mn.dat switch layer — the
    # shipped examples' shape)
    parts.append(vs_base_section(ss_entry, fam_deck, fam_href,
                                 bool(m.get("input_deck"))))

    # the effective-deck switch state, read-only from the
    # switchsets artifact — the run's configuration beside its deck.
    parts.append(switches_section(ss_entry))

    conv = m.get("convergence") or {}
    spark = conv.get("sparklines")
    parts.append("<h2>Convergence</h2>")
    if conv.get("verdict") or conv.get("counts"):
        active = sorted((conv.get("active_verdicts") or {}).items())
        mons = (spark or {}).get("monitors") or {}
        span = (spark or {}).get("time_span_s") or {}
        kv = [
            ("verdict", badge(conv.get("verdict"))),
            ("records", f'{conv.get("nrecords", "—")} time steps, '
                        f'{conv.get("ntraces", "—")} traces '
                        f'({conv.get("n_active", "—")} active)'),
            ("time bases excluded", html.escape(", ".join(conv.get("time_bases") or [])) or "—"),
        ]
        # the physical time — ONE text line (span + record count
        # straight from the sparklines block; no axes anywhere, the
        # sparklines are the only geometry the section carries).
        if span:
            kv.append(("monitored", f'{span["start"]:.1e} s -&gt; {span["end"]:.1e} s '
                                    f'over {conv.get("nrecords", "—")} records'))
        act_rows = "\n".join(
            f'<tr><td class="mono">{monitor_label(n, mons.get(n) or {})}</td>'
            f'<td class="sparkcell">{sparkline_svg(n, (mons.get(n) or {}).get("values") or [])}'
            f'</td><td>{badge(v)}</td></tr>'
            for n, v in active
        )
        parts.append(kv_rows(kv))
        if spark:
            # the evidence strip — one inline SVG per ACTIVE
            # monitor (badge TEXT carries identity; the polyline carries
            # only the flatness).  No axes, grid, legend, JS, external
            # assets — hand-built from the manifest JSON alone.
            parts.append(
                '<table class="sparktbl">\n<thead><tr><th>Active monitor</th>'
                "<th>Series (record window, downsampled)</th>"
                "<th>Tail verdict</th></tr></thead>\n"
                f"<tbody>\n{act_rows}\n</tbody>\n</table>\n"
                '<p class="sub">Sparklines: per-active-monitor b2time.nc series '
                "as verbatim tallies, downsampled every max(1, n÷40) records "
                "(final record always kept); each line is scaled to its own "
                "min-&gt;max: the evidence behind the badge, rendered from the "
                "manifest JSON, never re-derived.</p>"
            )
        else:
            # Sparkline-or-note is manifest-driven: a verdict-bearing
            # manifest without the block (pre-shape) states the
            # absence — never a blank, never a filesystem guess.
            parts.append(spark_absence_note(conv))
    else:
        reason = conv.get("skipped") or conv.get("error") or "no b2time.nc"
        parts.append(f'<p class="sub">Not assessed: {html.escape(str(reason))}</p>')
        parts.append(spark_absence_note(conv))

    wall = m.get("wall")
    wg = m.get("wall_geometry") or {}
    wall_rows = bool(wall and wall.get("loaded_rows"))
    # the wall gate: every page states its wall figure or exactly why there
    # is none, decided from the manifest's wall_geometry record (written
    # for EVERY run by the wall gate) — the has_fig filesystem check
    # retires.  A run with no wall data still carries the section: the
    # absence is information, not silence.
    if wall_rows or wg:
        parts.append(WALL_HEAD)
    if wall_rows:
        integ = wall.get("integrated_raw") or {}
        si = wall.get("integrated_si") or {}
        si_bits = " · ".join(
            f'{html.escape(e["what"])} {e["value"]:.3e} {html.escape(e["unit"])}'
            for e in si.values()
        )
        parts.append(kv_rows([
            ("wall segments", f'{wall["nlim"]} standard + {wall["nsts"]} stratum '
                              f'({wall["nstra"]} strata)'),
            ("loaded rows", html.escape(", ".join(str(i) for i in wall["loaded_rows"]))),
            ("integrated (raw)", "ion {:.3e} · atom {:.3e} · mol {:.3e} · eb {:.3e}".format(
                integ.get("ion", 0), integ.get("atom", 0),
                integ.get("mol", 0), integ.get("eb", 0))),
            ("integrated (SI)", si_bits or "—"),
            ("units", html.escape(wall.get("units", "raw EIRENE"))),
        ]))
        seg = wall.get("loaded_rows_si") or []
        if seg:
            def sci(v):
                return "—" if v is None else f"{v:.3e}"
            seg_rows = "\n".join(
                "<tr>"
                f'<td class="num">{e["row"]}</td>'
                f'<td class="num">{e["isrftype"] if e["isrftype"] is not None else "—"}</td>'
                f'<td class="num">{sci(e["area_m2"])}</td>'
                f'<td class="num">{sci(e["particle_flux_s1"])}</td>'
                f'<td class="num">{sci(e["particle_flux_density_m2_s1"])}</td>'
                f'<td class="num">{sci(e["emitted_power_w"])}</td>'
                "</tr>"
                for e in seg
            )
            parts.append(
                '<table>\n<thead><tr><th class="num">loaded row</th>'
                '<th class="num">type</th><th class="num">area [m²]</th>'
                '<th class="num">particle flux [s⁻¹]</th>'
                '<th class="num">flux density [m⁻² s⁻¹]</th>'
                '<th class="num">emitted power [W]</th></tr></thead>\n'
                f"<tbody>\n{seg_rows}\n</tbody>\n</table>"
            )
    if wg:
        parts.append(wall_figure_or_note(wg))

    files = m.get("files") or {}
    if files:
        rows = "\n".join(
            f'<tr><td class="mono">{html.escape(n)}</td>'
            f'<td class="num">{fmt_bytes(v["bytes"])}</td>'
            f'<td class="mono">{html.escape(v["md5"] or "(>200 MB, not hashed)")}</td></tr>'
            for n, v in sorted(files.items())
        )
        parts.append(
            "<h2>Files</h2>\n<table>\n<thead><tr><th>File</th><th class=\"num\">Size</th>"
            f"<th>MD5</th></tr></thead>\n<tbody>\n{rows}\n</tbody>\n</table>"
        )

    parts.append(
        '<footer>Generated by <span class="mono">catalog/build_catalog.py</span> from '
        f'<span class="mono">{html.escape(r["manifest"])}</span> and '
        '<span class="mono">out/switchsets.json</span>: numbers on this page '
        "come from the artifact JSON, never re-derived.</footer>"
    )
    # the dossier: document flow (vs-base delta, switches,
    # convergence, wall, files) + the sticky fact sheet beside it.
    # The crumb trail IS the backlink chain (checkpoint B):
    # Catalog > group > family > run (the family crumb only when its
    # page stands; the hrefs are root-relative, root-prefixed by
    # _crumbs_html)
    chain = [(html.escape(glabel), f"{url(gslug)}/index.html")]
    if fam_page:
        chain.append((html.escape(fam),
                      f"{url(gslug)}/{url(fam)}/index.html"))
    chain.append((html.escape(r["name"]), None))
    return page(r["name"], head,
                '<div class="dossier">\n<div class="flow">\n'
                + "\n".join(parts)
                + "\n</div>\n" + factsheet + "</div>\n",
                root="../../../", active="runs", active_run=r["name"],
                crumbs=tuple(chain))


#: the vendored typeface set — every file the CSS references;
#: staged beside EVERY page (relative url(), file://-proof at any depth).
FONT_FILES = (
    "sora-latin-400-normal.woff2",
    "sora-latin-600-normal.woff2",
    "source-serif-4-latin-400-normal.woff2",
    "source-serif-4-latin-400-italic.woff2",
    "source-serif-4-latin-600-normal.woff2",
    "ibm-plex-mono-latin-400-italic.woff2",
    "ibm-plex-mono-latin-400-normal.woff2",
    "ibm-plex-mono-latin-500-normal.woff2",
    "ibm-plex-mono-latin-600-normal.woff2",
    "ibm-plex-mono-latin-700-normal.woff2",
)


def stage_fonts(target: Path, with_licenses: bool = False) -> None:
    """Stage fonts/ at the site root: the shared CSS references
    fonts/<file> through each page's own depth prefix, so ONE copy
    serves every page.  The root copy also carries the OFL texts (one
    licensing location in the delivered tree).  A missing vendored
    file fails loudly, naming it."""
    src = HERE / "fonts"
    if not src.is_dir():
        raise SystemExit(f"{src} missing: the self-hosted typefaces "
                         "are vendored there; see README")
    d = target / "fonts"
    d.mkdir()
    for name in FONT_FILES:
        f = src / name
        if not f.is_file():
            raise SystemExit(f"{f} missing: fonts/ is incomplete")
        shutil.copy2(f, d / name)
    if with_licenses:
        for lic in sorted(src.glob("LICENSE-*.txt")):
            shutil.copy2(lic, d / lic.name)


def main(argv: list[str] | None = None) -> None:
    global _RAIL_META, OUT, SITE
    import argparse
    ap = argparse.ArgumentParser(
        description="Emit the static catalog site from out/ (index.json "
                    "+ manifests + switchsets.json).")
    ap.add_argument("--out", metavar="PATH", default=None,
                    help="the out tree to read and site under (default: "
                         "this catalog tree's out/; the CLI seats user "
                         "builds in the per-user share instead)")
    ap.add_argument("--built-at", metavar="ISO", default=None,
                    help="the user-seat build moment, rendered as the "
                         "landing's 'built at' line ONLY when user "
                         "groups stand (the determinism rule: no "
                         "wall clock ever enters proven bytes; the "
                         "gate and --in-tree never pass this)")
    args = ap.parse_args(argv)
    if args.out:
        OUT = Path(args.out).expanduser()
        SITE = OUT / "site"
    index = json.loads((OUT / "index.json").read_text(encoding="utf-8"))
    runs = index["runs"]
    # the shell's rail + topbar: the run list and the counts line are
    # injected BEFORE any page builds (every page's rail renders them).
    _RAIL_RUNS.clear()
    _RAIL_RUNS.extend(runs)
    # the run tree (the ruled navigation shape): first-seen
    # grouping over the display-ordered runs — (slug, label) then
    # families, deterministic without a re-sort (the same walk the
    # landing's inventory renders)
    tree: list[tuple[str, str, list[tuple[str, list[dict]]]]] = []
    for r in runs:
        parts = r["name"].split("/")
        gslug = r.get("group") or parts[0]
        glabel = r.get("group_label") or parts[0]
        fam = parts[1] if len(parts) > 2 else parts[0]
        if not tree or tree[-1][0] != gslug:
            tree.append((gslug, glabel, []))
        fams = tree[-1][2]
        if not fams or fams[-1][0] != fam:
            fams.append((fam, []))
        fams[-1][1].append(r)
    _RAIL_TREE.clear()
    _RAIL_TREE.extend(tree)
    # the per-group analysis fingerprint : content-derived —
    # md5 over the group's sorted per-run manifest md5s (a change to
    # any analysis changes it; a pure reorder does not).  Never a
    # clock, never a path — the double-build proof pins it.
    per_group: dict[str, list[str]] = {}
    for r in runs:
        m_path = OUT / r["manifest"]
        per_group.setdefault(
            r.get("group") or r["name"].split("/")[0], []).append(
            hashlib.md5(m_path.read_bytes()).hexdigest())
    fingerprints = {
        gslug: short_md5(hashlib.md5("".join(sorted(md5s)).encode())
                         .hexdigest())
        for gslug, md5s in per_group.items()}
    # the site is a CONSUMER of out/switchsets.json — a
    # page source with the same standing as the manifests, read-only.
    # Missing artifact = hard error naming it (the pattern),
    # never a partial site; hence the check_catalog.sh stage-1 order:
    # switchsets BEFORE the site build.
    ss_path = OUT / "switchsets.json"
    if not ss_path.is_file():
        raise SystemExit(
            f"{ss_path} missing: the site renders every run page's "
            "Switches section from it; run build_switchsets.py first")
    switchsets = json.loads(ss_path.read_text(encoding="utf-8"))
    # the release axis is DORMANT this delivery : the committed
    # page-data joins under out/deltarun_pages/, the builders, and the
    # rendering functions above all stay in the tree untouched — the
    # site simply stops reading the joins, emitting the deltarun pages
    # and the Releases section (one restore away from folding the
    # axis back in as a shaped feature).
    # families with a recorded deck get a comparison page, and
    # every member run page links to it (JSON-driven, never a dir
    # guess).  comp_entry_by_family keeps EVERY entry (deck-carrying
    # and skipped alike) for the family pages — the skipped decks'
    # honest home since the landing's deck table retired (C).
    comp_by_family = {c["run_family"]: c for c in index.get("comparisons") or []
                      if c.get("deck")}
    comp_entry_by_family = {c["run_family"]: c
                            for c in index.get("comparisons") or []}
    recorded = index.get("recorded_comparisons") or []
    fams = {r.get("run_family") or r["machine"] for r in runs}
    # the rail's data-driven children (checkpoint C): the recorded
    # pairs ONLY — the family decks retired from every top-level
    # listing (their home is the family page; the two-homes rule on
    # the landing's Comparisons section states it); hrefs follow the
    # pinned rule
    _RAIL_EXTRA.clear()
    # the rail's pair children carry FAMILY/MEMBER names (the leaves'
    # own discipline — the group prefix rides the tooltip with the
    # full pair), ellipsizing like every rail row
    _RAIL_EXTRA["comparisons"] = [
        (f'{rc["a"].split("/", 1)[1]} vs {rc["b"].split("/", 1)[1]}',
         f'compare/{url(rc["deck"].split("/")[-1].removesuffix("__diff"))}'
         "/index.html",
         f'{rc["a"]} vs {rc["b"]}')
        for rc in recorded if rc.get("deck")]
    _RAIL_META = (
        f'<b>{len(runs)}</b> runs<span class="sep">·</span>'
        f'<b>{len(fams)}</b> run families')
    # the recorded pairs' join to their member pages + the code-git
    # stamps (checkpoint C): every deck-carrying pair contributes a
    # factsheet backlink to BOTH member run pages, and the pair page
    # names the code delta when the legs' stamps differ (the runs'
    # own index entries carry the stamps — never re-read here)
    rec_pairs_by_run: dict[str, list[dict]] = {}
    for rc in recorded:
        if rc.get("deck"):
            for side in (rc["a"], rc["b"]):
                rec_pairs_by_run.setdefault(side, []).append(rc)
    code_by_run = {r["name"]: r.get("code_git") for r in runs}

    if SITE.exists():
        shutil.rmtree(SITE)
    SITE.mkdir(parents=True)
    # the root copy carries the OFL texts too (single licensing spot)
    stage_fonts(SITE, with_licenses=True)

    # the hierarchy pages (checkpoint B): one group page per
    # cataloged group (site/<group>/), one family page per real
    # family directory (site/<group>/<family>/).  The family set is
    # first-seen over the display-ordered runs — deterministic
    # without a re-sort (the same walk the tree and landing use);
    # degenerate 2-part names (no family layer) own no family page.
    # The set fills BEFORE any page renders (the landing's own rail
    # reads it for the family label anchors).
    fam_runs: dict[tuple[str, str], list[dict]] = {}
    for r in runs:
        parts = r["name"].split("/")
        if len(parts) > 2:
            fam_runs.setdefault(
                (r.get("group") or parts[0], parts[1]), []).append(r)
    _FAM_PAGES.clear()
    _FAM_PAGES.update(fam_runs)
    # the rail's A/B items (owner review of C): one per deck-carrying
    # family, tooltip = its pair's member names; filled before any
    # page renders like every rail global
    _RAIL_AB.clear()
    for run_family, c in comp_by_family.items():
        gslug, _, fam_name = run_family.partition("/")
        pa, pb = c["pair"]
        _RAIL_AB[(gslug, fam_name)] = (
            pa.removeprefix(fam_name + "/"), pb.removeprefix(fam_name + "/"))
    fam_decks = switchsets.get("family_decks") or {}
    grp_meta = {g["slug"]: g for g in index.get("groups") or []}
    glabels = {gslug: glabel for gslug, glabel, _ in tree}

    (SITE / "index.html").write_text(
        build_index(runs, index.get("comparisons") or [],
                    switchsets, index.get("groups") or [], recorded,
                    fingerprints, args.built_at),
        encoding="utf-8")
    n_grp = 0
    for gslug, glabel, fams in tree:
        gdir = SITE / gslug
        gdir.mkdir(parents=True, exist_ok=True)
        (gdir / "index.html").write_text(
            build_group_page(gslug, glabel, fams,
                             grp_meta.get(gslug, {})), encoding="utf-8")
        n_grp += 1
    n_fampg = 0
    for (gslug, fam), fam_rows in fam_runs.items():
        run_family = f"{gslug}/{fam}"
        fdir = SITE / gslug / fam
        fdir.mkdir(parents=True, exist_ok=True)
        m0 = json.loads((OUT / fam_rows[0]["manifest"]).read_text(
            encoding="utf-8"))
        deck = (json.loads((OUT / m0["input_deck"]).read_text(
            encoding="utf-8")) if m0.get("input_deck") else None)
        (fdir / "index.html").write_text(
            build_family_page(
                gslug, glabels.get(gslug, gslug), fam,
                fam_rows, deck, m0.get("input_deck"),
                comp_entry_by_family.get(run_family),
                fam_decks.get(run_family)),
            encoding="utf-8")
        n_fampg += 1

    n_conv = 0
    n_wall = n_wall_note = 0
    for r in runs:
        m = json.loads((OUT / r["manifest"]).read_text(encoding="utf-8"))
        # the name IS the path: group/family/run as real directories
        # (depth 3 — every run-page-relative href accounts for it)
        run_dir = SITE.joinpath(*r["name"].split("/"))
        run_dir.mkdir(parents=True)
        comparison = comp_by_family.get(r.get("run_family", ""))
        ss_entry = switchsets["runs"].get(r["name"])
        # the release-history cross-link is dormant with the axis
        # : the run-page machinery keeps its case_href branch,
        # the build hands it None
        (run_dir / "index.html").write_text(
            build_run_page(r, m, comparison, ss_entry, None,
                           fam_decks.get(r.get("run_family", "")),
                           rec_pairs_by_run.get(r["name"])),
            encoding="utf-8")
        # the wall gate: staging follows the manifest's record too — the
        # figure entry (recorded iff the wall gate passed) names
        # the hash-pinned source; nothing is staged the manifest does
        # not record, and a recorded-but-missing source fails loudly
        # (FileNotFoundError, the ruling).
        wg = m.get("wall_geometry") or {}
        if wg.get("figure"):
            # the entry's seat names the source root: the examples'
            # committed tree, or THIS build's out (user groups paint
            # their figures into the seat at manifest time)
            src_root = (HERE if wg["figure"].get("figures_seat",
                                                 "tree") == "tree"
                        else OUT)
            shutil.copy2(src_root / wg["figure"]["path"],
                         run_dir / "wall_loads.png")
            n_wall += 1
        elif wg:
            n_wall_note += 1
        # the convergence evidence ships INLINE (sparkline strip
        # from the manifest's sparklines block) — nothing staged, nothing
        # copied; the convergence PNGs are retired.
        if (m.get("convergence") or {}).get("sparklines"):
            n_conv += 1

    # stage each family's diff deck + comparison page.  Deck seating
    # follows the entry: the examples' decks are committed tree
    # content (figures/), every user-group deck a seat artifact
    # (out/figures).
    n_comp = 0
    for comp in index.get("comparisons") or []:
        if not comp.get("deck"):
            continue
        fam = comp["run_family"]
        cdir = SITE / "comparisons" / fam
        cdir.mkdir(parents=True)
        deck_root = (HERE if comp.get("figures_seat", "tree") == "tree"
                     else OUT) / comp["deck"]
        for p in sorted(deck_root.iterdir()):
            if p.is_file():
                shutil.copy2(p, cdir / p.name)
        (cdir / "index.html").write_text(
            build_comparison_page(
                comp, deck_root,
                glabels.get(fam.partition("/")[0])),
            encoding="utf-8")
        n_comp += 1

    # the recorded compare pairs — always seat artifacts (out/figures/
    # compare/), pages under site/compare/<pair>/
    n_recpg = 0
    for rc in recorded:
        if not rc.get("deck"):
            continue
        cdir = SITE / "compare" / rc["deck"].split("/")[-1].removesuffix("__diff")
        # exist_ok: the recorded list is deduped at the merge, but the
        # site stage never dies on a directory it already made
        cdir.mkdir(parents=True, exist_ok=True)
        deck_root = OUT / rc["deck"]
        for p in sorted(deck_root.iterdir()):
            if p.is_file():
                shutil.copy2(p, cdir / p.name)
        (cdir / "index.html").write_text(
            build_recorded_compare_page(
                rc, deck_root,
                (code_by_run.get(rc["a"]), code_by_run.get(rc["b"]))),
            encoding="utf-8")
        n_recpg += 1

    # one report page per release pair, the version-axis index and
    # the case screens are DORMANT with the axis : their
    # builders and staging helpers above stay in the tree untouched;
    # the site stops emitting everything under site/deltarun/

    # the switch -> runs direction — one page from the artifact's
    # inverted_index (row set + order = its own keys).  The artifact md5
    # is computed HERE (the artifact cannot carry its own hash); it pins
    # the input the page rendered from, like every manifest md5 pin.
    (SITE / "switches").mkdir()
    (SITE / "switches" / "index.html").write_text(
        build_switches_page(
            switchsets, hashlib.md5(ss_path.read_bytes()).hexdigest()), encoding="utf-8")

    n = len(runs)
    print(f"catalog site {SITE}: index + {n_grp} group pages "
          f"+ {n_fampg} family pages + {n} run pages "
          f"({n_wall} with wall figures + {n_wall_note} with wall notes, "
          f"{n_conv} with sparkline strips, "
          f"{n_comp} comparison pages + {n_recpg} recorded-pair pages) "
          f"+ switch index "
          f"({len(switchsets['inverted_index'])} switches)")


if __name__ == "__main__":
    main()
