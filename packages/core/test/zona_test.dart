import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('da la misma celda que public.celda_zona() en la base', () {
    // Valores calculados con la función de la base (dev, 15/10/2026).
    const casos = [
      (Punto(-34.7171, -55.9581), Punto(-34.71525, -55.957628)),
      (Punto(-34.71249, -55.95751), Punto(-34.71075, -55.960058)),
      (Punto(40.4168, -3.7038), Punto(40.41675, -3.702968)),
      (Punto(0.0001, 0.0001), Punto(0.00225, 0.00225)),
    ];
    for (final (exacto, celda) in casos) {
      expect(zonaAproximada(exacto), celda, reason: '$exacto');
    }
  });

  test('el centro de una celda es su propia celda (la base no la mueve)', () {
    final celda = zonaAproximada(centroPando);
    expect(zonaAproximada(celda), celda);
  });

  test('nunca se aleja más de media celda (unos 350 m en diagonal)', () {
    for (var i = 0; i < 200; i++) {
      final p = Punto(-34.75 + i * 0.00037, -55.99 + i * 0.00041);
      expect(distanciaMetros(p, zonaAproximada(p)), lessThan(360));
    }
  });
}
