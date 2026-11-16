export const manifest = (() => {
function __memo(fn) {
	let value;
	return () => value ??= (value = fn());
}

return {
	appDir: "_app",
	appPath: "_app",
	assets: new Set(["favicon.svg"]),
	mimeTypes: {".svg":"image/svg+xml"},
	_: {
		client: {start:"_app/immutable/entry/start.BD6v6frw.js",app:"_app/immutable/entry/app.C8t3gN-T.js",imports:["_app/immutable/entry/start.BD6v6frw.js","_app/immutable/chunks/BuN3jQtc.js","_app/immutable/chunks/Bh57Uu6y.js","_app/immutable/entry/app.C8t3gN-T.js","_app/immutable/chunks/Bh57Uu6y.js","_app/immutable/chunks/xihTtKlq.js"],stylesheets:[],fonts:[],uses_env_dynamic_public:false},
		nodes: [
			__memo(() => import('./nodes/0.js')),
			__memo(() => import('./nodes/1.js'))
		],
		remotes: {
			
		},
		routes: [
			
		],
		prerendered_routes: new Set(["/"]),
		matchers: async () => {
			
			return {  };
		},
		server_assets: {}
	}
}
})();
