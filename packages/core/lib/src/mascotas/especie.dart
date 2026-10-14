/// Especie de animal (tabla `species`).
class Especie {
  const Especie({
    required this.id,
    required this.slug,
    required this.nombre,
    required this.icono,
  });

  factory Especie.fromJson(Map<String, Object?> json) => Especie(
    id: (json['id']! as num).toInt(),
    slug: json['slug']! as String,
    nombre: json['name']! as String,
    icono: json['icon']! as String,
  );

  final int id;
  final String slug;
  final String nombre;
  final String icono;
}

/// Raza de una especie (tabla `breeds`).
class Raza {
  const Raza({required this.id, required this.especieId, required this.nombre});

  factory Raza.fromJson(Map<String, Object?> json) => Raza(
    id: (json['id']! as num).toInt(),
    especieId: (json['species_id']! as num).toInt(),
    nombre: json['name']! as String,
  );

  final int id;
  final int especieId;
  final String nombre;
}
