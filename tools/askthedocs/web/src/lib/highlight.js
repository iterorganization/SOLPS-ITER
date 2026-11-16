//  term highlighting for the citation pane + the counts the
// match navigator shows.
//
// Framework-free on purpose (the $lib/instant.js doctrine): the pure
// scanner below is exercisable in node against REAL chunk texts with
// the pinned goldens, so the mark counts the UI will show are proven
// before any browser is involved.
//
// SAFETY (the v1 excerpt discipline, restated for full chunk text):
// chunk text is DATA, never markup.  The DOM half walks TEXT NODES
// ONLY and builds every <mark> with the DOM factory APIs — nothing in
// this module ever assigns markup for the browser to parse, so a
// chunk cannot smuggle HTML through its own highlighting.  (The
// hit-row excerpt is different on purpose: its markup is built inside
// $lib/data.js from escaped text, never here.)

// A token run is a maximal span of letters/digits — underscore and
// every other non-alphanumeric is a separator, exactly as FTS5
// unicode61 tokenizes and exactly as the matched-term counts
// were derived (regex "[^\W_]+" over casefolded text).  Matching this
// same rule is what makes the navigator's "m of N" agree with the
// Σn of the why-this-result panel: N == Σ matched_terms.n, always.
// \p{M} keeps decomposed accents (NFD combining marks) inside the
// run — Python's \w counts them as word characters, so the JS class
// must too or the pane's mark count drifts from the server's n.
const RUN = /[\p{L}\p{N}\p{M}]+/gu;

/** All matches of `terms` in `text`, in document order.
 *
 * Case-insensitive whole-token equality: "EIRENE" and "Eirene" match
 * eirene; "walls" does not match wall; the "wall" inside the filename
 * wall_geometry_990429019.ogr DOES match (underscore is a separator).
 * Returns [{ start, end, term }] — offsets index into `text`,
 * `term` is the canonical (lowercase) query term.
 */
export function findMatches(text, terms) {
	const set = new Set(
		(terms ?? [])
			.map((t) => String(t).toLowerCase())
			.filter(Boolean)
	);
	const out = [];
	if (!set.size) return out;
	for (const m of String(text ?? '').matchAll(RUN)) {
		if (set.has(m[0].toLowerCase())) {
			out.push({ start: m.index, end: m.index + m[0].length, term: m[0].toLowerCase() });
		}
	}
	return out;
}

/** Wrap every match in `root`'s text nodes with <mark class="match">.
 *
 * Text-node walking ONLY: document.createTreeWalker(root,
 * NodeFilter.SHOW_TEXT) collects the
 * text nodes first, then each one carrying matches is replaced by a
 * fragment of plain text nodes + mark elements (createElement +
 * textContent — the substring is assigned, never parsed as HTML).
 * Collect-then-replace keeps the walker stable: marks created by this
 * pass are never visited by it.  Returns the marks in document order
 * (empty when root is absent or nothing matches).
 *
 * Caller contract: root's contents are Svelte-rendered plain text
 * ({cite.chunk.text} inside a {#key} block), so this pass is the only
 * thing that ever touches that subtree; Svelte never tries to update
 * a node this pass has replaced.
 */
export function markTextNodes(root, terms) {
	const marks = [];
	if (!root) return marks;
	const hits = new Map(); // text node -> its matches
	const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT);
	let node;
	while ((node = walker.nextNode())) {
		const found = findMatches(node.data, terms);
		if (found.length) hits.set(node, found);
	}
	for (const [textNode, found] of hits) {
		const data = textNode.data;
		const frag = document.createDocumentFragment();
		let at = 0;
		for (const { start, end } of found) {
			if (start > at) {
				frag.appendChild(document.createTextNode(data.slice(at, start)));
			}
			const mark = document.createElement('mark');
			mark.className = 'match';
			mark.textContent = data.slice(start, end); // assigned, never parsed
			frag.appendChild(mark);
			marks.push(mark);
			at = end;
		}
		if (at < data.length) {
			frag.appendChild(document.createTextNode(data.slice(at)));
		}
		textNode.replaceWith(frag);
	}
	return marks;
}
