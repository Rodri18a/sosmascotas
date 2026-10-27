import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'tienda_falsa.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

final _negocio = MiNegocio.fromJson({
  'id': 'b1',
  'name': 'Pet Shop Luna',
  'business_type': 'petshop',
  'kind': 'local',
  'lat': -34.71,
  'lng': -55.95,
  'verification': 'verified',
  'plan': 'plus',
  'status': 'active',
});

Pedido _pedido(int n) => Pedido(
  id: 'o$n',
  numero: n,
  estado: EstadoPedido.nuevo,
  total: 890,
  creado: DateTime(2026, 10, 20, 9),
  actualizado: DateTime(2026, 10, 20, 9),
  cliente: 'Beto',
  renglones: const [
    RenglonPedido(nombre: 'Alimento', precio: 890, cantidad: 1),
  ],
);

Future<void> _abrir(
  WidgetTester tester, {
  required Size tamano,
  List<Pedido> pedidos = const [],
}) async {
  tester.view
    ..physicalSize = tamano
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      negocios: NegociosFalsos([_negocio]),
      tienda: TiendaFalsa(pedidos: pedidos),
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.comercios,
        Funcionalidades.catalogo,
      }),
    ),
  );
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/negocio');
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('en el celular, la barra de abajo', (tester) async {
    await _abrir(tester, tamano: const Size(400, 850));
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.byType(NavigationRail), findsNothing);
  });

  testWidgets('en la computadora, el menú al costado (portal, D114)', (
    tester,
  ) async {
    await _abrir(tester, tamano: const Size(1400, 900));
    expect(find.byType(NavigationRail), findsOneWidget);
    expect(find.byType(NavigationBar), findsNothing);
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationRail),
        matching: find.text('Pedidos'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('Beto'), findsNothing);
  });

  testWidgets('«Para atender» muestra los pedidos nuevos y lleva a Pedidos', (
    tester,
  ) async {
    await _abrir(
      tester,
      tamano: const Size(1400, 900),
      pedidos: [_pedido(9), _pedido(10)],
    );
    expect(find.text('Para atender'), findsOneWidget);
    await tester.tap(find.text('2 pedidos nuevos'));
    await tester.pumpAndSettle();
    expect(find.text('Para atender'), findsNothing);
    expect(find.text('Pedido #9 · Beto'), findsOneWidget);
  });

  testWidgets('sin nada pendiente no aparece', (tester) async {
    await _abrir(tester, tamano: const Size(1400, 900));
    expect(find.text('Para atender'), findsNothing);
  });
}
