/// Equipo de la empresa (3.5, D117): el dueño y hasta 5 personas más, con
/// plan Plus. Entre ellos se ven solo el primer nombre.
library;

/// Máximo de personas en el equipo, además del dueño (lo controla la base).
const maximoEquipo = 5;

/// `equipo_del_negocio()`.
class EquipoNegocio {
  const EquipoNegocio({
    required this.soyTitular,
    this.personas = const [],
    this.invitaciones = const [],
  });

  factory EquipoNegocio.fromJson(Map<String, Object?> json) => EquipoNegocio(
    soyTitular: json['soy_titular'] == true,
    personas: [
      for (final p in (json['personas'] as List?) ?? const [])
        PersonaEquipo.fromJson((p as Map).cast<String, Object?>()),
    ],
    invitaciones: [
      for (final i in (json['invitaciones'] as List?) ?? const [])
        InvitacionEquipo.fromJson((i as Map).cast<String, Object?>()),
    ],
  );

  final bool soyTitular;
  final List<PersonaEquipo> personas;

  /// Códigos sin usar ni vencidos (solo los ve el dueño).
  final List<InvitacionEquipo> invitaciones;

  bool get lleno => personas.length >= maximoEquipo;
}

class PersonaEquipo {
  const PersonaEquipo({
    required this.userId,
    required this.desde,
    this.nombre,
    this.soyYo = false,
  });

  factory PersonaEquipo.fromJson(Map<String, Object?> json) => PersonaEquipo(
    userId: json['user_id']! as String,
    nombre: json['nombre'] as String?,
    desde: DateTime.parse(json['desde']! as String),
    soyYo: json['soy_yo'] == true,
  );

  final String userId;

  /// Solo el primer nombre (puede faltar).
  final String? nombre;
  final DateTime desde;
  final bool soyYo;
}

class InvitacionEquipo {
  const InvitacionEquipo({required this.codigo, required this.vence});

  factory InvitacionEquipo.fromJson(Map<String, Object?> json) =>
      InvitacionEquipo(
        codigo: json['code']! as String,
        vence: DateTime.parse(json['expires_at']! as String),
      );

  final String codigo;
  final DateTime vence;
}

/// El código de una invitación: 8 letras y números sin los que se confunden
/// (sin I, O, 0 ni 1), como lo genera la base. Acepta el enlace entero
/// (`…/equipo/<código>`), minúsculas y espacios. `null` si no es válido.
String? codigoEquipo(String texto) {
  final limpio = texto.trim();
  final ultimo = limpio.split('/').where((p) => p.isNotEmpty).lastOrNull ?? '';
  final codigo = ultimo.replaceAll(RegExp(r'[\s-]'), '').toUpperCase();
  return RegExp(r'^[A-HJ-NP-Z2-9]{8}$').hasMatch(codigo) ? codigo : null;
}
