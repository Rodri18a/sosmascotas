import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';

/// Por qué no se pudo pasar o recibir una mascota.
enum ErrorTransferencia { sosAbierto, codigoInvalido, otro }

class TransferenciaException implements Exception {
  const TransferenciaException(this.motivo);

  final ErrorTransferencia motivo;

  @override
  String toString() => 'TransferenciaException($motivo)';
}

/// Lo que ve quien recibe el código antes de aceptar (nunca datos del dueño).
typedef VistaTransferencia = ({
  String mascotaId,
  String nombre,
  int especieId,
  String? fotoPath,
});

/// El código abierto de una mascota (para mostrarlo o cancelarlo).
typedef CodigoAbierto = ({String codigo, DateTime vence});

/// Pasar una mascota a otra persona con todo su historial (tabla
/// `pet_transfers` y sus funciones, D132). Se reemplaza en las pruebas.
abstract interface class TransferenciasRepositorio {
  Future<CodigoAbierto?> abierto(String mascotaId);

  /// Genera un código nuevo (el anterior queda cancelado).
  Future<String> crear(String mascotaId);

  Future<void> cancelar(String mascotaId);

  /// `null` si el código no existe, venció, ya se usó o es mío.
  Future<VistaTransferencia?> ver(String codigo);

  /// Acepta y devuelve el id de la mascota, que ya es mía.
  Future<String> aceptar(String codigo);
}

class SupabaseTransferenciasRepositorio implements TransferenciasRepositorio {
  SupabaseTransferenciasRepositorio(this._cliente);

  final SupabaseClient _cliente;

  Future<T> _rpc<T>(String funcion, Map<String, Object?> parametros) async {
    try {
      return await _cliente.rpc<T>(funcion, params: parametros);
    } on PostgrestException catch (e) {
      throw TransferenciaException(switch (e.message) {
        final m when m.contains('SOS') => ErrorTransferencia.sosAbierto,
        final m when m.contains('código') || m.contains('Ya es tu') =>
          ErrorTransferencia.codigoInvalido,
        _ => ErrorTransferencia.otro,
      });
    }
  }

  @override
  Future<CodigoAbierto?> abierto(String mascotaId) async {
    final fila = await _cliente
        .from('pet_transfers')
        .select('code, expires_at')
        .eq('pet_id', mascotaId)
        .isFilter('accepted_at', null)
        .isFilter('cancelled_at', null)
        .gt('expires_at', DateTime.now().toUtc().toIso8601String())
        .maybeSingle();
    if (fila == null) return null;
    return (
      codigo: fila['code']! as String,
      vence: DateTime.parse(fila['expires_at']! as String).toLocal(),
    );
  }

  @override
  Future<String> crear(String mascotaId) =>
      _rpc<String>('crear_transferencia', {'p_pet': mascotaId});

  @override
  Future<void> cancelar(String mascotaId) =>
      _rpc<void>('cancelar_transferencia', {'p_pet': mascotaId});

  @override
  Future<VistaTransferencia?> ver(String codigo) async {
    final json = await _rpc<Map<String, dynamic>?>('ver_transferencia', {
      'p_code': codigo,
    });
    if (json == null) return null;
    return (
      mascotaId: json['pet_id'] as String,
      nombre: json['name'] as String,
      especieId: (json['species_id'] as num).toInt(),
      fotoPath: json['photo_path'] as String?,
    );
  }

  @override
  Future<String> aceptar(String codigo) =>
      _rpc<String>('aceptar_transferencia', {'p_code': codigo});
}

class TransferenciasSinConfigurar implements TransferenciasRepositorio {
  const TransferenciasSinConfigurar();

  @override
  Future<CodigoAbierto?> abierto(String mascotaId) async => null;

  @override
  Future<String> crear(String mascotaId) async => 'SINCONFIGU';

  @override
  Future<void> cancelar(String mascotaId) async {}

  @override
  Future<VistaTransferencia?> ver(String codigo) async => null;

  @override
  Future<String> aceptar(String codigo) async =>
      throw const TransferenciaException(ErrorTransferencia.codigoInvalido);
}

final transferenciasRepositorioProvider = Provider<TransferenciasRepositorio>((
  ref,
) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const TransferenciasSinConfigurar()
      : SupabaseTransferenciasRepositorio(cliente);
});

final codigoAbiertoProvider = FutureProvider.autoDispose
    .family<CodigoAbierto?, String>(
      (ref, mascotaId) =>
          ref.watch(transferenciasRepositorioProvider).abierto(mascotaId),
    );
