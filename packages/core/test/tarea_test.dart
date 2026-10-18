import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('lee y escribe household_tasks', () {
    final t = Tarea.fromJson({
      'id': 't1',
      'pet_id': 'm1',
      'kind': 'walk',
      'day': '2026-10-18',
      'note': null,
      'assigned_to': 'u2',
      'created_by': 'u1',
      'done_by': 'u2',
      'done_at': '2026-10-18T21:05:00Z',
    });
    expect(t.tipo, TipoTarea.walk);
    expect(t.dia, DateTime(2026, 10, 18));
    expect(t.hecha, isTrue);
    expect(t.hechaEn, DateTime.utc(2026, 10, 18, 21, 5).toLocal());
    expect(t.toJson(), {
      'pet_id': 'm1',
      'kind': 'walk',
      'note': null,
      'day': '2026-10-18',
      'assigned_to': 'u2',
    });
  });

  test('ordena: las mías pendientes, las de otros y al final las hechas', () {
    Tarea t(String id, TipoTarea tipo, {String? para, String? hechaPor}) =>
        Tarea(
          id: id,
          mascotaId: 'm1',
          tipo: tipo,
          dia: DateTime(2026, 10, 18),
          asignadaA: para,
          hechaPor: hechaPor,
        );
    final orden = ordenarTareas([
      t('hecha', TipoTarea.walk, para: 'u1', hechaPor: 'u1'),
      t('de beto', TipoTarea.walk, para: 'u2'),
      t('mia comida', TipoTarea.food, para: 'u1'),
      t('mia paseo', TipoTarea.walk, para: 'u1'),
    ], 'u1');
    expect(orden.map((x) => x.id), [
      'mia paseo',
      'mia comida',
      'de beto',
      'hecha',
    ]);
  });
}
