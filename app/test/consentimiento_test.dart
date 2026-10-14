import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/redireccion.dart';

import 'cuenta_falsa.dart';
import 'helpers.dart';
import 'perfil_falso.dart';

Future<void> _tocarPestana(WidgetTester tester, String nombre) async {
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(nombre),
    ),
  );
  await tester.pumpAndSettle();
}

/// Pantalla de un celular común (360 × 800).
void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Desplaza la pantalla hasta que [objetivo] esté a la vista.
Future<void> _verHasta(WidgetTester tester, Finder objetivo) async {
  await tester.scrollUntilVisible(
    objetivo,
    120,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _ingresar(WidgetTester tester) async {
  await tester.enterText(find.byType(TextField), 'ana@correo.com');
  await tester.tap(find.text('Enviarme el código'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), '123456');
  await tester.tap(find.widgetWithText(FilledButton, 'Ingresar'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('cuenta nueva: acepta los términos y sigue con la acción', (
    tester,
  ) async {
    final perfiles = PerfilRepositorioFalso(aceptoTerminos: false);
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(appDePrueba(perfiles: perfiles, eventos: eventos));
    await tester.pumpAndSettle();
    await _tocarPestana(tester, 'SOS');
    await tester.tap(find.widgetWithText(FloatingActionButton, 'Reportar'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.widgetWithText(FilledButton, 'Ingresar o crear cuenta'),
    );
    await tester.pumpAndSettle();
    await _ingresar(tester);

    expect(find.widgetWithText(AppBar, 'Antes de empezar'), findsOneWidget);
    final aceptar = find.widgetWithText(FilledButton, 'Aceptar y continuar');
    await _verHasta(tester, aceptar);
    expect(tester.widget<FilledButton>(aceptar).onPressed, isNull);

    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await tester.tap(aceptar);
    await tester.pumpAndSettle();

    expect(perfiles.aceptaciones, 1);
    expect(find.widgetWithText(AppBar, 'Nuevo reporte'), findsOneWidget);
    expect(eventos.map((e) => e['name']), contains('signup'));
  });

  testWidgets('"No acepto" cierra la sesión', (tester) async {
    _pantallaDeCelular(tester);
    final cuenta = ServicioCuentaFalso(
      conectado: const Usuario(id: 'u1', email: 'ana@correo.com'),
    );
    await tester.pumpWidget(
      appDePrueba(
        cuenta: cuenta,
        perfiles: PerfilRepositorioFalso(aceptoTerminos: false),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Antes de empezar'), findsOneWidget);

    final noAcepto = find.text('No acepto (cerrar sesión)');
    await _verHasta(tester, noAcepto);
    await tester.tap(noAcepto);
    await tester.pumpAndSettle();

    expect(cuenta.actual, isNull);
    expect(find.widgetWithText(AppBar, 'Mapa'), findsOneWidget);
  });

  testWidgets('se pueden leer los términos antes de aceptar', (tester) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(
          conectado: const Usuario(id: 'u1', email: 'ana@correo.com'),
        ),
        perfiles: PerfilRepositorioFalso(aceptoTerminos: false),
      ),
    );
    await tester.pumpAndSettle();

    final privacidad = find.widgetWithText(
      TextButton,
      'Política de privacidad',
    );
    await _verHasta(tester, privacidad);
    await tester.tap(privacidad);
    await tester.pumpAndSettle();

    expect(
      find.widgetWithText(AppBar, 'Política de privacidad'),
      findsOneWidget,
    );
    expect(find.textContaining('Ley 18.331'), findsWidgets);
  });

  group('redirigir con consentimiento pendiente', () {
    test(
      'cualquier pantalla lleva al consentimiento y guarda a dónde volver',
      () {
        expect(
          redirigir(
            conectado: true,
            necesitaConsentimiento: true,
            uri: Uri.parse('/sos/nuevo'),
          ),
          '/consentimiento?volver=%2Fsos%2Fnuevo',
        );
      },
    );

    test('los textos legales se pueden leer', () {
      expect(
        redirigir(
          conectado: true,
          necesitaConsentimiento: true,
          uri: Uri.parse('/legal/terminos'),
        ),
        isNull,
      );
    });

    test('ya aceptado, el consentimiento vuelve a la acción', () {
      expect(
        redirigir(
          conectado: true,
          uri: Uri.parse('/consentimiento?volver=%2Fmascotas'),
        ),
        '/mascotas',
      );
    });
  });
}
