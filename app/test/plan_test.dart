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

MiNegocio _negocio(String plan) => MiNegocio.fromJson({
  'id': 'b1',
  'name': 'Peluquería Luna',
  'business_type': 'grooming',
  'kind': 'local',
  'lat': -34.71,
  'lng': -55.95,
  'verification': 'verified',
  'plan': plan,
  'status': 'active',
});

Future<NegociosFalsos> _abrir(
  WidgetTester tester, {
  String plan = 'basic',
  MiPlan? miPlan,
  bool prendida = true,
  List<Map<String, Object?>>? eventos,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final negocios = NegociosFalsos([_negocio(plan)]);
  if (miPlan != null) negocios.planFijo = miPlan;
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      negocios: negocios,
      eventos: eventos,
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.comercios,
        if (prendida) Funcionalidades.planes,
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
    expect(find.textContaining('Tu plan'), findsNothing);
  });

  testWidgets('Básico: pide Destacado una sola vez', (tester) async {
    final eventos = <Map<String, Object?>>[];
    final negocios = await _abrir(tester, eventos: eventos);
    await _ir(tester, '/negocio');
    await tester.tap(find.text('Tu plan: Básico'));
    await tester.pumpAndSettle();

    expect(find.text('Plan Básico'), findsOneWidget);
    expect(find.text('Quiero Plus'), findsOneWidget);
    await tester.tap(find.text('Quiero Destacado'));
    await tester.pumpAndSettle();
    expect(negocios.planesPedidos.single, ('b1', PlanComercio.featured));
    expect(eventos.where((e) => e['name'] == 'plan_request').single['props'], {
      'plan': 'featured',
    });
    // Pedido abierto: los botones se apagan.
    expect(
      tester
          .widget<FilledButton>(
            find.ancestor(
              of: find.text('Quiero Plus'),
              matching: find.byType(FilledButton),
            ),
          )
          .onPressed,
      isNull,
    );
    expect(find.textContaining('Ya pediste un plan'), findsWidgets);
  });

  testWidgets('Destacado con atraso, pagos y antes/después', (tester) async {
    await _abrir(
      tester,
      plan: 'featured',
      miPlan: MiPlan.fromJson({
        'plan': 'featured',
        'estado': 'past_due',
        'vence': '2026-10-20',
        'precio': 600,
        'pagos': [
          {
            'fecha': '2026-09-20',
            'monto': 600,
            'metodo': 'transfer',
            'meses': 1,
          },
        ],
        'antes_despues': {
          'desde': '2026-09-20',
          'dias': 30,
          'aperturas_antes': 40,
          'aperturas_despues': 140,
          'contactos_antes': 2,
          'contactos_despues': 12,
        },
      }),
    );
    await _ir(tester, '/negocio/plan/b1');
    expect(find.textContaining('Tenés 7 días para pagarlo'), findsOneWidget);
    expect(find.textContaining(r'Precio: $ 600 por mes'), findsOneWidget);
    expect(
      find.textContaining(
        'En 30 días: 140 aperturas de tu ficha y 12 contactos',
      ),
      findsOneWidget,
    );
    await tester.scrollUntilVisible(find.text('Quiero Plus'), 300);
    expect(find.text('Quiero Plus'), findsOneWidget);
    expect(find.text('Quiero Destacado'), findsNothing);
    await tester.scrollUntilVisible(find.textContaining(r'$ 600 · 1 mes'), 300);
    expect(find.textContaining(r'$ 600 · 1 mes'), findsOneWidget);
  });
}
