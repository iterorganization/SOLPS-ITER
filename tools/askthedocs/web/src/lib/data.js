//  the ONE data-access module of the askthedocs web client.
//
// "Deployment stays a decision, never a rewrite": every fetch the app
// makes lives here, behind two interchangeable backends selected at
// BUILD time by the ASKTHEDOCS_MODE flag (vite envPrefix, see
// web/vite.config.js):
//
// static (default) — the fragmented index: pagefind runtime +
//                      KB-scale fragments fetched lazily per query, rows
//                      enriched from each result's own citation page
//                      (provenance is deliberately NOT in the index).
// api — the FastAPI service: GET /search + GET
//                      /chunk/{id}, same store, same ranking, JSON.
//
// App code (+page.svelte) imports ONLY this module — no pagefind
// knowledge, no /search or /chunk URLs, no pages/ paths anywhere else.
// The citation destination is part of the same boundary:
// chunkHref() returns the static citation-page URL in static mode and
// null in api mode, where the app renders the chunk inline instead via
// getChunk().
//
// ASKTHEDOCS_API_BASE (build-time, default '' = same origin) relocates the
// service for split deployments; the default keeps the api-mode build
// same-origin (service serves the build, runbook).
//
// the api display path also repairs PDF-extraction
// artifacts (collapsed dot leaders, joined end-of-line hyphenation)
// via $lib/excerpt.js — imported and applied ONLY in the api
// functions below, so the static face's data path (and its frozen
// bytes) never sees the cleanup.
//
// the api path also carries each row's and chunk's
// source LINK ($lib/srclink.js — the per-repo GitHub base-URL map,
// build-time constant).  The link is DATA, exactly like
// matchedTerms: rows get the document-level URL, the pane's chunk
// adds the Fortran line anchor from its own text header.  The
// static face's data path never computes one — its rows render the
// plain path exactly as the frozen face always did.

import { cleanSnippet, joinSoftHyphens, unescapeMarkup } from './excerpt.js';
import { githubShowsRendered, sourceUrl } from './srclink.js';

export const MODE = import.meta.env.ASKTHEDOCS_MODE || 'static';

export const CITATION_VIEW = MODE === 'api' ? 'inline' : 'page';

const API_BASE = (import.meta.env.ASKTHEDOCS_API_BASE || '').replace(/\/+$/, '');

// ---------------------------------------------------------------- shared

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
// The API snippet marks hits with «…»; pagefind emits <mark> HTML built
// from our own escaped static pages.  Convert the former so both modes
// hand the page <mark>-HTML (escaped here — chunk text is data, never
// trusted markup).
function markify(snippet) {
	const esc = snippet
		.replaceAll('&', '&amp;')
		.replaceAll('<', '&lt;')
		.replaceAll('>', '&gt;');
	return esc.replaceAll('«', '<mark>').replaceAll('»', '</mark>');
}

// ---------------------------------------------------------------- static

// The pagefind module, loaded on FIRST query only (the lazy-load
// contract: first paint carries zero index bytes).
let pagefind = null;

async function loadPagefind() {
	if (!pagefind) {
		// ESM import leaves document.currentScript null, so the
		// runtime cannot self-locate — basePath is set explicitly
		// (verified against pagefind 1.5.2, ).
		const base = new URL('pagefind/', document.baseURI).href;
		const mod = new URL('pagefind/pagefind.js', document.baseURI).href;
		pagefind = await import(/* @vite-ignore */ mod);
		await pagefind.options({ basePath: base });
	}
	return pagefind;
}

// Provenance (source/section/page) is deliberately NOT in the index
//every meta placement leaks into content) — it is read
// from the result's own citation page, fetched lazily per row.
// `signal` lets a superseded search abort its enrichment
// fetches on the wire.
async function citationPage(chunkId, signal) {
	const url = new URL(`pages/${chunkId}.html`, document.baseURI);
	const res = await fetch(url, { signal });
	if (!res.ok) return null;
	return new DOMParser().parseFromString(await res.text(), 'text/html');
}

