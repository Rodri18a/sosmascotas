import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'helpers.dart';
import 'sos_falso.dart';

final _perdida = SosResumen(
  id: 's1',
  tipo: TipoSos.perdida,
  especie: 'Perro',
  especieIcono: '🐶',
  nombre: 'Firulais',
  raza: 'Labrador',
  color: 'Negro',
  cuando: DateTime.now().subtract(const Duration(hours: 3)),
  distanciaMetros: 340,
);
final _encontrada = SosResumen(
  id: 's2',
  tipo: TipoSos.encontrada,
  especie: 'Gato',
  especieIcono: '🐱',
  cuando: DateTime.now().subtract(const Duration(days: 2)),
  distanciaMetros: 2430,
);

Future<void> _irASos(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(of: find.byType(BarraInferior), matching: find.text('SOS')),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el mapa trae solo la zona visible y no repite la consulta', (
    tester,
  ) async {
    final sos = SosFalso(
      pins: const [
        Pin(id: 's1', tipo: TipoPin.perdido, punto: Punto(-34.72, -55.95)),
        Pin(id: 's2', tipo: TipoPin.encontrado, punto: Punto(-34.71, -55.96)),
      ],
    );
    await tester.pumpWidget(appDePrueba(sos: sos));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('mapa-mover')));
    await tester.pumpAndSettle();
    expect(find.text('mapa: 2 pines'), findsOneWidget);
    expect(sos.zonasConsultadas, hasLength(1));
    expect(
      sos.zonasConsultadas.single.contiene(
        const Limites(
          minLat: -34.75,
          minLng: -56.0,
          maxLat: -34.68,
          maxLng: -55.9,
        ),
      ),
      isTrue,
      reason: 'se pide la zona agrandada',
    );

    await tester.tap(find.byKey(const ValueKey('mapa-mover')));
    await tester.pumpAndSettle();
    expect(sos.zonasConsultadas, hasLength(1), reason: 'ya estaba cargada');

    await tester.tap(find.byKey(const ValueKey('pin-s1')));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Reporte'), findsOneWidget);
  });

  testWidgets('la pestaña SOS lista por cercanía y filtra', (tester) async {
    await tester.pumpWidget(
      appDePrueba(sos: SosFalso(listaCercanos: [_perdida, _encontrada])),
    );
    await _irASos(tester);

    expect(find.text('Se perdió: Firulais'), findsOneWidget);
    expect(find.text('Labrador · Negro'), findsOneWidget);
    expect(find.text('A 350 m · hace 3 horas'), findsOneWidget);
    expect(find.text('Encontrada: Gato'), findsOneWidget);
    expect(find.text('A 2,4 km · hace 2 días'), findsOneWidget);

    await tester.tap(find.text('Encontradas'));
    await tester.pumpAndSettle();
    expect(find.text('Se perdió: Firulais'), findsNothing);
    expect(find.text('Encontrada: Gato'), findsOneWidget);

    await tester.tap(find.text('Encontrada: Gato'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Reporte'), findsOneWidget);
  });

  testWidgets('sin reportes cerca muestra un mensaje', (tester) async {
    await tester.pumpWidget(appDePrueba());
    await _irASos(tester);

    expect(
      find.textContaining('No hay reportes activos cerca'),
      findsOneWidget,
    );
  });
}
