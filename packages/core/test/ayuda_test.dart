import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('lee una entrada del directorio', () {
    final e = EntradaAyuda.fromJson({
      'id': 'a1',
      'kind': 'refugio',
      'name': 'Refugio Ejemplo Pando',
      'phone': '099000011',
      'link': null,
      'is_sample': true,
    })!;
    expect(e.tipo, TipoAyuda.refugio);
    expect(e.telefono, '099000011');
    expect(e.enlace, isNull);
    expect(e.esEjemplo, isTrue);
  });

  test('un tipo desconocido (de una versión nueva) se omite', () {
    expect(
      EntradaAyuda.fromJson({'id': 'a2', 'kind': 'veterinaria', 'name': 'X'}),
      isNull,
    );
  });
}
