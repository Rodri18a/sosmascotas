import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/comercios/mis_lugares.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'mascotas_falsas.dart';
import 'pedidos_chapita_falsos.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');
const _luna = Mascota(id: 'm1', nombre: 'Luna', especieId: 2);
const _lejos = PuntoRetiro(id: 'v1', nombre: 'Vete Lejos', direccion: 'Ruta 8');
const _mia = PuntoRetiro(id: 'v2', nombre: 'Vete Pando', direccion: 'Calle 1');

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  // La lista dibuja solo lo cercano: si todavía no está, bajar hasta verlo.
  if (objetivo.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      objetivo,
      200,
      scrollable: find
          .byWidgetPredicate(
            (w) => w is Scrollable && w.axisDirection == AxisDirection.down,
          )
          .first,
    );
  }
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

/// La pantalla del QR es una lista: lo de abajo se arma al bajar.
Future<void> _bajarHasta(WidgetTester tester, Finder objetivo) async {
  await tester.scrollUntilVisible(
    objetivo,
    200,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _abrirQrDeLuna(
  WidgetTester tester, {
  required PedidosChapitaFalsos pedidos,
  bool prendida = true,
  List<Map<String, Object?>>? eventos,
}) async {
  _pantallaDeCelular(tester);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      mascotas: MascotasFalsas([_luna]),
      pedidosChapita: pedidos,
      // Vete Pando es "mi veterinaria": va primera aunque esté más lejos.
      misLugares: MisLugaresFalsos({
        'v2': const LugarMio(comercioId: 'v2', miVeterinaria: true),
      }),
      funcionalidades: FuncionalidadesFalsas({
        if (prendida) Funcionalidades.pedidoChapitas,
      }),
      eventos: eventos,
    ),
  );
  await tester.pumpAndSettle();
  await _tocar(
    tester,
    find.descendant(
      of: find.byType(BarraInferior),
      matching: find.text('Mascotas'),
    ),
  );
  await _tocar(tester, find.widgetWithText(ListTile, 'Luna'));
  await _tocar(tester, find.text('Chapita QR'));
}

MiNegocio _vete({String verificacion = 'verified'}) => MiNegocio.fromJson({
  'id': 'v2',
  'name': 'Vete Pando',
  'business_type': 'vet',
  'kind': 'local',
  'lat': -34.71,
  'lng': -55.95,
  'hours': const <String, Object?>{},
  'verification': verificacion,
  'plan': 'basic',
  'status': 'active',
});

PedidoChapita _pedido(EstadoPedidoChapita estado) => PedidoChapita(
  id: 'o1',
  numero: 7,
  nombreMascota: 'Toby',
  cliente: 'Ana',
  grabado: 'Toby',
  estado: estado,
  codigo: 'K7M2QX9P',
  creado: DateTime(2026, 10, 23),
);

Future<void> _abrirRetiro(
  WidgetTester tester, {
  required PedidosChapitaFalsos pedidos,
  required MiNegocio negocio,
  List<Map<String, Object?>>? eventos,
}) async {
  _pantallaDeCelular(tester);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      negocios: NegociosFalsos([negocio]),
      pedidosChapita: pedidos,
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.comercios,
        Funcionalidades.pedidoChapitas,
      }),
      eventos: eventos,
    ),
  );
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/negocio');
  await tester.pumpAndSettle();
  await _tocar(tester, find.text('Chapitas: punto de retiro'));
}

