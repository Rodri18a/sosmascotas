import 'package:sosmascota_core/sosmascota_core.dart';

/// Indicadores del panel general (`admin_panel()`, 1.8.2).
class Panel {
  const Panel(this.datos);

  final Map<String, Object?> datos;

  int entero(String clave) => (datos[clave] as num?)?.toInt() ?? 0;

  double? decimal(String clave) => (datos[clave] as num?)?.toDouble();

  Map<String, int> conteos(String clave) => {
    for (final MapEntry(:key, :value)
        in ((datos[clave] as Map?) ?? const {}).entries)
      key as String: (value as num).toInt(),
  };
}

/// Demanda sin cubrir (`admin_demanda()`, 1.8.7, D97): búsquedas por rubro
/// contra los lugares de ese rubro, y textos sin rubro que no encontraron nada.
class Demanda {
  const Demanda({this.porRubro = const [], this.textos = const []});

  factory Demanda.fromJson(Map<String, Object?> json) => Demanda(
    porRubro: [
      for (final f in (json['por_rubro'] as List?) ?? const [])
        (
          rubro: (f as Map)['rubro'] as String,
          busquedas: (f['busquedas'] as num).toInt(),
          sinResultados: (f['sin_resultados'] as num).toInt(),
          lugares: (f['lugares'] as num).toInt(),
        ),
    ],
    textos: [
      for (final f in (json['textos_sin_resultado'] as List?) ?? const [])
        (
          texto: (f as Map)['texto'] as String,
          veces: (f['veces'] as num).toInt(),
        ),
    ],
  );

  final List<({String rubro, int busquedas, int sinResultados, int lugares})>
  porRubro;
  final List<({String texto, int veces})> textos;
}

/// Algo reportado para moderar (`admin_moderacion()`, 1.8.3).
class ItemModeracion {
  const ItemModeracion({
    required this.tipo,
    required this.id,
    required this.texto,
    required this.estado,
    required this.reportes,
    this.autorId,
    this.autorNombre,
    this.motivos = const [],
    this.ultimoReporte,
  });

  factory ItemModeracion.fromJson(Map<String, Object?> json) => ItemModeracion(
    tipo: json['target_type']! as String,
    id: json['target_id']! as String,
    autorId: json['autor_id'] as String?,
    autorNombre: json['autor_nombre'] as String?,
    texto: (json['texto'] as String?) ?? '',
    estado: (json['estado'] as String?) ?? '',
    reportes: (json['reportes'] as num?)?.toInt() ?? 0,
    motivos: [for (final m in (json['motivos'] as List?) ?? const []) '$m'],
    ultimoReporte: switch (json['ultimo_reporte']) {
      final String f => DateTime.parse(f).toLocal(),
      _ => null,
    },
  );

  /// `sos` o `message`.
  final String tipo;
  final String id;
  final String? autorId;
  final String? autorNombre;
  final String texto;

  /// `hidden` (oculto por reportes), `active` (con reportes) o `reported`.
  final String estado;
  final int reportes;
  final List<String> motivos;
  final DateTime? ultimoReporte;
}

/// Un lugar con los datos internos (`admin_lugares()`, 1.8.4 y 1.8.5).
class LugarAdmin {
  const LugarAdmin({
    required this.id,
    required this.datos,
    required this.comercio,
    required this.verificacion,
    required this.estado,
    this.aperturas30d = 0,
    this.favoritos = 0,
  });

  factory LugarAdmin.fromJson(Map<String, Object?> json) => LugarAdmin(
    id: json['id']! as String,
    datos: json,
    comercio: Comercio.fromJson({
      ...json,
      'verified': json['verification'] == 'verified',
    }),
    verificacion: (json['verification'] as String?) ?? 'unverified',
    estado: (json['status'] as String?) ?? 'active',
    aperturas30d: (json['aperturas_30d'] as num?)?.toInt() ?? 0,
    favoritos: (json['favoritos'] as num?)?.toInt() ?? 0,
  );

  final String id;

  /// La fila tal cual (para editar sin perder campos).
  final Map<String, Object?> datos;
  final Comercio comercio;

  /// `unverified`, `pending` o `verified`.
  final String verificacion;

  /// `active` o `hidden`.
  final String estado;
  final int aperturas30d;
  final int favoritos;
}

/// Etapas del embudo de ventas (mini CRM, 1.8.6).
const etapasProspecto = [
  'prospect',
  'contacted',
  'demo',
  'founder',
  'paying',
  'renewed',
  'lost',
];

class Prospecto {
  const Prospecto({
    required this.id,
    required this.nombre,
    this.rubro,
    this.contacto,
    this.etapa = 'prospect',
    this.proximoContacto,
    this.notas,
  });

