import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/router.dart';

import 'cuenta_falsa.dart';
import 'helpers.dart';
import 'soporte_falso.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

Future<void> _abrirSoporte(WidgetTester tester) async {
  // La ilustración de arriba (D162) empuja el formulario: se baja hasta él.
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpAndSettle();
  await abrirAjustesDesdeMenu(tester);
  await tester.tap(find.text('Ayuda y soporte'));
  await tester.pumpAndSettle();
  if (find.byType(TextField).evaluate().isNotEmpty) {
    await tester.ensureVisible(find.byType(TextField));
    await tester.pumpAndSettle();
  }
}

void main() {
  testWidgets('Ajustes → Ayuda y soporte: el correo abre un mail y sin '
      'WhatsApp cargado no se muestra', (tester) async {
    final enlaces = <Uri>[];
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        enlacesAbiertos: enlaces,
        eventos: eventos,
      ),
    );
    await _abrirSoporte(tester);

    expect(find.text('soporte@huellamy.com'), findsOneWidget);
    expect(find.text('Escribinos por WhatsApp'), findsNothing);
    await tester.tap(find.text('Mandanos un correo'));
    await tester.pumpAndSettle();

    expect(enlaces.single.scheme, 'mailto');
    expect(enlaces.single.path, 'soporte@huellamy.com');
    expect(
      eventos.map((e) => e['name']),
      containsAll(['support_open', 'support_email']),
    );
  });

  testWidgets('con WhatsApp cargado en la base, se muestra y abre wa.me', (
    tester,
  ) async {
    final enlaces = <Uri>[];
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        soporte: SoporteFalso(whatsapp: '59899000000'),
        enlacesAbiertos: enlaces,
      ),
    );
    await _abrirSoporte(tester);

    await tester.tap(find.text('Escribinos por WhatsApp'));
    await tester.pumpAndSettle();
    expect(enlaces.single.toString(), 'https://wa.me/59899000000');
  });

  testWidgets('con sesión, «Escribinos» manda el mensaje', (tester) async {
    final soporte = SoporteFalso();
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        soporte: soporte,
        eventos: eventos,
      ),
    );
    await _abrirSoporte(tester);

    await tester.enterText(find.byType(TextField), 'hola');
    await tester.ensureVisible(find.text('Enviar'));
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();
    expect(soporte.enviados, isEmpty);
    expect(
      find.text('Escribí un poco más, así te podemos ayudar.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byType(TextField),
      '  No me llega el código para ingresar  ',
    );
    await tester.ensureVisible(find.text('Enviar'));
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();
    expect(soporte.enviados, ['No me llega el código para ingresar']);
    expect(
      find.text('¡Listo! Te respondemos al correo de tu cuenta.'),
      findsOneWidget,
    );
    // La métrica no lleva el texto del mensaje.
    final envio = eventos.singleWhere((e) => e['name'] == 'support_message');
    expect(envio.toString(), isNot(contains('código')));
  });

  testWidgets('si ya mandó muchos, se le avisa', (tester) async {
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        soporte: SoporteFalso(limite: 0),
      ),
    );
    await _abrirSoporte(tester);

    await tester.enterText(
      find.byType(TextField),
      'Tengo una duda con la chapita',
    );
    await tester.ensureVisible(find.text('Enviar'));
    await tester.tap(find.text('Enviar'));
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Ya nos mandaste varios mensajes'),
      findsOneWidget,
    );
  });

  testWidgets('un visitante ve el correo y se le pide ingresar para escribir', (
    tester,
  ) async {
    await tester.pumpWidget(appDePrueba());
    await _abrirSoporte(tester);

    expect(find.text('soporte@huellamy.com'), findsOneWidget);
    expect(find.byType(TextField), findsNothing);
    expect(
      find.text('Ingresá para escribirnos desde la app, o mandanos un correo.'),
      findsOneWidget,
    );
  });

  testWidgets('en Huellamy Comercios no aparece el aviso de SOS', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        appComercio: true,
        inicio: Rutas.soporte,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('soporte@huellamy.com'), findsOneWidget);
    expect(find.text('Ir a SOS'), findsNothing);
  });
}
