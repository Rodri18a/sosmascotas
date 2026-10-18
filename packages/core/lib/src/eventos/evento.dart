import '../mapa/mapa.dart';

/// Tipo de evento (`events_calendar.kind`, 2.7, D80).
enum TipoEvento { castracion, adopcion, encuentro, otro }

/// Un evento del mapa (`eventos_en_zona()`): jornadas de castración, ferias
/// de adopción, encuentros. Los publican comercios verificados.
class Evento {
  const Evento({
    required this.id,
    required this.tipo,
    required this.titulo,
    required this.desde,
    required this.hasta,
    required this.punto,
    this.descripcion,
    this.direccion,
    this.enlace,
    this.organizador,
    this.mio = false,
  });

  factory Evento.fromJson(Map<String, Object?> json) => Evento(
    id: json['id']! as String,
    tipo: TipoEvento.values.asNameMap()[json['kind']] ?? TipoEvento.otro,
    titulo: json['title']! as String,
    descripcion: json['description'] as String?,
    desde: DateTime.parse(json['starts_at']! as String).toLocal(),
    hasta: DateTime.parse(json['ends_at']! as String).toLocal(),
    punto: Punto(
      (json['lat']! as num).toDouble(),
      (json['lng']! as num).toDouble(),
    ),
    direccion: json['address'] as String?,
    enlace: json['link'] as String?,
    organizador: json['organizador'] as String?,
    mio: json['mine'] == true,
  );

  final String id;
  final TipoEvento tipo;
  final String titulo;
  final String? descripcion;
  final DateTime desde;
  final DateTime hasta;
  final Punto punto;
  final String? direccion;
  final String? enlace;
  final String? organizador;
  final bool mio;

  /// ¿Está pasando en [ahora]?
  bool enCurso(DateTime ahora) =>
      !ahora.isBefore(desde) && ahora.isBefore(hasta);

  Pin get pin => Pin(id: 'evento:$id', tipo: TipoPin.evento, punto: punto);
}

/// Estado de una denuncia de maltrato (`abuse_reports.status`).
enum EstadoDenuncia { nueva, derivada, cerrada }

/// Una denuncia propia (`mis_denuncias()`).
class Denuncia {
  const Denuncia({
    required this.id,
    required this.descripcion,
    required this.estado,
    required this.creada,
  });

  factory Denuncia.fromJson(Map<String, Object?> json) => Denuncia(
    id: json['id']! as String,
    descripcion: json['description']! as String,
    estado: switch (json['status']) {
      'referred' => EstadoDenuncia.derivada,
      'closed' => EstadoDenuncia.cerrada,
      _ => EstadoDenuncia.nueva,
    },
    creada: DateTime.parse(json['created_at']! as String).toLocal(),
  );

  final String id;
  final String descripcion;
  final EstadoDenuncia estado;
  final DateTime creada;
}
