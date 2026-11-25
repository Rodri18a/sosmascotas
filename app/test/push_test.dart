import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/push/servicio_push.dart';

import 'cuenta_falsa.dart';
import 'helpers.dart';
import 'push_falso.dart';

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

SwitchListTile _interruptor(WidgetTester tester) => tester.widget(
  find.widgetWithText(SwitchListTile, 'Avisos en este dispositivo'),
);

void main() {
  testWidgets('la bandeja invita a activar los avisos y la tarjeta se va', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final push = PushFalso();
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        push: push,
      ),
    );
    await _abrir(tester, 'Avisos');

    expect(find.textContaining('Activá los avisos'), findsOneWidget);
    await tester.tap(find.text('Activar avisos'));
    await tester.pumpAndSettle();

    expect(push.actual, EstadoPush.activado);
    expect(find.textContaining('¡Listo!'), findsOneWidget);
    expect(find.textContaining('Activá los avisos'), findsNothing);
  });

  testWidgets('si falla al obtener o guardar el token, no dice "¡Listo!"', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final push = PushFalso()..fallar = true;
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        push: push,
      ),
    );
    await _abrir(tester, 'Avisos');

    await tester.tap(find.text('Activar avisos'));
    await tester.pumpAndSettle();

    expect(find.textContaining('No pudimos activar'), findsOneWidget);
    expect(find.textContaining('¡Listo!'), findsNothing);
    expect(find.textContaining('Activá los avisos'), findsOneWidget);
  });

  testWidgets('si el navegador niega el permiso, explica cómo habilitarlo', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final push = PushFalso(alPedirPermiso: EstadoPush.bloqueado);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        push: push,
      ),
    );
    await _abrir(tester, 'Ajustes');

    expect(_interruptor(tester).value, isFalse);
    await tester.tap(find.text('Avisos en este dispositivo'));
    await tester.pumpAndSettle();

    expect(find.textContaining('bloqueados en este navegador'), findsWidgets);
    expect(_interruptor(tester).onChanged, isNull);
  });

  testWidgets('apagar los avisos desde Ajustes', (tester) async {
    _pantallaDeCelular(tester);
    final push = PushFalso(actual: EstadoPush.activado);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        push: push,
      ),
    );
    await _abrir(tester, 'Ajustes');

    expect(_interruptor(tester).value, isTrue);
    await tester.tap(find.text('Avisos en este dispositivo'));
    await tester.pumpAndSettle();

    expect(push.actual, EstadoPush.apagado);
    expect(_interruptor(tester).value, isFalse);
  });

  testWidgets('sin soporte (iPhone sin instalar) explica qué hacer', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        push: PushFalso(actual: EstadoPush.noDisponible),
      ),
    );
    await _abrir(tester, 'Ajustes');

    expect(find.textContaining('pantalla de inicio'), findsOneWidget);
    expect(_interruptor(tester).onChanged, isNull);
  });

  testWidgets('al abrir la app con sesión renueva el token; al cerrar sesión '
      'el dispositivo deja de recibir', (tester) async {
    _pantallaDeCelular(tester);
    final push = PushFalso(actual: EstadoPush.activado);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        push: push,
      ),
    );
    await _abrir(tester, 'Ajustes');
    expect(push.renovaciones, greaterThanOrEqualTo(1));

    await tester.scrollUntilVisible(
      find.text('Cerrar sesión'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tocarBajando(tester, find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    expect(push.olvidos, 1);
  });
}
