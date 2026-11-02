/// Comunidad por raza y especie (3.4, D116): lo que devuelven `grupos()`,
/// `publicaciones_de()`, `publicacion()` y `mis_saludos()`.
library;

DateTime _momento(Object? v) => DateTime.parse(v! as String).toLocal();

List<String> _textos(Object? v) => [
  for (final x in (v as List?) ?? const []) '$x',
];

enum TipoGrupo {
  especie('species'),
  raza('breed'),
  tema('topic');

  const TipoGrupo(this.base);

  final String base;

  static TipoGrupo desdeBase(Object? v) =>
      values.firstWhere((e) => e.base == v, orElse: () => tema);
}

class Grupo {
  const Grupo({
    required this.id,
    required this.tipo,
    required this.nombre,
    this.descripcion,
    this.icono,
    this.especieId,
    this.razaId,
    this.miembros = 0,
    this.publicacionesSemana = 0,
    this.soyMiembro = false,
  });

  factory Grupo.fromJson(Map<String, Object?> json) => Grupo(
    id: json['id']! as String,
    tipo: TipoGrupo.desdeBase(json['kind']),
    nombre: json['name']! as String,
    descripcion: json['description'] as String?,
    icono: json['icon'] as String?,
    especieId: (json['species_id'] as num?)?.toInt(),
    razaId: (json['breed_id'] as num?)?.toInt(),
    miembros: (json['miembros'] as num?)?.toInt() ?? 0,
    publicacionesSemana: (json['publicaciones_semana'] as num?)?.toInt() ?? 0,
    soyMiembro: json['soy_miembro'] as bool? ?? false,
  );

  final String id;
  final TipoGrupo tipo;
  final String nombre;
  final String? descripcion;
  final String? icono;
  final int? especieId;
  final int? razaId;
  final int miembros;
  final int publicacionesSemana;
  final bool soyMiembro;
}

enum TipoPublicacion {
  pregunta('question'),
  consejo('tip'),
  experiencia('story');

  const TipoPublicacion(this.base);

  final String base;

  static TipoPublicacion desdeBase(Object? v) =>
      values.firstWhere((e) => e.base == v, orElse: () => pregunta);
}

/// Tema de una pregunta (2.3, D134): valores iguales a la base.
enum TemaPregunta {
  viajes('travel'),
  salud('health'),
  alimentacion('food'),
  adopcion('adoption'),
  tramites('paperwork'),
  otros('other');

  const TemaPregunta(this.base);

  final String base;

  static TemaPregunta? desdeBase(Object? v) =>
      values.where((e) => e.base == v).firstOrNull;
}

class Comentario {
  const Comentario({
    required this.id,
    required this.texto,
    required this.creado,
    this.autor,
    this.esMio = false,
    this.profesional,
  });

  factory Comentario.fromJson(Map<String, Object?> json) => Comentario(
    id: json['id']! as String,
    texto: json['body']! as String,
    autor: json['autor'] as String?,
    esMio: json['es_mio'] as bool? ?? false,
    creado: _momento(json['created_at']),
    profesional: json['profesional'] as String?,
  );

  final String id;
  final String texto;

  /// Solo el primer nombre.
  final String? autor;
  final bool esMio;
  final DateTime creado;

  /// La veterinaria verificada que firma la respuesta (D135), si la marcó.
  final String? profesional;
}

class Publicacion {
  const Publicacion({
    required this.id,
    required this.tipo,
    required this.texto,
    required this.creada,
    this.fotos = const [],
    this.autor,
    this.esMia = false,
    this.cantidadComentarios = 0,
    this.grupoId,
    this.grupoNombre,
    this.soyMiembro = false,
    this.comentarios = const [],
    this.tema,
    this.respuestaMarcadaId,
    this.resuelta = false,
    this.conProfesional = false,
  });

