import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../sos/sos_repositorio.dart';

/// Pedidos de chapitas con retiro en la veterinaria (1.8b.4, D98): el dueño
/// los hace y la veterinaria los recibe y entrega. Se reemplaza en las
/// pruebas.
abstract interface class PedidosChapitaRepositorio {
  /// Veterinarias verificadas que son punto de retiro, cerca de [desde].
  Future<List<PuntoRetiro>> puntosDeRetiro(Punto desde);

  Future<void> pedir(String mascotaId, String negocioId, String grabado);

  Future<List<PedidoChapita>> misPedidos();

  /// Solo mientras nadie lo preparó.
  Future<void> cancelar(String pedidoId);

  /// Si el negocio es punto de retiro, si puede serlo y sus pedidos.
  Future<PedidosDelNegocio> delNegocio(String negocioId);

  Future<void> prenderPuntoRetiro(String negocioId, {required bool prender});

  /// "Llegó" o "Entregada": devuelve el estado nuevo.
  Future<EstadoPedidoChapita> avanzar(String pedidoId);

  /// Entrega un pedido nuevo con una chapita del stock de la veterinaria
  /// (2.9, D105): queda vinculada a la mascota en ese momento.
  Future<void> entregarDeStock(String pedidoId, String codigo);
}

/// Lo del negocio: si es punto de retiro, sus pedidos y su stock de
/// chapitas en blanco (disponibles y activadas).
typedef PedidosDelNegocio = ({
  bool puntoRetiro,
  bool puedeSer,
  List<PedidoChapita> pedidos,
  int stockDisponibles,
  int stockActivadas,
});

/// Por qué no se pudo pedir o cambiar un pedido.
enum ErrorPedidoChapita {
  yaHayUno,
  demasiados,
  noEsPunto,
  soloVerificadas,
  noEstaEnStock,
  noSePuede,
  sinConexion,
}

class PedidoChapitaException implements Exception {
  const PedidoChapitaException(this.motivo);
  final ErrorPedidoChapita motivo;
}

class SupabasePedidosChapita implements PedidosChapitaRepositorio {
  SupabasePedidosChapita(this._cliente);

  final SupabaseClient _cliente;

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on PostgrestException catch (e) {
      throw PedidoChapitaException(switch ((e.code, e.message)) {
        ('23505', _) => ErrorPedidoChapita.yaHayUno,
        ('54000', _) => ErrorPedidoChapita.demasiados,
        (_, 'no_es_punto_de_retiro') => ErrorPedidoChapita.noEsPunto,
        (_, 'solo_verificadas') => ErrorPedidoChapita.soloVerificadas,
        (_, 'no_esta_en_tu_stock') => ErrorPedidoChapita.noEstaEnStock,
        _ => ErrorPedidoChapita.noSePuede,
      });
    } on Exception {
      throw const PedidoChapitaException(ErrorPedidoChapita.sinConexion);
    }
  }

  List<PedidoChapita> _pedidos(Object? filas) => ((filas as List?) ?? const [])
      .cast<Map<String, dynamic>>()
      .map(PedidoChapita.fromJson)
      .toList();

  @override
  Future<List<PuntoRetiro>> puntosDeRetiro(Punto desde) async {
    final filas = await _cliente.rpc<List<dynamic>>(
      'puntos_de_retiro',
      params: {'p_lat': desde.lat, 'p_lng': desde.lng},
    );
    return filas
        .cast<Map<String, dynamic>>()
        .map(PuntoRetiro.fromJson)
        .toList();
  }

  @override
  Future<void> pedir(String mascotaId, String negocioId, String grabado) =>
      _traducir(
        () => _cliente.rpc<String>(
          'pedir_chapita',
          params: {
            'p_pet': mascotaId,
            'p_business': negocioId,
            'p_texto': grabado,
          },
        ),
      );

  @override
  Future<List<PedidoChapita>> misPedidos() async =>
      _pedidos(await _cliente.rpc<List<dynamic>>('mis_pedidos_chapita'));

  @override
  Future<void> cancelar(String pedidoId) => _traducir(
    () => _cliente.rpc<void>(
      'cancelar_pedido_chapita',
      params: {'p_id': pedidoId},
    ),
  );

  @override
  Future<PedidosDelNegocio> delNegocio(String negocioId) async {
    final r = await _cliente.rpc<Map<String, dynamic>>(
      'pedidos_chapita_del_negocio',
      params: {'p_business': negocioId},
    );
    final stock = (r['stock'] as Map?) ?? const {};
    return (
      puntoRetiro: r['punto_retiro'] == true,
      puedeSer: r['puede_ser'] == true,
      pedidos: _pedidos(r['pedidos']),
      stockDisponibles: (stock['disponibles'] as num?)?.toInt() ?? 0,
      stockActivadas: (stock['activadas'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  Future<void> prenderPuntoRetiro(String negocioId, {required bool prender}) =>
      _traducir(
        () => _cliente.rpc<void>(
          'prender_punto_retiro',
          params: {'p_business': negocioId, 'p_prender': prender},
        ),
      );

  @override
  Future<EstadoPedidoChapita> avanzar(String pedidoId) => _traducir(
    () async => EstadoPedidoChapita.leer(
      await _cliente.rpc<String>(
        'negocio_avanzar_pedido_chapita',
        params: {'p_id': pedidoId},
      ),
    ),
  );

  @override
  Future<void> entregarDeStock(String pedidoId, String codigo) => _traducir(
    () => _cliente.rpc<void>(
      'negocio_entregar_de_stock',
      params: {'p_id': pedidoId, 'p_code': codigo},
    ),
  );
}

/// Sin Supabase configurado no hay pedidos.
class PedidosChapitaSinConfigurar implements PedidosChapitaRepositorio {
  const PedidosChapitaSinConfigurar();

  static const _error = PedidoChapitaException(ErrorPedidoChapita.sinConexion);

  @override
  Future<List<PuntoRetiro>> puntosDeRetiro(Punto desde) async => const [];

  @override
  Future<void> pedir(String mascotaId, String negocioId, String grabado) =>
      throw _error;

  @override
  Future<List<PedidoChapita>> misPedidos() async => const [];

  @override
  Future<void> cancelar(String pedidoId) => throw _error;

  @override
  Future<PedidosDelNegocio> delNegocio(String negocioId) async => (
    puntoRetiro: false,
    puedeSer: false,
    pedidos: const <PedidoChapita>[],
    stockDisponibles: 0,
    stockActivadas: 0,
  );

  @override
  Future<void> prenderPuntoRetiro(String negocioId, {required bool prender}) =>
      throw _error;

  @override
  Future<EstadoPedidoChapita> avanzar(String pedidoId) => throw _error;

  @override
  Future<void> entregarDeStock(String pedidoId, String codigo) => throw _error;
}

final pedidosChapitaRepositorioProvider = Provider<PedidosChapitaRepositorio>((
  ref,
) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const PedidosChapitaSinConfigurar()
      : SupabasePedidosChapita(cliente);
});

final misPedidosChapitaProvider = FutureProvider<List<PedidoChapita>>(
  (ref) => ref.watch(pedidosChapitaRepositorioProvider).misPedidos(),
);

final puntosDeRetiroProvider = FutureProvider<List<PuntoRetiro>>(
  (ref) => ref
      .watch(pedidosChapitaRepositorioProvider)
      .puntosDeRetiro(ref.watch(miZonaProvider)),
);

final pedidosChapitaNegocioProvider =
    FutureProvider.family<PedidosDelNegocio, String>(
      (ref, negocioId) =>
          ref.watch(pedidosChapitaRepositorioProvider).delNegocio(negocioId),
    );
