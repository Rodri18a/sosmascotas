import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  const pando = Limites(
    minLat: -34.75,
    minLng: -56.0,
    maxLat: -34.70,
    maxLng: -55.9,
  );

  test('agrandar mantiene el centro y contiene al original', () {
    final grande = pando.agrandado(1.5);

    expect(grande.contiene(pando), isTrue);
    expect(grande.centro.lat, closeTo(pando.centro.lat, 1e-9));
    expect(
      grande.maxLat - grande.minLat,
      closeTo((pando.maxLat - pando.minLat) * 1.5, 1e-9),
    );
  });

  test('distancia entre Pando y Montevideo (≈ 30 km)', () {
    const montevideo = Punto(-34.9011, -56.1645);
    expect(distanciaMetros(centroPando, montevideo), closeTo(28000, 3000));
    expect(distanciaMetros(centroPando, centroPando), 0);
  });
}
