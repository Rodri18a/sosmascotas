import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota/src/qr/cartel_qr.dart';
import 'package:sosmascota/src/qr/qr_repositorio.dart';
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
      of: find.byType(BarraInferior),
      matching: find.text('Mascotas'),
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

  testWidgets('muestra los últimos escaneos', (tester) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas([_luna]),
        qr: QrFalso(
          listaEscaneos: [
            Escaneo(
              id: 'e1',
              creado: DateTime(2026, 10, 14, 9, 5),
              lat: -34.7,
              lng: -55.9,
            ),
            Escaneo(id: 'e2', creado: DateTime(2026, 10, 13, 18, 40)),
          ],
        ),
      ),
    );
    await _abrirQrDeLuna(tester);
    await _ver(tester, find.text('Últimos escaneos'));

    await _ver(tester, find.text('Abrieron la página'));
    expect(
      find.text('Compartió su ubicación: tocá para verla'),
      findsOneWidget,
    );
    expect(find.text('14 de octubre, 09:05'), findsOneWidget);
  });

  testWidgets('activar una chapita con su código y desvincularla', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final qr = QrFalso();
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas([_luna]),
        qr: qr,
        eventos: eventos,
      ),
    );
    await _abrirQrDeLuna(tester);
    await _ver(tester, find.text('Activar una chapita'));
    expect(find.text('Todavía no vinculaste ninguna chapita.'), findsOneWidget);

    await tester.tap(find.text('Activar una chapita'));
    await tester.pumpAndSettle();
    final campo = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(campo, 'H4PZ7KQ');
    await tester.tap(find.text('Activar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('son 8 letras y números'), findsOneWidget);

    await tester.enterText(campo, 'ZZZZ2222');
    await tester.tap(find.text('Activar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No encontramos una chapita'), findsOneWidget);

    await tester.enterText(campo, 'h4pz-7kq2');
    await tester.tap(find.text('Activar'));
    await tester.pumpAndSettle();
    expect(qr.vinculadas.single.codigo, 'H4PZ7KQ2');
    expect(
      find.text('¡Listo! Quien escanee la chapita va a ver a Luna.'),
      findsOneWidget,
    );
    expect(eventos.where((e) => e['name'] == 'tag_activate').single['props'], {
      'origen': 'codigo',
    });
    await _ver(tester, find.text('H4PZ7KQ2'));

    await tester.tap(find.text('Desvincular'));
    await tester.pumpAndSettle();
    expect(find.text('¿Desvincular la chapita?'), findsOneWidget);
    await tester.tap(find.widgetWithText(FilledButton, 'Desvincular'));
    await tester.pumpAndSettle();
    expect(qr.vinculadas.single.activo, isFalse);
    expect(find.text('H4PZ7KQ2'), findsNothing);
    expect(eventos.map((e) => e['name']), contains('tag_unlink'));
  });

  testWidgets('el enlace de una chapita deja elegir la mascota y la activa', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final qr = QrFalso();
    const toto = Mascota(id: 'm2', nombre: 'Toto', especieId: 1);
    const ajena = Mascota(
      id: 'm3',
      nombre: 'Coco',
      especieId: 1,
      duenoId: 'otra',
    );
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas([_luna, toto, ajena]),
        qr: qr,
      ),
    );
    await tester.pumpAndSettle();
    GoRouter.of(
      tester.element(find.byType(Scaffold).first),
    ).go('/activar/w3rt8nm5');
    await tester.pumpAndSettle();

    expect(find.text('W3RT8NM5'), findsOneWidget);
    expect(find.text('Coco'), findsNothing, reason: 'solo las propias');
    final activar = find.widgetWithText(FilledButton, 'Activar');
    expect(tester.widget<FilledButton>(activar).onPressed, isNull);

    await tester.tap(find.text('Toto'));
    await tester.pumpAndSettle();
    await tester.tap(activar);
    await tester.pumpAndSettle();

    expect(qr.vinculadas.single.mascotaId, 'm2');
    expect(find.widgetWithText(AppBar, 'Chapita QR'), findsOneWidget);
    await _ver(tester, find.text('W3RT8NM5'));

    // La misma chapita otra vez: ya está usada.
    GoRouter.of(
      tester.element(find.byType(Scaffold).first),
    ).go('/activar/W3RT8NM5');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Luna'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Activar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ya está vinculada'), findsOneWidget);
  });

  testWidgets('sin mascotas, el enlace de la chapita invita a cargar una', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas(),
      ),
    );
    await tester.pumpAndSettle();
    GoRouter.of(
      tester.element(find.byType(Scaffold).first),
    ).go('/activar/W3RT8NM5');
    await tester.pumpAndSettle();

    expect(find.textContaining('Primero cargá a tu mascota'), findsOneWidget);
    expect(find.text('Agregar mascota'), findsOneWidget);
  });

  testWidgets('un visitante tiene que ingresar para activar una chapita', (
    tester,
  ) async {
    await tester.pumpWidget(appDePrueba());
    await tester.pumpAndSettle();
    GoRouter.of(
      tester.element(find.byType(Scaffold).first),
    ).go('/activar/W3RT8NM5');
    await tester.pumpAndSettle();

    expect(find.text('Activar chapita'), findsNothing);
    expect(find.text('Ingresar'), findsWidgets);
  });
}
