import '../comercios/comercio.dart';
import '../eventos/evento.dart';

/// De dónde sale una novedad de la comunidad (D86). `perdida`: una mascota
/// que se sigue buscando (D87); se abre su reporte para seguirlo.
enum TipoNovedad { reencuentro, adopcion, comercio, evento, perdida }

/// Una novedad de la comunidad (`novedades_comunidad()`, D86). Se arma sola
/// con lo que pasa en la app; los textos los pone la app con estos datos.
/// Nunca trae ubicación ni datos de personas.
class Novedad {
  const Novedad({
    required this.id,
    required this.tipo,
    required this.fecha,
    this.origenId,
    this.nombre,
    this.detalle,
    this.especieId,
    this.cantidad,
    this.desde,
    this.fotoPath,
  });

  /// `null` si el tipo es desconocido (una versión vieja de la app la saltea).
  static Novedad? fromJson(Map<String, Object?> json) {
    final tipo = TipoNovedad.values.asNameMap()[json['kind']];
    if (tipo == null) return null;
    final desde = json['starts_at'] as String?;
    return Novedad(
      id: json['id']! as String,
      tipo: tipo,
      fecha: DateTime.parse(json['created_at']! as String).toLocal(),
      origenId: json['origin_id'] as String?,
      nombre: json['name'] as String?,
      detalle: json['detail'] as String?,
      especieId: (json['species_id'] as num?)?.toInt(),
      cantidad: (json['amount'] as num?)?.toInt(),
      desde: desde == null ? null : DateTime.parse(desde).toLocal(),
      fotoPath: json['photo_path'] as String?,
    );
  }

  final String id;
  final TipoNovedad tipo;
  final DateTime fecha;

  /// Id de lo que la originó (SOS, adopción, lugar o evento).
  final String? origenId;

  /// Nombre de la mascota (puede faltar), del lugar o del evento.
  final String? nombre;

  /// Reencuentro: `lost` | `found`; comercio: rubro; evento: tipo.
  final String? detalle;
  final int? especieId;

  /// Días que estuvo perdida (reencuentro), que lleva perdida (perdida) o
  /// animales adoptados (adopción).
  final int? cantidad;

  /// Cuándo empieza (evento).
  final DateTime? desde;

  /// `<bucket>/<ruta>` de una foto pública.
  final String? fotoPath;

  /// Reencuentro de una mascota que se había perdido (si no, la encontró
  /// alguien y volvió con su familia).
  bool get eraPerdida => detalle != 'found';

  Categoria? get categoria =>
      tipo == TipoNovedad.comercio ? Categoria.leer(detalle) : null;

  TipoEvento? get tipoEvento => tipo == TipoNovedad.evento
      ? TipoEvento.values.asNameMap()[detalle]
      : null;

  /// Se puede reaccionar a todo menos a una perdida que se sigue buscando.
  bool get admiteReacciones => tipo != TipoNovedad.perdida;

  /// La misma regla de las noticias: sin especie es para todas.
  bool esPara(Set<int> especies) =>
      especies.isEmpty || especieId == null || especies.contains(especieId);
}

/// Totales de la comunidad (`resumen_comunidad()`): últimos 30 días, salvo
/// las perdidas que siguen buscando y los lugares verificados.
class ResumenComunidad {
  const ResumenComunidad({
    this.reencuentros = 0,
    this.adopciones = 0,
    this.perdidasActivas = 0,
    this.lugaresVerificados = 0,
  });

  factory ResumenComunidad.fromJson(Map<String, Object?> json) =>
      ResumenComunidad(
        reencuentros: (json['reencuentros'] as num?)?.toInt() ?? 0,
        adopciones: (json['adopciones'] as num?)?.toInt() ?? 0,
        perdidasActivas: (json['perdidas_activas'] as num?)?.toInt() ?? 0,
        lugaresVerificados: (json['lugares_verificados'] as num?)?.toInt() ?? 0,
      );

  final int reencuentros;
  final int adopciones;
  final int perdidasActivas;
  final int lugaresVerificados;

  /// Sin nada que contar, la tarjeta no se muestra.
  bool get vacio =>
      reencuentros + adopciones + perdidasActivas + lugaresVerificados == 0;
}

/// Reacciones fijas, sin comentarios (D87).
enum Reaccion {
  alegra('❤️'),
  festejo('🎉'),
  gracias('🙏');

  const Reaccion(this.emoji);

  final String emoji;
}

/// Totales de reacciones de una noticia o novedad y la mía (si reaccioné).
class Reacciones {
  const Reacciones({this.totales = const {}, this.mia});

  factory Reacciones.fromJson(Map<String, Object?> json) => Reacciones(
    totales: {
      for (final r in Reaccion.values)
        if ((json[r.name] as num?)?.toInt() case final n? when n > 0) r: n,
    },
    mia: Reaccion.values.asNameMap()[json['mia']],
  );

  final Map<Reaccion, int> totales;
  final Reaccion? mia;

  int cuantas(Reaccion r) => totales[r] ?? 0;

  int get total => totales.values.fold(0, (a, b) => a + b);

  /// Cómo queda al tocar [r]: si ya era la mía se quita; si no, la reemplaza.
  Reacciones tocar(Reaccion r) {
    final nuevos = {...totales};
    void sumar(Reaccion x, int d) {
      final n = (nuevos[x] ?? 0) + d;
      if (n > 0) {
        nuevos[x] = n;
      } else {
        nuevos.remove(x);
      }
    }

    if (mia case final antes?) sumar(antes, -1);
    if (mia == r) return Reacciones(totales: nuevos);
    sumar(r, 1);
    return Reacciones(totales: nuevos, mia: r);
  }
}