  factory Prospecto.fromJson(Map<String, Object?> json) => Prospecto(
    id: json['id']! as String,
    nombre: json['name']! as String,
    rubro: json['business_type'] as String?,
    contacto: json['contact'] as String?,
    etapa: (json['stage'] as String?) ?? 'prospect',
    proximoContacto: switch (json['next_contact']) {
      final String f => DateTime.parse(f),
      _ => null,
    },
    notas: json['notes'] as String?,
  );

  final String id;
  final String nombre;
  final String? rubro;
  final String? contacto;
  final String etapa;
  final DateTime? proximoContacto;
  final String? notas;

  Map<String, Object?> toJson() => {
    'name': nombre.trim(),
    'business_type': rubro,
    'contact': _vacio(contacto),
    'stage': etapa,
    'next_contact': proximoContacto == null ? null : fechaIso(proximoContacto!),
    'notes': _vacio(notas),
  };

  static String? _vacio(String? t) =>
      t == null || t.trim().isEmpty ? null : t.trim();
}

/// Una entrada del directorio de Ayuda (1.8.8).
class EntradaAyuda {
  const EntradaAyuda({
    required this.id,
    required this.tipo,
    required this.nombre,
    this.descripcion,
    this.telefono,
    this.whatsapp,
    this.enlace,
    this.activa = true,
  });

  factory EntradaAyuda.fromJson(Map<String, Object?> json) => EntradaAyuda(
    id: json['id']! as String,
    tipo: json['kind']! as String,
    nombre: json['name']! as String,
    descripcion: json['description'] as String?,
    telefono: json['phone'] as String?,
    whatsapp: json['whatsapp'] as String?,
    enlace: json['link'] as String?,
    activa: json['status'] != 'hidden',
  );

  final String id;

  /// `refugio`, `protectora`, `grupo` u `organismo`.
  final String tipo;
  final String nombre;
  final String? descripcion;
  final String? telefono;
  final String? whatsapp;

  /// Por ejemplo, la página de adopciones de un refugio.
  final String? enlace;
  final bool activa;
}

/// Algo para resolver de un comercio (`admin_pendientes_comercios()`, 1.3).
class PendienteComercio {
  const PendienteComercio({
    required this.tipo,
    required this.id,
    required this.negocioId,
    required this.negocio,
    required this.rubro,
    this.usuarioNombre,
    this.rut,
    this.nota,
    this.creado,
    this.tieneDuenio = false,
  });

  factory PendienteComercio.fromJson(Map<String, Object?> json) =>
      PendienteComercio(
        tipo: json['tipo']! as String,
        id: json['id']! as String,
        negocioId: json['business_id']! as String,
        negocio: (json['negocio'] as String?) ?? '',
        rubro: (json['rubro'] as String?) ?? '',
        usuarioNombre: json['usuario_nombre'] as String?,
        rut: json['rut'] as String?,
        nota: json['nota'] as String?,
        creado: switch (json['creado']) {
          final String f => DateTime.parse(f).toLocal(),
          _ => null,
        },
        tieneDuenio: json['tiene_duenio'] == true,
      );

  /// `claim`, `dispute`, `verification` o `renac`.
  final String tipo;
  final String id;
  final String negocioId;
  final String negocio;
  final String rubro;
  final String? usuarioNombre;
  final String? rut;
  final String? nota;
  final DateTime? creado;
  final bool tieneDuenio;
}

/// Datos de una propuesta para un comercio (`admin_propuesta()`, 2.4, D102).
/// Los grupos de menos de 5 llegan como `null` ("menos de 5").
class Propuesta {
  const Propuesta(this.datos);

  final Map<String, Object?> datos;

  Map<String, Object?> _mapa(String clave) =>
      ((datos[clave] as Map?) ?? const {}).cast<String, Object?>();

  String get rubro => datos['rubro']! as String;
  int get dias => (datos['dias'] as num?)?.toInt() ?? 30;
  String? get zona => datos['zona'] as String?;

  int? get usuarios => (_mapa('audiencia')['usuarios'] as num?)?.toInt();
  int? get activos => (_mapa('audiencia')['activos'] as num?)?.toInt();
  List<({String especie, int? cantidad})> get mascotas => [
    for (final m in (_mapa('audiencia')['mascotas'] as List?) ?? const [])
      (
        especie: (m as Map)['especie'] as String,
        cantidad: (m['cantidad'] as num?)?.toInt(),
      ),
  ];

  int get busquedas => (_mapa('demanda')['busquedas'] as num?)?.toInt() ?? 0;
  int get sinResultados =>
      (_mapa('demanda')['sin_resultados'] as num?)?.toInt() ?? 0;
  int get lugares => (_mapa('oferta')['lugares'] as num?)?.toInt() ?? 0;
  int get verificados => (_mapa('oferta')['verificados'] as num?)?.toInt() ?? 0;
  int get rubroAperturas => (datos['rubro_aperturas'] as num?)?.toInt() ?? 0;

