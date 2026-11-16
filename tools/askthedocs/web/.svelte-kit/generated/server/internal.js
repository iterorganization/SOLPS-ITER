
import root from '../root.js';
import { set_building, set_prerendering } from '$app/env/internal';
import { set_assets } from '$app/paths/internal/server';
import { set_manifest, set_read_implementation } from '__sveltekit/server';
import { set_private_env, set_public_env } from '../../../node_modules/@sveltejs/kit/src/runtime/shared-server.js';
import error from '../shared/error-template.js';

export const options = {
	app_template_contains_nonce: false,
	async: false,
	csp: {"mode":"auto","directives":{"upgrade-insecure-requests":false,"block-all-mixed-content":false},"reportOnly":{"upgrade-insecure-requests":false,"block-all-mixed-content":false}},
	csrf_check_origin: true,
	csrf_trusted_origins: [],
	embedded: false,
	env_public_prefix: 'PUBLIC_',
	env_private_prefix: '',
	hash_routing: false,
	hooks: null, // added lazily, via `get_hooks`
	preload_strategy: "modulepreload",
	root,
	service_worker: false,
	service_worker_options: undefined,
	server_error_boundaries: false,
	templates: {
		app: ({ head, body, assets, nonce, env }) => "<!doctype html>\n<html lang=\"en\">\n\t<head>\n\t\t<meta charset=\"utf-8\" />\n\t\t<link rel=\"icon\" href=\"" + assets + "/favicon.svg\" />\n\t\t<meta name=\"viewport\" content=\"width=device-width, initial-scale=1\" />\n\t\t<meta name=\"theme-color\" content=\"#f6f6f7\" media=\"(prefers-color-scheme: light)\" />\n\t\t<meta name=\"theme-color\" content=\"#0a0f22\" media=\"(prefers-color-scheme: dark)\" />\n\t\t<!-- the card this page shows when its URL is pasted\n\t\t     somewhere that renders one — honest copy only, no marketing\n\t\t     inflation: what it searches, how it ranks, what every hit\n\t\t     carries. -->\n\t\t<meta\n\t\t\tname=\"description\"\n\t\t\tcontent=\"bm25 search over the SOLPS-ITER documentation corpus: manuals, changelog, code. Every hit cites its source, section and page.\"\n\t\t/>\n\t\t<meta property=\"og:title\" content=\"askthedocs: SOLPS-ITER knowledge layer\" />\n\t\t<meta\n\t\t\tproperty=\"og:description\"\n\t\t\tcontent=\"bm25 search over the SOLPS-ITER documentation corpus: manuals, changelog, code. Every hit cites its source, section and page.\"\n\t\t/>\n\t\t<meta property=\"og:type\" content=\"website\" />\n\t\t<title>askthedocs</title>\n\t\t" + head + "\n\t\t<script>\n\t\t\t// degraded mode, layer 1 (works without hydration):\n\t\t\t// inline CLASSIC scripts execute on file:// too, so the\n\t\t\t// protocol is flagged on <html> before first paint and the\n\t\t\t// static notice below shows / the search form hides via CSS.\n\t\t\t// (Layer 2 is the Svelte onMount guard in +page.svelte.)\n\t\t\tif (window.location.protocol === 'file:') {\n\t\t\t\tdocument.documentElement.setAttribute('data-proto', 'file');\n\t\t\t}\n\t\t</script>\n\t\t<style>\n\t\t\t/* First-paint canvas (the kit stylesheet lands a beat later):\n\t\t\t   var() fallbacks keep this honest in both orders, and the\n\t\t\t   dark override prevents a white flash before app.css. */\n\t\t\thtml {\n\t\t\t\tbackground: var(--bg, #f6f6f7);\n\t\t\t}\n\t\t\t@media (prefers-color-scheme: dark) {\n\t\t\t\thtml {\n\t\t\t\t\tbackground: var(--bg, #0a0f22);\n\t\t\t\t}\n\t\t\t}\n\t\t\t.askthedocs-file-notice {\n\t\t\t\tdisplay: none;\n\t\t\t\tmax-width: 46rem;\n\t\t\t\tmargin: 3rem auto 4rem;\n\t\t\t\tpadding: 1rem 1.2rem 1.1rem;\n\t\t\t\tborder: 1px solid var(--line-strong, #b9b9bf);\n\t\t\t\tborder-left: 3px solid var(--plasma, #fdbb30);\n\t\t\t\tborder-radius: var(--r-3, 12px);\n\t\t\t\tbackground: var(--surface, #ffffff);\n\t\t\t\tcolor: var(--text, #212529);\n\t\t\t\tfont-family: var(--font-ui, 'Sora', sans-serif);\n\t\t\t\tline-height: 1.55;\n\t\t\t}\n\t\t\t@media (prefers-color-scheme: dark) {\n\t\t\t\t.askthedocs-file-notice {\n\t\t\t\t\tborder-color: var(--line-strong, #3d4a78);\n\t\t\t\t\tbackground: var(--surface, #0f1632);\n\t\t\t\t\tcolor: var(--text, #eef1f8);\n\t\t\t\t}\n\t\t\t}\n\t\t\t.askthedocs-file-notice h2 {\n\t\t\t\tfont-size: 1.05rem;\n\t\t\t\tmargin: 0 0 0.5rem;\n\t\t\t}\n\t\t\t.askthedocs-file-notice p {\n\t\t\t\tmargin: 0.4rem 0;\n\t\t\t}\n\t\t\t.askthedocs-file-notice code {\n\t\t\t\tfont-family: var(--font-mono, ui-monospace, Menlo, monospace);\n\t\t\t\tfont-size: 0.92em;\n\t\t\t}\n\t\t\thtml[data-proto='file'] .askthedocs-file-notice {\n\t\t\t\tdisplay: block;\n\t\t\t}\n\t\t\thtml[data-proto='file'] form[role='search'] {\n\t\t\t\tdisplay: none;\n\t\t\t}\n\t\t</style>\n\t</head>\n\t<body data-sveltekit-preload-data=\"hover\">\n\t\t<div style=\"display: contents\">" + body + "</div>\n\t\t<div class=\"askthedocs-file-notice\">\n\t\t\t<h2>Offline copy: search is unavailable</h2>\n\t\t\t<p>\n\t\t\t\tThis is a <code>file://</code> copy of the askthedocs site. Search\n\t\t\t\tfetches its answers over HTTP, so it needs the site to be\n\t\t\t\tserved; the corpus pages themselves are plain files and remain\n\t\t\t\treadable.\n\t\t\t</p>\n\t\t\t<p>\n\t\t\t\tSearch the same corpus from the terminal:\n\t\t\t\t<code>askthedocs search QUERY</code> and\n\t\t\t\t<code>askthedocs show CHUNK_ID</code>, or over MCP with the\n\t\t\t\t<code>search_docs</code> / <code>get_chunk</code> tools.\n\t\t\t</p>\n\t\t</div>\n\t</body>\n</html>\n",
		error
	},
	version_hash: "1vzi1g"
};

export async function get_hooks() {
	let handle;
	let handleFetch;
	let handleError;
	let handleValidationError;
	let init;
	

	let reroute;
	let transport;
	

	return {
		handle,
		handleFetch,
		handleError,
		handleValidationError,
		init,
		reroute,
		transport
	};
}

export { set_assets, set_building, set_manifest, set_prerendering, set_private_env, set_public_env, set_read_implementation };
