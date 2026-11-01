// Copiar como config.js y completar (config.js NO se sube al repositorio).
// Son datos públicos por diseño (la clave publishable viaja en cualquier app),
// pero se mantienen fuera del repo como el resto de la configuración.
window.SOS_CONFIG = {
  supabaseUrl: 'https://<proyecto>.supabase.co',
  supabaseKey: 'sb_publishable_...',
  // Cloudflare Turnstile (anti-bots). Clave de PRUEBA que siempre pasa:
  // reemplazar por la real antes del lanzamiento (ver docs/guias).
  turnstileSiteKey: '1x00000000000000000000AA',
  // Dirección de la app (botón "Conocé Huellitas" de la página del comercio).
  appUrl: 'https://sosmascota-dev.vercel.app',
};
