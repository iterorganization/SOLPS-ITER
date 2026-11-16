
// this file is generated — do not edit it


/// <reference types="@sveltejs/kit" />

/**
 * This module provides access to environment variables that are injected _statically_ into your bundle at build time and are limited to _private_ access.
 * 
 * |         | Runtime                                                                    | Build time                                                               |
 * | ------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
 * | Private | [`$env/dynamic/private`](https://svelte.dev/docs/kit/$env-dynamic-private) | [`$env/static/private`](https://svelte.dev/docs/kit/$env-static-private) |
 * | Public  | [`$env/dynamic/public`](https://svelte.dev/docs/kit/$env-dynamic-public)   | [`$env/static/public`](https://svelte.dev/docs/kit/$env-static-public)   |
 * 
 * Static environment variables are [loaded by Vite](https://vitejs.dev/guide/env-and-mode.html#env-files) from `.env` files and `process.env` at build time and then statically injected into your bundle at build time, enabling optimisations like dead code elimination.
 * 
 * **_Private_ access:**
 * 
 * - This module cannot be imported into client-side code
 * - This module only includes variables that _do not_ begin with [`config.kit.env.publicPrefix`](https://svelte.dev/docs/kit/configuration#env) _and do_ start with [`config.kit.env.privatePrefix`](https://svelte.dev/docs/kit/configuration#env) (if configured)
 * 
 * For example, given the following build time environment:
 * 
 * ```env
 * ENVIRONMENT=production
 * PUBLIC_BASE_URL=http://site.com
 * ```
 * 
 * With the default `publicPrefix` and `privatePrefix`:
 * 
 * ```ts
 * import { ENVIRONMENT, PUBLIC_BASE_URL } from '$env/static/private';
 * 
 * console.log(ENVIRONMENT); // => "production"
 * console.log(PUBLIC_BASE_URL); // => throws error during build
 * ```
 * 
 * The above values will be the same _even if_ different values for `ENVIRONMENT` or `PUBLIC_BASE_URL` are set at runtime, as they are statically replaced in your code with their build time values.
 */
declare module '$env/static/private' {
	export const COLORTERM: string;
	export const ANTHROPIC_DEFAULT_SONNET_MODEL: string;
	export const CLAUDE_CODE_MESSAGING_SOCKET: string;
	export const LC_TERMINAL: string;
	export const CLAUDE_CODE_SESSION_ID: string;
	export const npm_config_user_agent: string;
	export const npm_lifecycle_script: string;
	export const ANTHROPIC_AUTH_TOKEN: string;
	export const CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC: string;
	export const ITERM_SESSION_ID: string;
	export const NODE_ENV: string;
	export const CLAUDE_CODE_EXECPATH: string;
	export const npm_config_prefix: string;
	export const SHLVL: string;
	export const npm_package_version: string;
	export const ANTHROPIC_DEFAULT_OPUS_MODEL: string;
	export const CONTEXT_WINDOW: string;
	export const npm_config_npm_version: string;
	export const ITERM_PROFILE: string;
	export const EDITOR: string;
	export const XPC_FLAGS: string;
	export const npm_command: string;
	export const PYENV_SHELL: string;
	export const USER: string;
	export const GIT_EDITOR: string;
	export const __CFBundleIdentifier: string;
	export const __CF_USER_TEXT_ENCODING: string;
	export const npm_config_init_module: string;
	export const npm_execpath: string;
	export const npm_config_userconfig: string;
	export const LaunchInstanceID: string;
	export const SVELTEKIT_FORK: string;
	export const npm_node_execpath: string;
	export const _: string;
	export const TERM_SESSION_ID: string;
	export const TERM_FEATURES: string;
	export const PATH: string;
	export const CLAUDE_CODE_SESSION_ATTENDED: string;
	export const npm_package_engines_node: string;
	export const npm_package_json: string;
	export const npm_config_node_gyp: string;
	export const PWD: string;
	export const SECURITYSESSIONID: string;
	export const SSH_AUTH_SOCK: string;
	export const npm_config_globalconfig: string;
	export const COMMAND_MODE: string;
	export const API_TIMEOUT_MS: string;
	export const CDPATH: string;
	export const LOGNAME: string;
	export const ANTHROPIC_BASE_URL: string;
	export const npm_config_local_prefix: string;
	export const npm_package_name: string;
	export const npm_config_noproxy: string;
	export const LANG: string;
	export const CLAUDE_CODE_MESSAGING_TOKEN: string;
	export const CLAUDE_CODE_ENTRYPOINT: string;
	export const CLAUDE_CODE_CHILD_SESSION: string;
	export const SHELL: string;
	export const COLOR: string;
	export const ANTHROPIC_DEFAULT_HAIKU_MODEL: string;
	export const CLAUDECODE: string;
	export const npm_config_cache: string;
	export const LC_TERMINAL_VERSION: string;
	export const TERM_PROGRAM_VERSION: string;
	export const TMPDIR: string;
	export const TERM: string;
	export const NODE: string;
	export const COREPACK_ENABLE_AUTO_PIN: string;
	export const TERMINFO_DIRS: string;
	export const CLAUDE_PID: string;
	export const HOME: string;
	export const TERM_PROGRAM: string;
	export const COLORFGBG: string;
	export const INIT_CWD: string;
	export const CLAUDE_EFFORT: string;
	export const BUN_INSTALL: string;
	export const npm_config_global_prefix: string;
	export const NoDefaultCurrentDirectoryInExePath: string;
	export const npm_lifecycle_event: string;
	export const XPC_SERVICE_NAME: string;
	export const MAX_TOKENS: string;
	export const AI_AGENT: string;
	export const ASKTHEDOCS_MODE: string;
}

