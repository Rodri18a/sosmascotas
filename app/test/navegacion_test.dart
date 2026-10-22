import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'libreta_falsa.dart';
import 'mascotas_falsas.dart';

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

  Future<void> irDirecto(WidgetTester tester, String ruta) async {
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go(ruta);
    await tester.pumpAndSettle();
  }

  testWidgets('entrando directo a una pantalla fuera de las pestañas, la '
      'flecha lleva al Mapa', (tester) async {
    await tester.pumpWidget(appDePrueba());
    await tester.pumpAndSettle();
    for (final (ruta, titulo) in [
      ('/legal/terminos', 'Términos y condiciones'),
      ('/ingresar', 'Ingresar'),
    ]) {
      await irDirecto(tester, ruta);
      expect(find.byType(BarraInferior), findsNothing, reason: ruta);
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();
      expect(
        find.widgetWithText(AppBar, 'Mapa'),
        findsOneWidget,
        reason: titulo,
      );
    }
  });

  testWidgets('desde la libreta abierta directo, la flecha va a la ficha', (
    tester,
  ) async {
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(
          conectado: const Usuario(id: 'u1', email: 'ana@correo.com'),
        ),
        mascotas: MascotasFalsas(const [
          Mascota(id: 'm1', nombre: 'Luna', especieId: 2),
        ]),
        libreta: LibretaFalsa(),
        funcionalidades: FuncionalidadesFalsas({Funcionalidades.libreta}),
      ),
    );
    await tester.pumpAndSettle();
    await irDirecto(tester, '/libreta/m1/nuevo');
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Luna'), findsOneWidget);
  });
}
