<script>
	// search page — : ALL data access lives in
	// $lib/data.js (the boundary criterion).  This component renders;
	// it never fetches. Which backend serves the rows — the 
	// fragmented index (static mode) or the FastAPI service
	// (api mode) — is a BUILD-time flag (ASKTHEDOCS_MODE) read inside
	// the data module, so flipping deployment never rewrites this
	// page.
	//
	// the query FLOW (debounce, supersede + abort, skeleton
	// state) lives in $lib/instant.js — a framework-free controller
	// a node test can exercise with a delayed mock.  This component
	// renders onState snapshots and routes keys; it still owns no
	// fetches.
	//
	// api mode lays out as a workbench — the results list
	// (master) beside the citation pane (detail) once a search is under
	// way.  Static mode keeps its frozen single-column page: no pane
	// ever renders there, clicks navigate to the citation pages.
	//
	// every query term is marked inside the pane's chunk
	// text (text-node walking in $lib/highlight.js — never innerHTML of
	// untrusted text) and an n-of-m navigator scrolls to each match.
	//
	// the URL is the state — ?q=&cluster=&chunk= drive the
	// app, every committed view becomes a history entry, and popstate
	// restores a view INCLUDING auto-running its query.  The pure
	// parse/serialize half lives in $lib/urlstate.js; this component
	// owns only the window/history wiring.  API mode only — the static
	// face is frozen at v1-static and never reads or writes these
	// parameters.
	//
	// ⌘K opens the command palette — run a query, filter to
	// a cluster, paste a chunk id, re-run a recent.  The command model
	// (chunk-id detection, recents behind an injected store, command
	// building, the selection ring) is framework-free in
	// $lib/palette.js; this component owns the dialog, the ARIA
	// combobox/listbox wiring, the focus trap, and the actions.  API
	// mode only — the static face never hears ⌘K.
	//
	// the citation pane carries a copy button in two forms —
	// the plain provenance line and the same line plus the view's deep
	// link (the text assembly is framework-free in $lib/citeformat.js;
	// this component owns the clipboard and the honest copied/failed
	// status).  A search failure renders as a card with guidance, never
	// a bare red line.
	//
	// hits past the first page stay reachable — a "show N
	// more" control appends the next batch through the same search
	// (a bigger `limit`, no new endpoint).  Rows stay keyed by chunk
	// id so appends extend the list in place; selection, the pane
	// anchor and the URL all survive a batch, and the control hides
	// at exhaustion.
	//
	// below the 68rem split the pane still exists — the
	// stacked phone face.  The text cap is gone there (the page is
	// the only scroller, no nested scroll trap), opening a citation
	// brings the pane into view, and the match navigator centers its
	// matches in the viewport; the split keeps its pane-scroll
	// behavior unchanged.
	//
	// the landing state offers the way back in — a recents
	// band under the search instrument, iff this browser has committed
	// queries before (the palette's localStorage store, —
	// nothing new is invented).  Each recent is a real button on the
	// existing runQuery path: the query fires, the view commits as
	// its own history entry, the recent moves to the front.  No
	// recents, no band — a first-time landing renders exactly the
	// page it was (owner ruling: recents only, no curated examples,
	// no cluster census; REVISED 2026-09-26, — one curated
	// citation SPECIMEN exhibit is allowed, example queries and
	// cluster census stay out).  API mode only; the static face is
	// frozen.
	//
	// the pane's machine values finish like the instrument
	// they belong to — the chunk id renders 8…6 with click-to-copy of
	// the FULL id (the verify line keeps it visible; nothing is lost),
	// the bm25 score drops the 15-significant-figure theater (two
	// decimals), "lower is better" is promoted out of the dimmest slot,
	// the copy actions sit provenance-adjacent (reachable without
	// scrolling the text), and one honest line explains where a source
	// deep-link would go (the corpus's PDFs are bundled, not
	// deep-linkable — the dead end gets explained, not hidden).
	//
	// keyboard teaching appears ONCE — in the .spec line
	// under the search instrument, as <kbd> keycaps inside a .keys
	// span that a coarse pointer (no keyboard to teach) hides whole,
	// separators included.  The results hint and the pane placeholder
	// keep their functional claims and lose their keybind coaching:
	// one teacher, many doers.
	//
	// the list shows the corpus's best face, display-path
	// only — excerpt hygiene (collapsed dot leaders, joined
	// end-of-line hyphenation) happens in $lib/data.js's api path;
	// here, contents rows carry a leader-dot badge (NEVER demoted —
	// ranking is not ours to change) and consecutive same-source runs
	// >= 3 fold their path repetition (the source renders once, with
	// a ×n count; the run's other rows omit it).  Both are api-mode
	// affordances: the static face renders every source, unbadged,
	// exactly as it did.
	//
	// every citation reaches its document — the source
	// path renders as an anchor into the file's public GitHub
	// repository (rows document-level, the pane's Fortran chunks
	// line-anchored via their own text header; the link arrives as
	// DATA from $lib/data.js's api path, so the static face's plain
	// paths are frozen by construction).  The api row's primary
	// action becomes a STRETCHED LINK over the card — a real anchor
	// inside a button is invalid HTML, and the stretched form keeps
	// click, Enter AND middle-click (the href is the deep
	// link, so a new tab restores this exact view).
	//
	// file:// degraded mode: both backends fetch over HTTP, so an
	// offline folder copy replaces the search box with a notice
	// pointing at the CLI/MCP faces.  The protocol is detected in
	// onMount — never attempt a query there.
	import { onDestroy, onMount, tick } from 'svelte';
	import { CITATION_VIEW, chunkHref, fetchCorpus, fetchVerdicts, getChunk, getSwitchRuns, loadSpecimen, openReindexEvents, searchChunks, SPECIMEN_TERMS, startReindex, syntheticRow } from '$lib/data.js';
	import { createInstantSearch } from '$lib/instant.js';
	import { markTextNodes } from '$lib/highlight.js';
	import { readView, sameView, viewHref } from '$lib/urlstate.js';
	import { buildCommands, extractChunkId, isChunkId, loadRecents, moveSel, pushRecent } from '$lib/palette.js';
	import { citationForms } from '$lib/citeformat.js';
	import { pageUrl, switchDocsUrl, SOURCE_REPOS, MODULE_REPOS } from '$lib/srclink.js';

	const LIMIT = 10;

	// the URL carries state only in api mode — the static face
	// never reads it, writes it, or renders the controls that set it
	const URL_STATE = CITATION_VIEW === 'inline';

	let query = $state('');
	// 2026-10-18: the box's last-seen text, tracked OUTSIDE bind:value —
	// Svelte's binding syncs `query` before the oninput handler runs,
	// so comparing against `query` there can never see the edit.  This
	// mirror is what the typeahead's filter reset compares against.
	let lastTyped = '';
	// 2026-10-18: true while the current result set came from LIVE
	// typing (the typeahead) rather than a committed action — the
	// card-in entrance animation belongs to committed searches only;
	// a live swap animating every row at once reads as a flash
	let liveTyping = $state(false);
	let offline = $state(false); // file:// — search unavailable
	// the active cluster filter (api mode, ): '' = all clusters
	let cluster = $state('');
	// per-cluster chip data mirrored from the controller snapshots
	let facets = $state([]);
	// deep-link restore: the chunk the URL asks for, opened in
	// the pane once its search lands (cleared after the first result
	// set — it is a one-shot anchor, not persistent state)
	let pendingChunk = $state(null);
	// search state, owned by the controller and mirrored here from
	// its onState snapshots)
	let running = $state(false);
	let searched = $state(false);
	let total = $state(0);
	let completionsTotal = $state(0); // : completion-tier size while typing
	let didYouMean = $state(null); // : zero-hit boundary pick
	let completionWords = $state([]); // : [{word, count, adjacent}] on that boundary
	let separateTerms = $state([]); // (c): [{term, count}] when nothing combines
	let results = $state([]); // rows from searchChunks()
	let error = $state('');
	// mid-typing 4xx (dangling FTS5 syntax): a "keep typing" pause,
	// never a red error
	let transient = $state(false);
	// a show-more batch is in flight (the list keeps its rows
	// and meta — only the control itself goes busy)
	let fetchingMore = $state(false);
	// inline citation (api mode): { chunkId, loading, chunk | null,
	// matched, score } — the last two (why-this-result)
	// come from the hit row and stay undefined in static mode, where
	// the panel simply does not render
	let cite = $state(null);
	// the landing specimen — one real chunk exhibited in
	// the pane before any search (api mode only; null until loaded,
	// and null on ANY failure — the pane then falls back to its quiet
	// placeholder, a landing never shows an error it cannot fix)
	let specimen = $state(null);
	let specText = $state(null); // the specimen's .text box — walked after render
	// keyboard selection index into results (-1 = none)
	let sel = $state(-1);
	let box = $state(null); // the search input — '/' focuses it
	let pane = $state(null); // the citation pane — scroll resets per chunk
	// match navigator: the <mark> elements highlightTextNodes
	// planted in the pane's chunk text (document order) and the index
	// of the one the navigator is on
	let marks = $state([]);
	let mIdx = $state(0);
	let textEl = $state(null); // the pane's .text box — walked after render
	// the catalog cross-reference of the open citation —
	// { catalog: 'built'|'absent', runs: [{run, family, value}] } when
	// the open chunk is a source_switch citation (its section IS the
	// switch name, the ruled join key), else null (no panel).  Both
	// zero states are DATA, rendered verbatim: an absent artifact is
	// "catalog not built", an empty runs list is "no cataloged run
	// sets this switch" — never curated examples (design-audit ruling
	// 2026-09-26).  Api mode only; any fetch failure quietly drops
	// the panel (a bonus cross-reference is never a complaint).
	let xruns = $state(null);

	// command palette (api mode only): pQuery is the
	// palette's own box, pSel its keyboard ring, recents the persisted
	// query history.  pReturn holds the element to hand focus back to
	// when the dialog closes (never rendered, plain variable).
	let paletteOpen = $state(false);
	// corpus provenance line + repository modal
	let corpusInfo = $state(null);
	let corpusOpen = $state(false);
	let corpusError = $state('');
	let corpusDialog = $state(null);
	let corpusDate = $derived(
		corpusInfo ? new Date(corpusInfo.built_at).toISOString().slice(0, 10) : ''
	);
	// freshness: verdicts (the /status body) checked lazily after
	// every page load and once per 24 h in a living tab, re-fetched
	// on every modal open; verdictState drives the band's honest
	// states (fetching / ok / absent / unknown).  The reindex job:
	// one slot per service, followed over the PUSH stream (one
	// Server-Sent Events connection replaces the 2 s poll), its
	// measured duration quoted by the NEXT confirmation.
	let verdicts = $state(null);
	let verdictState = $state('idle'); // idle|fetching|ok|absent|unknown
	let verdictNote = $state(''); // the absent answer's named situation prose
	let reindexJob = $state(null); // the summary half of the poll shape (never .frame)
	let reindexPhase = $state('closed'); // closed | running | done | failed
	let reindexRefusal = $state('');
	let confirmOpen = $state(false);
	let confirmMode = $state('drift'); // 'drift' | 'force': the confirm's facts
	let progressOpen = $state(false); // the live-frame modal over the corpus modal
	let reindexStarting = $state(false); // the POST is in flight (the drift gate hashes before it answers)
	let stream = null; // plain: the EventSource, never rendered
	// the live display frame, updated line-by-line from the stream's
	// deltas (keyed per index in the template: a changed line updates
	// ITS span, never a full-frame rebuild)
	let frameLines = $state([]);
	// the elapsed clock: client-side, 1 Hz, one text node — the
	// running timer is the not-stuck signal.  The
	// anchor is the job's started_at taken from the POST answer (the
	// known race: never from a later observation), or the adopted
	// snapshot's for a job this page picked up mid-run
	let jobStartedIso = null; // plain: the anchor, never rendered raw
	let elapsedText = $state('');
	let clockTimer = null; // plain: the 1 Hz tick handle
	let dayTimer = null; // plain: the 24 h passive re-check handle
	let driftedLegs = $derived(
		verdicts?.legs?.filter((l) => l.verdict === 'drifted') ?? []
	);
	let carriedLegs = $derived(
		verdicts?.legs?.filter((l) => l.verdict === 'carried') ?? []
	);
	let frozenAsShipped = $derived(
		!!verdicts && verdicts.repos_present === 0 && carriedLegs.length > 0
	);
	// the chip's verdict face: the LATEST completed verdict (the
	// previous verdicts stay while a newer check is in flight, so the
	// chip never blinks neutral mid-check), overridden while a
	// rebuild runs or just failed.  The not-found state folds BOTH
	// absent shapes into one story: the service could not resolve the
	// corpus (the named 503), or resolved it and found zero
	// repositories (everything carried).  Null = neutral: no verdict.
	let chipState = $derived.by(() => {
		if (reindexPhase === 'running') return 'indexing';
		if (reindexPhase === 'failed') return 'failed';
		if (verdicts) {
			if (frozenAsShipped) return 'notfound';
			if (driftedLegs.length > 0) return 'drifted';
			return 'current';
		}
		if (verdictState === 'absent') return 'notfound';
		return null;
	});
	// the appended finding, after the unchanged base text: the color
	// is never the only carrier of the state
	let chipSuffix = $derived(
		chipState === 'drifted' ? ' · corpus shifted, click for details' :
		chipState === 'notfound' ? ' · corpus not found, click for details' :
		chipState === 'failed' ? ' · rebuild failed, click for details' : ''
	);
	let verdictMap = $derived(
		new Map((verdicts?.legs ?? []).map((l) => [l.name, l]))
	);
	let driftTotals = $derived({
		n: verdicts?.drift?.new?.length ?? 0,
		c: verdicts?.drift?.changed?.length ?? 0,
		r: verdicts?.drift?.removed?.length ?? 0
	});
	let pQuery = $state('');
	let pSel = $state(-1);
	let recents = $state([]);
	let pInput = $state(null); // the palette combobox — focus lands here on open
	let pReturn = null;

	// the command list for the current palette input — the pure model
	// in $lib/palette.js fed the live facet counts, the active cluster
	// and the recents
	const cmds = $derived(
		buildCommands({ text: pQuery, facets, cluster, recents })
	);

	// workbench split: API mode only — static mode keeps its
	// frozen single-column page (clicks navigate to citation pages).
	// From the first search on, the layout reserves the detail column:
	// the pane holds the open citation or a quiet placeholder, so
	// reading happens beside the list at >=68rem — and below it,
	// stacked, where keeps the pane alive on phones. A
	// citation opened straight by chunk id (palette, ) engages
	// the workbench too — the pane does not wait for a search to exist.
	// the landing exhibit engages the workbench too — the
	// page opens as the workbench AT REST, the specimen pane beside
	// the instrument (owner-directed revision of the zero-state
	// ruling, 2026-09-26: one curated citation exhibit in, curated
	// example queries and cluster census still out).  specimenOn is
	// the recents band's own gate family: clean slate, nothing typed,
	// nothing running, no pane open — Esc back to zero restores it.
	const specimenOn = $derived(
		CITATION_VIEW === 'inline' &&
			!offline &&
			!!specimen &&
			!query.trim() &&
			!running &&
			!searched &&
			!cite
	);
	const splitOn = $derived(CITATION_VIEW === 'inline' && (running || searched || !!cite || specimenOn));

	// the all-pill's count — SUM(facets). Computes
	// facets WITHOUT the active filter, so this stays the UNFILTERED
	// total even while one chip is on: the escape quantifies exactly
	// how many results the filter is hiding.
	const allCount = $derived(facets.reduce((s, f) => s + f.count, 0));

	// the live stacked/split answer for THIS viewport — one
	// matchMedia drives every breakpoint-aware behavior.  `stacked`
	// feeds the template (the hint's location word); handlers read
	// `wide.matches` plainly instead, so a viewport crossing 68rem can
	// never re-fire an open-scroll.  SSR/prerender (the static build's
	// index): window is absent, wide is null, stacked starts true — no
	// prerendered markup reads it, so nothing mismatches on hydration.
	const wide =
		typeof window === 'undefined' ? null : window.matchMedia('(min-width: 68rem)');
	let stacked = $state(!wide?.matches);

	const inst = createInstantSearch({
		// `cluster` is read at call time — a chip click changes it and
		// refires, so every request carries the filter now in force.
		// ...opts also carries the controller's own `limit`:
		// show-more asks for shown+batch rows; a fresh ask stays LIMIT)
		search: (q, opts) =>
			searchChunks(q, { limit: LIMIT, cluster: cluster || undefined, ...opts }),
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
			// a show-more batch GROWS the list (rows keyed by
			// chunk id) — selection, pane anchor and URL survive it;
			// only a fresh result set resets them
			if (s.appended) return;
			sel = -1; // a fresh result set resets selection + citation
			// …EXCEPT when the URL restore is about to re-anchor this
			// very chunk): keep the pane through the swap
			if (!(pendingChunk && cite?.chunkId === pendingChunk)) cite = null;
			// a restored view's chunk opens with its results (the row
			// supplies the why-this-result terms; a chunk beyond the
			// first LIMIT rows still opens, panel-less — honest)
			if (pendingChunk && s.searched && !s.running) {
				const id = pendingChunk;
				pendingChunk = null;
				const row = s.results.find((r) => r.chunkId === id);
				if (cite?.chunkId === id && row) {
					cite.matched = row.matchedTerms ?? [];
					cite.score = row.score ?? null;
					cite.phraseHit = row.phraseHit === true;
					cite.identity = row.identity === true;
				} else {
					openCitation(id);
				}
			}
			// typed queries REWRITE the entry in place — shareable at
			// every pause without flooding history)
			if (s.searched && !s.running) syncUrl('replace');
		}
	});

	// choosing a completion (the did-you-mean word, or any word
	// in the zero-hit list) rewrites the query's unfinished last token
	// and COMMITS the result — input() seeds the controller's own
	// query state, submit() fires the committed answer now
	function pickCompletion(word) {
		const parts = query.trim().split(/\s+/);
		if (!parts.length) return;
		parts[parts.length - 1] = word;
		const next = parts.join(' ');
		query = next;
		inst.input(next);
		inst.submit();
	}

	// (c): the escape hatch — a typed term run ALONE. No extending
	// word combines with the rest of the query, so the honest way out is
	// the term's own one-word search (its shown count IS what this
	// yields); the query box becomes the term and the answer commits now
	function pickEscape(term) {
		query = term;
		inst.input(term);
		inst.submit();
	}

	// ------------------------------------------------------ : URL
	// The current view as the codec sees it — query, active cluster,
	// the pane's chunk.  syncUrl writes it to the address bar: 'push'
	// for committed views (submit, chip, citation — Back/Forward walk
	// these), 'replace' for in-place refinements (typing, reset).
	// Identical views write nothing, so popstate restores never echo.
	function syncUrl(mode) {
		if (!URL_STATE || offline) return;
		const view = { q: query, cluster, chunk: cite?.chunkId ?? '' };
		if (sameView(window.location.search, view)) return;
		const href = viewHref(view, window.location.pathname);
		if (mode === 'push') history.pushState({}, '', href);
		else history.replaceState({}, '', href);
	}

	// Back/Forward: the URL IS the target state — restore the query,
	// the cluster and the pane from it, auto-running the query (the
	// criterion: a restored view reruns, it does not just repaint)
	function onPop() {
		const view = readView(window.location.search);
		cluster = view.cluster;
		query = view.q; // the box shows what is running
		lastTyped = view.q;
		pendingChunk = view.chunk || null;
		if (!view.chunk) cite = null;
		if (view.q) {
			// input() seeds the controller's query, submit() fires NOW
			inst.input(view.q);
			inst.submit();
		} else {
			inst.input('');
			// a chunk-only view opens its pane directly — the
			// same path the onMount deep link takes
			if (view.chunk) {
				pendingChunk = null;
				openCitation(view.chunk);
			}
		}
		sel = -1;
	}

	// the corpus line's data loads WITH the page — the line
	// renders only when the service answered, and the line is itself
	// the modal's opener (a click-lazy fetch would hide the opener
	// until first click: a deadlock, caught in the live smoke)
	onMount(() => {
		fetchCorpus().then((d) => { if (d) corpusInfo = d; }).catch(() => {});
		if (window.location.protocol === 'file:') offline = true;
		if (URL_STATE && !offline) {
			// the lazy freshness verdict: background-only, after the
			// page is up (never blocking first paint or the search
			// box), once per load, plus one re-check per 24 h in a
			// tab that never reloads (the chip self-heals; every
			// modal open re-checks as it always did)
			refreshVerdicts().catch(() => {});
			dayTimer = setInterval(
				() => refreshVerdicts().catch(() => {}),
				24 * 60 * 60 * 1000
			);
			// the push stream opens with the page: an idle slot
			// then ANNOUNCES a job started anywhere (the chip turns
			// indexing with the elapsed ticking); after a terminal it
			// closes for good until the next confirm or modal-open
			// re-opens it (the ruled close discipline)
			ensureStream();
		}
		// the persisted scheme (recents-style tolerance —
		// malformed data and unavailable storage both answer 'auto').
		// Applies even offline: theming is cosmetic.  Known minor: a
		// forced choice paints one system-themed frame before
		// hydration (app.html is shared with the frozen static face,
		// so no pre-paint script rides there).
		if (URL_STATE) {
			try {
				const t = window.localStorage.getItem(THEME_KEY);
				if (t === 'light' || t === 'dark') theme = t;
			} catch {
				/* storage unavailable — stay auto */
			}
			applyTheme();
		}
		if (URL_STATE && !offline) {
			// deep link: ?q=&cluster=&chunk= drive the app on load —
			// the query auto-runs, the chunk anchors to the results
			const view = readView(window.location.search);
			cluster = view.cluster;
			pendingChunk = view.chunk || null;
			// the palette's recents): injected storage, so the
			// module itself stays DOM-free; malformed data answers []
			recents = loadRecents(window.localStorage);
			// the landing exhibit — one best-effort fetch; any
			// failure leaves it null and the pane falls back to its
			// quiet placeholder (the landing itself never errors)
			loadSpecimen().then((c) => (specimen = c));
			if (view.q) {
				query = view.q;
				lastTyped = view.q;
				// input() seeds the controller's own query, submit()
				// fires it immediately — the deep link auto-runs
				inst.input(view.q);
				inst.submit();
			} else if (view.chunk) {
				// a chunk-ONLY deep link (palette paste, the
				// specimen's "copy with link") opens the pane straight
				// away — previously the chunk waited for a search that
				// never came
				pendingChunk = null;
				openCitation(view.chunk);
			}
			window.addEventListener('popstate', onPop);
		}
		// '/' from anywhere focuses search — never while typing, never
		// with a modifier (⌘K is the palette's, ). ⌘K / Ctrl-K
		// toggles the palette (api mode only): opens with focus on its
		// combobox, closes with focus handed back where it came from.
		const onKey = (ev) => {
			if ((ev.metaKey || ev.ctrlKey) && !ev.altKey && ev.key.toLowerCase() === 'k') {
				if (!URL_STATE || offline) return;
				ev.preventDefault();
				if (paletteOpen) closePalette();
				else openPalette();
				return;
			}
			if (ev.key !== '/' || ev.metaKey || ev.ctrlKey || ev.altKey) return;
			const t = ev.target;
			if (
				t instanceof HTMLElement &&
				(t.isContentEditable || /^(INPUT|TEXTAREA|SELECT)$/.test(t.tagName))
			)
				return;
			ev.preventDefault();
			box?.focus();
		};
		window.addEventListener('keydown', onKey);
		// keep the stacked/split answer live — a viewport that
		// crosses 68rem mid-session flips the hint's word and arms or
		// disarms the stacked-only scrolls (the listener is removed
		// with the rest of the page's wiring)
		const onWide = () => (stacked = !wide.matches);
		wide?.addEventListener('change', onWide);
		return () => {
			window.removeEventListener('keydown', onKey);
			if (URL_STATE) window.removeEventListener('popstate', onPop);
			wide?.removeEventListener('change', onWide);
			clearTimeout(copyTimer);
			clearTimeout(idTimer);
			inst.stop();
		};
	});

	// every keystroke feeds the controller (debounced inside it)
	// every keystroke feeds the controller (debounced inside it).
	// a PURE chunk id (the whole box is the id — pasted,
	// the dominant path) resolves LIVE instead: no pointless 0-hit
	// search fires (searched stays false, so the row gate
	// keeps working), the citation opens on the same debounce
	// cadence, and the URL REPLACES — typing is a preview, never a
	// commit: Back is not spammed; : no recent is
	// recorded, an id is not a query).  Enter stays the committer
	// (openPastedChunk: pushes the view, clears the box).  MIXED text
	// carrying an id (a pasted citation line) keeps the submit
	// path — its words may still hit, and the zero-hit card teaches
	// Enter for that case.
	function type(q) {
		// 2026-10-18, completing the new-search-starts-at-'all' ruling:
		// the filter belongs to the result set it was set on — the
		// first keystroke that EDITS the query text starts a new
		// search, so the live (typeahead) requests drop the stale
		// filter here, not at the committed submit.  Re-applying a
		// chip after typing filters the NEW result set, as it should.
		if (q !== lastTyped && cluster) cluster = '';
		lastTyped = q;
		liveTyping = true;
		query = q;
		// file:// — never attempt anything
		if (offline) return;
		clearTimeout(idTimer);
		if (URL_STATE && isChunkId(q)) {
			inst.input('');
			idTimer = setTimeout(() => resolveIdLive(extractChunkId(q)), 150);
			return;
		}
		inst.input(q);
	}

	function submit(ev) {
		ev?.preventDefault();
		// file:// — never attempt a query
		if (offline) return;
		// paste-anywhere: a committed submit whose text
		// CARRIES a 40-hex chunk id (a bare id, a copied citation
		// line, a deep-link URL) resolves THAT chunk through the pane
		// instead of querying FTS — everything the app copies out
		// resolves when it comes back.  Api mode only: the static
		// face's submit stays a plain search (frozen at v1-static).
		const pasted = URL_STATE ? extractChunkId(query) : null;
		if (pasted) {
			openPastedChunk(pasted);
			return;
		}
		cite = null; // a committed new query invalidates the pane
		// 2026-10-18 owner ruling: a NEW search starts at 'all' — the
		// cluster filter is a view on ONE result set, never a sticky
		// preference carried into the next query
		cluster = '';
		liveTyping = false;
		inst.submit();
		// a submitted query is a committed view — a history entry
		//): Back returns to it from whatever comes next.
		// Committed queries also record a recent) — debounced
		// typing never does.
		if (query.trim()) {
			syncUrl('push');
			recordRecent(query);
		}
	}

	// Esc: back to a clean slate, query included — the slate REWRITES
	// the current entry (Back still reaches the previous view)
	function reset() {
		query = '';
		lastTyped = '';
		cluster = '';
		pendingChunk = null;
		cite = null;
		inst.input('');
		syncUrl('replace');
	}

	// a chip click data, state) or the palette's
	// cluster command): filter to one cluster or clear it —
	// refires the query WITH the filter and commits the view as its
	// own history entry.  Without a live query (palette on a fresh
	// page) the filter waits for the next query — the URL still
	// carries it, a shareable intent.
	function toggleCluster(c) {
		liveTyping = false;
		cluster = cluster === c ? '' : c;
		pendingChunk = null;
		cite = null;
		if (offline) return;
		if (query.trim()) inst.submit();
		syncUrl('push');
	}

	// --------------------------------------------- : ⌘K palette
	// A committed query from ANY path (form submit, palette run,
	// palette recent) records a recent — via the module's injected
	// storage, so a locked-down browser silently loses recents
	// without breaking anything.  Api mode only.
	function recordRecent(q) {
		if (!URL_STATE) return;
		recents = pushRecent(window.localStorage, q);
	}

	// the palette's run-query / recent action: seed the box, fire NOW
	// (the restore doctrine: input() seeds, submit() fires),
	// commit the view, record the recent
	function runQuery(q) {
		if (offline || !q.trim()) return;
		query = q;
		lastTyped = q;
		liveTyping = false;
		cite = null;
		cluster = ''; // a new search starts at 'all' (2026-10-18)
		pendingChunk = null;
		inst.input(q);
		inst.submit();
		syncUrl('push');
		recordRecent(q);
	}

	// the palette's paste-a-chunk-id action: the chunk loads straight
	// into the pane — the workbench opens around it even before any
	// search has run (splitOn includes cite), and the view commits as
	// its own ?chunk= deep link
	async function openChunkId(id) {
		if (offline) return;
		pendingChunk = null;
		await openCitation(id);
		syncUrl('push');
	}

	// the search box's paste path — the extracted id
	// resolves through the SAME openCitation the palette's paste
	// uses, then the view commits chunk-only (?chunk=, q empty).  The
	// paste was a pointer, not a query: the box clears, and
	// input('') retires the paste's own pending debounced FTS shot
	// BEFORE it can fire — the criterion is "no FTS query fires", not
	// merely "none lands".  An unknown id 404s inside openCitation's
	// getChunk (null, not a throw) and the pane answers with its
	// honest "no chunk with id" line — never an error card.
	async function openPastedChunk(id) {
		pendingChunk = null;
		cluster = '';
		query = '';
		lastTyped = '';
		cite = null;
		inst.input('');
		await openCitation(id);
		syncUrl('push');
	}

	// the LIVE resolution — preview semantics, the twin of
	// openPastedChunk above.  The box KEEPS the typed id (it is the
	// user's text, not ours to erase mid-typing), the URL replaces
	// (never pushes), no recent records.  The fire-time isChunkId
	// recheck drops a stale timer whose typing has moved on; Enter
	// converts the preview into the committed view.
	async function resolveIdLive(id) {
		if (!id || !isChunkId(query.trim())) return;
		cite = null;
		await openCitation(id);
		// chunk-ONLY view, replaced in place: the box holding the id
		// is UI state, not view state — a riding ?q=<id> would
		// re-SEARCH the id on restore: the URL restores a
		// view, it never re-asks the question)
		history.replaceState(
			{},
			'',
			viewHref({ q: '', cluster: '', chunk: id }, window.location.pathname)
		);
	}

	// dispatch a palette command — the dialog closes first (focus
	// returns to the opener), then the action runs
	function execCommand(c) {
		if (!c) return;
		closePalette();
		if (c.kind === 'search' || c.kind === 'recent') runQuery(c.q);
		else if (c.kind === 'cluster') toggleCluster(c.cluster);
		else if (c.kind === 'chunk') openChunkId(c.id);
	}

	function openPalette() {
		pReturn = document.activeElement;
		paletteOpen = true;
		pQuery = '';
		pSel = -1;
	}

	function closePalette() {
		paletteOpen = false;
		pQuery = '';
		pSel = -1;
		(pReturn ?? box)?.focus?.();
		pReturn = null;
	}

	// the corpus modal — lazy-fetch on first open; Esc and the
	// veil close it (the palette's discipline, dialog-shaped).
	// every OPEN re-checks freshness (passive, on-open —
	// never a cached verdict going stale itself)
	async function openCorpus() {
		if (!corpusInfo && !corpusError) {
			try {
				corpusInfo = await fetchCorpus();
				if (!corpusInfo) corpusError = 'unavailable';
			} catch {
				corpusError = 'unreachable';
			}
		}
		corpusOpen = true;
		tick().then(() => corpusDialog?.focus());
		refreshVerdicts();
		pickupJob();
	}
	async function refreshVerdicts() {
		verdictState = 'fetching';
		// the PREVIOUS verdict stays while the new one is in flight:
		// the chip shows the latest COMPLETED verdict, never a color
		// blink mid-check; the band shows its own checking line
		try {
			const v = await fetchVerdicts();
			if (v && v.kind === 'verdicts') {
				verdicts = v.body;
				verdictState = 'ok';
			} else if (v && v.kind === 'absent') {
				verdicts = null;
				verdictNote = v.detail;
				verdictState = 'absent';
			} else {
				verdicts = null;
				verdictState = 'unknown';
			}
		} catch {
			verdicts = null;
			verdictState = 'unknown';
		}
	}
	function closeCorpus() {
		corpusOpen = false;
		confirmOpen = false;
		progressOpen = false;
	}
	// ---- the push stream: one Server-Sent Events connection
	// replaces the 2 s poll.  Opened at page load (an idle slot then
	// ANNOUNCES a job started anywhere) and re-opened by a confirm or
	// a modal-open after a terminal closed it — the stream closes at
	// every terminal (the ruled anti-zombie discipline: a settled slot
	// answers the terminal once more, idempotent, and this page never
	// re-watches a finished job).  Everything below is idempotent
	// under the stream's own snapshots, so a confirm's answer and the
	// stream's running snapshot can land in either order.
	function ensureStream() {
		if (stream) return;
		stream = openReindexEvents({
			onSnapshot: onStreamSnapshot,
			onDelta: onStreamDelta,
			onTerminal: onStreamTerminal
		});
	}
	// a snapshot while a job runs: adopt it (the reopen-mid-job,
	// refresh and second-tab case — the slot is the service's, not
	// this page's).  The idle snapshot is the connect heartbeat and
	// changes nothing.  The corpus dialog being open means the user
	// is looking: raise the progress modal beside the band
	function onStreamSnapshot(job) {
		if (job.status !== 'running') return;
		reindexPhase = 'running';
		reindexJob = job;
		frameLines = job.frame ?? [];
		startClock(job.started_at);
		if (corpusOpen) progressOpen = true;
	}
	// one delta: the frame's CHANGED lines, applied per index (the
	// template's keyed each keeps every other line's DOM node —
	// render on event, never a full-frame rebuild)
	function onStreamDelta(d) {
		const out = frameLines.slice();
		for (const c of d.lines ?? []) {
			while (out.length < c.i) out.push('');
			out[c.i] = c.text;
		}
		out.length = d.length;
		frameLines = out;
	}
	// the terminal: the summary plus, when this connection earned it,
	// the post-job freshness verdict (the old after-done /status ride,
	// now the closing event).  A terminal at a phase other than
	// running is a SETTLED slot this page connected to — nothing to
	// end, just close the stream and keep the page as it was
	function onStreamTerminal(job) {
		if (reindexPhase !== 'running') {
			stream?.close();
			stream = null;
			return;
		}
		stopClock();
		reindexPhase = job.status === 'failed' ? 'failed' : 'done';
		reindexJob = job;
		frameLines = job.frame ?? [];
		// the stream is finished for good: close it here, or the
		// browser's auto-reconnect fetches the idempotent replay
		stream?.close();
		stream = null;
		if (reindexPhase === 'done') {
			// the modal refreshes ITSELF: new date, new pinned
			// commits, new counts, band resolves to current — the
			// verdict arrives from the event when it was earned
			// (skip the re-hash), else the check runs as always
			void (async () => {
				try {
					corpusInfo = await fetchCorpus();
					corpusError = '';
				} catch { /* the band still refreshes below */ }
				if (job.verdict) {
					verdicts = job.verdict;
					verdictState = 'ok';
				} else {
					await refreshVerdicts();
				}
			})();
		}
	}
	// the elapsed clock: ticks 1 Hz on ONE text node (the modal's
	// title-line timer and the closed chip's suffix read the same
	// string); localhost service, one clock, no skew to bridge
	function startClock(iso) {
		if (!iso) return;
		jobStartedIso = iso;
		tickClock();
		if (clockTimer) clearInterval(clockTimer);
		clockTimer = setInterval(tickClock, 1000);
	}
	function tickClock() {
		if (!jobStartedIso) return;
		const s = Math.max(0, (Date.now() - Date.parse(jobStartedIso)) / 1000);
		elapsedText =
			s < 60
				? `${Math.floor(s)}s`
				: s < 3600
					? `${Math.floor(s / 60)}m${String(Math.floor(s) % 60).padStart(2, '0')}s`
					: `${Math.floor(s / 3600)}h${String(Math.floor((s % 3600) / 60)).padStart(2, '0')}m`;
	}
	function stopClock() {
		if (clockTimer) clearInterval(clockTimer);
		clockTimer = null;
		jobStartedIso = null;
	}
	function askReindex() {
		confirmMode = 'drift';
		confirmOpen = true;
	}
	function askForce() {
		confirmMode = 'force';
		confirmOpen = true;
	}
	function cancelReindex() {
		confirmOpen = false;
	}
	// the confirmation carries the evidence (drift counts +
	// carried legs named) and the measured duration when one exists;
	// the rebuild itself is the endpoint's job, polled until done
	function fmtDuration(s) {
		if (s == null) return '';
		const m = Math.round(s / 60);
		return m >= 1 ? `${m} min` : `${Math.round(s)} s`;
	}
	async function doReindex() {
		confirmOpen = false;
		reindexRefusal = '';
		reindexPhase = 'running';
		// the PREVIOUS job's closing frame never poses as the new
		// run's state: the summary the user just read must not freeze
		// on screen while the new job is being claimed
		reindexJob = null;
		frameLines = [];
		stopClock();
		progressOpen = true;
		// the drift path's POST re-hashes the corpus before it
		// answers (the gate): name that wait instead of a bare
		// "starting..." that reads as a stall (force answers at once,
		// so the line only ever flashes there)
		reindexStarting = true;
		const started = await startReindex(confirmMode === 'force');
		reindexStarting = false;
		if (!started.ok) {
			reindexPhase = 'closed';
			reindexRefusal = started.refusal;
			progressOpen = false;
			return;
		}
		reindexJob = started.job;
		// the clock's anchor comes from THIS answer (the started_at
		// race: a later observation may already be seconds in), and
		// the stream follows the job to its terminal — opened here
		// because the page-load stream may already have closed at an
		// earlier terminal
		startClock(started.job?.started_at);
		ensureStream();
	}
	function closeProgress() {
		// closing never stops the job: the stream keeps pushing and
		// the chip carries the state (the indexing text with its
		// ticking elapsed while it runs, then the refreshed verdict
		// when it lands).  Focus returns to the corpus dialog beneath
		// - a stranded focus would leave Esc dead until the next
		// click
		progressOpen = false;
		tick().then(() => corpusDialog?.focus());
	}
	// the progress modal's own dialog + frame elements: focus on
	// open, the frame pinned to its newest lines while the job runs
	let progressDialog = $state(null);
	let progressFrame = $state(null);
	$effect(() => {
		if (progressOpen) tick().then(() => progressDialog?.focus());
	});
	$effect(() => {
		void frameLines[frameLines.length - 1];
		if (progressOpen && progressFrame) {
			progressFrame.scrollTop = progressFrame.scrollHeight;
		}
	});
	onDestroy(() => {
		stopClock();
		stream?.close();
		if (dayTimer) clearInterval(dayTimer);
	});
	/** a repository row's external link — at the PINNED commit when
	 *  the scan pinned one (the same URLs per-hit source links build);
	 *  synthesized sources (b2mn.dat) are not repositories: no link */
	/** the row chip's label: current / carried / drifted +N —
	 *  null when the row has no leg (pointer-only rows like adas
	 *  contributed no sources, so no freshness exists to state) */
	function chipFor(name) {
		const v = verdictMap.get(name);
		if (!v) return null;
		if (v.verdict === 'drifted')
			return `drifted +${v.new + v.changed + v.removed}`;
		return v.verdict;
	}
	function repoLink(name, commit) {
		const parts = name.split('/');
		if (parts.length > 1) {
			const inner = parts.slice(1).join('/');
			const m = MODULE_REPOS[inner + '/'];
			// a submodule (own repo, own pinned commit) links there;
			// a PLAIN module directory (links INTO the parent
			// repo, at the parent's commit, at its path — the revision
			// that governs the code
			if (m) return commit ? `${m.url}/tree/${commit}` : m.url;
			const r = SOURCE_REPOS[parts[0]];
			if (r && commit) return `${r.url}/tree/${commit}/${inner}`;
			if (r) return r.url;
			return null;
		}
		const r = SOURCE_REPOS[parts[0]];
		if (r) return commit ? `${r.url}/tree/${commit}` : r.url;
		return null;
	}

	// the palette keyboard (ARIA combobox + listbox, APG): ↑/↓ move
	// the ring (the same wrap-around the search box uses), Home/End
	// jump, Enter executes, Esc closes — and Tab is EATEN: the
	// combobox is the dialog's only tab stop, so focus never escapes
	// beneath the veil (the trap).
	function onPaletteKey(ev) {
		if (ev.key === 'ArrowDown' || ev.key === 'ArrowUp') {
			ev.preventDefault();
			pSel = moveSel(pSel, ev.key === 'ArrowDown' ? 1 : -1, cmds.length);
		} else if (ev.key === 'Home' || ev.key === 'End') {
			if (cmds.length) {
				ev.preventDefault();
				pSel = ev.key === 'Home' ? 0 : cmds.length - 1;
			}
		} else if (ev.key === 'Enter') {
			ev.preventDefault();
			execCommand(cmds[pSel]);
		} else if (ev.key === 'Escape') {
			ev.preventDefault();
			closePalette();
		} else if (ev.key === 'Tab') {
			ev.preventDefault(); // the trap
		}
	}

	// focus lands on the combobox the moment the dialog renders
	$effect(() => {
		if (paletteOpen && pInput) pInput.focus();
	});

	// a new command list — or reopening the dialog on one that has not
	// changed since the last close — resets the ring to its first row:
	// the run intent is always one Enter away (without the paletteOpen
	// read, a reopen with an unchanged list kept the -1 closePalette
	// left behind, and Enter did nothing; caught live)
	$effect(() => {
		if (!paletteOpen) return;
		cmds;
		pSel = cmds.length ? 0 : -1;
	});

	// keep the ring's row in view as it moves
	$effect(() => {
		if (paletteOpen && pSel >= 0) {
			document.querySelector('#cmdk-list li[data-selected]')?.scrollIntoView({ block: 'nearest' });
		}
	});

	// the search-focused keyboard model: ↑/↓ select, Enter opens the
	// selection, Esc clears — all on the search box, where the hands
	// already are
	function onBoxKey(ev) {
		if (ev.key === 'ArrowDown' || ev.key === 'ArrowUp') {
			if (!results.length) return;
			ev.preventDefault();
			const dir = ev.key === 'ArrowDown' ? 1 : -1;
			sel = sel < 0 ? (dir > 0 ? 0 : results.length - 1) : (sel + dir + results.length) % results.length;
		} else if (ev.key === 'Enter') {
			if (sel >= 0 && sel < results.length) {
				ev.preventDefault();
				openRow(results[sel]);
			}
		} else if (ev.key === 'Escape') {
			ev.preventDefault();
			reset();
		}
	}

	// one entry point for both pointer paths: the keyboard arrives with
	// its selection already made, a click passes its own index — the
	// visible selection state is identical either way (keyboard +
	// mouse parity)
	function openRow(r, i) {
		if (typeof i === 'number') sel = i;
		if (CITATION_VIEW === 'page') {
			// static mode: the same plain navigation a click performs
			window.location.assign(chunkHref(r.chunkId));
		} else {
			openCitation(r.chunkId);
			// the open citation is a committed view — Back closes the
			// pane, Forward reopens it). The RESTORE path
			// (popstate/deep link) calls openCitation directly and
			// never pushes — the URL already is this view.
			syncUrl('push');
		}
	}

	// keep the keyboard selection in view as it moves
	$effect(() => {
		if (sel >= 0) {
			document.querySelector('li[data-selected]')?.scrollIntoView({ block: 'nearest' });
		}
	});

	// a chunk swap starts the pane at its top — comparing two hits
	// never lands mid-text
	$effect(() => {
		cite?.chunkId;
		pane?.scrollTo(0, 0);
	});

	// once a chunk's text has RENDERED, walk its text nodes
	// and plant a <mark> per query-term occurrence (the why-this-result
	// terms — cite.matched — so the navigator's total is the Σn that
	// panel already shows; terms absent from the chunk mark nothing).
	// The {#key cite.chunkId} around the text box rebuilds its subtree
	// per chunk, so each walk starts from Svelte-fresh plain text and
	// can never meet marks from the previous chunk (nor can Svelte try
	// to update a node the walk replaced).  Match 1 is the navigator's
	// starting anchor — marked active, not scrolled to: the pane just
	// reset to its top, and the reader should start at the chunk's
	// start, not be yanked to the first hit.
	$effect(() => {
		if (!textEl) {
			marks = [];
			return;
		}
		const terms = cite?.matched?.map((m) => m.term) ?? [];
		const found = markTextNodes(textEl, terms);
		marks = found;
		mIdx = 0;
		// the LOCAL list, never the marks state: reading what this
		// effect writes would make it depend on itself — it would
		// re-walk the already-marked text and nest marks without end
		// (caught live: 23,023 marks for a 23-match chunk)
		found[0]?.classList.add('active');
	});

	// the specimen's fixed terms — one walk, no state read
	// back: the section remounts whenever specimenOn returns, so
	// every walk starts from Svelte-fresh plain text and nothing can
	// nest.  No active mark, no navigator — the wash IS the demo.
	$effect(() => {
		if (specText) markTextNodes(specText, SPECIMEN_TERMS);
	});

	// the navigator: ‹ › step through the marks; each step centers its
	// match.  Split mode centers it inside EVERY scrollable box
	// between it and the pane — the pane itself — and never anything
	// beyond the pane, so the page never jumps under the sticky pane.
	// Stacked): the text cap is gone, so nothing between the
	// mark and the pane scrolls any more — the page is the only
	// scroller left, and the step centers the match in the viewport.
	function stepMatch(dir) {
		const i = Math.min(marks.length - 1, Math.max(0, mIdx + dir));
		if (i === mIdx) return;
		marks[mIdx]?.classList.remove('active');
		mIdx = i;
		const m = marks[i];
		m.classList.add('active');
		if (!wide?.matches) {
			const mr = m.getBoundingClientRect();
			const want =
				window.scrollY + mr.top - (window.innerHeight - mr.height) / 2;
			window.scrollTo(0, Math.max(0, want));
			return;
		}
		for (let el = m.parentElement; el && el !== pane?.parentElement; el = el.parentElement) {
			if (el.scrollHeight <= el.clientHeight) continue; // nothing to scroll
			const mr = m.getBoundingClientRect();
			const er = el.getBoundingClientRect();
			const want =
				el.scrollTop + mr.top - er.top - (el.clientHeight - mr.height) / 2;
			el.scrollTop = Math.max(0, Math.min(want, el.scrollHeight - el.clientHeight));
		}
	}

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
		xruns = null; // : the cross-reference belongs to THIS citation
		try {
			cite.chunk = await getChunk(chunkId);
			// a superseded open can never plant its answer under a
			// newer citation — the same staleness guard the
			// cross-reference fetch below carries.  Without it, a slow
			// fetch for hit A resolves after hit B was opened and
			// writes A's text into B's pane (B's header, A's body).
			if (cite?.chunkId !== chunkId) return;
			// a source_switch citation cross-references the
			// run catalog — its section IS the switch name (the ruled
			// join key, verbatim).  Fired beside the chunk fetch, never
			// awaited: the citation renders first, the muted panel lands
			// when it lands (below the citation body, by ruling).
			if (cite.chunk?.cluster === 'source_switch' && cite.chunk.section) {
				loadSwitchRuns(cite.chunk.section, chunkId);
			}
		} catch (e) {
			// a superseded open's failure is not the newer pane's error
			if (cite?.chunkId === chunkId) {
				error = `citation failed: ${e?.message ?? e}`;
			}
		} finally {
			// loading state and the scroll belong to the CURRENT
			// citation only — a superseded open must not clear the
			// newer pane's spinner mid-load nor scroll for a pane
			// that no longer exists
			if (cite?.chunkId === chunkId) {
				cite.loading = false;
				// a stacked phone just gained a pane BELOW the list
				//  bring it into view so the tap visibly did something.
				// Split never scrolls (the sticky pane is already on
				// screen).  The scroll waits for the chunk — the pane has
				// its full height by then, so the page can actually reach
				// its top (scrolling a still-loading pane clamps short and
				// the growth strands it below the fold) — plus a tick for
				// the render.  wide.matches is read plainly: this fires per
				// open, never per resize.
				if (!wide?.matches) {
					await tick();
					pane?.scrollIntoView({ block: 'start' });
				}
			}
		}
	}

	// the catalog cross-reference fetch, guarded by the
	// pane's chunk — a superseded open can never plant its answer under
	// a newer citation.  Any failure drops the panel quietly (a bonus
	// cross-reference is never a complaint the pane cannot fix).
	async function loadSwitchRuns(section, chunkId) {
		try {
			const d = await getSwitchRuns(section);
			if (cite?.chunkId === chunkId && d) xruns = d;
		} catch {
			/* quiet */
		}
	}

	// run names are FAMILY/variant — the panel splits them
	// for scanning (variant is the run, family the context it groups
	// under in the run-name sort)
	function runVariant(run) {
		return run.split('/')[1] ?? run;
	}

	// copy the citation — the plain provenance line, or the same
	// line plus the view's deep link (what you paste restores what you
	// see, the round-trip). The status is honest: 'copied' only
	// after the clipboard confirms, a blocked clipboard says so and
	// points at the full chunk id on the verify line.  The status
	// self-clears so a stale "copied" can never lie about a later chunk.
	// the mechanism is ONE path (writeClipboard) with three
	// entry points — the two citation forms and the pane's id chip —
	// so every copy action confirms, fails and self-clears identically.
	let copied = $state(''); // 'plain' | 'linked' | 'id' | 'fail' — '' = idle
	let copyTimer = null;
	// the live id-resolution debounce (cleared per
	// keystroke, and with the rest of the page's wiring on unmount)
	let idTimer = null;

	// the color-scheme toggle — tri-state (auto → dark →
	// light), persisted beside the recents.  'auto' follows the OS
	// (the standing v1 doctrine and still the default); the forced
	// states set data-theme on <html>, which tokens.css honors over
	// the prefers-color-scheme media query.  Api mode only — the
	// static face keeps follow-the-OS (frozen).
	let theme = $state('auto');
	const THEME_KEY = 'askthedocs.theme';

	function applyTheme() {
		if (theme === 'auto') document.documentElement.removeAttribute('data-theme');
		else document.documentElement.setAttribute('data-theme', theme);
	}

	function cycleTheme() {
		// auto → dark → light: each forced state one click from the
		// default, the opposite two
		const next = theme === 'auto' ? 'dark' : theme === 'dark' ? 'light' : 'auto';
		theme = next;
		applyTheme();
		try {
			window.localStorage.setItem(THEME_KEY, next);
		} catch {
			/* a locked-down browser just loses the preference */
		}
	}

	async function writeClipboard(text, kind) {
		try {
			await navigator.clipboard.writeText(text);
			copied = kind;
		} catch {
			copied = 'fail';
		}
		clearTimeout(copyTimer);
		copyTimer = setTimeout(() => {
			copied = '';
		}, 2400);
	}

	// `chunk` defaults to the pane's citation — the specimen
	// passes its own; the copied forms stay REAL (the with-link form
	// deep-links the exhibit chunk itself, ?chunk=-only)
	async function copyCite(kind, chunk = cite?.chunk) {
		if (!chunk) return;
		const forms = citationForms({
			chunk,
			view: { q: query, cluster, chunk: chunk.chunkId },
			origin: window.location.origin,
			pathname: window.location.pathname
		});
		await writeClipboard(kind === 'linked' ? forms.linked : forms.plain, kind);
	}

	// the truncated id chip's fast path — copies the FULL id
	// (the display truncates to 8…6; the clipboard never does);
	// takes the chunk it labels (pane default, specimen pass)
	async function copyId(chunk = cite?.chunk) {
		if (!chunk) return;
		await writeClipboard(chunk.chunkId, 'id');
	}

	// 8 leading chars, an ellipsis, 6 trailing — the verify
	// line (and the chip's title/aria-label) carry the full id
	function shortId(id) {
		return id.length > 16 ? `${id.slice(0, 8)}…${id.slice(-6)}` : id;
	}

	// where does row i sit in its consecutive same-source
	// run?  { first, n } — the row snippet folds repetition for runs
	// >= 3: the first row names the source (with ×n), the rest omit
	// it. Scanned, not stored: a show-more append) grows the
	// list and the folds recompute — a run that gains rows updates
	// its count in place, and rows still keyed by chunk id never
	// reorder (ranking untouched).
	function srcRun(i) {
		// ?. — the synthetic id-row renders row(r, 0) while
		// `results` is empty (no search ran); every other caller has
		// results[i] defined, so behavior there is byte-identical
		const s = results[i]?.source ?? '';
		let start = i;
		while (start > 0 && results[start - 1].source === s) start -= 1;
		let end = i;
		while (end + 1 < results.length && results[end + 1].source === s) end += 1;
		return { first: start === i, n: end - start + 1 };
	}

	// /b: the source link's honest label — it NAMES the repo
	// and the ref it points at. pins the ref to the exact
	// commit the corpus scan recorded (short form in the label, the
	// full sha rides the href); a manifest that could not pin falls
	// back to the default branch and SAYS so — never a pinning pretense
	// 2026-10-18: a source with a rendered page displays without its
	// .md extension — the label names what the link opens (a page);
	// the 'pinned source' anchor keeps the file name it opens
	function dispSource(s) {
		return pageUrl(s) ? String(s).replace(/\.md$/i, '') : s;
	}

	function srcTip(u) {
		return u.pinned
			? `${u.repo} at ${u.ref.slice(0, 8)}: pinned commit, opens on GitHub`
			: `${u.repo} at ${u.ref}: opens on GitHub`;
	}

	// the stretched link's hover text carries the row's most
	// useful explanation — the run fold for a run's head, the
	// contents-row badge for a TOC hit (the card-covering anchor
	// receives the hover those chips used to own)
	function rowTip(r, i) {
		if (URL_STATE && CITATION_VIEW === 'inline') {
			const ru = srcRun(i);
			if (ru.n >= 3 && ru.first)
				return `${ru.n} consecutive hits from this source: the ${ru.n - 1} rows below omit the repeated path`;
			if (r.toc) return 'table-of-contents row: dot leaders collapsed in display';
		}
		return undefined;
	}
