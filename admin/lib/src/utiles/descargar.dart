import 'dart:typed_data';

import 'descargar_otro.dart'
    if (dart.library.js_interop) 'descargar_web.dart'
    as plataforma;

/// Descarga un archivo (en la web, como cualquier descarga del navegador).
/// Devuelve `false` si la plataforma todavía no lo permite.
bool descargarArchivo(Uint8List bytes, String nombre, String tipo) =>
    plataforma.descargarArchivo(bytes, nombre, tipo);

/// Abre [url] en otra pestaña del navegador.
void abrirEnlace(String url) => plataforma.abrirEnlace(url);

/// Una imagen que eligió la persona: sus bytes y su tipo (`image/png`, …).
typedef ImagenElegida = ({Uint8List bytes, String tipo});

/// Abre el selector de archivos del navegador para elegir una imagen PNG,
/// JPEG o WebP. Devuelve null si se canceló o la plataforma no lo permite.
Future<ImagenElegida?> elegirImagen() => plataforma.elegirImagen();
