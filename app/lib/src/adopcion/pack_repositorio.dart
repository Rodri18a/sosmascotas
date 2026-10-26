import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

/// Por qué no se pudo pedir, cargar o canjear un beneficio.
enum ErrorPack {
  sinAdopcion,
  soloVerificados,
  demasiados,
  noDisponible,
  codigoInexistente,
  codigoUsado,
  sinConexion,
}

class PackException implements Exception {
  const PackException(this.motivo);
  final ErrorPack motivo;
}

typedef ListaBeneficios = ({bool puede, List<BeneficioAdopcion> beneficios});

/// Pack adopción (3.4b, D107). Se reemplaza en las pruebas.
abstract interface class PackAdopcionRepositorio {
  /// Los de mi zona; `puede` es falso si no adopté por la app hace poco.
  Future<ListaBeneficios> beneficios();

  /// Devuelve el código para mostrar en el local.
  Future<String> pedir(String beneficioId);

  /// Los del comercio; `puede` es falso si el rubro o la verificación no da.
  Future<ListaBeneficios> delNegocio(String negocioId);

  /// [datos]: id (para editar), title, description, active.
  Future<void> guardar(String negocioId, Map<String, Object?> datos);

  Future<CanjeBeneficio> canjear(String negocioId, String codigo);
}

class SupabasePackAdopcion implements PackAdopcionRepositorio {
  SupabasePackAdopcion(this._cliente);

  final SupabaseClient _cliente;

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on PostgrestException catch (e) {
      throw PackException(switch ((e.code, e.message)) {
        ('54000', _) => ErrorPack.demasiados,
        (_, 'sin_adopcion') => ErrorPack.sinAdopcion,
        (_, 'solo_verificados') => ErrorPack.soloVerificados,
        (_, 'codigo_inexistente') => ErrorPack.codigoInexistente,
        (_, 'codigo_usado') => ErrorPack.codigoUsado,
        _ => ErrorPack.noDisponible,
      });
    } on Exception {
      throw const PackException(ErrorPack.sinConexion);
    }
  }

  ListaBeneficios _lista(Map<String, dynamic> r) => (
    puede: r['puede'] == true,
    beneficios: [
      for (final f in (r['beneficios'] as List?) ?? const [])
        BeneficioAdopcion.fromJson((f as Map).cast<String, Object?>()),
    ],
  );

  @override
  Future<ListaBeneficios> beneficios() async =>
      _lista(await _cliente.rpc<Map<String, dynamic>>('beneficios_adopcion'));

  @override
  Future<String> pedir(String beneficioId) => _traducir(
    () => _cliente.rpc<String>(
      'pedir_beneficio_adopcion',
      params: {'p_perk': beneficioId},
    ),
  );

  @override
  Future<ListaBeneficios> delNegocio(String negocioId) async => _lista(
    await _cliente.rpc<Map<String, dynamic>>(
      'mis_beneficios_adopcion',
      params: {'p_business': negocioId},
    ),
  );

  @override
  Future<void> guardar(String negocioId, Map<String, Object?> datos) =>
      _traducir(
        () => _cliente.rpc<String>(
          'guardar_beneficio_adopcion',
          params: {'p_business': negocioId, 'p': datos},
        ),
      );

  @override
  Future<CanjeBeneficio> canjear(String negocioId, String codigo) =>
      _traducir(() async {
        final r = await _cliente.rpc<Map<String, dynamic>>(
          'canjear_beneficio_adopcion',
          params: {'p_business': negocioId, 'p_code': codigo},
        );
        return (
          titulo: r['title'] as String? ?? '',
          cliente: switch (r['cliente']) {
            final String c when c.isNotEmpty => c,
            _ => null,
          },
          animal: r['animal'] as String?,
        );
      });
}

class PackSinConfigurar implements PackAdopcionRepositorio {
  const PackSinConfigurar();

  static const _error = PackException(ErrorPack.sinConexion);
  static const _vacia = (puede: false, beneficios: <BeneficioAdopcion>[]);

  @override
  Future<ListaBeneficios> beneficios() async => _vacia;

  @override
  Future<String> pedir(String beneficioId) => throw _error;

  @override
  Future<ListaBeneficios> delNegocio(String negocioId) async => _vacia;

  @override
  Future<void> guardar(String negocioId, Map<String, Object?> datos) =>
      throw _error;

  @override
  Future<CanjeBeneficio> canjear(String negocioId, String codigo) =>
      throw _error;
}

final packAdopcionRepositorioProvider = Provider<PackAdopcionRepositorio>((
  ref,
) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const PackSinConfigurar()
      : SupabasePackAdopcion(cliente);
});

final beneficiosAdopcionProvider = FutureProvider<ListaBeneficios>((ref) {
  if (ref.watch(usuarioActualProvider).value == null) {
    return (puede: false, beneficios: const <BeneficioAdopcion>[]);
  }
  return ref.watch(packAdopcionRepositorioProvider).beneficios();
});

final beneficiosNegocioProvider =
    FutureProvider.family<ListaBeneficios, String>(
      (ref, negocioId) =>
          ref.watch(packAdopcionRepositorioProvider).delNegocio(negocioId),
    );
