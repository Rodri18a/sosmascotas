import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  group('equipo de la empresa (3.5, D117)', () {
    test('lee el equipo con el primer nombre y las invitaciones', () {
      final e = EquipoNegocio.fromJson({
        'soy_titular': true,
        'personas': [
          {
            'user_id': 'u1',
            'nombre': 'Ana',
            'desde': '2026-10-28T12:00:00Z',
            'soy_yo': false,
          },
        ],
        'invitaciones': [
          {'code': 'ABCD2345', 'expires_at': '2026-11-04T12:00:00Z'},
        ],
      });
      expect(e.soyTitular, isTrue);
      expect(e.personas.single.nombre, 'Ana');
      expect(e.personas.single.soyYo, isFalse);
      expect(e.invitaciones.single.codigo, 'ABCD2345');
      expect(e.lleno, isFalse);
    });

    test('sin datos, vacío y no titular', () {
      final e = EquipoNegocio.fromJson(const {});
      expect(e.soyTitular, isFalse);
      expect(e.personas, isEmpty);
      expect(e.invitaciones, isEmpty);
    });

    test('lleno con 5 personas', () {
      final e = EquipoNegocio(
        soyTitular: true,
        personas: [
          for (var i = 0; i < maximoEquipo; i++)
            PersonaEquipo(userId: 'u$i', desde: DateTime(2026)),
        ],
      );
      expect(e.lleno, isTrue);
    });

    test('código: acepta el enlace, minúsculas y espacios', () {
      expect(codigoEquipo('abcd 2345'), 'ABCD2345');
      expect(
        codigoEquipo('https://app.huellamy.com/equipo/ABCD2345'),
        'ABCD2345',
      );
      expect(
        codigoEquipo('https://app.huellamy.com/equipo/ABCD2345/'),
        'ABCD2345',
      );
      expect(codigoEquipo('ABCD-2345'), 'ABCD2345');
    });

    test('código: rechaza lo que la base no genera', () {
      expect(codigoEquipo(''), isNull);
      expect(codigoEquipo('ABC'), isNull);
      expect(codigoEquipo('ABCD23456'), isNull);
      expect(codigoEquipo('ABCDO234'), isNull); // O
      expect(codigoEquipo('ABCD1234'), isNull); // 1
    });

    test('mis negocios: el rol del equipo', () {
      Map<String, Object?> fila(String? rol) => {
        'id': 'n1',
        'business_type': 'petshop',
        'kind': 'local',
        'name': 'Pet Shop',
        'plan': 'plus',
        'verification': 'verified',
        'rol': ?rol,
      };
      expect(MiNegocio.fromJson(fila('owner')).esTitular, isTrue);
      expect(MiNegocio.fromJson(fila('employee')).esTitular, isFalse);
      // Sin la columna (versiones viejas de la base): dueño.
      expect(MiNegocio.fromJson(fila(null)).esTitular, isTrue);
    });
  });
}
