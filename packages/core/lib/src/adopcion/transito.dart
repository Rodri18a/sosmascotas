/// Hogares de tránsito (3.4b, D106): personas que cuidan por un tiempo a un
/// animal hasta que se adopte. Los ven solo los refugios verificados.
library;

const tamanosTransito = ['chico', 'mediano', 'grande'];

/// Mi anotación como hogar de tránsito (`foster_homes`).
class HogarTransito {
  const HogarTransito({
    required this.especies,
    this.tamanos = tamanosTransito,
    this.maxDias = 30,
    this.patio = false,
    this.otrosAnimales = false,
    this.barrio,
    this.notas,
    this.activo = true,
  });

  factory HogarTransito.fromJson(Map<String, Object?> json) => HogarTransito(
    especies: [
      for (final e in (json['species_ids'] as List?) ?? const [])
        (e as num).toInt(),
    ],
    tamanos: [for (final t in (json['sizes'] as List?) ?? const []) '$t'],
    maxDias: (json['max_days'] as num?)?.toInt() ?? 30,
    patio: json['has_yard'] == true,
    otrosAnimales: json['other_pets'] == true,
    barrio: json['neighborhood'] as String?,
    notas: json['notes'] as String?,
    activo: json['active'] != false,
  );

  final List<int> especies;
  final List<String> tamanos;
  final int maxDias;
  final bool patio;
  final bool otrosAnimales;

  /// Lo escribe la persona (nunca una dirección ni un punto en el mapa).
  final String? barrio;
  final String? notas;

  /// Pausado: no aparece para los refugios.
  final bool activo;

  Map<String, Object?> toJson() => {
    'species_ids': especies,
    'sizes': tamanos,
    'max_days': maxDias,
    'has_yard': patio,
    'other_pets': otrosAnimales,
    'neighborhood': barrio?.trim().isEmpty ?? true ? null : barrio!.trim(),
    'notes': notas?.trim().isEmpty ?? true ? null : notas!.trim(),
    'active': activo,
  };
}

/// Un hogar como lo ve un refugio verificado (`hogares_de_transito()`).
class HogarDisponible {
  const HogarDisponible({
    required this.id,
    required this.nombre,
    required this.especies,
    required this.tamanos,
    required this.maxDias,
    this.barrio,
    this.patio = false,
    this.otrosAnimales = false,
    this.notas,
    this.conAnimal = false,
    this.pedidoAbierto = false,
  });

  factory HogarDisponible.fromJson(Map<String, Object?> json) =>
      HogarDisponible(
        id: json['id']! as String,
        nombre: (json['nombre'] as String?) ?? '',
        barrio: json['barrio'] as String?,
        especies: [
          for (final e in (json['species_ids'] as List?) ?? const [])
            (e as num).toInt(),
        ],
        tamanos: [for (final t in (json['sizes'] as List?) ?? const []) '$t'],
        maxDias: (json['max_days'] as num?)?.toInt() ?? 30,
        patio: json['has_yard'] == true,
        otrosAnimales: json['other_pets'] == true,
        notas: json['notes'] as String?,
        conAnimal: json['con_animal'] == true,
        pedidoAbierto: json['pedido_abierto'] == true,
      );

  final String id;

  /// Solo el primer nombre.
  final String nombre;
  final String? barrio;
  final List<int> especies;
  final List<String> tamanos;
  final int maxDias;
  final bool patio;
  final bool otrosAnimales;
  final String? notas;

  /// Ya tiene un animal de un pedido aceptado.
  final bool conAnimal;

  /// Este refugio ya le pidió algo que sigue abierto.
  final bool pedidoAbierto;
}

enum EstadoTransito {
  nuevo('new'),
  aceptado('accepted'),
  rechazado('declined'),
  cancelado('cancelled'),
  terminado('finished');

  const EstadoTransito(this.valor);

  final String valor;

  static EstadoTransito leer(Object? valor) => values.firstWhere(
    (e) => e.valor == valor,
    orElse: () => EstadoTransito.cancelado,
  );

  bool get abierto => this == nuevo || this == aceptado;
}

/// Un pedido de un refugio a un hogar. Lo ven los dos: el hogar con el
/// nombre del refugio; el refugio con el primer nombre y el barrio del hogar.
class PedidoTransito {
  const PedidoTransito({
    required this.id,
    required this.nombreAnimal,
    required this.especieId,
    required this.dias,
    required this.estado,
    required this.creado,
    this.tamano,
    this.mensaje,
    this.refugioId,
    this.refugio,
    this.foto,
    this.hogar,
    this.barrio,
    this.conversacionId,
  });

  factory PedidoTransito.fromJson(Map<String, Object?> json) => PedidoTransito(
    id: json['id']! as String,
    nombreAnimal: (json['animal_name'] as String?) ?? '',
    especieId: (json['species_id']! as num).toInt(),
    tamano: json['size'] as String?,
    dias: (json['days']! as num).toInt(),
    mensaje: json['message'] as String?,
    estado: EstadoTransito.leer(json['status']),
    creado: DateTime.parse(json['created_at']! as String),
    refugioId: json['shelter_id'] as String?,
    refugio: json['shelter_name'] as String?,
    foto: json['photo'] as String?,
    hogar: json['hogar'] as String?,
    barrio: json['barrio'] as String?,
    conversacionId: json['conversation_id'] as String?,
  );

  final String id;
  final String nombreAnimal;
  final int especieId;
  final String? tamano;
  final int dias;
  final String? mensaje;
  final EstadoTransito estado;
  final DateTime creado;
  final String? refugioId;
  final String? refugio;

  /// Primera foto de la publicación de adopción, si el pedido viene de una.
  final String? foto;
  final String? hogar;
  final String? barrio;

  /// El chat con el refugio, una vez aceptado.
  final String? conversacionId;
}
