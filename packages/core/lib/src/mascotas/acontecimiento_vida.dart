import '../qr/qr_tag.dart';
import 'mascota.dart';

/// Tipo de acontecimiento del historial de vida (valores iguales a la base:
/// `life_events.kind`). Las alergias van en la libreta.
enum TipoAcontecimiento {
  surgery,
  accident,
  illness,
  treatment,
  diagnosis,
  other,
}

/// Un acontecimiento del historial de vida (tabla `life_events`, D131): una
/// operación, un accidente, una enfermedad… con fecha, nota y hasta
/// [maxAdjuntos] fotos o documentos (rutas del bucket privado `pet-records`).
class AcontecimientoVida {
  const AcontecimientoVida({
    required this.id,
    required this.mascotaId,
    required this.tipo,
    required this.titulo,
    required this.fecha,
    this.notas,
    this.adjuntos = const [],
  });

  factory AcontecimientoVida.fromJson(Map<String, Object?> json) =>
      AcontecimientoVida(
        id: json['id']! as String,
        mascotaId: json['pet_id']! as String,
        tipo:
            TipoAcontecimiento.values.asNameMap()[json['kind']] ??
            TipoAcontecimiento.other,
        titulo: json['title']! as String,
        fecha: DateTime.parse(json['date']! as String),
        notas: json['notes'] as String?,
        adjuntos: [
          for (final a in (json['files'] as List<Object?>?) ?? const []) '$a',
        ],
      );

  static const maxAdjuntos = 4;

  /// Tope de un adjunto (el del bucket): 5 MB.
  static const maxBytesAdjunto = 5 * 1024 * 1024;

  final String id;
  final String mascotaId;
  final TipoAcontecimiento tipo;
  final String titulo;
  final DateTime fecha;
  final String? notas;
  final List<String> adjuntos;

  AcontecimientoVida copiaCon({List<String>? adjuntos}) => AcontecimientoVida(
    id: id,
    mascotaId: mascotaId,
    tipo: tipo,
    titulo: titulo,
    fecha: fecha,
    notas: notas,
    adjuntos: adjuntos ?? this.adjuntos,
  );

  /// Columnas editables (sin `id`, que pone la base).
  Map<String, Object?> toJson() {
    final notasLimpias = notas?.trim();
    return {
      'pet_id': mascotaId,
      'kind': tipo.name,
      'title': titulo.trim(),
      'date': fechaIso(fecha),
      'notes': notasLimpias == null || notasLimpias.isEmpty
          ? null
          : notasLimpias,
      'files': adjuntos,
    };
  }

  /// Si el adjunto es un PDF (si no, es una foto).
  static bool esPdf(String ruta) => ruta.toLowerCase().endsWith('.pdf');
}

/// Resultado de validar un acontecimiento (mismas reglas que la base).
enum ValidacionAcontecimiento {
  valido,
  sinTitulo,
  tituloLargo,
  notasLargas,
  fechaFutura,
  muchosAdjuntos,
}

ValidacionAcontecimiento validarAcontecimiento({
  required String titulo,
  required DateTime fecha,
  required DateTime hoy,
  String? notas,
  int adjuntos = 0,
}) {
  final limpio = titulo.trim();
  if (limpio.isEmpty) return ValidacionAcontecimiento.sinTitulo;
  if (limpio.length > 80) return ValidacionAcontecimiento.tituloLargo;
  if ((notas?.trim().length ?? 0) > 1000) {
    return ValidacionAcontecimiento.notasLargas;
  }
  final dia = DateTime(hoy.year, hoy.month, hoy.day);
  if (fecha.isAfter(dia.add(const Duration(days: 1)))) {
    return ValidacionAcontecimiento.fechaFutura;
  }
  if (adjuntos > AcontecimientoVida.maxAdjuntos) {
    return ValidacionAcontecimiento.muchosAdjuntos;
  }
  return ValidacionAcontecimiento.valido;
}

/// Enlace público de solo lectura al historial: `<base>/h/<token>` (D133).
String urlHistorialCompartido(
  String token, {
  String base = urlPublicaPorDefecto,
}) => '${base.replaceAll(RegExp(r'/+$'), '')}/h/$token';

/// El historial de una mascota, de lo más nuevo a lo más viejo.
List<AcontecimientoVida> ordenarHistorial(List<AcontecimientoVida> lista) =>
    [...lista]..sort((a, b) => b.fecha.compareTo(a.fecha));