</script>

<!-- class:wide — the page widens into the workbench the
     moment the split opens (first search); static mode never widens. -->
<!-- data-api — the cluster palette's badge restyle rides
     this attribute; the static face (no URL_STATE) carries no
     data-api, so its badges keep the frozen amber. -->
<main class:wide={splitOn} data-api={URL_STATE ? '' : undefined}>
	<header class="masthead reveal reveal-1">
		<p class="overline">SOLPS-ITER knowledge layer</p>
		<div class="wordmark">
			<h1>askthedocs</h1>
			<span class="tick" aria-hidden="true"></span>
		</div>
		<!-- the color-scheme keycap (api mode only) — one mono
		     chip cycling auto → dark → light; 'auto' follows this
		     device, the forced states override the media query. -->
		{#if URL_STATE}
			<button
				type="button"
				class="theme-toggle"
				onclick={cycleTheme}
				aria-label={`Color scheme: ${theme}${theme === 'auto' ? ' (follows this device)' : ''}; click to cycle auto, dark, light`}
				title="Color scheme: cycles auto, dark, light"
			>
				{theme}
			</button>
		{/if}
		<p class="tagline">Answers in seconds: every claim carries its citation.</p>
		<!-- the corpus provenance line — when this index was
		     built, over how many repositories.  The DATE LINE is the
		     clickable element (the tagline stays copy); it opens the
		     repository modal.  Rendered only when the service answered
		     (api mode) — absence is honest, never a fake date. -->
		{#if corpusInfo}
			<!-- the chip IS the verdict face: neutral until a check
			     answers, green when current, red + the finding when
			     drifted or a rebuild failed, yellow + the finding when
			     the corpus cannot be found; while a rebuild runs the
			     indexing state takes every verdict's place (the
			     running job is the newer truth) — a STATIC edge and
			     the ticking elapsed are the whole motion vocabulary
			     (no infinite animation anywhere) -->
			<button
				class="corpus-line"
				class:v-current={chipState === 'current'}
				class:v-drifted={chipState === 'drifted'}
				class:v-notfound={chipState === 'notfound'}
				class:v-failed={chipState === 'failed'}
				class:v-indexing={chipState === 'indexing'}
				onclick={openCorpus}
				aria-haspopup="dialog"
			>
				{#if chipState === 'indexing'}
					Currently indexing corpus{elapsedText ? ` · ${elapsedText}` : ''}
				{:else}
					Corpus indexed {corpusDate} · {corpusInfo.repos.length} repositories{chipSuffix}
				{/if}
			</button>
		{/if}
	</header>

	{#if offline}
		<div class="notice card-in">
			<h2>Offline copy: search is unavailable</h2>
			<p>
				This is a <code>file://</code> copy of the site. Search fetches
				index fragments over HTTP, so it needs the site to be served;
				the pages themselves are plain files and remain readable.
			</p>
			<p>
				Search the same corpus from the terminal:
				<code>askthedocs search QUERY</code> and
				<code>askthedocs show CHUNK_ID</code>, or over MCP with the
				<code>search_docs</code> / <code>get_chunk</code> tools.
			</p>
		</div>
	{:else}
		<!-- workbench: the master column (instrument +
		     results) and the detail column (citation pane) side by
		     side; stacked below 68rem, a plain block in static mode —
		     where no pane ever renders. the instrument
		     itself lives INSIDE the master column — the landing opens
		     as the workbench at rest and the search box never spans
		     past the list it governs (in the split the pane owns the
		     remaining width; stacked and static the flow order is
		     exactly what it always was). -->
		<div class="bench" class:split={splitOn}>
			<div class="master">
				<!-- class:listing) — true while a keyboard selection is
				     live; the stylesheet suppresses the box's focus ring so the
				     selected row is the one focused signal on screen -->
				<form
					onsubmit={submit}
					role="search"
					class="reveal reveal-3"
					class:listing={sel >= 0}
				>
					<input
						type="search"
						name="q"
						placeholder="Search the corpus…"
						aria-label="Search the SOLPS-ITER corpus"
						autocomplete="off"
						bind:this={box}
						bind:value={query}
						oninput={(e) => type(e.target.value)}
						onkeydown={onBoxKey}
					/>
					<!-- the label NEVER swaps (the old busy-word swap
					     walked the form's width every keystroke burst); the
					     busy state is a centered spinner over the dimmed label,
					     both absolutely sized — the button's box is identical
					     idle and running. -->
					<button
						type="submit"
						disabled={running}
						aria-busy={running ? 'true' : undefined}
					>
						<span class="blabel">Search</span>
						{#if running}<span class="spin" aria-hidden="true"></span>{/if}
					</button>
				</form>
				<!-- keyboard teaching lives HERE, once — the .spec line,
				     where the keys it names sit directly above.  The keybind
				     segment (.keys) carries its own separators so a coarse
				     pointer drops it whole; the functional claims (bm25,
				     citations) are unconditional. -->
				<p class="spec reveal reveal-4">
					{#if !URL_STATE}bm25 over FTS5 · {/if}every hit cites source, section, page<span class="keys"> · <kbd>/</kbd> to search · <kbd>↑↓</kbd> select · <kbd>↵</kbd> open{#if URL_STATE} · <kbd>⌘K</kbd> commands{/if}</span>
				</p>

				{#if URL_STATE && !offline && !query.trim() && !searched && !running && !cite && recents.length}
					<!-- the recents band — the landing state's way back
					     in.  The gate is the landing state itself (api mode, not
					     offline, box empty, no search ever run or cleared back to
					     zero, no pane open) AND recents existing; a first-time
					     visitor sees none of this markup.  Each button is the
					     existing runQuery path — the same one the palette's recent
					     command uses — so a click records the recent (moves it to
					     the front) and commits the view as its own history entry. -->
					<section class="recents reveal reveal-5" aria-label="Recent queries">
						<h2 class="recents-label">recent queries</h2>
						<div class="recents-row">
							{#each recents as q (q)}
								<button type="button" class="recent" onclick={() => runQuery(q)}>
									{q}
								</button>
							{/each}
						</div>
					</section>
				{/if}

				{#if transient}
					<!-- a 4xx while typing (dangling FTS5 syntax, e.g. a lone
					     OR) — the query reruns on the next keystroke, so this
					     reads as a pause, not a failure -->
					<p class="pause" role="status">{error}; keep typing, the query reruns itself</p>
				{:else if error}
					<!-- a real failure (service unreachable, invalid
					     query even quoted, citation fetch died) — a card with
					     the raw message AND a way forward, never a bare red
					     line the user must diagnose alone -->
					<div class="errorcard card-in" role="alert">
						<p class="error-head">Search failed</p>
						<p class="error-msg">{error}</p>
						<p class="error-hint">
							The service may be unreachable or the query invalid. Edit the
							query to retry — the same corpus answers from the terminal
							(<code>askthedocs search QUERY</code>) and over MCP
							(<code>search_docs</code>).
						</p>
					</div>
				{/if}
				{#if running && results.length === 0}
					<!-- skeleton rows geometry, honesty): LIMIT
					     rows — the count the first page actually renders —
					     each mirroring the MODAL real card (rowhead with
					     badge + source, one meta line for section/page, two
					     excerpt lines) with bars boxed to the real metrics
					     (the .sk rules carry the derivation), so the
					     skeleton -> hits swap shifts nothing.  Decorative,
					     hidden from assistive tech. -->
					<ol class="results skels" aria-hidden="true">
						{#each { length: LIMIT } as _}
							<li class="hit skel">
								<span class="rowhead">
									<span class="sk sk-badge"></span>
									<span class="sk sk-src"></span>
								</span>
								<span class="sk sk-meta"></span>
								<span class="sk sk-line w95"></span>
								<span class="sk sk-line w80"></span>
							</li>
						{/each}
					</ol>
				{:else}
					{#if searched && !running}
						<p class="meta" aria-live="polite">
							<span class="count">{total}</span>
							{#if cluster}<span class="of">of {allCount}</span>{/if}
							{total === 1 ? 'hit' : 'hits'}
							{#if cluster}<span class="in">in {cluster}</span>{/if}
							{#if total > results.length}(showing {results.length}){/if}
							<!-- while typing, the completion tier rides
							     below the exact tier — the count line says so,
							     so the number never lies about the list -->
							{#if completionsTotal}
								<span class="sugg">+ {completionsTotal} suggestions</span>
							{/if}
						</p>
						{#if total > 0}
							<!-- the hint says where the citation opens.
							     : the keybind coaching moved out — teaching
							     lives once, in the .spec line.
							     (owner, 2026-09-26): the api face DROPS the
							     hint — the pane's own placeholder ("Select a hit
							     and the full chunk appears here…") is the single
							     teacher, teaching by being the destination; the
							     stacked phone keeps its affordance in 
							     auto-scroll-into-view.  Two surfaces teaching one
							     action was the once-rule violated one layer
							     down.  The static face keeps its frozen line, now
							     literal — its ternary arm always read 'beside'
							     there anyway. -->
							{#if !URL_STATE}
								<p class="hint">
									Click a hit: its citation opens beside the list.
								</p>
							{/if}
						{/if}
						<!-- data, state: cluster chips with
						     live counts — the drill-in.  Counts are the
						     FULL per-cluster breakdown (server computes
						     them without the filter), so the other chips
						     keep their counts while one is active; the
						     active chip is a toggle — click it again to
						     widen back.  API mode only: static mode has
						     no chips and no URL state (frozen face).
						     (owner ruling 2026-09-26): the row is
						     a COMPLETE view selector — the leading "all"
						     pill is the unfiltered state's visible home
						     (pressed when no filter is on; its count is
						     SUM(facets), the unfiltered total, so a
						     filtered view quantifies its own hidden
						     remainder and the way out is one click). -->
						{#if URL_STATE && facets.length > 1}
							<div class="chips" role="group" aria-label="Filter by cluster">
								<button
									type="button"
									class="chip"
									aria-pressed={cluster ? 'false' : 'true'}
									onclick={() => cluster && toggleCluster('')}
								>
									<span class="c">all</span><span class="n">{allCount}</span>
								</button>
								{#each facets as f (f.cluster)}
									<button
										type="button"
										class="chip"
										data-cluster={f.cluster}
										aria-pressed={cluster === f.cluster ? 'true' : 'false'}
										onclick={() => toggleCluster(f.cluster)}
									>
										<span class="c">{f.cluster}</span><span class="n">{f.count}</span>
									</button>
								{/each}
							</div>
						{/if}
					{/if}

					<!-- a chunk opened straight by id (palette paste, box
					     paste, ?chunk= deep link — /) — :
					     it renders as a REAL result row, the same shape
					     search rows take (built in data.js syntheticRow:
					     escaped excerpt from the chunk's own text, no
					     matched terms, no score — an id resolution has no
					     ranking story, so the why-panel does not render),
					     with the honest one-liner under it.  Plain click is
					     a no-op (the pane is already open on this row);
					     modifier clicks keep the native deep-link. -->
					{#if URL_STATE && cite && !searched && !running}
						{#if cite.chunk}
							<p class="meta"><span class="count">1</span> chunk: opened by id</p>
							<ol class="results">
								<li class="card-in" data-open="">
									<div class="hit">
										<a
											class="hit-open"
											href={viewHref({ q: '', cluster: '', chunk: cite.chunk.chunkId }, '')}
											aria-current="true"
											aria-label={`Open ${cite.chunk.source || cite.chunk.chunkId}`}
											title={`chunk ${cite.chunk.chunkId}`}
											onclick={(e) => {
												if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;
												e.preventDefault();
											}}
										></a>
										{@render row(syntheticRow(cite.chunk), 0)}
									</div>
								</li>
							</ol>
						{/if}
						<p class="hint">Opened by chunk id: run a query to see it ranked among its neighbours.</p>
					{/if}

					{#if searched && !running && total === 0 && !error}
						<div class="empty card-in">
							<!-- id-shaped text mid-typing — the generic
							     vocabulary advice is nonsense for a 40-hex id;
							     say what the box will actually do with it -->
							{#if URL_STATE && extractChunkId(query)}
								<p class="empty-head">That is a chunk id: search reads it as one long word.</p>
								<ul>
									<li>press Enter to open its citation: the id resolves exactly, no ranking involved</li>
									<li>to search inside chunks, use words from the text: the id itself never appears in it</li>
								</ul>
							{:else}
								<p class="empty-head">No hits for “{query.trim()}”.</p>
								<!-- + : the zero-hit recovery card —
								     only corpus words that CO-OCCUR with the
								     rest of the query, each with its true
								     click-yield count; of those hits, the
								     side-by-side count rides along and those
								     words are offered first (the corpus's own
								     phrase structure leads — expert reference
								     vocabulary, never log-popularity).  Every
								     word is verbatim from the index; choosing
								     one rewrites the token and commits.  No
								     fuzzy guessing, ever. -->
								{#if didYouMean}
									<p class="dym">
										did you mean
										<button class="dym-word" onclick={() => pickCompletion(didYouMean)}>{didYouMean}</button>?
									</p>
								{/if}
								{#if completionWords.length}
									<p class="comp-words-label">words starting with “{query.trim().split(/\s+/).at(-1)}”:</p>
									<ul class="comp-words">
										{#each completionWords as w, i (w.word)}
											{#if i === 0 || (w.adjacent > 0) !== (completionWords[i - 1].adjacent > 0)}
												<li class="comp-sub" aria-hidden="true">
													<span>{w.adjacent > 0 ? 'side-by-side with your other words:' : 'in the same chunk:'}</span>
												</li>
											{/if}
											<li>
												<button onclick={() => pickCompletion(w.word)}>
													{w.word} <span class="n">{w.adjacent > 0 ? `${w.count} hits, ${w.adjacent} side-by-side` : `${w.count} hits`}</span>
												</button>
											</li>
										{/each}
									</ul>
								{:else if separateTerms.length}
									<!-- (c): nothing combines — the honest
									     way out is each typed term on its own.
									     Every offered term has results by
									     construction; the card keeps the
									     zero-hit treatment (this is a miss
									     being diagnosed, not a success). -->
									<p class="dym">
										But we have results for
										{#each separateTerms as t, i (t.term)}
											{i > 0 ? (i === separateTerms.length - 1 ? ', and for ' : ', for ') : ''}
											<button class="dym-word" onclick={() => pickEscape(t.term)}>{t.term} ({t.count})</button>
										{/each}.
									</p>
								{/if}
								<ul>
									<li>every term must appear in a chunk: try fewer, more general terms</li>
									<li>terms match whole words, either number (condition finds conditions too); no wildcards or fuzzy stemming</li>
									<li>pick vocabulary from the domain you want: manual prose (<code>detachment</code>), code identifiers (<code>eirene</code>, <code>b2mn</code>), GUI wording (<code>menu</code>, <code>dialog</code>)</li>
								</ul>
							{/if}
						</div>
					{/if}

					<ol class="results">
						{#each results as r, i (r.chunkId)}
							<!-- the completion tier opens with one labeled
							     divider — everything above it is the committed
							     list verbatim; everything below is suggestion,
							     dimmed and badged, dropped on commit -->
							{#if r.completion && (i === 0 || !results[i - 1].completion)}
								<li class="comp-divider" aria-hidden="true">
									<span>suggestions: words starting with “{query.trim().split(/\s+/).at(-1) ?? ''}”</span>
								</li>
							{/if}
							<li
								class:card-in={!liveTyping}
								class:completion={r.completion}
								data-selected={i === sel ? '' : undefined}
								data-open={cite?.chunkId === r.chunkId ? '' : undefined}
							>
								{#if CITATION_VIEW === 'page'}
									<!-- data-sveltekit-reload: leave the app for a plain
									     static citation page — no client-side route. -->
									<a class="hit" href={chunkHref(r.chunkId)} data-sveltekit-reload>
										{@render row(r, i)}
									</a>
								{:else}
									<!-- api mode: no static citation pages exist — the
									     chunk renders in the detail pane from the
									     service. : the card's primary action
									     is a STRETCHED LINK (a real anchor covering
									     the card) — the row keeps click + Enter AND
									     gains middle/cmd-click (the href is the
									     deep link; a new tab restores this
									     exact view), while the source path renders
									     as its OWN anchor inside — an anchor inside
									     a button is invalid HTML, and this form is.
									     aria-current ties the pane to its row; the
									     click passes its own index so the visible
									     selection matches the keyboard's. -->
									<div class="hit">
										<a
											class="hit-open"
											href={viewHref({ q: query, cluster, chunk: r.chunkId }, '')}
											aria-current={cite?.chunkId === r.chunkId ? 'true' : undefined}
											aria-label={`Open ${r.source || r.chunkId}`}
											title={rowTip(r, i)}
											onclick={(e) => {
												// modifier clicks keep the browser's
												// native anchor behavior (new tab etc.)
												if (e.metaKey || e.ctrlKey || e.shiftKey || e.altKey) return;
												e.preventDefault();
												openRow(r, i);
											}}
										></a>
										{@render row(r, i)}
									</div>
								{/if}
							</li>
						{/each}
					</ol>

					<!-- hits past the first page stay reachable —
					     the control renders iff hits remain beyond the rows
					     shown, and each click asks the SAME search endpoint
					     for a bigger `limit` (no new endpoint, no offset).
					     Api mode only: the static face is frozen.  The label
					     counts the honest remainder; the counter above reads
					     the live row count; the control vanishes at
					     exhaustion. Paging never writes the URL: the
					     q, cluster and chunk parameters mean the same thing
					     at any depth). -->
					{#if CITATION_VIEW === 'inline' && searched && !running && !error && results.length < total}
						<div class="morebar">
							<button
								type="button"
								class="morebtn"
								disabled={fetchingMore}
								aria-busy={fetchingMore ? 'true' : undefined}
								onclick={() => inst.more()}
							>
								{fetchingMore ? 'Loading…' : `Show ${Math.min(LIMIT, total - results.length)} more`}
							</button>
						</div>
					{/if}
				{/if}
			</div>

			{#if splitOn}
				{#if cite}
					<!-- the detail pane: the v1 citation identity (full text,
					     source/section/page, cluster badge) restyled as a
					     side panel — sticky with its own scroll, so reading a
					     long chunk never scrolls the list out of view.  The
					     why-this-result panel rides along unchanged. -->
					<section class="citation card-in" id="citation" bind:this={pane}>
						<h2>
							Citation{#if searched && results.length}
								{@const ro = results.findIndex((r) => r.chunkId === cite.chunkId)}
								{#if ro >= 0}<span class="rank-echo"> · result {ro + 1} of {total}</span>{/if}
							{/if}
						</h2>
						{#if cite.loading}
							<p class="hint">Loading chunk {cite.chunkId}…</p>
						{:else if cite.chunk}
							<p class="rowhead">
								{#if cite.chunk.cluster}
									<span class="badge" data-cluster={cite.chunk.cluster}>{cite.chunk.cluster}</span>
								{/if}
								{#if cite.chunk.sourceUrl}
									{@const page = pageUrl(cite.chunk.source)}
									{#if page}
										<!-- 2026-10-18 dual-link: the read path lands on the
										     rendered tutorial page (live, always latest); the
										     proof path keeps the pinned blob — the same
										     two-destinations pattern as the switch's
										     b2input.xml second label below -->
										<a class="source" href={page} target="_blank" rel="noreferrer noopener" title="The rendered tutorial page: solps-tutorials.readthedocs.io, always the latest version">{@render srcpath(dispSource(cite.chunk.source) || cite.chunk.chunkId, true)}</a>
										<a class="source" href={cite.chunk.sourceUrl.url} target="_blank" rel="noreferrer noopener" title={srcTip(cite.chunk.sourceUrl)}>pinned source</a>
									{:else}
										<!-- the pane's link is the precision form —
									     a Fortran chunk's own text header carries its line
									     range into the URL's #L anchor -->
										<a class="source" href={cite.chunk.sourceUrl.url} target="_blank" rel="noreferrer noopener" title={srcTip(cite.chunk.sourceUrl)}>{@render srcpath(cite.chunk.source || cite.chunk.chunkId, true)}</a>
									{/if}
								{:else}
									<span class="source">{@render srcpath(cite.chunk.source || cite.chunk.chunkId, true)}</span>
								{/if}
								{#if cite.chunk.cluster === 'source_switch'}
									<!-- (owner ruling 2026-09-29): the DUAL label —
									     the synthetic b2mn.dat stays plain text linking
									     to nothing (the srclink rule, unchanged), while
									     BESIDE it this link names where the chunk's
									     documented content actually lives: one real,
									     pinned file (b2input.xml in the B2.5 module
									     repo), in the same source-link styling every
									     other cluster's row uses.  File-level, no #L
									     anchor — the section value below (the switch
									     name, the catalog join key) is the
									     precision instrument, each name unique in
									     b2input.xml. -->
									{@const docs = switchDocsUrl()}
									<a class="source" href={docs.url} target="_blank" rel="noreferrer noopener" title={srcTip(docs)}>b2input.xml</a>
								{/if}
							</p>
							<dl class="provenance">
								{#if cite.chunk.section}<div><dt>section</dt><dd>{cite.chunk.section}</dd></div>{/if}
								{#if cite.chunk.page}<div><dt>page</dt><dd>{cite.chunk.page}</dd></div>{/if}
								<div>
									<dt>chunk id</dt>
									<dd>
										<!-- the id reads 8…6 — one quiet chip, click
										     copies the FULL id.  The verify line below the
										     text keeps the full id visible; the title and
										     aria-label carry it too, so nothing is lost. -->
										<button
											type="button"
											class="idchip"
											data-copied={copied === 'id' ? '' : undefined}
											onclick={() => copyId()}
											aria-label={`Copy chunk id ${cite.chunk.chunkId}`}
											title={cite.chunk.chunkId}
										>
											{copied === 'id' ? 'Copied ✓' : shortId(cite.chunk.chunkId)}
										</button>
									</dd>
								</div>
							</dl>
							<!-- honest line, rewritten to the truth by :
							     the link reaches the DOCUMENT in its public repository;
							     GitHub's PDF viewer takes no page anchor, so the page
							     number in the citation is the anchor (and a Fortran
							     chunk's line range rides the link itself).  Only when a
							     link exists — the synthetic b2mn.dat source shows no
							     note it cannot honor -->
							{#if cite.chunk.sourceUrl && !pageUrl(cite.chunk.source)}
								<p class="deepnote">
									The source path opens the file in its public GitHub repository:
									Fortran links carry the chunk's line range; GitHub's PDF viewer
									takes no page anchor, so the page number in the citation is
									the anchor.
								</p>
							{/if}
							{#if cite.chunk.sourceUrl && pageUrl(cite.chunk.source)}
								<!-- 2026-10-18: the dual-link trade, stated on the artifact -->
								<p class="deepnote">
									The source path opens the rendered tutorial page: live, always
									the latest version; 'pinned source' opens the exact commit this
									citation was indexed from.
								</p>
							{/if}
							<!-- + : the citation, ready to paste — the
							     provenance line alone, or the same line plus this view's
							     deep link. The actions sit provenance-adjacent),
							     reachable without scrolling the full text.  The status is
							     honest both ways: confirmed by the clipboard, or a
							     visible failure with the full chunk id on the verify
							     line as the manual fallback. -->
							<div class="cite-actions">
								<button
									type="button"
									class="copybtn"
									data-copied={copied === 'plain' ? '' : undefined}
									onclick={() => copyCite('plain')}
								>
									{copied === 'plain' ? 'Copied ✓' : 'Copy citation'}
								</button>
								<button
									type="button"
									class="copybtn"
									data-copied={copied === 'linked' ? '' : undefined}
									onclick={() => copyCite('linked')}
								>
									{copied === 'linked' ? 'Copied ✓' : 'Copy with link'}
								</button>
								<span class="copystatus" role="status" aria-live="polite">
									{#if copied === 'fail'}
										clipboard unavailable: the full chunk id rides the verify line below the text
									{:else if copied === 'id'}
										chunk id on your clipboard
									{:else if copied}
										citation on your clipboard
									{/if}
								</span>
							</div>
							<!-- match navigator: the ‹ › walk the marks
							     planted below; disabled clamps at either end -->
							{#if marks.length}
								<p class="mnav">
									<span class="mcount" aria-live="polite"
										>match <span class="mnum">{mIdx + 1}</span> of {marks.length} in text</span
									>
									<button
										type="button"
										class="mstep mprev"
										onclick={() => stepMatch(-1)}
										disabled={mIdx === 0}
										aria-label="Previous match"
									>
										‹
									</button>
									<button
										type="button"
										class="mstep mnext"
										onclick={() => stepMatch(1)}
										disabled={mIdx === marks.length - 1}
										aria-label="Next match"
									>
										›
									</button>
								</p>
							{/if}
							<!-- {#key} rebuilds the box per chunk: each highlight
							     walk starts from Svelte-fresh plain text, and
							     Svelte never updates a node the walk replaced -->
							{#key cite.chunk.chunkId}
								<div class="text" bind:this={textEl}>{cite.chunk.text}</div>
							{/key}
							<!-- the catalog cross-reference — a
							     source_switch citation's section IS the switch
							     name (the ruled join key, VERBATIM, zero fuzzy
							     matching); the panel lists the cataloged runs
							     setting it, rendered from the artifact JSON the
							     service reads at REQUEST time (askthedocs build
							     never touches ../catalog).  Muted placement
							     below the citation body + no curated examples
							     in any zero state — both 2026-09-26
							     design-audit rulings.  Api mode only: the
							     panel renders from xruns, which stays null in
							     static mode and for every other cluster. -->
							{#if cite.chunk.cluster === 'source_switch' && xruns}
								<aside class="xruns" aria-label="Cataloged runs setting this switch">
									<p class="xruns-head">
										{#if xruns.runs.length}
											set by {xruns.runs.length}
											{xruns.runs.length === 1 ? 'cataloged run' : 'cataloged runs'}
										{:else}
											run catalog
										{/if}
									</p>
									{#if xruns.catalog !== 'built'}
										<p class="xruns-note">catalog not built</p>
									{:else if !xruns.runs.length}
										<p class="xruns-note">no cataloged run sets this switch</p>
									{:else}
										<ul class="xruns-list">
											{#each xruns.runs as r (r.run)}
												<li>
													<span class="xr-variant">{runVariant(r.run)}</span>
													<span class="xr-family">{r.family}</span>
													<code class="xr-value">{r.value}</code>
												</li>
											{/each}
										</ul>
										<p class="xruns-note">
											values from the runs' effective b2mn.dat, read live from the run catalog
										</p>
									{/if}
								</aside>
							{/if}
							{#if cite.matched.length || cite.score != null || cite.phraseHit || cite.identity}
								<!-- why-this-result: data exists only when the
								     backend supplied it (api mode); terms + counts + bm25,
								     with the honesty note — never a per-term score story.
								     adds the phrase-tier line: why THIS hit leads —
								     the plain query's terms sit adjacent in this chunk. -->
								<aside class="why">
									<p class="why-head">why this result</p>
									{#if cite.identity}
										<!-- the identity tier's marker — rendered
										     first because it is the first ranking fact:
										     this chunk's citation IS the query -->
										<p class="phraseline identityline">
											exact name<span class="dir">this chunk's citation is “{cite.chunk?.section ?? query.trim()}”: the thing you named, ranked first</span>
										</p>
									{/if}
									{#if cite.phraseHit}
										<!-- the implicit phrase tier's marker — rendered
										     first (below identity) because it is the next
										     ranking fact: these hits outrank every
										     non-phrase hit, bm25 only ordering within the
										     tier -->
										<p class="phraseline">
											phrase tier<span class="dir">query terms adjacent: ranks ahead of all non-phrase hits</span>
										</p>
									{/if}
									{#if cite.matched.length}
										<!-- each chip carries a frequency micro-bar —
										     fill length = n / max n across the panel's terms,
										     same-width tracks so lengths compare across chips
										     (length is pre-attentive where ×n digits are not).
										     The ×n count stays: the bar scans, the number
										     verifies. -->
										{@const maxN = Math.max(...cite.matched.map((m) => m.n))}
										<p class="terms">
											{#each cite.matched as m (m.term)}
												<span class="term">
													<span class="t">{m.term}</span><span class="n">×{m.n}</span>
													<span class="fbar" aria-hidden="true"><span
														class="ffill"
														style="width:{Math.max(6, Math.round((100 * m.n) / maxN))}%"
													></span></span>
												</span>
											{/each}
										</p>
									{/if}
									{#if cite.score != null}
										<p class="scoreline">
											bm25 <span class="score">{cite.score.toFixed(2)}</span>
											<span class="dir">lower is better</span>
										</p>
									{/if}
									<p class="why-note">
										term presence + frequency in this chunk: not a per-term bm25 breakdown
									</p>
								</aside>
							{/if}
							<!-- the verify line keeps the FULL chunk id — the
							     pane's one place the id reads untruncated, the manual
							     fallback when a clipboard is unavailable -->
							<p class="verify">
								Verify from the terminal: <code>askthedocs show {cite.chunk.chunkId}</code>
							</p>
						{:else}
							<p class="error">no chunk with id {cite.chunkId}</p>
						{/if}
					</section>
				{:else if specimenOn}
					<!-- the landing exhibit — ONE real chunk (the
					     Wiesen et al. 2015 JNM title/abstract, the corpus's
					     own origin story) in the pane's real chrome: badge,
					     source path, provenance, id chip, copy actions,
					     marked terms, verify line.  The "specimen" chip
					     labels it an exhibit, not a result; the first
					     keystroke swaps it for the live instrument.  No
					     why-panel (no query, no score to explain) and no
					     match navigator (the marks are the demo, not a
					     walk) — everything else is the pane itself. -->
					<section class="citation card-in" aria-label="Citation specimen">
						<h2>Citation <span class="spec-tag">specimen</span></h2>
						<p class="rowhead">
							{#if specimen.cluster}<span class="badge" data-cluster={specimen.cluster}>{specimen.cluster}</span>{/if}
							{#if specimen.sourceUrl}
								<a class="source" href={specimen.sourceUrl.url} target="_blank" rel="noreferrer noopener" title={srcTip(specimen.sourceUrl)}>{@render srcpath(specimen.source || specimen.chunkId, true)}</a>
							{:else}
								<span class="source">{@render srcpath(specimen.source || specimen.chunkId, true)}</span>
							{/if}
						</p>
						<dl class="provenance">
							<!-- section: PDF front matter often carries none (the
							     store holds NULL) — a literal "-" (an extractor
							     artifact) never renders either -->
							{#if specimen.section && specimen.section !== '-'}
								<div><dt>section</dt><dd>{specimen.section}</dd></div>
							{/if}
							{#if specimen.page}<div><dt>page</dt><dd>{specimen.page}</dd></div>{/if}
							<div>
								<dt>chunk id</dt>
								<dd>
									<!-- semantics, specimen-passing form: the id
									     reads 8…6, click copies the FULL id -->
									<button
										type="button"
										class="idchip"
										data-copied={copied === 'id' ? '' : undefined}
										onclick={() => copyId(specimen)}
										aria-label={`Copy chunk id ${specimen.chunkId}`}
										title={specimen.chunkId}
									>
										{copied === 'id' ? 'Copied ✓' : shortId(specimen.chunkId)}
									</button>
								</dd>
							</div>
						</dl>
						{#if specimen.sourceUrl}
							<p class="deepnote">
								The source path opens the file in its public GitHub repository —
								Fortran links carry the chunk's line range; GitHub's PDF viewer
								takes no page anchor, so the page number in the citation is
								the anchor.
							</p>
						{/if}
						<div class="cite-actions">
							<button
								type="button"
								class="copybtn"
								data-copied={copied === 'plain' ? '' : undefined}
								onclick={() => copyCite('plain', specimen)}
							>
								{copied === 'plain' ? 'Copied ✓' : 'Copy citation'}
							</button>
							<button
								type="button"
								class="copybtn"
								data-copied={copied === 'linked' ? '' : undefined}
								onclick={() => copyCite('linked', specimen)}
							>
								{copied === 'linked' ? 'Copied ✓' : 'Copy with link'}
							</button>
							<span class="copystatus" role="status" aria-live="polite">
								{#if copied === 'fail'}
									clipboard unavailable — the full chunk id rides the verify line below the text
								{:else if copied === 'id'}
									chunk id on your clipboard
								{:else if copied}
									citation on your clipboard
								{/if}
							</span>
						</div>
						<div class="text" bind:this={specText}>{specimen.text}</div>
						<p class="verify">
							Verify from the terminal: <code>askthedocs show {specimen.chunkId}</code>
						</p>
					</section>
				{:else}
					<!-- the pane before any hit is chosen: a quiet prompt, not
					     an empty hole — the column is part of the instrument -->
					<section class="citation ph card-in" bind:this={pane}>
						<h2>Citation</h2>
						<div class="ph-body">
							<span class="ph-tick" aria-hidden="true"></span>
							<p>
								Select a hit and the full chunk appears here: text,
								provenance, and why it ranked.
							</p>
						</div>
					</section>
				{/if}
			{/if}
		</div>
	{/if}
</main>

{#if paletteOpen}
	<!-- the ⌘K command palette (api mode only). ARIA
	     combobox + listbox (APG): the input owns focus and the ring,
	     options are aria-activedescendant targets; Esc closes and
	     hands focus back to the opener; Tab stays trapped (the
	     combobox is the only tab stop).  The veil click closes too. -->
	<div class="cmdk-veil" onclick={closePalette} aria-hidden="true"></div>
	<div
		class="cmdk"
		role="dialog"
		aria-modal="true"
		aria-label="Command palette"
		tabindex="-1"
		onkeydown={onPaletteKey}
	>
		<input
			type="text"
			bind:this={pInput}
			bind:value={pQuery}
			aria-label="Command palette: run a query, filter to a cluster, paste a chunk id"
			placeholder="Search or paste a chunk id…"
			autocomplete="off"
			spellcheck="false"
			role="combobox"
			aria-expanded="true"
			aria-controls="cmdk-list"
			aria-autocomplete="list"
			aria-activedescendant={pSel >= 0 ? `cmdk-opt-${pSel}` : undefined}
		/>
		<!-- the input row's tail glyph — the ⌘K keycap every
		     command palette carries, the reopen/close affordance made
		     visible.  Decorative (aria-hidden): the dialog is labelled,
		     the footer teaches, and a coarse pointer has no ⌘ to name. -->
		<span class="cmdk-glyph" aria-hidden="true"><kbd>⌘K</kbd></span>
		<ul id="cmdk-list" role="listbox" aria-label="Commands">
			{#each cmds as c, i}
				<!-- the options are aria-activedescendant targets, not tab
				     stops (focus stays on the combobox); the click is a
				     pointer shortcut and the key handler mirrors it for
				     the linter — Enter/Space run the option if it ever
				     holds focus -->
				<li
					id="cmdk-opt-{i}"
					role="option"
					aria-selected={pSel === i ? 'true' : 'false'}
					data-selected={pSel === i ? '' : undefined}
					onclick={() => execCommand(c)}
					onkeydown={(e) => {
						if (e.key === 'Enter' || e.key === ' ') execCommand(c);
					}}
				>
					{#if i === 0 || cmds[i - 1].kind !== c.kind}
						<span class="ck">{c.kind}</span>
					{:else}
						<!-- one chip names the run — five CLUSTER
						     cards in a row said CLUSTER five times.  The
						     ghost holds the column (labels stay aligned
						     down the run) while rendering nothing. -->
						<span class="ck ghost" aria-hidden="true">{c.kind}</span>
					{/if}
					<span class="cl">{c.label}</span>
					<span class="ch">{c.hint}</span>
				</li>
			{/each}
		</ul>
		{#if cmds.length === 0}
			<p class="cmdk-none">No commands yet: type a query, or paste a 40-character chunk id.</p>
		{/if}
		<!-- the legend strip — the overlay teaches its OWN keys
		     (the page behind the veil is off-screen, so this is not a
		     second teacher for one surface; once-rule governs
		     the page body).  A coarse pointer drops it, same rule. -->
		<footer class="cmdk-foot">
			<kbd>↑↓</kbd> navigate · <kbd>↵</kbd> run · <kbd>esc</kbd> close
		</footer>
		<p class="sr-only" aria-live="polite">
			{cmds.length} {cmds.length === 1 ? 'command' : 'commands'} available
		</p>
	</div>
{/if}

{#if corpusOpen}
	<!--  the corpus provenance modal (opened by the landing's
	     date line).  The palette overlay's discipline: veil click and
	     Esc close, dialog role + label, focus starts on the dialog.
	     Every row is the index's OWN record — name, the commit the
	     corpus scan pinned, chunk count — linking OUT to the
	     repository at exactly that commit (new window).  Synthesized
	     sources (the b2mn.dat switch inventory) render without a
	     link: they are artifacts of the corpus, not repositories. -->
	<div class="cmdk-veil" onclick={closeCorpus} aria-hidden="true"></div>
	<div
		class="cmdk corpus-modal"
		role="dialog"
		aria-modal="true"
		aria-label="Indexed corpus"
		tabindex="-1"
		bind:this={corpusDialog}
		onkeydown={(ev) => {
			if (ev.key === 'Escape') {
				// the confirm layer owns Esc while open — closing it
				// never closes the modal behind it in the same stroke
				if (confirmOpen) cancelReindex();
				else closeCorpus();
			}
		}}
	>
		<header class="corpus-head">
			<p class="corpus-title">The indexed corpus</p>
			<p class="corpus-built">
				built {corpusDate} · {(corpusInfo?.repos ?? []).reduce((t, r) => t + r.chunks, 0).toLocaleString()} chunks total in {corpusInfo?.repos.length ?? 0} repositories
			</p>
		</header>
		<!-- the freshness band — honest states, every absent control
		     explained by the band's own text (no disabled buttons, no
		     tooltips).  The absent (yellow) story folds BOTH decay
		     shapes: the service could not resolve the corpus (the
		     named refusal IS the situation), or resolved it and found
		     zero repositories (composed from the verdict's own root) -->
		{#if verdictState === 'fetching'}
			<div class="corpus-band"><p class="band-line quiet">checking freshness…</p></div>
		{:else if verdictState === 'absent'}
			<div class="corpus-band absent">
				<p class="band-line">{verdictNote}</p>
			</div>
		{:else if verdictState === 'unknown'}
			<div class="corpus-band">
				<p class="band-line quiet">freshness unknown: the staleness service did not answer</p>
			</div>
		{:else if verdictState === 'ok' && verdicts}
			<div class="corpus-band" class:drifted={driftedLegs.length > 0 && !frozenAsShipped} class:absent={frozenAsShipped}>
				{#if frozenAsShipped}
					<p class="band-line">
						the indexed corpus cannot be found on this machine: the repositories recorded beside this index (at {verdicts.repos_root ?? 'the recorded location'}) are not there anymore. Search keeps answering from the indexed content; freshness cannot be judged until the repositories are back. Restore them at that location, or run askthedocs setup from a clone to record a new one.
					</p>
				{:else if driftedLegs.length === 0}
					<div class="band-row">
						<p class="band-line">
							corpus unchanged since this index was built{carriedLegs.length ? `; ${carriedLegs.length} leg${carriedLegs.length === 1 ? '' : 's'} carried at the pinned commit${carriedLegs.length === 1 ? '' : 's'} shown (not on disk)` : ''}.
						</p>
						<!-- the deliberate rebuild of a fresh index,
						     BESIDE the statement it qualifies - the
						     confirmation carries the honesty, not the
						     button face alone -->
						{#if reindexPhase !== 'running'}
							<button type="button" class="band-reindex" onclick={askForce}>
								force re-index
							</button>
						{/if}
					</div>
				{:else}
					<p class="band-line">
						drifted on disk: {driftedLegs.map((l) => l.name).join(', ')}; {driftTotals.n} new · {driftTotals.c} changed · {driftTotals.r} removed since this index was built
					</p>
					{#if [...(verdicts.drift?.new ?? []), ...(verdicts.drift?.changed ?? []), ...(verdicts.drift?.removed ?? [])].length}
						<ul class="band-evidence">
							{#each verdicts.drift?.new ?? [] as label (label)}<li>new {label}</li>{/each}
							{#each verdicts.drift?.changed ?? [] as label (label)}<li>changed {label}</li>{/each}
							{#each verdicts.drift?.removed ?? [] as label (label)}<li>removed {label}</li>{/each}
						</ul>
					{/if}
					{#if carriedLegs.length}
						<p class="band-carried">kept at their shipped versions (not on disk): {carriedLegs.map((l) => l.name).join(', ')}</p>
					{/if}
					<!-- the control exists only where it can act — and its
					     absence above is already explained by the band's
					     own state text -->
					{#if reindexPhase !== 'running'}
						<button type="button" class="band-reindex" onclick={askReindex}>
							index now
						</button>
					{/if}
				{/if}
				{#if reindexRefusal}
					<p class="band-line refusal">reindex refused: {reindexRefusal}</p>
				{/if}
				{#if reindexPhase === 'running'}
					<p class="band-line running">
						rebuilding: search continues on the current index; this page refreshes itself when the new index lands
					</p>
				{/if}
				{#if reindexPhase === 'done' && reindexJob}
					<p class="band-line done">rebuilt in {fmtDuration(reindexJob.duration_s)}: the index above is current</p>
				{/if}
				{#if reindexPhase === 'failed' && reindexJob}
					<p class="band-line failure">rebuild failed: {reindexJob.error ?? 'unknown error'}; the current index is untouched. Fix or remove the named sources, then rebuild again.</p>
				{/if}
			</div>
		{/if}
		<ul class="corpus-repos">
			{#each corpusInfo?.repos ?? [] as r (r.name)}
				<li class:child={r.name.includes('/modules/')}>
					{#if r.linkable !== false && repoLink(r.name, r.commit)}
						<a href={repoLink(r.name, r.commit)} target="_blank" rel="noreferrer noopener">
							<span class="cr-name">{r.name.includes('/modules/') ? r.name.split('/').pop() : r.name}</span>
							<span class="cr-commit">{r.commit ? r.commit.slice(0, 9) : 'default branch'}</span>
							<span class="cr-chunks">{r.chunks.toLocaleString()} chunks</span>
							{#if chipFor(r.name)}<span class="cr-chip {verdictMap.get(r.name).verdict}">{chipFor(r.name)}</span>{/if}
						</a>
					{:else}
						<span class="cr-row-synth">
							<span class="cr-name">{r.name.includes('/modules/') ? r.name.split('/').pop() : r.name}</span>
							<!-- the honest non-link labels: a synthesized
							     source has no commit to pin; a non-public
							     submodule has one (its gitlink) but no
							     repository to open — adas answers 404 -->
							<span class="cr-commit">{r.commit ? `${r.commit.slice(0, 9)} · not public` : 'synthesized'}</span>
							<span class="cr-chunks">{r.chunks.toLocaleString()} chunks</span>
							{#if chipFor(r.name)}<span class="cr-chip {verdictMap.get(r.name).verdict}">{chipFor(r.name)}</span>{/if}
						</span>
					{/if}
				</li>
			{/each}
		</ul>
		<footer class="cmdk-foot">
			esc closes · every link opens the repository at the exact indexed commit
			<!-- the one-sentence coverage rule, stated where the
			     coverage is visible -->
			<p class="corpus-rule">
				every Fortran file, as procedure units · all documentation · the databases · the synthesized switch inventory: the GUI enters through its documentation (no switch or subroutine joins in its code)
			</p>
		</footer>
		{#if confirmOpen}
			<!-- the evidence-carrying confirmation: the drift facts
			     (or, on the force path, the deliberate-nothing-changed
			     fact), what stays at its shipped version, the measured
			     cost when one exists, and that search never stops.
			     Esc cancels the confirm, never the modal -->
			<div class="confirm-veil" aria-hidden="true"></div>
			<div class="confirm-card" role="dialog" aria-modal="true" aria-label="Rebuild the index now">
				<p class="confirm-title">Rebuild the index now</p>
				<ul class="confirm-facts">
					{#if confirmMode === 'force'}
						<li>
							nothing changed on disk since this index was built:
							this rebuilds the whole corpus anyway, the deliberate force path
						</li>
					{:else}
						<li>
							{driftTotals.n} new · {driftTotals.c} changed · {driftTotals.r} removed:
							the drifted legs are re-extracted from disk; deletions propagate
						</li>
					{/if}
					{#if confirmMode === 'drift' && carriedLegs.length}
						<li>kept at their shipped versions (not on disk): {carriedLegs.map((l) => l.name).join(', ')}</li>
					{/if}
					<li>
						{reindexJob?.duration_s != null
							? `the last rebuild took ${fmtDuration(reindexJob.duration_s)}`
							: 'this takes several minutes'}
					</li>
					<li>search continues on the current index throughout: on failure nothing changes</li>
				</ul>
				<div class="confirm-actions">
					<button type="button" class="confirm-go" onclick={doReindex}>Rebuild now</button>
					<button type="button" class="confirm-stop" onclick={cancelReindex}>Cancel</button>
				</div>
			</div>
		{/if}
	</div>
{/if}

		{#if progressOpen}
			<!-- the live frame: the CLI's own indexing display,
			     streamed line-by-line (the service diffs the shared
			     renderer's frames and pushes the changed lines); a
			     changed line updates ITS span — never a full-frame
			     rebuild (render on event).  ONE clock per
			     window: the frame's own global line carries the
			     elapsed (the CLI display's own, streamed with the
			     deltas) — the title's client-side twin was removed
			     as redundant (owner ruling 2026-11-11); the
			     client-side ticker survives for the CLOSED chip
			     only, no frame being visible there.  Closing this
			     window never stops the job — the chip carries the
			     state until the refreshed verdict lands.
			     Viewport-level and WIDE: the 72-column frame must
			     never scroll sideways, so the card outgrows the
			     corpus modal instead of clipping inside it -->
			<div class="progress-veil" aria-hidden="true"></div>
			<div
				class="progress-card"
				role="dialog"
				aria-modal="true"
				aria-label="Rebuilding the index"
				tabindex="-1"
				bind:this={progressDialog}
				onkeydown={(ev) => {
					if (ev.key === 'Escape') closeProgress();
				}}
			>
				<p class="confirm-title">Rebuilding the index</p>
				<p class="progress-note">
					search keeps answering from the current index throughout; closing this window does not stop the indexing.
				</p>
				<pre class="progress-frame" bind:this={progressFrame}>{#if reindexStarting && !frameLines.length}checking what changed on disk, the rebuild starts right after…{:else if frameLines.length}{#each frameLines as line, i (i)}<span class="fl">{line || ' '}</span>{'\n'}{/each}{:else}starting…{/if}</pre>
				{#if reindexPhase === 'done' && reindexJob}
					<p class="band-line done">rebuilt in {fmtDuration(reindexJob.duration_s)}: the index is current</p>
				{:else if reindexPhase === 'failed' && reindexJob}
					<p class="band-line failure">rebuild failed: {reindexJob.error ?? 'unknown error'}; the current index is untouched. Fix or remove the named sources, then rebuild again.</p>
				{/if}
				<div class="confirm-actions">
					<button type="button" class="confirm-stop" onclick={closeProgress}>
						{reindexPhase === 'running' ? 'Close' : 'Done'}
					</button>
				</div>
			</div>
		{/if}

{#snippet srcpath(s, breakable)}
	<!-- a source path wraps at its OWN seams — a break
	     opportunity after every / and nowhere else, so a long path
	     folds "SOLPS-ITER/doc/ CPP_2006.pdf", never "Report.p/df".
	     Text nodes + <wbr>, never innerHTML (the v1 excerpt
	     discipline); `breakable` false renders the plain string —
	     the static face's runtime rendering is frozen, the wbr ride
	     is api-gated like every display change. The CSS half
	     (.source below) swaps word-break: break-all for
	     overflow-wrap: break-word, so an unbreakable single segment
	     longer than the column still wraps as the last resort
	     instead of forcing horizontal scroll. -->
	{#if breakable}
		{@const parts = String(s).split('/')}
		{#each parts as seg, i}{seg}{#if i < parts.length - 1}/<wbr />{/if}{/each}
	{:else}
		{s}
	{/if}
{/snippet}
{#snippet row(r, i)}
	<!-- the same-source fold context — null in static mode,
	     where every row names its source exactly as the frozen face
	     always did -->
	{@const ru = CITATION_VIEW === 'inline' ? srcRun(i) : null}
	<!-- the page rides the PATH row in api mode ("path · p. 48")
	     — one meta line saved per hit.  It follows the source's own
	     visibility: a folded run's continuation rows omit the path, so
	     they omit the page too (the pane carries full provenance).
	     Static mode keeps the page on its own line, exactly as the
	     frozen face always rendered it. -->
	{@const pg = URL_STATE && r.page && !(ru && ru.n >= 3 && !ru.first) ? r.page : ''}
	<span class="rowhead">
		{#each r.clusters as c (c)}
			<span class="badge" data-cluster={c}>{c}</span>
		{/each}
		<!-- contents-row badge (leader-dot density, computed in
		     the data module on the RAW snippet) — the row is labeled
		     for what it is, never demoted -->
		{#if r.toc}
			<span
				class="tocbadge"
				title="table-of-contents row: dot leaders collapsed in display"
			>contents row</span>
		{/if}
		<!-- completion-tier badge — the row matches a corpus word
		     EXTENDING the unfinished typed word; it never counts as a
		     hit and committing drops it (the divider above labels the
		     tier; this badge survives row-level reuse, e.g. fold
		     continuations) -->
		{#if r.completion}
			<span
				class="combadge"
				title="completion: matches a word extending your unfinished term; dropped when you commit"
			>completion</span>
		{/if}
		<!-- runs >= 3 fold — the first row names the source with
		     a ×n count; the rest omit it (the pane still shows every
		     chunk's full provenance). : a row's source renders
		     as an ANCHOR into its public GitHub repo iff the data
		     module computed one (api mode; the synthetic b2mn.dat
		     source and the whole static face keep the plain span).
		     The two variants are guard-pairs ({#if}/{#if !}), not
		     if/else — the fold's structure stays flat for the
		     contract test's structural split -->
		{#if ru && ru.n >= 3}
			{#if ru.first}
				{#if r.sourceUrl}<a class="source" href={pageUrl(r.source) ?? r.sourceUrl.url} target="_blank" rel="noreferrer noopener" title={pageUrl(r.source) ? 'The rendered tutorial page — always the latest version' : srcTip(r.sourceUrl)}>{@render srcpath(dispSource(r.source) || r.chunkId, URL_STATE)}</a>{/if}
				{#if !r.sourceUrl}<span class="source">{@render srcpath(r.source || r.chunkId, URL_STATE)}</span>{/if}
				<span class="srun" title={`${ru.n} consecutive hits from this source: the ${ru.n - 1} rows below omit the repeated path`}>×{ru.n}</span>
				{#if pg}<span class="pgsep" aria-hidden="true">·</span><span class="page">{pg}</span>{/if}
			{/if}
		{:else}
			{#if r.sourceUrl}<a class="source" href={pageUrl(r.source) ?? r.sourceUrl.url} target="_blank" rel="noreferrer noopener" title={pageUrl(r.source) ? 'The rendered tutorial page — always the latest version' : srcTip(r.sourceUrl)}>{@render srcpath(dispSource(r.source) || r.chunkId, URL_STATE)}</a>{/if}
			{#if !r.sourceUrl}<span class="source">{@render srcpath(r.source || r.chunkId, URL_STATE)}</span>{/if}
			{#if pg}<span class="pgsep" aria-hidden="true">·</span><span class="page">{pg}</span>{/if}
		{/if}
	</span>
	{#if r.section}<span class="section">{r.section}</span>{/if}
	{#if !URL_STATE}<span class="page">{r.page}</span>{/if}
	<!-- excerpt HTML is built inside $lib/data.js: highlights arrive
	     as <mark> markup from the data module — never raw corpus
	     markup -->
	<span class="excerpt">{@html r.excerptHtml}</span>
{/snippet}

<style>
	main {
		max-width: 52rem;
		margin: 0 auto;
		padding: clamp(2rem, 6vh, 4.5rem) 1.25rem 5rem;
	}

	/* ------------------------------------------------------- masthead */

	.masthead {
		padding-bottom: 1.4rem;
		margin-bottom: 1.6rem;
		border-bottom: 1px solid var(--line);
		position: relative;
	}
	/* the plasma beam: a short amber segment riding the hairline.
	   : 2px (was 3) — at 3px the beam read as a chunky bar of
	   its own; at 2px it straddles the 1px hairline symmetrically
	   (bottom -1.5px puts its center on the hairline's center) and
	   reads as the hairline going plasma, which is the idea */
	.masthead::after {
		content: '';
		position: absolute;
		left: 0;
		bottom: -1.5px;
		width: 4.5rem;
		height: 2px;
		background: var(--plasma);
	}
	.overline {
		margin: 0 0 0.5rem;
		font-family: var(--font-mono);
		font-size: 0.72rem;
		font-weight: 600;
		letter-spacing: 0.16em;
		text-transform: uppercase;
		color: var(--accent);
	}
	.wordmark {
		display: flex;
		align-items: baseline;
		gap: 0.35rem;
	}
	h1 {
		margin: 0;
		font-size: clamp(2.1rem, 5vw, 2.9rem);
		font-weight: 600;
		letter-spacing: -0.02em;
		line-height: 1.05;
	}
	.tick {
		width: 0.5em;
		height: 0.5em;
		background: var(--plasma);
		transform: rotate(45deg) translate(-2px, -4px);
	}
	.tagline {
		margin: 0.65rem 0 0;
		font-family: var(--font-serif);
		font-size: 1.05rem;
		color: var(--text-2);
	}
	/* the color-scheme keycap — the quiet mono-chip family,
	   riding the masthead's top-right corner (the masthead is already
	   the positioned box its plasma beam hangs from) */
	.theme-toggle {
		position: absolute;
		top: 0;
		right: 0;
		padding: 0.26rem 0.62rem;
		font-family: var(--font-mono);
		font-size: 0.68rem;
		font-weight: 600;
		letter-spacing: 0.09em;
		text-transform: uppercase;
		color: var(--text-2);
		background: var(--surface);
		border: 1px solid var(--line-strong);
		border-radius: var(--r-1);
		cursor: pointer;
		transition: border-color 0.15s ease, color 0.15s ease;
	}
	.theme-toggle:hover {
		border-color: var(--plasma);
		color: var(--text);
	}
	.theme-toggle:focus-visible {
		outline: 2px solid var(--focus-ring);
		outline-offset: 2px;
	}

	/* ------------------------------------------------ search instrument */

	form {
		display: flex;
		gap: 0.6rem;
		margin: 0;
	}
	input[type='search'] {
		flex: 1;
		min-width: 0;
		height: 3.1rem;
		padding: 0 1rem;
		font-family: var(--font-ui);
		font-size: 1.02rem;
		color: var(--text);
		background: var(--surface);
		border: 1px solid var(--line-strong);
		border-radius: var(--r-2);
		transition: border-color 0.15s ease, box-shadow 0.15s ease;
	}
	/* the placeholder reads as a GHOST, not as typed text —
	   --text mixed ~50% toward the surface (both themes land ≈3:1,
	   recorded in tests/test_polish_us021.py — placeholder, not body
	   text; typed --text sits at full AA above it).  Same mix for the
	   palette input, which floats on the same --surface. */
	input[type='search']::placeholder {
		color: color-mix(in srgb, var(--text) 50%, var(--surface));
	}
	/* WebKit's native cancel ✕ (it appears the moment the
	   box has text) is redrawn as a system glyph — the default aqua
	   blob never met this instrument.  Two crossed gradient bands
	   draw the ✕ in --text-2 (≥3:1 on both surfaces, a UI part);
	   hover firms to --text like every chip/key hover on the page
	   (NOT plasma: amber on surface is 1.7:1, under the UI floor).
	   Firefox renders no native cancel button, so the rule is
	   deliberately -webkit-only. */
	input[type='search']::-webkit-search-cancel-button {
		-webkit-appearance: none;
		appearance: none;
		width: 0.8rem;
		height: 0.8rem;
		background:
			linear-gradient(
				45deg,
				transparent 44%,
				var(--text-2) 44%,
				var(--text-2) 56%,
				transparent 56%
			),
			linear-gradient(
				135deg,
				transparent 44%,
				var(--text-2) 44%,
				var(--text-2) 56%,
				transparent 56%
			);
		cursor: pointer;
	}
	input[type='search']:hover::-webkit-search-cancel-button {
		background-image:
			linear-gradient(
				45deg,
				transparent 44%,
				var(--text) 44%,
				var(--text) 56%,
				transparent 56%
			),
			linear-gradient(
				135deg,
				transparent 44%,
				var(--text) 44%,
				var(--text) 56%,
				transparent 56%
			);
	}
	form:focus-within input[type='search'] {
		border-color: var(--focus-ring);
		box-shadow: 0 0 0 3px color-mix(in srgb, var(--focus-ring) 22%, transparent);
	}
	/* while a list row holds the keyboard selection the box
	   yields its focus ring — ONE focused signal on screen at a time,
	   and it is the row's ink frame (the box still owns the keys; it
	   just stops claiming the eye).  sel resets on Esc/fresh results
	   and the class drops, restoring the ring on the still-focused
	   box without any extra wiring. */
	form.listing:focus-within input[type='search'] {
		border-color: var(--line-strong);
		box-shadow: none;
	}
	/* scoped to the search submit — a bare `button` selector would also
	   restyle the api-mode .hit cards (height-locked, ink fill on
	   hover); caught during panel verification.
	   Fill/ink come from the themed --button-* pair): light
	   keeps the ink CTA, dark flips to paper-on-navy so the control
	   survives the canvas (17.6:1) */
	form button {
		/* anchor for the busy spinner (absolutely centered —
		   the flow box never changes between idle and running, so the
		   form's geometry is state-independent) */
		position: relative;
		height: 3.1rem;
		padding: 0 1.5rem;
		font-family: var(--font-ui);
		font-weight: 600;
		font-size: 0.95rem;
		letter-spacing: 0.01em;
		color: var(--button-fg);
		background: var(--button-bg);
		border: 1px solid var(--button-bg);
		border-radius: var(--r-2);
		cursor: pointer;
		transition: background-color 0.15s ease;
	}
	form button:hover:not(:disabled) {
		background: color-mix(in srgb, var(--button-bg) 84%, var(--plasma));
		border-color: color-mix(in srgb, var(--button-bg) 84%, var(--plasma));
	}
	/* busy = spinner over a hidden label. The old
	   whole-button 0.55 dim went with the retired busy-word label
	   swap — the chrome now holds full strength (width AND fill
	   constant); the label hides while KEEPING its box
	   (visibility, not display — the flow geometry is untouched, and
	   protocol E's dimmed-text-under-the-ring read settled opacity
	   ghosts in favor of a clean hide), so the centered spinner owns
	   the button alone. */
	form button:disabled {
		cursor: wait;
	}
	form button:disabled .blabel {
		visibility: hidden;
	}
	/* the busy glyph: a 2px ring with one lit quadrant, centered over
	   the dimmed label — absolutely positioned, zero flow footprint.
	   Rotation is motion of the "state, not story" kind, but the
	   project rule is blanket: it runs only under
	   prefers-reduced-motion: no-preference (the static ring still
	   reads as busy, and aria-busy carries the state). */
	.spin {
		position: absolute;
		inset: 0;
		margin: auto;
		width: 1.05rem;
		height: 1.05rem;
		border-radius: var(--r-pill);
		border: 2px solid color-mix(in srgb, var(--button-fg) 30%, transparent);
		border-top-color: var(--button-fg);
	}
	@media (prefers-reduced-motion: no-preference) {
		.spin {
			animation: b-spin 0.7s linear infinite;
		}
	}
	@keyframes b-spin {
		to {
			transform: rotate(360deg);
		}
	}
	.spec {
		margin: 0.65rem 0.1rem 0;
		font-family: var(--font-mono);
		font-size: 0.72rem;
		letter-spacing: 0.05em;
		color: var(--text-2);
	}
	/* keybinds render as keycaps — the quiet mono-key family the
	   chips, steppers and copy buttons already use (surface, hairline,
	   4px radius), scaled to the spec line's rhythm; the 2px bottom edge
	   is the keycap's one mechanical cue, depth without a shadow.  Text
	   on --surface is the page's AA-verified pair; --line-strong is the
	   -raised hairline, visible in dark. */
	.spec kbd {
		font-family: var(--font-mono);
		font-size: 0.66rem;
		padding: 0.09rem 0.34rem;
		border: 1px solid var(--line-strong);
		border-bottom-width: 2px;
		border-radius: var(--r-1);
		background: var(--surface);
		color: var(--text);
		white-space: nowrap;
	}
	/* a coarse pointer has no keyboard to teach — the whole
	   keybind segment (its separators ride inside the span) drops out
	   and the functional claims stand alone.  Fine pointers keep the
	   full line; `pointer` (not hover) is the honest question: it asks
	   what the PRIMARY input is, which is exactly the teaching's
	   audience. */
	@media (pointer: coarse) {
		.spec .keys {
			display: none;
		}
		/* the palette's keybind teaching rides the same rule —
		   a touch device has no ↑↓, ↵ or ⌘K to teach, and the footer
		   strip is pure teaching (nothing functional lives in it) */
		.cmdk-foot,
		.cmdk-glyph {
			display: none;
		}
	}

	/* ---------------------------------------------- recents band) */
	/* the landing state's way back in: the queries this browser has
	   already committed, offered as real buttons before the first
	   keystroke.  A quiet machine readout — hairline boundary, mono
	   label, pill keys in the chip family (hover takes the plasma
	   border like every other key on the page).  No recents, no
	   band: a first-time landing renders none of this. */
	.recents {
		margin-top: 2.4rem;
		padding-top: 1.3rem;
		border-top: 1px solid var(--line);
	}
	.recents-label {
		margin: 0 0 0.75rem;
		font-family: var(--font-mono);
		font-size: 0.68rem;
		font-weight: 600;
		letter-spacing: 0.14em;
		text-transform: uppercase;
		color: var(--text-2);
	}
	.recents-row {
		display: flex;
		flex-wrap: wrap;
		gap: 0.45rem;
	}
	/* a recent can be a long typed query — the pill caps and
	   ellipsizes rather than pushing the row wide */
	.recent {
		max-width: 100%;
		padding: 0.34rem 0.85rem;
		font-family: var(--font-mono);
		font-size: 0.78rem;
		letter-spacing: 0.01em;
		color: var(--text);
		background: var(--surface);
		border: 1px solid var(--line-strong);
		border-radius: var(--r-pill);
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
		cursor: pointer;
		transition: border-color 0.15s ease, background-color 0.15s ease;
	}
	.recent:hover {
		border-color: var(--plasma);
		background: color-mix(in srgb, var(--plasma) 8%, var(--surface));
	}
	.recent:focus-visible {
		outline: 2px solid var(--focus-ring);
		outline-offset: 2px;
	}

	/* ------------------------------------------------------ hit cards */

	.meta {
		display: flex;
		align-items: baseline;
		gap: 0.4rem;
		margin: 2rem 0 0;
		font-family: var(--font-mono);
		font-size: 0.85rem;
		color: var(--text-2);
	}
	.meta .count {
		font-size: 1.35rem;
		font-weight: 600;
		color: var(--text);
	}
	.meta .in {
		color: var(--accent);
	}
	/* ---------------------------------------------------- cluster chips */
	.chips {
		display: flex;
		flex-wrap: wrap;
		/* row-gap 0.7rem (11.2px) clears the ±9.35px touch band
		   below — a wrapped row's band can never dip into the next
		   row's visible chips (that would be a mis-hit, the thing this
		   story exists to kill).  Column-gap stays 0.45rem: the touch
		   band is vertical-only, so horizontal spacing never mattered.
		   Single-row layouts (desktop) use no row gap at all — the
		   desktop face is pixel-identical. */
		gap: 0.7rem 0.45rem;
		margin: 0.95rem 0 0;
	}
	/* mono pill, machine values inside — a chip is a readout that
	   filters; the active one takes the badge pair (plasma + ink) */
	.chip {
		display: inline-flex;
		align-items: baseline;
		gap: 0.42rem;
		padding: 0.26rem 0.72rem;
		font-family: var(--font-mono);
		font-size: 0.74rem;
		letter-spacing: 0.03em;
		color: var(--text-2);
		background: var(--surface);
		border: 1px solid var(--line-strong);
		border-radius: var(--r-pill);
		cursor: pointer;
		transition: border-color 0.15s ease, background-color 0.15s ease,
			color 0.15s ease;
		/* anchor for the ::after touch band */
		position: relative;
	}
	/* touch floor: a 44px (2.75rem) invisible band centered on
	   the visible pill — every chip is tappable at thumb height while
	   the drawn control stays exactly its designed size.  Vertical
	   only (left/right 0): sideways bands would overlap the neighbor
	   chip and steal its edge taps.  Chips are position:relative so a
	   wrapped row's real box always paints above the row above's band
	   — the band may only claim dead whitespace, never a sibling's
	   pixels. */
	.chip::after {
		content: '';
		position: absolute;
		left: 0;
		right: 0;
		top: 50%;
		transform: translateY(-50%);
		height: 2.75rem;
	}
	.chip:hover {
		border-color: var(--plasma);
		color: var(--text);
	}
	.chip:focus-visible {
		outline: 2px solid var(--focus-ring);
		outline-offset: 2px;
	}
	.chip[aria-pressed='true'] {
		background: var(--plasma);
		border-color: var(--plasma);
		color: var(--ink);
	}
	.chip .n {
		font-size: 0.68rem;
		color: var(--text-2);
	}
	.chip[aria-pressed='true'] .n {
		color: var(--ink);
		font-weight: 600;
	}

	/* -------------------------------------------- cluster palette
	   Owner-directed 2026-09-27: pills + badges, curated twelve.  The
	   mapping block sets per-cluster custom props from tokens.css;
	   every rule below consumes them WITH a pre-030 fallback, so an
	   unknown cluster (a rebuilt corpus growing a new one) renders
	   exactly the old look.  The color LADDER: a hue DOT at rest
	   (non-text, 3:1 floor — the quiet machine aesthetic survives),
	   a faint tint on hover, the cluster's own fill when active.
	   On the active fill the dot is same-colored — absorbed by
	   construction, no extra rule.  Amber's meaning SHARPENS per the
	   ruling: matches + the all pill. Badges adopt the hue in
	   API MODE ONLY ([data-api]) — the static face keeps its frozen
	   amber.  Values are COMPUTED (tests/test_clusterpalette_us030.py),
	   never eyeballed. */
	[data-cluster='docs'] { --cc: var(--cluster-docs); --cc-on: var(--cluster-docs-on); }
	[data-cluster='solps_docs'] { --cc: var(--cluster-solps_docs); --cc-on: var(--cluster-solps_docs-on); }
	[data-cluster='eirene_manual'] { --cc: var(--cluster-eirene_manual); --cc-on: var(--cluster-eirene_manual-on); }
	[data-cluster='tutorials'] { --cc: var(--cluster-tutorials); --cc-on: var(--cluster-tutorials-on); }
	[data-cluster='amdata'] { --cc: var(--cluster-amdata); --cc-on: var(--cluster-amdata-on); }
	[data-cluster='fortran_source'] { --cc: var(--cluster-fortran_source); --cc-on: var(--cluster-fortran_source-on); }
	[data-cluster='gui_docs'] { --cc: var(--cluster-gui_docs); --cc-on: var(--cluster-gui_docs-on); }
	[data-cluster='gui_figures'] { --cc: var(--cluster-gui_figures); --cc-on: var(--cluster-gui_figures-on); }
	[data-cluster='source_switch'] { --cc: var(--cluster-source_switch); --cc-on: var(--cluster-source_switch-on); }
	[data-cluster='divgeo'] { --cc: var(--cluster-divgeo); --cc-on: var(--cluster-divgeo-on); }
	[data-cluster='module_docs'] { --cc: var(--cluster-module_docs); --cc-on: var(--cluster-module_docs-on); }
	[data-cluster='course'] { --cc: var(--cluster-course); --cc-on: var(--cluster-course-on); }
	[data-cluster='log'] { --cc: var(--cluster-log); --cc-on: var(--cluster-log-on); }
	.chip[data-cluster]::before {
		content: '';
		flex: none;
		align-self: center;
		width: 0.5rem;
		height: 0.5rem;
		border-radius: var(--r-pill);
		background: var(--cc, var(--text-2));
	}
	.chip[data-cluster]:hover {
		border-color: var(--cc, var(--plasma));
		color: var(--text);
		background: color-mix(in srgb, var(--cc, var(--plasma)) 8%, var(--surface));
	}
	.chip[data-cluster][aria-pressed='true'] {
		background: var(--cc, var(--plasma));
		border-color: var(--cc, var(--plasma));
		color: var(--cc-on, var(--ink));
	}
	.chip[data-cluster][aria-pressed='true'] .n {
		color: var(--cc-on, var(--ink));
		font-weight: 600;
	}
	/* api mode only — the static face's badges stay amber (frozen) */
	[data-api] .badge[data-cluster] {
		background: var(--cc, var(--plasma));
		color: var(--cc-on, var(--ink));
	}
	.hint {
		margin: 0.2rem 0 0;
		color: var(--text-2);
		font-size: 0.88rem;
	}
	.error {
		color: var(--danger);
		margin: 1rem 0 0;
	}
	/*  a real failure is a card with the message AND a way
	   forward (the .empty card's geometry, the danger rail instead of
	   the accent one) */
	.errorcard {
		margin-top: 1.2rem;
		padding: 1rem 1.2rem 1.1rem;
		border: 1px solid var(--line);
		border-left: 3px solid var(--danger);
		border-radius: var(--r-3);
		background: var(--surface);
	}
	.error-head {
		margin: 0 0 0.4rem;
		font-family: var(--font-serif);
		font-size: 1.02rem;
		color: var(--text);
	}
	.error-msg {
		margin: 0 0 0.5rem;
		font-family: var(--font-mono);
		font-size: 0.8rem;
		color: var(--danger);
		word-break: break-word;
	}
	.error-hint {
		margin: 0;
		font-size: 0.88rem;
		color: var(--text-2);
	}
	.error-hint code {
		font-family: var(--font-mono);
		font-size: 0.8rem;
		color: var(--text);
		background: var(--surface-2);
		border-radius: var(--r-1);
		padding: 0.05rem 0.35rem;
	}
	.pause {
		margin: 1rem 0 0;
		font-family: var(--font-mono);
		font-size: 0.8rem;
		color: var(--text-2);
	}

	/* ------------------------------------------------------ skeletons */

	.skels .hit {
		cursor: default;
		pointer-events: none;
	}
	/* each bar is boxed to the REAL metric of the element it
	   stands in for, so the skeleton card's height equals the modal
	   real card's and the skeleton -> hits swap shifts nothing:
	     badge box    0.66rem font x1.55 + 0.24 padding + 2px border
	                  ≈ 1.39rem (the rowhead's tallest box)
	     meta line moved the page onto the rowhead; the
	                  card's remaining meta line is the SECTION —
	                  .section's line box 0.95 x1.55 ≈ 1.47rem
	                  (0.95 bar + 0.52 leading)
	     excerpt line pitch 0.98 x1.65 = 1.617rem (0.98 bar + 0.64
	                  leading; the first adds 0.15 for the real
	                  excerpt's own margin-top)
	   Card total ≈ 8.4rem vs the measured real median (DOM-probed
	   numbers, recorded at design time).  The bars
	   are text-height, not line-height — the leading rides the
	   margins, which is also what makes them read as lines of text. */
	.sk {
		display: block;
		height: 0.98rem;
		border-radius: var(--r-1);
		background: var(--surface-2);
	}
	.sk-badge {
		width: 5.5rem;
		height: 1.39rem;
		flex: none;
	}
	.sk-src {
		width: 40%;
		height: 0.82rem;
	}
	.sk-meta {
		width: 30%;
		height: 0.95rem;
		margin-top: 0.52rem;
	}
	.sk-line {
		margin-top: 0.64rem;
	}
	.sk-line.w95 {
		margin-top: 0.79rem;
	}
	.w80 {
		width: 80%;
	}
	.w95 {
		width: 95%;
	}
	@media (prefers-reduced-motion: no-preference) {
		.sk {
			background: linear-gradient(
				100deg,
				var(--surface-2) 40%,
				color-mix(in srgb, var(--surface-2) 55%, var(--bg)) 50%,
				var(--surface-2) 60%
			);
			background-size: 200% 100%;
			animation: sk-shimmer 1.2s ease-in-out infinite;
		}
	}
	@keyframes sk-shimmer {
		to {
			background-position: -200% 0;
		}
	}

	/* three row states, three signals, one owner each:
	   the open row anchors the pane (plasma bar + wash, 
	   semantics unchanged); the keyboard selection is STRUCTURAL
	   (ink frame + inset top rule — an owner ruling, no tint, no
	   amber: amber stays with matches and the active filter); hover
	   lifts (shadow, no bar — see .hit:hover below).  The two rules
	   write DISJOINT longhands on purpose: open owns the left slot,
	   selected owns the other three sides + the rule, so a row that
	   is both shows every fact at once (source order never decides). */
	li[data-open] .hit {
		border-color: var(--line-strong);
		border-left-color: var(--plasma);
		/* filled, not edged: a wash you see without looking (up from
		   5% — 2026-10-18 pairing pass; revert to 5% if it shouts) */
		background: color-mix(in srgb, var(--plasma) 11%, var(--surface));
	}
	/* the open row points at its pane — › at the row's top-right,
	   pseudo-element so it costs zero layout; amber stays open's */
	li[data-open] .hit::after {
		content: '›';
		position: absolute;
		top: 0.55rem;
		right: 0.7rem;
		color: var(--plasma);
		font-size: 1.2rem;
		line-height: 1;
		font-weight: 600;
		pointer-events: none;
	}
	li[data-selected] .hit {
		border-top-color: var(--sel-line);
		border-right-color: var(--sel-line);
		border-bottom-color: var(--sel-line);
		/* the rule — inset, so selection costs zero layout
		   anti-shift doctrine); box-shadow also overrides hover's
		   lift on a selected row (specificity), keeping one signal.
		   Quieted 3px→2px (2026-10-18): with the open row carrying
		   bar+fill+chevron, selection is the transient signal and
		   must not compete with it */
		box-shadow: inset 0 2px 0 var(--sel-line);
	}
	/* the rank echo rides the pane's h2, quieter than the word it
	   follows; tabular so "3"/"20" widths don't jitter while paging */
	.rank-echo {
		opacity: 0.8;
		font-variant-numeric: tabular-nums;
	}

	/* ------------------------------------------------- workbench split */

	/* the page widens into the workbench the moment the split opens;
	   static mode (no pane, ever) keeps the 52rem reading column */
	main.wide {
		max-width: 76rem;
	}
	.bench {
		display: block;
	}
	.bench > * {
		min-width: 0; /* grid children must be allowed to wrap text */
	}
	/* stacked mode (viewports under 68rem, ): the pane rides
	   below the list with the classic citation rhythm — and its text
	   carries no cap (see .citation .text below), so the page is the
	   one scroller */
	.bench.split .citation {
		margin-top: 1.8rem;
	}
	@media (min-width: 68rem) {
		.bench.split {
			display: grid;
			grid-template-columns: minmax(0, 1.18fr) minmax(0, 0.82fr);
			gap: 1.8rem;
			align-items: start;
		}
		/* the split's master column runs wide enough that a
		   full-width excerpt line exceeds the comfortable reading
		   measure — capped at ~70ch (serif), the classic prose band.
		   Stacked keeps the column's natural width: the 52rem canvas
		   is already inside the measure. */
		.bench.split .excerpt {
			max-width: 70ch;
		}
		.bench.split .citation {
			position: sticky;
			top: 1.25rem;
			margin-top: 0;
			max-height: calc(100vh - 2.5rem);
			max-height: calc(100dvh - 2.5rem); /* mobile-browser honest */
			overflow: auto;
		}
	}

	/* the pane's pre-selection state: same card, quiet prompt */
	.ph .ph-body {
		padding: 1.5rem 1rem 1.7rem;
		min-height: 9rem;
	}
	.ph-tick {
		display: block;
		width: 0.55rem;
		height: 0.55rem;
		background: var(--plasma);
		transform: rotate(45deg);
		margin: 0 0 0.9rem 0.1rem;
	}
	.ph-body p {
		margin: 0;
		max-width: 24rem;
		font-family: var(--font-serif);
		font-size: 0.95rem;
		line-height: 1.6;
		color: var(--text-2);
	}

	/* ---------------------------------------------------- zero result */

	.empty {
		margin-top: 1.2rem;
		padding: 1rem 1.2rem 1.1rem;
		border: 1px solid var(--line);
		border-left: 3px solid var(--accent);
		border-radius: var(--r-3);
		background: var(--surface);
	}
	.empty-head {
		margin: 0 0 0.55rem;
		font-family: var(--font-serif);
		font-size: 1.02rem;
		color: var(--text);
	}
	/* the zero-hit boundary's grounded recovery — the
	   did-you-mean word and the completion list read as ACTIONS (the
	   .ck family's button voice), each word followed by its exact
	   count in the muted meta color */
	.dym {
		margin: 0 0 0.45rem;
		font-family: var(--font-serif);
		font-size: 1.02rem;
		color: var(--text);
	}
	.dym-word {
		font-family: var(--font-mono);
		font-size: 0.95rem;
		font-weight: 600;
		color: var(--text);
		background: none;
		border: 1px solid var(--line-strong);
		border-radius: var(--r-1);
		padding: 0.08rem 0.45rem;
		cursor: pointer;
	}
	.dym-word:hover {
		background: var(--surface);
	}
	.comp-words-label {
		margin: 0 0 0.3rem;
		font-family: var(--font-mono);
		font-size: 0.72rem;
		letter-spacing: 0.06em;
		text-transform: uppercase;
		color: var(--text-2);
	}
	ul.comp-words {
		margin: 0 0 0.7rem;
		padding: 0;
		list-style: none;
		display: flex;
		flex-wrap: wrap;
		gap: 0.4rem;
	}
	.comp-words button {
		font-family: var(--font-mono);
		font-size: 0.8rem;
		color: var(--text);
		background: none;
		border: 1px solid var(--line-strong);
		border-radius: var(--r-1);
		padding: 0.1rem 0.45rem;
		cursor: pointer;
	}
	.comp-words button:hover {
		background: var(--surface);
	}
	.comp-words .n {
		color: var(--text-2);
		margin-left: 0.25rem;
	}
	/* (b): the recovery card's tier divider — side-by-side words
	   lead, same-chunk words follow; a full-width row inside the chip
	   flex so the two tiers never share a line */
	.comp-sub {
		flex-basis: 100%;
		margin: 0.1rem 0 0.15rem;
		font-family: var(--font-mono);
		font-size: 0.68rem;
		letter-spacing: 0.06em;
		text-transform: uppercase;
		color: var(--text-2);
	}
	.empty ul {
		margin: 0;
		padding-left: 1.1rem;
		display: grid;
		gap: 0.32rem;
		font-size: 0.88rem;
		color: var(--text-2);
	}
	.empty code {
		font-family: var(--font-mono);
		font-size: 0.8rem;
		color: var(--text);
		background: var(--surface-2);
		border-radius: var(--r-1);
		padding: 0.05rem 0.35rem;
	}
	.results {
		list-style: none;
		padding: 0;
		margin: 1rem 0 0;
	}
	.results li + li {
		margin-top: 0.6rem;
	}
	.hit {
		display: flex;
		flex-direction: column;
		gap: 0.2rem;
		width: 100%;
		padding: 0.85rem 1rem 0.9rem;
		border: 1px solid var(--line);
		border-left: 4px solid transparent;
		border-radius: var(--r-3);
		text-align: left;
		text-decoration: none;
		color: inherit;
		background: var(--surface);
		font: inherit;
		cursor: pointer;
		/* the api row's stretched primary action (a.hit-open)
		   is positioned against this box; position: relative on an
		   otherwise-static card is a no-op visually */
		position: relative;
		transition: border-color 0.15s ease, box-shadow 0.15s ease,
			transform 0.15s ease;
	}
	/* the stretched link — the api row's whole-card primary
	   action.  It carries no content (the card beneath it is the
	   content); its accessible name comes from aria-label, its focus
	   ring from the global :focus-visible, its hover lift from
	   .hit:hover (it is a child of the card the pointer is inside).
	   Positioned elements paint above in-flow content, so the card
	   clicks through to it — and a.source re-positions above IT. */
	.hit-open {
		position: absolute;
		inset: 0;
		border-radius: var(--r-3);
	}
	/* regression fix (2026-09-26): the api row became a DIV
	   (the stretched a.hit-open pattern above) — BUTTONS get
	   border-box from the UA stylesheet, divs and li do not, so
	   width:100% + 2rem padding + 4px border painted ~36px past the
	   grid column and the cards slid under the citation pane in
	   split (measured live: card right 828 vs pane left 821).
	   Scoped BY TAG so the static face is untouched: div.hit = the
	   api real rows, main.wide li.hit = the api skeletons (main.wide
	   rides splitOn — running, searched, cite or specimen — which
	   static never satisfies); the frozen static a.hit keeps its
	   content-box geometry, where the same paint bled into empty
	   margin and no neighbor ever sat. */
	div.hit,
	main.wide li.hit {
		box-sizing: border-box;
	}
	/* hover lifts and firms the border ONLY — the left slot
	   stays transparent (the bar is exclusively open's signal, never
	   hover's), so a hovered card can never masquerade as chosen */
	.hit:hover {
		border-color: var(--line-strong);
		box-shadow: 0 4px 18px color-mix(in srgb, var(--ink) 14%, transparent);
	}
	.rowhead {
		display: flex;
		align-items: baseline;
		gap: 0.5rem;
		flex-wrap: wrap;
	}
	.badge {
		font-family: var(--font-mono);
		font-size: 0.66rem;
		font-weight: 600;
		letter-spacing: 0.07em;
		text-transform: uppercase;
		padding: 0.12rem 0.5rem;
		border-radius: var(--r-1);
		background: var(--plasma);
		color: var(--ink);
		white-space: nowrap;
	}
	/* the contents-row badge — a DATA label, not a state, so
	   it takes the quiet machine-chip family (the palette .ck look:
	   --text-2 on --surface, hairline border) and never amber — amber
	   stays with matches and the active filter (the ruling) */
	.tocbadge {
		font-family: var(--font-mono);
		font-size: 0.62rem;
		font-weight: 600;
		letter-spacing: 0.09em;
		text-transform: uppercase;
		color: var(--text-2);
		border: 1px solid var(--line-strong);
		border-radius: var(--r-1);
		padding: 0.08rem 0.4rem;
		white-space: nowrap;
	}
	/* the completion tier's visual system — one labeled divider
	   opens the tier, rows below it dim to suggestion weight, and the
	   per-row badge reuses the tocbadge voice so the two row-level
	   annotations read as one family */
	.combadge {
		font-family: var(--font-mono);
		font-size: 0.62rem;
		font-weight: 600;
		letter-spacing: 0.09em;
		text-transform: uppercase;
		color: var(--text-2);
		border: 1px dashed var(--line-strong);
		border-radius: var(--r-1);
		padding: 0.08rem 0.4rem;
		white-space: nowrap;
	}
	.comp-divider {
		list-style: none;
		margin: 0.6rem 0 0.2rem;
		padding-top: 0.55rem;
		border-top: 1px solid var(--line);
		font-family: var(--font-mono);
		font-size: 0.68rem;
		letter-spacing: 0.06em;
		text-transform: uppercase;
		color: var(--text-2);
	}
	ol.results li.completion {
		opacity: 0.72;
	}
	/* the corpus provenance line + repository modal — the line
   rides under the tagline in the header's meta voice; the modal
   reuses the cmdk overlay chrome with repo rows in the instrument's
   mono register (name, commit, count — the link is the whole row) */
.corpus-line {
	margin: 0.45rem 0 0;
	padding: 0.2rem 0.55rem;
	font-family: var(--font-mono);
	font-size: 0.72rem;
	letter-spacing: 0.04em;
	color: var(--text-2);
	background: none;
	border: 1px solid var(--line-strong);
	border-radius: var(--r-1);
	cursor: pointer;
}
.corpus-line:hover {
	color: var(--text);
	background: var(--surface);
}
/* the chip's verdict faces: green = verified fresh, red = shifted or
   a failed rebuild, yellow = the corpus cannot be found.  The edge
   is the signal, the appended text is its name — the color is never
   the only carrier.  The --fresh/--stale pair clears the 3:1
   non-text floor in both themes (the --danger pair's discipline) */
.corpus-line.v-current {
	border-color: var(--fresh);
}
.corpus-line.v-drifted,
.corpus-line.v-failed {
	border-color: var(--danger);
}
.corpus-line.v-notfound {
	border-color: var(--stale);
}
/* the running rebuild: a STATIC accent edge replaces every verdict
   edge (zero infinite animations: the class that animated
   this state is dead; the chip's own ticking elapsed text is the
   aliveness signal, readable with the modal closed too) */
.corpus-line.v-indexing {
	border-color: var(--accent);
	color: var(--text);
}
.corpus-rule {
	margin: 0.55rem 1.1rem 0.4rem;
	font-size: 0.72rem;
	line-height: 1.45;
	color: var(--text-2);
	border-top: 1px solid var(--line);
	padding-top: 0.5rem;
}
.corpus-modal {
	position: relative; /* the confirm layer anchors to the modal */
	max-width: 34rem;
	padding: 0;
	/* the corpus list is tall (15+ rows): cap the card inside the
	   viewport (the card sits at top: 16vh — 84vh minus a 2rem
	   breathing margin) and let the ROWS scroll; head, band and
	   footer stay pinned.  The palette keeps its own shape. */
	max-height: calc(84vh - 2rem);
	max-height: calc(84dvh - 2rem); /* mobile-browser honest */
	display: flex;
	flex-direction: column;
}
.corpus-head {
	padding: 0.9rem 1.1rem 0.6rem;
	border-bottom: 1px solid var(--line);
}
.corpus-title {
	margin: 0;
	font-family: var(--font-serif);
	font-size: 1.05rem;
	color: var(--text);
}
.corpus-built {
	margin: 0.25rem 0 0;
	font-family: var(--font-mono);
	font-size: 0.74rem;
	color: var(--text-2);
}
.corpus-repos {
	margin: 0;
	padding: 0.4rem 0;
	list-style: none;
	/* the scrollable middle of the capped card */
	flex: 1 1 auto;
	min-height: 0;
	overflow-y: auto;
}
.corpus-repos a,
.cr-row-synth {
	display: flex;
	gap: 0.8rem;
	align-items: baseline;
	padding: 0.42rem 1.1rem;
	color: var(--text);
	text-decoration: none;
	font-family: var(--font-mono);
	font-size: 0.8rem;
}
.corpus-repos a:hover {
	background: var(--surface);
}
.corpus-repos li.child {
	padding-left: 2.2rem;
}
.cr-name {
	flex: 1 1 auto;
	overflow-wrap: anywhere;
}
.cr-commit {
	color: var(--text-2);
	white-space: nowrap;
}
.cr-chunks {
	color: var(--text-2);
	white-space: nowrap;
}
/* the row chip: current / carried / drifted, one quiet mono
   tag per row at the row's own end.  Drifted carries the evidence
   count; carried reads informational (dashed edge — it is a state,
   not a warning); current is the quietest. */
.cr-chip {
	flex: 0 0 auto;
	padding: 0.05rem 0.4rem;
	border: 1px solid var(--line);
	border-radius: var(--r-1);
	font-size: 0.68rem;
	letter-spacing: 0.02em;
	color: var(--text-2);
	white-space: nowrap;
}
.cr-chip.carried {
	/* owner ruling 2026-11-01: carried reads AMBER — the middle rung
	   of the epistemic ladder (current = verified fresh, carried =
	   live but unverifiable, drifted = action needed).  The amber
	   wash + ink-grade text pair (mark-bg/mark-text) brings
	   theme-correct contrast in both light and dark; the dashed
	   edge stays as the second signal.  Amber was reserved for
	   matches — this ruling extends the family to the staleness
	   chips (a different component; they never share a screen) */
	border-style: dashed;
	border-color: var(--mark-text);
	background: var(--mark-bg);
	color: var(--mark-text);
}
.cr-chip.drifted {
	border-color: var(--danger);
	color: var(--danger);
}
/* the freshness band — under the head, above the rows; one quiet
   strip that explains its own state, and the ONLY home of the
   reindex control (an absent control is explained by the band's
   text — never a disabled button, never a tooltip) */
.corpus-band {
	padding: 0.55rem 1.1rem;
	border-bottom: 1px solid var(--line);
	font-family: var(--font-mono);
	font-size: 0.74rem;
	color: var(--text-2);
}
.corpus-band.drifted {
	border-left: 3px solid var(--danger);
	padding-left: calc(1.1rem - 3px);
}
/* the absent (yellow) story: the corpus the index was built from is
   gone — both decay shapes, one edge */
.corpus-band.absent {
	border-left: 3px solid var(--stale);
	padding-left: calc(1.1rem - 3px);
}
.band-line {
	margin: 0;
}
.band-line.quiet {
	opacity: 0.75;
}
.band-line.refusal,
.band-line.failure {
	color: var(--danger);
}
.band-line.done {
	color: var(--text);
}
.band-evidence {
	margin: 0.4rem 0 0;
	padding: 0 0 0 1rem;
	max-height: 8.5rem;
	overflow-y: auto;
	font-size: 0.7rem;
	overflow-wrap: anywhere;
}
.band-evidence li {
	margin: 0.08rem 0;
}
.band-carried {
	margin: 0.4rem 0 0;
	overflow-wrap: anywhere;
}
/* the statement and the control that qualifies it share a line
   (the force button sits BESIDE "corpus unchanged", never under
   it); narrow screens wrap the button under rather than clip */
.band-row {
	display: flex;
	align-items: center;
	gap: 0.8rem;
	flex-wrap: wrap;
}
.band-row .band-line {
	margin: 0;
	flex: 1 1 auto;
}
.band-row .band-reindex {
	margin: 0;
	flex: 0 0 auto;
}
.band-reindex {
	margin: 0.6rem 0 0;
	padding: 0.32rem 0.8rem;
	border: 1px solid var(--danger);
	border-radius: var(--r-2);
	background: none;
	color: var(--danger);
	font-family: var(--font-mono);
	font-size: 0.74rem;
	cursor: pointer;
}
.band-reindex:hover {
	background: var(--surface);
}
/* the evidence-carrying confirmation — a second layer
   inside the modal; Esc cancels IT, never the modal behind it */
.confirm-veil {
	position: absolute;
	inset: 0;
	background: color-mix(in srgb, var(--bg) 72%, transparent);
	border-radius: var(--r-3); /* matches the dialog card it covers */
}
.confirm-card {
	/* vertically CENTERED over the modal (owner ruling: bottom-
	   anchoring read as strange) — full-width minus the modal's
	   gutters, capped so a long fact list scrolls inside the card */
	position: absolute;
	top: 50%;
	left: 1.1rem;
	right: 1.1rem;
	transform: translateY(-50%);
	max-height: calc(100% - 2.2rem);
	overflow-y: auto;
	padding: 0.9rem 1rem 0.9rem;
	border: 1px solid var(--danger);
	border-radius: var(--r-3);
	background: var(--bg);
	font-family: var(--font-mono);
}
.confirm-title {
	margin: 0 0 0.5rem;
	font-family: var(--font-serif);
	font-size: 0.98rem;
	color: var(--text);
}
.confirm-facts {
	margin: 0;
	padding: 0 0 0 1.1rem;
	font-size: 0.72rem;
	color: var(--text-2);
}
.confirm-facts li {
	margin: 0.22rem 0;
	overflow-wrap: anywhere;
}
.confirm-actions {
	display: flex;
	gap: 0.6rem;
	margin-top: 0.7rem;
}
/* the live-frame modal: the CLI display verbatim, monospace.  A
   VIEWPORT-LEVEL dialog, not a layer inside the corpus modal: the
   72-column frame needs more width than the modal's gutters allow
   (no sideways scrolling), and the card must not clip against the
   modal's own scroll box */
.progress-veil {
	position: fixed;
	inset: 0;
	z-index: 50;
	background: color-mix(in srgb, var(--bg) 72%, transparent);
}
.progress-card {
	position: fixed;
	z-index: 51;
	top: 50%;
	left: 50%;
	transform: translate(-50%, -50%);
	width: min(46rem, calc(100vw - 3rem));
	max-height: min(85vh, 40rem);
	display: flex;
	flex-direction: column;
	padding: 0.9rem 1rem 0.9rem;
	border: 1px solid var(--line-strong);
	border-radius: var(--r-3);
	background: var(--bg);
	font-family: var(--font-mono);
}
.progress-note {
	margin: 0 0 0.6rem;
	font-size: 0.72rem;
	line-height: 1.45;
	color: var(--text-2);
}
.progress-frame {
	flex: 1 1 auto;
	min-height: 7rem;
	overflow: auto;
	margin: 0 0 0.5rem;
	padding: 0.55rem 0.7rem;
	background: var(--surface-2);
	border: 1px solid var(--line);
	border-radius: var(--r-2);
	font-family: var(--font-mono);
	font-size: 0.72rem;
	line-height: 1.45;
	white-space: pre;
	color: var(--text);
}
/* the frame's own per-line spans (.fl, keyed per index in the
   template) need no styling, they inherit the pre and update in
   place; the modal's elapsed is the frame's own global line — no
   title-side clock (removed as redundant, owner 2026-11-11; the
   client-side ticker serves the closed chip only) */
.confirm-go {
	padding: 0.34rem 0.9rem;
	border: none;
	border-radius: var(--r-2);
	background: var(--button-bg);
	color: var(--button-fg);
	font-family: var(--font-mono);
	font-size: 0.74rem;
	cursor: pointer;
}
.confirm-stop {
	padding: 0.34rem 0.9rem;
	border: 1px solid var(--line);
	border-radius: var(--r-2);
	background: none;
	color: var(--text-2);
	font-family: var(--font-mono);
	font-size: 0.74rem;
	cursor: pointer;
}
.confirm-stop:hover {
	background: var(--surface);
}
.meta .sugg {
		color: var(--text-2);
	}
	/* the ×n count riding the first source of a folded run —
	   same quiet readout register as .page (mono, --text-2), tight to
	   the source it qualifies */
	.srun {
		font-family: var(--font-mono);
		font-size: 0.7rem;
		color: var(--text-2);
		white-space: nowrap;
	}
	/* the "path · p. 48" separator — decorative (aria-hidden
	   in the markup), same mono register as what it separates */
	.pgsep {
		font-family: var(--font-mono);
		font-size: 0.74rem;
		color: var(--text-2);
		white-space: nowrap;
	}
	/* paths break AFTER slashes (the wbr the srcpath snippet
	   plants), never mid-extension — break-all could split a filename
	   anywhere ("Report.p/df"); break-word wraps a monster segment
	   only as the last resort before horizontal scroll */
	.source {
		font-family: var(--font-mono);
		font-size: 0.82rem;
		color: var(--text);
		overflow-wrap: break-word;
	}
	/* the source path as a LINK (api mode, iff the data
	   module computed a URL — the synthetic b2mn.dat source and the
	   whole static face keep the plain span above).  The path keeps
	   its data styling; the hairline underline is the affordance, so
	   a folded run of paths never reads as underlined prose.  Hover
	   firms to the app's link accent (NOT amber — that stays with
	   matches and the active filter).  position + z-index lift it
	   above the row's stretched link: this anchor goes to GitHub,
	   not to the citation. */
	a.source {
		position: relative;
		z-index: 1;
		text-decoration-line: underline;
		text-decoration-thickness: 1px;
		text-underline-offset: 3px;
		text-decoration-color: var(--line-strong);
	}
	a.source:hover {
		color: var(--accent);
		text-decoration-color: var(--accent);
	}
	.section {
		font-family: var(--font-serif);
		font-style: italic;
		font-size: 0.95rem;
		color: var(--text-2);
	}
	/* api mode rides the page INLINE on the rowhead (after a
	   · separator); static keeps it as the card's own meta line — the
	   rule serves both, nowrap so the inline ride never folds "p. 48"
	   mid-value (a static own-line span never needed it, never misses
	   it) */
	.page {
		font-family: var(--font-mono);
		font-size: 0.74rem;
		color: var(--text-2);
		white-space: nowrap;
	}
	.excerpt {
		font-family: var(--font-serif);
		font-size: 0.98rem;
		line-height: 1.65;
		color: var(--text);
		margin-top: 0.15rem;
	}

	/* ------------------------------------------------- show more) */
	/* the paging control: a quiet mono key in the .mstep family,
	   centered under the list; wide enough that its loading label
	   causes no shift, and a 44px touch target from the start */
	.morebar {
		display: flex;
		justify-content: center;
		margin-top: 0.9rem;
	}
	.morebtn {
		min-width: 11ch;
		min-height: 44px;
		padding: 0 1.4rem;
		font-family: var(--font-mono);
		font-size: 0.78rem;
		letter-spacing: 0.03em;
		color: var(--text);
		background: var(--surface);
		border: 1px solid var(--line-strong);
		border-radius: var(--r-2);
		cursor: pointer;
		transition: border-color 0.15s ease, background-color 0.15s ease;
	}
	.morebtn:hover:not(:disabled) {
		border-color: var(--plasma);
		background: color-mix(in srgb, var(--plasma) 10%, var(--surface));
	}
	.morebtn:focus-visible {
		outline: 2px solid var(--focus-ring);
		outline-offset: 2px;
	}
	.morebtn:disabled {
		opacity: 0.55;
		cursor: wait;
	}

	/* --------------------------------------------------------- citation */

	.citation {
		margin-top: 1.8rem;
		/* the pane wears the open row's mark — the same plasma edge
		   on both sides of the split says "these two are one object"
		   (2026-10-18 pairing pass) */
		box-shadow: inset 4px 0 0 var(--plasma);
		border: 1px solid var(--line);
		border-radius: var(--r-3);
		background: var(--surface);
		overflow: hidden;
	}
	.citation > * {
		padding-left: 1rem;
		padding-right: 1rem;
	}
	.citation h2 {
		margin: 0;
		padding: 0.65rem 1rem;
		font-size: 0.74rem;
		font-weight: 600;
		letter-spacing: 0.14em;
		text-transform: uppercase;
		color: var(--text-2);
		background: var(--surface-2);
		border-bottom: 1px solid var(--line);
		/* flex so the specimen chip rides the label row — a
		   single-text h2 renders exactly as before */
		display: flex;
		align-items: center;
		gap: 0.5rem;
	}
	/* the exhibit's label — the quiet machine-chip family
	   (.ck / .tocbadge): the pane IS a real citation; the chip says
	   why it shows before anything was asked */
	.spec-tag {
		font-family: var(--font-mono);
		font-size: 0.62rem;
		font-weight: 600;
		letter-spacing: 0.09em;
		text-transform: uppercase;
		color: var(--text-2);
		border: 1px solid var(--line-strong);
		border-radius: var(--r-1);
		padding: 0.08rem 0.4rem;
		white-space: nowrap;
	}
	.citation .rowhead {
		padding-top: 0.85rem;
	}
	.provenance {
		margin: 0.6rem 0 0;
		display: grid;
		grid-template-columns: minmax(6rem, auto) 1fr;
		gap: 0.25rem 1rem;
	}
	.provenance div {
		display: contents;
	}
	.provenance dt {
		font-family: var(--font-mono);
		font-size: 0.68rem;
		font-weight: 600;
		letter-spacing: 0.08em;
		text-transform: uppercase;
		color: var(--text-2);
		align-self: baseline;
		padding-top: 0.15rem;
	}
	.provenance dd {
		margin: 0;
		font-family: var(--font-mono);
		font-size: 0.84rem;
		color: var(--text);
		word-break: break-all;
	}
	/* the truncated id chip — a quiet mono key in the .copybtn
	   family (a bordered key reads as clickable here); the button's
	   title carries the full id on hover, the verify line below the
	   text keeps it visible for good */
	.provenance dd .idchip {
		font-family: var(--font-mono);
		font-size: 0.78rem;
		color: var(--text);
		background: var(--surface);
		border: 1px solid var(--line-strong);
		border-radius: var(--r-2);
		padding: 0.12rem 0.5rem;
		cursor: pointer;
		transition: border-color 0.15s ease, background-color 0.15s ease;
		/* anchor for the ::after touch band */
		position: relative;
	}
	/* touch floor: the id chip is a copy button too (21.8px
	   visual) — the 44px band extends into the deepnote corridor
	   below and the provenance rows above, all non-interactive text;
	   full-width (the chip is 130px wide), vertical only */
	.provenance dd .idchip::after {
		content: '';
		position: absolute;
		left: 0;
		right: 0;
		top: 50%;
		transform: translateY(-50%);
		height: 2.75rem;
	}
	.provenance dd .idchip:hover {
		border-color: var(--plasma);
	}
	.provenance dd .idchip:focus-visible {
		outline: 2px solid var(--focus-ring);
		outline-offset: 2px;
	}
	.provenance dd .idchip[data-copied] {
		border-color: var(--plasma);
		background: color-mix(in srgb, var(--plasma) 14%, var(--surface));
	}
	/* the honest dead-end note — where a source deep-link would
	   go, one line explains why there is none (the corpus's PDFs are
	   bundled); quiet secondary prose, the .why-note family */
	.deepnote {
		margin: 0.7rem 0 0;
		font-size: 0.74rem;
		color: var(--text-2);
	}
	/* -------------------------------------------------- why this result */

	.why {
		margin: 0.9rem 0 0;
		padding: 0.7rem 1rem 0.75rem;
		border: 1px solid var(--line);
		border-left: 3px solid var(--accent);
		border-radius: var(--r-2);
		background: var(--surface-2);
	}
	.why p {
		margin: 0;
	}
	.why-head {
		font-family: var(--font-mono);
		font-size: 0.68rem;
		font-weight: 600;
		letter-spacing: 0.14em;
		text-transform: uppercase;
		color: var(--accent);
	}
	.terms {
		display: flex;
		flex-wrap: wrap;
		gap: 0.35rem;
		margin: 0.5rem 0 0;
	}
	.term {
		display: inline-flex;
		align-items: baseline;
		gap: 0.3rem;
		padding: 0.14rem 0.55rem;
		border: 1px solid var(--line-strong);
		border-radius: var(--r-1);
		background: var(--surface);
		font-family: var(--font-mono);
		font-size: 0.78rem;
		white-space: nowrap;
	}
	.term .t {
		color: var(--text);
		font-weight: 600;
	}
	.term .n {
		color: var(--text-2);
		font-size: 0.7rem;
	}
	/* the frequency micro-bar — every track the SAME width so
	   fill lengths compare across chips at a glance (the ×n digit
	   verifies what the bar scans).  Fill --accent (this panel's own
	   rail color, ≥3:1 on the --surface-2 track in both themes —
	   computed in tests/test_polish_us021.py; amber stays exclusive to
	   matches and the active filter, the ruling). */
	.fbar {
		align-self: center;
		width: 2.4rem;
		height: 0.38rem;
		border-radius: var(--r-pill);
		background: var(--surface-2);
		overflow: hidden;
	}
	.ffill {
		display: block;
		height: 100%;
		border-radius: var(--r-pill);
		background: var(--accent);
	}
	.scoreline {
		margin: 0.55rem 0 0;
		font-family: var(--font-mono);
		font-size: 0.78rem;
		color: var(--text-2);
	}
	.scoreline .score {
		color: var(--text);
		font-weight: 600;
	}
	/* "lower is better" promoted out of the dimmest-text slot —
	   a bordered machine label in the .ck family (text color on
	   surface, never text-2), so the score's direction reads without
	   squinting */
	.scoreline .dir {
		margin-left: 0.45rem;
		padding: 0.1rem 0.42rem;
		border: 1px solid var(--line-strong);
		border-radius: var(--r-1);
		background: var(--surface);
		font-size: 0.62rem;
		font-weight: 600;
		letter-spacing: 0.08em;
		text-transform: uppercase;
		color: var(--text);
		white-space: nowrap;
	}
	.why-note {
		margin: 0.55rem 0 0;
		font-size: 0.74rem;
		color: var(--text-2);
	}
	/* the phrase-tier line shares the scoreline's voice (mono,
	   text-2) with the same bordered direction label — the two ranking
	   facts read as one system: tier first, score within the tier */
	.phraseline {
		margin: 0.55rem 0 0;
		font-family: var(--font-mono);
		font-size: 0.78rem;
		color: var(--text);
		font-weight: 600;
	}
	.phraseline .dir {
		margin-left: 0.45rem;
		padding: 0.1rem 0.42rem;
		border: 1px solid var(--line-strong);
		border-radius: var(--r-1);
		background: var(--surface);
		font-size: 0.62rem;
		font-weight: 600;
		letter-spacing: 0.08em;
		text-transform: uppercase;
		color: var(--text);
		white-space: nowrap;
	}
	/* the identity line rides the phraseline voice with one
	   distinction — it is the FIRST ranking fact, so the label chip
	   inverts (filled) to stand above the phrase line */
	.identityline .dir {
		background: var(--text);
		color: var(--surface);
		border-color: var(--text);
	}

	/* -------------------------------------------------- match navigator */

	.mnav {
		display: flex;
		align-items: center;
		gap: 0.55rem;
		margin: 0.85rem 1rem 0;
		font-family: var(--font-mono);
		font-size: 0.78rem;
		color: var(--text-2);
	}
	.mcount .mnum {
		color: var(--text);
		font-weight: 600;
	}
	/* the stepper: quiet mono keys, plasma when armed, clearly out at
	   the ends — a machine readout, not a decorative button */
	.mstep {
		display: inline-flex;
		align-items: center;
		justify-content: center;
		width: 1.55rem;
		height: 1.55rem;
		font-family: var(--font-mono);
		font-size: 1rem;
		line-height: 1;
		color: var(--text);
		background: var(--surface);
		border: 1px solid var(--line-strong);
		border-radius: var(--r-2);
		cursor: pointer;
		transition: border-color 0.15s ease, background-color 0.15s ease;
		/* anchor for the ::after touch square */
		position: relative;
	}
	/* touch floor, steppers FIRST (24.8px visual, the pane's
	   highest-frequency tap): each grows to an exact 44×44 hit square
	   while staying a 1.55rem visual key.  The square is biased
	   OUTWARD — ‹ extends left over the count readout's tail, › right
	   into the row's empty half — so the two squares never meet and
	   never steal each other's edge taps (the 8.8px gap between the
	   arrows stays neutral: an arrow aimed at is an arrow hit; a tap
	   exactly between them is no intent at all).  Keeping the pair
	   visually tight matters more than a symmetric band — proximity
	   is what reads as "one stepper". */
	.mstep::after {
		content: '';
		position: absolute;
		top: 50%;
		transform: translateY(-50%);
		width: 2.75rem;
		height: 2.75rem;
	}
	.mstep.mprev::after {
		right: 0;
	}
	.mstep.mnext::after {
		left: 0;
	}
	.mstep:hover:not(:disabled) {
		border-color: var(--plasma);
		background: color-mix(in srgb, var(--plasma) 12%, var(--surface));
	}
	.mstep:focus-visible {
		outline: 2px solid var(--focus-ring);
		outline-offset: 2px;
	}
	.mstep:disabled {
		opacity: 0.38;
		cursor: default;
	}

	/* ------------------------------------------------------- the marks */

	/* the SAME marker in light and dark: a translucent plasma wash
	   behind unchanged text color, so the base (AA-verified) contrast
	   carries over; the navigator's current match hardens to the
	   badge pair — full plasma behind ink.  :global because the marks
	   are planted by the text-node walk AFTER render — the template
	   never contains them (and Svelte would prune the selector). */
	.citation .text :global(mark) {
		background: color-mix(in srgb, var(--plasma) 26%, transparent);
		color: inherit;
		border-radius: var(--r-1);
		padding: 0 0.06em;
	}
	.citation .text :global(mark.active) {
		background: var(--plasma);
		color: var(--ink);
	}

	.citation .text {
		white-space: pre-wrap;
		/* no height cap and no inner scroll — below the 68rem
		   split the page is the only scroller (the old 24rem box was a
		   nested scroll trap on phones); at >=68rem the pane itself
		   scrolls.  break-word keeps a long unbroken token (a path, a
		   URL) from forcing horizontal scroll on the 375px face. */
		overflow-wrap: break-word;
		font-family: var(--font-serif);
		font-size: 0.95rem;
		line-height: 1.65;
		color: var(--text);
		background: var(--bg);
		border: 1px solid var(--line);
		border-radius: var(--r-2);
		padding: 0.9rem 1rem;
		margin: 0.9rem 1rem 0;
	}
	.citation .hint {
		padding-top: 0.9rem;
	}
	.citation .error {
		padding: 0.9rem 1rem 1rem;
		margin: 0;
	}
	/* ------------------------------------------- copy citation) */
	/* the two paste forms + their honest status line — quiet mono keys
	   in the .mstep family, the copied state hardens to plasma */
	.cite-actions {
		display: flex;
		align-items: center;
		flex-wrap: wrap;
		gap: 0.5rem;
		margin: 0.85rem 0 0;
	}
	.copystatus {
		font-family: var(--font-mono);
		font-size: 0.72rem;
		color: var(--text-2);
	}
	.copybtn {
		padding: 0.3rem 0.75rem;
		font-family: var(--font-mono);
		font-size: 0.74rem;
		letter-spacing: 0.02em;
		color: var(--text);
		background: var(--surface);
		border: 1px solid var(--line-strong);
		border-radius: var(--r-2);
		cursor: pointer;
		transition: border-color 0.15s ease, background-color 0.15s ease;
		/* anchor for the ::after touch band */
		position: relative;
	}
	/* touch floor: the 44px band, same construction as the
	   cluster chips — vertical only (both buttons are 121px+ wide),
	   so the 0.5rem between them stays unclaimed */
	.copybtn::after {
		content: '';
		position: absolute;
		left: 0;
		right: 0;
		top: 50%;
		transform: translateY(-50%);
		height: 2.75rem;
	}
	.copybtn:hover {
		border-color: var(--plasma);
	}
	.copybtn:focus-visible {
		outline: 2px solid var(--focus-ring);
		outline-offset: 2px;
	}
	.copybtn[data-copied] {
		border-color: var(--plasma);
		background: color-mix(in srgb, var(--plasma) 14%, var(--surface));
	}

	.verify {
		margin: 0.8rem 0 1rem;
		color: var(--text-2);
		font-family: var(--font-mono);
		font-size: 0.78rem;
	}
	.verify code {
		background: var(--surface-2);
		border-radius: var(--r-1);
		padding: 0.1rem 0.4rem;
	}

	/* -------------------------------------------- catalog cross-ref) */
	/* Muted by the 2026-09-26 design-audit ruling: BELOW the citation
	   body, separated by a hairline — never a card (the why-panel owns
	   that register), quiet enough to read as a footnote to the
	   citation.  Zero states are one honest line each, no curated
	   examples.  All colors ride existing tokens (text/text-2/line), so
	   both themes inherit their AA pairs unchanged. */
	.xruns {
		margin: 0.9rem 0 0;
		padding-top: 0.7rem;
		border-top: 1px solid var(--line);
	}
	.xruns p {
		margin: 0;
	}
	.xruns-head {
		font-family: var(--font-mono);
		font-size: 0.7rem;
		font-weight: 600;
		letter-spacing: 0.14em;
		text-transform: uppercase;
		color: var(--text-2);
	}
	/* two lines per run: the variant alone (it can be long — it wraps
	   anywhere rather than pushing the value off the pane), then family
	   left + value right, so values column-align to scan */
	.xruns-list {
		margin: 0.55rem 0 0;
		padding: 0;
		list-style: none;
		display: grid;
		gap: 0.45rem;
	}
	.xruns-list li {
		display: grid;
		grid-template-columns: minmax(0, 1fr) auto;
		gap: 0.1rem 0.7rem;
		font-family: var(--font-mono);
		font-size: 0.76rem;
	}
	.xr-variant {
		grid-column: 1 / -1;
		grid-row: 1;
		color: var(--text);
		overflow-wrap: anywhere;
	}
	.xr-family {
		grid-column: 1;
		grid-row: 2;
		color: var(--text-2);
		font-size: 0.68rem;
	}
	.xr-value {
		grid-column: 2;
		grid-row: 2;
		color: var(--text);
	}
	.xruns-note {
		margin: 0.55rem 0 0;
		font-size: 0.74rem;
		color: var(--text-2);
	}

	/* ---------------------------------------------------------- notice */

	.notice {
		margin-top: 1.6rem;
		padding: 1rem 1.2rem 1.1rem;
		border: 1px solid var(--line-strong);
		border-left: 3px solid var(--plasma);
		border-radius: var(--r-3);
		background: var(--surface);
	}
	.notice h2 {
		font-size: 1.05rem;
		margin: 0 0 0.5rem;
	}
	.notice p {
		margin: 0.4rem 0;
	}

	/* ------------------------------------------- command palette (⌘K) */

	/* the veil dims the page beneath; a click closes */
	.cmdk-veil {
		position: fixed;
		inset: 0;
		z-index: 40;
		background: color-mix(in srgb, var(--ink) 46%, transparent);
		/* the veil BLURS the page it dims — the depth cue that
		   makes the card read as floating above the workbench.  The
		   verify-or-drop check ran on the intranet-Chromium
		   proxy (measured). */
		-webkit-backdrop-filter: blur(8px);
		backdrop-filter: blur(8px);
	}
	/* the dialog: a top-anchored card, one column — input, list, live
	   count; the only tab stop inside is the combobox (the trap is in
	   the key handler, the veil swallows stray clicks) */
	.cmdk {
		position: fixed;
		top: 16vh;
		left: 50%;
		transform: translateX(-50%);
		z-index: 41;
		width: min(34rem, calc(100vw - 2.5rem));
		border: 1px solid var(--line-strong);
		border-radius: var(--r-3);
		background: var(--surface);
		/* two-layer shadow — a tight contact edge (the card
		   touching the veil) under the wide ambient cast.  The single
		   60px wash read as a flat sticker; the pair reads as lift. */
		box-shadow:
			0 2px 6px color-mix(in srgb, var(--ink) 20%, transparent),
			0 24px 60px color-mix(in srgb, var(--ink) 32%, transparent);
		overflow: hidden;
	}
	.cmdk input {
		display: block;
		width: 100%;
		box-sizing: border-box;
		height: 3.2rem;
		/* the right padding reserves the glyph's lane so typed
		   text never runs under the ⌘K keycap */
		padding: 0 3.6rem 0 1.1rem;
		font-family: var(--font-ui);
		font-size: 1.02rem;
		color: var(--text);
		background: transparent;
		border: none;
		border-bottom: 1px solid var(--line);
		border-radius: 0;
	}
	/* the input row's tail glyph — vertically centered in the
	   3.2rem input row, never a click target (the input owns the row) */
	.cmdk-glyph {
		position: absolute;
		top: 1rem;
		right: 1.1rem;
		pointer-events: none;
	}
	.cmdk input:focus-visible {
		outline: 2px solid var(--focus-ring);
		outline-offset: -2px;
	}
	.cmdk input::placeholder {
		color: color-mix(in srgb, var(--text) 50%, var(--surface));
	}
	#cmdk-list {
		list-style: none;
		margin: 0;
		padding: 0.4rem;
		max-height: 18rem;
		overflow: auto;
	}
	#cmdk-list li {
		display: flex;
		align-items: baseline;
		gap: 0.6rem;
		/* palette rows ABUT — there is no gap for a touch band
		   to claim, and an overlapping band would steal the neighbor
		   row's edge taps (a menu row that fires the row above is a
		   mis-hit).  So the row itself grows to the 44px floor:
		   0.66rem vertical padding over the ~23.6px content line =
		   ~44.7px per row — the standard command-palette row height
		   (Raycast, Linear), the one deliberate visual delta in this
		   story.  Horizontal padding and the baseline alignment are
		   untouched; the in-row rhythm reads exactly as before. */
		padding: 0.66rem 0.7rem;
		border-left: 3px solid transparent;
		border-radius: var(--r-2);
		cursor: pointer;
	}
	#cmdk-list li[data-selected] {
		/* the wash reads now — 20% plasma over surface, up from
		   the invisible 8%.  COMPUTED (tests/test_palette_us018.py
		   re-derives these from the CSS): vs the unselected row, light
		   1.117:1 / dark 1.424:1 (was 1.042/1.145); against the 46%
		   veiled page behind, dark 2.80:1 (the row jumps forward off
		   the veil); label text on the fill 13.8:1 / 5.4:1, AA held. */
		background: color-mix(in srgb, var(--plasma) 20%, var(--surface));
		border-left-color: var(--plasma);
	}
	/* the kind chip — mono, uppercase, a machine label; the label row
	   itself is UI text, the hint a mono readout */
	.ck {
		flex: none;
		font-family: var(--font-mono);
		font-size: 0.62rem;
		font-weight: 600;
		letter-spacing: 0.09em;
		text-transform: uppercase;
		color: var(--text-2);
		border: 1px solid var(--line-strong);
		border-radius: var(--r-1);
		padding: 0.08rem 0.4rem;
	}
	/* the run's continuation rows hold the chip's column with
	   nothing in it — one CLUSTER names the run, the rest align to it */
	.ck.ghost {
		visibility: hidden;
	}
	li[data-selected] .ck {
		color: var(--text);
		border-color: var(--plasma);
	}
	.cl {
		flex: 1;
		min-width: 0;
		font-size: 0.94rem;
		color: var(--text);
		white-space: nowrap;
		overflow: hidden;
		text-overflow: ellipsis;
	}
	.ch {
		flex: none;
		font-family: var(--font-mono);
		font-size: 0.72rem;
		color: var(--text-2);
		/* counts hold their column — already true in a mono
		   face, pinned here so a font swap can't quietly regress it */
		font-variant-numeric: tabular-nums;
	}
	.cmdk-none {
		margin: 0;
		padding: 0.95rem 1.1rem 1.05rem;
		font-size: 0.9rem;
		color: var(--text-2);
	}
	/* the legend strip — the dialog's machined base, an inset
	   band (surface-2 is the system's below-the-card step) under a
	   hairline; the row's own keys as keycaps (the family,
	   surface fill so the keys LIFT off the inset band) */
	.cmdk-foot {
		padding: 0.55rem 1.1rem;
		border-top: 1px solid var(--line);
		background: var(--surface-2);
		font-size: 0.78rem;
		color: var(--text-2);
	}
	.cmdk-foot kbd,
	.cmdk-glyph kbd {
		font-family: var(--font-mono);
		font-size: 0.66rem;
		padding: 0.09rem 0.34rem;
		margin-right: 0.18rem;
		border: 1px solid var(--line-strong);
		border-bottom-width: 2px;
		border-radius: var(--r-1);
		background: var(--surface);
		color: var(--text);
		white-space: nowrap;
	}
	/* the screen-reader-only live region (the palette's N-commands
	   announcement) */
	.sr-only {
		position: absolute;
		width: 1px;
		height: 1px;
		margin: -1px;
		padding: 0;
		border: 0;
		clip: rect(0 0 0 0);
		clip-path: inset(50%);
		overflow: hidden;
		white-space: nowrap;
	}
	@media (prefers-reduced-motion: no-preference) {
		.cmdk {
			animation: cmdk-in 0.14s ease-out;
		}
		.cmdk-veil {
			animation: cmdk-fade 0.14s ease-out;
		}
	}
	@keyframes cmdk-in {
		from {
			opacity: 0;
			transform: translateX(-50%) translateY(-0.4rem);
		}
	}
	@keyframes cmdk-fade {
		from {
			opacity: 0;
		}
	}
</style>
