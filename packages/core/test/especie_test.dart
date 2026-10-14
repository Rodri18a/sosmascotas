import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('lee especies y razas de la base', () {
    final perro = Especie.fromJson({
      'id': 1,
      'slug': 'dog',
      'name': 'Perro',
      'icon': '🐶',
    });
    final raza = Raza.fromJson({'id': 7, 'species_id': 1, 'name': 'Mestizo'});

    expect(perro.nombre, 'Perro');
    expect(raza.especieId, perro.id);
  });
}
