import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('lee un integrante sin correo', () {
    final i = Integrante.fromJson({
      'household_id': 'h1',
      'user_id': 'u2',
      'display_name': 'Beto',
      'role': 'temp_caregiver',
      'access_until': '2026-10-25T03:00:00Z',
      'es_dueno': false,
    });
    expect(i.rol, RolHogar.tempCaregiver);
    expect(i.nombre, 'Beto');
    expect(i.accesoHasta, DateTime.utc(2026, 10, 25, 3).toLocal());
    expect(i.esDueno, isFalse);
    expect(
      Integrante.fromJson({
        'household_id': 'h1',
        'user_id': 'u1',
        'role': 'owner',
      }).esDueno,
      isTrue,
    );
  });

  test('códigos de invitación', () {
    expect(codigoInvitacionValido('abcdefghjk'), isTrue);
    expect(codigoInvitacionValido(' K7M2QX9PAB '), isTrue);
    for (final malo in ['ABCDEFGHJ', 'ABCDEFGHI1', 'ABCDEFGH0K', '']) {
      expect(codigoInvitacionValido(malo), isFalse, reason: malo);
    }
  });

  test('la mascota sabe de quién es', () {
    final m = Mascota.fromJson({
      'id': 'm1',
      'name': 'Luna',
      'species_id': 2,
      'owner_id': 'u1',
    });
    expect(m.esDe('u1'), isTrue);
    expect(m.esDe('u2'), isFalse);
    expect(m.toJson().containsKey('owner_id'), isFalse);
  });
}
