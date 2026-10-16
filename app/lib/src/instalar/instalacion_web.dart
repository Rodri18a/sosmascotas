import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

import 'servicio_instalacion.dart';

ServicioInstalacion crearServicioInstalacion() => InstalacionWeb();

/// Lo que guarda `web/index.html` antes de que arranque Flutter
/// (`beforeinstallprompt` puede llegar antes que la app).
extension type _EstadoJs(JSObject _) implements JSObject {
  external JSObject? get aviso;
  external set aviso(JSObject? valor);
  external bool get instalada;
}

extension type _AvisoJs(JSObject _) implements JSObject {
  external JSPromise<JSAny?> prompt();
  external JSPromise<_EleccionJs> get userChoice;
}

extension type _EleccionJs(JSObject _) implements JSObject {
  external String get outcome;
}

@JS('sosInstalacion')
external _EstadoJs? get _estado;

/// Safari del iPhone: `true` si se abrió desde el ícono de inicio.
@JS('navigator.standalone')
external JSBoolean? get _standaloneSafari;

class InstalacionWeb implements ServicioInstalacion {
  InstalacionWeb() {
    web.window.addEventListener(
      'sos-instalacion',
      ((web.Event _) => _cambios.add(null)).toJS,
    );
  }

  final _cambios = StreamController<void>.broadcast();

  @override
  Stream<void> get cambios => _cambios.stream;

  @override
  bool get yaInstalada =>
      (_estado?.instalada ?? false) ||
      web.window.matchMedia('(display-mode: standalone)').matches ||
      _standaloneIos;

  bool get _standaloneIos => _standaloneSafari?.toDart ?? false;

  @override
  bool get puedeMostrarAviso => _estado?.aviso != null;

  @override
  bool get esIphone {
    final agente = web.window.navigator.userAgent;
    // Los iPad nuevos se presentan como Mac, pero tienen pantalla táctil.
    return RegExp('iPhone|iPad|iPod').hasMatch(agente) ||
        (agente.contains('Macintosh') &&
            web.window.navigator.maxTouchPoints > 1);
  }

  @override
  Future<bool> mostrarAviso() async {
    final estado = _estado;
    final aviso = estado?.aviso;
    if (estado == null || aviso == null) return false;
    // El aviso del navegador se puede usar una sola vez.
    estado.aviso = null;
    final avisoJs = _AvisoJs(aviso);
    await avisoJs.prompt().toDart;
    final eleccion = await avisoJs.userChoice.toDart;
    _cambios.add(null);
    return eleccion.outcome == 'accepted';
  }
}
