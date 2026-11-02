/// Estadísticas del comercio (2.3, D101): lo que devuelve
/// `estadisticas_negocio()`. Solo cantidades, nunca quién fue.
library;

/// Métricas que muestra la app (nombre en `daily_stats`).
abstract final class MetricasComercio {
  static const aperturas = 'place_open';
  static const personas = 'place_open_people';
  static const contactos = 'contactos';
  static const favoritos = 'favorite_add';
  static const visitas = 'place_visit';
  static const chats = 'chat_start';
  static const catalogo = 'catalog_open';
  static const consultasCatalogo = 'catalog_ask';
  static const consultasServicios = 'service_ask';
  static const pedidos = 'order_create';
  static const pagina = 'business_page_open';
  static const resenas = 'review_create';

  /// Promociones en el muro (D136).
  static const promoVistas = 'promo_view';
  static const promoToques = 'promo_click';

  /// Clics de la ficha: `place_click:<tipo>`.
  static const clic = 'place_click:';
}

class MesEstadisticas {
  const MesEstadisticas({required this.mes, this.metricas = const {}});

  factory MesEstadisticas.fromJson(Map<String, Object?> json) =>
      MesEstadisticas(
        mes: DateTime.parse(json['mes']! as String),
        metricas: {
          for (final MapEntry(:key, :value)
              in ((json['metricas'] as Map?) ?? const {}).entries)
            key as String: (value as num).toInt(),
        },
      );

  /// Primer día del mes.
  final DateTime mes;
  final Map<String, int> metricas;

  int operator [](String metrica) => metricas[metrica] ?? 0;

  /// Clics de la ficha por tipo (whatsapp, llamar, como_llegar…).
  Map<String, int> get clics => {
    for (final MapEntry(:key, :value) in metricas.entries)
      if (key.startsWith(MetricasComercio.clic))
        key.substring(MetricasComercio.clic.length): value,
  };
}

class SemanaEstadisticas {
  const SemanaEstadisticas({
    required this.semana,
    this.aperturas = 0,
    this.contactos = 0,
  });

  factory SemanaEstadisticas.fromJson(Map<String, Object?> json) =>
      SemanaEstadisticas(
        semana: DateTime.parse(json['semana']! as String),
        aperturas: (json['aperturas'] as num?)?.toInt() ?? 0,
        contactos: (json['contactos'] as num?)?.toInt() ?? 0,
      );

  /// Lunes de la semana.
  final DateTime semana;
  final int aperturas;
  final int contactos;
}

class EstadisticasNegocio {
  const EstadisticasNegocio({
    required this.completo,
    this.meses = const [],
    this.semanas = const [],
  });

  factory EstadisticasNegocio.fromJson(Map<String, Object?> json) =>
      EstadisticasNegocio(
        completo: json['completo'] as bool? ?? false,
        meses: [
          for (final m in (json['meses'] as List?) ?? const [])
            MesEstadisticas.fromJson((m as Map).cast()),
        ],
        semanas: [
          for (final s in (json['semanas'] as List?) ?? const [])
            SemanaEstadisticas.fromJson((s as Map).cast()),
        ],
      );

  /// `false` con el plan Básico: solo aperturas y contactos de dos meses.
  final bool completo;

  /// Del más viejo al actual (el último es el mes en curso).
  final List<MesEstadisticas> meses;
  final List<SemanaEstadisticas> semanas;

  MesEstadisticas? get actual => meses.lastOrNull;
  MesEstadisticas? get anterior =>
      meses.length < 2 ? null : meses[meses.length - 2];

  bool get sinDatos => meses.every((m) => m.metricas.isEmpty);

  /// Cambio de [metrica] entre el mes anterior y el actual.
  Variacion variacion(String metrica) =>
      Variacion.entre(anterior?[metrica] ?? 0, actual?[metrica] ?? 0);
}

/// Cómo cambió una cantidad: sube, baja, igual o sin base para comparar.
class Variacion {
  const Variacion._(this.antes, this.ahora);

  factory Variacion.entre(int antes, int ahora) => Variacion._(antes, ahora);

  final int antes;
  final int ahora;

  /// `null` si antes no hubo nada (no se puede decir "x % más").
  int? get porcentaje =>
      antes == 0 ? null : (((ahora - antes) / antes) * 100).round();

  bool get sube => ahora > antes;
  bool get baja => ahora < antes;
}
