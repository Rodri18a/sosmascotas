import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/painting.dart';

import 'mapa_vista.dart';

/// Dibuja un pin en forma de gota con ícono (D82, D122) como PNG, a [escala] píxeles por punto
/// (la densidad de la pantalla, para que se vea nítido). Lo usa el motor del
/// mapa para registrar cada imagen una sola vez; sirve igual para Google Maps
/// nativo (1.2.2).
Future<Uint8List> dibujarPin(AspectoPin aspecto, {double escala = 1}) async {
  final ancho = (aspecto.diametro * escala).ceil();
  final alto = (aspecto.alto * escala).ceil();
  final grabador = ui.PictureRecorder();
  final lienzo = Canvas(grabador)..scale(escala);
  final radio = aspecto.diametro / 2;
  final centro = Offset(radio, radio);
  final gota = gotaPin(aspecto.diametro, aspecto.grosorBorde);
  lienzo
    ..drawPath(gota, Paint()..color = aspecto.fondo)
    ..drawPath(
      gota,
      Paint()
        ..color = aspecto.borde
        ..style = PaintingStyle.stroke
        ..strokeWidth = aspecto.grosorBorde
        ..strokeJoin = StrokeJoin.round,
    );
  final icono = aspecto.icono;
  final texto = TextPainter(
    text: switch (aspecto.texto) {
      final texto? => TextSpan(
        text: texto,
        style: TextStyle(
          fontFamily: 'Sora',
          fontWeight: FontWeight.w700,
          fontSize: aspecto.diametro * 0.42,
          color: aspecto.colorIcono,
          height: 1,
        ),
      ),
      null => TextSpan(
        text: String.fromCharCode(icono.codePoint),
        style: TextStyle(
          fontFamily: icono.fontFamily,
          package: icono.fontPackage,
          fontSize: aspecto.diametro * 0.58,
          color: aspecto.colorIcono,
          height: 1,
        ),
      ),
    },
    textDirection: TextDirection.ltr,
  )..layout();
  texto.paint(lienzo, centro - Offset(texto.width / 2, texto.height / 2));
  texto.dispose();
  final imagen = await grabador.endRecording().toImage(ancho, alto);
  final datos = await imagen.toByteData(format: ui.ImageByteFormat.png);
  imagen.dispose();
  return datos!.buffer.asUint8List();
}
