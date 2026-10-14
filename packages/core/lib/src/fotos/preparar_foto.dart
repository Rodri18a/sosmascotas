import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Lado mayor máximo de una foto subida (px).
const ladoMaximoFoto = 1280;

/// Prepara una foto para subirla:
/// 1. La endereza según la orientación que guardó el celular.
/// 2. La achica a [ladoMaximo] px de lado mayor.
/// 3. **Le quita todos los metadatos EXIF** (incluida la ubicación GPS: regla
///    del proyecto, una foto no puede revelar dónde vive la mascota).
/// 4. La guarda como JPEG de calidad 80 (≈ 100–300 KB).
///
/// Devuelve `null` si los bytes no son una imagen.
Uint8List? prepararFoto(Uint8List original, {int ladoMaximo = ladoMaximoFoto}) {
  final decodificada = img.decodeImage(original);
  if (decodificada == null) return null;

  var foto = img.bakeOrientation(decodificada);
  if (foto.width > ladoMaximo || foto.height > ladoMaximo) {
    foto = foto.width >= foto.height
        ? img.copyResize(
            foto,
            width: ladoMaximo,
            interpolation: img.Interpolation.average,
          )
        : img.copyResize(
            foto,
            height: ladoMaximo,
            interpolation: img.Interpolation.average,
          );
  }
  foto.exif =
      img.ExifData(); // Sin EXIF: ni GPS, ni modelo de celular, ni fecha.
  return img.encodeJpg(foto, quality: 80);
}
