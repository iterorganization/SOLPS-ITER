import { n as onDestroy, r as tick } from "../../chunks/index-server.js";
import { b as escape_html, c as html, i as ensure_array_like, n as attr_style, o as stringify, r as derived, t as attr_class, y as attr } from "../../chunks/server.js";
//#region src/lib/excerpt.js
/** Dot-leader runs — 4+ consecutive dots (an ellipsis "..." of three
*  stays prose; a TOC leader is never shorter than four). */
var LEADER = /\.{4,}/g;
/** A run of dots collapses to ONE ellipsis character — the same
*  omission glyph FTS5's snippet window already uses. */
var LEADER_TO = "…";
/** Collapse every dot-leader run in an excerpt. */
function collapseLeaders(s) {
	return s.replace(LEADER, LEADER_TO);
}
/** Soft-hyphen candidates: letter(s) - newline lowercase-letter(s).
*  Uppercase continuations are never end-of-line hyphenation — a
*  heading in caps keeps its break.  The {1,12}/{1,14} spans match
*  the derivation scan exactly (see JOIN_PREFIXES). */
var SOFT_HYPHEN = /([A-Za-z]{1,12})-\n([a-z]{1,14})/g;
/** Fragments whose hyphen is end-of-line hyphenation: joining
*  "diver-\ntor" yields "divertor", a word the corpus itself uses.
*  DERIVED, not hand-picked (2026-09-26, store sha of build_summary):
*  every fragment flanking a soft hyphen with >= 2 occurrences whose
*  no-hyphen concatenation occurs as a whole token elsewhere in the
*  corpus (>= 50% of its splits) — 185 fragments covering 67% of the
*  1,232 corpus splits.  Everything NOT listed keeps its hyphen: the
*  conservative error ("cross-section" stays "cross-section"; an
*  unlisted true split reads "asym-metrically", a near-miss) beats
*  mangling a compound ("crosssection").  Known cosmetic limit:
*  suspensive hyphens ("X-\nand") join to "X-and" — 5 occurrences in
*  the corpus, kept over a special case. */
var JOIN_PREFIXES = new Set("absorp ac anal anoma ap approx as assump av avail aver back be bound cal calcu chap char charac co col colli com compres con conduc consid contri conve coordi cor corre cou counter cur de den deter deu devel devi di dia diagnos dif differ diffu direc dis discon discretisa disso distri distribu diver dou down draw el ele elec emis en equa equi equiva es espe ex exist experi fig fol for formu func gen geome green how hydro im impu in integra inter interac ion ionisa ioniza ma mag mea men meta mid mo mod momen ne nec neu nu num ob on opera originat pa par param parti pene per perpen plas po pos posi possi poten pre pres pro prob prod produc projec quasi ra radi radia re recom recombi recombina redistri rela remain repre repro respec rou sam schit schnei se sec sep sepa separa set sig simula sput stan start statis struc subrou sug sur tar target tem temper tempera test theoret ther there three time toka trans transi tri under up us vari ve veloc ver with".split(" "));
/** Repair end-of-line hyphenation in display text.  The newline
*  ALWAYS goes (a mid-word hard break is wrong at any display
*  width); the hyphen survives unless the fragment is in
*  JOIN_PREFIXES.  Pane text passes through here too, which also
*  reunites query terms the store text holds split — the highlight
*  walk and the server's matched-term counts then agree on what the
*  reader sees. */
function joinSoftHyphens(s) {
	return s.replace(SOFT_HYPHEN, (m, head, tail, offset, whole) => {
		const prev = whole[offset - 1];
		if (prev && /[A-Za-z]/.test(prev)) return m;
		return JOIN_PREFIXES.has(head.toLowerCase()) ? head + tail : head + "-" + tail;
	});
}
/** Contents-row threshold: leader dots as a fraction of the snippet.
*  MEASURED (2026-09-26, golden-suite + probe queries): true TOC
*  snippets from CPP_2006.pdf sit at 0.38–0.70; the only other
*  ≥4-dot runs in snippets are Fortran range comments
*  ("IH=2,3....,10") at ~0.05.  0.15 sits in the empty gap, 3x above
*  the comment zone and 2.5x below the TOC zone. */
var TOC_DENSITY = .15;
/** Is this excerpt a table-of-contents row?  Leader-dot density
*  heuristic (see TOC_DENSITY).  Badged in the row — never demoted:
*  the chunk still ranks where bm25 put it. */
function contentsRow(rawSnippet) {
	if (!rawSnippet) return false;
	const runs = rawSnippet.match(LEADER);
	if (!runs) return false;
	return runs.reduce((n, r) => n + r.length, 0) / rawSnippet.length >= TOC_DENSITY;
}
/** The full api-mode snippet treatment: joined text for display +
*  the contents-row flag (computed on the RAW snippet — density is a
*  property of what the corpus holds, not of the collapse). */
function cleanSnippet(raw) {
	return {
		text: collapseLeaders(joinSoftHyphens(raw)),
		toc: contentsRow(raw)
	};
}
/**  markup-source escape sequences (reST and LaTeX prose):
*  the escapable specials, backslashed because the markup gives the
*  bare character a meaning (`\_` is a literal underscore in reST
*  prose and TeX text mode).  In a RENDERED view of the document none
*  of them survive as backslashes — so for chunks whose GitHub blob
*  RENDERS (srclink.githubShowsRendered), display text unescapes them
*  and a Ctrl+F of the copied text finds the place.  Raw-view chunks
*  (.tex code view, Fortran) keep every byte — their Ctrl+F target is
*  the source itself.  Display path only, never the store. */
var MARKUP_ESCAPES = /\\([_%&#])/g;
/** Unescape the markup specials in display text (rendered-view
*  chunks only). */
function unescapeMarkup(s) {
	return s.replace(MARKUP_ESCAPES, "$1");
}
//#endregion
//#region src/lib/srclink.js
/** Repo first-segment -> { url, ref } (default branch, verified
*  2026-09-26: SOLPS-ITER master, SOLPS-GUI develop). */
var SOURCE_REPOS = Object.freeze({
	"SOLPS-ITER": Object.freeze({
		url: "https://github.com/iterorganization/SOLPS-ITER",
		ref: "master"
	}),
	"SOLPS-GUI": Object.freeze({
		url: "https://github.com/iterorganization/SOLPS-GUI",
		ref: "develop"
	}),
	"SOLPS-Tutorials": Object.freeze({
		url: "https://github.com/iterorganization/SOLPS-Tutorials",
		ref: "master"
	})
});
/** Submodule prefixes inside SOLPS-ITER -> their own public repo
*  (the main repo 404s these paths; .gitmodules names the reroutes). */
var MODULE_REPOS = Object.freeze({
	"modules/B2.5/": Object.freeze({
		url: "https://github.com/iterorganization/B2.5",
		ref: "master"
	}),
	"modules/Eirene/": Object.freeze({
		url: "https://github.com/iterorganization/EIRENE",
		ref: "master"
	}),
	"modules/DivGeo/": Object.freeze({
		url: "https://github.com/iterorganization/DivGeo",
		ref: "master"
	}),
	"modules/Carre/": Object.freeze({
		url: "https://github.com/iterorganization/CARRE",
		ref: "master"
	})
});
var FORTRAN_HEADER = /^source: (\S+) lines (\d+)-(\d+)$/m;
/** The commit each repo was scanned at) — a mirror of the
*  corpus manifest's `heads` block (out/corpus.json, schema
*  askthedocs-corpus/2, scan of 2026-09-26; the sync is golden-tested
*  against the manifest).  Keys use the chunk-source namespace:
*  repo name, or '<repo>/<submodule path>' for rerouted modules.  A
*  repo absent here links at its default branch, `pinned: false`. */
var PINNED_COMMITS = Object.freeze({
	"SOLPS-ITER": "ca0d04d9b0b2d4887bd3262e4e867d471ba86d62",
	"SOLPS-GUI": "d590673299f5b664a7610b3efea1aba63e761f44",
	"SOLPS-Tutorials": "21e1769621c26b65579e5c89e598cbf5ea86950b",
	"SOLPS-ITER/modules/B2.5": "a1129dd949a4fa49d5c1c1ad149085a273dcb3d3",
	"SOLPS-ITER/modules/Eirene": "97ceb4b329f1816b0b73ec44e57284c9707a5eb8",
	"SOLPS-ITER/modules/DivGeo": "a919c5cd8871de30bdd5bc13f37bae754c9de93c",
	"SOLPS-ITER/modules/Carre": "d7b314aa604a16d32c8a12d4f5f3644e398385de"
});
function fortranAnchor(source, text) {
	if (!text) return "";
	const head = text.split("\n").slice(0, 3).join("\n");
	const m = FORTRAN_HEADER.exec(head);
	if (!m || m[1] !== source) return "";
	return `#L${m[2]}-L${m[3]}`;
}
/**  the Ctrl+F contract: does GitHub's blob view RENDER this
*  source type (prose — clean text, no markup escapes), or show it as
*  raw code (line-numbered source, escapes visible)?  VERIFIED live
*  2026-09-27, real browser against the real blob pages: .rst RENDERS
*  (markdown-body present, clean SPECIES_START, no backslash form);
*  .tex shows the code view; PDFs open GitHub's rendered viewer.  The
*  pane's text treatment follows this answer — text copied from the
*  citation must be findable where its link lands. */
var RENDERED_TYPES = /* @__PURE__ */ new Set([
	".rst",
	".md",
	".adoc",
	".pdf"
]);
/** True when the source's GitHub blob renders (display text unescapes
*  markup escapes); false when it shows raw code (display text keeps
*  every byte — the source IS the Ctrl+F target there). */
function githubShowsRendered(source) {
	const s = String(source ?? "");
	const dot = s.lastIndexOf(".");
	return dot >= 0 && RENDERED_TYPES.has(s.slice(dot).toLowerCase());
}
/** Where a chunk's source path reaches, or null when it honestly
*  reaches nowhere (no repo segment, or the synthetic b2mn.dat).
*  `{ url, repo, ref, pinned }` — `repo` display form
*  'iterorganization/X'; `ref` the PINNED commit when one is known
*  (else the default branch, `pinned: false` so callers label it
*  honestly).  `text` (the pane's full chunk text) adds the Fortran
*  line anchor when the chunk's own header names its range.  `pins`
*  is injectable for the fallback goldens — production callers never
*  pass it. */
function sourceUrl(source, text = "", pins = PINNED_COMMITS) {
	const s = String(source ?? "");
	const slash = s.indexOf("/");
	if (slash < 1) return null;
	let base = SOURCE_REPOS[s.slice(0, slash)];
	if (!base) return null;
	let rest = s.slice(slash + 1);
	let pinKey = s.slice(0, slash);
	for (const [prefix, repo] of Object.entries(MODULE_REPOS)) if (rest.startsWith(prefix)) {
		base = repo;
		rest = rest.slice(prefix.length);
		pinKey = `${pinKey}/${prefix.slice(0, -1)}`;
		break;
	}
	const commit = pins[pinKey];
	const ref = commit ?? base.ref;
	const path = rest.split("/").map(encodeURIComponent).join("/");
	return {
		url: `${base.url}/blob/${ref}/${path}${fortranAnchor(s, text)}`,
		repo: base.url.replace("https://github.com/", ""),
		ref,
		pinned: Boolean(commit)
	};
}
/** 2026-10-18 dual-link ruling: sources whose canonical READABLE form
*  is a rendered site, not a repo blob.  The read path (source
*  anchors) lands on the live page — always latest; the pinned GitHub
*  blob (sourceUrl above, unchanged) stays the proof path, labeled
*  'pinned source' beside it.  MkDocs directory URLs verified live
*  2026-10-18: docs/<a>/b.md -> <site>/<a>/b/; docs/index.md ->
*  <site>/.  Only docs/*.md have pages — every other path answers
*  null and callers keep the blob link.  The live page may run ahead
*  of the indexed commit between corpus rebuilds; the pinned blob is
*  what the citation's text is verifiable against, forever. */
var SITE_PAGES = Object.freeze({ "SOLPS-Tutorials": "https://solps-tutorials.readthedocs.io" });
/** The rendered-page URL for a source, or null when the source has no
*  page (non-site repos, non-docs paths, non-markdown files). */
function pageUrl(source) {
	const s = String(source ?? "");
	const slash = s.indexOf("/");
	if (slash < 1) return null;
	const site = SITE_PAGES[s.slice(0, slash)];
	if (!site) return null;
	const rest = s.slice(slash + 1);
	if (!rest.startsWith("docs/") || !rest.toLowerCase().endsWith(".md")) return null;
	const page = rest.slice(5, -3);
	return `${site}/${page === "index" ? "" : page.split("/").map(encodeURIComponent).join("/") + "/"}`;
}
/** The chunk-source-namespace path of the switch documentation's
*  origin — the ONE real, pinned file behind every b2mn.dat switch
* chunk's documented content (the ruling above). */
var SWITCH_DOCS_SOURCE = "SOLPS-ITER/modules/B2.5/src/documentation/b2input.xml";
/**  the link that sits BESIDE the synthetic b2mn.dat label:
*  the pinned b2input.xml blob, built through the SAME sourceUrl
*  machinery (SOURCE_REPOS lookup, MODULE_REPOS reroute into the
*  B2.5 module repo, PINNED_COMMITS' submodule pin), never a
*  hardcoded URL — a corpus re-scan that moves B2.5 moves this link
*  together with every other one (the mirror golden follows the
*  manifest).  File-level, no #L anchor (the ruling above: the
*  switch name — the citation's section — is the precision
*  instrument).  `pins` injectable for the fallback golden, exactly
*  like sourceUrl's. */
function switchDocsUrl(pins = PINNED_COMMITS) {
	return sourceUrl(SWITCH_DOCS_SOURCE, "", pins);
}
//#endregion
//#region src/lib/data.js
var CITATION_VIEW = "inline";
var API_BASE = "".replace(/\/+$/, "");
/** Result row shape rendered by +page.svelte:
*  { chunkId, clusters: string[], excerptHtml, toc?: boolean,
*    source, section, page, matchedTerms?: [{term, n}], score?: number,
*    phraseHit?: boolean, sourceUrl?: {url, repo, ref, pinned} }
* The last five (why-this-result; contents-row badge;
* phrase-tier marker; the GitHub source link)
* exist only in api mode —
*  the static index carries no per-hit analytics, so the surfaces
*  that read them render only when they are present.  `ref` is the
* commit the corpus scan pinned — `pinned: false` means
*  the manifest had no pin and the URL rides the default branch. */
function markify(snippet) {
	return snippet.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll("«", "<mark>").replaceAll("»", "</mark>");
}
async function apiSearch(query, limit, cluster, signal, typeahead) {
	const params = new URLSearchParams({
		q: query,
		limit
	});
	if (cluster) params.set("cluster", cluster);
	if (typeahead) params.set("typeahead", "1");
	const res = await fetch(`${API_BASE}/search?${params}`, { signal });
	if (!res.ok) {
		const err = /* @__PURE__ */ new Error(`/search answered ${res.status}`);
		err.status = res.status;
		throw err;
	}
	const data = await res.json();
	return {
		total: data.total,
		completionsTotal: data.completions_total ?? 0,
		didYouMean: data.did_you_mean ?? null,
		completionWords: (data.completions ?? []).map((c) => ({
			word: c.word,
			count: c.count,
			adjacent: c.adjacent ?? 0
		})),
		separateTerms: (data.separate_terms ?? []).map((t) => ({
			term: t.term,
			count: t.count
		})),
		facets: (data.facets ?? []).map((f) => ({
			cluster: f.cluster,
			count: f.count
		})),
		rows: data.hits.map((h) => {
			const v = cleanSnippet(h.snippet ?? "");
			const display = githubShowsRendered(h.source) ? unescapeMarkup(v.text) : v.text;
			return {
				chunkId: h.chunk_id,
				clusters: h.cluster ? [h.cluster] : [],
				excerptHtml: markify(display),
				toc: v.toc,
				source: h.source,
				section: h.section ?? "",
				page: h.page != null ? `p. ${h.page}` : "",
				matchedTerms: h.matched_terms ?? [],
				score: h.score ?? null,
				phraseHit: h.phrase_hit === true,
				identity: h.identity === true,
				completion: h.completion === true,
				sourceUrl: sourceUrl(h.source)
			};
		})
	};
}
async function apiGetChunk(chunkId) {
	const res = await fetch(`${API_BASE}/chunk/${encodeURIComponent(chunkId)}`);
	if (res.status === 404) return null;
	if (!res.ok) throw new Error(`/chunk answered ${res.status}`);
	const c = await res.json();
	const text = githubShowsRendered(c.source) ? unescapeMarkup(joinSoftHyphens(c.text)) : joinSoftHyphens(c.text);
	return {
		chunkId: c.chunk_id,
		source: c.source,
		cluster: c.cluster,
		section: c.section ?? "",
		page: c.page != null ? `p. ${c.page}` : "",
		text,
		sourceUrl: sourceUrl(c.source, text)
	};
}
/** Ranked search.  Resolves to { total, facets, rows } — the row
* shape above; `facets` (api mode only) is the
*  per-cluster chip data [{cluster, count}], empty in static mode
*  where no chips render.  Throws on backend failure (the page
* surfaces the message). `cluster` restricts the api
*  query to one cluster — static mode ignores it (its frozen face
*  never sends one: the chips are api-mode UI).  `signal` aborts a superseded request on the wire — the api fetch
*  honors it directly, static mode aborts its enrichment fetches and
*  relies on the controller's seq guard. */
async function searchChunks(query, { limit = 10, cluster, signal, typeahead } = {}) {
	return apiSearch(query, limit, cluster, signal, typeahead);
}
async function getChunk(chunkId) {
	return apiGetChunk(chunkId);
}
async function getSwitchRuns(switchName) {
	const res = await fetch(`${API_BASE}/switchruns/${encodeURIComponent(switchName)}`);
	if (!res.ok) throw new Error(`/switchruns answered ${res.status}`);
	const d = await res.json();
	return {
		catalog: d.catalog,
		runs: (d.runs ?? []).map((r) => ({
			run: r.run,
			family: r.family,
			value: r.value
		}))
	};
}
function syntheticRow(chunk) {
	if (!chunk) return null;
	const esc = String(chunk.text ?? "").slice(0, 240).replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;");
	return {
		chunkId: chunk.chunkId,
		clusters: chunk.cluster ? [chunk.cluster] : [],
		excerptHtml: esc,
		source: chunk.source,
		section: chunk.section ?? "",
		page: chunk.page ?? ""
	};
}
function createInstantSearch({ search, debounceMs = 150, limit = 10, onState }) {
	let seq = 0;
	let timer = null;
	let controller = null;
	const state = {
		query: "",
		running: false,
		searched: false,
		total: 0,
		results: [],
		facets: [],
		error: "",
		transient: false,
		fetchingMore: false,
		appended: false,
		mode: "committed",
		completionsTotal: 0,
		didYouMean: null,
		completionWords: [],
		separateTerms: []
	};
	function apply(patch) {
		Object.assign(state, patch);
		onState?.({ ...state });
	}
	function supersede() {
		seq++;
		if (timer) {
			clearTimeout(timer);
			timer = null;
		}
		if (controller) {
			controller.abort();
			controller = null;
		}
	}
	function fire(mode) {
		timer = null;
		const id = ++seq;
		controller?.abort();
		controller = new AbortController();
		apply({
			running: true,
			error: "",
			transient: false,
			appended: false,
			mode
		});
		search(state.query.trim(), {
			signal: controller.signal,
			limit,
			typeahead: mode === "typeahead"
		}).then(({ total, rows, facets, completionsTotal, didYouMean, completionWords, separateTerms }) => {
			if (id !== seq) return;
			apply({
				total,
				results: rows,
				facets: facets ?? [],
				completionsTotal: completionsTotal ?? 0,
				didYouMean: didYouMean ?? null,
				completionWords: completionWords ?? [],
				separateTerms: separateTerms ?? [],
				searched: true,
				appended: false,
				mode
			});
		}).catch((err) => {
			if (id !== seq) return;
			if (err?.name === "AbortError") return;
			const status = typeof err?.status === "number" ? err.status : 0;
			apply({
				searched: true,
				total: 0,
				results: [],
				facets: [],
				completionsTotal: 0,
				didYouMean: null,
				completionWords: [],
				separateTerms: [],
				error: String(err?.message ?? err),
				transient: status >= 400 && status < 500,
				appended: false
			});
		}).finally(() => {
			if (id !== seq) return;
			controller = null;
			apply({ running: false });
		});
	}
	/** A keystroke: debounce the query; clear immediately when empty. */
	function input(q) {
		state.query = q;
		if (!q.trim()) {
			supersede();
			apply({
				running: false,
				searched: false,
				total: 0,
				results: [],
				facets: [],
				completionsTotal: 0,
				didYouMean: null,
				completionWords: [],
				separateTerms: [],
				error: "",
				transient: false,
				fetchingMore: false,
				appended: false
			});
			return;
		}
		if (timer) clearTimeout(timer);
		timer = setTimeout(() => fire("typeahead"), debounceMs);
	}
	/** Fire NOW — Enter or the submit button bypass the debounce.  A
	*  commit asks the COMMITTED answer: the exact tier alone, in the
	*  same order the type-ahead head already showed. */
	function submit() {
		if (!state.query.trim()) return;
		supersede();
		fire("committed");
	}
	/** show-more: grow the list by one batch — re-ask the
	*  transport for `shown + batch` rows of the SAME query (no new
	*  endpoint, no offset; the ranking's prefix stability makes the
	*  wider answer a strict extension).  Supersede/abort discipline
	*  identical to fire(): typing still wins, a stale batch never
	*  lands.  `appended` stays true for the whole cycle so the page
	*  preserves selection, pane anchor and URL; a failed batch keeps
	* the rows already on screen. : a batch extends the CURRENT
	*  view's mode, and the exhaustion ceiling counts the completion
	*  tier too (its rows are part of results but not of total). */
	function more() {
		if (!state.query.trim() || !state.searched || state.fetchingMore) return;
		const ceiling = state.mode === "typeahead" ? state.total + state.completionsTotal : state.total;
		if (state.results.length >= ceiling) return;
		supersede();
		const id = ++seq;
		controller = new AbortController();
		apply({
			fetchingMore: true,
			appended: true
		});
		search(state.query.trim(), {
			signal: controller.signal,
			limit: state.results.length + limit,
			typeahead: state.mode === "typeahead"
		}).then(({ total, rows, facets, completionsTotal }) => {
			if (id !== seq) return;
			apply({
				total,
				results: rows,
				completionsTotal: completionsTotal ?? state.completionsTotal,
				facets: facets ?? state.facets,
				searched: true,
				appended: true
			});
		}).catch((err) => {
			if (id !== seq) return;
			if (err?.name === "AbortError") return;
			apply({
				error: String(err?.message ?? err),
				appended: true
			});
		}).finally(() => {
			if (id !== seq) return;
			controller = null;
			apply({ fetchingMore: false });
		});
	}
	/** Tear-down: nothing in flight may touch state after this. */
	function stop() {
		supersede();
		state.running = false;
	}
	return {
		input,
		submit,
		stop,
		more
	};
}
//#endregion
//#region src/lib/urlstate.js
function readView(search) {
	const p = new URLSearchParams(typeof search === "string" ? search : "");
	return {
		q: (p.get("q") ?? "").trim(),
		cluster: (p.get("cluster") ?? "").trim(),
		chunk: (p.get("chunk") ?? "").trim()
	};
}
/** Canonical href for a view: `path` alone when nothing is set, else
*  `path?q=…&cluster=…&chunk=…` with empty parts omitted. */
function viewHref(view, path) {
	const p = new URLSearchParams();
	const q = (view?.q ?? "").trim();
	const cluster = (view?.cluster ?? "").trim();
	const chunk = (view?.chunk ?? "").trim();
	if (q) p.set("q", q);
	if (cluster) p.set("cluster", cluster);
	if (chunk) p.set("chunk", chunk);
	const s = p.toString();
	return s ? `${path}?${s}` : path;
}
/** True when `search` (the address bar's query string) already IS
*  `view` in
*  canonical form — the no-op guard that keeps popstate restores from
*  pushing history entries and identical states from rewriting the
*  URL (compare canonically: `?q=x&chunk=` is the same view as
*  `?q=x`). */
function sameView(search, view) {
	const have = readView(search);
	const want = {
		q: (view?.q ?? "").trim(),
		cluster: (view?.cluster ?? "").trim(),
		chunk: (view?.chunk ?? "").trim()
	};
	return have.q === want.q && have.cluster === want.cluster && have.chunk === want.chunk;
}
function isChunkId(text) {
	return /^[0-9a-f]{40}$/.test((text ?? "").trim().toLowerCase());
}
/** paste-anywhere — the tolerant extractor beside the strict
*  one.  isChunkId answers "is THIS TEXT an id"; extractChunkId
*  answers "does this text CARRY one": the first EXACTLY-40-hex
*  token in the submitted text, downcased — so everything the app
*  copies out (the plain citation line, the with-URL form, the bare
*  id, a deep link pasted whole) resolves when it comes back.  The
*  word-boundary guards make the match exactly 40: a longer hex run
*  (a sha256, say) extracts nothing — an id the store never minted
*  must not resolve to a lookalike. */
function extractChunkId(text) {
	const m = (text ?? "").match(/\b[0-9a-fA-F]{40}\b/);
	return m ? m[0].toLowerCase() : null;
}
/** The command list for the current input.  Order is intent-first:
*  the typed actions (chunk paste, then run-query), then matching
*  recents, then matching clusters (live facet counts when a search
*  has run; none before — an honest empty, not a fake list).  An
*  empty input lists recents then every cluster.  Labels are copy,
*  not state: the active filter reads `hint: 'clear filter'`. */
function buildCommands({ text = "", facets = [], cluster = "", recents = [] } = {}) {
	const t = (text ?? "").trim();
	const lower = t.toLowerCase();
	const matches = (s) => !lower || s.toLowerCase().includes(lower);
	const cmds = [];
	if (t) {
		if (isChunkId(t)) cmds.push({
			kind: "chunk",
			id: t.toLowerCase(),
			label: `Open chunk ${t.slice(0, 10)}…${t.slice(-6)}`,
			hint: "paste → fetch"
		});
		cmds.push({
			kind: "search",
			q: t,
			label: `Run “${t}”`,
			hint: "bm25 search"
		});
	}
	for (const q of recents) {
		if (q.trim() === t) continue;
		if (!matches(q)) continue;
		cmds.push({
			kind: "recent",
			q,
			label: q,
			hint: "recent: run again"
		});
	}
	for (const f of facets) {
		if (!matches(f.cluster)) continue;
		cmds.push({
			kind: "cluster",
			cluster: f.cluster,
			count: f.count,
			label: `Filter to ${f.cluster}`,
			hint: cluster === f.cluster ? "clear filter" : `${f.count} ${f.count === 1 ? "hit" : "hits"}`
		});
	}
	return cmds.slice(0, 12);
}
//#endregion
//#region src/routes/+page.svelte
function srcpath($$renderer, s, breakable) {
	if (breakable) {
		$$renderer.push("<!--[0-->");
		const parts = String(s).split("/");
		$$renderer.push(`<!--[-->`);
		const each_array = ensure_array_like(parts);
		for (let i = 0, $$length = each_array.length; i < $$length; i++) {
			let seg = each_array[i];
			$$renderer.push(`<!---->${escape_html(seg)}`);
			if (i < parts.length - 1) $$renderer.push(`<!--[0-->/<wbr/>`);
			else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]-->`);
		}
		$$renderer.push(`<!--]-->`);
	} else $$renderer.push(`<!--[-1-->${escape_html(s)}`);
	$$renderer.push(`<!--]-->`);
}
function _page($$renderer, $$props) {
	$$renderer.component(($$renderer) => {
		const LIMIT = 10;
		const URL_STATE = CITATION_VIEW === "inline";
		let query = "";
		let offline = false;
		let cluster = "";
		let facets = [];
		let pendingChunk = null;
		let running = false;
		let searched = false;
		let total = 0;
		let completionsTotal = 0;
		let didYouMean = null;
		let completionWords = [];
		let separateTerms = [];
		let results = [];
		let error = "";
		let transient = false;
		let fetchingMore = false;
		let cite = null;
		let specimen = null;
		let sel = -1;
		let marks = [];
		let mIdx = 0;
		let xruns = null;
		derived(() => "");
		let clockTimer = null;
		derived(() => []);
		derived(() => []);
		derived(() => false);
		let chipState = derived(() => {
			return null;
		});
		derived(() => chipState() === "drifted" ? " · corpus shifted, click for details" : chipState() === "notfound" ? " · corpus not found, click for details" : chipState() === "failed" ? " · rebuild failed, click for details" : "");
		derived(() => new Map([].map((l) => [l.name, l])));
		derived(() => ({
			n: 0,
			c: 0,
			r: 0
		}));
		let pQuery = "";
		let recents = [];
		derived(() => buildCommands({
			text: pQuery,
			facets,
			cluster,
			recents
		}));
		const specimenOn = derived(() => false);
		const splitOn = derived(() => running || searched || !!cite || specimenOn());
		const allCount = derived(() => facets.reduce((s, f) => s + f.count, 0));
		const wide = typeof window === "undefined" ? null : window.matchMedia("(min-width: 68rem)");
		wide?.matches;
		createInstantSearch({
			search: (q, opts) => searchChunks(q, {
				limit: LIMIT,
				cluster: void 0,
				...opts
			}),
			limit: LIMIT,
			onState: (s) => {
				running = s.running;
				searched = s.searched;
				total = s.total;
				results = s.results;
				facets = s.facets;
				error = s.error;
				transient = s.transient;
				fetchingMore = s.fetchingMore;
				completionsTotal = s.completionsTotal ?? 0;
				didYouMean = s.didYouMean ?? null;
				completionWords = s.completionWords ?? [];
				separateTerms = s.separateTerms ?? [];
				if (s.appended) return;
				sel = -1;
				if (!(pendingChunk && cite?.chunkId === pendingChunk)) cite = null;
				if (pendingChunk && s.searched && !s.running) {
					const id = pendingChunk;
					pendingChunk = null;
					const row = s.results.find((r) => r.chunkId === id);
					if (cite?.chunkId === id && row) {
						cite.matched = row.matchedTerms ?? [];
						cite.score = row.score ?? null;
						cite.phraseHit = row.phraseHit === true;
						cite.identity = row.identity === true;
					} else openCitation(id);
				}
				if (s.searched && !s.running) syncUrl("replace");
			}
		});
		function syncUrl(mode) {
			if (!URL_STATE || offline) return;
			const view = {
				q: query,
				cluster,
				chunk: cite?.chunkId ?? ""
			};
			if (sameView(window.location.search, view)) return;
			const href = viewHref(view, window.location.pathname);
			if (mode === "push") history.pushState({}, "", href);
			else history.replaceState({}, "", href);
		}
		function stopClock() {
			if (clockTimer) clearInterval(clockTimer);
			clockTimer = null;
		}
		onDestroy(() => {
			stopClock();
		});
		async function openCitation(chunkId) {
			const row = results.find((r) => r.chunkId === chunkId);
			cite = {
				chunkId,
				matched: row?.matchedTerms ?? [],
				score: row?.score ?? null,
				phraseHit: row?.phraseHit === true,
				identity: row?.identity === true,
				loading: true,
				chunk: null
			};
			xruns = null;
			try {
				cite.chunk = await getChunk(chunkId);
				if (cite?.chunkId !== chunkId) return;
				if (cite.chunk?.cluster === "source_switch" && cite.chunk.section) loadSwitchRuns(cite.chunk.section, chunkId);
			} catch (e) {
				if (cite?.chunkId === chunkId) error = `citation failed: ${e?.message ?? e}`;
			} finally {
				if (cite?.chunkId === chunkId) {
					cite.loading = false;
					if (!wide?.matches) await /* @__PURE__ */ tick();
				}
			}
		}
		async function loadSwitchRuns(section, chunkId) {
			try {
				const d = await getSwitchRuns(section);
				if (cite?.chunkId === chunkId && d) xruns = d;
			} catch {}
		}
		function runVariant(run) {
			return run.split("/")[1] ?? run;
		}
		let theme = "auto";
		function shortId(id) {
			return id.length > 16 ? `${id.slice(0, 8)}…${id.slice(-6)}` : id;
		}
		function srcRun(i) {
			const s = results[i]?.source ?? "";
			let start = i;
			while (start > 0 && results[start - 1].source === s) start -= 1;
			let end = i;
			while (end + 1 < results.length && results[end + 1].source === s) end += 1;
			return {
				first: start === i,
				n: end - start + 1
			};
		}
		function dispSource(s) {
			return pageUrl(s) ? String(s).replace(/\.md$/i, "") : s;
		}
		function srcTip(u) {
			return u.pinned ? `${u.repo} at ${u.ref.slice(0, 8)}: pinned commit, opens on GitHub` : `${u.repo} at ${u.ref}: opens on GitHub`;
		}
		function rowTip(r, i) {
			if (URL_STATE && true) {
				const ru = srcRun(i);
				if (ru.n >= 3 && ru.first) return `${ru.n} consecutive hits from this source: the ${ru.n - 1} rows below omit the repeated path`;
				if (r.toc) return "table-of-contents row: dot leaders collapsed in display";
			}
		}
		function row($$renderer, r, i) {
			const ru = srcRun(i);
			const pg = URL_STATE && r.page && !(ru && ru.n >= 3 && !ru.first) ? r.page : "";
			$$renderer.push(`<span class="rowhead svelte-1uha8ag"><!--[-->`);
			const each_array_1 = ensure_array_like(r.clusters);
			for (let $$index_15 = 0, $$length = each_array_1.length; $$index_15 < $$length; $$index_15++) {
				let c = each_array_1[$$index_15];
				$$renderer.push(`<span class="badge svelte-1uha8ag"${attr("data-cluster", c)}>${escape_html(c)}</span>`);
			}
			$$renderer.push(`<!--]--> `);
			if (r.toc) $$renderer.push(`<!--[0--><span class="tocbadge svelte-1uha8ag" title="table-of-contents row: dot leaders collapsed in display">contents row</span>`);
			else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> `);
			if (r.completion) $$renderer.push(`<!--[0--><span class="combadge svelte-1uha8ag" title="completion: matches a word extending your unfinished term; dropped when you commit">completion</span>`);
			else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> `);
			if (ru && ru.n >= 3) {
				$$renderer.push("<!--[0-->");
				if (ru.first) {
					$$renderer.push("<!--[0-->");
					if (r.sourceUrl) {
						$$renderer.push(`<!--[0--><a class="source svelte-1uha8ag"${attr("href", pageUrl(r.source) ?? r.sourceUrl.url)} target="_blank" rel="noreferrer noopener"${attr("title", pageUrl(r.source) ? "The rendered tutorial page — always the latest version" : srcTip(r.sourceUrl))}>`);
						srcpath($$renderer, dispSource(r.source) || r.chunkId, URL_STATE);
						$$renderer.push(`<!----></a>`);
					} else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]--> `);
					if (!r.sourceUrl) {
						$$renderer.push(`<!--[0--><span class="source svelte-1uha8ag">`);
						srcpath($$renderer, r.source || r.chunkId, URL_STATE);
						$$renderer.push(`<!----></span>`);
					} else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]--> <span class="srun svelte-1uha8ag"${attr("title", `${ru.n} consecutive hits from this source: the ${ru.n - 1} rows below omit the repeated path`)}>×${escape_html(ru.n)}</span> `);
					if (pg) $$renderer.push(`<!--[0--><span class="pgsep svelte-1uha8ag" aria-hidden="true">·</span><span class="page svelte-1uha8ag">${escape_html(pg)}</span>`);
					else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]-->`);
				} else $$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]-->`);
			} else {
				$$renderer.push("<!--[-1-->");
				if (r.sourceUrl) {
					$$renderer.push(`<!--[0--><a class="source svelte-1uha8ag"${attr("href", pageUrl(r.source) ?? r.sourceUrl.url)} target="_blank" rel="noreferrer noopener"${attr("title", pageUrl(r.source) ? "The rendered tutorial page — always the latest version" : srcTip(r.sourceUrl))}>`);
					srcpath($$renderer, dispSource(r.source) || r.chunkId, URL_STATE);
					$$renderer.push(`<!----></a>`);
				} else $$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]--> `);
				if (!r.sourceUrl) {
					$$renderer.push(`<!--[0--><span class="source svelte-1uha8ag">`);
					srcpath($$renderer, r.source || r.chunkId, URL_STATE);
					$$renderer.push(`<!----></span>`);
				} else $$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]--> `);
				if (pg) $$renderer.push(`<!--[0--><span class="pgsep svelte-1uha8ag" aria-hidden="true">·</span><span class="page svelte-1uha8ag">${escape_html(pg)}</span>`);
				else $$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]-->`);
			}
			$$renderer.push(`<!--]--></span> `);
			if (r.section) $$renderer.push(`<!--[0--><span class="section svelte-1uha8ag">${escape_html(r.section)}</span>`);
			else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> `);
			if (!URL_STATE) $$renderer.push(`<!--[0--><span class="page svelte-1uha8ag">${escape_html(r.page)}</span>`);
			else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> <span class="excerpt svelte-1uha8ag">${html(r.excerptHtml)}</span>`);
		}
		$$renderer.push(`<main${attr("data-api", URL_STATE ? "" : void 0)}${attr_class("svelte-1uha8ag", void 0, { "wide": splitOn() })}><header class="masthead reveal reveal-1 svelte-1uha8ag"><p class="overline svelte-1uha8ag">SOLPS-ITER knowledge layer</p> <div class="wordmark svelte-1uha8ag"><h1 class="svelte-1uha8ag">askthedocs</h1> <span class="tick svelte-1uha8ag" aria-hidden="true"></span></div> `);
		if (URL_STATE) $$renderer.push(`<!--[0--><button type="button" class="theme-toggle svelte-1uha8ag"${attr("aria-label", `Color scheme: ${theme} (follows this device); click to cycle auto, dark, light`)} title="Color scheme: cycles auto, dark, light">${escape_html(theme)}</button>`);
		else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> <p class="tagline svelte-1uha8ag">Answers in seconds: every claim carries its citation.</p> `);
		$$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--></header> `);
		$$renderer.push(`<!--[-1--><div${attr_class("bench svelte-1uha8ag", void 0, { "split": splitOn() })}><div class="master svelte-1uha8ag"><form role="search"${attr_class("reveal reveal-3 svelte-1uha8ag", void 0, { "listing": sel >= 0 })}><input type="search" name="q" placeholder="Search the corpus…" aria-label="Search the SOLPS-ITER corpus" autocomplete="off"${attr("value", query)} class="svelte-1uha8ag"/> <button type="submit"${attr("disabled", running, true)}${attr("aria-busy", running ? "true" : void 0)} class="svelte-1uha8ag"><span class="blabel svelte-1uha8ag">Search</span> `);
		if (running) $$renderer.push(`<!--[0--><span class="spin svelte-1uha8ag" aria-hidden="true"></span>`);
		else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--></button></form> <p class="spec reveal reveal-4 svelte-1uha8ag">`);
		if (!URL_STATE) $$renderer.push(`<!--[0-->bm25 over FTS5 ·`);
		else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]-->every hit cites source, section, page<span class="keys svelte-1uha8ag">· <kbd class="svelte-1uha8ag">/</kbd> to search · <kbd class="svelte-1uha8ag">↑↓</kbd> select · <kbd class="svelte-1uha8ag">↵</kbd> open`);
		if (URL_STATE) $$renderer.push(`<!--[0-->· <kbd class="svelte-1uha8ag">⌘K</kbd> commands`);
		else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--></span></p> `);
		if (URL_STATE && !query.trim() && !searched && !running && !cite && recents.length) {
			$$renderer.push(`<!--[0--><section class="recents reveal reveal-5 svelte-1uha8ag" aria-label="Recent queries"><h2 class="recents-label svelte-1uha8ag">recent queries</h2> <div class="recents-row svelte-1uha8ag"><!--[-->`);
			const each_array_2 = ensure_array_like(recents);
			for (let $$index = 0, $$length = each_array_2.length; $$index < $$length; $$index++) {
				let q = each_array_2[$$index];
				$$renderer.push(`<button type="button" class="recent svelte-1uha8ag">${escape_html(q)}</button>`);
			}
			$$renderer.push(`<!--]--></div></section>`);
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> `);
		if (transient) $$renderer.push(`<!--[0--><p class="pause svelte-1uha8ag" role="status">${escape_html(error)}; keep typing, the query reruns itself</p>`);
		else if (error) $$renderer.push(`<!--[1--><div class="errorcard card-in svelte-1uha8ag" role="alert"><p class="error-head svelte-1uha8ag">Search failed</p> <p class="error-msg svelte-1uha8ag">${escape_html(error)}</p> <p class="error-hint svelte-1uha8ag">The service may be unreachable or the query invalid. Edit the
							query to retry — the same corpus answers from the terminal
							(<code class="svelte-1uha8ag">askthedocs search QUERY</code>) and over MCP
							(<code class="svelte-1uha8ag">search_docs</code>).</p></div>`);
		else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> `);
		if (running && results.length === 0) {
			$$renderer.push(`<!--[0--><ol class="results skels svelte-1uha8ag" aria-hidden="true"><!--[-->`);
			const each_array_3 = ensure_array_like({ length: LIMIT });
			for (let $$index_1 = 0, $$length = each_array_3.length; $$index_1 < $$length; $$index_1++) {
				each_array_3[$$index_1];
				$$renderer.push(`<li class="hit skel svelte-1uha8ag"><span class="rowhead svelte-1uha8ag"><span class="sk sk-badge svelte-1uha8ag"></span> <span class="sk sk-src svelte-1uha8ag"></span></span> <span class="sk sk-meta svelte-1uha8ag"></span> <span class="sk sk-line w95 svelte-1uha8ag"></span> <span class="sk sk-line w80 svelte-1uha8ag"></span></li>`);
			}
			$$renderer.push(`<!--]--></ol>`);
		} else {
			$$renderer.push("<!--[-1-->");
			if (searched && !running) {
				$$renderer.push(`<!--[0--><p class="meta svelte-1uha8ag" aria-live="polite"><span class="count svelte-1uha8ag">${escape_html(total)}</span> `);
				$$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]--> ${escape_html(total === 1 ? "hit" : "hits")} `);
				$$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]--> `);
				if (total > results.length) $$renderer.push(`<!--[0-->(showing ${escape_html(results.length)})`);
				else $$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]--> `);
				if (completionsTotal) $$renderer.push(`<!--[0--><span class="sugg svelte-1uha8ag">+ ${escape_html(completionsTotal)} suggestions</span>`);
				else $$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]--></p> `);
				if (total > 0) {
					$$renderer.push("<!--[0-->");
					if (!URL_STATE) $$renderer.push(`<!--[0--><p class="hint svelte-1uha8ag">Click a hit: its citation opens beside the list.</p>`);
					else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]-->`);
				} else $$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]--> `);
				if (URL_STATE && facets.length > 1) {
					$$renderer.push(`<!--[0--><div class="chips svelte-1uha8ag" role="group" aria-label="Filter by cluster"><button type="button" class="chip svelte-1uha8ag"${attr("aria-pressed", "true")}><span class="c">all</span><span class="n svelte-1uha8ag">${escape_html(allCount())}</span></button> <!--[-->`);
					const each_array_4 = ensure_array_like(facets);
					for (let $$index_2 = 0, $$length = each_array_4.length; $$index_2 < $$length; $$index_2++) {
						let f = each_array_4[$$index_2];
						$$renderer.push(`<button type="button" class="chip svelte-1uha8ag"${attr("data-cluster", f.cluster)}${attr("aria-pressed", cluster === f.cluster ? "true" : "false")}><span class="c">${escape_html(f.cluster)}</span><span class="n svelte-1uha8ag">${escape_html(f.count)}</span></button>`);
					}
					$$renderer.push(`<!--]--></div>`);
				} else $$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]-->`);
			} else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> `);
			if (URL_STATE && cite && !searched && !running) {
				$$renderer.push("<!--[0-->");
				if (cite.chunk) {
					$$renderer.push(`<!--[0--><p class="meta svelte-1uha8ag"><span class="count svelte-1uha8ag">1</span> chunk: opened by id</p> <ol class="results svelte-1uha8ag"><li class="card-in svelte-1uha8ag" data-open=""><div class="hit svelte-1uha8ag"><a class="hit-open svelte-1uha8ag"${attr("href", viewHref({
						q: "",
						cluster: "",
						chunk: cite.chunk.chunkId
					}, ""))} aria-current="true"${attr("aria-label", `Open ${cite.chunk.source || cite.chunk.chunkId}`)}${attr("title", `chunk ${cite.chunk.chunkId}`)}></a> `);
					row($$renderer, syntheticRow(cite.chunk), 0);
					$$renderer.push(`<!----></div></li></ol>`);
				} else $$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]--> <p class="hint svelte-1uha8ag">Opened by chunk id: run a query to see it ranked among its neighbours.</p>`);
			} else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> `);
			if (searched && !running && total === 0 && !error) {
				$$renderer.push(`<!--[0--><div class="empty card-in svelte-1uha8ag">`);
				if (URL_STATE && extractChunkId(query)) $$renderer.push(`<!--[0--><p class="empty-head svelte-1uha8ag">That is a chunk id: search reads it as one long word.</p> <ul class="svelte-1uha8ag"><li>press Enter to open its citation: the id resolves exactly, no ranking involved</li> <li>to search inside chunks, use words from the text: the id itself never appears in it</li></ul>`);
				else {
					$$renderer.push(`<!--[-1--><p class="empty-head svelte-1uha8ag">No hits for “${escape_html(query.trim())}”.</p> `);
					if (didYouMean) $$renderer.push(`<!--[0--><p class="dym svelte-1uha8ag">did you mean <button class="dym-word svelte-1uha8ag">${escape_html(didYouMean)}</button>?</p>`);
					else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]--> `);
					if (completionWords.length) {
						$$renderer.push(`<!--[0--><p class="comp-words-label svelte-1uha8ag">words starting with “${escape_html(query.trim().split(/\s+/).at(-1))}”:</p> <ul class="comp-words svelte-1uha8ag"><!--[-->`);
						const each_array_5 = ensure_array_like(completionWords);
						for (let i = 0, $$length = each_array_5.length; i < $$length; i++) {
							let w = each_array_5[i];
							if (i === 0 || w.adjacent > 0 !== completionWords[i - 1].adjacent > 0) $$renderer.push(`<!--[0--><li class="comp-sub svelte-1uha8ag" aria-hidden="true"><span>${escape_html(w.adjacent > 0 ? "side-by-side with your other words:" : "in the same chunk:")}</span></li>`);
							else $$renderer.push("<!--[-1-->");
							$$renderer.push(`<!--]--> <li><button class="svelte-1uha8ag">${escape_html(w.word)} <span class="n svelte-1uha8ag">${escape_html(w.adjacent > 0 ? `${w.count} hits, ${w.adjacent} side-by-side` : `${w.count} hits`)}</span></button></li>`);
						}
						$$renderer.push(`<!--]--></ul>`);
					} else if (separateTerms.length) {
						$$renderer.push(`<!--[1--><p class="dym svelte-1uha8ag">But we have results for <!--[-->`);
						const each_array_6 = ensure_array_like(separateTerms);
						for (let i = 0, $$length = each_array_6.length; i < $$length; i++) {
							let t = each_array_6[i];
							$$renderer.push(`<!---->${escape_html(i > 0 ? i === separateTerms.length - 1 ? ", and for " : ", for " : "")} <button class="dym-word svelte-1uha8ag">${escape_html(t.term)} (${escape_html(t.count)})</button>`);
						}
						$$renderer.push(`<!--]-->.</p>`);
					} else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]--> <ul class="svelte-1uha8ag"><li>every term must appear in a chunk: try fewer, more general terms</li> <li>terms match whole words, either number (condition finds conditions too); no wildcards or fuzzy stemming</li> <li>pick vocabulary from the domain you want: manual prose (<code class="svelte-1uha8ag">detachment</code>), code identifiers (<code class="svelte-1uha8ag">eirene</code>, <code class="svelte-1uha8ag">b2mn</code>), GUI wording (<code class="svelte-1uha8ag">menu</code>, <code class="svelte-1uha8ag">dialog</code>)</li></ul>`);
				}
				$$renderer.push(`<!--]--></div>`);
			} else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]--> <ol class="results svelte-1uha8ag"><!--[-->`);
			const each_array_7 = ensure_array_like(results);
			for (let i = 0, $$length = each_array_7.length; i < $$length; i++) {
				let r = each_array_7[i];
				if (r.completion && (i === 0 || !results[i - 1].completion)) $$renderer.push(`<!--[0--><li class="comp-divider svelte-1uha8ag" aria-hidden="true"><span>suggestions: words starting with “${escape_html(query.trim().split(/\s+/).at(-1) ?? "")}”</span></li>`);
				else $$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]--> <li${attr("data-selected", i === sel ? "" : void 0)}${attr("data-open", cite?.chunkId === r.chunkId ? "" : void 0)}${attr_class("svelte-1uha8ag", void 0, {
					"card-in": true,
					"completion": r.completion
				})}>`);
				$$renderer.push(`<!--[-1--><div class="hit svelte-1uha8ag"><a class="hit-open svelte-1uha8ag"${attr("href", viewHref({
					q: query,
					cluster,
					chunk: r.chunkId
				}, ""))}${attr("aria-current", cite?.chunkId === r.chunkId ? "true" : void 0)}${attr("aria-label", `Open ${r.source || r.chunkId}`)}${attr("title", rowTip(r, i))}></a> `);
				row($$renderer, r, i);
				$$renderer.push(`<!----></div>`);
				$$renderer.push(`<!--]--></li>`);
			}
			$$renderer.push(`<!--]--></ol> `);
			if (searched && !running && !error && results.length < total) $$renderer.push(`<!--[0--><div class="morebar svelte-1uha8ag"><button type="button" class="morebtn svelte-1uha8ag"${attr("disabled", fetchingMore, true)}${attr("aria-busy", fetchingMore ? "true" : void 0)}>${escape_html(fetchingMore ? "Loading…" : `Show ${Math.min(LIMIT, total - results.length)} more`)}</button></div>`);
			else $$renderer.push("<!--[-1-->");
			$$renderer.push(`<!--]-->`);
		}
		$$renderer.push(`<!--]--></div> `);
		if (splitOn()) {
			$$renderer.push("<!--[0-->");
			if (cite) {
				$$renderer.push(`<!--[0--><section class="citation card-in svelte-1uha8ag" id="citation"><h2 class="svelte-1uha8ag">Citation`);
				if (searched && results.length) {
					$$renderer.push("<!--[0-->");
					const ro = results.findIndex((r) => r.chunkId === cite.chunkId);
					if (ro >= 0) $$renderer.push(`<!--[0--><span class="rank-echo svelte-1uha8ag">· result ${escape_html(ro + 1)} of ${escape_html(total)}</span>`);
					else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]-->`);
				} else $$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]--></h2> `);
				if (cite.loading) $$renderer.push(`<!--[0--><p class="hint svelte-1uha8ag">Loading chunk ${escape_html(cite.chunkId)}…</p>`);
				else if (cite.chunk) {
					$$renderer.push(`<!--[1--><p class="rowhead svelte-1uha8ag">`);
					if (cite.chunk.cluster) $$renderer.push(`<!--[0--><span class="badge svelte-1uha8ag"${attr("data-cluster", cite.chunk.cluster)}>${escape_html(cite.chunk.cluster)}</span>`);
					else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]--> `);
					if (cite.chunk.sourceUrl) {
						$$renderer.push("<!--[0-->");
						const page = pageUrl(cite.chunk.source);
						if (page) {
							$$renderer.push(`<!--[0--><a class="source svelte-1uha8ag"${attr("href", page)} target="_blank" rel="noreferrer noopener" title="The rendered tutorial page: solps-tutorials.readthedocs.io, always the latest version">`);
							srcpath($$renderer, dispSource(cite.chunk.source) || cite.chunk.chunkId, true);
							$$renderer.push(`<!----></a> <a class="source svelte-1uha8ag"${attr("href", cite.chunk.sourceUrl.url)} target="_blank" rel="noreferrer noopener"${attr("title", srcTip(cite.chunk.sourceUrl))}>pinned source</a>`);
						} else {
							$$renderer.push(`<!--[-1--><a class="source svelte-1uha8ag"${attr("href", cite.chunk.sourceUrl.url)} target="_blank" rel="noreferrer noopener"${attr("title", srcTip(cite.chunk.sourceUrl))}>`);
							srcpath($$renderer, cite.chunk.source || cite.chunk.chunkId, true);
							$$renderer.push(`<!----></a>`);
						}
						$$renderer.push(`<!--]-->`);
					} else {
						$$renderer.push(`<!--[-1--><span class="source svelte-1uha8ag">`);
						srcpath($$renderer, cite.chunk.source || cite.chunk.chunkId, true);
						$$renderer.push(`<!----></span>`);
					}
					$$renderer.push(`<!--]--> `);
					if (cite.chunk.cluster === "source_switch") {
						$$renderer.push("<!--[0-->");
						const docs = switchDocsUrl();
						$$renderer.push(`<a class="source svelte-1uha8ag"${attr("href", docs.url)} target="_blank" rel="noreferrer noopener"${attr("title", srcTip(docs))}>b2input.xml</a>`);
					} else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]--></p> <dl class="provenance svelte-1uha8ag">`);
					if (cite.chunk.section) $$renderer.push(`<!--[0--><div class="svelte-1uha8ag"><dt class="svelte-1uha8ag">section</dt><dd class="svelte-1uha8ag">${escape_html(cite.chunk.section)}</dd></div>`);
					else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]--> `);
					if (cite.chunk.page) $$renderer.push(`<!--[0--><div class="svelte-1uha8ag"><dt class="svelte-1uha8ag">page</dt><dd class="svelte-1uha8ag">${escape_html(cite.chunk.page)}</dd></div>`);
					else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]--> <div class="svelte-1uha8ag"><dt class="svelte-1uha8ag">chunk id</dt> <dd class="svelte-1uha8ag"><button type="button" class="idchip svelte-1uha8ag"${attr("data-copied", void 0)}${attr("aria-label", `Copy chunk id ${cite.chunk.chunkId}`)}${attr("title", cite.chunk.chunkId)}>${escape_html(shortId(cite.chunk.chunkId))}</button></dd></div></dl> `);
					if (cite.chunk.sourceUrl && !pageUrl(cite.chunk.source)) $$renderer.push(`<!--[0--><p class="deepnote svelte-1uha8ag">The source path opens the file in its public GitHub repository:
									Fortran links carry the chunk's line range; GitHub's PDF viewer
									takes no page anchor, so the page number in the citation is
									the anchor.</p>`);
					else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]--> `);
					if (cite.chunk.sourceUrl && pageUrl(cite.chunk.source)) $$renderer.push(`<!--[0--><p class="deepnote svelte-1uha8ag">The source path opens the rendered tutorial page: live, always
									the latest version; 'pinned source' opens the exact commit this
									citation was indexed from.</p>`);
					else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]--> <div class="cite-actions svelte-1uha8ag"><button type="button" class="copybtn svelte-1uha8ag"${attr("data-copied", void 0)}>${escape_html("Copy citation")}</button> <button type="button" class="copybtn svelte-1uha8ag"${attr("data-copied", void 0)}>${escape_html("Copy with link")}</button> <span class="copystatus svelte-1uha8ag" role="status" aria-live="polite">`);
					$$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]--></span></div> `);
					if (marks.length) $$renderer.push(`<!--[0--><p class="mnav svelte-1uha8ag"><span class="mcount svelte-1uha8ag" aria-live="polite">match <span class="mnum svelte-1uha8ag">${escape_html(1)}</span> of ${escape_html(marks.length)} in text</span> <button type="button" class="mstep mprev svelte-1uha8ag"${attr("disabled", true, true)} aria-label="Previous match">‹</button> <button type="button" class="mstep mnext svelte-1uha8ag"${attr("disabled", mIdx === marks.length - 1, true)} aria-label="Next match">›</button></p>`);
					else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]--> <!---->`);
					$$renderer.push(`<div class="text svelte-1uha8ag">${escape_html(cite.chunk.text)}</div>`);
					$$renderer.push(`<!----> `);
					if (cite.chunk.cluster === "source_switch" && xruns) {
						$$renderer.push(`<!--[0--><aside class="xruns svelte-1uha8ag" aria-label="Cataloged runs setting this switch"><p class="xruns-head svelte-1uha8ag">`);
						if (xruns.runs.length) $$renderer.push(`<!--[0-->set by ${escape_html(xruns.runs.length)}
											${escape_html(xruns.runs.length === 1 ? "cataloged run" : "cataloged runs")}`);
						else $$renderer.push(`<!--[-1-->run catalog`);
						$$renderer.push(`<!--]--></p> `);
						if (xruns.catalog !== "built") $$renderer.push(`<!--[0--><p class="xruns-note svelte-1uha8ag">catalog not built</p>`);
						else if (!xruns.runs.length) $$renderer.push(`<!--[1--><p class="xruns-note svelte-1uha8ag">no cataloged run sets this switch</p>`);
						else {
							$$renderer.push(`<!--[-1--><ul class="xruns-list svelte-1uha8ag"><!--[-->`);
							const each_array_8 = ensure_array_like(xruns.runs);
							for (let $$index_6 = 0, $$length = each_array_8.length; $$index_6 < $$length; $$index_6++) {
								let r = each_array_8[$$index_6];
								$$renderer.push(`<li class="svelte-1uha8ag"><span class="xr-variant svelte-1uha8ag">${escape_html(runVariant(r.run))}</span> <span class="xr-family svelte-1uha8ag">${escape_html(r.family)}</span> <code class="xr-value svelte-1uha8ag">${escape_html(r.value)}</code></li>`);
							}
							$$renderer.push(`<!--]--></ul> <p class="xruns-note svelte-1uha8ag">values from the runs' effective b2mn.dat, read live from the run catalog</p>`);
						}
						$$renderer.push(`<!--]--></aside>`);
					} else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]--> `);
					if (cite.matched.length || cite.score != null || cite.phraseHit || cite.identity) {
						$$renderer.push(`<!--[0--><aside class="why svelte-1uha8ag"><p class="why-head svelte-1uha8ag">why this result</p> `);
						if (cite.identity) $$renderer.push(`<!--[0--><p class="phraseline identityline svelte-1uha8ag">exact name<span class="dir svelte-1uha8ag">this chunk's citation is “${escape_html(cite.chunk?.section ?? query.trim())}”: the thing you named, ranked first</span></p>`);
						else $$renderer.push("<!--[-1-->");
						$$renderer.push(`<!--]--> `);
						if (cite.phraseHit) $$renderer.push(`<!--[0--><p class="phraseline svelte-1uha8ag">phrase tier<span class="dir svelte-1uha8ag">query terms adjacent: ranks ahead of all non-phrase hits</span></p>`);
						else $$renderer.push("<!--[-1-->");
						$$renderer.push(`<!--]--> `);
						if (cite.matched.length) {
							$$renderer.push("<!--[0-->");
							const maxN = Math.max(...cite.matched.map((m) => m.n));
							$$renderer.push(`<p class="terms svelte-1uha8ag"><!--[-->`);
							const each_array_9 = ensure_array_like(cite.matched);
							for (let $$index_7 = 0, $$length = each_array_9.length; $$index_7 < $$length; $$index_7++) {
								let m = each_array_9[$$index_7];
								$$renderer.push(`<span class="term svelte-1uha8ag"><span class="t svelte-1uha8ag">${escape_html(m.term)}</span><span class="n svelte-1uha8ag">×${escape_html(m.n)}</span> <span class="fbar svelte-1uha8ag" aria-hidden="true"><span class="ffill svelte-1uha8ag"${attr_style(`width:${stringify(Math.max(6, Math.round(100 * m.n / maxN)))}%`)}></span></span></span>`);
							}
							$$renderer.push(`<!--]--></p>`);
						} else $$renderer.push("<!--[-1-->");
						$$renderer.push(`<!--]--> `);
						if (cite.score != null) $$renderer.push(`<!--[0--><p class="scoreline svelte-1uha8ag">bm25 <span class="score svelte-1uha8ag">${escape_html(cite.score.toFixed(2))}</span> <span class="dir svelte-1uha8ag">lower is better</span></p>`);
						else $$renderer.push("<!--[-1-->");
						$$renderer.push(`<!--]--> <p class="why-note svelte-1uha8ag">term presence + frequency in this chunk: not a per-term bm25 breakdown</p></aside>`);
					} else $$renderer.push("<!--[-1-->");
					$$renderer.push(`<!--]--> <p class="verify svelte-1uha8ag">Verify from the terminal: <code class="svelte-1uha8ag">askthedocs show ${escape_html(cite.chunk.chunkId)}</code></p>`);
				} else $$renderer.push(`<!--[-1--><p class="error svelte-1uha8ag">no chunk with id ${escape_html(cite.chunkId)}</p>`);
				$$renderer.push(`<!--]--></section>`);
			} else if (specimenOn()) {
				$$renderer.push(`<!--[1--><section class="citation card-in svelte-1uha8ag" aria-label="Citation specimen"><h2 class="svelte-1uha8ag">Citation <span class="spec-tag svelte-1uha8ag">specimen</span></h2> <p class="rowhead svelte-1uha8ag">`);
				if (specimen.cluster) $$renderer.push(`<!--[0--><span class="badge svelte-1uha8ag"${attr("data-cluster", specimen.cluster)}>${escape_html(specimen.cluster)}</span>`);
				else $$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]--> `);
				if (specimen.sourceUrl) {
					$$renderer.push(`<!--[0--><a class="source svelte-1uha8ag"${attr("href", specimen.sourceUrl.url)} target="_blank" rel="noreferrer noopener"${attr("title", srcTip(specimen.sourceUrl))}>`);
					srcpath($$renderer, specimen.source || specimen.chunkId, true);
					$$renderer.push(`<!----></a>`);
				} else {
					$$renderer.push(`<!--[-1--><span class="source svelte-1uha8ag">`);
					srcpath($$renderer, specimen.source || specimen.chunkId, true);
					$$renderer.push(`<!----></span>`);
				}
				$$renderer.push(`<!--]--></p> <dl class="provenance svelte-1uha8ag">`);
				if (specimen.section && specimen.section !== "-") $$renderer.push(`<!--[0--><div class="svelte-1uha8ag"><dt class="svelte-1uha8ag">section</dt><dd class="svelte-1uha8ag">${escape_html(specimen.section)}</dd></div>`);
				else $$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]--> `);
				if (specimen.page) $$renderer.push(`<!--[0--><div class="svelte-1uha8ag"><dt class="svelte-1uha8ag">page</dt><dd class="svelte-1uha8ag">${escape_html(specimen.page)}</dd></div>`);
				else $$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]--> <div class="svelte-1uha8ag"><dt class="svelte-1uha8ag">chunk id</dt> <dd class="svelte-1uha8ag"><button type="button" class="idchip svelte-1uha8ag"${attr("data-copied", void 0)}${attr("aria-label", `Copy chunk id ${specimen.chunkId}`)}${attr("title", specimen.chunkId)}>${escape_html(shortId(specimen.chunkId))}</button></dd></div></dl> `);
				if (specimen.sourceUrl) $$renderer.push(`<!--[0--><p class="deepnote svelte-1uha8ag">The source path opens the file in its public GitHub repository —
								Fortran links carry the chunk's line range; GitHub's PDF viewer
								takes no page anchor, so the page number in the citation is
								the anchor.</p>`);
				else $$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]--> <div class="cite-actions svelte-1uha8ag"><button type="button" class="copybtn svelte-1uha8ag"${attr("data-copied", void 0)}>${escape_html("Copy citation")}</button> <button type="button" class="copybtn svelte-1uha8ag"${attr("data-copied", void 0)}>${escape_html("Copy with link")}</button> <span class="copystatus svelte-1uha8ag" role="status" aria-live="polite">`);
				$$renderer.push("<!--[-1-->");
				$$renderer.push(`<!--]--></span></div> <div class="text svelte-1uha8ag">${escape_html(specimen.text)}</div> <p class="verify svelte-1uha8ag">Verify from the terminal: <code class="svelte-1uha8ag">askthedocs show ${escape_html(specimen.chunkId)}</code></p></section>`);
			} else $$renderer.push(`<!--[-1--><section class="citation ph card-in svelte-1uha8ag"><h2 class="svelte-1uha8ag">Citation</h2> <div class="ph-body svelte-1uha8ag"><span class="ph-tick svelte-1uha8ag" aria-hidden="true"></span> <p class="svelte-1uha8ag">Select a hit and the full chunk appears here: text,
								provenance, and why it ranked.</p></div></section>`);
			$$renderer.push(`<!--]-->`);
		} else $$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--></div>`);
		$$renderer.push(`<!--]--></main> `);
		$$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> `);
		$$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]--> `);
		$$renderer.push("<!--[-1-->");
		$$renderer.push(`<!--]-->`);
	});
}
//#endregion
export { _page as default };
