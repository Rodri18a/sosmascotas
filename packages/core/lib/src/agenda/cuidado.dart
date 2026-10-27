/// Contratar paseadores, hoteles y cuidadores (3.3, D115): lo que devuelven
/// `condiciones_cuidados()`, `mis_cuidados()`, `cuidados_del_negocio()` y
/// `mis_ajustes_cuidados()`.
library;

DateTime _dia(Object? v) => DateTime.parse(v! as String);

String _fecha(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}'
    '-${d.day.toString().padLeft(2, '0')}';

enum TipoCuidado {
  paseo('walk'),
  guarderia('daycare'),
  estadia('boarding'),
  visitas('home_visit');

  const TipoCuidado(this.base);

  final String base;

  static TipoCuidado? desdeBase(Object? v) =>
      values.where((e) => e.base == v).firstOrNull;

  /// Guardería y estadía ocupan lugar (el cupo por día del prestador).
  bool get ocupaLugar => this == guarderia || this == estadia;
}

enum FranjaCuidado {
  manana('morning'),
  tarde('afternoon'),
  noche('evening');

  const FranjaCuidado(this.base);

  final String base;

  static FranjaCuidado? desdeBase(Object? v) =>
      values.where((e) => e.base == v).firstOrNull;
}

enum EstadoCuidado {
  pendiente('pending'),
  aceptado('accepted'),
  rechazado('rejected'),
  cancelado('cancelled'),
  terminado('done');

  const EstadoCuidado(this.base);

  final String base;

  static EstadoCuidado desdeBase(Object? v) =>
      values.firstWhere((e) => e.base == v, orElse: () => pendiente);

  bool get vigente => this == pendiente || this == aceptado;
}

class Cuidado {
  const Cuidado({
    required this.id,
    required this.tipo,
    required this.desde,
    required this.hasta,
    required this.estado,
    this.mascotas = const [],
    this.negocioId,
    this.negocio,
    this.cliente,
    this.franja,
    this.canceladoPor,
    this.nota,
    this.chatId,
  });

  factory Cuidado.fromJson(Map<String, Object?> json) => Cuidado(
    id: json['id']! as String,
    negocioId: json['business_id'] as String?,
    negocio: json['business_name'] as String?,
    cliente: json['cliente'] as String?,
    mascotas: [for (final m in (json['pets'] as List?) ?? const []) '$m'],
    tipo: TipoCuidado.desdeBase(json['kind']) ?? TipoCuidado.paseo,
    desde: _dia(json['start_day']),
    hasta: _dia(json['end_day']),
    franja: FranjaCuidado.desdeBase(json['time_slot']),
    estado: EstadoCuidado.desdeBase(json['status']),
    canceladoPor: json['cancelled_by'] as String?,
    nota: json['note'] as String?,
    chatId: json['conversation_id'] as String?,
  );

  final String id;

  /// Solo en «Mis cuidados».
  final String? negocioId;
  final String? negocio;

  /// Solo para el prestador: el primer nombre de quien pidió.
  final String? cliente;

  /// Nombres (para el prestador, con la especie entre paréntesis).
  final List<String> mascotas;
  final TipoCuidado tipo;

  /// Días (a medianoche, sin hora).
  final DateTime desde;
  final DateTime hasta;
  final FranjaCuidado? franja;
  final EstadoCuidado estado;

  /// `cliente` o `negocio`.
  final String? canceladoPor;
  final String? nota;

  /// El chat, una vez aceptado.
  final String? chatId;

  int get dias => hasta.difference(desde).inDays + 1;

  /// Quien pidió cancela un pendiente siempre y un aceptado hasta el día
  /// anterior (D115; lo exige también la base).
  bool puedeCancelar(DateTime hoy) =>
      estado == EstadoCuidado.pendiente ||
      (estado == EstadoCuidado.aceptado &&
          desde.isAfter(DateTime(hoy.year, hoy.month, hoy.day)));

  /// El prestador lo marca terminado desde el primer día.
  bool puedeTerminar(DateTime hoy) =>
      estado == EstadoCuidado.aceptado &&
      !desde.isAfter(DateTime(hoy.year, hoy.month, hoy.day));
}

