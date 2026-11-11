// Invitaciones al hogar (/unirme/<código>): la app vive en otra dirección
// (D156: huellamy.com es la landing y la app está en app.huellamy.com), así
// que los enlaces armados desde Android o iPhone con la dirección pública se
// pasan a la app con el mismo código.
'use strict';
(function () {
  const app = (window.SOS_CONFIG && window.SOS_CONFIG.appUrl) || '';
  const codigo = location.pathname.replace(/^\/unirme\/?/, '');
  // Solo letras, números y guiones: nada que pueda cambiar el destino.
  if (!/^https:\/\//.test(app) || !/^[A-Za-z0-9-]{1,64}$/.test(codigo)) return;
  const destino = app.replace(/\/+$/, '') + '/unirme/' + codigo;
  document.getElementById('seguir').href = destino;
  location.replace(destino);
})();
