import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';
import '../utiles/enlaces.dart';

/// Tareas del hogar (tabla `household_tasks`, paso 1.6.3, D71). Se reemplaza
/// en las pruebas.
abstract interface class TareasRepositorio {
  Future<List<Tarea>> deMascota(String mascotaId, DateTime dia);

  Future<Tarea> crear(Tarea tarea);

  /// Marca hecha a mi nombre ([hecha]) o la deja pendiente otra vez.
  Future<void> marcar(String tareaId, {required bool hecha});

  Future<void> borrar(String tareaId);
}

class SupabaseTareasRepositorio implements TareasRepositorio {
  SupabaseTareasRepositorio(this._cliente);

  final SupabaseClient _cliente;

  SupabaseQueryBuilder get _tabla => _cliente.from('household_tasks');

  String get _yo =>
      _cliente.auth.currentUser?.id ??
      (throw StateError('Hace falta una sesión'));

  @override
  Future<List<Tarea>> deMascota(String mascotaId, DateTime dia) async {
    final filas = await _tabla
        .select()
        .eq('pet_id', mascotaId)
        .eq('day', fechaIso(dia))
        .order('created_at');
    return filas.map(Tarea.fromJson).toList();
  }

  @override
  Future<Tarea> crear(Tarea tarea) async => Tarea.fromJson(
    await _tabla
        .insert({...tarea.toJson(), 'created_by': _yo})
        .select()
        .single(),
  );

  @override
  Future<void> marcar(String tareaId, {required bool hecha}) =>
      _tabla.update({'done_by': hecha ? _yo : null}).eq('id', tareaId);

  @override
  Future<void> borrar(String tareaId) => _tabla.delete().eq('id', tareaId);
}

class TareasSinConfigurar implements TareasRepositorio {
  const TareasSinConfigurar();

  @override
  Future<List<Tarea>> deMascota(String mascotaId, DateTime dia) async =>
      const [];

  @override
  Future<Tarea> crear(Tarea tarea) async => tarea;

  @override
  Future<void> marcar(String tareaId, {required bool hecha}) async {}

  @override
  Future<void> borrar(String tareaId) async {}
}

final tareasRepositorioProvider = Provider<TareasRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const TareasSinConfigurar()
      : SupabaseTareasRepositorio(cliente);
});

/// Tareas de hoy de una mascota, ordenadas (las mías pendientes arriba).
final tareasDeHoyProvider = FutureProvider.family<List<Tarea>, String>((
  ref,
  mascotaId,
) async {
  final yo = ref.watch(usuarioActualProvider).value?.id;
  final hoy = ref.watch(relojProvider)();
  final tareas = await ref
      .watch(tareasRepositorioProvider)
      .deMascota(mascotaId, hoy);
  return ordenarTareas(tareas, yo);
});
