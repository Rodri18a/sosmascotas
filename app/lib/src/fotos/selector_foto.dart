import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

enum OrigenFoto { camara, galeria }

/// Elige una foto del celular (o de la computadora, en la web).
/// Se reemplaza en las pruebas. Devuelve `null` si la persona cancela.
typedef SelectorFoto = Future<Uint8List?> Function(OrigenFoto origen);

final selectorFotoProvider = Provider<SelectorFoto>(
  (ref) => (origen) async {
    final archivo = await ImagePicker().pickImage(
      source: origen == OrigenFoto.camara
          ? ImageSource.camera
          : ImageSource.gallery,
      // Primer achique en el dispositivo (rápido); después prepararFoto
      // termina el trabajo y quita el EXIF.
      maxWidth: 2048,
      maxHeight: 2048,
    );
    return archivo?.readAsBytes();
  },
);
