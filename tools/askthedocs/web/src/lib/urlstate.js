//  URL as state: the view codec for ?q=&cluster=&chunk=.
//
// Framework-free on purpose (the instant.js / highlight.js doctrine):
// the pure parse/serialize/compare half of deep links lives here where
// node can exercise it, while the page owns only the wiring — reading
// the address bar, writing history entries, listening for navigation.
// No DOM globals are touched in this module, so
// `node --input-type=module` imports it directly in
// tests/test_urlstate_us005.py.
//
// THE VIEW is exactly three parameters, nothing else:
//
//   q        the query text            (empty = no query)
//   cluster  the active cluster filter (empty = all clusters)
//   chunk    the chunk id in the pane  (empty = no citation open)
//
// Canonical form (what every history entry holds):
//   - params are written in q, cluster, chunk order
//   - empty values are OMITTED, values are trimmed
//   - a view with nothing set is the bare path — no '?'
//   - any other parameter in an incoming URL is ignored on read and
//     dropped on the next write: the URL is STATE, not a bag (a
//     pasted ?utm=… survives until the app's next history write, then
//     it is gone — deliberately, so what you copy is what restores)
//
// api-mode only: the static face is frozen at v1-static and never
// reads or writes these parameters (the page gates every call).

export function readView(search) {
	const p = new URLSearchParams(typeof search === 'string' ? search : '');
	return {
		q: (p.get('q') ?? '').trim(),
		cluster: (p.get('cluster') ?? '').trim(),
		chunk: (p.get('chunk') ?? '').trim()
	};
}

/** Canonical href for a view: `path` alone when nothing is set, else
 *  `path?q=…&cluster=…&chunk=…` with empty parts omitted. */
export function viewHref(view, path) {
	const p = new URLSearchParams();
	const q = (view?.q ?? '').trim();
	const cluster = (view?.cluster ?? '').trim();
	const chunk = (view?.chunk ?? '').trim();
	if (q) p.set('q', q);
	if (cluster) p.set('cluster', cluster);
	if (chunk) p.set('chunk', chunk);
	const s = p.toString();
	return s ? `${path}?${s}` : path;
}

/** True when `search` (the address bar's query string) already IS
 *  `view` in
 *  canonical form — the no-op guard that keeps popstate restores from
 *  pushing history entries and identical states from rewriting the
 *  URL (compare canonically: `?q=x&chunk=` is the same view as
 *  `?q=x`). */
export function sameView(search, view) {
	const have = readView(search);
	const want = {
		q: (view?.q ?? '').trim(),
		cluster: (view?.cluster ?? '').trim(),
		chunk: (view?.chunk ?? '').trim()
	};
	return (have.q === want.q && have.cluster === want.cluster &&
	        have.chunk === want.chunk);
}