/**
 * This module provides access to environment variables that are injected _statically_ into your bundle at build time and are _publicly_ accessible.
 * 
 * |         | Runtime                                                                    | Build time                                                               |
 * | ------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
 * | Private | [`$env/dynamic/private`](https://svelte.dev/docs/kit/$env-dynamic-private) | [`$env/static/private`](https://svelte.dev/docs/kit/$env-static-private) |
 * | Public  | [`$env/dynamic/public`](https://svelte.dev/docs/kit/$env-dynamic-public)   | [`$env/static/public`](https://svelte.dev/docs/kit/$env-static-public)   |
 * 
 * Static environment variables are [loaded by Vite](https://vitejs.dev/guide/env-and-mode.html#env-files) from `.env` files and `process.env` at build time and then statically injected into your bundle at build time, enabling optimisations like dead code elimination.
 * 
 * **_Public_ access:**
 * 
 * - This module _can_ be imported into client-side code
 * - **Only** variables that begin with [`config.kit.env.publicPrefix`](https://svelte.dev/docs/kit/configuration#env) (which defaults to `PUBLIC_`) are included
 * 
 * For example, given the following build time environment:
 * 
 * ```env
 * ENVIRONMENT=production
 * PUBLIC_BASE_URL=http://site.com
 * ```
 * 
 * With the default `publicPrefix` and `privatePrefix`:
 * 
 * ```ts
 * import { ENVIRONMENT, PUBLIC_BASE_URL } from '$env/static/public';
 * 
 * console.log(ENVIRONMENT); // => throws error during build
 * console.log(PUBLIC_BASE_URL); // => "http://site.com"
 * ```
 * 
 * The above values will be the same _even if_ different values for `ENVIRONMENT` or `PUBLIC_BASE_URL` are set at runtime, as they are statically replaced in your code with their build time values.
 */
declare module '$env/static/public' {
	
}

