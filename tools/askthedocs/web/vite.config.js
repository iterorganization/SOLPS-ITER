import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig({
	plugins: [sveltekit()],
	// expose ASKTHEDOCS_* env vars to the client bundle — the
	// build-mode flag.  `ASKTHEDOCS_MODE=api npm run build:api` compiles
	// $lib/data.js onto the FastAPI backend; the default build stays
	// on the fragmented pagefind index.  ASKTHEDOCS_API_BASE (default ''
	// = same origin) is the other knob.
	envPrefix: 'ASKTHEDOCS_',
	build: {
		rolldownOptions: {
			checks: {
				// rolldown prints a [PLUGIN_TIMINGS] perf
				// notice whenever plugin callbacks exceed ~3 s — pure
				// machine-load noise (back-to-back builds flip it on
				// and off), not a compiler warning.  The empty-stderr
				// build doctrine targets real warnings, so exactly this
				// diagnostic is off; every other check stays on.
				pluginTimings: false
			}
		}
	}
});
