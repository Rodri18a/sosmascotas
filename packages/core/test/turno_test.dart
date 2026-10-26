import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('un turno de Mis turnos y cuándo se puede cancelar', () {
    final t = Turno.fromJson({
      'id': 't1',
      'business_id': 'b1',
      'business_name': 'Peluquería Luna',
      'service_name': 'Baño y corte',
      'pet_name': 'Toby',
      'starts_at': '2026-10-27T12:00:00+00:00',
      'ends_at': '2026-10-27T13:00:00+00:00',
      'status': 'confirmed',
    });
    expect(t.estado, EstadoTurno.confirmado);
    expect(t.estado.vigente, isTrue);
    expect(t.fin.difference(t.inicio), const Duration(hours: 1));
    final inicio = t.inicio;
    expect(t.puedeCancelar(inicio.subtract(const Duration(hours: 3))), isTrue);
    expect(t.puedeCancelar(inicio.subtract(const Duration(hours: 2))), isTrue);
    expect(
      t.puedeCancelar(inicio.subtract(const Duration(minutes: 119))),
      isFalse,
    );
    expect(t.puedeCancelar(inicio.add(const Duration(hours: 1))), isFalse);
    expect(
      t.puedeMarcarAtendido(inicio.subtract(const Duration(minutes: 1))),
      isFalse,
    );
    expect(t.puedeMarcarAtendido(inicio), isTrue);
  });

  test('un rechazado ya no se cancela', () {
    final t = Turno.fromJson({
      'id': 't2',
      'starts_at': '2030-01-01T12:00:00Z',
      'ends_at': '2030-01-01T12:30:00Z',
      'status': 'rejected',
    });
    expect(t.estado.vigente, isFalse);
    expect(t.puedeCancelar(DateTime(2029)), isFalse);
  });

  test('días reservables sin los bloqueados', () {
    final c = CondicionesAgenda.fromJson({
      'slot_min': 60,
      'days_ahead': 3,
      'bloqueados': ['2026-10-27'],
      'servicios': [
        {'id': 's1', 'name': 'Baño', 'duration_min': 90, 'price': '600.00'},
      ],
    });
    expect(c.servicios.single.duracionMinutos, 90);
    expect(c.servicios.single.precio, 600);
    expect(c.diasReservables(DateTime(2026, 10, 26, 15)), [
      DateTime(2026, 10, 26),
      DateTime(2026, 10, 28),
      DateTime(2026, 10, 29),
    ]);
  });

  test('ajustes de la agenda ida y vuelta', () {
    final a = AjustesAgenda.fromJson({
      'configurada': true,
      'slot_min': 45,
      'capacity': 2,
      'notice_min': 60,
      'days_ahead': 14,
      'service_ids': ['s1'],
      'bloqueados': [
        {'day': '2026-12-25', 'note': 'Navidad'},
      ],
    });
    expect(a.bloqueados.single.nota, 'Navidad');
    expect(a.copyWith(aLaVez: 3).toJson(), {
      'slot_min': 45,
      'capacity': 3,
      'notice_min': 60,
      'days_ahead': 14,
      'service_ids': ['s1'],
    });
  });
}
