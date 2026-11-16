//  the instant-search controller.
//
// Framework-free on purpose: the page wires it to the DOM, the data
// module supplies the transport, and the RACE DISCIPLINE lives here
// where a delayed mock can exercise it — tests/test_instant_us003.py
// imports THIS module in node and proves stale responses never
// overwrite newer ones.  Two guards make a superseded request
// harmless:
//
//   ABORT — every superseded request's AbortController fires, so the
//           HTTP fetch dies on the wire (api mode; the static
//           backend's runtime takes no signal, but its enrichment
//           fetches in $lib/data.js do).
//   SEQ   — a monotonic request id; a response whose id is no longer
//           current is DROPPED even if abort arrived too late.
//
// The seq guard is the product contract; the abort is the cost
// optimization.  State changes are pushed through onState snapshots
// ({ query, running, searched, total, results, facets, error,
// transient }) — `transient` marks a 4xx (mid-typing FTS5 syntax,
// e.g. a dangling OR): visible as a gentle "keep typing" pause,
// never a red error. `facets` passes the per-cluster
// chip counts straight from the backend payload; [] when absent.
//
// show-more: `more()` grows the SAME query's list by one
// batch — it re-asks the transport for `shown + batch` rows (the
// server's bm25+rowid order is prefix-stable, so the wider answer
// EXTENDS the list; rows are keyed by chunk id upstream).  Snapshots
// carry `appended` (true for every snapshot of a show-more cycle)
// and `fetchingMore`: the page keeps its selection, pane anchor and
// URL across a batch — only a fresh result set resets them.  A
// failed batch preserves the rows already on screen.

export const DEBOUNCE_MS = 150;

export function createInstantSearch({ search, debounceMs = DEBOUNCE_MS, limit = 10, onState }) {
	let seq = 0; // current request id — responses with a lower id are stale
	let timer = null; // pending debounce
	let controller = null; // AbortController of the in-flight request

	const state = {
		query: '',
		running: false,
		searched: false,
		total: 0,
		results: [],
		facets: [],
		error: '',
		transient: false,
		fetchingMore: false, // a show-more batch is in flight
		appended: false, // this snapshot belongs to a batch cycle
		// which semantics produced the current view — 'typeahead'
		// (typing: exact tier + flagged completion tier) or 'committed'
		// (submit: exact only).  more() re-asks in the SAME mode.
		mode: 'committed',
		completionsTotal: 0, // : completion-tier size (0 when none)
		// zero-hit boundary recovery — grounded completions;
		// (c): the separate-term escape hatch rides the same state
		didYouMean: null,
		completionWords: [],
		separateTerms: []
	};

	function apply(patch) {
		Object.assign(state, patch);
		onState?.({ ...state });
	}

	// Invalidate everything in flight: bump the id (their responses
	// become stale), cancel a pending debounce, abort the wire.
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
		// the request being superseded (still in flight — its own
		// finally has not run) dies on the wire, not just in memory
		controller?.abort();
		controller = new AbortController();
		// a fresh query always asks for the base page — paging depth
		// is view-local, never carried across queries.
		// typing asks the type-ahead answer (exact tier keeps
		// committed order; completion hits ride below, flagged);
		// submit asks the committed answer (exact only) — the head of
		// the typing view IS the committed list, so Enter never
		// reshuffles what the reader saw above the divider.
		apply({ running: true, error: '', transient: false, appended: false,
		        mode });
		search(state.query.trim(),
		       { signal: controller.signal, limit, typeahead: mode === 'typeahead' })
			.then(({ total, rows, facets, completionsTotal, didYouMean, completionWords, separateTerms }) => {
				if (id !== seq) return; // stale — never overwrite
				// facets: per-cluster chip counts from the
				// backend; static mode returns none — normalized empty
				apply({ total, results: rows, facets: facets ?? [],
				        completionsTotal: completionsTotal ?? 0,
				        didYouMean: didYouMean ?? null,
				        completionWords: completionWords ?? [],
				        separateTerms: separateTerms ?? [],
				        searched: true, appended: false, mode });
			})
			.catch((err) => {
				if (id !== seq) return; // stale — never overwrite
				if (err?.name === 'AbortError') return; // superseded on the wire
				const status = typeof err?.status === 'number' ? err.status : 0;
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
			})
			.finally(() => {
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
				error: '',
				transient: false,
				fetchingMore: false, // an in-flight batch died with the clear
				appended: false
			});
			return;
		}
		if (timer) clearTimeout(timer);
		timer = setTimeout(() => fire('typeahead'), debounceMs);
	}

	/** Fire NOW — Enter or the submit button bypass the debounce.  A
	 *  commit asks the COMMITTED answer: the exact tier alone, in the
	 *  same order the type-ahead head already showed. */
	function submit() {
		if (!state.query.trim()) return;
		supersede();
		fire('committed');
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
		const ceiling = state.mode === 'typeahead'
			? state.total + state.completionsTotal
			: state.total;
		if (state.results.length >= ceiling) return; // exhausted
		supersede();
		const id = ++seq;
		controller = new AbortController();
		apply({ fetchingMore: true, appended: true });
		search(state.query.trim(), {
			signal: controller.signal,
			limit: state.results.length + limit,
			typeahead: state.mode === 'typeahead'
		})
			.then(({ total, rows, facets, completionsTotal }) => {
				if (id !== seq) return; // stale — never overwrite
				apply({
					total,
					results: rows,
					completionsTotal: completionsTotal ?? state.completionsTotal,
					// a batch never blanks the chips: absent counts keep
					// the ones on screen (same query, same MATCH set)
					facets: facets ?? state.facets,
					searched: true,
					appended: true
				});
			})
			.catch((err) => {
				if (id !== seq) return; // stale — never overwrite
				if (err?.name === 'AbortError') return; // superseded on the wire
				// the batch failed, not the search: the rows on screen
				// stay; the error surfaces beside them
				apply({ error: String(err?.message ?? err), appended: true });
			})
			.finally(() => {
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

	return { input, submit, stop, more };
}
