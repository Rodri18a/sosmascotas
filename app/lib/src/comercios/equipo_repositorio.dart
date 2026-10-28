import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';

/// Por qué no se pudo invitar o sumarse a un equipo.
enum ErrorEquipo { soloPlus, lleno, codigoInvalido, yaSosDuenio, sinConexion }

class EquipoException implements Exception {
  const EquipoException(this.motivo);
  final ErrorEquipo motivo;
}

/// Equipo de la empresa (3.5, D117). Se reemplaza en las pruebas.
abstract interface class EquipoRepositorio {
  Future<EquipoNegocio> equipo(String negocioId);

  /// Solo el dueño. Devuelve el código (8 letras, 7 días, un uso).
  Future<String> invitar(String negocioId);

  /// Devuelve el id del negocio.
  Future<String> unirme(String codigo);

  /// El dueño saca a alguien; cualquiera se saca a sí mismo.
  Future<void> quitar(String negocioId, String userId);

  Future<void> anular(String codigo);
}

class SupabaseEquipo implements EquipoRepositorio {
  SupabaseEquipo(this._cliente);

  final SupabaseClient _cliente;

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on PostgrestException catch (e) {
      throw EquipoException(switch (e.code) {
        '54000' => ErrorEquipo.lleno,
        'P0002' => ErrorEquipo.codigoInvalido,
        '22023' => ErrorEquipo.yaSosDuenio,
        _ => ErrorEquipo.soloPlus,
      });
    } on Exception {
      throw const EquipoException(ErrorEquipo.sinConexion);
    }
  }

  @override
  Future<EquipoNegocio> equipo(String negocioId) async =>
      EquipoNegocio.fromJson(
        (await _cliente.rpc<Map<String, dynamic>>(
          'equipo_del_negocio',
          params: {'p_negocio': negocioId},
        )).cast<String, Object?>(),
      );

  @override
  Future<String> invitar(String negocioId) => _traducir(
    () => _cliente.rpc<String>(
      'invitar_al_equipo',
      params: {'p_negocio': negocioId},
    ),
  );

  @override
  Future<String> unirme(String codigo) => _traducir(
    () =>
        _cliente.rpc<String>('unirme_al_equipo', params: {'p_codigo': codigo}),
  );

  @override
  Future<void> quitar(String negocioId, String userId) => _traducir(
    () => _cliente.rpc<void>(
      'quitar_del_equipo',
      params: {'p_negocio': negocioId, 'p_user': userId},
    ),
  );

  @override
  Future<void> anular(String codigo) => _traducir(
    () => _cliente.rpc<void>(
      'anular_invitacion_equipo',
      params: {'p_codigo': codigo},
    ),
  );
}

class EquipoSinConfigurar implements EquipoRepositorio {
  const EquipoSinConfigurar();

  static const _error = EquipoException(ErrorEquipo.sinConexion);

  @override
  Future<EquipoNegocio> equipo(String negocioId) async =>
      const EquipoNegocio(soyTitular: false);

  @override
  Future<String> invitar(String negocioId) => throw _error;

  @override
  Future<String> unirme(String codigo) => throw _error;

  @override
  Future<void> quitar(String negocioId, String userId) => throw _error;

  @override
  Future<void> anular(String codigo) => throw _error;
}

final equipoRepositorioProvider = Provider<EquipoRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const EquipoSinConfigurar()
      : SupabaseEquipo(cliente);
});

final equipoNegocioProvider = FutureProvider.family<EquipoNegocio, String>(
  (ref, id) => ref.watch(equipoRepositorioProvider).equipo(id),
);
