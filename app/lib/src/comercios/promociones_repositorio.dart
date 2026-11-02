import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../sos/sos_repositorio.dart' show miZonaProvider;

/// Por qué no se pudo guardar una promoción.
enum ErrorPromocion { sinPlan, tope, otro }

class PromocionException implements Exception {
  const PromocionException(this.motivo);

  final ErrorPromocion motivo;

  @override
  String toString() => 'PromocionException($motivo)';
}

/// Promociones de comercios en el muro (tabla `promotions` y sus funciones,
/// D136). Se reemplaza en las pruebas.
abstract interface class PromocionesRepositorio {
  /// Vigentes de comercios Destacado o Plus cerca de [punto] (rotan).
  Future<List<Promocion>> cerca(Punto punto);

  /// Las de mi negocio, vigentes primero.
  Future<List<Promocion>> deMiNegocio(String negocioId);

  Future<String> guardar({
    required String negocioId,
    required String titulo,
    required String texto,
    required int dias,
    String? id,
    String? fotoPath,
  });

  Future<void> terminar(String id);

  Future<void> reportar(String id, String motivo);
}

class SupabasePromocionesRepositorio implements PromocionesRepositorio {
  SupabasePromocionesRepositorio(this._cliente);

  final SupabaseClient _cliente;

  List<Promocion> _lista(Object? filas) => [
    for (final f in (filas as List?) ?? const [])
      Promocion.fromJson((f as Map).cast()),
  ];

  @override
  Future<List<Promocion>> cerca(Punto punto) async => _lista(
    await _cliente.rpc<List<dynamic>>(
      'promociones_cerca',
      params: {'p_lat': punto.lat, 'p_lng': punto.lng},
    ),
  );

  @override
  Future<List<Promocion>> deMiNegocio(String negocioId) async => _lista(
    await _cliente.rpc<List<dynamic>>(
      'mis_promociones',
      params: {'p_negocio': negocioId},
    ),
  );

  @override
  Future<String> guardar({
    required String negocioId,
    required String titulo,
    required String texto,
    required int dias,
    String? id,
    String? fotoPath,
  }) async {
    try {
      return await _cliente.rpc<String>(
        'guardar_promocion',
        params: {
          'p': {
            'id': ?id,
            'business_id': negocioId,
            'title': titulo,
            'body': texto,
            'dias': dias,
            'photo_path': fotoPath,
          },
        },
      );
    } on PostgrestException catch (e) {
      throw PromocionException(switch (e.code) {
        '54000' => ErrorPromocion.tope,
        '42501' when e.message.contains('Destacado') => ErrorPromocion.sinPlan,
        _ => ErrorPromocion.otro,
      });
    }
  }

  @override
  Future<void> terminar(String id) =>
      _cliente.rpc<void>('terminar_promocion', params: {'p_id': id});

  @override
  Future<void> reportar(String id, String motivo) => _cliente
      .from('flags')
      .insert({'target_type': 'promo', 'target_id': id, 'reason': motivo});
}

class PromocionesSinConfigurar implements PromocionesRepositorio {
  const PromocionesSinConfigurar();

  @override
  Future<List<Promocion>> cerca(Punto punto) async => const [];

  @override
  Future<List<Promocion>> deMiNegocio(String negocioId) async => const [];

  @override
  Future<String> guardar({
    required String negocioId,
    required String titulo,
    required String texto,
    required int dias,
    String? id,
    String? fotoPath,
  }) => throw const PromocionException(ErrorPromocion.otro);

  @override
  Future<void> terminar(String id) async {}

  @override
  Future<void> reportar(String id, String motivo) async {}
}

final promocionesRepositorioProvider = Provider<PromocionesRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const PromocionesSinConfigurar()
      : SupabasePromocionesRepositorio(cliente);
});

/// Las del muro, cerca de mi zona. Si falla, el muro sigue sin promociones.
final promocionesCercaProvider = FutureProvider<List<Promocion>>((ref) async {
  try {
    return await ref
        .watch(promocionesRepositorioProvider)
        .cerca(ref.watch(miZonaProvider));
  } on Exception {
    return const [];
  }
});

final misPromocionesProvider = FutureProvider.autoDispose
    .family<List<Promocion>, String>(
      (ref, negocioId) =>
          ref.watch(promocionesRepositorioProvider).deMiNegocio(negocioId),
    );

/// Promociones ya vistas en esta sesión (la métrica se manda una sola vez).
final promocionesVistasProvider = Provider<Set<String>>((ref) => <String>{});