function citationValue(doc, cls) {
	return doc.querySelector(`header p.${cls}`)?.textContent.trim() ?? '';
}

async function staticSearch(query, limit, signal) {
	// The pagefind runtime takes no AbortSignal — the seq guard in
	// $lib/instant.js drops a superseded response — but the
	// per-row enrichment fetches below DO honor one.
	const pf = await loadPagefind();
	const search = await pf.search(query);
	const rows = await Promise.all(
		search.results.slice(0, limit).map(async (r) => {
			const data = await r.data(); // fetches this result's fragment
			const chunkId = data.url.split('/').pop().replace(/\.html$/, '');
			const clusters = data.filters?.cluster ?? [];
			const prov = await citationPage(chunkId, signal)
				.then((doc) =>
					doc
						? {
								source: citationValue(doc, 'source'),
								section: citationValue(doc, 'section'),
								page: citationValue(doc, 'page')
							}
						: {})
				.catch(() => ({}));
			return {
				chunkId,
				clusters,
				excerptHtml: data.excerpt ?? '',
				...prov
			};
		})
	);
	return { total: search.results.length, rows };
}

async function staticGetChunk(chunkId) {
	const doc = await citationPage(chunkId);
	if (!doc) return null;
	const cluster =
		doc.querySelector('header p.facets span[data-pagefind-filter="cluster"]')
			?.textContent.trim() ?? '';
	const text = [...doc.querySelectorAll('main .text p')]
		.map((p) => p.textContent)
		.join('\n');
	return {
		chunkId,
		source: citationValue(doc, 'source'),
		cluster,
		section: citationValue(doc, 'section'),
		page: citationValue(doc, 'page'),
		text
	};
}

// ------------------------------------------------------------------- api

