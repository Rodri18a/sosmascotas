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
