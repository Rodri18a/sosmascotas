/// Apadrinamiento de refugios y ferias (3.4b, D108): comercios verificados
/// que apadrinan a un refugio verificado o a un evento suyo.
library;

enum EstadoApadrinamiento {
  pendiente('pending'),
  activo('active'),
  rechazado('declined'),
  terminado('ended');

  const EstadoApadrinamiento(this.valor);

  final String valor;

  static EstadoApadrinamiento leer(Object? valor) => values.firstWhere(
    (e) => e.valor == valor,
    orElse: () => EstadoApadrinamiento.terminado,
  );
}

/// Un ofrecimiento visto desde el comercio (`otro` = el refugio) o desde el
/// refugio (`otro` = el comercio).
class Apadrinamiento {
  const Apadrinamiento({
    required this.id,
    required this.estado,
    required this.aporte,
    required this.otro,
    this.evento,
  });

  factory Apadrinamiento.fromJson(Map<String, Object?> json) => Apadrinamiento(
    id: json['id']! as String,
    estado: EstadoApadrinamiento.leer(json['status']),
    aporte: (json['contribution'] as String?) ?? '',
    otro: (json['otro'] as String?) ?? '',
    evento: json['evento'] as String?,
  );

  final String id;
  final EstadoApadrinamiento estado;
  final String aporte;
  final String otro;

  /// El título del evento, si es para una feria y no para el refugio.
  final String? evento;
}

class EventoParaApadrinar {
  const EventoParaApadrinar({
    required this.id,
    required this.titulo,
    required this.desde,
  });

  final String id;
  final String titulo;
  final DateTime desde;
}

class RefugioParaApadrinar {
  const RefugioParaApadrinar({
    required this.id,
    required this.nombre,
    this.direccion,
    this.eventos = const [],
  });

  factory RefugioParaApadrinar.fromJson(Map<String, Object?> json) =>
      RefugioParaApadrinar(
        id: json['id']! as String,
        nombre: json['name']! as String,
        direccion: json['address'] as String?,
        eventos: [
          for (final e in (json['eventos'] as List?) ?? const [])
            if (e case final Map<String, Object?> e)
              EventoParaApadrinar(
                id: e['id']! as String,
                titulo: e['title']! as String,
                desde: DateTime.parse(e['starts_at']! as String),
              ),
        ],
      );

  final String id;
  final String nombre;
  final String? direccion;
  final List<EventoParaApadrinar> eventos;
}

/// Lo que ve el negocio en su pantalla de apadrinamiento.
class DatosApadrinamiento {
  const DatosApadrinamiento({
    this.esRefugio = false,
    this.puedeOfrecer = false,
    this.recibidos = const [],
    this.ofrecidos = const [],
    this.refugios = const [],
  });

  factory DatosApadrinamiento.fromJson(Map<String, Object?> json) {
    List<T> lista<T>(String clave, T Function(Map<String, Object?>) leer) => [
      for (final f in (json[clave] as List?) ?? const [])
        if (f case final Map<String, Object?> f) leer(f),
    ];
    return DatosApadrinamiento(
      esRefugio: json['es_refugio'] == true,
      puedeOfrecer: json['puede_ofrecer'] == true,
      recibidos: lista('recibidos', Apadrinamiento.fromJson),
      ofrecidos: lista('ofrecidos', Apadrinamiento.fromJson),
      refugios: lista('refugios', RefugioParaApadrinar.fromJson),
    );
  }

  final bool esRefugio;
  final bool puedeOfrecer;
  final List<Apadrinamiento> recibidos;
  final List<Apadrinamiento> ofrecidos;
  final List<RefugioParaApadrinar> refugios;
}

/// Quien apadrina, como se muestra en la ficha del refugio o del evento.
class Padrino {
  const Padrino({required this.nombre, required this.aporte, this.negocioId});

  factory Padrino.fromJson(Map<String, Object?> json) => Padrino(
    nombre: json['name']! as String,
    aporte: (json['contribution'] as String?) ?? '',
    negocioId: json['business_id'] as String?,
  );

  final String nombre;
  final String aporte;
  final String? negocioId;
}
