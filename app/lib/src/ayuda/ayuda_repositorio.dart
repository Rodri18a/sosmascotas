import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../comercios/comercios_repositorio.dart';
import '../config/supabase_providers.dart';
import '../sos/sos_repositorio.dart';

/// Directorio de la pestaña Ayuda. Se reemplaza en las pruebas.
abstract interface class AyudaRepositorio {
  /// Entradas activas, ordenadas por tipo y por orden de carga.
  Future<List<EntradaAyuda>> directorio();
}

class SupabaseAyudaRepositorio implements AyudaRepositorio {
  SupabaseAyudaRepositorio(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<List<EntradaAyuda>> directorio() async {
    // La política de la tabla ya filtra los activos.
    final filas = await _cliente
        .from('help_directory')
        .select('id, kind, name, description, phone, whatsapp, link, is_sample')
        // Ojo: en supabase_flutter `order` es descendente si no se aclara.
        .order('sort', ascending: true)
        .order('name', ascending: true);
    return [for (final f in filas) ?EntradaAyuda.fromJson(f)];
  }
}

/// Sin Supabase configurado el directorio está vacío.
class AyudaSinConfigurar implements AyudaRepositorio {
  const AyudaSinConfigurar();

  @override
  Future<List<EntradaAyuda>> directorio() async => const [];
}

final ayudaRepositorioProvider = Provider<AyudaRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const AyudaSinConfigurar()
      : SupabaseAyudaRepositorio(cliente);
});

final directorioAyudaProvider = FutureProvider<List<EntradaAyuda>>(
  (ref) => ref.watch(ayudaRepositorioProvider).directorio(),
);

/// Veterinarias de urgencia o 24 h alrededor de la zona de la persona
/// (unos 10 km), para la pestaña Ayuda.
final veterinariasUrgenciaProvider = FutureProvider<List<Comercio>>((
  ref,
) async {
  final centro = ref.watch(miZonaProvider);
  final zona = Limites(
    minLat: centro.lat - 0.09,
    minLng: centro.lng - 0.11,
    maxLat: centro.lat + 0.09,
    maxLng: centro.lng + 0.11,
  );
  final todas = await ref
      .watch(comerciosRepositorioProvider)
      .enZona(zona, categorias: const {Categoria.vet});
  return [
    for (final c in todas)
      if (c.urgencias || c.es24h) c,
  ];
});
