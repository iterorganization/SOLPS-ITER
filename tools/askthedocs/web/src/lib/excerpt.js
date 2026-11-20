//  display-path corpus hygiene (api mode ONLY; the static
// face is frozen and its data path never imports this module).
//
// The corpus is PDF-extracted, and two extraction artifacts follow it
// into every display: table-of-contents lines whose dot leaders
// swamp the excerpt ("3 Divertor operation regimes ......... 47"),
// and end-of-line hyphenation left as a hard break mid-word
// ("diver-\ntor").  Both are repaired in the DISPLAY path only —
// the store, the API rows and the ranking are untouched (§4: ranking
// is not ours to change; tests/test_excerpt_us019.py pins the
// chunk-ID order before/after).
//
// All functions are pure string -> string/boolean: framework-free,
// node-testable, deterministic.

/** Dot-leader runs — 4+ consecutive dots (an ellipsis "..." of three
 *  stays prose; a TOC leader is never shorter than four). */
const LEADER = /\.{4,}/g;

/** A run of dots collapses to ONE ellipsis character — the same
 *  omission glyph FTS5's snippet window already uses. */
const LEADER_TO = '…';

/** Collapse every dot-leader run in an excerpt. */
export function collapseLeaders(s) {
	return s.replace(LEADER, LEADER_TO);
}

/** Soft-hyphen candidates: letter(s) - newline lowercase-letter(s).
 *  Uppercase continuations are never end-of-line hyphenation — a
 *  heading in caps keeps its break.  The {1,12}/{1,14} spans match
 *  the derivation scan exactly (see JOIN_PREFIXES). */
const SOFT_HYPHEN = /([A-Za-z]{1,12})-\n([a-z]{1,14})/g;

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
export const JOIN_PREFIXES = new Set(
	('absorp ac anal anoma ap approx as assump av avail aver back be ' +
		'bound cal calcu chap char charac co col colli com compres con ' +
		'conduc consid contri conve coordi cor corre cou counter cur de ' +
		'den deter deu devel devi di dia diagnos dif differ diffu direc ' +
		'dis discon discretisa disso distri distribu diver dou down draw ' +
		'el ele elec emis en equa equi equiva es espe ex exist experi ' +
		'fig fol for formu func gen geome green how hydro im impu in ' +
		'integra inter interac ion ionisa ioniza ma mag mea men meta mid ' +
		'mo mod momen ne nec neu nu num ob on opera originat pa par param ' +
		'parti pene per perpen plas po pos posi possi poten pre pres pro ' +
		'prob prod produc projec quasi ra radi radia re recom recombi ' +
		'recombina redistri rela remain repre repro respec rou sam schit ' +
		'schnei se sec sep sepa separa set sig simula sput stan start ' +
		'statis struc subrou sug sur tar target tem temper tempera test ' +
		'theoret ther there three time toka trans transi tri under up us ' +
		'vari ve veloc ver with').split(' ')
);

/** Repair end-of-line hyphenation in display text.  The newline
 *  ALWAYS goes (a mid-word hard break is wrong at any display
 *  width); the hyphen survives unless the fragment is in
 *  JOIN_PREFIXES.  Pane text passes through here too, which also
 *  reunites query terms the store text holds split — the highlight
 *  walk and the server's matched-term counts then agree on what the
 *  reader sees. */
export function joinSoftHyphens(s) {
	return s.replace(
		SOFT_HYPHEN,
		(m, head, tail, offset, whole) => {
			// word-start boundary: a letter before the match means the
			// fragment is longer than it looks ("adiver-\ntor" must not
			// join on its "diver" tail)
			const prev = whole[offset - 1];
			if (prev && /[A-Za-z]/.test(prev)) return m;
			return JOIN_PREFIXES.has(head.toLowerCase())
				? head + tail
				: head + '-' + tail;
		}
	);
}

/** Contents-row threshold: leader dots as a fraction of the snippet.
 *  MEASURED (2026-09-26, golden-suite + probe queries): true TOC
 *  snippets from CPP_2006.pdf sit at 0.38–0.70; the only other
 *  ≥4-dot runs in snippets are Fortran range comments
 *  ("IH=2,3....,10") at ~0.05.  0.15 sits in the empty gap, 3x above
 *  the comment zone and 2.5x below the TOC zone. */
const TOC_DENSITY = 0.15;

/** Is this excerpt a table-of-contents row?  Leader-dot density
 *  heuristic (see TOC_DENSITY).  Badged in the row — never demoted:
 *  the chunk still ranks where bm25 put it. */
export function contentsRow(rawSnippet) {
	if (!rawSnippet) return false;
	const runs = rawSnippet.match(LEADER);
	if (!runs) return false;
	const dots = runs.reduce((n, r) => n + r.length, 0);
	return dots / rawSnippet.length >= TOC_DENSITY;
}

/** The full api-mode snippet treatment: joined text for display +
 *  the contents-row flag (computed on the RAW snippet — density is a
 *  property of what the corpus holds, not of the collapse). */
export function cleanSnippet(raw) {
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
const MARKUP_ESCAPES = /\\([_%&#])/g;

/** Unescape the markup specials in display text (rendered-view
 *  chunks only). */
export function unescapeMarkup(s) {
	return s.replace(MARKUP_ESCAPES, '$1');
}
