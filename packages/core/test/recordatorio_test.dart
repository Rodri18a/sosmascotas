import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

Recordatorio _r(
  Frecuencia frecuencia, {
  DateTime? inicio,
  DateTime? fin,
  bool activo = true,
}) => Recordatorio(
  id: 'r1',
  mascotaId: 'm1',
  tipo: TipoRecordatorio.medication,
  titulo: 'Antibiótico',
  frecuencia: frecuencia,
  inicio: inicio ?? DateTime(2026, 10, 17, 8),
  fin: fin,
  activo: activo,
);

void main() {
  group('HoraDelDia', () {
    test('lee y escribe HH:MM', () {
      expect(HoraDelDia.leer('08:05'), const HoraDelDia(8, 5));
      expect(HoraDelDia.leer('08:05')!.texto, '08:05');
      for (final malo in ['8:05', '24:00', '12:60', 'mañana', 8, null]) {
        expect(HoraDelDia.leer(malo), isNull, reason: '$malo');
      }
    });
  });

  group('Frecuencia', () {
    test('lee cada tipo y vuelve al mismo JSON', () {
      for (final json in <Map<String, Object?>>[
        {'tipo': 'cada_horas', 'horas': 8},
        {
          'tipo': 'diaria',
          'horarios': ['08:00', '20:00'],
        },
        {
          'tipo': 'semanal',
          'dias': [1, 4],
          'horarios': ['09:30'],
        },
        {'tipo': 'una_vez'},
      ]) {
        expect(Frecuencia.leer(json)!.toJson(), json);
      }
    });

    test('ordena los horarios y saca repetidos', () {
      final f = Frecuencia.leer({
        'tipo': 'diaria',
        'horarios': ['20:00', '08:00', '20:00'],
      });
      expect(f!.toJson()['horarios'], ['08:00', '20:00']);
    });

    test('rechaza lo inválido', () {
      for (final json in <Object?>[
        null,
        'diaria',
        {'tipo': 'cada_horas', 'horas': 0},
        {'tipo': 'cada_horas', 'horas': 100},
        {'tipo': 'diaria', 'horarios': <String>[]},
        {
          'tipo': 'diaria',
          'horarios': ['8'],
        },
        {
          'tipo': 'semanal',
          'dias': [0],
          'horarios': ['08:00'],
        },
        {'tipo': 'mensual'},
      ]) {
        expect(Frecuencia.leer(json), isNull, reason: '$json');
      }
    });
  });

  group('Recordatorio', () {
    test('lee la fila de la base en hora local y la vuelve a escribir', () {
      final inicio = DateTime(2026, 10, 17, 8);
      final r = Recordatorio.fromJson({
        'id': 'r1',
        'pet_id': 'm1',
        'kind': 'medication',
        'title': 'Antibiótico',
        'dose': '1/2 comprimido',
        'schedule': {'tipo': 'cada_horas', 'horas': 12},
        'starts_at': inicio.toUtc().toIso8601String(),
        'ends_on': '2026-10-24',
        'active': true,
      })!;
      expect(r.inicio, inicio);
      expect(r.fin, DateTime(2026, 10, 24));
      expect(r.toJson(), {
        'pet_id': 'm1',
        'kind': 'medication',
        'title': 'Antibiótico',
        'dose': '1/2 comprimido',
        'schedule': {'tipo': 'cada_horas', 'horas': 12},
        'starts_at': inicio.toUtc().toIso8601String(),
        'ends_on': '2026-10-24',
        'active': true,
      });
    });

    test('una frecuencia rota no se usa', () {
      expect(
        Recordatorio.fromJson({
          'id': 'r1',
          'pet_id': 'm1',
          'kind': 'medication',
          'title': 'X',
          'schedule': {'tipo': 'rara'},
          'starts_at': '2026-10-17T11:00:00Z',
        }),
        isNull,
      );
    });
  });

  group('tomas', () {
    test('cada 8 horas desde la primera toma, hasta el último día', () {
      final r = _r(const CadaHoras(8), fin: DateTime(2026, 10, 18));
      expect(r.tomasEntre(DateTime(2026, 10, 17), DateTime(2026, 10, 20)), [
        DateTime(2026, 10, 17, 8),
        DateTime(2026, 10, 17, 16),
        DateTime(2026, 10, 18),
        DateTime(2026, 10, 18, 8),
        DateTime(2026, 10, 18, 16),
      ]);
    });

    test('cada 8 horas: la próxima a mitad del día', () {
      final r = _r(const CadaHoras(8));
      expect(
        r.proximaToma(DateTime(2026, 10, 19, 9, 15)),
        DateTime(2026, 10, 19, 16),
      );
      expect(
        r.proximaToma(DateTime(2026, 10, 19, 16)),
        DateTime(2026, 10, 19, 16),
      );
    });

    test('todos los días a las 8 y a las 20, desde el inicio', () {
      final r = _r(
        const Diaria([HoraDelDia(8, 0), HoraDelDia(20, 0)]),
        inicio: DateTime(2026, 10, 17, 12),
      );
      expect(r.tomasEntre(DateTime(2026, 10, 17), DateTime(2026, 10, 19)), [
        DateTime(2026, 10, 17, 20),
        DateTime(2026, 10, 18, 8),
        DateTime(2026, 10, 18, 20),
      ]);
    });

    test('lunes y jueves a las 9:30', () {
      // 17/10/2026 es sábado.
      final r = _r(const Semanal({1, 4}, [HoraDelDia(9, 30)]));
      expect(
        r.proximaToma(DateTime(2026, 10, 17, 10)),
        DateTime(2026, 10, 19, 9, 30),
      );
      expect(r.tomasEntre(DateTime(2026, 10, 17), DateTime(2026, 10, 26)), [
        DateTime(2026, 10, 19, 9, 30),
        DateTime(2026, 10, 22, 9, 30),
      ]);
    });

    test('una sola vez, aunque falte mucho', () {
      final r = _r(const UnaVez(), inicio: DateTime(2027, 9, 1, 10));
      expect(r.proximaToma(DateTime(2026, 10, 17)), DateTime(2027, 9, 1, 10));
      expect(r.proximaToma(DateTime(2027, 9, 2)), isNull);
    });

    test('un tratamiento terminado o pausado no suena', () {
      expect(
        _r(
          const CadaHoras(12),
          fin: DateTime(2026, 10, 18),
        ).proximaToma(DateTime(2026, 10, 19)),
        isNull,
      );
      expect(
        _r(
          const CadaHoras(12),
          activo: false,
        ).proximaToma(DateTime(2026, 10, 18)),
        isNull,
      );
    });
  });

  group('validarRecordatorio', () {
    final inicio = DateTime(2026, 10, 17, 8);

    test('pide título, horarios, días y un fin posible', () {
      expect(
        validarRecordatorio(
          titulo: ' ',
          frecuencia: const UnaVez(),
          inicio: inicio,
        ),
        ValidacionRecordatorio.sinTitulo,
      );
      expect(
        validarRecordatorio(
          titulo: 'x' * 81,
          frecuencia: const UnaVez(),
          inicio: inicio,
        ),
        ValidacionRecordatorio.tituloLargo,
      );
      expect(
        validarRecordatorio(
          titulo: 'X',
          frecuencia: const Diaria([]),
          inicio: inicio,
        ),
        ValidacionRecordatorio.sinHorarios,
      );
      expect(
        validarRecordatorio(
          titulo: 'X',
          frecuencia: const Semanal({}, [HoraDelDia(8, 0)]),
          inicio: inicio,
        ),
        ValidacionRecordatorio.sinDias,
      );
      expect(
        validarRecordatorio(
          titulo: 'X',
          frecuencia: const CadaHoras(8),
          inicio: inicio,
          fin: DateTime(2026, 10, 16),
        ),
        ValidacionRecordatorio.finAntesDelInicio,
      );
      expect(
        validarRecordatorio(
          titulo: 'X',
          frecuencia: const CadaHoras(8),
          inicio: inicio,
          fin: DateTime(2026, 10, 17),
        ),
        ValidacionRecordatorio.valido,
      );
    });
  });

  group('toma pendiente', () {
    final r = _r(const CadaHoras(8));
    TomaHecha hecha(DateTime prevista) => TomaHecha(
      id: 'h',
      recordatorioId: 'r1',
      prevista: prevista,
      hecha: prevista,
    );

    test('la de la hora, desde media hora antes', () {
      final primera = _r(
        const CadaHoras(8),
        inicio: DateTime(2026, 10, 17, 16),
      );
      expect(
        tomaPendiente(primera, DateTime(2026, 10, 17, 15, 29), []),
        isNull,
      );
      expect(
        tomaPendiente(primera, DateTime(2026, 10, 17, 15, 30), []),
        DateTime(2026, 10, 17, 16),
      );
      // Con una toma anterior sin marcar, a las 15:29 se ofrece esa.
      expect(
        tomaPendiente(r, DateTime(2026, 10, 17, 15, 29), []),
        DateTime(2026, 10, 17, 8),
      );
    });

    test('si se olvidó, sigue ofreciendo la más reciente', () {
      expect(
        tomaPendiente(r, DateTime(2026, 10, 17, 18), []),
        DateTime(2026, 10, 17, 16),
      );
    });

    test('marcada, ya no se ofrece (ni la anterior)', () {
      final ahora = DateTime(2026, 10, 17, 18);
      expect(
        tomaPendiente(r, ahora, [hecha(DateTime(2026, 10, 17, 16))]),
        DateTime(2026, 10, 17, 8),
      );
      expect(
        tomaPendiente(r, ahora, [
          hecha(DateTime(2026, 10, 17, 16)),
          hecha(DateTime(2026, 10, 17, 8)),
        ]),
        isNull,
      );
    });

    test('lee la fila de reminder_logs', () {
      final h = TomaHecha.fromJson({
        'id': 'h1',
        'reminder_id': 'r1',
        'due_at': DateTime(2026, 10, 17, 16).toUtc().toIso8601String(),
        'done_at': DateTime(2026, 10, 17, 16, 5).toUtc().toIso8601String(),
      });
      expect(h.prevista, DateTime(2026, 10, 17, 16));
      expect(h.hecha, DateTime(2026, 10, 17, 16, 5));
    });
  });
}