/**
 * This module provides access to environment variables set _dynamically_ at runtime and that are limited to _private_ access.
 * 
 * |         | Runtime                                                                    | Build time                                                               |
 * | ------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
 * | Private | [`$env/dynamic/private`](https://svelte.dev/docs/kit/$env-dynamic-private) | [`$env/static/private`](https://svelte.dev/docs/kit/$env-static-private) |
 * | Public  | [`$env/dynamic/public`](https://svelte.dev/docs/kit/$env-dynamic-public)   | [`$env/static/public`](https://svelte.dev/docs/kit/$env-static-public)   |
 * 
 * Dynamic environment variables are defined by the platform you're running on. For example if you're using [`adapter-node`](https://github.com/sveltejs/kit/tree/main/packages/adapter-node) (or running [`vite preview`](https://svelte.dev/docs/kit/cli)), this is equivalent to `process.env`.
 * 
 * **_Private_ access:**
 * 
 * - This module cannot be imported into client-side code
 * - This module includes variables that _do not_ begin with [`config.kit.env.publicPrefix`](https://svelte.dev/docs/kit/configuration#env) _and do_ start with [`config.kit.env.privatePrefix`](https://svelte.dev/docs/kit/configuration#env) (if configured)
 * 
 * > [!NOTE] In `dev`, `$env/dynamic` includes environment variables from `.env`. In `prod`, this behavior will depend on your adapter.
 * 
 * > [!NOTE] To get correct types, environment variables referenced in your code should be declared (for example in an `.env` file), even if they don't have a value until the app is deployed:
 * >
 * > ```env
 * > MY_FEATURE_FLAG=
 * > ```
 * >
 * > You can override `.env` values from the command line like so:
 * >
 * > ```sh
 * > MY_FEATURE_FLAG="enabled" npm run dev
 * > ```
 * 
 * For example, given the following runtime environment:
 * 
 * ```env
 * ENVIRONMENT=production
 * PUBLIC_BASE_URL=http://site.com
 * ```
 * 
 * With the default `publicPrefix` and `privatePrefix`:
 * 
 * ```ts
 * import { env } from '$env/dynamic/private';
 * 
 * console.log(env.ENVIRONMENT); // => "production"
 * console.log(env.PUBLIC_BASE_URL); // => undefined
 * ```
 */
declare module '$env/dynamic/private' {
	export const env: {
		COLORTERM: string;
		ANTHROPIC_DEFAULT_SONNET_MODEL: string;
		CLAUDE_CODE_MESSAGING_SOCKET: string;
		LC_TERMINAL: string;
		CLAUDE_CODE_SESSION_ID: string;
		npm_config_user_agent: string;
		npm_lifecycle_script: string;
		ANTHROPIC_AUTH_TOKEN: string;
		CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC: string;
		ITERM_SESSION_ID: string;
		NODE_ENV: string;
		CLAUDE_CODE_EXECPATH: string;
		npm_config_prefix: string;
		SHLVL: string;
		npm_package_version: string;
		ANTHROPIC_DEFAULT_OPUS_MODEL: string;
		CONTEXT_WINDOW: string;
		npm_config_npm_version: string;
		ITERM_PROFILE: string;
		EDITOR: string;
		XPC_FLAGS: string;
		npm_command: string;
		PYENV_SHELL: string;
		USER: string;
		GIT_EDITOR: string;
		__CFBundleIdentifier: string;
		__CF_USER_TEXT_ENCODING: string;
		npm_config_init_module: string;
		npm_execpath: string;
		npm_config_userconfig: string;
		LaunchInstanceID: string;
		SVELTEKIT_FORK: string;
		npm_node_execpath: string;
		_: string;
		TERM_SESSION_ID: string;
		TERM_FEATURES: string;
		PATH: string;
		CLAUDE_CODE_SESSION_ATTENDED: string;
		npm_package_engines_node: string;
		npm_package_json: string;
		npm_config_node_gyp: string;
		PWD: string;
		SECURITYSESSIONID: string;
		SSH_AUTH_SOCK: string;
		npm_config_globalconfig: string;
		COMMAND_MODE: string;
		API_TIMEOUT_MS: string;
		CDPATH: string;
		LOGNAME: string;
		ANTHROPIC_BASE_URL: string;
		npm_config_local_prefix: string;
		npm_package_name: string;
		npm_config_noproxy: string;
		LANG: string;
		CLAUDE_CODE_MESSAGING_TOKEN: string;
		CLAUDE_CODE_ENTRYPOINT: string;
		CLAUDE_CODE_CHILD_SESSION: string;
		SHELL: string;
		COLOR: string;
		ANTHROPIC_DEFAULT_HAIKU_MODEL: string;
		CLAUDECODE: string;
		npm_config_cache: string;
		LC_TERMINAL_VERSION: string;
		TERM_PROGRAM_VERSION: string;
		TMPDIR: string;
		TERM: string;
		NODE: string;
		COREPACK_ENABLE_AUTO_PIN: string;
		TERMINFO_DIRS: string;
		CLAUDE_PID: string;
		HOME: string;
		TERM_PROGRAM: string;
		COLORFGBG: string;
		INIT_CWD: string;
		CLAUDE_EFFORT: string;
		BUN_INSTALL: string;
		npm_config_global_prefix: string;
		NoDefaultCurrentDirectoryInExePath: string;
		npm_lifecycle_event: string;
		XPC_SERVICE_NAME: string;
		MAX_TOKENS: string;
		AI_AGENT: string;
		ASKTHEDOCS_MODE: string;
		[key: `PUBLIC_${string}`]: undefined;
		[key: `${string}`]: string | undefined;
	}
}

