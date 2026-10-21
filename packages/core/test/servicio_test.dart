import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('el servicio se lee de la base (precio como texto o número)', () {
    final s = Servicio.fromJson({
      'id': 's1',
      'name': 'Baño y corte',
      'price': '600.00',
      'price_from': true,
      'duration_min': 90,
      'species_ids': [1],
    });
    expect(s.precio, 600);
    expect(s.desde, isTrue);
    expect(s.duracionMinutos, 90);
    expect(s.especieIds, [1]);
    expect(s.disponible, isTrue);
    expect(s.soloConsultar, isFalse);
  });

  test('sin precio: solo "Consultar" y nunca "desde"', () {
    const s = Servicio(id: '', nombre: 'Consulta a domicilio', desde: true);
    expect(s.soloConsultar, isTrue);
    final json = s.toJson();
    expect(json['id'], isNull);
    expect(json['price'], isNull);
    expect(json['price_from'], isFalse);
  });
}
