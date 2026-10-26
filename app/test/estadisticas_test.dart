import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

final _negocio = MiNegocio.fromJson({
  'id': 'b1',
  'name': 'Peluquería Luna',
  'business_type': 'grooming',
  'kind': 'local',
  'lat': -34.71,
  'lng': -55.95,
  'verification': 'verified',
  'plan': 'plus',
  'status': 'active',
});

Future<NegociosFalsos> _abrir(
  WidgetTester tester, {
  bool prendida = true,
  EstadisticasNegocio? estadisticas,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final negocios = NegociosFalsos([_negocio]);
  if (estadisticas != null) negocios.estadisticasFijas = estadisticas;
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      negocios: negocios,
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.comercios,
        if (prendida) Funcionalidades.estadisticas,
      }),
    ),
  );
  await tester.pumpAndSettle();
  return negocios;
}

Future<void> _ir(WidgetTester tester, String ruta) async {
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(ruta);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sin la funcionalidad no aparece en el Panel', (tester) async {
    await _abrir(tester, prendida: false);
    await _ir(tester, '/negocio');
    expect(find.text('Ver estadísticas'), findsNothing);
  });

  testWidgets('del Panel a las estadísticas completas (plan Plus)', (
    tester,
  ) async {
    await _abrir(tester);
    await _ir(tester, '/negocio');
    await tester.tap(find.text('Ver estadísticas'));
    await tester.pumpAndSettle();

    expect(find.text('Estadísticas'), findsOneWidget);
    expect(find.text('340'), findsOneWidget);
    expect(find.textContaining('70 % más que el mes anterior'), findsOneWidget);
    // Contactos: 30 contra 40.
    expect(
      find.textContaining('25 % menos que el mes anterior'),
      findsOneWidget,
    );
    expect(find.text('280'), findsOneWidget);
    // Chats: el mes anterior no hubo.
    expect(
      find.textContaining('Chats nuevos\nEl mes anterior: 0'),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(find.text('WhatsApp: 20'), 300);
    expect(find.text('WhatsApp: 20'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Últimas 12 semanas'), 300);
    expect(find.text('Últimas 12 semanas'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.textContaining('nunca se muestra quién fue'),
      300,
    );
    expect(find.textContaining('nunca se muestra quién fue'), findsOneWidget);
    expect(find.textContaining('Con el plan Básico'), findsNothing);
  });

  testWidgets('plan Básico: solo el resumen y la invitación a Destacado', (
    tester,
  ) async {
    await _abrir(
      tester,
      estadisticas: EstadisticasNegocio.fromJson({
        'completo': false,
        'meses': [
          {
            'mes': '2026-09-01',
            'metricas': {'place_open': 10, 'contactos': 2},
          },
          {
            'mes': '2026-10-01',
            'metricas': {'place_open': 10, 'contactos': 3},
          },
        ],
      }),
    );
    await _ir(tester, '/negocio/estadisticas/b1');
    expect(find.textContaining('Igual que el mes anterior'), findsOneWidget);
    expect(find.textContaining('Con el plan Básico'), findsOneWidget);
    expect(find.text('Últimas 12 semanas'), findsNothing);
  });

  testWidgets('sin movimiento lo dice', (tester) async {
    await _abrir(
      tester,
      estadisticas: EstadisticasNegocio.fromJson({
        'completo': true,
        'meses': [
          {'mes': '2026-10-01', 'metricas': <String, Object?>{}},
        ],
      }),
    );
    await _ir(tester, '/negocio/estadisticas/b1');
    expect(find.textContaining('Todavía no hay movimiento'), findsOneWidget);
  });
}
