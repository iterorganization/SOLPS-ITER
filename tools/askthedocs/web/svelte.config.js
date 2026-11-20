import adapter from '@sveltejs/adapter-static';
import { vitePreprocess } from '@sveltejs/vite-plugin-svelte';

/** @type {import('@sveltejs/kit').Config} */
const config = {
	preprocess: vitePreprocess(),
	kit: {
		// doctrine: the web face is plain files — no server, no
		// Node at runtime.  strict (default) fails the build if any route
		// escapes prerendering, so a server dependency can never slip in.
		adapter: adapter({
			pages: 'build',
			assets: 'build',
			precompress: false,
			strict: true
		}),
		// Determinism: the DEFAULT version.name is Date.now() (kit config
		// options.js:335) — it feeds the __sveltekit_<hash> global AND the
		// client bundle that references it, so every asset filename would
		// churn per build.  Pinned; cache busting is carried by the
		// content-hashed _app/immutable/ filenames instead.
		version: {
			name: '0.1.0'
		}
	}
};

export default config;
