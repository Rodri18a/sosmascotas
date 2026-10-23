import '../mapa/mapa.dart';

/// Estado de un pedido de chapita (`tag_orders.status`, 1.8b.4, D98).
enum EstadoPedidoChapita {
  /// Pedida: la administración todavía no la mandó.
  nuevo('new'),

  /// En camino a la veterinaria (ya tiene código asignado).
  enviado('sent'),

  /// Llegó a la veterinaria: lista para retirar.
  listo('ready'),

  /// Entregada: la chapita quedó vinculada a la mascota.
  entregado('delivered'),
  cancelado('cancelled');

  const EstadoPedidoChapita(this.valor);

  final String valor;

  static EstadoPedidoChapita leer(Object? valor) =>
      values.where((e) => e.valor == valor).firstOrNull ?? nuevo;

  bool get abierto => this == nuevo || this == enviado || this == listo;
}

/// Largo máximo del texto grabado en la chapita.
const maximoGrabado = 20;

/// Pedidos abiertos que puede tener una cuenta a la vez.
const maximoPedidosChapitaAbiertos = 3;

/// Texto a grabar: sin espacios de más y cortado; sin texto, el nombre de la
/// mascota (la base hace lo mismo).
String textoGrabado(String? texto, String nombreMascota) {
  final limpio = (texto ?? '').trim().replaceAll(RegExp(r'\s+'), ' ');
  final elegido = limpio.isEmpty ? nombreMascota.trim() : limpio;
  return elegido.length <= maximoGrabado
      ? elegido
      : elegido.substring(0, maximoGrabado).trimRight();
}

/// Un pedido de chapita con retiro en la veterinaria. El dueño lo ve con los
/// datos de la veterinaria; la veterinaria, con el primer nombre de quien lo
/// pidió ([cliente]) y nada de contacto.
class PedidoChapita {
  const PedidoChapita({
    required this.id,
    required this.numero,
    required this.nombreMascota,
    required this.grabado,
    required this.estado,
    required this.creado,
    this.mascotaId,
    this.negocioId,
    this.negocioNombre,
    this.negocioDireccion,
    this.cliente,
    this.codigo,
    this.actualizado,
  });

  factory PedidoChapita.fromJson(Map<String, Object?> json) => PedidoChapita(
    id: json['id']! as String,
    numero: (json['number']! as num).toInt(),
    mascotaId: json['pet_id'] as String?,
    nombreMascota: json['pet_name']! as String,
    negocioId: json['business_id'] as String?,
    negocioNombre: json['business_name'] as String?,
    negocioDireccion: json['business_address'] as String?,
    cliente: switch (json['cliente']) {
      final String c when c.trim().isNotEmpty => c.trim(),
      _ => null,
    },
    grabado: json['engraving']! as String,
    estado: EstadoPedidoChapita.leer(json['status']),
    codigo: json['code'] as String?,
    creado: DateTime.parse(json['created_at']! as String),
    actualizado: switch (json['updated_at']) {
      final String f => DateTime.parse(f),
      _ => null,
    },
  );

  final String id;
  final int numero;
  final String? mascotaId;
  final String nombreMascota;
  final String? negocioId;
  final String? negocioNombre;
  final String? negocioDireccion;
  final String? cliente;
  final String grabado;
  final EstadoPedidoChapita estado;

  /// Código de la chapita: el dueño lo ve al recibirla; la veterinaria, desde
  /// que se la mandan (para encontrarla).
  final String? codigo;
  final DateTime creado;
  final DateTime? actualizado;
}

/// Veterinaria que es punto de retiro de chapitas.
class PuntoRetiro {
  const PuntoRetiro({
    required this.id,
    required this.nombre,
    this.direccion,
    this.punto,
  });

  factory PuntoRetiro.fromJson(Map<String, Object?> json) => PuntoRetiro(
    id: json['id']! as String,
    nombre: json['name']! as String,
    direccion: json['address'] as String?,
    punto: switch ((json['lat'], json['lng'])) {
      (final num lat, final num lng) => Punto(lat.toDouble(), lng.toDouble()),
      _ => null,
    },
  );

  final String id;
  final String nombre;
  final String? direccion;
  final Punto? punto;
}

/// Puntos de retiro con "mi veterinaria" primero (si es punto de retiro);
/// los demás quedan en el orden de la base (los más cercanos primero).
List<PuntoRetiro> conMiVeterinariaPrimero(
  List<PuntoRetiro> puntos,
  String? miVeterinariaId,
) {
  if (miVeterinariaId == null) return puntos;
  final mia = puntos.where((p) => p.id == miVeterinariaId).toList();
  return [...mia, ...puntos.where((p) => p.id != miVeterinariaId)];
}
