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

  /// Formas de pago y entrega (2.10c, D92); `null` si no las configuró.
  Future<CondicionesPedido?> condicionesPedido(String negocioId);

  Future<void> guardarCondicionesPedido(
    String negocioId,
    CondicionesPedido condiciones,
  );

  /// Los precios, el envío y el total los pone la base.
  Future<String> hacerPedido(
    String negocioId,
    Carrito carrito, {
    String? nota,
    FormaPago? pago,
    Entrega? entrega,
  });

  Future<List<Pedido>> misPedidos();

  Future<List<Pedido>> pedidosDelNegocio(String negocioId);

  Future<void> cambiarEstado(String pedidoId, EstadoPedido estado);

  /// Servicios (2.10a, D90): lo disponible, si el comercio tiene plan Plus
  /// (también visitantes).
  Future<List<Servicio>> serviciosDe(String negocioId);

  /// El dueño: todos, también los no disponibles.
  Future<List<Servicio>> misServicios(String negocioId);

  Future<String> guardarServicio(String negocioId, Servicio servicio);

  Future<void> borrarServicio(String servicioId);
}

class SupabaseTiendaRepositorio implements TiendaRepositorio {
  SupabaseTiendaRepositorio(this._cliente);

  final SupabaseClient _cliente;

  List<Producto> _productos(List<dynamic> filas) => [
    for (final f in filas)
      Producto.fromJson((f as Map).cast<String, Object?>()),
  ];

  List<Servicio> _servicios(List<dynamic> filas) => [
    for (final f in filas)
      Servicio.fromJson((f as Map).cast<String, Object?>()),
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
  Future<CondicionesPedido?> condicionesPedido(String negocioId) async {
    final json = await _cliente.rpc<Object?>(
      'condiciones_pedido',
      params: {'p_negocio': negocioId},
    );
    return json is Map
        ? CondicionesPedido.fromJson(json.cast<String, Object?>())
        : null;
  }

  @override
  Future<void> guardarCondicionesPedido(
    String negocioId,
    CondicionesPedido condiciones,
  ) => _traducir(
    () => _cliente.rpc<void>(
      'guardar_condiciones_pedido',
      params: {'p_negocio': negocioId, 'p': condiciones.toJson()},
    ),
  );

  @override
  Future<String> hacerPedido(
    String negocioId,
    Carrito carrito, {
    String? nota,
    FormaPago? pago,
    Entrega? entrega,
  }) => _traducir(
    () => _cliente.rpc<String>(
      'hacer_pedido',
      params: {
        'p_negocio': negocioId,
        'p_items': carrito.paraPedir(),
        'p_nota': nota,
        'p_pago': pago?.base,
        'p_entrega': entrega?.base,
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

  @override
  Future<List<Servicio>> serviciosDe(String negocioId) async => _servicios(
    await _cliente.rpc<List<dynamic>>(
      'servicios_de',
      params: {'p_negocio': negocioId},
    ),
  );

  @override
  Future<List<Servicio>> misServicios(String negocioId) async => _servicios(
    await _cliente.rpc<List<dynamic>>(
      'mis_servicios',
      params: {'p_negocio': negocioId},
    ),
  );

  @override
  Future<String> guardarServicio(String negocioId, Servicio servicio) =>
      _traducir(
        () => _cliente.rpc<String>(
          'guardar_servicio',
          params: {'p_negocio': negocioId, 'p': servicio.toJson()},
        ),
      );

  @override
  Future<void> borrarServicio(String servicioId) => _traducir(
    () => _cliente.rpc<void>('borrar_servicio', params: {'p_id': servicioId}),
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
  Future<CondicionesPedido?> condicionesPedido(String negocioId) async => null;

  @override
  Future<void> guardarCondicionesPedido(
    String negocioId,
    CondicionesPedido condiciones,
  ) async {}

  @override
  Future<String> hacerPedido(
    String negocioId,
    Carrito carrito, {
    String? nota,
    FormaPago? pago,
    Entrega? entrega,
  }) async => '';

  @override
  Future<List<Pedido>> misPedidos() async => const [];

  @override
  Future<List<Pedido>> pedidosDelNegocio(String negocioId) async => const [];

  @override
  Future<void> cambiarEstado(String pedidoId, EstadoPedido estado) async {}

  @override
  Future<List<Servicio>> serviciosDe(String negocioId) async => const [];

  @override
  Future<List<Servicio>> misServicios(String negocioId) async => const [];

  @override
  Future<String> guardarServicio(String negocioId, Servicio servicio) async =>
      '';

  @override
  Future<void> borrarServicio(String servicioId) async {}
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

final serviciosDeProvider = FutureProvider.family<List<Servicio>, String>(
  (ref, negocioId) =>
      ref.watch(tiendaRepositorioProvider).serviciosDe(negocioId),
);

final misServiciosProvider = FutureProvider.family<List<Servicio>, String>(
  (ref, negocioId) =>
      ref.watch(tiendaRepositorioProvider).misServicios(negocioId),
);

final condicionesPedidoProvider =
    FutureProvider.family<CondicionesPedido?, String>(
      (ref, negocioId) =>
          ref.watch(tiendaRepositorioProvider).condicionesPedido(negocioId),
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
