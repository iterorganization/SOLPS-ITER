// the copy-citation formats.
//
// Framework-free on purpose (the instant.js / urlstate.js / palette.js
// doctrine): the pure text assembly lives here where node can exercise
// it, while the page owns the clipboard and the buttons.  No DOM
// globals are touched in this module.
//
// TWO FORMS (the criterion), both one paste-ready string:
//
//   plain   one line of provenance — source, section, page, cluster,
//           chunk id — citable anywhere, no dependence on the app
//   linked  the same line, a newline, then the ABSOLUTE deep link of
// the view the citation was copied from (origin + the 
//           canonical ?q=&cluster=&chunk= form via $lib/urlstate.js),
//           so pasting the with-URL form into a chat or a ticket
//           restores exactly this query, filter and citation
//
// Honesty rules, deliberate:
//   - absent provenance is OMITTED, never rendered as empty prose
//     (“p. ” or “()” must never appear)
//   - the plain form never fabricates a URL; the linked form's URL is
//     built by the same codec the address bar uses — what you copy is
// what restores (the round-trip identity)
//   - the chunk id always rides along: a citation without its anchor
//     cannot be verified from the terminal (`askthedocs show <id>`)
// - a source_switch citation's with-URL form GAINS one more
//     line — the documentation origin (the pinned b2input.xml blob,
//     built by the same srclink machinery every other source link
//     uses).  The plain form is the identity (`b2mn.dat — <switch>`)
//     and stays URL-free for every cluster, switches included.

import { switchDocsUrl } from './srclink.js';
import { viewHref } from './urlstate.js';

/** The plain-text citation line for one chunk. */
export function plainCitation(chunk) {
	const id = (chunk?.chunkId ?? '').trim();
	const bits = [];
	const source = (chunk?.source ?? '').trim();
	bits.push(source || id);
	const section = (chunk?.section ?? '').trim();
	if (section) bits.push(section);
	const page = (chunk?.page ?? '').trim();
	if (page) bits.push(page);
	let line = bits.join(': ');
	const cluster = (chunk?.cluster ?? '').trim();
	if (cluster) line += ` (${cluster})`;
	// never "…id — chunk id" when the id already leads the line (the
	// source-less degenerate chunk)
	if (id && id !== bits[0]) line += `: chunk ${id}`;
	return line;
}

/** Both copy forms for the pane's current citation.  `view` is the
 *  { q, cluster, chunk } the deep link restores; `origin` + `pathname`
 *  come from the page (absolute URL, valid wherever it is pasted).
 * a source_switch chunk's linked form carries one more line
 *  after the deep link — the pinned b2input.xml documentation origin
 *  (the same link the provenance row shows beside the b2mn.dat
 *  label); every other cluster, and the plain form for all clusters,
 *  are exactly what they were. */
export function citationForms({ chunk, view, origin = '', pathname = '' }) {
	const plain = plainCitation(chunk);
	const base = `${origin}${viewHref(view ?? {}, pathname)}`;
	const docs =
		(chunk?.cluster ?? '').trim() === 'source_switch' ? switchDocsUrl() : null;
	return {
		plain,
		linked: docs ? `${plain}\n${base}\n${docs.url}` : `${plain}\n${base}`
	};
}
