import '../mascotas/mascota.dart';

/// Tipo de tarea del hogar (valores iguales a la base: `household_tasks.kind`).
enum TipoTarea { walk, food, bath, vet, other }

/// Tarea del hogar para una mascota y un día (tabla `household_tasks`,
/// paso 1.6.3, D71).
class Tarea {
  const Tarea({
    required this.id,
    required this.mascotaId,
    required this.tipo,
    required this.dia,
    this.nota,
    this.asignadaA,
    this.creadaPor,
    this.hechaPor,
    this.hechaEn,
  });

  factory Tarea.fromJson(Map<String, Object?> json) => Tarea(
    id: json['id']! as String,
    mascotaId: json['pet_id']! as String,
    tipo: TipoTarea.values.asNameMap()[json['kind']] ?? TipoTarea.other,
    dia: DateTime.parse(json['day']! as String),
    nota: json['note'] as String?,
    asignadaA: json['assigned_to'] as String?,
    creadaPor: json['created_by'] as String?,
    hechaPor: json['done_by'] as String?,
    hechaEn: switch (json['done_at']) {
      final String fecha => DateTime.parse(fecha).toLocal(),
      _ => null,
    },
  );

  final String id;
  final String mascotaId;
  final TipoTarea tipo;

  /// Solo la fecha.
  final DateTime dia;
  final String? nota;
  final String? asignadaA;
  final String? creadaPor;
  final String? hechaPor;
  final DateTime? hechaEn;

  bool get hecha => hechaPor != null;

  /// Columnas para crearla (`created_by` lo pone el repositorio; `done_at`,
  /// la base).
  Map<String, Object?> toJson() {
    final notaLimpia = nota?.trim();
    return {
      'pet_id': mascotaId,
      'kind': tipo.name,
      'note': notaLimpia == null || notaLimpia.isEmpty ? null : notaLimpia,
      'day': fechaIso(dia),
      'assigned_to': asignadaA,
    };
  }
}

/// Tareas para mostrar: primero las pendientes (las mías arriba), después
/// las hechas.
List<Tarea> ordenarTareas(Iterable<Tarea> tareas, String? yo) {
  int peso(Tarea t) => t.hecha ? 2 : (t.asignadaA == yo ? 0 : 1);
  return tareas.toList()..sort((a, b) {
    final p = peso(a).compareTo(peso(b));
    return p != 0 ? p : a.tipo.index.compareTo(b.tipo.index);
  });
}
