import 'package:sosmascota/src/hogar/tareas_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Tareas del hogar en memoria para las pruebas.
class TareasFalsas implements TareasRepositorio {
  TareasFalsas({List<Tarea>? iniciales, this.yo = 'u1', DateTime? ahora})
    : tareas = [...?iniciales],
      ahora = ahora ?? DateTime(2026, 10, 17, 10, 20);

  final List<Tarea> tareas;
  final String yo;
  final DateTime ahora;
  int _siguiente = 1;

  @override
  Future<List<Tarea>> deMascota(String mascotaId, DateTime dia) async => [
    for (final t in tareas)
      if (t.mascotaId == mascotaId && fechaIso(t.dia) == fechaIso(dia)) t,
  ];

  @override
  Future<Tarea> crear(Tarea tarea) async {
    final guardada = Tarea.fromJson({
      ...tarea.toJson(),
      'id': 'tarea-${_siguiente++}',
      'created_by': yo,
    });
    tareas.add(guardada);
    return guardada;
  }

  @override
  Future<void> marcar(String tareaId, {required bool hecha}) async {
    final i = tareas.indexWhere((t) => t.id == tareaId);
    final t = tareas[i];
    tareas[i] = Tarea(
      id: t.id,
      mascotaId: t.mascotaId,
      tipo: t.tipo,
      dia: t.dia,
      nota: t.nota,
      asignadaA: t.asignadaA,
      creadaPor: t.creadaPor,
      hechaPor: hecha ? yo : null,
      hechaEn: hecha ? ahora : null,
    );
  }

  @override
  Future<void> borrar(String tareaId) async =>
      tareas.removeWhere((t) => t.id == tareaId);
}
