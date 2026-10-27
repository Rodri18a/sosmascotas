import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'plan_usuario_falso.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

Future<PlanUsuarioFalso> _abrir(
  WidgetTester tester, {
  MiPlanUsuario plan = const MiPlanUsuario(
    plan: Plan.free,
    mascotas: 3,
    limiteMascotas: 5,
  ),
  bool prendida = true,
  List<Map<String, Object?>>? eventos,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final planes = PlanUsuarioFalso(plan);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      planUsuario: planes,
      eventos: eventos,
      funcionalidades: FuncionalidadesFalsas({
        if (prendida) Funcionalidades.planesUsuario,
      }),
    ),
  );
  await tester.pumpAndSettle();
  return planes;
}

Future<void> _ir(WidgetTester tester, String ruta) async {
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(ruta);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sin la funcionalidad no está en Ajustes', (tester) async {
    await _abrir(tester, prendida: false);
    await _ir(tester, '/ajustes');
    expect(find.text('Mi plan'), findsNothing);
  });

  testWidgets('Gratis: ve sus mascotas y pide Pro una sola vez', (
    tester,
  ) async {
    final eventos = <Map<String, Object?>>[];
    final planes = await _abrir(tester, eventos: eventos);
    await _ir(tester, '/ajustes');
    await tester.scrollUntilVisible(find.text('Mi plan'), 200);
    await tester.tap(find.text('Mi plan'));
    await tester.pumpAndSettle();

    expect(find.text('Plan Gratis'), findsOneWidget);
    expect(find.textContaining('3 mascotas de 5'), findsOneWidget);
    expect(find.textContaining('es gratis siempre'), findsOneWidget);
    expect(find.textContaining('30 días gratis de Familia'), findsOneWidget);
    await tester.tap(find.text('Quiero Pro'));
    await tester.pumpAndSettle();
    expect(planes.pedidos.single, Plan.pro);
    expect(eventos.where((e) => e['name'] == 'plan_request').single['props'], {
      'plan': 'pro',
    });
    expect(find.text('Ya pediste Pro: te vamos a contactar.'), findsOneWidget);
    // Con un pedido abierto, no se pide otro.
    final familia = find.widgetWithText(FilledButton, 'Quiero Familia');
    expect(tester.widget<FilledButton>(familia).onPressed, isNull);
  });

  testWidgets('Familia en prueba: cuándo termina', (tester) async {
    await _abrir(
      tester,
      plan: MiPlanUsuario(
        plan: Plan.family,
        estado: EstadoPlan.activo,
        vence: DateTime(2026, 11, 26),
        prueba: true,
        pruebaFamiliaUsada: true,
      ),
    );
    await _ir(tester, '/mi-plan');
    expect(find.text('Plan Familia'), findsOneWidget);
    expect(
      find.textContaining('Prueba gratis de Familia hasta'),
      findsOneWidget,
    );
    expect(find.textContaining('Mejorá tu plan'), findsNothing);
  });

  testWidgets('integrante de un hogar Familia', (tester) async {
    await _abrir(
      tester,
      plan: const MiPlanUsuario(
        plan: Plan.free,
        efectivo: Plan.family,
        porHogar: true,
      ),
    );
    await _ir(tester, '/mi-plan');
    expect(find.text('Plan Familia'), findsOneWidget);
    expect(find.textContaining('sos parte de un hogar'), findsOneWidget);
  });

  testWidgets('con Pro se elige el tamaño de letra', (tester) async {
    await _abrir(tester, plan: const MiPlanUsuario(plan: Plan.pro));
    await _ir(tester, '/ajustes');
    await tester.scrollUntilVisible(find.text('Tamaño de letra'), 200);
    double escala() => MediaQuery.of(
      tester.element(find.text('Tamaño de letra')),
    ).textScaler.scale(1);
    expect(escala(), 1);
    await tester.tap(find.text('Grande'));
    await tester.pumpAndSettle();
    expect(escala(), closeTo(1.15, 0.001));
  });

  testWidgets('con Gratis no aparece el tamaño de letra', (tester) async {
    await _abrir(tester);
    await _ir(tester, '/ajustes');
    expect(find.text('Tamaño de letra'), findsNothing);
  });
}
