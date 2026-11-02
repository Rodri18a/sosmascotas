import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Elige un PDF del celular o la computadora (historial de vida, D131).
/// Se reemplaza en las pruebas. Devuelve `null` si la persona cancela.
typedef SelectorDocumento = Future<Uint8List?> Function();

final selectorDocumentoProvider = Provider<SelectorDocumento>(
  (ref) => () async {
    final archivo = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: const ['pdf'],
    );
    return archivo?.readAsBytes();
  },
);

/// Si los bytes son de verdad un PDF (empiezan con «%PDF-»).
bool esPdfValido(Uint8List bytes) =>
    bytes.length > 5 &&
    bytes[0] == 0x25 &&
    bytes[1] == 0x50 &&
    bytes[2] == 0x44 &&
    bytes[3] == 0x46 &&
    bytes[4] == 0x2D;
