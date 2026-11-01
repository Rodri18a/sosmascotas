import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Colores fijos del logo (guía visual de Huellitas, D126): no cambian con el tema.
abstract final class ColoresLogo {
  /// Globo de la app de las personas (celeste profundo).
  static const globo = Color(0xFF1E9BD7);

  /// Globo de la app de los comercios (azul).
  static const globoComercio = Color(0xFF1F4FD1);

  static const huella = Color(0xFFFFFFFF);
  static const nombre = Color(0xFF13294B);
}

/// Isotipo de Huellitas: globo de conversación de un solo color con una
/// huella blanca adentro.
///
/// [color] es el del globo (celeste por defecto; [ColoresLogo.globoComercio]
/// para los comercios). Con [tinta], de una sola tinta con la huella calada.
class Isotipo extends StatelessWidget {
  const Isotipo({
    this.tamanio = 48,
    this.color = ColoresLogo.globo,
    this.tinta,
    super.key,
  });

  final double tamanio;
  final Color color;
  final Color? tinta;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: tamanio,
    child: CustomPaint(
      painter: PintorIsotipo(color: color, tinta: tinta),
    ),
  );
}

/// Dibuja el isotipo en un cuadrado (lo usan la app, el portal de administración y el generador de íconos,
/// `app/tool/iconos_marca_test.dart`).
class PintorIsotipo extends CustomPainter {
  const PintorIsotipo({this.color = ColoresLogo.globo, this.tinta});

  final Color color;
  final Color? tinta;

  /// El dibujo está pensado en un cuadrado de 200 × 200.
  static const _lado = 200.0;

  /// Globo con esquinas redondeadas y la cola abajo a la izquierda.
  static Path get globo => Path()
    ..moveTo(60, 20)
    ..lineTo(140, 20)
    ..arcToPoint(const Offset(180, 60), radius: const Radius.circular(40))
    ..lineTo(180, 120)
    ..arcToPoint(const Offset(140, 160), radius: const Radius.circular(40))
    ..lineTo(84, 160)
    ..lineTo(48, 186)
    ..lineTo(54, 158)
    ..arcToPoint(const Offset(20, 120), radius: const Radius.circular(40))
    ..lineTo(20, 60)
    ..arcToPoint(const Offset(60, 20), radius: const Radius.circular(40))
    ..close();

  /// Almohadilla y cuatro dedos, centrados en el globo.
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
    if (tinta == null) {
      canvas
        ..drawPath(globo, Paint()..color = color)
        ..drawPath(huella, Paint()..color = ColoresLogo.huella);
    } else {
      // Una tinta: la huella se cala (deja ver el fondo).
      canvas.drawPath(
        Path.combine(PathOperation.difference, globo, huella),
        Paint()..color = tinta,
      );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PintorIsotipo anterior) =>
      anterior.color != color || anterior.tinta != tinta;
}
