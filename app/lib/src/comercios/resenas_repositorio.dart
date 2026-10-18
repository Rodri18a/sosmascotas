import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

/// Reseñas de comercios (1.7, D78). Se reemplaza en las pruebas.
abstract interface class ResenasRepositorio {
  Future<List<Resena>> deComercio(String comercioId);

  /// ¿Tuve un contacto real con el comercio (y no es mío)?
  Future<bool> puedoResenar(String comercioId);

  /// Escribir o editar la mía.
  Future<void> guardar(String comercioId, int estrellas, String? comentario);

  /// El comercio responde una sola vez.
  Future<void> responder(String resenaId, String respuesta);

  Future<void> reportar(String resenaId, String motivo);
}

class SupabaseResenasRepositorio implements ResenasRepositorio {
  SupabaseResenasRepositorio(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<List<Resena>> deComercio(String comercioId) async {
    final filas = await _cliente.rpc<List<dynamic>>(
      'resenas_de',
      params: {'p_business': comercioId},
    );
    return [
      for (final f in filas)
        Resena.fromJson((f as Map).cast<String, Object?>()),
    ];
  }

  @override
  Future<bool> puedoResenar(String comercioId) async =>
      (await _cliente.rpc<bool?>(
        'puedo_resenar',
        params: {'p_business': comercioId},
      )) ??
      false;

  @override
  Future<void> guardar(String comercioId, int estrellas, String? comentario) =>
      _cliente.rpc<String>(
        'guardar_resena',
        params: {
          'p_business': comercioId,
          'p_estrellas': estrellas,
          'p_comentario': comentario,
        },
      );

  @override
  Future<void> responder(String resenaId, String respuesta) =>
      _cliente.rpc<void>(
        'responder_resena',
        params: {'p_review': resenaId, 'p_respuesta': respuesta},
      );

  @override
  Future<void> reportar(String resenaId, String motivo) =>
      _cliente.from('flags').insert({
        'target_type': 'review',
        'target_id': resenaId,
        'reason': motivo,
      });
}

class ResenasSinConfigurar implements ResenasRepositorio {
  const ResenasSinConfigurar();

  @override
  Future<List<Resena>> deComercio(String comercioId) async => const [];

  @override
  Future<bool> puedoResenar(String comercioId) async => false;

  @override
  Future<void> guardar(
    String comercioId,
    int estrellas,
    String? comentario,
  ) async {}

  @override
  Future<void> responder(String resenaId, String respuesta) async {}

  @override
  Future<void> reportar(String resenaId, String motivo) async {}
}

final resenasRepositorioProvider = Provider<ResenasRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const ResenasSinConfigurar()
      : SupabaseResenasRepositorio(cliente);
});

final resenasProvider = FutureProvider.family<List<Resena>, String>(
  (ref, id) => ref.watch(resenasRepositorioProvider).deComercio(id),
);

final puedoResenarProvider = FutureProvider.family<bool, String>((ref, id) {
  if (ref.watch(usuarioActualProvider).value == null) return false;
  return ref.watch(resenasRepositorioProvider).puedoResenar(id);
});
