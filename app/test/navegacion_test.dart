import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';

import 'helpers.dart';

Future<void> _tocarPestana(WidgetTester tester, String nombre) async {
  await tester.tap(
    find.descendant(
      of: find.byType(BarraInferior),
      matching: find.text(nombre),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la barra inferior lleva a las 5 pestañas, con el Mapa en el '
      'medio', (tester) async {
    final metricas = <Map<String, Object?>>[];
    await tester.pumpWidget(appDePrueba(eventos: metricas));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Mapa'), findsOneWidget, reason: 'abre');

    final textos = [
      for (final w in tester.widgetList<Text>(
        find.descendant(
          of: find.byType(BarraInferior),
          matching: find.byType(Text),
        ),
      ))
        w.data,
    ];
    expect(textos, ['Noticias', 'SOS', 'Mapa', 'Mascotas', 'Ayuda']);

    for (final (pestana, titulo) in [
      ('Noticias', 'Noticias'),
      ('SOS', 'SOS'),
      ('Mascotas', 'Mis mascotas'),
      ('Ayuda', 'Ayuda'),
    ]) {
      await _tocarPestana(tester, pestana);
      expect(find.widgetWithText(AppBar, titulo), findsOneWidget);
    }

    // El botón redondo del medio vuelve al Mapa.
    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Mapa'), findsOneWidget);
    expect(
      [
        for (final e in metricas)
          if (e['name'] == 'tab_open') (e['props']! as Map)['tab'],
      ],
      ['noticias', 'sos', 'mascotas', 'ayuda', 'mapa'],
    );
  });

  testWidgets('cada pestaña conserva su estado al cambiar', (tester) async {
    await tester.pumpWidget(appDePrueba());
    await tester.pumpAndSettle();

    await _tocarPestana(tester, 'SOS');
    final estadoSos = tester.state(find.byType(Scaffold).last);
    await _tocarPestana(tester, 'Mapa');
    await _tocarPestana(tester, 'SOS');

    expect(tester.state(find.byType(Scaffold).last), same(estadoSos));
  });

  testWidgets('Ajustes se abre desde arriba y vuelve a la pestaña', (
    tester,
  ) async {
    await tester.pumpWidget(appDePrueba());
    await tester.pumpAndSettle();
    await _tocarPestana(tester, 'Ayuda');

    await tester.tap(find.byTooltip('Ajustes'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Ajustes'), findsOneWidget);
    expect(find.byType(BarraInferior), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Ayuda'), findsOneWidget);
  });
}
