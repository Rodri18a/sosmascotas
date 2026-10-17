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

/// Semáforo de próximos controles (paso 1.5.2, `03-funcionalidades-app.md`):
/// rojo a 7 días o menos, amarillo hasta 30, verde si falta más, y vencido
/// si la fecha ya pasó.
enum Semaforo { vencido, rojo, amarillo, verde }

/// Días de calendario desde [hoy] hasta [fecha] (negativo si ya pasó).
int diasHasta(DateTime fecha, DateTime hoy) => DateTime.utc(
  fecha.year,
  fecha.month,
  fecha.day,
).difference(DateTime.utc(hoy.year, hoy.month, hoy.day)).inDays;

Semaforo semaforoDe(DateTime proxima, DateTime hoy) {
  final dias = diasHasta(proxima, hoy);
  if (dias < 0) return Semaforo.vencido;
  if (dias <= 7) return Semaforo.rojo;
  if (dias <= 30) return Semaforo.amarillo;
  return Semaforo.verde;
}

/// Registros cuya próxima fecha sigue vigente, del más urgente al menos.
/// Si se cargó una dosis más nueva de lo mismo (mismo tipo y nombre), la
/// próxima fecha de la anterior ya no cuenta: la reemplaza la nueva.
List<RegistroSalud> proximosVigentes(Iterable<RegistroSalud> registros) {
  String clave(RegistroSalud r) =>
      '${r.tipo.name}:${r.nombre.trim().toLowerCase()}';
  final ultimo = <String, RegistroSalud>{};
  for (final r in registros) {
    final actual = ultimo[clave(r)];
    final masNuevo =
        actual == null ||
        (r.fecha ?? DateTime(0)).isAfter(actual.fecha ?? DateTime(0));
    if (masNuevo) ultimo[clave(r)] = r;
  }
  return ultimo.values.where((r) => r.proxima != null).toList()
    ..sort((a, b) => a.proxima!.compareTo(b.proxima!));
}
