import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'avisador.dart';

AvisadorRecordatorios crearAvisador() => AvisadorWeb();

/// El constructor `Notification` (no existe en algunos navegadores, por
/// ejemplo Safari del iPhone sin instalar la app).
@JS('Notification')
external JSAny? get _notificacionJs;

/// Avisos con la API de notificaciones del navegador, mientras la app está
/// abierta (D67). Se muestran con el service worker de Firebase, así tocarlos
/// lleva a la ficha de la mascota igual que un aviso push.
class AvisadorWeb implements AvisadorRecordatorios {
  final _pendientes = <String, Timer>{};
  final _mostrados = <String>{};

  bool get _hayNotificaciones =>
      _notificacionJs != null && web.window.isSecureContext;

  @override
  Future<PermisoAvisos> permiso() async {
    if (!_hayNotificaciones) return PermisoAvisos.noDisponible;
    return switch (web.Notification.permission) {
      'granted' => PermisoAvisos.concedido,
      'denied' => PermisoAvisos.bloqueado,
      _ => PermisoAvisos.sinPedir,
    };
  }

  @override
  Future<PermisoAvisos> pedirPermiso() async {
    if (!_hayNotificaciones) return PermisoAvisos.noDisponible;
    await web.Notification.requestPermission().toDart;
    return permiso();
  }

  @override
  void programar(List<AvisoProgramado> avisos) {
    for (final timer in _pendientes.values) {
      timer.cancel();
    }
    _pendientes.clear();
    final ahora = DateTime.now();
    for (final aviso in avisos) {
      if (_mostrados.contains(aviso.id)) continue;
      final falta = aviso.cuando.difference(ahora);
      if (falta.isNegative) continue;
      _pendientes[aviso.id] = Timer(falta, () => _mostrar(aviso));
    }
  }

  Future<void> _mostrar(AvisoProgramado aviso) async {
    _pendientes.remove(aviso.id);
    _mostrados.add(aviso.id);
    if (await permiso() != PermisoAvisos.concedido) return;
    final opciones = web.NotificationOptions(
      body: aviso.cuerpo,
      icon: '/icons/Icon-192.png',
      badge: '/icons/Icon-maskable-192.png',
      tag: aviso.id,
      data: {'ruta': aviso.ruta}.jsify(),
    );
    try {
      final registro = await web.window.navigator.serviceWorker
          .getRegistration('/firebase-cloud-messaging-push-scope')
          .toDart;
      if (registro != null) {
        await registro.showNotification(aviso.titulo, opciones).toDart;
        return;
      }
    } on Object {
      // Sin service worker: aviso simple de la página (abajo).
    }
    web.Notification(aviso.titulo, opciones);
  }
}
