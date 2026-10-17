/// Rol en un hogar compartido (D69).
enum RolHogar { owner, member, tempCaregiver }

/// Una persona de un hogar compartido (`integrantes_de_mis_hogares()`).
/// Solo el nombre visible: el correo de los demás nunca llega a la app.
class Integrante {
  const Integrante({
    required this.hogarId,
    required this.usuarioId,
    required this.rol,
    this.nombre,
    this.accesoHasta,
  });

  factory Integrante.fromJson(Map<String, Object?> json) => Integrante(
    hogarId: json['household_id']! as String,
    usuarioId: json['user_id']! as String,
    nombre: json['display_name'] as String?,
    rol: switch (json['role']) {
      'owner' => RolHogar.owner,
      'temp_caregiver' => RolHogar.tempCaregiver,
      _ => RolHogar.member,
    },
    accesoHasta: switch (json['access_until']) {
      final String fecha => DateTime.parse(fecha).toLocal(),
      _ => null,
    },
  );

  final String hogarId;
  final String usuarioId;
  final String? nombre;
  final RolHogar rol;

  /// Hasta cuándo puede entrar un cuidador temporal (1.6.4).
  final DateTime? accesoHasta;

  bool get esDueno => rol == RolHogar.owner;
}

/// Máximo de integrantes además del dueño (lo controla también la base).
const maxIntegrantesHogar = 5;

/// Código de invitación: 10 letras y números sin los que se confunden (0/O, 1/I).
bool codigoInvitacionValido(String codigo) =>
    RegExp(r'^[A-HJ-NP-Z2-9]{10}$').hasMatch(codigo.trim().toUpperCase());
