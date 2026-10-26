/// Plan del comercio con sus pagos (2.2, D103): lo que devuelve `mi_plan()`.
library;

import 'comercio.dart';

DateTime? _fecha(Object? v) => v is String ? DateTime.parse(v) : null;

double _numero(Object? v) => switch (v) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s) ?? 0,
  _ => 0,
};

/// Estado de la suscripción (`subscriptions.status`).
enum EstadoPlan { activo, conAtraso, cancelado }

class PagoPlan {
  const PagoPlan({
    required this.fecha,
    required this.monto,
    required this.metodo,
    this.meses = 1,
  });

  factory PagoPlan.fromJson(Map<String, Object?> json) => PagoPlan(
    fecha: DateTime.parse(json['fecha']! as String),
    monto: _numero(json['monto']),
    metodo: json['metodo']! as String,
    meses: (json['meses'] as num?)?.toInt() ?? 1,
  );

  final DateTime fecha;
  final double monto;

  /// `transfer`, `payment_link`, `cash` u `other`.
  final String metodo;
  final int meses;
}

/// Aperturas y contactos antes y después de pasar al plan pago (D101).
class AntesYDespues {
  const AntesYDespues({
    required this.desde,
    required this.dias,
    this.aperturasAntes = 0,
    this.aperturasDespues = 0,
    this.contactosAntes = 0,
    this.contactosDespues = 0,
  });

  factory AntesYDespues.fromJson(Map<String, Object?> json) => AntesYDespues(
    desde: DateTime.parse(json['desde']! as String),
    dias: (json['dias'] as num).toInt(),
    aperturasAntes: (json['aperturas_antes'] as num?)?.toInt() ?? 0,
    aperturasDespues: (json['aperturas_despues'] as num?)?.toInt() ?? 0,
    contactosAntes: (json['contactos_antes'] as num?)?.toInt() ?? 0,
    contactosDespues: (json['contactos_despues'] as num?)?.toInt() ?? 0,
  );

  final DateTime desde;

  /// Días comparados de cada lado (hasta 30).
  final int dias;
  final int aperturasAntes;
  final int aperturasDespues;
  final int contactosAntes;
  final int contactosDespues;
}

class MiPlan {
  const MiPlan({
    required this.plan,
    this.estado,
    this.vence,
    this.precio = 0,
    this.moneda = 'UYU',
    this.fundador = false,
    this.socioFundadorHasta,
    this.pagos = const [],
    this.pedidoAbierto = false,
    this.antesYDespues,
  });

  factory MiPlan.fromJson(Map<String, Object?> json) => MiPlan(
    plan: PlanComercio.values.asNameMap()[json['plan']] ?? PlanComercio.basic,
    estado: switch (json['estado']) {
      'active' => EstadoPlan.activo,
      'past_due' => EstadoPlan.conAtraso,
      'cancelled' => EstadoPlan.cancelado,
      _ => null,
    },
    vence: _fecha(json['vence']),
    precio: _numero(json['precio']),
    moneda: json['moneda'] as String? ?? 'UYU',
    fundador: json['fundador'] as bool? ?? false,
    socioFundadorHasta: _fecha(json['socio_fundador_hasta']),
    pagos: [
      for (final p in (json['pagos'] as List?) ?? const [])
        PagoPlan.fromJson((p as Map).cast()),
    ],
    pedidoAbierto: json['pedido_abierto'] as bool? ?? false,
    antesYDespues: switch (json['antes_despues']) {
      final Map<String, Object?> m => AntesYDespues.fromJson(m),
      final Map<dynamic, dynamic> m => AntesYDespues.fromJson(m.cast()),
      _ => null,
    },
  );

  final PlanComercio plan;

  /// `null`: nunca tuvo un plan pago con suscripción (Básico o solo Socio
  /// Fundador cargado a mano).
  final EstadoPlan? estado;
  final DateTime? vence;

  /// Por mes (congelado para los Socios Fundadores).
  final double precio;
  final String moneda;
  final bool fundador;
  final DateTime? socioFundadorHasta;
  final List<PagoPlan> pagos;

  /// Ya pidió un plan desde la app y la administración todavía no lo llamó.
  final bool pedidoAbierto;
  final AntesYDespues? antesYDespues;

  bool get esPago => plan != PlanComercio.basic;

  /// Días hasta el vencimiento (negativo si ya venció), o `null`.
  int? diasParaVencer(DateTime hoy) => vence == null
      ? null
      : DateTime(
          vence!.year,
          vence!.month,
          vence!.day,
        ).difference(DateTime(hoy.year, hoy.month, hoy.day)).inDays;
}
