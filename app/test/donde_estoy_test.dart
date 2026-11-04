import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'helpers.dart';
import 'mascotas_falsas.dart';
import 'sos_falso.dart';

/// D145: al informar algo, el punto arranca donde está la persona; el Mapa
/// abre ahí si el permiso ya está dado y tiene «📍».
const _ana = Usuario(id: 'u1', email: 'ana@correo.com');
const _aca = (lat: -34.7301, lng: -55.9402);
const _luna = Mascota(
  id: 'm1',
  nombre: 'Luna',
  especieId: 2,
  sexo: Sexo.female,
  fotoPath: 'u1/luna.jpg',
);

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _abrirReporte(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(of: find.byType(BarraInferior), matching: find.text('SOS')),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FloatingActionButton, 'Reportar'));
  await tester.pumpAndSettle();
}

Future<void> _publicar(WidgetTester tester) async {
  final publicar = find.widgetWithText(FilledButton, 'Publicar');
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.ensureVisible(publicar);
  await tester.pumpAndSettle();
  await tester.tap(publicar);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('el reporte arranca marcado donde estoy y se publica así', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final sos = SosFalso();
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas([_luna]),
        sos: sos,
        posicion: _aca,
        eventos: eventos,
      ),
    );
    await _abrirReporte(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Luna'));
    await tester.pumpAndSettle();

    expect(
      find.text('📍 Marcado donde estás. Tocá el mapa si fue en otro lugar.'),
      findsOneWidget,
    );
    expect(find.text('marcado: ${_aca.lat},${_aca.lng}'), findsOneWidget);
    expect(
      find.byKey(ValueKey('centro: ${_aca.lat},${_aca.lng}')),
      findsWidgets,
    );
    expect(eventos.map((e) => e['name']), contains('location_prefill'));

    await _publicar(tester);
    expect(sos.creados.single.ubicacion, Punto(_aca.lat, _aca.lng));
  });

  testWidgets('si fue en otro lado, tocar el mapa lo cambia', (tester) async {
    _pantallaDeCelular(tester);
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        sos: SosFalso(),
        posicion: _aca,
        eventos: eventos,
      ),
    );
    await _abrirReporte(tester);

    final tocar = find.byKey(const ValueKey('mapa-tocar'));
    await tester.ensureVisible(tocar);
    await tester.tap(tocar);
    await tester.pumpAndSettle();

    expect(find.text('marcado: -34.72,-55.95'), findsOneWidget);
    expect(find.text('Lugar marcado ✔'), findsOneWidget);
    // El mapa no salta al punto tocado: sigue donde estaba.
    expect(
      find.byKey(ValueKey('centro: ${_aca.lat},${_aca.lng}')),
      findsWidgets,
    );
    expect(eventos.map((e) => e['name']), contains('location_changed'));

    // «Donde estoy» lo vuelve a poner.
    await tester.tap(find.widgetWithText(TextButton, 'Donde estoy'));
    await tester.pumpAndSettle();
    expect(find.text('marcado: ${_aca.lat},${_aca.lng}'), findsOneWidget);
  });

  testWidgets('sin permiso de ubicación, se marca a mano como antes', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        sos: SosFalso(),
      ),
    );
    await _abrirReporte(tester);

    expect(
      find.text('No pudimos saber dónde estás. Tocá el mapa en el lugar.'),
      findsOneWidget,
    );
    expect(find.textContaining('marcado:'), findsNothing);
  });

  testWidgets('el Mapa abre donde estoy si el permiso ya estaba dado', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(appDePrueba(posicionSinPreguntar: _aca));
    await tester.pumpAndSettle();

    expect(
      find.byKey(ValueKey('centro: ${_aca.lat},${_aca.lng}')),
      findsOneWidget,
    );
  });

  testWidgets('sin permiso, el Mapa abre en la zona y 📍 lo pide', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(appDePrueba(posicion: _aca, eventos: eventos));
    await tester.pumpAndSettle();

    expect(
      find.byKey(ValueKey('centro: ${centroPando.lat},${centroPando.lng}')),
      findsOneWidget,
    );
    await tester.tap(find.byTooltip('Ir a donde estoy'));
    await tester.pumpAndSettle();
    expect(
      find.byKey(ValueKey('centro: ${_aca.lat},${_aca.lng}')),
      findsOneWidget,
    );
    expect(eventos.map((e) => e['name']), contains('location_me'));
  });
}