/// Lo que se puede pedir a un prestador (`null` si no ofrece nada).
class CondicionesCuidados {
  const CondicionesCuidados({
    required this.tipos,
    this.diasAdelante = 60,
    this.maximoDias = 15,
    this.condiciones,
    this.completos = const {},
  });

  factory CondicionesCuidados.fromJson(Map<String, Object?> json) =>
      CondicionesCuidados(
        tipos: [
          for (final k in (json['kinds'] as List?) ?? const [])
            ?TipoCuidado.desdeBase(k),
        ],
        diasAdelante: (json['days_ahead'] as num?)?.toInt() ?? 60,
        maximoDias: (json['max_days'] as num?)?.toInt() ?? 15,
        condiciones: json['conditions'] as String?,
        completos: {
          for (final d in (json['completos'] as List?) ?? const []) _dia(d),
        },
      );

  final List<TipoCuidado> tipos;
  final int diasAdelante;
  final int maximoDias;
  final String? condiciones;

  /// Días sin lugar para guardería y estadía.
  final Set<DateTime> completos;

  /// Por qué no se puede pedir de [desde] a [hasta] (`null`: se puede).
  ProblemaFechas? revisar(
    TipoCuidado tipo,
    DateTime desde,
    DateTime hasta,
    DateTime hoy,
  ) {
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);
    if (desde.isBefore(inicio) || hasta.isBefore(desde)) {
      return ProblemaFechas.fueraDeRango;
    }
    if (desde.difference(inicio).inDays > diasAdelante) {
      return ProblemaFechas.fueraDeRango;
    }
    if (hasta.difference(desde).inDays + 1 > maximoDias) {
      return ProblemaFechas.muyLargo;
    }
    if (tipo.ocupaLugar) {
      for (
        var d = desde;
        !d.isAfter(hasta);
        d = DateTime(d.year, d.month, d.day + 1)
      ) {
        if (completos.contains(d)) return ProblemaFechas.sinLugar;
      }
    }
    return null;
  }
}

enum ProblemaFechas { fueraDeRango, muyLargo, sinLugar }

/// Configuración del prestador (`mis_ajustes_cuidados()`).
class AjustesCuidados {
  const AjustesCuidados({
    this.tipos = const {},
    this.cupo = 5,
    this.diasAdelante = 60,
    this.maximoDias = 15,
    this.condiciones,
  });

  factory AjustesCuidados.fromJson(Map<String, Object?> json) =>
      AjustesCuidados(
        tipos: {
          for (final k in (json['kinds'] as List?) ?? const [])
            ?TipoCuidado.desdeBase(k),
        },
        cupo: (json['capacity'] as num?)?.toInt() ?? 5,
        diasAdelante: (json['days_ahead'] as num?)?.toInt() ?? 60,
        maximoDias: (json['max_days'] as num?)?.toInt() ?? 15,
        condiciones: json['conditions'] as String?,
      );

  final Set<TipoCuidado> tipos;

  /// Mascotas por día en guardería y estadía.
  final int cupo;
  final int diasAdelante;
  final int maximoDias;
  final String? condiciones;

  AjustesCuidados copyWith({
    Set<TipoCuidado>? tipos,
    int? cupo,
    int? diasAdelante,
    int? maximoDias,
    String? condiciones,
  }) => AjustesCuidados(
    tipos: tipos ?? this.tipos,
    cupo: cupo ?? this.cupo,
    diasAdelante: diasAdelante ?? this.diasAdelante,
    maximoDias: maximoDias ?? this.maximoDias,
    condiciones: condiciones ?? this.condiciones,
  );

  Map<String, Object?> toJson() => {
    'kinds': [for (final k in tipos) k.base],
    'capacity': cupo,
    'days_ahead': diasAdelante,
    'max_days': maximoDias,
    'conditions': condiciones,
  };
}

/// `AAAA-MM-DD` para mandar un día a la base.
String fechaCuidado(DateTime d) => _fecha(d);
