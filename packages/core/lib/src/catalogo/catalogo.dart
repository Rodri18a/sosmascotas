/// Catálogo de un comercio y pedidos (2.5 y 3.2, D85).
library;

double? _numero(Object? v) => switch (v) {
  final num n => n.toDouble(),
  final String s => double.tryParse(s),
  _ => null,
};

/// Precio en pesos uruguayos: "$ 1.780" o "$ 89,50".
String formatoPrecio(double precio) {
  final centavos = (precio * 100).round();
  final enteros = (centavos ~/ 100).toString();
  final conPuntos = StringBuffer();
  for (var i = 0; i < enteros.length; i++) {
    if (i > 0 && (enteros.length - i) % 3 == 0) conPuntos.write('.');
    conPuntos.write(enteros[i]);
  }
  final resto = centavos % 100;
  return resto == 0
      ? '\$ $conPuntos'
      : '\$ $conPuntos,${resto.toString().padLeft(2, '0')}';
}

/// Un producto o servicio del catálogo.
class Producto {
  const Producto({
    required this.id,
    required this.nombre,
    this.descripcion,
    this.precio,
    this.foto,
    this.especieIds = const [],
    this.disponible = true,
    this.orden = 0,
  });

  factory Producto.fromJson(Map<String, Object?> json) => Producto(
    id: json['id']! as String,
    nombre: json['name']! as String,
    descripcion: json['description'] as String?,
    precio: _numero(json['price']),
    foto: json['photo_path'] as String?,
    especieIds: [
      for (final e in (json['species_ids'] as List?) ?? const [])
        (e as num).toInt(),
    ],
    disponible: json['available'] as bool? ?? true,
    orden: (json['sort'] as num?)?.toInt() ?? 0,
  );

  final String id;
  final String nombre;
  final String? descripcion;

  /// `null`: no tiene precio publicado, solo se puede "Consultar".
  final double? precio;

  /// Ruta en el bucket público de fotos del comercio.
  final String? foto;
  final List<int> especieIds;
  final bool disponible;
  final int orden;

  bool get soloConsultar => precio == null;

  Map<String, Object?> toJson() => {
    'id': id.isEmpty ? null : id,
    'name': nombre,
    'description': descripcion,
    'price': precio,
    'photo_path': foto,
    'species_ids': especieIds,
    'available': disponible,
    'sort': orden,
  };
}

/// Lo que se va eligiendo antes de pedir: id del producto → cantidad.
class Carrito {
  const Carrito([this.cantidades = const {}]);

  static const maximoPorProducto = 99;
  static const maximoProductos = 30;

  final Map<String, int> cantidades;

  bool get vacio => cantidades.isEmpty;

  int cantidad(String productoId) => cantidades[productoId] ?? 0;

  int get unidades => cantidades.values.fold(0, (a, b) => a + b);

  /// Suma uno (si tiene precio y no se pasa de los límites).
  Carrito sumar(Producto p) {
    if (p.soloConsultar || !p.disponible) return this;
    final actual = cantidad(p.id);
    if (actual >= maximoPorProducto) return this;
    if (actual == 0 && cantidades.length >= maximoProductos) return this;
    return Carrito({...cantidades, p.id: actual + 1});
  }

  Carrito restar(String productoId) {
    final actual = cantidad(productoId);
    if (actual <= 1) return Carrito({...cantidades}..remove(productoId));
    return Carrito({...cantidades, productoId: actual - 1});
  }

  /// Total con los precios de [productos] (lo que se muestra; el que vale lo
  /// calcula la base).
  double total(Iterable<Producto> productos) {
    final precios = {for (final p in productos) p.id: p.precio ?? 0};
    return cantidades.entries.fold(
      0,
      (suma, e) => suma + (precios[e.key] ?? 0) * e.value,
    );
  }

  /// Para `hacer_pedido()`.
  List<Map<String, Object?>> paraPedir() => [
    for (final e in cantidades.entries) {'id': e.key, 'qty': e.value},
  ];
}

enum EstadoPedido {
  nuevo('new'),
  preparando('preparing'),
  listo('ready'),
  entregado('delivered'),
  cancelado('cancelled');

  const EstadoPedido(this.base);

  final String base;

  static EstadoPedido desdeBase(Object? v) =>
      values.firstWhere((e) => e.base == v, orElse: () => nuevo);

  /// El paso que sigue para el comercio (`null` si ya terminó).
  EstadoPedido? get siguiente => switch (this) {
    nuevo => preparando,
    preparando => listo,
    listo => entregado,
    entregado || cancelado => null,
  };

  bool get abierto => this != entregado && this != cancelado;
}

class RenglonPedido {
  const RenglonPedido({
    required this.nombre,
    required this.precio,
    required this.cantidad,
  });

  factory RenglonPedido.fromJson(Map<String, Object?> json) => RenglonPedido(
    nombre: json['name']! as String,
    precio: _numero(json['unit_price']) ?? 0,
    cantidad: (json['qty']! as num).toInt(),
  );

  final String nombre;
  final double precio;
  final int cantidad;

  double get subtotal => precio * cantidad;
}

class Pedido {
  const Pedido({
    required this.id,
    required this.numero,
    required this.estado,
    required this.total,
    required this.creado,
    required this.actualizado,
    this.renglones = const [],
    this.negocioId,
    this.negocio,
    this.cliente,
    this.nota,
  });

  factory Pedido.fromJson(Map<String, Object?> json) => Pedido(
    id: json['id']! as String,
    numero: (json['number']! as num).toInt(),
    estado: EstadoPedido.desdeBase(json['status']),
    total: _numero(json['total']) ?? 0,
    creado: DateTime.parse(json['created_at']! as String).toLocal(),
    actualizado: DateTime.parse(
      (json['updated_at'] ?? json['created_at'])! as String,
    ).toLocal(),
    renglones: [
      for (final r in (json['items'] as List?) ?? const [])
        RenglonPedido.fromJson((r as Map).cast<String, Object?>()),
    ],
    negocioId: json['business_id'] as String?,
    negocio: json['business_name'] as String?,
    cliente: json['cliente'] as String?,
    nota: json['note'] as String?,
  );

  final String id;
  final int numero;
  final EstadoPedido estado;
  final double total;
  final DateTime creado;
  final DateTime actualizado;
  final List<RenglonPedido> renglones;

  /// En "Mis pedidos": a qué comercio.
  final String? negocioId;
  final String? negocio;

  /// Para el comercio: el primer nombre de quien pidió.
  final String? cliente;
  final String? nota;
}
