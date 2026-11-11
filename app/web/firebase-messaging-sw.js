// Avisos push de Huellamy (paso 0.6.1).
//
// Firebase registra este archivo al pedir el token. FCM entrega Web Push
// estándar, así que no hace falta cargar el SDK de Firebase acá (ni su
// configuración): se muestra la notificación siempre, con la app abierta o
// cerrada, para que ningún aviso se pierda.
//
// Mensaje esperado (FCM HTTP v1, webpush):
//   notification: { title, body, image? }
//   data: { ruta?: "/sos/<id>" }        → adónde lleva al tocarla
//   fcmOptions: { link? }               → alternativa a data.ruta
'use strict';

self.addEventListener('push', (event) => {
  let mensaje = {};
  try {
    mensaje = event.data ? event.data.json() : {};
  } catch (_) {
    mensaje = { notification: { body: event.data && event.data.text() } };
  }
  const notificacion = mensaje.notification || {};
  const datos = mensaje.data || {};
  const titulo = notificacion.title || datos.titulo || 'Huellamy';
  const ruta = datos.ruta || (mensaje.fcmOptions && mensaje.fcmOptions.link) || '/avisos';

  event.waitUntil(
    self.registration.showNotification(titulo, {
      body: notificacion.body || datos.cuerpo || '',
      icon: '/icons/Icon-192.png',
      badge: '/icons/Icon-maskable-192.png',
      image: notificacion.image,
      // Un aviso nuevo del mismo asunto reemplaza al anterior.
      tag: datos.tag || mensaje.fcmMessageId,
      data: { ruta },
    }),
  );
});

// Cada app vive en su dirección (D156): Huellamy en app.huellamy.com y
// Huellamy Comercios en comercios.huellamy.com. tool/armar_web.sh cambia estas
// marcas por la dirección de la otra app y por si esta es la de comercios;
// sin cambiar (flutter run), todo se abre acá mismo.
const OTRA_APP = '__OTRA_APP_URL__';
const ES_COMERCIOS = '__ES_COMERCIOS__' === 'si';

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  const ruta = event.notification.data?.ruta || '/';
  // Lo del negocio se abre en Huellamy Comercios y lo demás en Huellamy (D143).
  const delNegocio = ruta.startsWith('/negocio');
  const base = OTRA_APP.startsWith('http') && delNegocio !== ES_COMERCIOS
    ? OTRA_APP
    : self.location.origin;
  const destino = new URL(ruta, base);
  // Solo rutas de las apps propias.
  if (destino.origin !== new URL(base).origin) return;

  event.waitUntil((async () => {
    if (destino.origin === self.location.origin) {
      const ventanas = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
      const abierta = ventanas.find((v) => new URL(v.url).origin === destino.origin);
      if (abierta) {
        try {
          // navigate() solo funciona en ventanas que controla este service
          // worker; si no, se abre una nueva con la ruta.
          await abierta.navigate(destino.href);
          return abierta.focus();
        } catch (_) { /* sigue abajo */ }
      }
    }
    return self.clients.openWindow(destino.href);
  })());
});
