/// Una noticia de la app (2.8, D83). Las carga la administración. Las
/// patrocinadas siempre se muestran con "Promocionado" y el nombre de la
/// marca: nunca se mezclan sin avisar.
class Noticia {
  const Noticia({
    required this.id,
    required this.titulo,
    required this.cuerpo,
    required this.publicada,
    this.fuente,
    this.enlace,
    this.especieIds = const [],
    this.patrocinada = false,
    this.marca,
  });

  factory Noticia.fromJson(Map<String, Object?> json) => Noticia(
    id: json['id']! as String,
    titulo: json['title']! as String,
    cuerpo: json['body']! as String,
    publicada: DateTime.parse(json['published_at']! as String).toLocal(),
    fuente: json['source'] as String?,
    enlace: json['link'] as String?,
    especieIds: [
      for (final e in (json['species_ids'] as List?) ?? const [])
        (e as num).toInt(),
    ],
    patrocinada: json['sponsored'] as bool? ?? false,
    marca: json['sponsor_name'] as String?,
  );

  final String id;
  final String titulo;
  final String cuerpo;
  final DateTime publicada;
  final String? fuente;

  /// Enlace para leer más (siempre `https://`).
  final String? enlace;

  /// Vacío: es para todas las especies.
  final List<int> especieIds;
  final bool patrocinada;

  /// Marca que la patrocina (obligatoria si es patrocinada).
  final String? marca;

  /// Regla de 06: coincide si es para todas o incluye alguna de [especies]
  /// (sin especies elegidas, coincide siempre).
  bool esPara(Set<int> especies) =>
      especies.isEmpty ||
      especieIds.isEmpty ||
      especieIds.any(especies.contains);

  /// Un pedazo del cuerpo para la tarjeta de la lista.
  String get resumen {
    final limpio = cuerpo.replaceAll(RegExp(r'\s+'), ' ').trim();
    return limpio.length <= 140 ? limpio : '${limpio.substring(0, 137)}…';
  }
}