/**
 * This module provides access to environment variables set _dynamically_ at runtime and that are _publicly_ accessible.
 * 
 * |         | Runtime                                                                    | Build time                                                               |
 * | ------- | -------------------------------------------------------------------------- | ------------------------------------------------------------------------ |
 * | Private | [`$env/dynamic/private`](https://svelte.dev/docs/kit/$env-dynamic-private) | [`$env/static/private`](https://svelte.dev/docs/kit/$env-static-private) |
 * | Public  | [`$env/dynamic/public`](https://svelte.dev/docs/kit/$env-dynamic-public)   | [`$env/static/public`](https://svelte.dev/docs/kit/$env-static-public)   |
 * 
 * Dynamic environment variables are defined by the platform you're running on. For example if you're using [`adapter-node`](https://github.com/sveltejs/kit/tree/main/packages/adapter-node) (or running [`vite preview`](https://svelte.dev/docs/kit/cli)), this is equivalent to `process.env`.
 * 
 * **_Public_ access:**
 * 
 * - This module _can_ be imported into client-side code
 * - **Only** variables that begin with [`config.kit.env.publicPrefix`](https://svelte.dev/docs/kit/configuration#env) (which defaults to `PUBLIC_`) are included
 * 
 * > [!NOTE] In `dev`, `$env/dynamic` includes environment variables from `.env`. In `prod`, this behavior will depend on your adapter.
 * 
 * > [!NOTE] To get correct types, environment variables referenced in your code should be declared (for example in an `.env` file), even if they don't have a value until the app is deployed:
 * >
 * > ```env
 * > MY_FEATURE_FLAG=
 * > ```
 * >
 * > You can override `.env` values from the command line like so:
 * >
 * > ```sh
 * > MY_FEATURE_FLAG="enabled" npm run dev
 * > ```
 * 
 * For example, given the following runtime environment:
 * 
 * ```env
 * ENVIRONMENT=production
 * PUBLIC_BASE_URL=http://example.com
 * ```
 * 
 * With the default `publicPrefix` and `privatePrefix`:
 * 
 * ```ts
 * import { env } from '$env/dynamic/public';
 * console.log(env.ENVIRONMENT); // => undefined, not public
 * console.log(env.PUBLIC_BASE_URL); // => "http://example.com"
 * ```
 * 
 * ```
 * 
 * ```
 */
declare module '$env/dynamic/public' {
	export const env: {
		[key: `PUBLIC_${string}`]: string | undefined;
	}
}
