import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('lee un evento y su pin', () {
    final e = Evento.fromJson({
      'id': 'e1',
      'kind': 'castracion',
      'title': 'Jornada de castración',
      'starts_at': '2027-01-10T12:00:00Z',
      'ends_at': '2027-01-10T20:00:00Z',
      'lat': -34.71,
      'lng': -55.95,
      'organizador': 'Veterinaria Centro',
    });
    expect(e.tipo, TipoEvento.castracion);
    expect(e.pin.tipo, TipoPin.evento);
    expect(e.enCurso(DateTime.utc(2027, 1, 10, 15)), isTrue);
    expect(e.enCurso(DateTime.utc(2027, 1, 11)), isFalse);
  });

  test('los eventos no se agrupan', () {
    const visible = Limites(
      minLat: -34.8,
      minLng: -56.0,
      maxLat: -34.6,
      maxLng: -55.9,
    );
    final pins = [
      for (var i = 0; i < 4; i++)
        Pin(
          id: 'e$i',
          tipo: TipoPin.evento,
          punto: Punto(-34.701 - i * 0.0001, -55.951),
        ),
    ];
    expect(agruparPins(pins, visible), hasLength(4));
  });

  test('denuncia', () {
    final d = Denuncia.fromJson({
      'id': 'd1',
      'description': 'Perro atado sin agua',
      'status': 'referred',
      'created_at': '2026-10-19T12:00:00Z',
    });
    expect(d.estado, EstadoDenuncia.derivada);
  });
}
