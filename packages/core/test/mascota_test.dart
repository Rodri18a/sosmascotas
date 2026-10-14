import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  group('Mascota', () {
    test('ida y vuelta con la base', () {
      final json = {
        'id': 'p1',
        'name': 'Firulais',
        'species_id': 1,
        'breed_id': 3,
        'breed_other': null,
        'sex': 'male',
        'color': 'Negro',
        'marks': 'Mancha blanca en el pecho',
        'birth': '2020-03-15',
        'photo_path': 'u1/foto.jpg',
        'microchip': '858000000123456',
        'neutered': true,
        'notes': null,
      };
      final mascota = Mascota.fromJson(json);

      expect(mascota.sexo, Sexo.male);
      expect(mascota.nacimiento, DateTime(2020, 3, 15));
      expect(mascota.toJson()['birth'], '2020-03-15');
      expect(mascota.toJson()['sex'], 'male');
      expect(mascota.toJson().containsKey('id'), isFalse);
    });

    test('los textos vacíos se guardan como nulos', () {
      const mascota = Mascota(
        id: 'p1',
        nombre: '  Luna ',
        especieId: 2,
        color: '  ',
        microchip: '',
      );

      expect(mascota.toJson()['name'], 'Luna');
      expect(mascota.toJson()['color'], isNull);
      expect(mascota.toJson()['microchip'], isNull);
    });
  });

  group('edad', () {
    test('cuenta años y meses cumplidos', () {
      expect(edad(DateTime(2020, 3, 15), DateTime(2026, 10, 14)), (
        anios: 6,
        meses: 6,
      ));
      expect(edad(DateTime(2026, 8, 1), DateTime(2026, 10, 14)), (
        anios: 0,
        meses: 2,
      ));
    });

    test('nunca es negativa', () {
      expect(edad(DateTime(2027, 1, 1), DateTime(2026, 10, 14)), (
        anios: 0,
        meses: 0,
      ));
    });
  });

  group('validarMicrochip', () {
    test('acepta 15 números, con espacios o guiones', () {
      expect(validarMicrochip('858000000123456'), ValidacionMicrochip.valido);
      expect(
        validarMicrochip('858 000 000 123 456'),
        ValidacionMicrochip.valido,
      );
      expect(validarMicrochip('858-000000-123456'), ValidacionMicrochip.valido);
    });

    test('rechaza largos o caracteres incorrectos', () {
      expect(validarMicrochip('12345'), ValidacionMicrochip.noSonQuinceNumeros);
      expect(
        validarMicrochip('85800000012345A'),
        ValidacionMicrochip.noSonQuinceNumeros,
      );
      expect(validarMicrochip('  '), ValidacionMicrochip.vacio);
    });
  });
}
