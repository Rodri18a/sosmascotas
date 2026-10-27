/// Plan de la persona (2.1, D111): lo que devuelve `mi_plan_usuario()`.
library;

import '../comercios/mi_plan.dart' show EstadoPlan;
import 'perfil.dart';

DateTime? _fecha(Object? v) => v is String ? DateTime.parse(v) : null;

Plan _plan(Object? v) => Plan.values.asNameMap()[v] ?? Plan.free;

class MiPlanUsuario {
  const MiPlanUsuario({
    required this.plan,
    Plan? efectivo,
    this.porHogar = false,
    this.estado,
    this.vence,
    this.prueba = false,
    this.precio = 0,
    this.mascotas = 0,
    this.limiteMascotas,
    this.pruebaFamiliaUsada = false,
    this.pedidoAbierto,
  }) : efectivo = efectivo ?? plan;

  factory MiPlanUsuario.fromJson(Map<String, Object?> json) => MiPlanUsuario(
    plan: _plan(json['plan']),
    efectivo: _plan(json['efectivo']),
    porHogar: json['por_hogar'] as bool? ?? false,
    estado: switch (json['estado']) {
      'active' => EstadoPlan.activo,
      'past_due' => EstadoPlan.conAtraso,
      'cancelled' => EstadoPlan.cancelado,
      _ => null,
    },
    vence: _fecha(json['vence']),
    prueba: json['prueba'] as bool? ?? false,
    precio: switch (json['precio']) {
      final num n => n.toDouble(),
      final String s => double.tryParse(s) ?? 0,
      _ => 0,
    },
    mascotas: (json['mascotas'] as num?)?.toInt() ?? 0,
    limiteMascotas: (json['limite_mascotas'] as num?)?.toInt(),
    pruebaFamiliaUsada: json['prueba_familia_usada'] as bool? ?? false,
    pedidoAbierto: switch (json['pedido_abierto']) {
      final String p => _plan(p),
      _ => null,
    },
  );

  /// El plan propio (`profiles.plan`).
  final Plan plan;

  /// El que vale en la práctica: Familia también por integrar un hogar Familia.
  final Plan efectivo;

  /// Tiene Familia por ser integrante del hogar de otra persona.
  final bool porHogar;

  /// `null`: nunca tuvo un plan pago.
  final EstadoPlan? estado;
  final DateTime? vence;

  /// Es la prueba gratis de 30 días de Familia.
  final bool prueba;

  /// Por mes.
  final double precio;
  final int mascotas;

  /// Tope de mascotas propias (Gratis: 5), o `null` si no tiene.
  final int? limiteMascotas;
  final bool pruebaFamiliaUsada;

  /// Plan que pidió desde la app y la administración todavía no activó.
  final Plan? pedidoAbierto;

  bool get esPro => efectivo != Plan.free;

  /// ¿Puede sumar otra mascota?
  bool get puedeSumarMascota =>
      limiteMascotas == null || mascotas < limiteMascotas!;
}
