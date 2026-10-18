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
