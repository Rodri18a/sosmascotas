/// Servicios de un comercio (2.10a, D90): "Baño y corte", "Consulta"…
library;

double? _numero(Object? v) => switch (v) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s),
  _ => null,
};

class Servicio {
  const Servicio({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.precio,
    this.desde = false,
    this.duracionMinutos,
    this.especieIds = const [],
    this.disponible = true,
    this.orden = 0,
  });

  factory Servicio.fromJson(Map<String, Object?> json) => Servicio(
    id: json['id']! as String,
    nombre: json['name']! as String,
    descripcion: json['description'] as String?,
    precio: _numero(json['price']),
    desde: json['price_from'] as bool? ?? false,
    duracionMinutos: (json['duration_min'] as num?)?.toInt(),
    especieIds: [
      for (final e in (json['species_ids'] as List?) ?? const [])
        (e as num).toInt(),
    ],
    disponible: json['available'] as bool? ?? true,
    orden: (json['sort'] as num?)?.toInt() ?? 0,
  );

  static const maximoPorComercio = 50;

  final String id;
  final String nombre;
  final String? descripcion;

  /// `null`: no tiene precio publicado, solo se puede "Consultar".
  final double? precio;

  /// El precio es un piso ("desde $ 600"), por ejemplo según el tamaño.
  final bool desde;
  final int? duracionMinutos;
  final List<int> especieIds;
  final bool disponible;
  final int orden;

  bool get soloConsultar => precio == null;

  Map<String, Object?> toJson() => {
    'id': id.isEmpty ? null : id,
    'name': nombre,
    'description': descripcion,
    'price': precio,
    'price_from': precio != null && desde,
    'duration_min': duracionMinutos,
    'species_ids': especieIds,
    'available': disponible,
    'sort': orden,
  };
}
