import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('estados con los valores de la base', () {
    expect(EstadoPedidoChapita.leer('ready'), EstadoPedidoChapita.listo);
    expect(EstadoPedidoChapita.leer('cualquiera'), EstadoPedidoChapita.nuevo);
    expect(EstadoPedidoChapita.enviado.abierto, isTrue);
    expect(EstadoPedidoChapita.entregado.abierto, isFalse);
    expect(EstadoPedidoChapita.cancelado.abierto, isFalse);
  });

  test('texto grabado: limpio, cortado y con el nombre si está vacío', () {
    expect(textoGrabado('  Toby   el  bueno ', 'Toby'), 'Toby el bueno');
    expect(textoGrabado('', 'Luna'), 'Luna');
    expect(textoGrabado(null, 'Luna'), 'Luna');
    expect(textoGrabado('Un nombre larguísimo de verdad', 'X'), hasLength(20));
  });

  test('lee un pedido del dueño y uno de la veterinaria', () {
    final delDueno = PedidoChapita.fromJson({
      'id': 'o1',
      'number': 12,
      'pet_id': 'p1',
      'pet_name': 'Toby',
      'business_id': 'b1',
      'business_name': 'Vet Pando',
      'business_address': 'Calle 1',
      'engraving': 'Toby',
      'status': 'delivered',
      'code': 'K7M2QX9P',
      'created_at': '2026-10-23T10:00:00Z',
      'updated_at': '2026-10-25T10:00:00Z',
    });
    expect(delDueno.numero, 12);
    expect(delDueno.estado, EstadoPedidoChapita.entregado);
    expect(delDueno.codigo, 'K7M2QX9P');
    expect(delDueno.cliente, isNull);

    final deLaVete = PedidoChapita.fromJson({
      'id': 'o2',
      'number': 13,
      'pet_name': 'Luna',
      'cliente': '',
      'engraving': 'Luna',
      'status': 'sent',
      'created_at': '2026-10-23T10:00:00Z',
    });
    expect(deLaVete.cliente, isNull, reason: 'sin nombre visible');
    expect(deLaVete.negocioNombre, isNull);
  });

  test('"mi veterinaria" va primero si es punto de retiro', () {
    const a = PuntoRetiro(id: 'a', nombre: 'A');
    const b = PuntoRetiro(id: 'b', nombre: 'B');
    expect(conMiVeterinariaPrimero([a, b], 'b').map((p) => p.id), ['b', 'a']);
    expect(conMiVeterinariaPrimero([a, b], 'z').map((p) => p.id), ['a', 'b']);
    expect(conMiVeterinariaPrimero([a, b], null).map((p) => p.id), ['a', 'b']);
  });
}
