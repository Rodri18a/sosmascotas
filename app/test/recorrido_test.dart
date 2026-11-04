import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota/src/recorrido/recorrido.dart';
import 'package:sosmascota/src/router.dart';

import 'helpers.dart';

Future<List<Map<String, Object?>>> _abrir(
  WidgetTester tester,
  AlmacenRecorridos recorridos,
) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final metricas = <Map<String, Object?>>[];
  await tester.pumpWidget(
    appDePrueba(
      inicio: Rutas.inicio,
      eventos: metricas,
      recorridos: recorridos,
    ),
  );
  await tester.pumpAndSettle();
  // El recorrido espera a que la pantalla termine de cargar.
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
  return metricas;
}

Iterable<Object?> _de(List<Map<String, Object?>> metricas, String nombre) =>
    metricas.where((e) => e['name'] == nombre).map((e) => e['props']);

void main() {
  testWidgets('la primera vez sale solo; Saltar lo cierra y no vuelve', (
    tester,
  ) async {
    final almacen = AlmacenRecorridosFalso();
    final metricas = await _abrir(tester, almacen);
    expect(find.text('¡Te damos la bienvenida a Huellitas!'), findsOneWidget);
    expect(almacen.vistos, {PantallaRecorrido.inicio});
    expect(_de(metricas, 'tour_start'), [
      {'screen': 'inicio', 'auto': true},
    ]);

    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('El menú'), findsOneWidget);
    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();
    expect(find.text('El menú'), findsNothing);
    expect(_de(metricas, 'tour_skip'), [
      {'screen': 'inicio', 'step': 2},
    ]);
  });

  testWidgets('si ya se vio, no sale solo', (tester) async {
    final metricas = await _abrir(
      tester,
      AlmacenRecorridosFalso()..vistos.add(PantallaRecorrido.inicio),
    );
    expect(find.text('¡Te damos la bienvenida a Huellitas!'), findsNothing);
    expect(_de(metricas, 'tour_start'), isEmpty);
  });

  testWidgets('el botón ? lo repite hasta Listo, sin lo que no se ve', (
    tester,
  ) async {
    final metricas = await _abrir(
      tester,
      AlmacenRecorridosFalso(todosVistos: true),
    );
    await tester.tap(find.byTooltip('Cómo funciona esta pantalla'));
    await tester.pumpAndSettle();
    final titulos = <String>[];
    while (find.text('Listo').evaluate().isEmpty) {
      titulos.add(
        (tester.widget<Text>(
          find
              .descendant(of: find.byType(Card), matching: find.byType(Text))
              .first,
        )).data!,
      );
      // Tocar fuera del globo también pasa al siguiente.
      await tester.tapAt(const Offset(4, 300));
      await tester.pumpAndSettle();
    }
    expect(titulos.first, '¡Te damos la bienvenida a Huellitas!');
    expect(titulos, contains('El menú'));
    expect(titulos, contains('Lo principal, abajo'));
    expect(
      titulos,
      isNot(contains('Mensajes y avisos')),
      reason: 'un visitante no tiene avisos: el paso se saltea',
    );
    expect(find.text('¿Alguna duda?'), findsOneWidget);
    await tester.tap(find.text('Listo'));
    await tester.pumpAndSettle();
    expect(find.text('¿Alguna duda?'), findsNothing);
    expect(_de(metricas, 'tour_start'), [
      {'screen': 'inicio', 'auto': false},
    ]);
    expect(_de(metricas, 'tour_finish'), [
      {'screen': 'inicio'},
    ]);
    expect(_de(metricas, 'tour_skip'), isEmpty);
  });

  testWidgets('en las cinco pestañas está el ? y no el ícono de Ajustes', (
    tester,
  ) async {
    await _abrir(tester, AlmacenRecorridosFalso(todosVistos: true));
    for (final pestana in ['Inicio', 'SOS', 'Mapa', 'Mascotas', 'Urgencias']) {
      await tester.tap(
        find.descendant(
          of: find.byType(BarraInferior),
          matching: find.text(pestana),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.byTooltip('Cómo funciona esta pantalla'),
        findsOneWidget,
        reason: pestana,
      );
      expect(find.byIcon(Icons.settings_outlined), findsNothing);
    }
  });

  testWidgets('las pantallas de adentro también tienen su recorrido (D144)', (
    tester,
  ) async {
    final almacen = AlmacenRecorridosFalso()
      ..vistos.add(PantallaRecorrido.inicio);
    final metricas = await _abrir(tester, almacen);
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));

    router.go(Rutas.ajustes);
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    expect(find.textContaining('la zona para enterarte'), findsOneWidget);
    expect(almacen.vistos, contains(PantallaRecorrido.ajustes));
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Listo'));
    await tester.pumpAndSettle();
    expect(_de(metricas, 'tour_finish'), [
      {'screen': 'ajustes'},
    ]);

    // Con el ? se repite.
    await tester.tap(find.byTooltip('Cómo funciona esta pantalla'));
    await tester.pumpAndSettle();
    expect(find.textContaining('la zona para enterarte'), findsOneWidget);
  });
}
