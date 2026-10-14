/// Estado de un aviso (valores iguales a la base: `alert_status`).
enum EstadoAviso { nuevo, visto, respondido, estafa }

const _estadosBase = {
  'new': EstadoAviso.nuevo,
  'seen': EstadoAviso.visto,
  'replied': EstadoAviso.respondido,
  'scam_reported': EstadoAviso.estafa,
};

String estadoAvisoABase(EstadoAviso estado) =>
    _estadosBase.entries.firstWhere((e) => e.value == estado).key;

/// Aviso que alguien le dejó al dueño (contacto inverso, vista `owner_alerts_app`).
class Aviso {
  const Aviso({
    required this.id,
    required this.desdeQr,
    required this.nombreRemitente,
    required this.contactoRemitente,
    required this.mensaje,
    required this.estado,
    required this.creado,
    this.mascotaId,
    this.lat,
    this.lng,
  });

  factory Aviso.fromJson(Map<String, Object?> json) => Aviso(
    id: json['id']! as String,
    desdeQr: json['target_type'] == 'qr',
    mascotaId: json['pet_id'] as String?,
    nombreRemitente: json['sender_name']! as String,
    contactoRemitente: json['sender_contact']! as String,
    mensaje: json['message']! as String,
    estado: _estadosBase[json['status']] ?? EstadoAviso.nuevo,
    creado: DateTime.parse(json['created_at']! as String).toLocal(),
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
  );

  final String id;
  final bool desdeQr;
  final String? mascotaId;
  final String nombreRemitente;
  final String contactoRemitente;
  final String mensaje;
  final EstadoAviso estado;
  final DateTime creado;
  final double? lat;
  final double? lng;

  bool get tieneUbicacion => lat != null && lng != null;
}

/// Teléfono uruguayo en formato internacional sin "+" (para wa.me), o `null`
/// si no parece un teléfono. "099 123 456" → "59899123456".
String? telefonoInternacionalUy(String texto) {
  var digitos = texto.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digitos.startsWith('+')) digitos = digitos.substring(1);
  if (digitos.startsWith('00')) digitos = digitos.substring(2);
  if (digitos.startsWith('598')) {
    return digitos.length >= 11 ? digitos : null;
  }
  if (digitos.startsWith('0') && digitos.length >= 8) {
    return '598${digitos.substring(1)}';
  }
  if (digitos.length == 8 &&
      (digitos.startsWith('9') ||
          digitos.startsWith('2') ||
          digitos.startsWith('4'))) {
    return '598$digitos';
  }
  return digitos.length >= 10 ? digitos : null; // Otro país con su código.
}
