import '../mapa/mapa.dart';
import '../mascotas/mascota.dart';
import '../qr/qr_tag.dart';

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

/// Tarjeta pública de un SOS para la lista por cercanía (`sos_cercanos`).
class SosResumen {
  const SosResumen({
    required this.id,
    required this.tipo,
    required this.especie,
    required this.especieIcono,
    required this.cuando,
    required this.distanciaMetros,
    this.nombre,
    this.raza,
    this.color,
    this.foto,
  });

  factory SosResumen.fromJson(Map<String, Object?> json) => SosResumen(
    id: json['id']! as String,
    tipo: TipoSos.desdeBase(json['kind']),
    especie: json['species']! as String,
    especieIcono: json['species_icon']! as String,
    cuando: DateTime.parse(json['happened_at']! as String).toLocal(),
    distanciaMetros: (json['distance_m']! as num).toDouble(),
    nombre: json['name'] as String?,
    raza: json['breed'] as String?,
    color: json['color'] as String?,
    foto: json['photo'] as String?,
  );

  final String id;
  final TipoSos tipo;
  final String especie;
  final String especieIcono;
  final DateTime cuando;
  final double distanciaMetros;
  final String? nombre;
  final String? raza;
  final String? color;
  final String? foto;
}

/// Pin del mapa a partir de una fila de `sos_en_zona`.
Pin pinDeSos(Map<String, Object?> json) => Pin(
  id: json['id']! as String,
  tipo: json['kind'] == 'found' ? TipoPin.encontrado : TipoPin.perdido,
  punto: Punto(
    (json['lat']! as num).toDouble(),
    (json['lng']! as num).toDouble(),
  ),
);

/// "a 350 m", "a 2,4 km".
String textoDistancia(double metros) {
  final redondeado = (metros / 50).round() * 50;
  return redondeado < 1000
      ? '$redondeado m'
      : '${(metros / 1000).toStringAsFixed(1).replaceAll('.', ',')} km';
}

/// Detalle público de un SOS (`sos_publico`).
class SosDetalle {
  const SosDetalle({
    required this.id,
    required this.tipo,
    required this.estado,
    required this.especie,
    required this.especieIcono,
    required this.cuando,
    required this.zona,
    required this.fotos,
    required this.esMio,
    this.nombre,
    this.raza,
    this.sexo = Sexo.unknown,
    this.color,
    this.senas,
    this.descripcion,
    this.recompensa,
    this.tieneMicrochip = false,
    this.whatsapp,
    this.muestraWhatsapp = false,
  });

  factory SosDetalle.fromJson(Map<String, Object?> json) => SosDetalle(
    id: json['id']! as String,
    tipo: TipoSos.desdeBase(json['kind']),
    estado: EstadoSos.desdeBase(json['status']),
    especie: json['species']! as String,
    especieIcono: json['species_icon']! as String,
    cuando: DateTime.parse(json['happened_at']! as String).toLocal(),
    zona: Punto(
      (json['lat']! as num).toDouble(),
      (json['lng']! as num).toDouble(),
    ),
    fotos: [...?(json['photos'] as List<Object?>?)?.cast<String>()],
    esMio: json['mine'] == true,
    nombre: json['name'] as String?,
    raza: json['breed'] as String?,
    sexo: Sexo.values.asNameMap()[json['sex']] ?? Sexo.unknown,
    color: json['color'] as String?,
    senas: json['marks'] as String?,
    descripcion: json['description'] as String?,
    recompensa: json['reward'] as String?,
    tieneMicrochip: json['has_microchip'] == true,
    whatsapp: json['whatsapp'] as String?,
    muestraWhatsapp: json['show_whatsapp'] == true,
  );

  final String id;
  final TipoSos tipo;
  final EstadoSos estado;
  final String especie;
  final String especieIcono;
  final DateTime cuando;

  /// Punto aproximado (nunca el exacto).
  final Punto zona;
  final List<String> fotos;
  final bool esMio;
  final String? nombre;
  final String? raza;
  final Sexo sexo;
  final String? color;
  final String? senas;
  final String? descripcion;
  final String? recompensa;
  final bool tieneMicrochip;
  final String? whatsapp;
  final bool muestraWhatsapp;
}

/// Enlace público para compartir un SOS: `<base>/s/<id>`.
String urlPaginaSos(String id, {String base = urlPublicaPorDefecto}) =>
    '${base.replaceAll(RegExp(r'/+$'), '')}/s/$id';