  /// De `publicaciones_de()` o `preguntas()` (listas) o de `publicacion()`
  /// (con comentarios).
  factory Publicacion.fromJson(Map<String, Object?> json) {
    final comentarios = [
      if (json['comentarios'] case final List<Object?> lista)
        for (final c in lista) Comentario.fromJson((c! as Map).cast()),
    ];
    return Publicacion(
      id: json['id']! as String,
      tipo: TipoPublicacion.desdeBase(json['kind']),
      texto: json['body']! as String,
      fotos: _textos(json['photo_paths']),
      autor: json['autor'] as String?,
      esMia: (json['es_mio'] as bool?) ?? false,
      // En la lista es un número; en el detalle, la lista de comentarios.
      cantidadComentarios: switch (json['comentarios'] ?? json['respuestas']) {
        final num n => n.toInt(),
        _ => comentarios.length,
      },
      creada: _momento(json['created_at']),
      grupoId: json['group_id'] as String?,
      grupoNombre: json['group_name'] as String?,
      soyMiembro: json['soy_miembro'] as bool? ?? false,
      comentarios: comentarios,
      tema: TemaPregunta.desdeBase(json['topic']),
      respuestaMarcadaId: json['solved_comment_id'] as String?,
      resuelta: json['resuelta'] as bool? ?? json['solved_comment_id'] != null,
      conProfesional:
          json['con_profesional'] as bool? ??
          comentarios.any((c) => c.profesional != null),
    );
  }

  final String id;
  final TipoPublicacion tipo;
  final String texto;

  /// Rutas en el bucket `community-photos`.
  final List<String> fotos;
  final String? autor;
  final bool esMia;
  final int cantidadComentarios;
  final DateTime creada;

  /// Solo en el detalle.
  final String? grupoId;
  final String? grupoNombre;
  final bool soyMiembro;
  final List<Comentario> comentarios;

  /// Solo en las preguntas (D134).
  final TemaPregunta? tema;

  /// La respuesta que quien preguntó marcó con «Me sirvió» (solo en el detalle).
  final String? respuestaMarcadaId;
  final bool resuelta;

  /// Tiene una respuesta de una veterinaria verificada (D135).
  final bool conProfesional;
}

enum EstadoSaludo {
  pendiente('pending'),
  aceptado('accepted'),
  rechazado('declined');

  const EstadoSaludo(this.base);

  final String base;

  static EstadoSaludo desdeBase(Object? v) =>
      values.firstWhere((e) => e.base == v, orElse: () => pendiente);
}

/// Un saludo previo al chat: recibido o mandado.
class Saludo {
  const Saludo({
    required this.id,
    required this.recibido,
    required this.mensaje,
    required this.estado,
    required this.creado,
    this.persona,
    this.publicacionId,
    this.publicacionTexto,
    this.chatId,
  });

  factory Saludo.fromJson(Map<String, Object?> json) => Saludo(
    id: json['id']! as String,
    recibido: json['recibido'] as bool? ?? false,
    persona: json['persona'] as String?,
    mensaje: json['message']! as String,
    publicacionId: json['post_id'] as String?,
    publicacionTexto: json['post_texto'] as String?,
    estado: EstadoSaludo.desdeBase(json['status']),
    chatId: json['conversation_id'] as String?,
    creado: _momento(json['created_at']),
  );

  final String id;
  final bool recibido;

  /// Primer nombre de la otra persona.
  final String? persona;
  final String mensaje;
  final String? publicacionId;
  final String? publicacionTexto;
  final EstadoSaludo estado;

  /// Solo si se aceptó.
  final String? chatId;
  final DateTime creado;
}

final _prohibido = RegExp(
  r'(^|[^a-zñ])((vendo|vendemos|se venden?|cruzar(la|lo|las|los)?|cruzo'
  r'|cruzamos|para cruza|busco cruza|monta|servicio de monta|padrillo'
  r'|semental|busco novi[oa])([^a-zñ]|$)'
  r'|venta de (cachorr|gatit|perr|gat|mascot|conej|pajar))',
);

/// ¿Ofrece venta o cruza de animales? Misma regla que
/// `texto_prohibido_comunidad()` en la base (06): la app avisa antes de mandar.
bool textoProhibidoComunidad(String texto) {
  const con = 'áéíóúü';
  const sin = 'aeiouu';
  final normal = texto.toLowerCase().split('').map((c) {
    final i = con.indexOf(c);
    return i < 0 ? c : sin[i];
  }).join();
  return _prohibido.hasMatch(normal);
}
