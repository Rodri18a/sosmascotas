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
}
