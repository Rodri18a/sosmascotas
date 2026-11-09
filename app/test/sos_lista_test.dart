import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
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

  testWidgets('Mis reportes (D150): cerrado, en otro color y fuera de la '
      'lista de los vecinos', (tester) async {
    final sos = SosFalso(listaCercanos: [_perdida, _encontrada])
      ..mios = [
        MiSos(
          id: 's1',
          tipo: TipoSos.perdida,
          estado: EstadoSos.activo,
          creado: DateTime(2026, 10, 14),
          ubicacion: const Punto(-34.72, -55.95),
          nombre: 'Firulais',
        ),
      ];
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(
          conectado: const Usuario(id: 'u1', email: 'ana@correo.com'),
        ),
        sos: sos,
      ),
    );
    await _irASos(tester);

    final tarjeta = tester.widget<Card>(
      find.byKey(const ValueKey('mis-reportes')),
    );
    expect(tarjeta.color, const Color(0xFFFFF1DC));
    expect(find.text('1 reporte · 1 activo'), findsOneWidget);
    expect(find.text('Activo'), findsNothing, reason: 'arranca cerrado');
    expect(find.text('Reportes de otros vecinos cerca'), findsOneWidget);
    // El mío (s1, Firulais) no se repite abajo; el de otro vecino sí está.
    expect(find.text('Se perdió: Firulais'), findsNothing);
    expect(find.text('Labrador · Negro'), findsNothing);
    expect(find.text('Encontrada: Gato'), findsOneWidget);
  });

  testWidgets('SOS (D154): al final, aparte, el enlace a Adopción', (
    tester,
  ) async {
    final metricas = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        sos: SosFalso(listaCercanos: [_perdida]),
        eventos: metricas,
        funcionalidades: FuncionalidadesFalsas({Funcionalidades.adopcion}),
      ),
    );
    await _irASos(tester);
    final enlace = find.byKey(const Key('acceso-adopcion'));
    await tester.scrollUntilVisible(enlace, 200);
    expect(
      tester.getTopLeft(enlace).dy,
      greaterThan(tester.getTopLeft(find.text('Se perdió: Firulais')).dy),
      reason: 'va después de los reportes',
    );
    await tester.tap(enlace);
    await tester.pumpAndSettle();
    expect(find.text('Adopción responsable'), findsOneWidget);
    expect(
      metricas
          .where((e) => e['name'] == 'adoption_shortcut')
          .map((e) => e['props']),
      [
        {'desde': 'sos'},
      ],
    );
  });

  testWidgets('SOS (D154): sin Adopción prendida no hay enlace', (
    tester,
  ) async {
    await tester.pumpWidget(appDePrueba());
    await _irASos(tester);
    expect(find.byKey(const Key('acceso-adopcion')), findsNothing);
  });
}
