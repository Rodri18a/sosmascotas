import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';
import 'helpers.dart';
import 'sos_falso.dart';

final _centro = Comercio(
  id: 'vet-centro',
  nombre: 'Veterinaria Ejemplo Centro',
  direccion: 'Calle de ejemplo 100',
  punto: const Punto(-34.7168, -55.9575),
  telefono: '099 000 001',
  whatsapp: '099000001',
  especieIds: const [1, 2],
  esEjemplo: true,
  horario: Horario.fromJson({
    for (final d in ['mon', 'tue', 'wed', 'thu', 'fri'])
      d: [
        ['09:00', '13:00'],
        ['15:00', '20:00'],
      ],
  }),
);

const _guardia = Comercio(
  id: 'vet-24h',
  nombre: 'Clínica Ejemplo 24 h',
  punto: Punto(-34.7215, -55.9512),
  horario: Horario({}),
  es24h: true,
  urgencias: true,
);

// Jueves 15/10/2026 a las 10:00 de Uruguay (13:00 UTC).
final _juevesALas10 = DateTime.utc(2026, 10, 15, 13);

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _moverMapa(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('mapa-mover')));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el mapa trae las veterinarias de la zona junto con los SOS', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final comercios = ComerciosFalsos([_centro, _guardia]);
    await tester.pumpWidget(
      appDePrueba(
        comercios: comercios,
        sos: SosFalso(
          pins: const [
            Pin(id: 's1', tipo: TipoPin.perdido, punto: Punto(-34.72, -55.95)),
          ],
        ),
      ),
    );
    await _moverMapa(tester);

    expect(find.text('mapa: 3 pines'), findsOneWidget);
    expect(comercios.zonasConsultadas, hasLength(1));
    expect(find.text('Urgencias / 24 h'), findsOneWidget, reason: 'leyenda');

    await tester.tap(find.byKey(const ValueKey('mapa-mover')));
    await tester.pumpAndSettle();
    expect(comercios.zonasConsultadas, hasLength(1), reason: 'ya cargada');
  });

  testWidgets('la ficha muestra si está abierta, el horario y los contactos', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final enlaces = <Uri>[];
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        comercios: ComerciosFalsos([_centro]),
        enlacesAbiertos: enlaces,
        eventos: eventos,
        ahora: _juevesALas10,
      ),
    );
    await _moverMapa(tester);
    await tester.tap(find.byKey(const ValueKey('pin-vet-centro')));
    await tester.pumpAndSettle();

    expect(find.text('Veterinaria Ejemplo Centro'), findsOneWidget);
    expect(find.text('Abierto · cierra a las 13:00'), findsOneWidget);
    expect(find.text('Ejemplo'), findsOneWidget);
    expect(find.textContaining('no es una veterinaria real'), findsOneWidget);
    expect(find.text('Atiende: Perro, Gato'), findsOneWidget);
    expect(
      eventos.where((e) => e['name'] == 'place_open').single['business_id'],
      'vet-centro',
    );

    await tester.tap(find.text('Llamar'));
    await tester.tap(find.text('WhatsApp'));
    await tester.tap(find.text('Cómo llegar'));
    await tester.pumpAndSettle();
    expect(enlaces.map((u) => u.toString()), [
      'tel:099000001',
      'https://wa.me/59899000001',
      'https://www.google.com/maps/dir/?api=1&destination=-34.7168%2C-55.9575',
    ]);
    expect(
      eventos
          .where((e) => e['name'] == 'place_click')
          .map((e) => (e['props']! as Map)['tipo']),
      ['llamar', 'whatsapp', 'como_llegar'],
    );

    await tester.tap(find.text('Horario de la semana'));
    await tester.pumpAndSettle();
    expect(find.text('09:00–13:00 · 15:00–20:00'), findsNWidgets(5));
    expect(find.text('Cerrado'), findsNWidgets(2), reason: 'sábado y domingo');
  });

  testWidgets('cerrada de noche: dice cuándo abre', (tester) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        comercios: ComerciosFalsos([_centro]),
        // Viernes 16/10 a las 21:00 de Uruguay: abre el lunes.
        ahora: DateTime.utc(2026, 10, 17, 0),
      ),
    );
    await _moverMapa(tester);
    await tester.tap(find.byKey(const ValueKey('pin-vet-centro')));
    await tester.pumpAndSettle();

    expect(find.text('Cerrado · abre el lunes a las 09:00'), findsOneWidget);
  });

  testWidgets('la de 24 h siempre está abierta y no muestra horario', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(comercios: ComerciosFalsos([_guardia]), ahora: _juevesALas10),
    );
    await _moverMapa(tester);
    await tester.tap(find.byKey(const ValueKey('pin-vet-24h')));
    await tester.pumpAndSettle();

    expect(find.text('Abierto las 24 h'), findsOneWidget);
    expect(find.text('24 h'), findsOneWidget);
    expect(find.text('Horario de la semana'), findsNothing);
    expect(find.text('Llamar'), findsNothing, reason: 'no tiene teléfono');
    expect(find.text('Cómo llegar'), findsOneWidget);
  });
}
