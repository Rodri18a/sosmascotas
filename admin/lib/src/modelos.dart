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
