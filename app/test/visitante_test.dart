import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/redireccion.dart';

import 'cuenta_falsa.dart';
import 'helpers.dart';

Future<void> _tocarPestana(WidgetTester tester, String nombre) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(nombre),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('un visitante que reporta: pide cuenta, ingresa y llega al '
      'formulario', (tester) async {
    final cuenta = ServicioCuentaFalso();
    await tester.pumpWidget(appDePrueba(cuenta: cuenta));
    await tester.pumpAndSettle();
    await _tocarPestana(tester, 'SOS');

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Reportar'));
    await tester.pumpAndSettle();
    expect(find.text('Necesitás una cuenta'), findsOneWidget);
    expect(find.textContaining('Tu teléfono nunca se muestra'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(FilledButton, 'Ingresar o crear cuenta'),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'ana@correo.com');
    await tester.tap(find.text('Enviarme el código'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Ingresar'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Nuevo reporte'), findsOneWidget);
  });

  testWidgets('"Ahora no" deja al visitante donde estaba', (tester) async {
    await tester.pumpWidget(appDePrueba());
    await tester.pumpAndSettle();
    await _tocarPestana(tester, 'Mis mascotas');

    await tester.tap(find.text('Agregar mascota'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ahora no'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Mis mascotas'), findsOneWidget);
    expect(find.text('Necesitás una cuenta'), findsNothing);
  });

  testWidgets('con sesión, la acción se abre directo', (tester) async {
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(
          conectado: const Usuario(id: 'u1', email: 'ana@correo.com'),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await _tocarPestana(tester, 'Mis mascotas');

    await tester.tap(find.text('Agregar mascota'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Nueva mascota'), findsOneWidget);
  });

  test('un enlace directo a una acción pide ingresar y vuelve', () {
    expect(
      redirigir(conectado: false, uri: Uri.parse('/sos/nuevo')),
      '/ingresar?volver=%2Fsos%2Fnuevo',
    );
    expect(redirigir(conectado: true, uri: Uri.parse('/sos/nuevo')), isNull);
  });
}
