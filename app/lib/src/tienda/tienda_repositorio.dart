import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

enum ErrorTienda { soloPlus, sinModulo, noSePuede, limite, otro }

class TiendaException implements Exception {
  const TiendaException(this.motivo);

  final ErrorTienda motivo;

  @override
  String toString() => 'TiendaException($motivo)';
}

/// Catálogo de los comercios y pedidos (2.5 y 3.2, D85). Se reemplaza en las
/// pruebas.
abstract interface class TiendaRepositorio {
  /// Lo disponible, si el comercio tiene el catálogo prendido (también
  /// visitantes).
  Future<List<Producto>> catalogoDe(String negocioId);

  /// El dueño: todo, también lo no disponible.
  Future<List<Producto>> miCatalogo(String negocioId);

  Future<String> guardarProducto(String negocioId, Producto producto);

  Future<void> borrarProducto(String productoId);

  /// Foto ya preparada (sin EXIF); devuelve la ruta para el producto.
  Future<String> subirFoto(String negocioId, Uint8List jpeg);

  String? urlFoto(String? ruta);

  /// Los precios y el total los pone la base.
  Future<String> hacerPedido(String negocioId, Carrito carrito, {String? nota});

  Future<List<Pedido>> misPedidos();

  Future<List<Pedido>> pedidosDelNegocio(String negocioId);

  Future<void> cambiarEstado(String pedidoId, EstadoPedido estado);
}

class SupabaseTiendaRepositorio implements TiendaRepositorio {
  SupabaseTiendaRepositorio(this._cliente);

  final SupabaseClient _cliente;

  List<Producto> _productos(List<dynamic> filas) => [
    for (final f in filas)
      Producto.fromJson((f as Map).cast<String, Object?>()),
  ];

  List<Pedido> _pedidos(List<dynamic> filas) => [
    for (final f in filas) Pedido.fromJson((f as Map).cast<String, Object?>()),
  ];

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on PostgrestException catch (e) {
      throw TiendaException(switch (e.code) {
        '54000' => ErrorTienda.limite,
        '22023' => ErrorTienda.noSePuede,
        '42501' when e.message.contains('Plus') => ErrorTienda.soloPlus,
        '42501' when e.message.contains('pedidos') => ErrorTienda.sinModulo,
        _ => ErrorTienda.otro,
      });
    }
  }

  @override
  Future<List<Producto>> catalogoDe(String negocioId) async => _productos(
    await _cliente.rpc<List<dynamic>>(
      'catalogo_de',
      params: {'p_negocio': negocioId},
    ),
  );

  @override
  Future<List<Producto>> miCatalogo(String negocioId) async => _productos(
    await _cliente.rpc<List<dynamic>>(
      'mi_catalogo',
      params: {'p_negocio': negocioId},
    ),
  );

  @override
  Future<String> guardarProducto(String negocioId, Producto producto) =>
      _traducir(
        () => _cliente.rpc<String>(
          'guardar_producto',
          params: {'p_negocio': negocioId, 'p': producto.toJson()},
        ),
      );

  @override
  Future<void> borrarProducto(String productoId) => _traducir(
    () => _cliente.rpc<void>('borrar_producto', params: {'p_id': productoId}),
  );

  @override
  Future<String> subirFoto(String negocioId, Uint8List jpeg) async {
    final ruta = '$negocioId/catalogo/${generarAnonId()}.jpg';
    await _cliente.storage
        .from('business-photos')
        .uploadBinary(
          ruta,
          jpeg,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return ruta;
  }

  @override
  String? urlFoto(String? ruta) => ruta == null
      ? null
      : _cliente.storage.from('business-photos').getPublicUrl(ruta);

  @override
  Future<String> hacerPedido(
    String negocioId,
    Carrito carrito, {
    String? nota,
  }) => _traducir(
    () => _cliente.rpc<String>(
      'hacer_pedido',
      params: {
        'p_negocio': negocioId,
        'p_items': carrito.paraPedir(),
        'p_nota': nota,
      },
    ),
  );

  @override
  Future<List<Pedido>> misPedidos() async =>
      _pedidos(await _cliente.rpc<List<dynamic>>('mis_pedidos'));

  @override
  Future<List<Pedido>> pedidosDelNegocio(String negocioId) async => _pedidos(
    await _cliente.rpc<List<dynamic>>(
      'pedidos_del_negocio',
      params: {'p_negocio': negocioId},
    ),
  );

  @override
  Future<void> cambiarEstado(String pedidoId, EstadoPedido estado) => _traducir(
    () => _cliente.rpc<void>(
      'cambiar_estado_pedido',
      params: {'p_id': pedidoId, 'p_estado': estado.base},
    ),
  );
}

class TiendaSinConfigurar implements TiendaRepositorio {
  const TiendaSinConfigurar();

  @override
  Future<List<Producto>> catalogoDe(String negocioId) async => const [];

  @override
  Future<List<Producto>> miCatalogo(String negocioId) async => const [];

  @override
  Future<String> guardarProducto(String negocioId, Producto producto) async =>
      '';

  @override
  Future<void> borrarProducto(String productoId) async {}

  @override
  Future<String> subirFoto(String negocioId, Uint8List jpeg) =>
      throw StateError('Supabase no está configurado');

  @override
  String? urlFoto(String? ruta) => null;

  @override
  Future<String> hacerPedido(
    String negocioId,
    Carrito carrito, {
    String? nota,
  }) async => '';

  @override
  Future<List<Pedido>> misPedidos() async => const [];

  @override
  Future<List<Pedido>> pedidosDelNegocio(String negocioId) async => const [];

  @override
  Future<void> cambiarEstado(String pedidoId, EstadoPedido estado) async {}
}

final tiendaRepositorioProvider = Provider<TiendaRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const TiendaSinConfigurar()
      : SupabaseTiendaRepositorio(cliente);
});

final catalogoDeProvider = FutureProvider.family<List<Producto>, String>(
  (ref, negocioId) =>
      ref.watch(tiendaRepositorioProvider).catalogoDe(negocioId),
);

final miCatalogoProvider = FutureProvider.family<List<Producto>, String>(
  (ref, negocioId) =>
      ref.watch(tiendaRepositorioProvider).miCatalogo(negocioId),
);

final misPedidosProvider = FutureProvider<List<Pedido>>((ref) {
  if (ref.watch(usuarioActualProvider).value == null) return const [];
  return ref.watch(tiendaRepositorioProvider).misPedidos();
});

final pedidosDelNegocioProvider = FutureProvider.family<List<Pedido>, String>(
  (ref, negocioId) =>
      ref.watch(tiendaRepositorioProvider).pedidosDelNegocio(negocioId),
);

/// Carrito de cada comercio, mientras dura la sesión de la app.
final carritoProvider =
    NotifierProvider.family<CarritoNotifier, Carrito, String>(
      CarritoNotifier.new,
    );

class CarritoNotifier extends Notifier<Carrito> {
  CarritoNotifier(this.negocioId);

  final String negocioId;

  @override
  Carrito build() => const Carrito();

  void sumar(Producto p) => state = state.sumar(p);

  void restar(String productoId) => state = state.restar(productoId);

  void vaciar() => state = const Carrito();
}
