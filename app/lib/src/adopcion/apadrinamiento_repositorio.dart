import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';

/// Por qué no se pudo ofrecer o cambiar un apadrinamiento.
enum ErrorApadrinamiento {
  soloVerificados,
  noDisponible,
  yaHayUno,
  limite,
  noSePuede,
  sinConexion,
}

class ApadrinamientoException implements Exception {
  const ApadrinamientoException(this.motivo);
  final ErrorApadrinamiento motivo;
}

/// Apadrinamiento de refugios y ferias (3.4b, D108). Se reemplaza en las
/// pruebas.
abstract interface class ApadrinamientoRepositorio {
  Future<DatosApadrinamiento> delNegocio(String negocioId);

  Future<void> ofrecer({
    required String negocioId,
    required String refugioId,
    required String aporte,
    String? eventoId,
  });

  Future<void> responder(String id, {required bool aceptar});

  Future<void> terminar(String id);

  /// Los padrinos activos de un refugio (sin [eventoId]) o de un evento.
  Future<List<Padrino>> padrinos({String? negocioId, String? eventoId});
}

class SupabaseApadrinamiento implements ApadrinamientoRepositorio {
  SupabaseApadrinamiento(this._cliente);

  final SupabaseClient _cliente;

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on PostgrestException catch (e) {
      throw ApadrinamientoException(switch ((e.code, e.message)) {
        ('23505', _) => ErrorApadrinamiento.yaHayUno,
        ('54000', _) => ErrorApadrinamiento.limite,
        (_, 'solo_comercios_verificados') =>
          ErrorApadrinamiento.soloVerificados,
        (_, 'refugio_no_disponible' || 'evento_no_disponible') =>
          ErrorApadrinamiento.noDisponible,
        _ => ErrorApadrinamiento.noSePuede,
      });
    } on Exception {
      throw const ApadrinamientoException(ErrorApadrinamiento.sinConexion);
    }
  }

  @override
  Future<DatosApadrinamiento> delNegocio(String negocioId) async =>
      DatosApadrinamiento.fromJson(
        (await _cliente.rpc<Map<String, dynamic>>(
          'apadrinamientos_del_negocio',
          params: {'p_business': negocioId},
        )).cast<String, Object?>(),
      );

  @override
  Future<void> ofrecer({
    required String negocioId,
    required String refugioId,
    required String aporte,
    String? eventoId,
  }) => _traducir(
    () => _cliente.rpc<String>(
      'ofrecer_apadrinamiento',
      params: {
        'p_business': negocioId,
        'p_refugio': refugioId,
        'p_aporte': aporte,
        'p_evento': eventoId,
      },
    ),
  );

  @override
  Future<void> responder(String id, {required bool aceptar}) => _traducir(
    () => _cliente.rpc<void>(
      'responder_apadrinamiento',
      params: {'p_id': id, 'p_aceptar': aceptar},
    ),
  );

  @override
  Future<void> terminar(String id) => _traducir(
    () => _cliente.rpc<void>('terminar_apadrinamiento', params: {'p_id': id}),
  );

  @override
  Future<List<Padrino>> padrinos({String? negocioId, String? eventoId}) async =>
      [
        for (final f in await _cliente.rpc<List<dynamic>>(
          'padrinos',
          params: {'p_business': negocioId, 'p_evento': eventoId},
        ))
          Padrino.fromJson((f as Map).cast<String, Object?>()),
      ];
}

class ApadrinamientoSinConfigurar implements ApadrinamientoRepositorio {
  const ApadrinamientoSinConfigurar();

  static const _error = ApadrinamientoException(
    ErrorApadrinamiento.sinConexion,
  );

  @override
  Future<DatosApadrinamiento> delNegocio(String negocioId) async =>
      const DatosApadrinamiento();

  @override
  Future<void> ofrecer({
    required String negocioId,
    required String refugioId,
    required String aporte,
    String? eventoId,
  }) => throw _error;

  @override
  Future<void> responder(String id, {required bool aceptar}) => throw _error;

  @override
  Future<void> terminar(String id) => throw _error;

  @override
  Future<List<Padrino>> padrinos({String? negocioId, String? eventoId}) async =>
      const [];
}

final apadrinamientoRepositorioProvider = Provider<ApadrinamientoRepositorio>((
  ref,
) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const ApadrinamientoSinConfigurar()
      : SupabaseApadrinamiento(cliente);
});

final apadrinamientoNegocioProvider =
    FutureProvider.family<DatosApadrinamiento, String>(
      (ref, negocioId) =>
          ref.watch(apadrinamientoRepositorioProvider).delNegocio(negocioId),
    );

/// Clave: (id del refugio, id del evento); uno de los dos.
final padrinosProvider =
    FutureProvider.family<List<Padrino>, (String?, String?)>(
      (ref, clave) => ref
          .watch(apadrinamientoRepositorioProvider)
          .padrinos(negocioId: clave.$1, eventoId: clave.$2),
    );
