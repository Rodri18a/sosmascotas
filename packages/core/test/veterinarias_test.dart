import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('un socio trae lo mínimo y su próximo control', () {
    final s = Socio.fromJson({
      'pet_id': 'p1',
      'nombre': 'Toby',
      'especie': 1,
      'duenio': 'Ana',
      'proximo': '2026-11-10',
      'proximo_que': 'Vacuna antirrábica',
    });
    expect(s.duenio, 'Ana');
    expect(s.vencePronto(DateTime(2026, 10, 20)), isTrue);
    expect(s.vencePronto(DateTime(2026, 8, 1)), isFalse);
    expect(
      Socio.fromJson({
        'pet_id': 'p2',
        'nombre': 'Mishi',
        'especie': 2,
        'duenio': '',
      }).duenio,
      isNull,
    );
  });

  test('propuestas: estado y pendiente', () {
    final p = Propuesta.fromJson({
      'proposal_id': 'x',
      'business_id': 'b',
      'negocio': 'Vet',
      'message': 'Primera consulta sin cargo',
      'status': 'seen',
      'created_at': '2026-10-18T12:00:00Z',
    });
    expect(p.estado, EstadoPropuesta.vista);
    expect(p.pendiente, isTrue);
  });

  test('estado de búsqueda sin respuesta (no es mi mascota)', () {
    final e = EstadoBusqueda.fromJson(null);
    expect(e.buscando, isFalse);
    expect(e.preguntar, isFalse);
  });
}
