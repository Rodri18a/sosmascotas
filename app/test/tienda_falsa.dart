import 'dart:typed_data';

import 'package:sosmascota/src/tienda/tienda_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Catálogo y pedidos en memoria para las pruebas.
class TiendaFalsa implements TiendaRepositorio {
  TiendaFalsa({List<Producto>? productos, List<Pedido>? pedidos})
    : productos = [...?productos],
      pedidos = [...?pedidos];

  final List<Producto> productos;
  final List<Pedido> pedidos;
  final hechos = <(String, Map<String, int>, String?)>[];
  final estados = <(String, EstadoPedido)>[];
  final guardados = <Producto>[];

  @override
  Future<List<Producto>> catalogoDe(String negocioId) async => [
    for (final p in productos)
      if (p.disponible) p,
  ];

  @override
  Future<List<Producto>> miCatalogo(String negocioId) async => productos;

  @override
  Future<String> guardarProducto(String negocioId, Producto producto) async {
    guardados.add(producto);
    final id = producto.id.isEmpty ? 'nuevo${guardados.length}' : producto.id;
    productos
      ..removeWhere((p) => p.id == id)
      ..add(
        Producto(
          id: id,
          nombre: producto.nombre,
          descripcion: producto.descripcion,
          precio: producto.precio,
          disponible: producto.disponible,
        ),
      );
    return id;
  }

  @override
  Future<void> borrarProducto(String productoId) async =>
      productos.removeWhere((p) => p.id == productoId);

  @override
  Future<String> subirFoto(String negocioId, Uint8List jpeg) async =>
      '$negocioId/catalogo/foto.jpg';

  @override
  String? urlFoto(String? ruta) => null;

  @override
  Future<String> hacerPedido(
    String negocioId,
    Carrito carrito, {
    String? nota,
  }) async {
    hechos.add((negocioId, carrito.cantidades, nota));
    final porId = {for (final p in productos) p.id: p};
    pedidos.insert(
      0,
      Pedido(
        id: 'o${hechos.length}',
        numero: hechos.length,
        estado: EstadoPedido.nuevo,
        total: carrito.total(productos),
        creado: DateTime(2026, 10, 20, 10),
        actualizado: DateTime(2026, 10, 20, 10),
        negocio: 'Pet Shop Ejemplo',
        nota: nota,
        renglones: [
          for (final e in carrito.cantidades.entries)
            RenglonPedido(
              nombre: porId[e.key]!.nombre,
              precio: porId[e.key]!.precio!,
              cantidad: e.value,
            ),
        ],
      ),
    );
    return 'o${hechos.length}';
  }

  @override
  Future<List<Pedido>> misPedidos() async => pedidos;

  @override
  Future<List<Pedido>> pedidosDelNegocio(String negocioId) async => pedidos;

  @override
  Future<void> cambiarEstado(String pedidoId, EstadoPedido estado) async {
    estados.add((pedidoId, estado));
    final i = pedidos.indexWhere((p) => p.id == pedidoId);
    final p = pedidos[i];
    pedidos[i] = Pedido(
      id: p.id,
      numero: p.numero,
      estado: estado,
      total: p.total,
      creado: p.creado,
      actualizado: p.actualizado,
      renglones: p.renglones,
      cliente: p.cliente,
      negocio: p.negocio,
    );
  }
}
