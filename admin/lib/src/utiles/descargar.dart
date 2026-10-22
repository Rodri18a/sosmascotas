import 'dart:typed_data';

import 'descargar_otro.dart'
    if (dart.library.js_interop) 'descargar_web.dart'
    as plataforma;

/// Descarga un archivo (en la web, como cualquier descarga del navegador).
/// Devuelve `false` si la plataforma todavía no lo permite.
bool descargarArchivo(Uint8List bytes, String nombre, String tipo) =>
    plataforma.descargarArchivo(bytes, nombre, tipo);
