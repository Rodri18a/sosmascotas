import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

/// Recordatorios de mis mascotas (tabla `reminders`, paso 1.5.3). La RLS deja
/// ver y editar solo los de mis mascotas. Se reemplaza en las pruebas.
abstract interface class RecordatoriosRepositorio {
  /// Todos los de mis mascotas (para programar los avisos del dispositivo).
  Future<List<Recordatorio>> misRecordatorios();

  /// Crea el recordatorio y devuelve la versión guardada (con su id).
  Future<Recordatorio> crear(Recordatorio recordatorio);

  Future<Recordatorio> actualizar(Recordatorio recordatorio);

  Future<void> borrar(String id);
}

class SupabaseRecordatoriosRepositorio implements RecordatoriosRepositorio {
  SupabaseRecordatoriosRepositorio(this._cliente);

  final SupabaseClient _cliente;

  SupabaseQueryBuilder get _tabla => _cliente.from('reminders');

  static Recordatorio _leer(Map<String, Object?> fila) =>
      Recordatorio.fromJson(fila) ??
      (throw FormatException('Recordatorio inválido: ${fila['id']}'));

  @override
  Future<List<Recordatorio>> misRecordatorios() async {
    final filas = await _tabla.select().order('created_at', ascending: true);
    // Una fila que esta versión de la app no entiende se ignora.
    return filas.map(Recordatorio.fromJson).nonNulls.toList();
  }

  @override
  Future<Recordatorio> crear(Recordatorio recordatorio) async =>
      _leer(await _tabla.insert(recordatorio.toJson()).select().single());

  @override
  Future<Recordatorio> actualizar(Recordatorio recordatorio) async => _leer(
    await _tabla
        .update(recordatorio.toJson())
        .eq('id', recordatorio.id)
        .select()
        .single(),
  );

  @override
  Future<void> borrar(String id) => _tabla.delete().eq('id', id);
}

class RecordatoriosSinConfigurar implements RecordatoriosRepositorio {
  const RecordatoriosSinConfigurar();

  @override
  Future<List<Recordatorio>> misRecordatorios() async => const [];

  @override
  Future<Recordatorio> crear(Recordatorio recordatorio) async => recordatorio;

  @override
  Future<Recordatorio> actualizar(Recordatorio recordatorio) async =>
      recordatorio;

  @override
  Future<void> borrar(String id) async {}
}

final recordatoriosRepositorioProvider = Provider<RecordatoriosRepositorio>((
  ref,
) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const RecordatoriosSinConfigurar()
      : SupabaseRecordatoriosRepositorio(cliente);
});

/// Recordatorios de la persona con sesión (vacío si es visitante).
final misRecordatoriosProvider = FutureProvider<List<Recordatorio>>((
  ref,
) async {
  final usuario = ref.watch(usuarioActualProvider).value;
  if (usuario == null) return const [];
  return ref.watch(recordatoriosRepositorioProvider).misRecordatorios();
});

/// Los de una mascota.
final recordatoriosDeMascotaProvider =
    Provider.family<AsyncValue<List<Recordatorio>>, String>(
      (ref, mascotaId) => ref
          .watch(misRecordatoriosProvider)
          .whenData(
            (lista) => lista.where((r) => r.mascotaId == mascotaId).toList(),
          ),
    );

/// Un recordatorio puntual (para editarlo).
final recordatorioProvider = Provider.family<AsyncValue<Recordatorio?>, String>(
  (ref, id) => ref
      .watch(misRecordatoriosProvider)
      .whenData((lista) => lista.where((r) => r.id == id).firstOrNull),
);
