import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sosmascota_core/sosmascota_core.dart';

/// Foto de prueba de [ancho]×[alto] con ubicación GPS y modelo de celular.
Uint8List _fotoConGps(int ancho, int alto) {
  final foto = img.Image(width: ancho, height: alto)
    ..exif.gpsIfd.gpsLatitude = -34.7171
    ..exif.gpsIfd.gpsLongitude = -55.9581
    ..exif.imageIfd.make = 'CelularDePrueba';
  img.fill(foto, color: img.ColorRgb8(200, 120, 40));
  return img.encodeJpg(foto);
}

void main() {
  test('la foto de prueba sí tiene GPS (control)', () {
    final original = img.decodeJpg(_fotoConGps(100, 80))!;
    expect(original.exif.gpsIfd.isEmpty, isFalse);
  });

  test('le quita la ubicación GPS y el resto del EXIF', () {
    final lista = _fotoConGps(100, 80);
    final preparada = prepararFoto(lista)!;
    final resultado = img.decodeJpg(preparada)!;

    expect(resultado.exif.gpsIfd.isEmpty, isTrue);
    expect(resultado.exif.imageIfd.make, isNull);
    expect(resultado.exif.isEmpty, isTrue);
  });

  test('achica las fotos grandes manteniendo la proporción', () {
    final preparada = prepararFoto(_fotoConGps(3000, 2000))!;
    final resultado = img.decodeJpg(preparada)!;

    expect(resultado.width, ladoMaximoFoto);
    expect(resultado.height, closeTo(853, 1));
  });

  test('no agranda las fotos chicas', () {
    final resultado = img.decodeJpg(prepararFoto(_fotoConGps(300, 400))!)!;

    expect((resultado.width, resultado.height), (300, 400));
  });

  test('devuelve null si no es una imagen', () {
    expect(prepararFoto(Uint8List.fromList([1, 2, 3, 4])), isNull);
  });
}
