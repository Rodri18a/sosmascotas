import '../mapa/mapa.dart';
import '../mascotas/mascota.dart';
import '../qr/qr_tag.dart';

/// Rubro de un lugar (valores iguales a la base: `businesses.business_type`).
enum Categoria {
  vet('vet'),
  petshop('petshop'),
  pharmacy('pharmacy'),
  grooming('grooming'),
  walker('walker'),
  hotel('hotel'),
  trainer('trainer'),
  petFriendly('pet_friendly'),
  shelter('shelter'),
  agro('agro');

  const Categoria(this.valor);

  final String valor;

  static Categoria? leer(Object? valor) =>
      values.where((c) => c.valor == valor).firstOrNull;
}

/// Con local (pin en el mapa), online o a domicilio ("Sin local").
enum Modalidad { local, online, domicilio }

/// Plan de una empresa (06): Básico, Destacado o Plus.
enum PlanComercio { basic, featured, plus }

/// Módulos del modo comercio (06 "Módulos según el tipo de negocio").
enum Modulo { catalogo, agenda, socios }

/// ¿El tipo de negocio admite el módulo? Si no, se muestra "No aplica".
bool moduloAdmitido(Categoria c, Modalidad m, Modulo modulo) {
  if (m == Modalidad.online) return modulo == Modulo.catalogo;
  if (m == Modalidad.domicilio) return modulo == Modulo.agenda;
  return switch ((c, modulo)) {
    (Categoria.vet, _) => true,
    (
      Categoria.petshop || Categoria.pharmacy || Categoria.agro,
      Modulo.catalogo,
    ) =>
      true,
    (
      Categoria.grooming ||
          Categoria.hotel ||
          Categoria.walker ||
          Categoria.trainer,
      Modulo.agenda,
    ) =>
      true,
    _ => false,
  };
}

/// Regla de activación (06): solo con plan Plus, si el tipo lo admite y la
/// empresa lo prendió.
bool moduloActivo(
  Categoria c,
  Modalidad m,
  PlanComercio plan,
  Modulo modulo, {
  required bool prendido,
}) => plan == PlanComercio.plus && moduloAdmitido(c, m, modulo) && prendido;

/// Estado de verificación de una empresa (`businesses.verification`).
enum Verificacion { unverified, pending, verified }

/// Un negocio propio (`mis_negocios()`, 1.3, D77): la ficha pública más lo
/// que solo ve su dueño.
class MiNegocio {
  const MiNegocio({
    required this.comercio,
    required this.verificacion,
    this.visible = true,
    this.rut,
    this.fundadorHasta,
    this.renacPedido = false,
    this.verificacionPedida = false,
  });

  factory MiNegocio.fromJson(Map<String, Object?> json) => MiNegocio(
    comercio: Comercio.fromJson({...json, 'has_owner': true}),
    verificacion:
        Verificacion.values.asNameMap()[json['verification']] ??
        Verificacion.unverified,
    visible: json['status'] != 'hidden',
    rut: json['rut'] as String?,
    fundadorHasta: switch (json['founder_until']) {
      final String f => DateTime.parse(f),
      _ => null,
    },
    renacPedido: json['renac_requested_at'] != null,
    verificacionPedida: json['verification_requested_at'] != null,
  );

  final Comercio comercio;
  final Verificacion verificacion;
  final bool visible;
  final String? rut;

  /// Socio Fundador: plan pago gratis hasta esta fecha.
  final DateTime? fundadorHasta;
  final bool renacPedido;
  final bool verificacionPedida;

  String get id => comercio.id;
}

/// Lugares marcados por usuarios (sin nombre) que se juntan a menos de 30 m
/// (`lugares_sin_reclamar_en_zona()`, 1.3.2).
class LugarSinReclamar {
  const LugarSinReclamar({
    required this.id,
    required this.categoria,
    required this.punto,
    required this.marcas,
    this.enlaceGoogle,
  });

  factory LugarSinReclamar.fromJson(Map<String, Object?> json) =>
      LugarSinReclamar(
        id: json['grupo']! as String,
        categoria: Categoria.leer(json['category']) ?? Categoria.vet,
        punto: Punto(
          (json['lat']! as num).toDouble(),
          (json['lng']! as num).toDouble(),
        ),
        marcas: (json['marcas'] as num?)?.toInt() ?? 1,
        enlaceGoogle: json['google_link'] as String?,
      );

  final String id;
  final Categoria categoria;
  final Punto punto;

