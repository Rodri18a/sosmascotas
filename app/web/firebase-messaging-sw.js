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

self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  let ruta = event.notification.data?.ruta || '/';
  // Lo del negocio se abre en Huellamy Comercios, que es otra app (D143).
  if (ruta.startsWith('/negocio')) ruta = '/comercios' + ruta;
  const destino = new URL(ruta, self.location.origin);
  // Solo rutas de la propia app.
  if (destino.origin !== self.location.origin) return;
  const esComercios = (url) => new URL(url).pathname.startsWith('/comercios/');

  event.waitUntil((async () => {
    const ventanas = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    const abierta = ventanas.find((v) => new URL(v.url).origin === destino.origin
      && esComercios(v.url) === esComercios(destino.href));
    if (abierta) {
      try {
        // navigate() solo funciona en ventanas que controla este service
        // worker; si no, se abre una nueva con la ruta.
        await abierta.navigate(destino.href);
        return abierta.focus();
      } catch (_) { /* sigue abajo */ }
    }
    return self.clients.openWindow(destino.href);
  })());
});
