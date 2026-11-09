import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Colores fijos del logo (guía de Huellamy, D146): no cambian con el tema.
abstract final class ColoresLogo {
  /// Mancha celeste de fondo y huella azul profundo: app de las personas.
  static const fondo = Color(0xFFBFE3FA);
  static const huella = Color(0xFF0B4F94);

  /// Al revés para Huellamy Comercios: huella blanca sobre azul profundo.
  static const fondoComercio = Color(0xFF0B4F94);
  static const huellaComercio = Color(0xFFFFFFFF);

  /// «Huell» en azul profundo y «amy» en azul brillante, como en el logo.
  static const nombre = Color(0xFF0B4F94);
  static const nombreAcento = Color(0xFF1AA0EA);
}

/// Isotipo de Huellamy: la huella azul sobre una mancha redonda celeste.
///
/// [color] es el de la huella y [fondo] el de la mancha
/// ([ColoresLogo.huellaComercio] y [ColoresLogo.fondoComercio] para los
/// comercios). Con [tinta], solo la huella, de ese color y sin mancha.
class Isotipo extends StatelessWidget {
  const Isotipo({
    this.tamanio = 48,
    this.color = ColoresLogo.huella,
    this.fondo = ColoresLogo.fondo,
    this.tinta,
    super.key,
  });

  final double tamanio;
  final Color color;
  final Color fondo;
  final Color? tinta;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: tamanio,
    child: CustomPaint(
      painter: PintorIsotipo(color: color, fondo: fondo, tinta: tinta),
    ),
  );
}

/// Dibuja el isotipo en un cuadrado (lo usan la app, el portal de administración y el generador de íconos,
/// `app/tool/iconos_marca_test.dart`).
class PintorIsotipo extends CustomPainter {
  const PintorIsotipo({
    this.color = ColoresLogo.huella,
    this.fondo = ColoresLogo.fondo,
    this.tinta,
  });

  final Color color;
  final Color? fondo;
  final Color? tinta;

  /// El dibujo está pensado en un cuadrado de 200 × 200.
  static const _lado = 200.0;

  /// Mancha redonda de fondo.
  static Path get mancha =>
      Path()
        ..addOval(Rect.fromCircle(center: const Offset(100, 100), radius: 96));

  /// La huella agrandada y centrada en la mancha.
  static Path get huellaCentrada => huella.transform(
    (Matrix4.identity()
          ..translateByDouble(100, 101, 0, 1)
          ..scaleByDouble(1.38, 1.38, 1, 1)
          ..translateByDouble(-100, -90.5, 0, 1))
        .storage,
  );

  /// Almohadilla y cuatro dedos (sin agrandar).
  static Path get huella {
    final almohadilla = Path()
      ..moveTo(100, 88)
      ..cubicTo(116, 88, 130, 102, 132, 114)
      ..cubicTo(134, 126, 124, 132, 114, 130)
      ..cubicTo(108, 128, 106, 126, 100, 126)
      ..cubicTo(94, 126, 92, 128, 86, 130)
      ..cubicTo(76, 132, 66, 126, 68, 114)
      ..cubicTo(70, 102, 84, 88, 100, 88)
      ..close();
    Rect dedo(double x, double y, double r) =>
        Rect.fromCircle(center: Offset(x, y), radius: r);
    return Path()
      ..addOval(dedo(67, 80, 10))
      ..addOval(dedo(86, 60, 11))
      ..addOval(dedo(114, 60, 11))
      ..addOval(dedo(133, 80, 10))
      ..addPath(almohadilla, Offset.zero);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final escala = math.min(size.width, size.height) / _lado;
    canvas
      ..save()
      ..translate(
        (size.width - _lado * escala) / 2,
        (size.height - _lado * escala) / 2,
      )
      ..scale(escala);
    final tinta = this.tinta;
    if (tinta != null) {
      canvas.drawPath(huellaCentrada, Paint()..color = tinta);
    } else {
      if (fondo case final fondo?) {
        canvas.drawPath(mancha, Paint()..color = fondo);
      }
      canvas.drawPath(huellaCentrada, Paint()..color = color);
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PintorIsotipo anterior) =>
      anterior.color != color ||
      anterior.fondo != fondo ||
      anterior.tinta != tinta;
}
