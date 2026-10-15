import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('lee un comercio de comercios_en_zona()', () {
    final c = Comercio.fromJson({
      'id': 'b1',
      'business_type': 'vet',
      'name': 'Veterinaria Ejemplo Centro',
      'address': 'Calle de ejemplo 100',
      'lat': -34.7168,
      'lng': -55.9575,
      'phone': '099000001',
      'hours': {
        'mon': [
          ['09:00', '13:00'],
          ['15:00', '20:00'],
        ],
        'sat': [
          ['09:00', '13:00'],
        ],
      },
      'is_24h': false,
      'emergencies': false,
      'species_ids': [1, 2],
      'verified': false,
      'is_sample': true,
    });

    expect(c.nombre, 'Veterinaria Ejemplo Centro');
    expect(c.punto, const Punto(-34.7168, -55.9575));
    expect(c.horario.delDia(0), const [Franja(540, 780), Franja(900, 1200)]);
    expect(c.horario.delDia(5), const [Franja(540, 780)]);
    expect(c.horario.delDia(6), isEmpty, reason: 'domingo cerrado');
    expect(c.especieIds, [1, 2]);
    expect(c.esEjemplo, isTrue);
    expect(c.pin.tipo, TipoPin.veterinaria);
  });

  test('las de urgencia o 24 h usan el pin de urgencia', () {
    Comercio con({bool urgencias = false, bool es24h = false}) => Comercio(
      id: 'b',
      nombre: 'X',
      punto: centroPando,
      horario: const Horario({}),
      urgencias: urgencias,
      es24h: es24h,
    );
    expect(con(urgencias: true).pin.tipo, TipoPin.urgencia);
    expect(con(es24h: true).pin.tipo, TipoPin.urgencia);
  });

  test('un horario raro no rompe: se ignora lo que no se entiende', () {
    final h = Horario.fromJson({
      'mon': [
        ['9', '13'],
        ['15:00', '24:00'],
      ],
      'xyz': [
        ['09:00', '10:00'],
      ],
      'tue': 'cerrado',
      'wed': [
        ['20:00', '10:00'],
      ],
    });
    expect(h.delDia(0), const [Franja(900, 1440)]);
    expect(h.porDia.keys, [0]);
    expect(Horario.fromJson(null).vacio, isTrue);
  });
}
