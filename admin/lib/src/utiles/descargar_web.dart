import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

bool descargarArchivo(Uint8List bytes, String nombre, String tipo) {
  final blob = web.Blob([bytes.toJS].toJS, web.BlobPropertyBag(type: tipo));
  final url = web.URL.createObjectURL(blob);
  final enlace = web.HTMLAnchorElement()
    ..href = url
    ..download = nombre;
  web.document.body?.append(enlace);
  enlace.click();
  enlace.remove();
  web.URL.revokeObjectURL(url);
  return true;
}

void abrirEnlace(String url) => web.window.open(url, '_blank', 'noopener');

Future<({Uint8List bytes, String tipo})?> elegirImagen() {
  final listo = Completer<({Uint8List bytes, String tipo})?>();
  final entrada = web.HTMLInputElement()
    ..type = 'file'
    ..accept = 'image/png,image/jpeg,image/webp';
  entrada.onchange = (web.Event _) {
    final archivo = entrada.files?.item(0);
    if (archivo == null) {
      listo.complete(null);
      return;
    }
    archivo.arrayBuffer().toDart.then(
      (datos) => listo.complete((
        bytes: datos.toDart.asUint8List(),
        tipo: archivo.type,
      )),
      onError: (Object _) => listo.complete(null),
    );
  }.toJS;
  entrada.oncancel = (web.Event _) {
    if (!listo.isCompleted) listo.complete(null);
  }.toJS;
  entrada.click();
  return listo.future;
}
