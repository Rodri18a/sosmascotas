// Genera los íconos de la app desde el isotipo (guía de marca, D122).
// No corre con las pruebas: se usa a mano cuando cambia el logo, desde app/:
//   flutter test tool/iconos_marca_test.dart
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Fondo del ícono de la app: celeste del logo, un poco más oscuro abajo.
const _fondoArriba = Color(0xFF8FD0E8);
const _fondoAbajo = Color(0xFF4FA3CB);

enum _Forma {
  /// Cuadrado redondeado (web, favicon, Android).
  redondeado,

  /// Cuadrado lleno: el sistema le pone la forma (iPhone, maskable).
  lleno,

  /// Solo el isotipo a color, con fondo transparente (PDF, web pública).
  isotipo,
}

Future<void> _escribir(String ruta, int lado, _Forma forma) async {
  final grabador = ui.PictureRecorder();
  final lienzo = Canvas(grabador);
  final l = lado.toDouble();
  final todo = Rect.fromLTWH(0, 0, l, l);
  if (forma == _Forma.isotipo) {
    const PintorIsotipo().paint(lienzo, todo.size);
  } else {
    final fondo = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [_fondoArriba, _fondoAbajo],
      ).createShader(todo);
    if (forma == _Forma.redondeado) {
      lienzo.drawRRect(
        RRect.fromRectAndRadius(todo, Radius.circular(l * 0.22)),
        fondo,
      );
    } else {
      lienzo.drawRect(todo, fondo);
    }
    // En los «llenos» el sistema recorta: el dibujo va en la zona segura.
    final margen = l * (forma == _Forma.lleno ? 0.2 : 0.12);
    lienzo
      ..save()
      ..translate(margen, margen);
    const PintorIsotipo(
      tinta: Colors.white,
    ).paint(lienzo, Size.square(l - 2 * margen));
    lienzo.restore();
  }
  final imagen = await grabador.endRecording().toImage(lado, lado);
  final datos = await imagen.toByteData(format: ui.ImageByteFormat.png);
  File(ruta)
    ..createSync(recursive: true)
    ..writeAsBytesSync(datos!.buffer.asUint8List());
}

void main() {
  test('genera los íconos de la marca', () async {
    final ios = Directory('ios/Runner/Assets.xcassets/AppIcon.appiconset');
    final tamaniosIos = RegExp(r'Icon-App-([\d.]+)x[\d.]+@(\d)x\.png$');
    final archivos = <(String, int, _Forma)>[
      ('web/favicon.png', 48, _Forma.redondeado),
      ('web/icons/Icon-192.png', 192, _Forma.redondeado),
      ('web/icons/Icon-512.png', 512, _Forma.redondeado),
      ('web/icons/Icon-maskable-192.png', 192, _Forma.lleno),
      ('web/icons/Icon-maskable-512.png', 512, _Forma.lleno),
      ('web/icons/apple-touch-icon.png', 180, _Forma.lleno),
      ('web/icons/isotipo.png', 192, _Forma.isotipo),
      ('assets/marca/isotipo.png', 512, _Forma.isotipo),
      ('../web-publica/assets/isotipo.png', 96, _Forma.isotipo),
      for (final (carpeta, lado) in const [
        ('mdpi', 48),
        ('hdpi', 72),
        ('xhdpi', 96),
        ('xxhdpi', 144),
        ('xxxhdpi', 192),
      ])
        (
          'android/app/src/main/res/mipmap-$carpeta/ic_launcher.png',
          lado,
          _Forma.redondeado,
        ),
      if (ios.existsSync())
        for (final archivo in ios.listSync().whereType<File>())
          if (tamaniosIos.firstMatch(archivo.path) case final m?)
            (
              archivo.path,
              (double.parse(m[1]!) * int.parse(m[2]!)).round(),
              _Forma.lleno,
            ),
    ];
    for (final (ruta, lado, forma) in archivos) {
      await _escribir(ruta, lado, forma);
    }
  });
}