void main() {
  testWidgets('apagada: no se ofrece pedir una chapita', (tester) async {
    await _abrirQrDeLuna(
      tester,
      pedidos: PedidosChapitaFalsos(puntos: [_lejos]),
      prendida: false,
    );
    await _bajarHasta(tester, find.text('Activar una chapita'));
    expect(find.text('Pedir una chapita'), findsNothing);
  });

  testWidgets('el dueño pide la chapita con su veterinaria primero y la '
      'cancela', (tester) async {
    final pedidos = PedidosChapitaFalsos(puntos: [_lejos, _mia])
      ..nombres['m1'] = 'Luna';
    final eventos = <Map<String, Object?>>[];
    await _abrirQrDeLuna(tester, pedidos: pedidos, eventos: eventos);

    await _bajarHasta(tester, find.text('Pedir una chapita'));
    await _tocar(tester, find.text('Pedir una chapita'));
    expect(find.widgetWithText(AppBar, 'Pedir una chapita'), findsOneWidget);
    expect(find.text('Sin cargo durante el lanzamiento.'), findsOneWidget);
    // El texto grabado arranca con el nombre.
    expect(find.widgetWithText(TextField, 'Luna'), findsOneWidget);
    // "Mi veterinaria" primero.
    final titulos = tester
        .widgetList<RadioListTile<String>>(find.byType(RadioListTile<String>))
        .map((r) => r.value)
        .toList();
    expect(titulos, ['v2', 'v1']);
    expect(find.textContaining('Tu veterinaria'), findsOneWidget);

    // Sin elegir dónde, no se puede pedir.
    final boton = find.widgetWithText(FilledButton, 'Pedirla');
    expect(tester.widget<FilledButton>(boton).onPressed, isNull);

    await tester.enterText(find.byType(TextField), '  Lunita  ');
    await _tocar(tester, find.text('Vete Pando'));
    await _tocar(tester, boton);

    final hecho = pedidos.pedidos.single;
    expect(hecho.negocioId, 'v2');
    expect(hecho.grabado, 'Lunita');
    expect(eventos.where((e) => e['name'] == 'tag_order_create'), hasLength(1));

    // De vuelta en la Chapita QR, el pedido en curso.
    await _bajarHasta(tester, find.text('Pedido N.º 101 · Lunita'));
    expect(find.text('Pedido N.º 101 · Lunita'), findsOneWidget);
    expect(find.text('Pedida: la estamos preparando.'), findsOneWidget);
    expect(find.text('Pedir una chapita'), findsNothing);

    await _tocar(tester, find.widgetWithText(TextButton, 'Cancelar'));
    expect(pedidos.pedidos.single.estado, EstadoPedidoChapita.cancelado);
    expect(find.text('Pedir una chapita'), findsOneWidget);
  });

  testWidgets('lista para retirar: dice dónde y con qué número', (
    tester,
  ) async {
    final pedidos = PedidosChapitaFalsos(
      pedidos: [
        PedidoChapita(
          id: 'o1',
          numero: 42,
          mascotaId: 'm1',
          nombreMascota: 'Luna',
          negocioNombre: 'Vete Pando',
          grabado: 'Luna',
          estado: EstadoPedidoChapita.listo,
          creado: DateTime(2026, 10, 23),
        ),
      ],
    );
    await _abrirQrDeLuna(tester, pedidos: pedidos);
    await _bajarHasta(tester, find.text('Pedido N.º 42 · Luna'));
    expect(
      find.text('¡Lista para retirar en Vete Pando! Decí el pedido N.º 42.'),
      findsOneWidget,
    );
    // Ya no se puede cancelar.
    expect(find.widgetWithText(TextButton, 'Cancelar'), findsNothing);
  });

  testWidgets('la veterinaria se hace punto de retiro, recibe y entrega', (
    tester,
  ) async {
    final pedidos = PedidosChapitaFalsos(
      pedidos: [_pedido(EstadoPedidoChapita.enviado)],
    );
    final eventos = <Map<String, Object?>>[];
    await _abrirRetiro(
      tester,
      pedidos: pedidos,
      negocio: _vete(),
      eventos: eventos,
    );

    await _tocar(tester, find.byType(SwitchListTile));
    expect(pedidos.puntoRetiro, isTrue);

    // Ve el primer nombre, la mascota, el grabado y el código; nada de contacto.
    expect(find.text('Pedido N.º 7 · Toby'), findsOneWidget);
    expect(find.textContaining('Para Ana'), findsOneWidget);
    expect(find.textContaining('Código K7M2QX9P'), findsOneWidget);

    await _tocar(tester, find.text('Llegó'));
    expect(pedidos.pedidos.single.estado, EstadoPedidoChapita.listo);

    await _tocar(tester, find.widgetWithText(FilledButton, 'Entregada'));
    expect(find.text('¿La entregaste?'), findsOneWidget);
    await _tocar(
      tester,
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Entregada'),
      ),
    );
    expect(pedidos.pedidos.single.estado, EstadoPedidoChapita.entregado);
    expect(find.textContaining('Entregada.'), findsOneWidget);
    expect(
      [
        for (final e in eventos)
          if (e['name'] == 'tag_order_status') e['props'],
      ],
      [
        {'estado': 'ready'},
        {'estado': 'delivered'},
      ],
    );
  });

  testWidgets('la veterinaria entrega un pedido nuevo con una de su stock', (
    tester,
  ) async {
    final pedidos = PedidosChapitaFalsos(
      pedidos: [_pedido(EstadoPedidoChapita.nuevo)],
      stock: ['STK12345', 'STK67890'],
      puntoRetiro: true,
    );
    final eventos = <Map<String, Object?>>[];
    await _abrirRetiro(
      tester,
      pedidos: pedidos,
      negocio: _vete(),
      eventos: eventos,
    );
    expect(
      find.text('Tu stock: 2 chapitas sin usar · 0 activadas'),
      findsOneWidget,
    );

    await _tocar(tester, find.text('Entregar el N.º 7 de mi stock'));
    final campo = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(campo, 'ZZZ99999');
    await _tocar(tester, find.widgetWithText(FilledButton, 'Entregada'));
    expect(
      find.text('Ese código no está entre las chapitas sin usar de tu stock.'),
      findsOneWidget,
    );
    expect(pedidos.pedidos.single.estado, EstadoPedidoChapita.nuevo);

    await tester.pumpAndSettle(const Duration(seconds: 5));
    await _tocar(tester, find.text('Entregar el N.º 7 de mi stock'));
    await tester.enterText(campo, 'stk12345');
    await _tocar(tester, find.widgetWithText(FilledButton, 'Entregada'));
    expect(pedidos.pedidos.single.estado, EstadoPedidoChapita.entregado);
    expect(
      find.text('Tu stock: 1 chapita sin usar · 1 activada'),
      findsOneWidget,
    );
    expect(
      [
        for (final e in eventos)
          if (e['name'] == 'tag_stock_deliver') e['name'],
      ],
      ['tag_stock_deliver'],
    );
  });

  testWidgets('sin verificar no puede ser punto de retiro', (tester) async {
    await _abrirRetiro(
      tester,
      pedidos: PedidosChapitaFalsos(puedeSer: false),
      negocio: _vete(verificacion: 'unverified'),
    );
    expect(find.text('Solo para veterinarias verificadas.'), findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged,
      isNull,
    );
  });
}
