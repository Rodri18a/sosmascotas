/// Agenda de turnos (3.1, D104): lo que devuelven `condiciones_agenda()`,
/// `horarios_libres()`, `mis_turnos()`, `turnos_del_negocio()` y `mi_agenda()`.
library;

double? _numero(Object? v) => switch (v) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s),
  _ => null,
};

DateTime _momento(Object? v) => DateTime.parse(v! as String).toLocal();

enum EstadoTurno {
  pendiente('pending'),
  confirmado('confirmed'),
  rechazado('rejected'),
  cancelado('cancelled'),
  atendido('done');

  const EstadoTurno(this.base);

  final String base;

  static EstadoTurno desdeBase(Object? v) =>
      values.firstWhere((e) => e.base == v, orElse: () => pendiente);

  /// Pendiente o confirmado: todavía ocupa el horario.
  bool get vigente => this == pendiente || this == confirmado;
}

/// Quien reservó cancela hasta 2 horas antes (D104; lo exige también la base).
const anticipacionParaCancelar = Duration(hours: 2);

class Turno {
  const Turno({
    required this.id,
    required this.inicio,
    required this.fin,
    required this.estado,
    this.negocioId,
    this.negocio,
    this.cliente,
    this.mascota,
    this.especie,
    this.servicio,
    this.canceladoPor,
    this.nota,
  });

  factory Turno.fromJson(Map<String, Object?> json) => Turno(
    id: json['id']! as String,
    negocioId: json['business_id'] as String?,
    negocio: json['business_name'] as String?,
    cliente: json['cliente'] as String?,
    mascota: json['pet_name'] as String?,
    especie: json['especie'] as String?,
    servicio: json['service_name'] as String?,
    inicio: _momento(json['starts_at']),
    fin: _momento(json['ends_at']),
    estado: EstadoTurno.desdeBase(json['status']),
    canceladoPor: json['cancelled_by'] as String?,
    nota: json['note'] as String?,
  );

  final String id;

  /// Solo en «Mis turnos».
  final String? negocioId;
  final String? negocio;

  /// Solo para el comercio: el primer nombre de quien reservó.
  final String? cliente;
  final String? mascota;
  final String? especie;
  final String? servicio;
  final DateTime inicio;
  final DateTime fin;
  final EstadoTurno estado;

  /// `cliente` o `negocio`.
  final String? canceladoPor;
  final String? nota;

  bool puedeCancelar(DateTime ahora) =>
      estado.vigente &&
      !inicio.difference(ahora).isNegative &&
      inicio.difference(ahora) >= anticipacionParaCancelar;

  /// El comercio lo marca como atendido cuando ya empezó.
  bool puedeMarcarAtendido(DateTime ahora) =>
      estado == EstadoTurno.confirmado && !inicio.isAfter(ahora);
}

class HorarioLibre {
  const HorarioLibre({required this.inicio, required this.fin});

  factory HorarioLibre.fromJson(Map<String, Object?> json) => HorarioLibre(
    inicio: _momento(json['inicio']),
    fin: _momento(json['fin']),
  );

  final DateTime inicio;
  final DateTime fin;
}

class ServicioReservable {
  const ServicioReservable({
    required this.id,
    required this.nombre,
    required this.duracionMinutos,
    this.precio,
    this.desde = false,
  });

  factory ServicioReservable.fromJson(Map<String, Object?> json) =>
      ServicioReservable(
        id: json['id']! as String,
        nombre: json['name']! as String,
        duracionMinutos: (json['duration_min'] as num?)?.toInt() ?? 30,
        precio: _numero(json['price']),
        desde: json['price_from'] as bool? ?? false,
      );

  final String id;
  final String nombre;
  final int duracionMinutos;
  final double? precio;
  final bool desde;
}

/// Lo que se puede reservar en un comercio (`null` si no toma turnos).
class CondicionesAgenda {
  const CondicionesAgenda({
    required this.minutosPorTurno,
    required this.diasAdelante,
    this.servicios = const [],
    this.bloqueados = const {},
  });

  factory CondicionesAgenda.fromJson(Map<String, Object?> json) =>
      CondicionesAgenda(
        minutosPorTurno: (json['slot_min'] as num?)?.toInt() ?? 30,
        diasAdelante: (json['days_ahead'] as num?)?.toInt() ?? 30,
        servicios: [
          for (final s in (json['servicios'] as List?) ?? const [])
            ServicioReservable.fromJson((s as Map).cast()),
        ],
        bloqueados: {
          for (final d in (json['bloqueados'] as List?) ?? const [])
            DateTime.parse(d as String),
        },
      );

  final int minutosPorTurno;
  final int diasAdelante;
  final List<ServicioReservable> servicios;

  /// Días sin turnos (a medianoche).
  final Set<DateTime> bloqueados;

  /// Días que se pueden elegir, desde [hoy], sin los bloqueados.
  List<DateTime> diasReservables(DateTime hoy) {
    final inicio = DateTime(hoy.year, hoy.month, hoy.day);
    return [
      for (var i = 0; i <= diasAdelante; i++)
        if (DateTime(inicio.year, inicio.month, inicio.day + i) case final d
            when !bloqueados.contains(d))
          d,
    ];
  }
}

/// Configuración de la agenda para el dueño (`mi_agenda()`).
class AjustesAgenda {
  const AjustesAgenda({
    this.configurada = false,
    this.minutosPorTurno = 30,
    this.aLaVez = 1,
    this.anticipacionMinutos = 120,
    this.diasAdelante = 30,
    this.servicioIds,
    this.bloqueados = const [],
  });

  factory AjustesAgenda.fromJson(Map<String, Object?> json) => AjustesAgenda(
    configurada: json['configurada'] as bool? ?? false,
    minutosPorTurno: (json['slot_min'] as num?)?.toInt() ?? 30,
    aLaVez: (json['capacity'] as num?)?.toInt() ?? 1,
    anticipacionMinutos: (json['notice_min'] as num?)?.toInt() ?? 120,
    diasAdelante: (json['days_ahead'] as num?)?.toInt() ?? 30,
    servicioIds: switch (json['service_ids']) {
      final List<Object?> l => [for (final s in l) s! as String],
      _ => null,
    },
    bloqueados: [
      for (final b in (json['bloqueados'] as List?) ?? const [])
        (
          dia: DateTime.parse((b as Map)['day'] as String),
          nota: b['note'] as String?,
        ),
    ],
  );

  final bool configurada;
  final int minutosPorTurno;

  /// Cuántos turnos atiende al mismo tiempo.
  final int aLaVez;
  final int anticipacionMinutos;
  final int diasAdelante;

  /// `null`: se reservan todos los servicios disponibles.
  final List<String>? servicioIds;
  final List<({DateTime dia, String? nota})> bloqueados;

  AjustesAgenda copyWith({
    int? minutosPorTurno,
    int? aLaVez,
    int? anticipacionMinutos,
    int? diasAdelante,
  }) => AjustesAgenda(
    configurada: configurada,
    minutosPorTurno: minutosPorTurno ?? this.minutosPorTurno,
    aLaVez: aLaVez ?? this.aLaVez,
    anticipacionMinutos: anticipacionMinutos ?? this.anticipacionMinutos,
    diasAdelante: diasAdelante ?? this.diasAdelante,
    servicioIds: servicioIds,
    bloqueados: bloqueados,
  );

  Map<String, Object?> toJson() => {
    'slot_min': minutosPorTurno,
    'capacity': aLaVez,
    'notice_min': anticipacionMinutos,
    'days_ahead': diasAdelante,
    'service_ids': servicioIds,
  };
}
