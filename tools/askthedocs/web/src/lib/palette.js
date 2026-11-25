//  the ⌘K command palette: the command model.
//
// Framework-free on purpose (the instant.js / highlight.js / urlstate.js
// doctrine): the pure half — chunk-id detection (strict AND the 
// tolerant extractor), recent-query storage (behind an injected store so
// plain node can exercise it), command building/filtering, and the
// selection ring — lives here, while the page owns the DOM: the dialog,
// the ARIA combobox/listbox wiring, the focus trap, and the action
// handlers.  No DOM globals are touched in this module, so
// `node --input-type=module` imports it directly in
// tests/test_palette_us006.py and tests/test_paste_us023.py.
//
// THE COMMANDS are exactly the four the story accepts —
//
//   search   run the typed text as a query          (Enter on it fires)
//   chunk    open a pasted 40-hex chunk id          (paste → fetch)
//   cluster  filter the results to one cluster      (facet counts live)
//   recent   re-run a recent query                  (injected storage)
//
// "Sources" were considered and dropped: the service's search route
// has no source filter, and a command that merely queried the
// source's filename would be a fake action — the same honesty rule
// that keeps did-you-mean out (the no-fuzzy rule).  Nothing here invents a
// command the app cannot honor.

export const RECENTS_KEY = 'askthedocs.recent';
export const MAX_RECENTS = 6;
export const MAX_COMMANDS = 12;

// chunk ids are sha1 hex — 40 characters of [0-9a-f] (build.py formula)
export function isChunkId(text) {
	return /^[0-9a-f]{40}$/.test((text ?? '').trim().toLowerCase());
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
export function extractChunkId(text) {
	const m = (text ?? '').match(/\b[0-9a-fA-F]{40}\b/);
	return m ? m[0].toLowerCase() : null;
}

/** Recent queries from the injected storage — malformed data answers
 *  [] (never throws: a locked-down browser just loses recents, the
 *  palette still works).  `store` is the web storage interface
 *  (getItem/setItem); the page passes the real one, tests a fake. */
export function loadRecents(store) {
	try {
		const list = JSON.parse(store?.getItem?.(RECENTS_KEY) ?? '[]');
		if (!Array.isArray(list)) return [];
		return list
			.filter((q) => typeof q === 'string' && q.trim())
			.slice(0, MAX_RECENTS);
	} catch {
		return [];
	}
}

/** Record a committed query: dedupe (move to front), cap, persist via
 *  the injected storage (a failed write is silent — recents are a
 *  convenience, never a gate).  Returns the new list. */
export function pushRecent(store, query) {
	const q = (query ?? '').trim();
	if (!q) return loadRecents(store);
	const capped = [q, ...loadRecents(store).filter((x) => x !== q)].slice(
		0,
		MAX_RECENTS
	);
	try {
		store?.setItem?.(RECENTS_KEY, JSON.stringify(capped));
	} catch {
		// private-browsing storage quota — keep the in-memory list
	}
	return capped;
}

/** The command list for the current input.  Order is intent-first:
 *  the typed actions (chunk paste, then run-query), then matching
 *  recents, then matching clusters (live facet counts when a search
 *  has run; none before — an honest empty, not a fake list).  An
 *  empty input lists recents then every cluster.  Labels are copy,
 *  not state: the active filter reads `hint: 'clear filter'`. */
export function buildCommands({ text = '', facets = [], cluster = '', recents = [] } = {}) {
	const t = (text ?? '').trim();
	const lower = t.toLowerCase();
	const matches = (s) => !lower || s.toLowerCase().includes(lower);
	const cmds = [];
	if (t) {
		if (isChunkId(t)) {
			cmds.push({
				kind: 'chunk',
				id: t.toLowerCase(),
				label: `Open chunk ${t.slice(0, 10)}…${t.slice(-6)}`,
				hint: 'paste → fetch'
			});
		}
		cmds.push({ kind: 'search', q: t, label: `Run “${t}”`, hint: 'bm25 search' });
	}
	for (const q of recents) {
		if (q.trim() === t) continue; // the run-query command already is it
		if (!matches(q)) continue;
		cmds.push({ kind: 'recent', q, label: q, hint: 'recent: run again' });
	}
	for (const f of facets) {
		if (!matches(f.cluster)) continue;
		cmds.push({
			kind: 'cluster',
			cluster: f.cluster,
			count: f.count,
			label: `Filter to ${f.cluster}`,
			// honest microcopy — a one-hit cluster says "1 hit"
			// (the .meta counter above the results pluralizes the same
			// way; the palette never misspeaks where it is watched)
			hint:
				cluster === f.cluster
					? 'clear filter'
					: `${f.count} ${f.count === 1 ? 'hit' : 'hits'}`
		});
	}
	return cmds.slice(0, MAX_COMMANDS);
}

/** The selection ring — the same wrap-around model the search box's
 *  ↑/↓ uses, so both lists answer identical keypresses identically. */
export function moveSel(sel, dir, len) {
	if (!len) return -1;
	if (sel < 0) return dir > 0 ? 0 : len - 1;
	return (sel + dir + len) % len;
}
