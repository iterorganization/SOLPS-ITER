<script>
	// the single global stylesheet entry — fonts (self-hosted
	// @fontsource), design tokens and the canvas live in app.css; route
	// components add only scoped styles on top.  No data access here
	// (that boundary is $lib/data.js, ).
	import '../app.css';

	let { children } = $props();
</script>

{@render children()}
