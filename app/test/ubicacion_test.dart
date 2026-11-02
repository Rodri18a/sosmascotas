import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/push/servicio_push.dart';
import 'package:sosmascota/src/ubicacion/servicio_ubicacion.dart';

import 'cuenta_falsa.dart';
import 'helpers.dart';
import 'perfil_falso.dart';
import 'push_falso.dart';
import 'ubicacion_falsa.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _abrir(WidgetTester tester, String tooltip) async {
  await tester.pumpAndSettle();
  // Ajustes ya no está arriba: se abre desde el menú ☰ (D130).
  if (tooltip == 'Ajustes') return abrirAjustesDesdeMenu(tester);
  await tester.tap(find.byTooltip(tooltip));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('al activar los avisos explica la zona y, si acepta, la guarda', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final perfiles = PerfilRepositorioFalso();
    final ubicacion = UbicacionFalsa(perfiles);
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        perfiles: perfiles,
        push: PushFalso(),
        ubicacion: ubicacion,
        eventos: eventos,
      ),
    );
    await _abrir(tester, 'Avisos');

    await tester.tap(find.text('Activar avisos'));
    await tester.pumpAndSettle();
    expect(find.textContaining('nunca tu ubicación exacta'), findsOneWidget);
    expect(ubicacion.activaciones, 0, reason: 'no pide nada antes de explicar');

    await tester.tap(find.text('Usar mi zona'));
    await tester.pumpAndSettle();

    expect(ubicacion.activaciones, 1);
    expect(perfiles.zonaAvisosEn, isNotNull);
    expect(find.textContaining('cerca de tu zona'), findsOneWidget);
    expect(eventos.map((e) => e['name']), contains('alert_zone_set'));
    // El evento no lleva coordenadas.
    final evento = eventos.firstWhere((e) => e['name'] == 'alert_zone_set');
    expect(evento['props'], isEmpty);
  });

  testWidgets('"Ahora no" no pide el permiso', (tester) async {
    _pantallaDeCelular(tester);
    final perfiles = PerfilRepositorioFalso();
    final ubicacion = UbicacionFalsa(perfiles);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        perfiles: perfiles,
        push: PushFalso(),
        ubicacion: ubicacion,
      ),
    );
    await _abrir(tester, 'Avisos');

    await tester.tap(find.text('Activar avisos'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ahora no'));
    await tester.pumpAndSettle();

    expect(ubicacion.activaciones, 0);
    expect(perfiles.zonaAvisosEn, isNull);
  });

  testWidgets('si ya tiene zona, activar los avisos no vuelve a preguntar', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final perfiles = PerfilRepositorioFalso()
      ..zonaAvisosEn = DateTime(2026, 10, 15);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        perfiles: perfiles,
        push: PushFalso(),
        ubicacion: UbicacionFalsa(perfiles),
      ),
    );
    await _abrir(tester, 'Avisos');

    await tester.tap(find.text('Activar avisos'));
    await tester.pumpAndSettle();

    expect(find.text('Usar mi zona'), findsNothing);
  });

  testWidgets('en Ajustes se ve la zona guardada y se puede borrar', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final perfiles = PerfilRepositorioFalso()
      ..zonaAvisosEn = DateTime(2026, 10, 15);
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        perfiles: perfiles,
        push: PushFalso(actual: EstadoPush.activado),
        ubicacion: UbicacionFalsa(perfiles, actual: EstadoUbicacion.permitida),
        eventos: eventos,
      ),
    );
    await _abrir(tester, 'Ajustes');

    expect(
      find.textContaining('Guardada: una zona aproximada'),
      findsOneWidget,
    );
    await tester.tap(find.text('Borrar'));
    await tester.pumpAndSettle();

    expect(perfiles.zonaAvisosEn, isNull);
    expect(find.textContaining('Borramos tu zona'), findsOneWidget);
    expect(find.textContaining('Sin guardar'), findsOneWidget);
    expect(eventos.map((e) => e['name']), contains('alert_zone_clear'));
  });

  testWidgets('desde Ajustes se puede guardar la zona', (tester) async {
    _pantallaDeCelular(tester);
    final perfiles = PerfilRepositorioFalso();
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        perfiles: perfiles,
        ubicacion: UbicacionFalsa(perfiles),
      ),
    );
    await _abrir(tester, 'Ajustes');

    await tester.tap(find.text('Usar mi zona'));
    await tester.pumpAndSettle();

    expect(perfiles.zonaAvisosEn, isNotNull);
    expect(
      find.textContaining('Guardada: una zona aproximada'),
      findsOneWidget,
    );
  });

  testWidgets('si el navegador la bloquea, explica cómo habilitarla', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final perfiles = PerfilRepositorioFalso();
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        perfiles: perfiles,
        ubicacion: UbicacionFalsa(perfiles, actual: EstadoUbicacion.bloqueada),
      ),
    );
    await _abrir(tester, 'Ajustes');

    expect(find.textContaining('bloqueada en este navegador'), findsOneWidget);
    expect(find.text('Usar mi zona'), findsNothing);
  });

  testWidgets('al abrir la app con sesión actualiza la zona sin preguntar', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final perfiles = PerfilRepositorioFalso();
    final ubicacion = UbicacionFalsa(
      perfiles,
      actual: EstadoUbicacion.permitida,
    );
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        perfiles: perfiles,
        ubicacion: ubicacion,
      ),
    );
    await tester.pumpAndSettle();

    expect(ubicacion.renovaciones, greaterThanOrEqualTo(1));
    expect(ubicacion.activaciones, 0);
    expect(find.byType(AlertDialog), findsNothing);
  });

  testWidgets('sin Supabase configurado no se muestra la zona', (tester) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(cuenta: ServicioCuentaFalso(conectado: _ana)),
    );
    await _abrir(tester, 'Ajustes');

    expect(find.text('Zona para avisos de perdidos'), findsNothing);
  });
}
