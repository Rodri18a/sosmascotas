import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('lee un perfil completo de la base', () {
    final perfil = Perfil.fromJson({
      'id': 'u1',
      'display_name': 'Ana',
      'plan': 'pro',
      'alert_radius_km': 10,
      'zone_id': 1,
      'terms_version': '2026-10',
      'terms_accepted_at': '2026-10-14T10:00:00Z',
      'approx_location_at': '2026-10-15T09:00:00Z',
    });

    expect(perfil.nombre, 'Ana');
    expect(perfil.plan, Plan.pro);
    expect(perfil.radioAvisosKm, 10);
    expect(perfil.zonaId, 1);
    expect(perfil.aceptoTerminos('2026-10'), isTrue);
    expect(perfil.aceptoTerminos('2027-01'), isFalse);
    expect(perfil.zonaAvisosEn, DateTime.utc(2026, 10, 15, 9));
  });

  test('usa valores seguros si faltan datos', () {
    final perfil = Perfil.fromJson({'id': 'u1', 'plan': 'desconocido'});

    expect(perfil.nombre, '');
    expect(perfil.plan, Plan.free);
    expect(perfil.radioAvisosKm, 5);
    expect(perfil.zonaAvisosEn, isNull);
    expect(perfil.aceptoTerminos('2026-10'), isFalse);
  });
}
