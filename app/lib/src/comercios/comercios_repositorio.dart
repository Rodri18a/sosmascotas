import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';

/// Comercios del mapa (en la Fase 0, veterinarias de urgencia cargadas a
/// mano). Se reemplaza en las pruebas.
abstract interface class ComerciosRepositorio {
  /// Comercios activos dentro de la zona visible (regla de costo del mapa).
  Future<List<Comercio>> enZona(Limites zona, {String tipo = 'vet'});
}

class SupabaseComerciosRepositorio implements ComerciosRepositorio {
  SupabaseComerciosRepositorio(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<List<Comercio>> enZona(Limites zona, {String tipo = 'vet'}) async {
    final filas = await _cliente.rpc<List<dynamic>>(
      'comercios_en_zona',
      params: {
        'p_min_lat': zona.minLat,
        'p_min_lng': zona.minLng,
        'p_max_lat': zona.maxLat,
        'p_max_lng': zona.maxLng,
        'p_tipo': tipo,
      },
    );
    return filas.cast<Map<String, dynamic>>().map(Comercio.fromJson).toList();
  }
}

/// Sin Supabase configurado no hay comercios.
class ComerciosSinConfigurar implements ComerciosRepositorio {
  const ComerciosSinConfigurar();

  @override
  Future<List<Comercio>> enZona(Limites zona, {String tipo = 'vet'}) async =>
      const [];
}

final comerciosRepositorioProvider = Provider<ComerciosRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const ComerciosSinConfigurar()
      : SupabaseComerciosRepositorio(cliente);
});
