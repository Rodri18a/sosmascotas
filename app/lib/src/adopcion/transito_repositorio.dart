import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

/// Por qué no se pudo pedir o responder un tránsito.
enum ErrorTransito {
  soloRefugios,
  noDisponible,
  noRecibe,
  masDias,
  yaHayUno,
  limite,
  noSePuede,
  sinConexion,
}

class TransitoException implements Exception {
  const TransitoException(this.motivo);
  final ErrorTransito motivo;
}

/// Hogares de tránsito (3.4b, D106): el hogar se anota y responde; el
/// refugio verificado busca y pide. Se reemplaza en las pruebas.
abstract interface class TransitoRepositorio {
  /// Null si todavía no me anoté.
  Future<HogarTransito?> miHogar();

  Future<void> guardarHogar(HogarTransito hogar);

  /// Me borra de la lista (y los pedidos que me llegaron).
  Future<void> borrarHogar();

  Future<List<PedidoTransito>> misPedidos();

  /// Aceptar devuelve el id del chat con el refugio; rechazar, null.
  Future<String?> responder(String pedidoId, {required bool aceptar});

  Future<List<HogarDisponible>> hogares(String refugioId, {int? especieId});

  Future<void> pedir({
    required String refugioId,
    required String hogarId,
    required int dias,
    required String nombre,
    required int especieId,
    String? tamano,
    String? mensaje,
  });

  Future<List<PedidoTransito>> pedidosDelRefugio(String refugioId);

  /// Cancela un pedido sin responder o da por terminado el tránsito.
  Future<EstadoTransito> cerrar(String pedidoId);
}

class SupabaseTransito implements TransitoRepositorio {
  SupabaseTransito(this._cliente);

  final SupabaseClient _cliente;

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on PostgrestException catch (e) {
      throw TransitoException(switch ((e.code, e.message)) {
        ('23505', _) => ErrorTransito.yaHayUno,
        ('54000', _) => ErrorTransito.limite,
        (_, 'solo_refugios_verificados') => ErrorTransito.soloRefugios,
        (_, 'hogar_no_disponible') => ErrorTransito.noDisponible,
        (_, 'no_recibe_ese_animal') => ErrorTransito.noRecibe,
        (_, 'mas_dias_que_el_maximo') => ErrorTransito.masDias,
        _ => ErrorTransito.noSePuede,
      });
    } on Exception {
      throw const TransitoException(ErrorTransito.sinConexion);
    }
  }

  List<Map<String, Object?>> _filas(Object? datos) => [
    for (final f in (datos as List?) ?? const [])
      (f as Map).cast<String, Object?>(),
  ];

  @override
  Future<HogarTransito?> miHogar() async {
    final fila = await _cliente.from('foster_homes').select().maybeSingle();
    return fila == null ? null : HogarTransito.fromJson(fila);
  }

  @override
  Future<void> guardarHogar(HogarTransito hogar) => _traducir(
    () => _cliente.from('foster_homes').upsert({
      ...hogar.toJson(),
      'user_id': _cliente.auth.currentUser?.id,
    }),
  );

  @override
  Future<void> borrarHogar() => _traducir(
    () => _cliente
        .from('foster_homes')
        .delete()
        .eq('user_id', _cliente.auth.currentUser?.id ?? ''),
  );

  @override
  Future<List<PedidoTransito>> misPedidos() async => _filas(
    await _cliente.rpc<List<dynamic>>('mis_pedidos_transito'),
  ).map(PedidoTransito.fromJson).toList();

  @override
  Future<String?> responder(String pedidoId, {required bool aceptar}) =>
      _traducir(
        () => _cliente.rpc<String?>(
          'responder_transito',
          params: {'p_id': pedidoId, 'p_aceptar': aceptar},
        ),
      );

  @override
  Future<List<HogarDisponible>> hogares(String refugioId, {int? especieId}) =>
      _traducir(
        () async => _filas(
          await _cliente.rpc<List<dynamic>>(
            'hogares_de_transito',
            params: {'p_business': refugioId, 'p_especie': especieId},
          ),
        ).map(HogarDisponible.fromJson).toList(),
      );

  @override
  Future<void> pedir({
    required String refugioId,
    required String hogarId,
    required int dias,
    required String nombre,
    required int especieId,
    String? tamano,
    String? mensaje,
  }) => _traducir(
    () => _cliente.rpc<String>(
      'pedir_transito',
      params: {
        'p_business': refugioId,
        'p_hogar': hogarId,
        'p_dias': dias,
        'p_nombre': nombre,
        'p_especie': especieId,
        'p_tamano': tamano,
        'p_mensaje': mensaje,
      },
    ),
  );

  @override
  Future<List<PedidoTransito>> pedidosDelRefugio(String refugioId) => _traducir(
    () async => _filas(
      await _cliente.rpc<List<dynamic>>(
        'pedidos_transito_del_refugio',
        params: {'p_business': refugioId},
      ),
    ).map(PedidoTransito.fromJson).toList(),
  );

  @override
  Future<EstadoTransito> cerrar(String pedidoId) => _traducir(
    () async => EstadoTransito.leer(
      await _cliente.rpc<String>('cerrar_transito', params: {'p_id': pedidoId}),
    ),
  );
}

/// Sin Supabase configurado no hay hogares.
class TransitoSinConfigurar implements TransitoRepositorio {
  const TransitoSinConfigurar();

  static const _error = TransitoException(ErrorTransito.sinConexion);

  @override
  Future<HogarTransito?> miHogar() async => null;

  @override
  Future<void> guardarHogar(HogarTransito hogar) => throw _error;

  @override
  Future<void> borrarHogar() => throw _error;

  @override
  Future<List<PedidoTransito>> misPedidos() async => const [];

  @override
  Future<String?> responder(String pedidoId, {required bool aceptar}) =>
      throw _error;

  @override
  Future<List<HogarDisponible>> hogares(
    String refugioId, {
    int? especieId,
  }) async => const [];

  @override
  Future<void> pedir({
    required String refugioId,
    required String hogarId,
    required int dias,
    required String nombre,
    required int especieId,
    String? tamano,
    String? mensaje,
  }) => throw _error;

  @override
  Future<List<PedidoTransito>> pedidosDelRefugio(String refugioId) async =>
      const [];

  @override
  Future<EstadoTransito> cerrar(String pedidoId) => throw _error;
}

final transitoRepositorioProvider = Provider<TransitoRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const TransitoSinConfigurar()
      : SupabaseTransito(cliente);
});

final miHogarTransitoProvider = FutureProvider<HogarTransito?>((ref) {
  if (ref.watch(usuarioActualProvider).value == null) return null;
  return ref.watch(transitoRepositorioProvider).miHogar();
});

final misPedidosTransitoProvider = FutureProvider<List<PedidoTransito>>((ref) {
  if (ref.watch(usuarioActualProvider).value == null) return const [];
  return ref.watch(transitoRepositorioProvider).misPedidos();
});

final hogaresTransitoProvider =
    FutureProvider.family<List<HogarDisponible>, String>(
      (ref, refugioId) =>
          ref.watch(transitoRepositorioProvider).hogares(refugioId),
    );

final pedidosTransitoRefugioProvider =
    FutureProvider.family<List<PedidoTransito>, String>(
      (ref, refugioId) =>
          ref.watch(transitoRepositorioProvider).pedidosDelRefugio(refugioId),
    );
