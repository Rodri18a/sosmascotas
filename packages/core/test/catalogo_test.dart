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
}