  /// Una marca del grupo (el id es `rubro:marca`): va en la métrica
  /// `unclaimed_open` para contar las aperturas por grupo (D99).
  String get marcaId => id.substring(id.indexOf(':') + 1);

  /// "Marcado por N usuarios".
  final int marcas;
  final String? enlaceGoogle;

  Pin get pin => Pin(
    id: 'sin-reclamar:$id',
    tipo: TipoPin.sinReclamar,
    punto: punto,
    categoria: categoria,
  );
}

/// RUT uruguayo: 12 números (se ignoran espacios, puntos y guiones).
bool rutValido(String texto) =>
    RegExp(r'^[0-9]{12}$').hasMatch(texto.replaceAll(RegExp(r'[\s.\-]'), ''));

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

/// Hora de Uruguay (UTC−3, sin horario de verano desde 2015). "Abierto ahora"
/// se calcula con la hora del lugar (docs/06-reglas-negocio.md); al sumar
/// zonas de otros países se usa `zones.timezone`.
const diferenciaUruguay = Duration(hours: -3);

/// Si un comercio está abierto en un momento dado, y hasta cuándo o desde
/// cuándo.
class EstadoApertura {
  const EstadoApertura.abierto24h()
    : abierto = true,
      es24h = true,
      dia = null,
      minutos = null,
      diasHasta = null;

  const EstadoApertura.abierto({required int cierra})
    : abierto = true,
      es24h = false,
      dia = null,
      minutos = cierra,
      diasHasta = 0;

  const EstadoApertura.cerrado({
    required int this.dia,
    required int abre,
    required int this.diasHasta,
  }) : abierto = false,
       es24h = false,
       minutos = abre;

  /// Cerrado y sin ningún horario cargado.
  const EstadoApertura.sinHorario()
    : abierto = false,
      es24h = false,
      dia = null,
      minutos = null,
      diasHasta = null;

  final bool abierto;
  final bool es24h;

  /// Abierto: a qué hora cierra. Cerrado: a qué hora abre (minutos del día).
  final int? minutos;

  /// Cerrado: qué día abre (0 = lunes … 6 = domingo) y en cuántos días
  /// (0 = hoy, 1 = mañana).
  final int? dia;
  final int? diasHasta;

  @override
  bool operator ==(Object other) =>
      other is EstadoApertura &&
      other.abierto == abierto &&
      other.es24h == es24h &&
      other.minutos == minutos &&
      other.dia == dia &&
      other.diasHasta == diasHasta;

  @override
  int get hashCode => Object.hash(abierto, es24h, minutos, dia, diasHasta);

  @override
  String toString() =>
      'EstadoApertura(abierto: $abierto, 24h: $es24h, minutos: $minutos, '
      'dia: $dia, diasHasta: $diasHasta)';
}

/// Horario semanal de un comercio. Un día sin franjas está cerrado.
/// [especiales] reemplaza el horario de fechas puntuales (feriados, D75).
class Horario {
  const Horario(this.porDia, {this.especiales = const {}});

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

  /// Igual, con los días especiales de `special_days`
  /// (`{"2026-12-25": [], "2026-12-24": [["09:00","13:00"]]}`).
  factory Horario.conEspeciales(Object? horas, Object? especiales) {
    final base = Horario.fromJson(horas);
    final porFecha = <String, List<Franja>>{};
    if (especiales is Map) {
      for (final MapEntry(:key, :value) in especiales.entries) {
        if (key is! String || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(key)) {
          continue;
        }
        porFecha[key] = Horario.fromJson({'mon': value}).delDia(0);
      }
    }
    return Horario(base.porDia, especiales: porFecha);
  }

  /// Franjas por día: 0 = lunes … 6 = domingo.
  final Map<int, List<Franja>> porDia;

  /// Fechas puntuales (`2026-12-25`): reemplazan al día de la semana.
  final Map<String, List<Franja>> especiales;

  bool get vacio => porDia.isEmpty;

  List<Franja> delDia(int dia) => porDia[dia] ?? const [];

  /// Franjas de una fecha (hora de Uruguay): la especial si la hay.
  List<Franja> deLaFecha(DateTime fecha) =>
      especiales[fechaIso(fecha)] ?? delDia(fecha.weekday - 1);

