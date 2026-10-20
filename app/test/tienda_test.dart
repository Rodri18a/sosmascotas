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
import 'veterinarias_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

const _petshop = Comercio(
  id: 'ps',
  nombre: 'Pet Shop Ejemplo',
  tipo: 'petshop',
  punto: Punto(-34.72, -55.95),
  horario: Horario({}),
  whatsapp: '099 000 014',
  plan: PlanComercio.plus,
);

List<Producto> _productos() => const [
  Producto(id: 'p1', nombre: 'Alimento perro adulto 3 kg', precio: 890),
  Producto(id: 'p2', nombre: 'Collar regulable', precio: 250),
  Producto(id: 'p3', nombre: 'Cucha a medida'),
];

MiNegocio _miPetshop() => MiNegocio.fromJson({
  'id': 'ps',
  'name': 'Pet Shop Ejemplo',
  'business_type': 'petshop',
  'kind': 'local',
  'lat': -34.72,
  'lng': -55.95,
  'verification': 'verified',
  'plan': 'plus',
  'status': 'active',
});

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

Future<void> _ir(WidgetTester tester, String ruta) async {
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(ruta);
  await tester.pumpAndSettle();
}

Future<void> _abrir(
  WidgetTester tester, {
  required TiendaFalsa tienda,
  bool conectado = true,
  bool conFuncionalidad = true,
  NegociosFalsos? negocios,
  VeterinariasFalsas? veterinarias,
  List<Uri>? enlaces,
  List<Map<String, Object?>>? metricas,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: conectado ? _ana : null),
      comercios: ComerciosFalsos([_petshop]),
      tienda: tienda,
      negocios: negocios,
      veterinarias: veterinarias,
      enlacesAbiertos: enlaces,
      eventos: metricas,
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.comercios,
        if (conFuncionalidad) Funcionalidades.catalogo,
      }),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _abrirFicha(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('mapa-mover')));
  await tester.pumpAndSettle();
  await _tocar(tester, find.byKey(const ValueKey('pin-ps')));
}

