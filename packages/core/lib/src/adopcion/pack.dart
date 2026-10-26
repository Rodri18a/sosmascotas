/// Pack adopción (3.4b, D107): beneficios de comercios verificados para
/// quien adopta por la app.
library;

class BeneficioAdopcion {
  const BeneficioAdopcion({
    required this.id,
    required this.titulo,
    this.descripcion,
    this.vigenteHasta,
    this.activo = true,
    this.pedidos = 0,
    this.usados = 0,
    this.negocioId,
    this.negocio,
    this.direccion,
    this.codigo,
    this.usado = false,
  });

  factory BeneficioAdopcion.fromJson(Map<String, Object?> json) =>
      BeneficioAdopcion(
        id: json['id']! as String,
        titulo: json['title']! as String,
        descripcion: json['description'] as String?,
        vigenteHasta: switch (json['valid_until']) {
          final String f => DateTime.parse(f),
          _ => null,
        },
        activo: json['active'] != false,
        pedidos: (json['pedidos'] as num?)?.toInt() ?? 0,
        usados: (json['usados'] as num?)?.toInt() ?? 0,
        negocioId: json['business_id'] as String?,
        negocio: json['business_name'] as String?,
        direccion: json['address'] as String?,
        codigo: json['code'] as String?,
        usado: json['used'] == true,
      );

  final String id;
  final String titulo;
  final String? descripcion;
  final DateTime? vigenteHasta;
  final bool activo;

  /// Para el comercio: cuántos pidieron el código y cuántos lo usaron.
  final int pedidos;
  final int usados;

  /// Para quien adoptó: de qué comercio es y su código, si ya lo pidió.
  final String? negocioId;
  final String? negocio;
  final String? direccion;
  final String? codigo;
  final bool usado;
}

/// Lo que ve el comercio al canjear un código: nunca un contacto.
typedef CanjeBeneficio = ({String titulo, String? cliente, String? animal});