  /// ¿Está abierto en [momento]? (se pasa a la hora de Uruguay).
  EstadoApertura estadoEn(DateTime momento) {
    final local = momento.toUtc().add(diferenciaUruguay);
    final hoy = local.weekday - 1;
    final ahora = local.hour * 60 + local.minute;
    DateTime fecha(int n) => DateTime(local.year, local.month, local.day + n);
    for (final f in deLaFecha(fecha(0))) {
      if (f.desde <= ahora && ahora < f.hasta) {
        return EstadoApertura.abierto(cierra: f.hasta);
      }
    }
    for (var n = 0; n <= 7; n++) {
      final dia = (hoy + n) % 7;
      final siguientes = [
        for (final f in deLaFecha(fecha(n)))
          if (n > 0 || f.desde > ahora) f.desde,
      ]..sort();
      if (siguientes.isNotEmpty) {
        return EstadoApertura.cerrado(
          dia: dia,
          abre: siguientes.first,
          diasHasta: n,
        );
      }
    }
    return const EstadoApertura.sinHorario();
  }

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
    required this.horario,
    this.punto,
    this.tipo = 'vet',
    this.modalidad = Modalidad.local,
    this.operadorRenac = false,
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
    this.facebook,
    this.promo,
    this.plan = PlanComercio.basic,
    this.cobertura,
    this.tieneDuenio = false,
    this.fotos = const [],
  });

  factory Comercio.fromJson(Map<String, Object?> json) => Comercio(
    id: json['id']! as String,
    tipo: (json['business_type'] as String?) ?? 'vet',
    modalidad: Modalidad.values.asNameMap()[json['kind']] ?? Modalidad.local,
    operadorRenac: json['renac_operator'] == true,
    nombre: json['name']! as String,
    descripcion: json['description'] as String?,
    direccion: json['address'] as String?,
    punto: switch ((json['lat'], json['lng'])) {
      (final num lat, final num lng) => Punto(lat.toDouble(), lng.toDouble()),
      _ => null,
    },
    telefono: json['phone'] as String?,
    whatsapp: json['whatsapp'] as String?,
    web: json['web'] as String?,
    instagram: json['instagram'] as String?,
    horario: Horario.conEspeciales(json['hours'], json['special_days']),
    es24h: json['is_24h'] == true,
    urgencias: json['emergencies'] == true,
    especieIds: [
      for (final id in (json['species_ids'] as List?) ?? const [])
        (id as num).toInt(),
    ],
    verificado: json['verified'] == true,
    esEjemplo: json['is_sample'] == true,
    facebook: json['facebook'] as String?,
    promo: json['promo'] as String?,
    plan: PlanComercio.values.asNameMap()[json['plan']] ?? PlanComercio.basic,
    cobertura: json['coverage'] as String?,
    tieneDuenio: json['has_owner'] == true,
    fotos: [for (final f in (json['photos'] as List?) ?? const []) '$f'],
  );

  final String id;
  final String tipo;
  final Modalidad modalidad;

  /// Insignia "Operador RENAC" (coloca microchip; la marca el administrador).
  final bool operadorRenac;
  final String nombre;
  final String? descripcion;
  final String? direccion;

  /// `null` si no tiene local (online o a domicilio).
  final Punto? punto;

  Categoria get categoria => Categoria.leer(tipo) ?? Categoria.vet;
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
  final String? facebook;

  /// Promoción (solo planes pagos; la base no la manda con plan Básico).
  final String? promo;
  final PlanComercio plan;

  /// Sin local: dónde trabaja ("Pando y alrededores").
  final String? cobertura;

  /// Ya tiene una cuenta a cargo (si no, se ofrece "¿Es tu negocio?").
  final bool tieneDuenio;

  /// Rutas en el bucket público `business-photos`.
  final List<String> fotos;

  /// ¿Está abierto en [momento]?
  EstadoApertura estadoEn(DateTime momento) =>
      es24h ? const EstadoApertura.abierto24h() : horario.estadoEn(momento);

  /// Pin del mapa (`null` sin local): las veterinarias de urgencia o 24 h se
  /// destacan; los lugares que aceptan mascotas y los demás rubros tienen su
  /// color.
  Pin? get pin => switch (punto) {
    final p? => Pin(
      id: id,
      tipo: switch (categoria) {
        Categoria.vet =>
          urgencias || es24h ? TipoPin.urgencia : TipoPin.veterinaria,
        Categoria.petFriendly => TipoPin.aceptaMascotas,
        _ => TipoPin.comercio,
      },
      punto: p,
      categoria: categoria,
    ),
    null => null,
  };
}

/// Página pública del comercio para compartir (2.10b, D90): `<base>/n/<id>`.
/// Solo existe con el plan Plus.
String urlPaginaComercio(String id, {String base = urlPublicaPorDefecto}) =>
    '${base.replaceAll(RegExp(r'/+$'), '')}/n/$id';
