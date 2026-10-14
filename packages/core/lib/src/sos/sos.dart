import '../mapa/mapa.dart';
import '../mascotas/mascota.dart';

/// Perdida (`lost`) o encontrada (`found`).
enum TipoSos {
  perdida('lost'),
  encontrada('found');

  const TipoSos(this.base);

  final String base;

  static TipoSos desdeBase(Object? valor) =>
      valor == 'found' ? TipoSos.encontrada : TipoSos.perdida;
}

enum EstadoSos {
  activo('active'),
  resuelto('resolved'),
  archivado('archived'),
  oculto('hidden');

  const EstadoSos(this.base);

  final String base;

  static EstadoSos desdeBase(Object? valor) =>
      EstadoSos.values.where((e) => e.base == valor).firstOrNull ??
      EstadoSos.activo;
}

/// Datos para publicar un SOS (función `crear_sos`).
class NuevoSos {
  const NuevoSos({
    required this.tipo,
    required this.especieId,
    required this.ubicacion,
    required this.fotos,
    this.mascotaId,
    this.razaId,
    this.razaOtra,
    this.nombre,
    this.sexo = Sexo.unknown,
    this.color,
    this.senas,
    this.descripcion,
    this.recompensa,
    this.tieneMicrochip = false,
    this.cuando,
  });

  final TipoSos tipo;
  final int especieId;
  final Punto ubicacion;

  /// Rutas `bucket/user_id/archivo` (al menos una).
  final List<String> fotos;
  final String? mascotaId;
  final int? razaId;
  final String? razaOtra;
  final String? nombre;
  final Sexo sexo;
  final String? color;
  final String? senas;
  final String? descripcion;
  final String? recompensa;
  final bool tieneMicrochip;
  final DateTime? cuando;

  Map<String, Object?> toJson() => {
    'kind': tipo.base,
    'species_id': especieId,
    'lat': ubicacion.lat,
    'lng': ubicacion.lng,
    'photos': fotos,
    'pet_id': mascotaId,
    'breed_id': razaId,
    'breed_other': razaOtra,
    'name': nombre,
    'sex': sexo.name,
    'color': color,
    'marks': senas,
    'description': descripcion,
    'reward': tipo == TipoSos.perdida ? recompensa : null,
    'has_microchip': tieneMicrochip,
    'happened_at': cuando?.toUtc().toIso8601String(),
  };
}

/// Un SOS propio (función `mis_sos`).
class MiSos {
  const MiSos({
    required this.id,
    required this.tipo,
    required this.estado,
    required this.creado,
    required this.ubicacion,
    this.nombre,
    this.mascotaId,
    this.fotos = const [],
  });

  factory MiSos.fromJson(Map<String, Object?> json) => MiSos(
    id: json['id']! as String,
    tipo: TipoSos.desdeBase(json['kind']),
    estado: EstadoSos.desdeBase(json['status']),
    creado: DateTime.parse(json['created_at']! as String).toLocal(),
    ubicacion: Punto(
      (json['lat']! as num).toDouble(),
      (json['lng']! as num).toDouble(),
    ),
    nombre: json['name'] as String?,
    mascotaId: json['pet_id'] as String?,
    fotos: [...?(json['photos'] as List<Object?>?)?.cast<String>()],
  );

  final String id;
  final TipoSos tipo;
  final EstadoSos estado;
  final DateTime creado;
  final Punto ubicacion;
  final String? nombre;
  final String? mascotaId;
  final List<String> fotos;
}
