import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('lee un aviso de la base', () {
    final aviso = Aviso.fromJson({
      'id': 'a1',
      'target_type': 'qr',
      'target_id': 't1',
      'pet_id': 'p1',
      'sender_name': 'Carla',
      'sender_contact': '099 555 666',
      'message': 'La vi en la plaza',
      'status': 'scam_reported',
      'created_at': '2026-10-14T10:00:00Z',
      'lat': -34.7,
      'lng': -55.9,
    });

    expect(aviso.desdeQr, isTrue);
    expect(aviso.estado, EstadoAviso.estafa);
    expect(aviso.tieneUbicacion, isTrue);
    expect(estadoAvisoABase(EstadoAviso.respondido), 'replied');
  });

  test('pasa teléfonos uruguayos a formato internacional', () {
    expect(telefonoInternacionalUy('099 555 666'), '59899555666');
    expect(telefonoInternacionalUy('+598 99 555 666'), '59899555666');
    expect(telefonoInternacionalUy('99555666'), '59899555666');
    expect(telefonoInternacionalUy('2292 1234'), '59822921234');
    expect(telefonoInternacionalUy('+54 9 11 5555 6666'), '5491155556666');
    expect(telefonoInternacionalUy('hola'), isNull);
    expect(telefonoInternacionalUy('123'), isNull);
  });
}
