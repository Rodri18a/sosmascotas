/// Plan de la persona usuaria (valores iguales a la base: `user_plan`).
enum Plan { free, pro, family }

/// Radio de avisos permitido, en km (igual que la regla de la base).
const radioAvisosMinKm = 1;
const radioAvisosMaxKm = 20;

/// Perfil de una cuenta (tabla `profiles`). Solo lo ve su dueño.
class Perfil {
  const Perfil({
    required this.id,
    required this.nombre,
    required this.plan,
    required this.radioAvisosKm,
    this.zonaId,
    this.versionTerminos,
    this.terminosAceptadosEn,
  });

  factory Perfil.fromJson(Map<String, Object?> json) => Perfil(
    id: json['id']! as String,
    nombre: (json['display_name'] as String?) ?? '',
    plan: Plan.values.asNameMap()[json['plan']] ?? Plan.free,
    radioAvisosKm: (json['alert_radius_km'] as num?)?.toInt() ?? 5,
    zonaId: (json['zone_id'] as num?)?.toInt(),
    versionTerminos: json['terms_version'] as String?,
    terminosAceptadosEn: switch (json['terms_accepted_at']) {
      final String fecha => DateTime.parse(fecha),
      _ => null,
    },
  );

  final String id;
  final String nombre;
  final Plan plan;
  final int radioAvisosKm;
  final int? zonaId;
  final String? versionTerminos;
  final DateTime? terminosAceptadosEn;

  /// ¿Aceptó esta versión de los términos y la política de privacidad?
  bool aceptoTerminos(String versionVigente) =>
      versionTerminos == versionVigente && terminosAceptadosEn != null;
}
