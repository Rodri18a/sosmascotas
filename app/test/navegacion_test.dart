import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota/src/router.dart';
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
    await tester.pumpWidget(
      appDePrueba(eventos: metricas, inicio: Rutas.inicio),
    );
    await tester.pumpAndSettle();
    expect(
      find.widgetWithText(AppBar, 'Inicio'),
      findsOneWidget,
      reason: 'abre en el muro (D127)',
    );

    final textos = [
      for (final w in tester.widgetList<Text>(
        find.descendant(
          of: find.byType(BarraInferior),
          matching: find.byType(Text),
        ),
      ))
        w.data,
    ];
    expect(textos, ['Inicio', 'SOS', 'Mapa', 'Mascotas', 'Urgencias']);

    for (final (pestana, titulo) in [
      ('SOS', 'SOS'),
      ('Mascotas', 'Mascotas'),
      ('Urgencias', 'Urgencias'),
    ]) {
      await _tocarPestana(tester, pestana);
      expect(find.widgetWithText(AppBar, titulo), findsOneWidget);
    }

    // El botón redondo del medio vuelve al Mapa.
    await tester.tap(find.byIcon(Icons.map_outlined));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Mapa'), findsOneWidget);
    await _tocarPestana(tester, 'Inicio');
    expect(find.widgetWithText(AppBar, 'Inicio'), findsOneWidget);
    expect(
      [
        for (final e in metricas)
          if (e['name'] == 'tab_open') (e['props']! as Map)['tab'],
      ],
      ['sos', 'mascotas', 'ayuda', 'mapa', 'noticias'],
    );
  });

  testWidgets('cada pestaña conserva su estado al cambiar', (tester) async {
    await tester.pumpWidget(appDePrueba(inicio: Rutas.inicio));
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
    await tester.pumpWidget(appDePrueba(inicio: Rutas.inicio));
    await tester.pumpAndSettle();
    await _tocarPestana(tester, 'Urgencias');

    await abrirAjustesDesdeMenu(tester);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Ajustes'), findsOneWidget);
    expect(find.byType(BarraInferior), findsNothing);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Urgencias'), findsOneWidget);
  });

  Future<void> irDirecto(WidgetTester tester, String ruta) async {
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go(ruta);
    await tester.pumpAndSettle();
  }

  testWidgets('entrando directo a una pantalla fuera de las pestañas, la '
      'flecha lleva al Inicio', (tester) async {
    await tester.pumpWidget(appDePrueba(inicio: Rutas.inicio));
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
        find.widgetWithText(AppBar, 'Inicio'),
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
        inicio: Rutas.inicio,
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

  testWidgets('al cerrar sesión se descarta la navegación: Mascotas abre su '
      'pantalla aunque se haya quedado en una ficha (CU-07)', (tester) async {
    final cuenta = ServicioCuentaFalso(
      conectado: const Usuario(id: 'u1', email: 'ana@correo.com'),
    );
    await tester.pumpWidget(
      appDePrueba(
        inicio: Rutas.inicio,
        cuenta: cuenta,
        mascotas: MascotasFalsas(const [
          Mascota(id: 'm1', nombre: 'Luna', especieId: 2),
        ]),
      ),
    );
    await tester.pumpAndSettle();
    await _tocarPestana(tester, 'Mascotas');
    await irDirecto(tester, '/mascotas/m1');
    expect(find.widgetWithText(AppBar, 'Luna'), findsOneWidget);

    cuenta.conectar(null);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Inicio'), findsOneWidget);
    expect(find.text('Luna'), findsNothing, reason: 'no queda nada privado');

    await _tocarPestana(tester, 'Mascotas');
    expect(find.widgetWithText(AppBar, 'Mascotas'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Ingresar'), findsNothing);
  });
}
