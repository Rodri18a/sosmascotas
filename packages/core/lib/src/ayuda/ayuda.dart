/// Tipo de entrada del directorio de Ayuda (igual que `help_directory.kind`).
enum TipoAyuda {
  refugio,
  protectora,
  grupo,
  organismo;

  static TipoAyuda? desdeBase(Object? valor) =>
      TipoAyuda.values.where((t) => t.name == valor).firstOrNull;
}

/// Una entrada del directorio de Ayuda: refugio, protectora, grupo de
/// difusión u organismo de la zona.
class EntradaAyuda {
  const EntradaAyuda({
    required this.id,
    required this.tipo,
    required this.nombre,
    this.descripcion,
    this.telefono,
    this.whatsapp,
    this.enlace,
    this.esEjemplo = false,
  });

  /// `null` si el tipo no se conoce (versión vieja de la app): se omite.
  static EntradaAyuda? fromJson(Map<String, Object?> json) {
    final tipo = TipoAyuda.desdeBase(json['kind']);
    if (tipo == null) return null;
    return EntradaAyuda(
      id: json['id']! as String,
      tipo: tipo,
      nombre: json['name']! as String,
      descripcion: json['description'] as String?,
      telefono: json['phone'] as String?,
      whatsapp: json['whatsapp'] as String?,
      enlace: json['link'] as String?,
      esEjemplo: json['is_sample'] == true,
    );
  }

  final String id;
  final TipoAyuda tipo;
  final String nombre;
  final String? descripcion;
  final String? telefono;
  final String? whatsapp;
  final String? enlace;

  /// Dato de ejemplo (solo en desarrollo).
  final bool esEjemplo;
}
