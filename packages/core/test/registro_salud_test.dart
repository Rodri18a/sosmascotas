import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  group('RegistroSalud', () {
    test('lee y escribe las columnas de health_records', () {
      final r = RegistroSalud.fromJson({
        'id': 'r1',
        'pet_id': 'm1',
        'kind': 'vaccine',
        'name': 'Antirrábica',
        'date': '2026-09-01',
        'next_date': '2027-09-01',
        'notes': null,
      });
      expect(r.tipo, TipoRegistroSalud.vaccine);
      expect(r.fecha, DateTime(2026, 9));
      expect(r.proxima, DateTime(2027, 9));
      expect(r.toJson(), {
        'pet_id': 'm1',
        'kind': 'vaccine',
        'name': 'Antirrábica',
        'date': '2026-09-01',
        'next_date': '2027-09-01',
        'notes': null,
      });
    });

    test(
      'un tipo desconocido se lee como "otro" y las notas vacías no se guardan',
      () {
        final r = RegistroSalud.fromJson({
          'id': 'r1',
          'pet_id': 'm1',
          'kind': 'nuevo_tipo',
          'name': ' Pollo ',
        });
        expect(r.tipo, TipoRegistroSalud.other);
        expect(
          const RegistroSalud(
            id: 'r1',
            mascotaId: 'm1',
            tipo: TipoRegistroSalud.allergy,
            nombre: ' Pollo ',
            notas: '  ',
          ).toJson(),
          containsPair('notes', null),
        );
        expect(r.toJson()['name'], 'Pollo');
      },
    );

    test('las alergias no llevan fecha', () {
      expect(TipoRegistroSalud.allergy.llevaFecha, isFalse);
      expect(TipoRegistroSalud.vaccine.llevaFecha, isTrue);
    });

    test('los tipos son los de la base', () {
      expect(TipoRegistroSalud.values.map((t) => t.name), [
        'vaccine',
        'deworming',
        'checkup',
        'allergy',
        'other',
      ]);
    });
  });

  group('validarRegistroSalud', () {
    test('pide nombre de hasta 80 letras', () {
      expect(
        validarRegistroSalud(nombre: '  '),
        ValidacionRegistroSalud.sinNombre,
      );
      expect(
        validarRegistroSalud(nombre: 'x' * 81),
        ValidacionRegistroSalud.nombreLargo,
      );
      expect(
        validarRegistroSalud(nombre: 'Séxtuple'),
        ValidacionRegistroSalud.valido,
      );
    });

    test('la próxima fecha no puede ser anterior', () {
      expect(
        validarRegistroSalud(
          nombre: 'Control',
          fecha: DateTime(2026, 9),
          proxima: DateTime(2026, 8),
        ),
        ValidacionRegistroSalud.proximaAntes,
      );
      expect(
        validarRegistroSalud(
          nombre: 'Control',
          fecha: DateTime(2026, 9),
          proxima: DateTime(2026, 9),
        ),
        ValidacionRegistroSalud.valido,
      );
    });
  });

  test('agruparLibreta ordena por tipo y lo más reciente primero', () {
    RegistroSalud r(String id, TipoRegistroSalud tipo, [DateTime? fecha]) =>
        RegistroSalud(
          id: id,
          mascotaId: 'm1',
          tipo: tipo,
          nombre: id,
          fecha: fecha,
        );
    final grupos = agruparLibreta([
      r('alergia', TipoRegistroSalud.allergy),
      r('vieja', TipoRegistroSalud.vaccine, DateTime(2025)),
      r('sin fecha', TipoRegistroSalud.vaccine),
      r('nueva', TipoRegistroSalud.vaccine, DateTime(2026)),
    ]);
    expect(grupos.keys, [TipoRegistroSalud.vaccine, TipoRegistroSalud.allergy]);
    expect(grupos[TipoRegistroSalud.vaccine]!.map((x) => x.id), [
      'nueva',
      'vieja',
      'sin fecha',
    ]);
  });

  group('semáforo', () {
    final hoy = DateTime(2026, 10, 17, 22, 30);

    test('cuenta días de calendario, sin importar la hora', () {
      expect(diasHasta(DateTime(2026, 10, 18), hoy), 1);
      expect(diasHasta(DateTime(2026, 10, 17), hoy), 0);
      expect(diasHasta(DateTime(2026, 10, 16), hoy), -1);
    });

    test('vencido, rojo hasta 7 días, amarillo hasta 30 y verde', () {
      expect(semaforoDe(DateTime(2026, 10, 16), hoy), Semaforo.vencido);
      expect(semaforoDe(DateTime(2026, 10, 17), hoy), Semaforo.rojo);
      expect(semaforoDe(DateTime(2026, 10, 24), hoy), Semaforo.rojo);
      expect(semaforoDe(DateTime(2026, 10, 25), hoy), Semaforo.amarillo);
      expect(semaforoDe(DateTime(2026, 11, 16), hoy), Semaforo.amarillo);
      expect(semaforoDe(DateTime(2026, 11, 17), hoy), Semaforo.verde);
    });

    test('una dosis nueva de lo mismo reemplaza la próxima de la anterior', () {
      RegistroSalud r(
        String id,
        String nombre,
        DateTime fecha, [
        DateTime? proxima,
      ]) => RegistroSalud(
        id: id,
        mascotaId: 'm1',
        tipo: TipoRegistroSalud.vaccine,
        nombre: nombre,
        fecha: fecha,
        proxima: proxima,
      );
      final vigentes = proximosVigentes([
        r('vieja', 'Antirrábica', DateTime(2025, 9), DateTime(2026, 9)),
        r('nueva', ' antirrábica ', DateTime(2026, 9), DateTime(2027, 9)),
        r('sextuple', 'Séxtuple', DateTime(2026, 3), DateTime(2026, 11)),
        r('sin proxima', 'Tos de las perreras', DateTime(2026, 1)),
      ]);
      expect(vigentes.map((x) => x.id), ['sextuple', 'nueva']);
    });
  });
}
