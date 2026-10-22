/// Código QR de una mascota (tabla `qr_tags`).
class QrTag {
  const QrTag({
    required this.id,
    required this.codigo,
    required this.activo,
    this.mascotaId,
    this.notaPublica,
  });

  factory QrTag.fromJson(Map<String, Object?> json) => QrTag(
    id: json['id']! as String,
    codigo: json['code']! as String,
    activo: json['active']! as bool,
    mascotaId: json['pet_id'] as String?,
    notaPublica: json['public_note'] as String?,
  );

  final String id;
  final String codigo;
  final bool activo;
  final String? mascotaId;
  final String? notaPublica;

  Map<String, Object?> toJson() => {
    'id': id,
    'code': codigo,
    'active': activo,
    'pet_id': mascotaId,
    'public_note': notaPublica,
  };
}

/// Dirección pública por defecto de las páginas del QR y de los SOS.
const urlPublicaPorDefecto = 'https://sosmascotas.uy';

/// Enlace que va dentro del QR: `<base>/m/<código>`.
String urlPaginaQr(String codigo, {String base = urlPublicaPorDefecto}) =>
    '${base.replaceAll(RegExp(r'/+$'), '')}/m/$codigo';

/// Código de una chapita a partir de lo que escribió o pegó el dueño: el
/// código solo (con espacios, guiones o minúsculas) o el enlace completo
/// `…/m/<código>`. `null` si no es un código válido (8 caracteres sin los que
/// se confunden: 0/O, 1/I).
String? codigoChapita(String texto) {
  final enlace = RegExp(r'/m/([^/?#\s]+)').firstMatch(texto);
  final limpio = (enlace?.group(1) ?? texto)
      .replaceAll(RegExp(r'[\s-]'), '')
      .toUpperCase();
  return RegExp(r'^[2-9A-HJ-NP-Z]{8}$').hasMatch(limpio) ? limpio : null;
}
