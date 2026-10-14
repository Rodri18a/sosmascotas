import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('NuevoSos arma lo que espera crear_sos', () {
    final json = NuevoSos(
      tipo: TipoSos.encontrada,
      especieId: 1,
      ubicacion: centroPando,
      fotos: const ['sos-photos/u1/a.jpg'],
      recompensa: r'$ 2000',
      cuando: DateTime.utc(2026, 10, 14, 12),
    ).toJson();

    expect(json['kind'], 'found');
    expect(json['lat'], centroPando.lat);
    expect(
      json['reward'],
      isNull,
      reason: 'solo los perdidos llevan recompensa',
    );
    expect(json['happened_at'], '2026-10-14T12:00:00.000Z');
  });

  test('MiSos lee la respuesta de mis_sos', () {
    final mio = MiSos.fromJson({
      'id': 's1',
      'kind': 'lost',
      'status': 'hidden',
      'created_at': '2026-10-14T10:00:00Z',
      'lat': -34.7,
      'lng': -55.9,
      'name': 'Luna',
      'photos': ['sos-photos/u1/a.jpg'],
    });

    expect(mio.tipo, TipoSos.perdida);
    expect(mio.estado, EstadoSos.oculto);
    expect(mio.fotos, hasLength(1));
  });

  test('distancia redondeada para mostrar', () {
    expect(textoDistancia(162), '150 m');
    expect(textoDistancia(980), '1,0 km');
    expect(textoDistancia(2430), '2,4 km');
  });

  test('pin de un SOS encontrado', () {
    final pin = pinDeSos({
      'id': 's1',
      'kind': 'found',
      'lat': -34.7,
      'lng': -55.9,
    });
    expect(pin.tipo, TipoPin.encontrado);
    expect(pin.punto, const Punto(-34.7, -55.9));
  });
}
