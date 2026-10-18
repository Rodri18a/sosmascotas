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
    expect(c.pin!.tipo, TipoPin.veterinaria);
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
    expect(con(urgencias: true).pin!.tipo, TipoPin.urgencia);
    expect(con(es24h: true).pin!.tipo, TipoPin.urgencia);
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

  group('abierto ahora (hora de Uruguay, UTC−3)', () {
    // Lunes a viernes 09–13 y 15–20; sábado 09–13; domingo cerrado.
    final horario = Horario.fromJson({
      for (final d in ['mon', 'tue', 'wed', 'thu', 'fri'])
        d: [
          ['09:00', '13:00'],
          ['15:00', '20:00'],
        ],
      'sat': [
        ['09:00', '13:00'],
      ],
    });
    // 15/10/2026 es jueves. Las horas se escriben en UTC (+3 de Uruguay).
    DateTime uy(int dia, int hora, [int minuto = 0]) =>
        DateTime.utc(2026, 10, dia, hora + 3, minuto);

    test('abierto en la primera franja: dice a qué hora cierra', () {
      expect(
        horario.estadoEn(uy(15, 10)),
        const EstadoApertura.abierto(cierra: 780),
      );
    });

    test('al mediodía está cerrado y abre hoy a las 15', () {
      expect(
        horario.estadoEn(uy(15, 13)),
        const EstadoApertura.cerrado(dia: 3, abre: 900, diasHasta: 0),
      );
    });

    test('a la noche abre mañana a las 9', () {
      expect(
        horario.estadoEn(uy(15, 21)),
        const EstadoApertura.cerrado(dia: 4, abre: 540, diasHasta: 1),
      );
    });

    test('sábado de tarde: el domingo está cerrado, abre el lunes', () {
      expect(
        horario.estadoEn(uy(17, 14)),
        const EstadoApertura.cerrado(dia: 0, abre: 540, diasHasta: 2),
      );
    });

    test('usa la hora de Uruguay, no la del dispositivo', () {
      // 23:30 UTC del jueves = 20:30 en Uruguay: ya cerró.
      expect(
        horario.estadoEn(DateTime.utc(2026, 10, 15, 23, 30)).abierto,
        isFalse,
      );
      // 12:00 UTC = 09:00 en Uruguay: abre justo.
      expect(horario.estadoEn(DateTime.utc(2026, 10, 15, 12)).abierto, isTrue);
    });

    test('24 h siempre abierta; sin horario, cerrada', () {
      const c = Comercio(
        id: 'b',
        nombre: 'X',
        punto: centroPando,
        horario: Horario({}),
        es24h: true,
      );
      expect(c.estadoEn(uy(18, 3)), const EstadoApertura.abierto24h());
      expect(
        const Horario({}).estadoEn(uy(15, 10)),
        const EstadoApertura.sinHorario(),
      );
    });
  });
}
