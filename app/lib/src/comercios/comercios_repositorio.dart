import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';

/// Lugares del mapa (comercios, refugios y lugares que aceptan mascotas). Se
/// reemplaza en las pruebas.
abstract interface class ComerciosRepositorio {
  /// Lugares con local dentro de la zona visible (regla de costo del mapa),
  /// de [categorias] (todas si es `null`).
  Future<List<Comercio>> enZona(Limites zona, {Set<Categoria>? categorias});

  /// "Sin local": tiendas online y servicios a domicilio (1.2.7, D75).
  Future<List<Comercio>> sinLocal({int? zonaId});
}

class SupabaseComerciosRepositorio implements ComerciosRepositorio {
  SupabaseComerciosRepositorio(this._cliente);

  final SupabaseClient _cliente;

  static List<String>? _tipos(Set<Categoria>? categorias) =>
      categorias?.map((c) => c.valor).toList();

  @override
  Future<List<Comercio>> enZona(
    Limites zona, {
    Set<Categoria>? categorias,
  }) async {
    final filas = await _cliente.rpc<List<dynamic>>(
      'lugares_en_zona',
      params: {
        'p_min_lat': zona.minLat,
        'p_min_lng': zona.minLng,
        'p_max_lat': zona.maxLat,
        'p_max_lng': zona.maxLng,
        'p_tipos': _tipos(categorias),
      },
    );
    return filas.cast<Map<String, dynamic>>().map(Comercio.fromJson).toList();
  }

  @override
  Future<List<Comercio>> sinLocal({int? zonaId}) async {
    final filas = await _cliente.rpc<List<dynamic>>(
      'lugares_sin_local',
      params: {'p_zona': zonaId},
    );
    return filas.cast<Map<String, dynamic>>().map(Comercio.fromJson).toList();
  }
}

/// Sin Supabase configurado no hay comercios.
class ComerciosSinConfigurar implements ComerciosRepositorio {
  const ComerciosSinConfigurar();

  @override
  Future<List<Comercio>> enZona(
    Limites zona, {
    Set<Categoria>? categorias,
  }) async => const [];

  @override
  Future<List<Comercio>> sinLocal({int? zonaId}) async => const [];
}

final comerciosRepositorioProvider = Provider<ComerciosRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const ComerciosSinConfigurar()
      : SupabaseComerciosRepositorio(cliente);
});

/// Lugares sin local de la zona de la persona.
final sinLocalProvider = FutureProvider<List<Comercio>>(
  (ref) => ref.watch(comerciosRepositorioProvider).sinLocal(),
);
