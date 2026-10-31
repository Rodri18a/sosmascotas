import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Colores fijos del logo (guía de marca, D122): no cambian con el tema.
abstract final class ColoresLogo {
  static const pinArriba = Color(0xFF6FBDE0);
  static const pinAbajo = Color(0xFF3D95C2);
  static const aro = Color(0xFF8DCDE6);
  static const huella = Color(0xFFFFFFFF);
  static const nombre = Color(0xFF0F5E7A);
}

/// Isotipo de SOS Mascotas: pin con una huella adentro y un aro abajo.
///
/// A color por defecto; con [tinta], de una sola tinta (negro, blanco o el
/// color que se pase) con la huella calada, como en la guía de marca.
class Isotipo extends StatelessWidget {
  const Isotipo({this.tamanio = 48, this.tinta, super.key});

  final double tamanio;
  final Color? tinta;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: tamanio,
    child: CustomPaint(painter: PintorIsotipo(tinta: tinta)),
  );
}

/// Dibuja el isotipo en un cuadrado (lo usan la app, el portal de administración y el generador de íconos,
/// `app/tool/iconos_marca_test.dart`).
class PintorIsotipo extends CustomPainter {
  const PintorIsotipo({this.tinta});

  final Color? tinta;

  /// El dibujo está pensado en un cuadrado de 200 × 200.
  static const _lado = 200.0;

  static Path get pin => Path()
    ..moveTo(100, 162)
    ..cubicTo(90, 148, 38, 122, 38, 80)
    ..arcToPoint(
      const Offset(162, 80),
      radius: const Radius.circular(62),
      largeArc: true,
    )
    ..cubicTo(162, 122, 110, 148, 100, 162)
    ..close();

  static Path get huella {
    Path dedo(double x, double y, double grados) {
      final giro = Matrix4.identity()
        ..translateByDouble(x, y, 0, 1)
        ..rotateZ(grados * math.pi / 180);
      return (Path()..addOval(
            Rect.fromCenter(center: Offset.zero, width: 20, height: 27),
          ))
          .transform(giro.storage);
    }

    // Almohadilla: triángulo redondeado, más ancho abajo.
    final almohadilla = Path()
      ..moveTo(100, 82)
      ..cubicTo(114, 82, 134, 102, 134, 114)
      ..cubicTo(134, 127, 118, 127, 100, 123)
      ..cubicTo(82, 127, 66, 127, 66, 114)
      ..cubicTo(66, 102, 86, 82, 100, 82)
      ..close();
    return Path()
      ..addPath(dedo(66, 74, -28), Offset.zero)
      ..addPath(dedo(87, 53, -8), Offset.zero)
      ..addPath(dedo(113, 53, 8), Offset.zero)
      ..addPath(dedo(134, 74, 28), Offset.zero)
      ..addPath(almohadilla, Offset.zero);
  }

  /// La parte de abajo de una elipse, alrededor de la punta del pin.
  static Path get aro => Path()
    ..addArc(
      Rect.fromCenter(center: const Offset(100, 150), width: 150, height: 46),
      0.03 * math.pi,
      0.94 * math.pi,
    );

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
    final trazoAro = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round;
    final tinta = this.tinta;
    if (tinta == null) {
      final degrade = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [ColoresLogo.pinArriba, ColoresLogo.pinAbajo],
      ).createShader(const Rect.fromLTWH(38, 18, 124, 144));
      canvas
        ..drawPath(aro, trazoAro..color = ColoresLogo.aro)
        ..drawPath(pin, Paint()..shader = degrade)
        ..drawPath(huella, Paint()..color = ColoresLogo.huella);
    } else {
      // Una tinta: la huella se cala (deja ver el fondo).
      canvas
        ..drawPath(aro, trazoAro..color = tinta)
        ..drawPath(
          Path.combine(PathOperation.difference, pin, huella),
          Paint()..color = tinta,
        );
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(PintorIsotipo anterior) => anterior.tinta != tinta;
}