  /// Lo del comercio, si la propuesta es para uno en particular.
  Map<String, Object?>? get negocio =>
      (datos['negocio'] as Map?)?.cast<String, Object?>();

  int numeroDelNegocio(String clave) => (negocio?[clave] as num?)?.toInt() ?? 0;

  List<({String comercio, String cita, String? autor, String? numeros})>
  get casos => [
    for (final c in (datos['casos'] as List?) ?? const [])
      (
        comercio: (c as Map)['comercio'] as String,
        cita: c['cita'] as String,
        autor: c['autor'] as String?,
        numeros: c['numeros'] as String?,
      ),
  ];
}

/// Caso de éxito para ventas (`success_stories`, 2.4, D102).
class CasoExito {
  const CasoExito({
    required this.id,
    required this.comercio,
    required this.rubro,
    required this.cita,
    this.negocioId,
    this.zonaId,
    this.autor,
    this.numeros,
    this.permiso = false,
    this.publicado = false,
  });

  factory CasoExito.fromJson(Map<String, Object?> json) => CasoExito(
    id: json['id']! as String,
    negocioId: json['business_id'] as String?,
    comercio: json['business_name']! as String,
    rubro: json['business_type']! as String,
    zonaId: (json['zone_id'] as num?)?.toInt(),
    cita: json['quote']! as String,
    autor: json['author'] as String?,
    numeros: json['numbers'] as String?,
    permiso: json['consent'] as bool? ?? false,
    publicado: json['status'] == 'published',
  );

  final String id;
  final String? negocioId;
  final String comercio;
  final String rubro;
  final int? zonaId;
  final String cita;
  final String? autor;
  final String? numeros;

  /// La empresa autorizó usar su nombre y sus números.
  final bool permiso;
  final bool publicado;

  Map<String, Object?> toJson() => {
    'id': id.isEmpty ? null : id,
    'business_id': negocioId,
    'business_name': comercio,
    'business_type': rubro,
    'zone_id': zonaId,
    'quote': cita,
    'author': autor,
    'numbers': numeros,
    'consent': permiso,
    'status': publicado ? 'published' : 'draft',
  };
}

/// Plan pago de un comercio (`admin_suscripciones()`, 2.2, D103).
class Suscripcion {
  const Suscripcion({
    required this.id,
    required this.negocioId,
    required this.comercio,
    required this.plan,
    required this.estado,
    required this.vence,
    this.rubro,
    this.fundador = false,
    this.precio = 0,
    this.pagado = 0,
    this.ultimoPago,
  });

  factory Suscripcion.fromJson(Map<String, Object?> json) => Suscripcion(
    id: json['id']! as String,
    negocioId: json['business_id']! as String,
    comercio: json['comercio'] as String? ?? '—',
    rubro: json['rubro'] as String?,
    plan: json['plan']! as String,
    estado: json['status']! as String,
    vence: DateTime.parse(json['period_end']! as String),
    fundador: json['founder'] as bool? ?? false,
    precio: double.tryParse('${json['price']}') ?? 0,
    pagado: double.tryParse('${json['pagado']}') ?? 0,
    ultimoPago: switch (json['ultimo_pago']) {
      final String f => DateTime.parse(f),
      _ => null,
    },
  );

  final String id;
  final String negocioId;
  final String comercio;
  final String? rubro;

  /// `featured` o `plus`.
  final String plan;

  /// `active`, `past_due`, `cancelled` o `expired`.
  final String estado;
  final DateTime vence;
  final bool fundador;

  /// Por mes.
  final double precio;
  final double pagado;
  final DateTime? ultimoPago;

  bool get vigente => estado == 'active' || estado == 'past_due';
}

/// Ingresos por mes y por plan (`admin_ingresos()`, 2.2, D103).
class Ingresos {
  const Ingresos({
    this.porMes = const [],
    this.vigentes = const {},
    this.esperadoPorMes = 0,
  });

  factory Ingresos.fromJson(Map<String, Object?> json) => Ingresos(
    porMes: [
      for (final f in (json['por_mes'] as List?) ?? const [])
        (
          mes: DateTime.parse((f as Map)['mes'] as String),
          plan: f['plan'] as String,
          total: (f['total'] as num).toDouble(),
          pagos: (f['pagos'] as num).toInt(),
        ),
    ],
    vigentes: {
      for (final MapEntry(:key, :value)
          in ((json['vigentes'] as Map?) ?? const {}).entries)
        key as String: (value as num).toInt(),
    },
    esperadoPorMes: (json['por_mes_esperado'] as num?)?.toDouble() ?? 0,
  );

  final List<({DateTime mes, String plan, double total, int pagos})> porMes;
  final Map<String, int> vigentes;

  /// Lo que deberían pagar por mes las vigentes que no son Socios Fundadores.
  final double esperadoPorMes;
}
