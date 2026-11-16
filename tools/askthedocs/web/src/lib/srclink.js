// the source-path link builder (framework-free).
//
// Every chunk's `source` is a repo-root-relative path whose FIRST
// segment names the repository it lives in.  Both corpus repos are
// PUBLIC on GitHub (repo pages and every representative blob below
// verified HTTP 200, 2026-09-26):
//
//   SOLPS-ITER/*  -> github.com/iterorganization/SOLPS-ITER  (master)
//   SOLPS-GUI/*   -> github.com/iterorganization/SOLPS-GUI   (develop)
//
// One wrinkle the local checkout hides: SOLPS-ITER's modules/B2.5,
// modules/Eirene, modules/DivGeo and modules/Carre are git SUBMODULES
//  the main repo answers 404 for files under them (the path holds a
// commit pointer, not the file).  The blob lives in the module's own
// public repo, so those prefixes reroute: same file, module repo,
// prefix stripped.  modules/amds and every other path stay in the
// main repo.
//
// b2mn.dat (the v1 switch inventory) is a SYNTHETIC source —
// a conceptual input file of which the repo holds many copies; it
// names no one document and links to none: sourceUrl answers null
// and the caller renders plain text, never a dead-looking link.
// amendment (owner ruling 2026-09-29): the rule STANDS — the
// deck label still links to nothing — but the switch chunks'
// documented content (name/default/type/description) comes from
// exactly ONE real, pinned file, modules/B2.5's b2input.xml, so the
// provenance row places a LINK to that file BESIDE the synthetic
// label (switchDocsUrl below): both labels are true — one names what
// the chunk is about, the other names where the documentation lives.
// File-level only, no #L anchor: the citation's section (the switch
// name) is the precision instrument, each name unique in b2input.xml.
//
// `ref` is PINNED): the corpus manifest records each repo's
// HEAD commit at scan time — and each rerouted submodule's OWN
// checkout commit, not SOLPS-ITER's (the module bytes the scan walked
// live at the submodule's HEAD; the parent's commit does not name
// them).  PINNED_COMMITS below mirrors the manifest's `heads` block
// (keyed the same way); the sync is test-pinned, so a re-scan that
// records new commits fails the mirror golden until this map is
// re-mirrored.  A repo with no pin (git was absent at scan time, or a
// manifest that predates the field) falls back to its DEFAULT branch —
// labeled as such by the caller via the `pinned` flag, never a
// pinning pretense.  PDF pages get NO anchor: GitHub's viewer takes
// none — the citation's page number is the precision instrument.
// Fortran chunks DO anchor: their text's `source: <path> lines N-M`
// header (written by askthedocs.fortran.chunk_text) carries the 1-based
// range, and the link gains #LN-LM when that header names THIS
// chunk's source.  Display path only — the store schema is untouched.

/** Repo first-segment -> { url, ref } (default branch, verified
 *  2026-09-26: SOLPS-ITER master, SOLPS-GUI develop). */
export const SOURCE_REPOS = Object.freeze({
	'SOLPS-ITER': Object.freeze({
		url: 'https://github.com/iterorganization/SOLPS-ITER',
		ref: 'master'
	}),
	'SOLPS-GUI': Object.freeze({
		url: 'https://github.com/iterorganization/SOLPS-GUI',
		ref: 'develop'
	}),
	'SOLPS-Tutorials': Object.freeze({
		url: 'https://github.com/iterorganization/SOLPS-Tutorials',
		ref: 'master'
	})
});

/** Submodule prefixes inside SOLPS-ITER -> their own public repo
 *  (the main repo 404s these paths; .gitmodules names the reroutes). */
export const MODULE_REPOS = Object.freeze({
	'modules/B2.5/': Object.freeze({
		url: 'https://github.com/iterorganization/B2.5',
		ref: 'master'
	}),
	'modules/Eirene/': Object.freeze({
		url: 'https://github.com/iterorganization/EIRENE',
		ref: 'master'
	}),
	'modules/DivGeo/': Object.freeze({
		url: 'https://github.com/iterorganization/DivGeo',
		ref: 'master'
	}),
	'modules/Carre/': Object.freeze({
		url: 'https://github.com/iterorganization/CARRE',
		ref: 'master'
	})
});

// the fortran header line — whole-line anchored so prose that merely
// quotes the shape never anchors
const FORTRAN_HEADER = /^source: (\S+) lines (\d+)-(\d+)$/m;

/** The commit each repo was scanned at) — a mirror of the
 *  corpus manifest's `heads` block (out/corpus.json, schema
 *  askthedocs-corpus/2, scan of 2026-09-26; the sync is golden-tested
 *  against the manifest).  Keys use the chunk-source namespace:
 *  repo name, or '<repo>/<submodule path>' for rerouted modules.  A
 *  repo absent here links at its default branch, `pinned: false`. */
