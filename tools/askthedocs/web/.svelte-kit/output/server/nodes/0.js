import * as universal from '../entries/pages/_layout.js';

export const index = 0;
let component_cache;
export const component = async () => component_cache ??= (await import('../entries/pages/_layout.svelte.js')).default;
export { universal };
export const universal_id = "src/routes/+layout.js";
export const imports = ["_app/immutable/nodes/0.BiF_HFkS.js","_app/immutable/chunks/Bh57Uu6y.js","_app/immutable/chunks/xihTtKlq.js"];
export const stylesheets = ["_app/immutable/assets/0.CTLn4kLC.css"];
export const fonts = ["_app/immutable/assets/sora-latin-400-normal.CRt88UEn.woff2","_app/immutable/assets/sora-latin-400-normal.OW7qkl5a.woff","_app/immutable/assets/sora-latin-600-normal.Cdg4DaK0.woff2","_app/immutable/assets/sora-latin-600-normal.1_7fyUAY.woff","_app/immutable/assets/ibm-plex-mono-latin-400-normal.DMJ8VG8y.woff2","_app/immutable/assets/ibm-plex-mono-latin-400-normal.CvHOgSBP.woff","_app/immutable/assets/ibm-plex-mono-latin-600-normal.BgSNZQsw.woff2","_app/immutable/assets/ibm-plex-mono-latin-600-normal.DWFSQ4vo.woff","_app/immutable/assets/source-serif-4-latin-400-normal.DJ5YJwmz.woff2","_app/immutable/assets/source-serif-4-latin-400-normal.Dn3IlU-Z.woff"];
