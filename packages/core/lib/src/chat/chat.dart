/// Una conversación del chat interno (`mis_conversaciones()`, D73).
class Conversacion {
  const Conversacion({
    required this.id,
    required this.tipo,
    required this.ultimoMensajeEn,
    this.contextoId,
    this.otroId,
    this.otroNombre,
    this.soyAutor = false,
    this.sosEncontrada = false,
    this.sosNombre,
    this.negocioNombre,
    this.ultimoMensaje,
    this.sinLeer = 0,
    this.bloqueada = false,
    this.bloqueadaPorMi = false,
  });

  factory Conversacion.fromJson(Map<String, Object?> json) => Conversacion(
    id: json['id']! as String,
    tipo: json['kind']! as String,
    contextoId: json['context_id'] as String?,
    ultimoMensajeEn: DateTime.parse(
      json['last_message_at']! as String,
    ).toLocal(),
    otroId: json['otro_id'] as String?,
    otroNombre: json['otro_nombre'] as String?,
    soyAutor: json['soy_autor'] as bool? ?? false,
    sosEncontrada: json['sos_kind'] == 'found',
    sosNombre: json['sos_nombre'] as String?,
    negocioNombre: json['negocio_nombre'] as String?,
    ultimoMensaje: json['ultimo_mensaje'] as String?,
    sinLeer: (json['sin_leer'] as num?)?.toInt() ?? 0,
    bloqueada: json['bloqueada'] as bool? ?? false,
    bloqueadaPorMi: json['bloqueada_por_mi'] as bool? ?? false,
  );

  final String id;

  /// `sos`, `qr`, `business` o `user`.
  final String tipo;
  final String? contextoId;
  final DateTime ultimoMensajeEn;
  final String? otroId;

  /// Nombre visible del otro, o `null` si es quien publicó el SOS (la app lo
  /// nombra por la mascota, D73).
  final String? otroNombre;

  /// ¿Yo publiqué el SOS de esta conversación?
  final bool soyAutor;

  /// El SOS es de una mascota encontrada (no perdida).
  final bool sosEncontrada;
  final String? sosNombre;

  /// Chat con un comercio: su nombre (para quien le escribe).
  final String? negocioNombre;
  final String? ultimoMensaje;
  final int sinLeer;

  /// Alguno de los dos la bloqueó: no se puede escribir.
  final bool bloqueada;
  final bool bloqueadaPorMi;
}

/// Un mensaje del chat (tabla `messages`).
class Mensaje {
  const Mensaje({
    required this.id,
    required this.conversacionId,
    required this.creado,
    this.remitenteId,
    this.texto,
    this.foto,
    this.lat,
    this.lng,
  });

  factory Mensaje.fromJson(Map<String, Object?> json) => Mensaje(
    id: json['id']! as String,
    conversacionId: json['conversation_id']! as String,
    remitenteId: json['sender_id'] as String?,
    texto: json['body'] as String?,
    foto: json['attachment_path'] as String?,
    lat: (json['lat'] as num?)?.toDouble(),
    lng: (json['lng'] as num?)?.toDouble(),
    creado: DateTime.parse(json['created_at']! as String).toLocal(),
  );

  final String id;
  final String conversacionId;
  final String? remitenteId;
  final String? texto;

  /// Ruta en el bucket privado `chat-photos`.
  final String? foto;
  final double? lat;
  final double? lng;
  final DateTime creado;

  bool get conUbicacion => lat != null && lng != null;
}

/// Agrega [nuevos] a [lista] sin repetir (por id) y en orden de llegada.
List<Mensaje> sumarMensajes(List<Mensaje> lista, Iterable<Mensaje> nuevos) {
  final porId = {
    for (final m in lista) m.id: m,
    for (final m in nuevos) m.id: m,
  };
  return porId.values.toList()..sort((a, b) => a.creado.compareTo(b.creado));
}

/// Señales típicas de estafa en un mensaje (pedir plata, códigos o datos de
/// tarjeta): la app muestra un aviso de seguridad (1.4.4).
bool pareceEstafa(String texto) {
  final t = texto.toLowerCase();
  const pistas = [
    'transfer',
    'depósit',
    'deposit',
    'giro',
    'abitab',
    'redpagos',
    'mercado pago',
    'mercadopago',
    'código',
    'codigo',
    'tarjeta',
    'cvv',
    'contraseña',
    'clave',
    'recompensa por adelantado',
    'pagá',
    'paga ',
    'pagame',
    'pagáme',
    'envío de dinero',
    'prex',
    'cuenta bancaria',
  ];
  return pistas.any(t.contains);
}

/// Una reseña pública de un comercio (`resenas_de()`, 1.7, D78).
class Resena {
  const Resena({
    required this.id,
    required this.estrellas,
    required this.creada,
    this.comentario,
    this.respuesta,
    this.respondida,
    this.autor = '',
    this.mia = false,
  });

  factory Resena.fromJson(Map<String, Object?> json) => Resena(
    id: json['id']! as String,
    estrellas: (json['estrellas']! as num).toInt(),
    comentario: json['comentario'] as String?,
    respuesta: json['respuesta'] as String?,
    respondida: switch (json['respondida']) {
      final String f => DateTime.parse(f).toLocal(),
      _ => null,
    },
    creada: DateTime.parse(json['creada']! as String).toLocal(),
    autor: (json['autor'] as String?) ?? '',
    mia: json['mia'] == true,
  );

  final String id;

  /// De 1 a 5.
  final int estrellas;
  final String? comentario;

  /// La respuesta del comercio (una sola, en público).
  final String? respuesta;
  final DateTime? respondida;
  final DateTime creada;

  /// Solo el primer nombre visible de quien la escribió.
  final String autor;
  final bool mia;
}

/// Promedio de estrellas con un decimal (`null` sin reseñas).
double? promedioEstrellas(Iterable<Resena> resenas) {
  final lista = resenas.toList();
  if (lista.isEmpty) return null;
  final total = lista.fold<int>(0, (s, r) => s + r.estrellas);
  return (total / lista.length * 10).round() / 10;
}
