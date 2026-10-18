/// Una mascota socia de la veterinaria (`mis_socios()`, 2.6, D81): lo
/// mínimo para cuidarla. Nunca el teléfono ni el id del dueño.
class Socio {
  const Socio({
    required this.mascotaId,
    required this.nombre,
    required this.especieId,
    this.duenio,
    this.proximo,
    this.proximoQue,
  });

  factory Socio.fromJson(Map<String, Object?> json) => Socio(
    mascotaId: json['pet_id']! as String,
    nombre: json['nombre']! as String,
    especieId: (json['especie']! as num).toInt(),
    duenio: switch (json['duenio']) {
      final String d when d.isNotEmpty => d,
      _ => null,
    },
    proximo: switch (json['proximo']) {
      final String f => DateTime.parse(f),
      _ => null,
    },
    proximoQue: json['proximo_que'] as String?,
  );

  final String mascotaId;
  final String nombre;
  final int especieId;

  /// Primer nombre del dueño.
  final String? duenio;

  /// Próximo control de la libreta (vacuna, desparasitación, control).
  final DateTime? proximo;
  final String? proximoQue;

  /// ¿El próximo control vence dentro de [dias] desde [hoy]?
  bool vencePronto(DateTime hoy, {int dias = 30}) {
    final p = proximo;
    if (p == null) return false;
    final hoySolo = DateTime(hoy.year, hoy.month, hoy.day);
    return !p.isBefore(hoySolo) && p.difference(hoySolo).inDays <= dias;
  }
}

/// Cuántas mascotas buscan veterinaria cerca, por especie
/// (`demanda_de_veterinaria()`): solo grupos de 5 o más, anónimos.
class Demanda {
  const Demanda({required this.especieId, required this.cantidad});

  factory Demanda.fromJson(Map<String, Object?> json) => Demanda(
    especieId: (json['species_id']! as num).toInt(),
    cantidad: (json['cantidad']! as num).toInt(),
  );

  final int especieId;
  final int cantidad;
}

/// Mínimo de mascotas para mostrar la demanda (06: nunca menos de 5).
const minimoDemanda = 5;

/// Propuestas que puede recibir cada mascota por mes, entre todas las
/// veterinarias (06).
const maximoPropuestasPorMes = 3;

/// Resultado de una propuesta enviada (`resultados_propuestas()`).
class ResultadoPropuesta {
  const ResultadoPropuesta({
    required this.id,
    required this.mensaje,
    required this.enviada,
    required this.enviadas,
    required this.vistas,
    required this.aceptadas,
  });

  factory ResultadoPropuesta.fromJson(Map<String, Object?> json) =>
      ResultadoPropuesta(
        id: json['id']! as String,
        mensaje: json['message']! as String,
        enviada: DateTime.parse(json['created_at']! as String).toLocal(),
        enviadas: (json['enviadas']! as num).toInt(),
        vistas: (json['vistas']! as num).toInt(),
        aceptadas: (json['aceptadas']! as num).toInt(),
      );

  final String id;
  final String mensaje;
  final DateTime enviada;
  final int enviadas;
  final int vistas;
  final int aceptadas;
}

/// Estado de una propuesta recibida (`vet_proposal_deliveries.status`).
enum EstadoPropuesta { enviada, vista, aceptada, rechazada }

/// Una propuesta de una veterinaria para una mascota (`propuestas_para()`).
class Propuesta {
  const Propuesta({
    required this.id,
    required this.negocioId,
    required this.negocio,
    required this.mensaje,
    required this.estado,
    required this.recibida,
  });

  factory Propuesta.fromJson(Map<String, Object?> json) => Propuesta(
    id: json['proposal_id']! as String,
    negocioId: json['business_id']! as String,
    negocio: json['negocio']! as String,
    mensaje: json['message']! as String,
    estado: switch (json['status']) {
      'accepted' => EstadoPropuesta.aceptada,
      'declined' => EstadoPropuesta.rechazada,
      'seen' => EstadoPropuesta.vista,
      _ => EstadoPropuesta.enviada,
    },
    recibida: DateTime.parse(json['created_at']! as String).toLocal(),
  );

  final String id;
  final String negocioId;
  final String negocio;
  final String mensaje;
  final EstadoPropuesta estado;
  final DateTime recibida;

  bool get pendiente =>
      estado == EstadoPropuesta.enviada || estado == EstadoPropuesta.vista;
}

/// ¿Se le pregunta al dueño si busca veterinaria? (`estado_busco_veterinaria()`).
class EstadoBusqueda {
  const EstadoBusqueda({this.buscando = false, this.preguntar = false});

  factory EstadoBusqueda.fromJson(Map<String, Object?>? json) => EstadoBusqueda(
    buscando: json?['buscando'] == true,
    preguntar: json?['preguntar'] == true,
  );

  final bool buscando;
  final bool preguntar;
}
