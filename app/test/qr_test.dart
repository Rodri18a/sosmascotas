import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/qr/cartel_qr.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'helpers.dart';
import 'mascotas_falsas.dart';
import 'qr_falso.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');
const _luna = Mascota(id: 'm1', nombre: 'Luna', especieId: 2);

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _abrirQrDeLuna(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Mis mascotas'),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(ListTile, 'Luna'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('Chapita QR'));
  await tester.pumpAndSettle();
}

Future<void> _ver(WidgetTester tester, Finder objetivo) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    objetivo,
    150,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('muestra el QR con el enlace público y el código', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas([_luna]),
      ),
    );
    await _abrirQrDeLuna(tester);

    expect(find.widgetWithText(AppBar, 'Chapita QR'), findsOneWidget);
    expect(find.text('K7M2QX9P'), findsOneWidget);
    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(
      (qr.semanticsLabel, qr.errorCorrectionLevel),
      ('QR de Luna', QrErrorCorrectLevel.H),
    );
  });

  testWidgets('guardar la nota para quien la encuentre', (tester) async {
    _pantallaDeCelular(tester);
    final qr = QrFalso();
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas([_luna]),
        qr: qr,
      ),
    );
    await _abrirQrDeLuna(tester);

    final campo = find.byType(TextField);
    await _ver(tester, campo);
    await tester.enterText(campo, 'Toma medicación');
    await _ver(tester, find.text('Guardar'));
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    expect(qr.porMascota['m1']!.notaPublica, 'Toma medicación');
    expect(find.text('Nota guardada'), findsOneWidget);
  });

  testWidgets('cambiar el código pide confirmación', (tester) async {
    _pantallaDeCelular(tester);
    final qr = QrFalso();
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas([_luna]),
        qr: qr,
      ),
    );
    await _abrirQrDeLuna(tester);

    final cambiar = find.widgetWithText(TextButton, 'Cambiar el código');
    await _ver(tester, cambiar);
    await tester.tap(cambiar);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(qr.regeneraciones, 0);

    await tester.tap(cambiar);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Cambiar el código'));
    await tester.pumpAndSettle();

    expect(qr.regeneraciones, 1);
    expect(find.text('Listo: el código nuevo ya está activo.'), findsOneWidget);
  });

  testWidgets('el cartel para imprimir es un PNG', (tester) async {
    final png = await tester.runAsync(
      () => cartelQrPng(
        url: urlPaginaQr('K7M2QX9P'),
        nombre: 'Luna',
        indicacion: '¿Me encontraste? Escaneame',
        codigo: 'K7M2QX9P',
      ),
    );

    expect(png!.sublist(0, 8), [137, 80, 78, 71, 13, 10, 26, 10]);
  });
}
