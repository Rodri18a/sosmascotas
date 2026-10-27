import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'descuentos_falsos.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

Future<void> _abrir(
  WidgetTester tester, {
  required DescuentosFalsos descuentos,
  List<Map<String, Object?>>? eventos,
  NegociosFalsos? negocios,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      descuentos: descuentos,
      negocios: negocios,
      eventos: eventos,
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.planesUsuario,
        Funcionalidades.comercios,
      }),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _ir(WidgetTester tester, String ruta) async {
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(ruta);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sin Pro se ven los descuentos pero no se pide código', (
    tester,
  ) async {
    await _abrir(tester, descuentos: DescuentosFalsos());
    await _ir(tester, '/descuentos');
    expect(find.text('10 % en baños'), findsOneWidget);
    expect(find.text('Peluquería Luna · Artigas 123'), findsOneWidget);
    expect(find.text('Quiero mi código'), findsNothing);
    expect(find.text('Ver planes'), findsOneWidget);
  });

  testWidgets('con Pro pide su código', (tester) async {
    final descuentos = DescuentosFalsos(pro: true);
    final eventos = <Map<String, Object?>>[];
    await _abrir(tester, descuentos: descuentos, eventos: eventos);
    await _ir(tester, '/descuentos');
    await tester.tap(find.text('Quiero mi código'));
    await tester.pumpAndSettle();
    expect(descuentos.pedidos.single, 'd1');
    expect(find.text('ABC234'), findsOneWidget);
    expect(eventos.where((e) => e['name'] == 'discount_claim'), hasLength(1));
  });

  testWidgets('el comercio canjea un código y ve a quién', (tester) async {
    final descuentos = DescuentosFalsos();
    final eventos = <Map<String, Object?>>[];
    await _abrir(tester, descuentos: descuentos, eventos: eventos);
    await _ir(tester, '/negocio/descuentos/b1');
    expect(find.text('Tus descuentos'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'HOY000');
    await tester.tap(find.text('Canjear'));
    await tester.pumpAndSettle();
    expect(find.textContaining('ya se usó hoy'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, 'abc234');
    await tester.tap(find.text('Canjear'));
    await tester.pumpAndSettle();
    expect(descuentos.canjes.single, 'abc234');
    expect(find.text('Descuento válido'), findsOneWidget);
    expect(find.textContaining('Ana'), findsWidgets);
    expect(eventos.where((e) => e['name'] == 'discount_redeem'), hasLength(1));
  });

  testWidgets('sin verificar no puede cargar descuentos', (tester) async {
    await _abrir(tester, descuentos: DescuentosFalsos(puede: false));
    await _ir(tester, '/negocio/descuentos/b1');
    expect(find.text('Nuevo descuento'), findsNothing);
    expect(find.textContaining('tiene que estar verificado'), findsOneWidget);
  });
}
