import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'helpers.dart';
import 'instalacion_falsa.dart';

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _abrirAjustes(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await abrirAjustesDesdeMenu(tester);
  await tester.pumpAndSettle();
}

List<Object?> _props(List<Map<String, Object?>> eventos, String nombre) =>
    eventos.where((e) => e['name'] == nombre).map((e) => e['props']).toList();

void main() {
  group('Ajustes', () {
    testWidgets('con aviso del navegador: instala y lo mide', (tester) async {
      _pantallaDeCelular(tester);
      final navegador = InstalacionFalsa(puedeMostrarAviso: true);
      final eventos = <Map<String, Object?>>[];
      await tester.pumpWidget(
        appDePrueba(instalacion: navegador, eventos: eventos),
      );
      await _abrirAjustes(tester);

      await tester.tap(find.text('Instalar la app'));
      await tester.pumpAndSettle();

      expect(navegador.avisosMostrados, 1);
      expect(find.textContaining('Ya podés abrir Huellitas'), findsOneWidget);
      expect(find.text('Instalar la app'), findsNothing);
      expect(_props(eventos, 'pwa_prompt'), [
        {'origen': 'ajustes', 'forma': 'aviso', 'resultado': 'aceptada'},
      ]);
    });

    testWidgets('si la rechaza, se mide y no se agradece', (tester) async {
      _pantallaDeCelular(tester);
      final eventos = <Map<String, Object?>>[];
      await tester.pumpWidget(
        appDePrueba(
          instalacion: InstalacionFalsa(puedeMostrarAviso: true, acepta: false),
          eventos: eventos,
        ),
      );
      await _abrirAjustes(tester);

      await tester.tap(find.text('Instalar la app'));
      await tester.pumpAndSettle();

      expect(find.textContaining('Ya podés abrir'), findsNothing);
      expect(_props(eventos, 'pwa_prompt'), [
        {'origen': 'ajustes', 'forma': 'aviso', 'resultado': 'rechazada'},
      ]);
    });

    testWidgets('en el iPhone muestra los pasos y el aviso de las push', (
      tester,
    ) async {
      _pantallaDeCelular(tester);
      final eventos = <Map<String, Object?>>[];
      await tester.pumpWidget(
        appDePrueba(
          instalacion: InstalacionFalsa(esIphone: true),
          eventos: eventos,
        ),
      );
      await _abrirAjustes(tester);

      await tester.tap(find.text('Instalar la app'));
      await tester.pumpAndSettle();

      expect(find.text('Instalar en el iPhone'), findsOneWidget);
      expect(find.textContaining('Agregar a inicio'), findsOneWidget);
      expect(
        find.textContaining('solo llegan con la app instalada'),
        findsOneWidget,
      );
      await tester.tap(find.text('Entendido'));
      await tester.pumpAndSettle();
      expect(_props(eventos, 'pwa_prompt'), [
        {'origen': 'ajustes', 'forma': 'iphone', 'resultado': 'pasos'},
      ]);
    });

    for (final (caso, navegador) in [
      (
        'ya instalada',
        () => InstalacionFalsa(yaInstalada: true, puedeMostrarAviso: true),
      ),
      ('sin forma de instalar', InstalacionFalsa.new),
    ]) {
      testWidgets('$caso: no aparece', (tester) async {
        _pantallaDeCelular(tester);
        await tester.pumpWidget(appDePrueba(instalacion: navegador()));
        await _abrirAjustes(tester);
        expect(find.text('Instalar la app'), findsNothing);
      });
    }

    testWidgets('si no se ofrecía, instalar desde el navegador no se cuenta', (
      tester,
    ) async {
      _pantallaDeCelular(tester);
      final navegador = InstalacionFalsa();
      final eventos = <Map<String, Object?>>[];
      await tester.pumpWidget(
        appDePrueba(instalacion: navegador, eventos: eventos),
      );
      await _abrirAjustes(tester);
      expect(find.text('Instalar la app'), findsNothing);

      navegador.puedeMostrarAviso = true;
      navegador.instalarDesdeElNavegador(); // emite el cambio
      await tester.pumpAndSettle();
      expect(find.text('Instalar la app'), findsNothing);
      // Venía "ninguna" (no se ofrecía): no cuenta como instalación por la app.
      expect(_props(eventos, 'pwa_installed'), isEmpty);
    });
  });

  group('tarjeta del mapa', () {
    testWidgets('no aparece en la primera apertura', (tester) async {
      _pantallaDeCelular(tester);
      await tester.pumpWidget(
        appDePrueba(instalacion: InstalacionFalsa(puedeMostrarAviso: true)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Instalá Huellitas'), findsNothing);
    });

    testWidgets('desde la segunda apertura aparece, y "Ahora no" la descarta', (
      tester,
    ) async {
      _pantallaDeCelular(tester);
      final almacen = AlmacenInstalacionFalso(aperturas: 1);
      await tester.pumpWidget(
        appDePrueba(
          instalacion: InstalacionFalsa(puedeMostrarAviso: true),
          almacenInstalacion: almacen,
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Instalá Huellitas'), findsOneWidget);
      await tester.tap(find.text('Ahora no'));
      await tester.pumpAndSettle();

      expect(find.text('Instalá Huellitas'), findsNothing);
      expect(almacen.estaDescartada, isTrue);
    });

    testWidgets('instalar desde la tarjeta la saca y lo mide', (tester) async {
      _pantallaDeCelular(tester);
      final eventos = <Map<String, Object?>>[];
      await tester.pumpWidget(
        appDePrueba(
          instalacion: InstalacionFalsa(puedeMostrarAviso: true),
          almacenInstalacion: AlmacenInstalacionFalso(aperturas: 5),
          eventos: eventos,
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, 'Instalar'));
      await tester.pumpAndSettle();

      expect(find.text('Instalá Huellitas'), findsNothing);
      expect(_props(eventos, 'pwa_prompt'), [
        {'origen': 'mapa', 'forma': 'aviso', 'resultado': 'aceptada'},
      ]);
    });

    testWidgets('descartada no vuelve a aparecer', (tester) async {
      _pantallaDeCelular(tester);
      await tester.pumpWidget(
        appDePrueba(
          instalacion: InstalacionFalsa(puedeMostrarAviso: true),
          almacenInstalacion: AlmacenInstalacionFalso(
            aperturas: 5,
            estaDescartada: true,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Instalá Huellitas'), findsNothing);
    });
  });

  testWidgets('instalada desde el menú del navegador: se mide pwa_installed', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final navegador = InstalacionFalsa(puedeMostrarAviso: true);
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(instalacion: navegador, eventos: eventos),
    );
    await _abrirAjustes(tester);
    expect(find.text('Instalar la app'), findsOneWidget);

    navegador.instalarDesdeElNavegador();
    await tester.pumpAndSettle();

    expect(find.text('Instalar la app'), findsNothing);
    expect(eventos.where((e) => e['name'] == 'pwa_installed'), hasLength(1));
  });
}
