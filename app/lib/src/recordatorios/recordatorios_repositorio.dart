import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';
import '../utiles/enlaces.dart';
import '../utiles/respaldo.dart';

/// Recordatorios de mis mascotas (tabla `reminders`, paso 1.5.3). La RLS deja
/// ver y editar solo los de mis mascotas. Se reemplaza en las pruebas.
abstract interface class RecordatoriosRepositorio {
  /// Todos los de mis mascotas (para programar los avisos del dispositivo).
  Future<List<Recordatorio>> misRecordatorios();

  /// Crea el recordatorio y devuelve la versión guardada (con su id).
  Future<Recordatorio> crear(Recordatorio recordatorio);

  Future<Recordatorio> actualizar(Recordatorio recordatorio);

  Future<void> borrar(String id);

  /// Tomas marcadas de mis recordatorios desde [desde] (paso 1.5.5).
  Future<List<TomaHecha>> tomasHechas({required DateTime desde});

  /// Las últimas tomas marcadas de un recordatorio (historial).
  Future<List<TomaHecha>> historial(String recordatorioId, {int limite = 30});

  /// "✅ Ya se la di": marca la toma [prevista].
  Future<TomaHecha> marcar(String recordatorioId, DateTime prevista);

  /// Deshace una marca hecha por error.
  Future<void> desmarcar(String tomaId);
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

  SupabaseQueryBuilder get _tomas => _cliente.from('reminder_logs');

  @override
  Future<List<TomaHecha>> tomasHechas({required DateTime desde}) async {
    final filas = await _tomas
        .select()
        .gte('due_at', desde.toUtc().toIso8601String())
        .order('due_at');
    return filas.map(TomaHecha.fromJson).toList();
  }

  @override
  Future<List<TomaHecha>> historial(
    String recordatorioId, {
    int limite = 30,
  }) async {
    final filas = await _tomas
        .select()
        .eq('reminder_id', recordatorioId)
        .order('due_at', ascending: false)
        .limit(limite);
    return filas.map(TomaHecha.fromJson).toList();
  }

  @override
  Future<TomaHecha> marcar(String recordatorioId, DateTime prevista) async =>
      TomaHecha.fromJson(
        await _tomas
            .insert({
              'reminder_id': recordatorioId,
              'due_at': prevista.toUtc().toIso8601String(),
            })
            .select()
            .single(),
      );

  @override
  Future<void> desmarcar(String tomaId) => _tomas.delete().eq('id', tomaId);
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

  @override
  Future<List<TomaHecha>> tomasHechas({required DateTime desde}) async =>
      const [];

  @override
  Future<List<TomaHecha>> historial(
    String recordatorioId, {
    int limite = 30,
  }) async => const [];

  @override
  Future<TomaHecha> marcar(String recordatorioId, DateTime prevista) async =>
      TomaHecha(
        id: '',
        recordatorioId: recordatorioId,
        prevista: prevista,
        hecha: DateTime.now(),
      );

  @override
  Future<void> desmarcar(String tomaId) async {}
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
  final repo = ref.watch(recordatoriosRepositorioProvider);
  return conRespaldo(
    ref,
    clave: 'recordatorios',
    pedir: repo.misRecordatorios,
    aJson: (lista) => [
      for (final r in lista) {...r.toJson(), 'id': r.id},
    ],
    deJson: (json) =>
        listaJson(json).map(Recordatorio.fromJson).nonNulls.toList(),
  );
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

/// Tomas marcadas en el último día y medio (alcanza para la toma pendiente).
final tomasHechasProvider = FutureProvider<List<TomaHecha>>((ref) async {
  final usuario = ref.watch(usuarioActualProvider).value;
  if (usuario == null) return const [];
  final ahora = ref.watch(relojProvider)();
  return ref
      .watch(recordatoriosRepositorioProvider)
      .tomasHechas(desde: ahora.subtract(const Duration(hours: 36)));
});

/// Historial de un recordatorio.
final historialProvider = FutureProvider.family<List<TomaHecha>, String>(
  (ref, recordatorioId) =>
      ref.watch(recordatoriosRepositorioProvider).historial(recordatorioId),
);
