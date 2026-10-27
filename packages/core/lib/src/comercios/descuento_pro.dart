/// Descuentos para Pro de los comercios adheridos (2.11, D113).
library;

class DescuentoPro {
  const DescuentoPro({
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
  });

  factory DescuentoPro.fromJson(Map<String, Object?> json) => DescuentoPro(
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
  );

  final String id;
  final String titulo;
  final String? descripcion;
  final DateTime? vigenteHasta;
  final bool activo;

  /// Para el comercio: cuántos pidieron el código y cuántas veces se usó.
  final int pedidos;
  final int usados;

  /// Para la persona: de qué comercio es y su código, si ya lo pidió.
  final String? negocioId;
  final String? negocio;
  final String? direccion;
  final String? codigo;
}

/// Lo que ve el comercio al canjear un código: nunca un contacto.
typedef CanjeDescuento = ({String titulo, String? cliente});
