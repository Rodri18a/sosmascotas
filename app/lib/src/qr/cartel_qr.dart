import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Arma una imagen PNG para imprimir: el QR grande, el nombre de la mascota y
/// una indicación para quien la encuentre. Pensada para A6 / etiqueta.
Future<Uint8List> cartelQrPng({
  required String url,
  required String nombre,
  required String indicacion,
  required String codigo,
}) async {
  const ancho = 1200.0;
  const alto = 1500.0;
  const ladoQr = 900.0;
  final grabador = ui.PictureRecorder();
  final lienzo = Canvas(grabador)
    ..drawRect(
      const Rect.fromLTWH(0, 0, ancho, alto),
      Paint()..color = Colors.white,
    );

  void texto(String contenido, double y, double tamano, FontWeight peso) {
    final pintor = TextPainter(
      text: TextSpan(
        text: contenido,
        style: TextStyle(
          color: Colors.black,
          fontSize: tamano,
          fontWeight: peso,
        ),
      ),
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: ancho - 120);
    pintor.paint(lienzo, Offset((ancho - pintor.width) / 2, y));
  }

  texto(nombre, 70, 96, FontWeight.bold);
  lienzo
    ..save()
    ..translate((ancho - ladoQr) / 2, 240);
  // Corrección de errores alta: se sigue leyendo aunque la chapita se gaste.
  QrPainter(
    data: url,
    version: QrVersions.auto,
    errorCorrectionLevel: QrErrorCorrectLevel.H,
    gapless: true,
    eyeStyle: const QrEyeStyle(
      eyeShape: QrEyeShape.square,
      color: Colors.black,
    ),
    dataModuleStyle: const QrDataModuleStyle(
      dataModuleShape: QrDataModuleShape.square,
      color: Colors.black,
    ),
  ).paint(lienzo, const Size.square(ladoQr));
  lienzo.restore();
  texto(indicacion, 1190, 56, FontWeight.w600);
  texto(codigo, 1300, 44, FontWeight.normal);

  final imagen = await grabador.endRecording().toImage(
    ancho.toInt(),
    alto.toInt(),
  );
  final datos = await imagen.toByteData(format: ui.ImageByteFormat.png);
  imagen.dispose();
  return datos!.buffer.asUint8List();
}
