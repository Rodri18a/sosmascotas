import '../mapa/mapa.dart';

/// Días como los guarda la base (`businesses.hours`), de lunes a domingo.
const diasHorario = ['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'];

/// Una franja de atención, en minutos desde la medianoche (`24:00` = 1440).
class Franja {
  const Franja(this.desde, this.hasta);

  final int desde;
  final int hasta;

  @override
  bool operator ==(Object other) =>
      other is Franja && other.desde == desde && other.hasta == hasta;

  @override
  int get hashCode => Object.hash(desde, hasta);

  @override
  String toString() => 'Franja($desde, $hasta)';
}

/// Horario semanal de un comercio. Un día sin franjas está cerrado.
class Horario {
  const Horario(this.porDia);

  /// `{"mon": [["09:00","13:00"], ...], ...}` (formato de la base). Ignora lo
  /// que no entiende en vez de fallar: un horario raro no rompe el mapa.
  factory Horario.fromJson(Object? json) {
    final porDia = <int, List<Franja>>{};
    if (json is Map) {
      for (final (i, dia) in diasHorario.indexed) {
        final franjas = json[dia];
        if (franjas is! List) continue;
        for (final f in franjas) {
          if (f is List && f.length == 2) {
            final desde = _minutos(f[0]);
            final hasta = _minutos(f[1]);
            if (desde != null && hasta != null && desde < hasta) {
              (porDia[i] ??= []).add(Franja(desde, hasta));
            }
          }
        }
      }
    }
    return Horario(porDia);
  }

  /// Franjas por día: 0 = lunes … 6 = domingo.
  final Map<int, List<Franja>> porDia;

  bool get vacio => porDia.isEmpty;

  List<Franja> delDia(int dia) => porDia[dia] ?? const [];

  static int? _minutos(Object? hora) {
    if (hora is! String) return null;
    final m = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(hora);
    if (m == null) return null;
    final total = int.parse(m[1]!) * 60 + int.parse(m[2]!);
    return total <= 24 * 60 ? total : null;
  }
}

/// Un comercio del mapa (función `comercios_en_zona`). En la Fase 0, solo
/// veterinarias.
class Comercio {
  const Comercio({
    required this.id,
    required this.nombre,
    required this.punto,
    required this.horario,
    this.tipo = 'vet',
    this.descripcion,
    this.direccion,
    this.telefono,
    this.whatsapp,
    this.web,
    this.instagram,
    this.es24h = false,
    this.urgencias = false,
    this.especieIds = const [],
    this.verificado = false,
    this.esEjemplo = false,
  });

  factory Comercio.fromJson(Map<String, Object?> json) => Comercio(
    id: json['id']! as String,
    tipo: (json['business_type'] as String?) ?? 'vet',
    nombre: json['name']! as String,
    descripcion: json['description'] as String?,
    direccion: json['address'] as String?,
    punto: Punto(
      (json['lat']! as num).toDouble(),
      (json['lng']! as num).toDouble(),
    ),
    telefono: json['phone'] as String?,
    whatsapp: json['whatsapp'] as String?,
    web: json['web'] as String?,
    instagram: json['instagram'] as String?,
    horario: Horario.fromJson(json['hours']),
    es24h: json['is_24h'] == true,
    urgencias: json['emergencies'] == true,
    especieIds: [
      for (final id in (json['species_ids'] as List?) ?? const [])
        (id as num).toInt(),
    ],
    verificado: json['verified'] == true,
    esEjemplo: json['is_sample'] == true,
  );

  final String id;
  final String tipo;
  final String nombre;
  final String? descripcion;
  final String? direccion;
  final Punto punto;
  final String? telefono;
  final String? whatsapp;
  final String? web;
  final String? instagram;
  final Horario horario;
  final bool es24h;
  final bool urgencias;

  /// Vacío: atiende todas las especies.
  final List<int> especieIds;
  final bool verificado;

  /// Dato de ejemplo (solo en desarrollo).
  final bool esEjemplo;

  /// Pin del mapa: las de urgencia o 24 h se destacan.
  Pin get pin => Pin(
    id: id,
    tipo: urgencias || es24h ? TipoPin.urgencia : TipoPin.veterinaria,
    punto: punto,
  );
}
