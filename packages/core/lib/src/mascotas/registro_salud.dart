import 'mascota.dart';

/// Tipo de registro de la libreta sanitaria (valores iguales a la base:
/// `health_records.kind`).
enum TipoRegistroSalud {
  vaccine,
  deworming,
  checkup,
  allergy,
  other;

  /// Las alergias no llevan fecha: son un dato permanente de la mascota.
  bool get llevaFecha => this != TipoRegistroSalud.allergy;
}

/// Un registro de la libreta sanitaria (tabla `health_records`, paso 1.5.1).
class RegistroSalud {
  const RegistroSalud({
    required this.id,
    required this.mascotaId,
    required this.tipo,
    required this.nombre,
    this.fecha,
    this.proxima,
    this.notas,
  });

  factory RegistroSalud.fromJson(Map<String, Object?> json) => RegistroSalud(
    id: json['id']! as String,
    mascotaId: json['pet_id']! as String,
    tipo:
        TipoRegistroSalud.values.asNameMap()[json['kind']] ??
        TipoRegistroSalud.other,
    nombre: json['name']! as String,
    fecha: _fecha(json['date']),
    proxima: _fecha(json['next_date']),
    notas: json['notes'] as String?,
  );

  final String id;
  final String mascotaId;
  final TipoRegistroSalud tipo;
  final String nombre;
  final DateTime? fecha;

  /// Próxima dosis o control (la usa el semáforo de 1.5.2).
  final DateTime? proxima;
  final String? notas;

  /// Columnas editables (sin `id`, que pone la base).
  Map<String, Object?> toJson() {
    final notasLimpias = notas?.trim();
    return {
      'pet_id': mascotaId,
      'kind': tipo.name,
      'name': nombre.trim(),
      'date': fecha == null ? null : fechaIso(fecha!),
      'next_date': proxima == null ? null : fechaIso(proxima!),
      'notes': notasLimpias == null || notasLimpias.isEmpty
          ? null
          : notasLimpias,
    };
  }

  static DateTime? _fecha(Object? valor) => switch (valor) {
    final String fecha => DateTime.parse(fecha),
    _ => null,
  };
}

/// Resultado de validar un registro antes de guardarlo (mismas reglas que la base).
enum ValidacionRegistroSalud { valido, sinNombre, nombreLargo, proximaAntes }

ValidacionRegistroSalud validarRegistroSalud({
  required String nombre,
  DateTime? fecha,
  DateTime? proxima,
}) {
  final limpio = nombre.trim();
  if (limpio.isEmpty) return ValidacionRegistroSalud.sinNombre;
  if (limpio.length > 80) return ValidacionRegistroSalud.nombreLargo;
  if (fecha != null && proxima != null && proxima.isBefore(fecha)) {
    return ValidacionRegistroSalud.proximaAntes;
  }
  return ValidacionRegistroSalud.valido;
}

/// Libreta ordenada para mostrar: por tipo (en el orden del enum) y, dentro
/// de cada tipo, lo más reciente primero (sin fecha al final).
Map<TipoRegistroSalud, List<RegistroSalud>> agruparLibreta(
  Iterable<RegistroSalud> registros,
) {
  final grupos = <TipoRegistroSalud, List<RegistroSalud>>{};
  for (final tipo in TipoRegistroSalud.values) {
    final delTipo = registros.where((r) => r.tipo == tipo).toList()
      ..sort((a, b) {
        final (fa, fb) = (a.fecha, b.fecha);
        if (fa == null || fb == null) {
          if (fa != null) return -1;
          if (fb != null) return 1;
          return a.nombre.compareTo(b.nombre);
        }
        return fb.compareTo(fa);
      });
    if (delTipo.isNotEmpty) grupos[tipo] = delTipo;
  }
  return grupos;
}
