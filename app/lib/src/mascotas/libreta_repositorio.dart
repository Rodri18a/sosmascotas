import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';

/// Libreta sanitaria de las mascotas propias (tabla `health_records`, paso
/// 1.5.1). La RLS deja ver y editar solo la de mis mascotas. Se reemplaza en
/// las pruebas.
abstract interface class LibretaRepositorio {
  Future<List<RegistroSalud>> deMascota(String mascotaId);

  /// Crea el registro y devuelve la versión guardada (con su id).
  Future<RegistroSalud> crear(RegistroSalud registro);

  Future<RegistroSalud> actualizar(RegistroSalud registro);

  Future<void> borrar(String id);
}

class SupabaseLibretaRepositorio implements LibretaRepositorio {
  SupabaseLibretaRepositorio(this._cliente);

  final SupabaseClient _cliente;

  SupabaseQueryBuilder get _tabla => _cliente.from('health_records');

  @override
  Future<List<RegistroSalud>> deMascota(String mascotaId) async {
    final filas = await _tabla.select().eq('pet_id', mascotaId);
    return filas.map(RegistroSalud.fromJson).toList();
  }

  @override
  Future<RegistroSalud> crear(RegistroSalud registro) async =>
      RegistroSalud.fromJson(
        await _tabla.insert(registro.toJson()).select().single(),
      );

  @override
  Future<RegistroSalud> actualizar(RegistroSalud registro) async =>
      RegistroSalud.fromJson(
        await _tabla
            .update(registro.toJson())
            .eq('id', registro.id)
            .select()
            .single(),
      );

  @override
  Future<void> borrar(String id) => _tabla.delete().eq('id', id);
}

class LibretaSinConfigurar implements LibretaRepositorio {
  const LibretaSinConfigurar();

  @override
  Future<List<RegistroSalud>> deMascota(String mascotaId) async => const [];

  @override
  Future<RegistroSalud> crear(RegistroSalud registro) async => registro;

  @override
  Future<RegistroSalud> actualizar(RegistroSalud registro) async => registro;

  @override
  Future<void> borrar(String id) async {}
}

final libretaRepositorioProvider = Provider<LibretaRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const LibretaSinConfigurar()
      : SupabaseLibretaRepositorio(cliente);
});

/// Libreta de una mascota, agrupada por tipo y ordenada para mostrar.
final libretaProvider =
    FutureProvider.family<Map<TipoRegistroSalud, List<RegistroSalud>>, String>((
      ref,
      mascotaId,
    ) async {
      final registros = await ref
          .watch(libretaRepositorioProvider)
          .deMascota(mascotaId);
      return agruparLibreta(registros);
    });

/// Un registro puntual de la libreta (para editarlo).
final registroSaludProvider =
    Provider.family<
      AsyncValue<RegistroSalud?>,
      ({String mascotaId, String id})
    >(
      (ref, clave) => ref
          .watch(libretaProvider(clave.mascotaId))
          .whenData(
            (grupos) => grupos.values
                .expand((l) => l)
                .where((r) => r.id == clave.id)
                .firstOrNull,
          ),
    );