void main() {
  testWidgets('sin la funcionalidad, la ficha no muestra el catálogo', (
    tester,
  ) async {
    await _abrir(
      tester,
      tienda: TiendaFalsa(productos: _productos()),
      conFuncionalidad: false,
    );
    await _abrirFicha(tester);
    expect(find.textContaining('Ver catálogo'), findsNothing);
  });

  testWidgets('armar un pedido desde la ficha y verlo en "Mis pedidos"', (
    tester,
  ) async {
    final tienda = TiendaFalsa(productos: _productos());
    final metricas = <Map<String, Object?>>[];
    await _abrir(tester, tienda: tienda, metricas: metricas);
    await _abrirFicha(tester);
    await _tocar(tester, find.text('Ver catálogo (3)'));

    expect(find.text('Alimento perro adulto 3 kg'), findsOneWidget);
    expect(find.text(r'$ 890'), findsOneWidget);
    expect(find.text('Consultar precio'), findsOneWidget);

    // Dos alimentos y un collar.
    final alimento = find.byKey(const ValueKey('producto-p1'));
    await _tocar(
      tester,
      find.descendant(of: alimento, matching: find.text('Agregar')),
    );
    await _tocar(
      tester,
      find.descendant(of: alimento, matching: find.byTooltip('Sumar uno')),
    );
    await _tocar(
      tester,
      find.descendant(
        of: find.byKey(const ValueKey('producto-p2')),
        matching: find.text('Agregar'),
      ),
    );
    // La cucha no tiene precio: solo se consulta.
    expect(
      find.descendant(
        of: find.byKey(const ValueKey('producto-p3')),
        matching: find.text('Agregar'),
      ),
      findsNothing,
    );
    expect(find.text(r'Ver pedido · 3 · $ 2.030'), findsOneWidget);

    await _tocar(tester, find.byKey(const ValueKey('ver-pedido')));
    expect(find.text('Tu pedido'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Paso a las 18');
    await _tocar(tester, find.text('Hacer pedido'));

    final (negocio, cantidades, nota) = tienda.hechos.single;
    expect((negocio, nota), ('ps', 'Paso a las 18'));
    expect(cantidades, {'p1': 2, 'p2': 1});
    expect(find.text('Mis pedidos'), findsOneWidget);
    expect(find.text('Pedido #1 · Pet Shop Ejemplo'), findsOneWidget);
    expect(find.text('Nuevo'), findsOneWidget);
    expect(find.text(r'$ 2.030'), findsOneWidget);
    expect(
      metricas.map((e) => e['name']),
      containsAll(['catalog_open', 'order_create']),
    );

    await _tocar(tester, find.text('Cancelar pedido'));
    expect(tienda.estados.single, ('o1', EstadoPedido.cancelado));
    expect(find.text('Cancelado'), findsOneWidget);
  });

  testWidgets('"Consultar" sin chat abre WhatsApp del comercio con el '
      'producto', (tester) async {
    final enlaces = <Uri>[];
    await _abrir(
      tester,
      tienda: TiendaFalsa(productos: _productos()),
      enlaces: enlaces,
    );
    await _abrirFicha(tester);
    await _tocar(tester, find.text('Ver catálogo (3)'));
    await _tocar(
      tester,
      find.descendant(
        of: find.byKey(const ValueKey('producto-p3')),
        matching: find.text('Consultar'),
      ),
    );
    expect(enlaces.single.host, 'wa.me');
    expect(enlaces.single.path, '/59899000014');
    expect(enlaces.single.queryParameters['text'], contains('Cucha a medida'));
  });

  testWidgets('un visitante ve el catálogo y, para pedir, ingresa', (
    tester,
  ) async {
    final tienda = TiendaFalsa(productos: _productos());
    await _abrir(tester, tienda: tienda, conectado: false);
    await _abrirFicha(tester);
    await _tocar(tester, find.text('Ver catálogo (3)'));
    await _tocar(
      tester,
      find.descendant(
        of: find.byKey(const ValueKey('producto-p2')),
        matching: find.text('Agregar'),
      ),
    );
    await _tocar(tester, find.byKey(const ValueKey('ver-pedido')));
    expect(find.text('Hacer pedido'), findsNothing);
    await _tocar(tester, find.text('Ingresá para hacer el pedido'));
    expect(tienda.hechos, isEmpty);
    expect(find.text('Ingresar'), findsWidgets);
  });

  testWidgets('modo comercio: prender el catálogo y cargar un producto', (
    tester,
  ) async {
    final tienda = TiendaFalsa();
    final vets = VeterinariasFalsas();
    await _abrir(
      tester,
      tienda: tienda,
      negocios: NegociosFalsos([_miPetshop()]),
      veterinarias: vets,
    );
    await _ir(tester, '/negocio');
    await _tocar(tester, find.text('Catálogo').last);
    expect(
      find.text('Todavía no cargaste productos. Tocá «Agregar producto».'),
      findsOneWidget,
    );

    await _tocar(tester, find.text('Catálogo y pedidos'));
    expect(vets.prendidos, {Modulo.catalogo});

    await _tocar(tester, find.text('Agregar producto'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre'),
      'Piedras sanitarias 4 kg',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Precio'),
      '1.250,50',
    );
    await _tocar(tester, find.text('Guardar'));
    expect(tienda.guardados.single.precio, 1250.5);
    expect(find.text('Piedras sanitarias 4 kg'), findsOneWidget);
    expect(find.text(r'$ 1.250,50'), findsOneWidget);
  });

  testWidgets('modo comercio: el pedido avanza de a un paso', (tester) async {
    final tienda = TiendaFalsa(
      pedidos: [
        Pedido(
          id: 'o9',
          numero: 9,
          estado: EstadoPedido.nuevo,
          total: 890,
          creado: DateTime(2026, 10, 20, 9),
          actualizado: DateTime(2026, 10, 20, 9),
          cliente: 'Beto',
          renglones: const [
            RenglonPedido(nombre: 'Alimento', precio: 890, cantidad: 1),
          ],
        ),
      ],
    );
    await _abrir(
      tester,
      tienda: tienda,
      negocios: NegociosFalsos([_miPetshop()]),
    );
    await _ir(tester, '/negocio');
    await _tocar(tester, find.text('Pedidos').last);
    expect(find.text('Pedido #9 · Beto'), findsOneWidget);
    await _tocar(tester, find.text('Pasar a «Preparando»'));
    await _tocar(tester, find.text('Pasar a «Listo para retirar»'));
    await _tocar(tester, find.text('Pasar a «Entregado»'));
    expect(tienda.estados.map((e) => e.$2), [
      EstadoPedido.preparando,
      EstadoPedido.listo,
      EstadoPedido.entregado,
    ]);
    expect(find.text('Cancelar pedido'), findsNothing);
  });
}