async function apiSearch(query, limit, cluster, signal, typeahead) {
	// `cluster` is URL state — the drill-in filter the
	// chips set and the deep link restores.  URLSearchParams builds
	// and encodes the whole query string in one place. :
	// `typeahead` marks a TYPING state — the server keeps the exact
	// tier in committed order and appends flagged completion hits.
	const params = new URLSearchParams({ q: query, limit });
	if (cluster) params.set('cluster', cluster);
	if (typeahead) params.set('typeahead', '1');
	const res = await fetch(`${API_BASE}/search?${params}`, { signal });
	if (!res.ok) {
		// .status lets the instant-search controller tell a
		// mid-typing 4xx (FTS5 syntax) from a real failure (5xx/network).
		const err = new Error(`/search answered ${res.status}`);
		err.status = res.status;
		throw err;
	}
	const data = await res.json();
	return {
		total: data.total,
		// the completion tier's size (0 on committed searches) —
		// the count line renders "+ N suggestions" from it
		completionsTotal: data.completions_total ?? 0,
		// + : the zero-hit recovery card — corpus words
		// extending the unfinished last token that CO-OCCUR with the
		// rest of the query, each with its true click-yield count and
		// (of those) the side-by-side count; side-by-side words come
		// first.  When nothing combines, separateTerms carries the
		// (c) escape hatch: typed terms runnable alone.
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
		// facets surfaced for the chips): the FULL
		// per-cluster breakdown, computed server-side WITHOUT the
		// cluster filter — chips keep every count while one is active
		facets: (data.facets ?? []).map((f) => ({
			cluster: f.cluster,
			count: f.count
		})),
		rows: data.hits.map((h) => {
			// leader dots collapsed + hyphenation joined in
			// the DISPLAY copy; `toc` (leader-dot density on the RAW
			// snippet) badges contents rows in the list — never demotes.
			// rendered-view sources (GitHub renders the
			// type — rst/pdf) unescape markup escapes in the display
			// copy, so an excerpted phrase is Ctrl+F-findable where
			// its link lands; raw-view sources keep every byte.
			const v = cleanSnippet(h.snippet ?? '');
			const display = githubShowsRendered(h.source)
				? unescapeMarkup(v.text)
				: v.text;
			return {
				chunkId: h.chunk_id,
				clusters: h.cluster ? [h.cluster] : [],
				excerptHtml: markify(display),
				toc: v.toc,
				source: h.source,
				section: h.section ?? '',
				page: h.page != null ? `p. ${h.page}` : '',
				matchedTerms: h.matched_terms ?? [],
				score: h.score ?? null,
				// the implicit phrase tier's per-hit marker —
				// true only when the query was plain multi-term AND
				// this chunk carries its tokens as one adjacent
				// phrase (the hits that rank first).  Strict compare:
				// a face without the field reports false, never
				// undefined rendering as truthy
				phraseHit: h.phrase_hit === true,
				// the identity tier's per-hit marker — true
				// exactly when this chunk's citation name IS the
				// query (trimmed, case-insensitive); such hits rank
				// first, above the phrase tier.  Same strict compare
				identity: h.identity === true,
				// completion-tier marker — the row renders dimmed
				// under a labeled divider and never counts as a hit.
				// Strict compare: a face without the field reports
				// false, never undefined-as-truthy
				completion: h.completion === true,
				// rows link at DOCUMENT level — the line
				// range lives in the chunk text the pane fetches
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
	// pane text joins end-of-line hyphenation — a
	// mid-word hard break is wrong at any pane width, and reuniting
	// "diver-\ntor" lets the highlight walk agree with the
	// server's matched-term counts.  Dot leaders are NOT collapsed
	// here: the pane is the verification surface, it shows the
	// chunk as the corpus holds it.
	// (owner ruling 2026-09-27, superseding the
	// as-the-corpus-holds-it stance for ESCAPES only): the pane text
	// is a Ctrl+F PROBE for where its link lands — GitHub RENDERS
	// rst/pdf sources, so their display text unescapes the markup
	// specials; .tex and code sources show as raw source there and
	// keep every byte (dot leaders still keep — those are content).
	const text = githubShowsRendered(c.source)
		? unescapeMarkup(joinSoftHyphens(c.text))
		: joinSoftHyphens(c.text);
	return {
		chunkId: c.chunk_id,
		source: c.source,
		cluster: c.cluster,
		section: c.section ?? '',
		page: c.page != null ? `p. ${c.page}` : '',
		text,
		// the pane's link is the precision form — the
		// Fortran line anchor rides the chunk's own text header
		sourceUrl: sourceUrl(c.source, text)
	};
}

// ----------------------------------------------------------------- face

/** Ranked search.  Resolves to { total, facets, rows } — the row
 * shape above; `facets` (api mode only) is the
 *  per-cluster chip data [{cluster, count}], empty in static mode
 *  where no chips render.  Throws on backend failure (the page
 * surfaces the message). `cluster` restricts the api
 *  query to one cluster — static mode ignores it (its frozen face
 *  never sends one: the chips are api-mode UI).  `signal` aborts a superseded request on the wire — the api fetch
 *  honors it directly, static mode aborts its enrichment fetches and
 *  relies on the controller's seq guard. */
export async function searchChunks(query, { limit = 10, cluster, signal, typeahead } = {}) {
	if (MODE === 'api') return apiSearch(query, limit, cluster, signal, typeahead);
	return staticSearch(query, limit, signal);
}

/** One chunk in full: { chunkId, source, cluster, section, page, text }
 *  or null when unknown. */
/** the landing's corpus provenance — when this store was
 *  built and every repository it holds (name, pinned commit, chunk
 *  count).  API mode only; the static face (archived) never calls
 *  it and null means "line unavailable", rendered as absence. */
export async function fetchCorpus(signal) {
	if (MODE !== 'api') return null;
	const res = await fetch(`${API_BASE}/corpus`, { signal });
	if (!res.ok) return null;
	return res.json();
}

/** the staleness verdicts (GET /status): the per-leg chips the
 *  corpus modal renders beside its rows + the band's summary and
 *  drift evidence, and the chip's own verdict face.  DRIFT answers
 *  as HTTP 409 with the SAME body (the curl --fail gate), so both
 *  200 and 409 are verdicts; 503 is the named ABSENT answer (the
 *  corpus cannot be found — the detail prose names where setup
 *  stood and the way out); anything else is null, the quiet
 *  'freshness unknown' line.  Checked lazily on every page load and
 *  once per 24 h in a living tab, and re-checked on every modal
 *  open: no cached freshness going stale itself.  Api mode only. */
export async function fetchVerdicts(signal) {
	if (MODE !== 'api') return null;
	const res = await fetch(`${API_BASE}/status`, { signal });
	if (res.status === 200 || res.status === 409) {
		return { kind: 'verdicts', body: await res.json() };
	}
	if (res.status === 503) {
		let detail = `the staleness service answered ${res.status}`;
		try {
			const body = await res.json();
			if (body && body.detail) detail = body.detail;
		} catch { /* keep the status form */ }
		return { kind: 'absent', detail };
	}
	return null;
}

/** start the reindex job. Returns {ok, job} on the 202
 *  start, {ok: false, refusal} carrying the endpoint's named reason
 *  otherwise (nothing actionable / already running / no store).
 *  *force* starts a rebuild of a CURRENT index too (the fresh-index
 *  force path; the confirmation dialog carries the honesty, the
 *  gate lives in the endpoint).  Never throws — a refusal is data,
 *  rendered as the band's own text.  The 202 body's started_at is
 *  the elapsed clock's anchor — take it from THIS answer, never
 *  from a later observation (the started_at race). */
export async function startReindex(force = false) {
	if (MODE !== 'api') return { ok: false, refusal: 'static face' };
	const q = force ? '?force=true' : '';
	const res = await fetch(`${API_BASE}/reindex${q}`, { method: 'POST' });
	if (res.status === 202) return { ok: true, job: await res.json() };
	let refusal = `/reindex answered ${res.status}`;
	try {
		const body = await res.json();
		if (body && body.detail) refusal = body.detail;
	} catch { /* keep the status form */ }
	return { ok: false, refusal };
}

/** the reindex event stream (the push wire, GET /reindex/events,
 *  Server-Sent Events): ONE long-lived connection replaces the 2 s
 *  poll.  The handlers receive PARSED payloads; a malformed frame is
 *  dropped quietly (the stream is a bonus face, never a crash).
 *  - onSnapshot(job): on connect and on every job-slot transition
 *    into running — status 'idle' snapshots are the idle heartbeat
 *    and change nothing (handlers decide what a snapshot means);
 *  - onDelta({length, lines}): the frame's CHANGED display lines
 *    while a job runs (positional: lines[i] = text, then resize to
 *    length) — at most one per second by construction;
 *  - onTerminal(job): the single closing done/failed event with the
 *    summary and (when this connection earned it) the post-job
 *    freshness verdict under .verdict — after it the stream is
 *    CLOSED: close the EventSource in the handler, or the browser's
 *    auto-reconnect will fetch the idempotent terminal replay
 *    forever.  Returns the EventSource (null in static mode). */
export function openReindexEvents({ onSnapshot, onDelta, onTerminal } = {}) {
	if (MODE !== 'api' || typeof EventSource === 'undefined') return null;
	const es = new EventSource(`${API_BASE}/reindex/events`);
	for (const [name, fn] of [
		['snapshot', onSnapshot],
		['delta', onDelta],
		['done', onTerminal],
		['failed', onTerminal]
	]) {
		if (!fn) continue;
		es.addEventListener(name, (ev) => {
			try {
				fn(JSON.parse(ev.data));
			} catch { /* a malformed frame is noise, never a crash */ }
		});
	}
	return es;
}

export async function getChunk(chunkId) {
	if (MODE === 'api') return apiGetChunk(chunkId);
	return staticGetChunk(chunkId);
}

/** Citation destination for a hit: static mode → the prerendered
 *  citation page (a plain navigation); api mode → null, meaning the
 *  app renders the chunk inline from getChunk(). */
export function chunkHref(chunkId) {
	if (MODE === 'api') return null;
	return `pages/${chunkId}.html`;
}

// the catalog cross-reference: for a source_switch
// citation (whose section IS the switch name, the ruled join key),
// which cataloged runs set the switch, to what value.  The service
// reads the sibling catalog's switchsets.json artifact at REQUEST
// time — nothing about ../catalog is baked into the store or this
// build, so the repos stay independently buildable.  Answers
// { catalog: 'built'|'absent', runs: [{run, family, value}] } — both
// zero states are data (absent artifact ≠ no runs), rendered verbatim
// by the pane's panel.  Api mode only: the frozen static face has no
// service to ask and never renders a panel.
export async function getSwitchRuns(switchName) {
	if (MODE !== 'api') return null;
	const res = await fetch(`${API_BASE}/switchruns/${encodeURIComponent(switchName)}`);
	if (!res.ok) throw new Error(`/switchruns answered ${res.status}`);
	const d = await res.json();
	return {
		catalog: d.catalog,
		runs: (d.runs ?? []).map((r) => ({ run: r.run, family: r.family, value: r.value }))
	};
}

// the landing specimen: ONE real chunk exhibited in the
// citation pane before any search, so the product's identity (every
// claim carries its citation) is demonstrated, not claimed.
//
// The chunk is the Wiesen et al. 2015 JNM overview's title/abstract —
// the paper that introduced SOLPS-ITER, i.e. the corpus's own origin
// story.  The id is identity-addressed (sha1 of source+page+para —
// stable across rebuilds of the same corpus; a changed corpus 404s,
// loadSpecimen answers null, and the pane falls back to its quiet
// placeholder).  SPECIMEN_TERMS are the exhibit's marked words —
// single FTS5 tokens (hyphens split: 'solps' marks the SOLPS inside
// SOLPS-ITER), driven through the same whole-token walk the live
// pane uses.
//
// Api mode only: the static face is frozen at v1-static and never
// renders a specimen.
export const SPECIMEN_CHUNK_ID = '2c0a260adc8de2bd60ce692232260c76d7420dd3';
export const SPECIMEN_TERMS = ['solps', 'eirene'];

/** The landing exhibit, or null (api mode only; any failure is
 *  swallowed — a landing never renders an error it cannot fix). */
export async function loadSpecimen() {
	if (MODE !== 'api') return null;
	try {
		return await apiGetChunk(SPECIMEN_CHUNK_ID);
	} catch {
		return null;
	}
}

// the id-resolution ROW — one chunk opened straight by id
// (pasted into the box, the palette, or a ?chunk= deep link) renders
// in the master column as a result row, the same shape search rows
// take, so the workbench opens around it instead of an empty list
// beside a full pane.  Built HERE (the data boundary): the excerpt is
// escaped from the chunk's own text (the v1 excerpt discipline —
// corpus text is data, never markup).  Deliberately NO matchedTerms
// and NO score: an id resolution has no ranking story, and the
// why-this-result panel simply does not render for it.
export function syntheticRow(chunk) {
	if (!chunk) return null;
	const esc = String(chunk.text ?? '')
		.slice(0, 240)
		.replaceAll('&', '&amp;')
		.replaceAll('<', '&lt;')
		.replaceAll('>', '&gt;');
	return {
		chunkId: chunk.chunkId,
		clusters: chunk.cluster ? [chunk.cluster] : [],
		excerptHtml: esc,
		source: chunk.source,
		section: chunk.section ?? '',
		page: chunk.page ?? ''
	};
}
