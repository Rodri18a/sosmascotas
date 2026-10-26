import 'dart:async';
import 'dart:typed_data';

import 'package:sosmascota/src/tienda/tienda_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Catálogo y pedidos en memoria para las pruebas.
class TiendaFalsa implements TiendaRepositorio {
  TiendaFalsa({
    List<Producto>? productos,
    List<Pedido>? pedidos,
    List<Servicio>? servicios,
    this.condiciones,
  }) : productos = [...?productos],
       pedidos = [...?pedidos],
       servicios = [...?servicios];

  final List<Producto> productos;
  final List<Servicio> servicios;
  final serviciosGuardados = <Servicio>[];
  final List<Pedido> pedidos;

  /// Lo que llega en vivo (D100); la clave es el comercio (`null` = los míos).
  final enVivoCanales = <String?, StreamController<void>>{};
  CondicionesPedido? condiciones;
  final hechos = <(String, Map<String, int>, String?)>[];
  final pagosYEntregas = <(FormaPago?, Entrega?)>[];
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
  Future<CondicionesPedido?> condicionesPedido(String negocioId) async =>
      condiciones;

  @override
  Future<void> guardarCondicionesPedido(
    String negocioId,
    CondicionesPedido condiciones,
  ) async => this.condiciones = condiciones;

  @override
  Future<String> hacerPedido(
    String negocioId,
    Carrito carrito, {
    String? nota,
    FormaPago? pago,
    Entrega? entrega,
  }) async {
    hechos.add((negocioId, carrito.cantidades, nota));
    pagosYEntregas.add((pago, entrega));
    final porId = {for (final p in productos) p.id: p};
    final subtotal = carrito.total(productos);
    final envio = condiciones?.costoDe(entrega, subtotal) ?? 0;
    pedidos.insert(
      0,
      Pedido(
        id: 'o${hechos.length}',
        numero: hechos.length,
        estado: EstadoPedido.nuevo,
        total: subtotal + envio,
        creado: DateTime(2026, 10, 20, 10),
        actualizado: DateTime(2026, 10, 20, 10),
        negocio: 'Pet Shop Ejemplo',
        nota: nota,
        formaPago: pago,
        entrega: entrega,
        costoEnvio: envio,
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
  Stream<void> enVivo({String? negocioId}) =>
      (enVivoCanales[negocioId] ??= StreamController<void>.broadcast()).stream;

  /// Simula un cambio que hizo la otra parte.
  void cambioDeAfuera(String? negocioId) => enVivoCanales[negocioId]?.add(null);

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
      formaPago: p.formaPago,
      entrega: p.entrega,
      costoEnvio: p.costoEnvio,
    );
  }

  @override
  Future<List<Servicio>> serviciosDe(String negocioId) async => [
    for (final s in servicios)
      if (s.disponible) s,
  ];

  @override
  Future<List<Servicio>> misServicios(String negocioId) async => servicios;

  @override
  Future<String> guardarServicio(String negocioId, Servicio servicio) async {
    serviciosGuardados.add(servicio);
    final id = servicio.id.isEmpty
        ? 's${serviciosGuardados.length}'
        : servicio.id;
    servicios
      ..removeWhere((s) => s.id == id)
      ..add(
        Servicio(
          id: id,
          nombre: servicio.nombre,
          descripcion: servicio.descripcion,
          precio: servicio.precio,
          desde: servicio.desde,
          duracionMinutos: servicio.duracionMinutos,
          disponible: servicio.disponible,
        ),
      );
    return id;
  }

  @override
  Future<void> borrarServicio(String servicioId) async =>
      servicios.removeWhere((s) => s.id == servicioId);
}
