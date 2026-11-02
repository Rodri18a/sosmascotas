/// Un banner del carrusel de Inicio (D128). Los carga la administración; los
/// patrocinados siempre se muestran con "Promocionado" y el nombre de la marca.
class BannerInicio {
  const BannerInicio({
    required this.id,
    required this.titulo,
    required this.imagen,
    this.enlace,
    this.noticiaId,
    this.patrocinado = false,
    this.marca,
  });

  factory BannerInicio.fromJson(Map<String, Object?> json) => BannerInicio(
    id: json['id']! as String,
    titulo: json['title']! as String,
    imagen: json['image_path']! as String,
    enlace: json['link'] as String?,
    noticiaId: json['news_id'] as String?,
    patrocinado: json['sponsored'] as bool? ?? false,
    marca: json['sponsor_name'] as String?,
  );

  final String id;

  /// También es el texto alternativo de la imagen.
  final String titulo;

  /// Ruta de la imagen en el bucket `banners`.
  final String imagen;

  /// Enlace que se abre al tocarlo (siempre `https://`).
  final String? enlace;

  /// Noticia que se abre al tocarlo (solo si sigue publicada).
  final String? noticiaId;

  final bool patrocinado;

  /// Marca que lo patrocina (obligatoria si es patrocinado).
  final String? marca;
}