export const PINNED_COMMITS = Object.freeze({
	'SOLPS-ITER': 'ca0d04d9b0b2d4887bd3262e4e867d471ba86d62',
	'SOLPS-GUI': 'd590673299f5b664a7610b3efea1aba63e761f44',
	'SOLPS-Tutorials': '21e1769621c26b65579e5c89e598cbf5ea86950b',
	'SOLPS-ITER/modules/B2.5':
		'a1129dd949a4fa49d5c1c1ad149085a273dcb3d3',
	'SOLPS-ITER/modules/Eirene':
		'97ceb4b329f1816b0b73ec44e57284c9707a5eb8',
	'SOLPS-ITER/modules/DivGeo':
		'a919c5cd8871de30bdd5bc13f37bae754c9de93c',
	'SOLPS-ITER/modules/Carre':
		'd7b314aa604a16d32c8a12d4f5f3644e398385de'
});

function fortranAnchor(source, text) {
	if (!text) return '';
	// the range lives in the chunk's LEADING header (line 2 of the
	// text: kind line, then the source line) — a matching line quoted
	// anywhere deeper in a chunk anchors nothing
	const head = text.split('\n').slice(0, 3).join('\n');
	const m = FORTRAN_HEADER.exec(head);
	// the header must name THIS chunk's source — a range quoted from
	// any other file never anchors
	if (!m || m[1] !== source) return '';
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
const RENDERED_TYPES = new Set(['.rst', '.md', '.adoc', '.pdf']);

/** True when the source's GitHub blob renders (display text unescapes
 *  markup escapes); false when it shows raw code (display text keeps
 *  every byte — the source IS the Ctrl+F target there). */
export function githubShowsRendered(source) {
	const s = String(source ?? '');
	const dot = s.lastIndexOf('.');
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
export function sourceUrl(source, text = '', pins = PINNED_COMMITS) {
	const s = String(source ?? '');
	const slash = s.indexOf('/');
	if (slash < 1) return null; // no repo first segment ('b2mn.dat')
	let base = SOURCE_REPOS[s.slice(0, slash)];
	if (!base) return null;
	let rest = s.slice(slash + 1);
	let pinKey = s.slice(0, slash); // 'SOLPS-ITER' / 'SOLPS-GUI'
	for (const [prefix, repo] of Object.entries(MODULE_REPOS)) {
		if (rest.startsWith(prefix)) {
			base = repo;
			rest = rest.slice(prefix.length);
			// the pin for a reroute is the SUBMODULE's own commit —
			// keyed '<repo>/<module path>' like the manifest's heads
			pinKey = `${pinKey}/${prefix.slice(0, -1)}`;
			break;
		}
	}
	// the pinned commit wins; a repo the manifest could not pin (git
	// absent, or a pre-manifest) falls back to the branch —
	// flagged, never a pinning pretense
	const commit = pins[pinKey];
	const ref = commit ?? base.ref;
	// per-segment encoding: a space or '#' inside a filename must not
	// break the path or masquerade as a fragment
	const path = rest.split('/').map(encodeURIComponent).join('/');
	return {
		url: `${base.url}/blob/${ref}/${path}${fortranAnchor(s, text)}`,
		repo: base.url.replace('https://github.com/', ''),
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
const SITE_PAGES = Object.freeze({
	'SOLPS-Tutorials': 'https://solps-tutorials.readthedocs.io'
});

/** The rendered-page URL for a source, or null when the source has no
 *  page (non-site repos, non-docs paths, non-markdown files). */
export function pageUrl(source) {
	const s = String(source ?? '');
	const slash = s.indexOf('/');
	if (slash < 1) return null;
	const site = SITE_PAGES[s.slice(0, slash)];
	if (!site) return null;
	const rest = s.slice(slash + 1);
	if (!rest.startsWith('docs/') || !rest.toLowerCase().endsWith('.md'))
		return null;
	const page = rest.slice('docs/'.length, -3);
	const path = page === 'index'
		? ''
		: page.split('/').map(encodeURIComponent).join('/') + '/';
	return `${site}/${path}`;
}

/** The chunk-source-namespace path of the switch documentation's
 *  origin — the ONE real, pinned file behind every b2mn.dat switch
 * chunk's documented content (the ruling above). */
const SWITCH_DOCS_SOURCE =
	'SOLPS-ITER/modules/B2.5/src/documentation/b2input.xml';

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
export function switchDocsUrl(pins = PINNED_COMMITS) {
	return sourceUrl(SWITCH_DOCS_SOURCE, '', pins);
}
