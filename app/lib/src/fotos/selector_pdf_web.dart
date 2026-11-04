import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

/// Elige un PDF en la web con un `<input type="file">` propio.
///
/// El de `file_picker` da por cancelado el pedido cuando la ventana vuelve a
/// tener el foco, y en el iPhone (sobre todo en la app instalada) el archivo
/// llega bastante después: el PDF nunca se sumaba. Acá solo se cancela con
/// el evento `cancel` del propio campo.
Future<Uint8List?> elegirPdf() {
  final listo = Completer<Uint8List?>();
  final campo = web.HTMLInputElement()
    ..type = 'file'
    ..accept = 'application/pdf,.pdf'
    ..style.display = 'none';
  // Safari no avisa el `change` si el campo no está en la página.
  web.document.body?.append(campo);

  void terminar(Uint8List? bytes) {
    if (!listo.isCompleted) listo.complete(bytes);
    campo.remove();
  }

  campo
    ..addEventListener(
      'change',
      ((web.Event _) async {
        final archivo = campo.files?.item(0);
        if (archivo == null) return terminar(null);
        try {
          final datos = await archivo.arrayBuffer().toDart;
          terminar(datos.toDart.asUint8List());
        } on Object {
          terminar(null);
        }
      }).toJS,
    )
    ..addEventListener('cancel', ((web.Event _) => terminar(null)).toJS)
    ..click();
  return listo.future;
}
