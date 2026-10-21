import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

const _alimento = Producto(id: 'p1', nombre: 'Alimento', precio: 890);
const _collar = Producto(id: 'p2', nombre: 'Collar', precio: 250.5);
const _cucha = Producto(id: 'p3', nombre: 'Cucha a medida');

void main() {
  test('precio en pesos uruguayos', () {
    expect(formatoPrecio(890), r'$ 890');
    expect(formatoPrecio(1780), r'$ 1.780');
    expect(formatoPrecio(1234567.5), r'$ 1.234.567,50');
    expect(formatoPrecio(0), r'$ 0');
  });

  test('el producto se lee de la base (precio como texto o número)', () {
    final p = Producto.fromJson({
      'id': 'p1',
      'name': 'Alimento',
      'price': '890.00',
      'species_ids': [1],
    });
    expect(p.precio, 890);
    expect(p.soloConsultar, isFalse);
    expect(
      Producto.fromJson({'id': 'p3', 'name': 'Cucha'}).soloConsultar,
      isTrue,
    );
  });

  test('carrito: sumar, restar, total y lo que se manda', () {
    var c = const Carrito().sumar(_alimento).sumar(_alimento).sumar(_collar);
    expect(c.cantidad('p1'), 2);
    expect(c.unidades, 3);
    expect(c.total([_alimento, _collar]), 2030.5);
    c = c.restar('p2');
    expect(c.cantidad('p2'), 0);
    expect(c.paraPedir(), [
      {'id': 'p1', 'qty': 2},
    ]);
  });

  test('carrito: lo que solo se consulta o no está disponible no entra', () {
    const agotado = Producto(
      id: 'p4',
      nombre: 'X',
      precio: 1,
      disponible: false,
    );
    expect(const Carrito().sumar(_cucha).vacio, isTrue);
    expect(const Carrito().sumar(agotado).vacio, isTrue);
  });

  test('carrito: hasta 99 por producto', () {
    var c = const Carrito();
    for (var i = 0; i < 120; i++) {
      c = c.sumar(_alimento);
    }
    expect(c.cantidad('p1'), 99);
  });

  test('estados del pedido: un paso por vez', () {
    expect(EstadoPedido.nuevo.siguiente, EstadoPedido.preparando);
    expect(EstadoPedido.listo.siguiente, EstadoPedido.entregado);
    expect(EstadoPedido.entregado.siguiente, isNull);
    expect(EstadoPedido.cancelado.abierto, isFalse);
    expect(EstadoPedido.desdeBase('ready'), EstadoPedido.listo);
  });

  test('el pedido se lee de la base con sus renglones', () {
    final p = Pedido.fromJson({
      'id': 'o1',
      'number': 7,
      'status': 'preparing',
      'total': '1780.00',
      'created_at': '2026-10-20T12:00:00Z',
      'business_name': 'Pet Shop',
      'items': [
        {'name': 'Alimento', 'unit_price': 890, 'qty': 2},
      ],
    });
    expect(p.numero, 7);
    expect(p.estado, EstadoPedido.preparando);
    expect(p.total, 1780);
    expect(p.renglones.single.subtotal, 1780);
    expect(p.negocio, 'Pet Shop');
  });

  test('leerPrecio entiende puntos de miles y coma decimal', () {
    expect(leerPrecio('1.780,50'), 1780.5);
    expect(leerPrecio(r'$ 150'), 150);
    expect(leerPrecio('89.5'), 89.5);
    expect(leerPrecio('3.000'), 3000);
    expect(leerPrecio('1.250.000'), 1250000);
    expect(leerPrecio('12.50'), 12.5);
    expect(leerPrecio('  '), isNull);
    expect(leerPrecio('abc'), isNull);
  });

  test('condiciones del pedido: costo del envío y gratis desde', () {
    final c = CondicionesPedido.fromJson({
      'payment_methods': ['mercadopago', 'cash', 'otra'],
      'pickup': true,
      'shipping': true,
      'shipping_cost': '150.00',
      'free_shipping_from': 3000,
    });
    expect(c.formasPago, [FormaPago.efectivo, FormaPago.mercadoPago]);
    expect(c.entregas, [Entrega.retiro, Entrega.envio]);
    expect(c.costoDe(Entrega.retiro, 1000), 0);
    expect(c.costoDe(Entrega.envio, 1000), 150);
    expect(c.costoDe(Entrega.envio, 3000), 0);
    expect(c.costoDe(null, 1000), 0);
    expect(const CondicionesPedido(envio: true).costoDe(Entrega.envio, 10), 0);
  });

  test('condiciones del pedido: sin envío no se mandan costos', () {
    const c = CondicionesPedido(
      formasPago: [FormaPago.transferencia],
      costoEnvio: 150,
      envioGratisDesde: 3000,
    );
    expect(c.toJson(), {
      'payment_methods': ['transfer'],
      'pickup': true,
      'shipping': false,
      'shipping_cost': null,
      'free_shipping_from': null,
    });
    const gratis = CondicionesPedido(envio: true, envioGratisDesde: 3000);
    expect(gratis.toJson()['free_shipping_from'], isNull);
  });

  test('el pedido trae el pago, la entrega y el envío', () {
    final p = Pedido.fromJson({
      'id': 'o2',
      'number': 8,
      'status': 'new',
      'total': 2380,
      'created_at': '2026-10-21T12:00:00Z',
      'payment_method': 'transfer',
      'delivery': 'shipping',
      'shipping_cost': '150.00',
    });
    expect(p.formaPago, FormaPago.transferencia);
    expect(p.entrega, Entrega.envio);
    expect(p.costoEnvio, 150);
    expect(p.subtotal, 2230);
    final viejo = Pedido.fromJson({
      'id': 'o1',
      'number': 1,
      'status': 'new',
      'total': 890,
      'created_at': '2026-10-20T12:00:00Z',
    });
    expect((viejo.formaPago, viejo.entrega, viejo.costoEnvio), (null, null, 0));
  });
}
