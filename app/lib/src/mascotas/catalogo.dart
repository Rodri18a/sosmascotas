import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';

/// Especies y razas (datos de referencia, iguales para todos).
abstract interface class CatalogoRepositorio {
  Future<List<Especie>> especies();

  Future<List<Raza>> razas(int especieId);
}

class SupabaseCatalogoRepositorio implements CatalogoRepositorio {
  SupabaseCatalogoRepositorio(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<List<Especie>> especies() async {
    final filas = await _cliente
        .from('species')
        .select('id, slug, name, icon')
        // Solo las habilitadas: la primera versión es de perros y gatos (D149).
        .eq('enabled', true)
        // En supabase_flutter `order` es descendente si no se aclara.
        .order('sort', ascending: true);
    return filas.map(Especie.fromJson).toList();
  }

  @override
  Future<List<Raza>> razas(int especieId) async {
    final filas = await _cliente
        .from('breeds')
        .select('id, species_id, name')
        .eq('species_id', especieId)
        .order('sort', ascending: true) // "Mestizo" primero
        .order('name', ascending: true);
    return filas.map(Raza.fromJson).toList();
  }
}

class CatalogoSinConfigurar implements CatalogoRepositorio {
  const CatalogoSinConfigurar();

  @override
  Future<List<Especie>> especies() async => const [];

  @override
  Future<List<Raza>> razas(int especieId) async => const [];
}

final catalogoRepositorioProvider = Provider<CatalogoRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const CatalogoSinConfigurar()
      : SupabaseCatalogoRepositorio(cliente);
});

/// Se cargan una vez por sesión (no cambian).
final especiesProvider = FutureProvider<List<Especie>>(
  (ref) => ref.watch(catalogoRepositorioProvider).especies(),
);

final razasProvider = FutureProvider.family<List<Raza>, int>(
  (ref, especieId) => ref.watch(catalogoRepositorioProvider).razas(especieId),
);
