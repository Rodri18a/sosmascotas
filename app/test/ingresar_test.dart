import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';

import 'cuenta_falsa.dart';
import 'helpers.dart';

Future<void> _irAIngresarDesdeAjustes(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Ajustes'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Ingresar o crear cuenta'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('ingresar con correo y código, y volver a Ajustes', (
    tester,
  ) async {
    final cuenta = ServicioCuentaFalso();
    await tester.pumpWidget(appDePrueba(cuenta: cuenta));
    await tester.pumpAndSettle();
    await _irAIngresarDesdeAjustes(tester);

    await tester.enterText(find.byType(TextField), ' Ana@Correo.com ');
    await tester.tap(find.text('Enviarme el código'));
    await tester.pumpAndSettle();
    expect(cuenta.correosEnviados, ['ana@correo.com']);
    expect(
      find.textContaining('Te mandamos un correo a ana@correo.com'),
      findsOneWidget,
    );

    await tester.enterText(find.byType(TextField), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Ingresar'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Ajustes'), findsOneWidget);
    expect(find.text('ana@correo.com'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('avisa si el correo está mal escrito', (tester) async {
    final cuenta = ServicioCuentaFalso();
    await tester.pumpWidget(appDePrueba(cuenta: cuenta));
    await tester.pumpAndSettle();
    await _irAIngresarDesdeAjustes(tester);

    await tester.enterText(find.byType(TextField), 'ana-sin-arroba');
    await tester.tap(find.text('Enviarme el código'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Revisá el correo'), findsOneWidget);
    expect(cuenta.correosEnviados, isEmpty);
  });

  testWidgets('avisa si el código es incorrecto', (tester) async {
    await tester.pumpWidget(appDePrueba());
    await tester.pumpAndSettle();
    await _irAIngresarDesdeAjustes(tester);
    await tester.enterText(find.byType(TextField), 'ana@correo.com');
    await tester.tap(find.text('Enviarme el código'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), '999999');
    await tester.tap(find.widgetWithText(FilledButton, 'Ingresar'));
    await tester.pumpAndSettle();

    expect(find.textContaining('El código no es correcto'), findsOneWidget);
  });

  testWidgets('avisa si hubo demasiados intentos', (tester) async {
    final cuenta = ServicioCuentaFalso()
      ..fallarCon = ErrorCuenta.demasiadosIntentos;
    await tester.pumpWidget(appDePrueba(cuenta: cuenta));
    await tester.pumpAndSettle();
    await _irAIngresarDesdeAjustes(tester);

    await tester.enterText(find.byType(TextField), 'ana@correo.com');
    await tester.tap(find.text('Enviarme el código'));
    await tester.pumpAndSettle();

    expect(find.textContaining('muchos intentos'), findsOneWidget);
  });

  testWidgets('cerrar sesión vuelve a ofrecer el ingreso', (tester) async {
    final cuenta = ServicioCuentaFalso(
      conectado: const Usuario(id: 'u1', email: 'ana@correo.com'),
    );
    await tester.pumpWidget(appDePrueba(cuenta: cuenta));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Ajustes'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Cerrar sesión'));
    await tester.pumpAndSettle();

    // Se descarta la navegación y arranca de nuevo en el Mapa (CU-07).
    expect(find.widgetWithText(AppBar, 'Mapa'), findsOneWidget);
    await tester.tap(find.byTooltip('Ajustes'));
    await tester.pumpAndSettle();
    expect(find.text('Ingresar o crear cuenta'), findsOneWidget);
  });

  testWidgets('sin Google configurado no muestra el botón', (tester) async {
    await tester.pumpWidget(appDePrueba(conSupabase: true));
    await tester.pumpAndSettle();
    await _irAIngresarDesdeAjustes(tester);

    expect(find.text('Continuar con Google'), findsNothing);
  });

  testWidgets('con Google configurado, el botón inicia el ingreso', (
    tester,
  ) async {
    final cuenta = ServicioCuentaFalso();
    await tester.pumpWidget(
      appDePrueba(conSupabase: true, googleHabilitado: true, cuenta: cuenta),
    );
    await tester.pumpAndSettle();
    await _irAIngresarDesdeAjustes(tester);

    await tester.tap(find.text('Continuar con Google'));
    await tester.pumpAndSettle();

    expect(cuenta.ingresosConGoogle, 1);
  });
}
