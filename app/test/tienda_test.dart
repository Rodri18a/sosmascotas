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
  testWidgets('el catálogo se ve sin la funcionalidad gradual (D93)', (
    tester,
  ) async {
    await _abrir(
      tester,
      tienda: TiendaFalsa(productos: _productos()),
      conFuncionalidad: false,
    );
    await _abrirFicha(tester);
    await _tocar(tester, find.text('Ver catálogo (3)'));
    expect(find.text('Alimento perro adulto 3 kg'), findsOneWidget);
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
    await _tocar(tester, find.text('Enviar pedido por WhatsApp'));
    expect(find.text('¡Pedido #1 guardado!'), findsOneWidget);
    await _tocar(tester, find.text('Ahora no'));

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

  testWidgets('elige pago y envío, y manda el pedido por WhatsApp', (
    tester,
  ) async {
    final tienda = TiendaFalsa(
      productos: _productos(),
      condiciones: const CondicionesPedido(
        formasPago: [FormaPago.efectivo, FormaPago.transferencia],
        envio: true,
        costoEnvio: 150,
        envioGratisDesde: 3000,
      ),
    );
    final enlaces = <Uri>[];
    final metricas = <Map<String, Object?>>[];
    await _abrir(tester, tienda: tienda, enlaces: enlaces, metricas: metricas);
    await _abrirFicha(tester);
    await _tocar(tester, find.text('Ver catálogo (3)'));
    final alimento = find.byKey(const ValueKey('producto-p1'));
    await _tocar(
      tester,
      find.descendant(of: alimento, matching: find.text('Agregar')),
    );
    await _tocar(
      tester,
      find.descendant(of: alimento, matching: find.byTooltip('Sumar uno')),
    );
    await _tocar(tester, find.byKey(const ValueKey('ver-pedido')));

    // Sin elegir, no se puede mandar.
    expect(find.text('Elegí la forma de pago y la entrega.'), findsOneWidget);
    final boton = find.byKey(const ValueKey('hacer-pedido'));
    expect(tester.widget<ButtonStyleButton>(boton).onPressed, isNull);

    await _tocar(tester, find.byKey(const ValueKey('pago-transfer')));
    await _tocar(tester, find.byKey(const ValueKey('entrega-shipping')));
    expect(find.text(r'Envío gratis desde $ 3.000'), findsOneWidget);
    expect(find.text(r'$ 1.780'), findsNWidgets(2));
    expect(find.text(r'$ 150'), findsOneWidget);
    expect(find.text(r'$ 1.930'), findsOneWidget);

    await _tocar(tester, boton);
    expect(tienda.pagosYEntregas.single, (
      FormaPago.transferencia,
      Entrega.envio,
    ));
    await _tocar(tester, find.byKey(const ValueKey('abrir-whatsapp')));
    expect(enlaces.single.host, 'wa.me');
    expect(enlaces.single.path, '/59899000014');
    expect(
      enlaces.single.queryParameters['text'],
      'Hola, te hago un pedido desde SOS Mascota (#1):\n'
      '• 2 × Alimento perro adulto 3 kg — \$ 1.780\n'
      'Subtotal: \$ 1.780 · Envío: \$ 150 · Total: \$ 1.930\n'
      'Pago: Transferencia\n'
      'Entrega: Envío a domicilio\n'
      'Te paso la dirección por acá.',
    );
    expect(find.text('Mis pedidos'), findsOneWidget);
    expect(
      find.text('Pago: Transferencia · Entrega: Envío a domicilio'),
      findsOneWidget,
    );
    expect(
      metricas.map((e) => e['name']),
      containsAll(['order_create', 'order_whatsapp']),
    );
  });

  testWidgets('con una sola opción ya queda elegida y el envío llega gratis '
      'desde el monto', (tester) async {
    final tienda = TiendaFalsa(
      productos: const [
        Producto(id: 'p1', nombre: 'Bolsa 15 kg', precio: 3200),
      ],
      condiciones: const CondicionesPedido(
        formasPago: [FormaPago.efectivo],
        retiro: false,
        envio: true,
        costoEnvio: 150,
        envioGratisDesde: 3000,
      ),
    );
    await _abrir(tester, tienda: tienda);
    await _abrirFicha(tester);
    await _tocar(tester, find.text('Ver catálogo (1)'));
    await _tocar(tester, find.text('Agregar'));
    await _tocar(tester, find.byKey(const ValueKey('ver-pedido')));
    expect(find.text('Gratis'), findsOneWidget);
    await _tocar(tester, find.byKey(const ValueKey('hacer-pedido')));
    expect(tienda.pagosYEntregas.single, (FormaPago.efectivo, Entrega.envio));
    expect(tienda.pedidos.single.total, 3200);
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

  testWidgets('un visitante ve el catálogo y, para armar un pedido, ingresa', (
    tester,
  ) async {
    final tienda = TiendaFalsa(productos: _productos());
    await _abrir(
      tester,
      tienda: tienda,
      conectado: false,
      conFuncionalidad: false,
    );
    await _abrirFicha(tester);
    await _tocar(tester, find.text('Ver catálogo (3)'));
    await _tocar(
      tester,
      find.descendant(
        of: find.byKey(const ValueKey('producto-p2')),
        matching: find.text('Agregar'),
      ),
    );
    expect(find.text('Necesitás una cuenta'), findsOneWidget);
    expect(find.textContaining('Para armar un pedido'), findsOneWidget);
    await _tocar(tester, find.text('Ahora no'));
    // No se sumó nada al carrito.
    expect(find.byKey(const ValueKey('ver-pedido')), findsNothing);

    await _tocar(
      tester,
      find.descendant(
        of: find.byKey(const ValueKey('producto-p2')),
        matching: find.text('Agregar'),
      ),
    );
    await _tocar(tester, find.text('Ingresar o crear cuenta'));
    expect(tienda.hechos, isEmpty);
    expect(find.text('Ingresar'), findsWidgets);
  });

  testWidgets('un visitante, para consultar, ingresa (no se abre WhatsApp)', (
    tester,
  ) async {
    final enlaces = <Uri>[];
    final metricas = <Map<String, Object?>>[];
    await _abrir(
      tester,
      tienda: TiendaFalsa(productos: _productos()),
      conectado: false,
      enlaces: enlaces,
      metricas: metricas,
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
    expect(find.textContaining('Para consultarle al comercio'), findsOneWidget);
    await _tocar(tester, find.text('Ahora no'));
    expect(enlaces, isEmpty);
    expect(metricas.map((e) => e['name']), isNot(contains('catalog_ask')));
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

  testWidgets('modo comercio: cómo cobra y entrega', (tester) async {
    final tienda = TiendaFalsa();
    final metricas = <Map<String, Object?>>[];
    await _abrir(
      tester,
      tienda: tienda,
      negocios: NegociosFalsos([_miPetshop()]),
      metricas: metricas,
    );
    await _ir(tester, '/negocio');
    await _tocar(tester, find.text('Catálogo').last);
    expect(
      find.text(
        'Sin configurar: quien pide arregla el pago y la entrega con vos.',
      ),
      findsOneWidget,
    );
    await _tocar(tester, find.byKey(const ValueKey('condiciones-pedido')));
    await _tocar(tester, find.byKey(const ValueKey('acepta-cash')));
    await _tocar(tester, find.byKey(const ValueKey('acepta-mercadopago')));
    await _tocar(tester, find.text('Hacés envíos'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Costo del envío'),
      '150',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Envío gratis desde (opcional)'),
      '3.000',
    );
    await _tocar(tester, find.text('Guardar'));
    final c = tienda.condiciones!;
    expect(c.formasPago, [FormaPago.efectivo, FormaPago.mercadoPago]);
    expect(
      (c.retiro, c.envio, c.costoEnvio, c.envioGratisDesde),
      (true, true, 150, 3000),
    );
    expect(
      find.text(r'Efectivo, Mercado Pago · Retiro en el local · Envío $ 150'),
      findsOneWidget,
    );
    expect(metricas.map((e) => e['name']), contains('order_settings_save'));

    // Sin retiro ni envío no se guarda.
    await _tocar(tester, find.byKey(const ValueKey('condiciones-pedido')));
    await _tocar(tester, find.text('Retiro en el local'));
    await _tocar(tester, find.text('Hacés envíos'));
    await _tocar(tester, find.text('Guardar'));
    expect(find.text('Elegí al menos retiro o envío.'), findsOneWidget);
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

  Pedido pedido(String id, int numero, EstadoPedido estado) => Pedido(
    id: id,
    numero: numero,
    estado: estado,
    total: 890,
    creado: DateTime(2026, 10, 26, 9),
    actualizado: DateTime(2026, 10, 26, 9),
    cliente: 'Beto',
    negocio: 'Pet Shop Ejemplo',
    renglones: const [
      RenglonPedido(nombre: 'Alimento', precio: 890, cantidad: 1),
    ],
  );

  testWidgets('"Mis pedidos" muestra el estado en vivo (D100)', (tester) async {
    final tienda = TiendaFalsa(pedidos: [pedido('o1', 1, EstadoPedido.nuevo)]);
    await _abrir(tester, tienda: tienda);
    await _ir(tester, '/pedidos');
    expect(find.text('Nuevo'), findsOneWidget);
    // El comercio lo pasa a "Listo" desde su celular.
    tienda.pedidos[0] = pedido('o1', 1, EstadoPedido.listo);
    tienda.cambioDeAfuera(null);
    await tester.pumpAndSettle();
    expect(find.text('Nuevo'), findsNothing);
    expect(find.text('Listo para retirar'), findsOneWidget);
  });

  testWidgets('la push de un pedido abre Pedidos y los nuevos aparecen solos '
      '(D100)', (tester) async {
    final tienda = TiendaFalsa();
    await _abrir(
      tester,
      tienda: tienda,
      negocios: NegociosFalsos([_miPetshop()]),
    );
    await _ir(tester, '/negocio?seccion=pedidos');
    expect(find.text('Pedido #4 · Beto'), findsNothing);
    tienda.pedidos.add(pedido('o4', 4, EstadoPedido.nuevo));
    tienda.cambioDeAfuera('ps');
    await tester.pumpAndSettle();
    expect(find.text('Pedido #4 · Beto'), findsOneWidget);
  });
}
