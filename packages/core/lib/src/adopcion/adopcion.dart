/// Adopción responsable (etapa 2.0, D79): modelos, compatibilidad y
/// calculadora de costos.
library;

/// Etapas de una solicitud (`adoption_requests.stage`).
enum EtapaAdopcion {
  interest,
  questionnaire,
  interview,
  visit,
  agreement,
  adopted,
  rejected,
  withdrawn;

  bool get terminada =>
      this == adopted || this == rejected || this == withdrawn;

  /// La siguiente etapa que puede poner quien publica (o `null`).
  EtapaAdopcion? get siguiente => switch (this) {
    interest => questionnaire,
    questionnaire => interview,
    interview => visit,
    visit => agreement,
    _ => null,
  };
}

EtapaAdopcion _etapa(Object? v) =>
    EtapaAdopcion.values.asNameMap()[v] ?? EtapaAdopcion.interest;

/// Perfil de adoptante (`adopter_profiles`): se completa una vez.
class PerfilAdoptante {
  const PerfilAdoptante({
    this.vivienda,
    this.patio,
    this.horasSolo,
    this.experiencia,
    this.otrosAnimales,
    this.ninos,
    this.casaDeAcuerdo,
  });

  factory PerfilAdoptante.fromJson(Map<String, Object?> json) =>
      PerfilAdoptante(
        vivienda: json['housing'] as String?,
        patio: json['has_yard'] as bool?,
        horasSolo: (json['hours_alone'] as num?)?.toInt(),
        experiencia: json['experience'] as String?,
        otrosAnimales: json['other_pets'] as bool?,
        ninos: json['kids'] as bool?,
        casaDeAcuerdo: json['household_agrees'] as bool?,
      );

  /// `casa`, `apartamento` u `otro`.
  final String? vivienda;
  final bool? patio;
  final int? horasSolo;

  /// `ninguna`, `alguna` o `mucha`.
  final String? experiencia;
  final bool? otrosAnimales;
  final bool? ninos;
  final bool? casaDeAcuerdo;

  bool get completo =>
      vivienda != null && patio != null && horasSolo != null && ninos != null;

  Map<String, Object?> toJson() => {
    'housing': vivienda,
    'has_yard': patio,
    'hours_alone': horasSolo,
    'experience': experiencia,
    'other_pets': otrosAnimales,
    'kids': ninos,
    'household_agrees': casaDeAcuerdo,
  };
}

/// Un animal en adopción (`adopciones_disponibles()`).
class AnimalAdopcion {
  const AnimalAdopcion({
    required this.id,
    required this.publicacionId,
    required this.especieId,
    required this.fotos,
    this.nombre,
    this.raza,
    this.edadMeses,
    this.tamano,
    this.energia,
    this.castrado,
    this.vacunado,
    this.microchip,
    this.conNinos,
    this.conPerros,
    this.conGatos,
    this.necesitaPatio = false,
    this.necesidades,
    this.descripcion,
    this.requisitos,
    this.aporte,
    this.aporteCubre,
    this.deRefugio = false,
    this.refugio,
    this.camada = false,
    this.mio = false,
    this.enTransito = false,
  });

  factory AnimalAdopcion.fromJson(Map<String, Object?> json) => AnimalAdopcion(
    id: json['animal_id']! as String,
    publicacionId: json['adoption_id']! as String,
    nombre: json['name'] as String?,
    especieId: (json['species_id']! as num).toInt(),
    raza: switch (json['breed']) {
      final String r when r.isNotEmpty => r,
      _ => null,
    },
    edadMeses: (json['age_months'] as num?)?.toInt(),
    tamano: json['size'] as String?,
    energia: json['energy'] as String?,
    castrado: json['neutered'] as bool?,
    vacunado: json['vaccinated'] as bool?,
    microchip: json['microchip'] as bool?,
    conNinos: json['good_with_kids'] as bool?,
    conPerros: json['good_with_dogs'] as bool?,
    conGatos: json['good_with_cats'] as bool?,
    necesitaPatio: json['needs_yard'] == true,
    necesidades: json['special_needs'] as String?,
    fotos: [for (final f in (json['photos'] as List?) ?? const []) '$f'],
    descripcion: json['description'] as String?,
    requisitos: json['requirements'] as String?,
    aporte: (json['contribution_amount'] as num?)?.toInt(),
    aporteCubre: json['contribution_covers'] as String?,
    deRefugio: json['publisher_kind'] == 'shelter',
    refugio: json['shelter_name'] as String?,
    camada: json['is_litter'] == true,
    mio: json['mine'] == true,
    enTransito: json['in_foster'] == true,
  );

  final String id;
  final String publicacionId;
  final String? nombre;
  final int especieId;
  final String? raza;
  final int? edadMeses;

  /// `chico`, `mediano` o `grande`.
  final String? tamano;

  /// `baja`, `media` o `alta`.
  final String? energia;
  final bool? castrado;
  final bool? vacunado;
  final bool? microchip;
  final bool? conNinos;
  final bool? conPerros;
  final bool? conGatos;
  final bool necesitaPatio;
  final String? necesidades;
  final List<String> fotos;
  final String? descripcion;
  final String? requisitos;

  /// Aporte transparente (solo refugios verificados).
  final int? aporte;
  final String? aporteCubre;
  final bool deRefugio;
  final String? refugio;
  final bool camada;
  final bool mio;

  /// Está en un hogar de tránsito (3.4b): no se dice dónde.
  final bool enTransito;
}

/// Lo que la compatibilidad señala (orienta, no bloquea: 03 §11).
enum AvisoCompatibilidad {
  necesitaPatio,
  noConNinos,
  noConOtrosAnimales,
  muchoTiempoSolo,
  casaNoDeAcuerdo,
  sinExperienciaConNecesidades,
}

/// Cruza el perfil con la ficha. Vacío = buena compatibilidad.
List<AvisoCompatibilidad> compatibilidad(
  PerfilAdoptante perfil,
  AnimalAdopcion animal,
) => [
  if (animal.necesitaPatio &&
      (perfil.patio == false || perfil.vivienda == 'apartamento'))
    AvisoCompatibilidad.necesitaPatio,
  if (perfil.ninos == true && animal.conNinos == false)
    AvisoCompatibilidad.noConNinos,
  if (perfil.otrosAnimales == true &&
      (animal.conPerros == false || animal.conGatos == false))
    AvisoCompatibilidad.noConOtrosAnimales,
  if ((perfil.horasSolo ?? 0) >= 8 && animal.energia == 'alta')
    AvisoCompatibilidad.muchoTiempoSolo,
  if (perfil.casaDeAcuerdo == false) AvisoCompatibilidad.casaNoDeAcuerdo,
  if (perfil.experiencia == 'ninguna' &&
      (animal.necesidades?.trim().isNotEmpty ?? false))
    AvisoCompatibilidad.sinExperienciaConNecesidades,
];

/// Una solicitud propia (`mis_solicitudes_adopcion()`).
class SolicitudAdopcion {
  const SolicitudAdopcion({
    required this.id,
    required this.animalId,
    required this.especieId,
    required this.etapa,
    this.nombre,
    this.fotos = const [],
    this.compromisoAceptado = false,
  });

  factory SolicitudAdopcion.fromJson(Map<String, Object?> json) =>
      SolicitudAdopcion(
        id: json['id']! as String,
        animalId: json['animal_id']! as String,
        nombre: json['name'] as String?,
        especieId: (json['species_id']! as num).toInt(),
        fotos: [for (final f in (json['photos'] as List?) ?? const []) '$f'],
        etapa: _etapa(json['stage']),
        compromisoAceptado: json['compromiso_aceptado'] == true,
      );

  final String id;
  final String animalId;
  final String? nombre;
  final int especieId;
  final List<String> fotos;
  final EtapaAdopcion etapa;
  final bool compromisoAceptado;
}

/// Una solicitud que me llegó como publicador (`solicitudes_recibidas()`).
class SolicitudRecibida {
  const SolicitudRecibida({
    required this.id,
    required this.animalId,
    required this.etapa,
    this.animal,
    this.mensaje,
    this.adoptante = '',
    this.perfil,
    this.nota,
    this.seguimiento = const [],
  });

  factory SolicitudRecibida.fromJson(Map<String, Object?> json) =>
      SolicitudRecibida(
        id: json['id']! as String,
        animalId: json['animal_id']! as String,
        animal: json['animal'] as String?,
        etapa: _etapa(json['stage']),
        mensaje: json['message'] as String?,
        adoptante: (json['adoptante'] as String?) ?? '',
        perfil: switch (json['perfil']) {
          final Map<String, Object?> p => PerfilAdoptante.fromJson(p),
          final Map<dynamic, dynamic> p => PerfilAdoptante.fromJson(
            p.cast<String, Object?>(),
          ),
          _ => null,
        },
        nota: json['nota'] as String?,
        seguimiento: [
          for (final s in (json['seguimiento'] as List?) ?? const [])
            if (s is Map)
              (
                dia: (s['day'] as num).toInt(),
                respuesta: s['answer'] as String?,
                foto: s['photo'] as String?,
              ),
        ],
      );

  final String id;
  final String animalId;
  final String? animal;
  final EtapaAdopcion etapa;
  final String? mensaje;
  final String adoptante;
  final PerfilAdoptante? perfil;

  /// Nota privada de quien publica.
  final String? nota;
  final List<({int dia, String? respuesta, String? foto})> seguimiento;
}

/// Un seguimiento pendiente o respondido (`mis_seguimientos()`).
class Seguimiento {
  const Seguimiento({
    required this.id,
    required this.dia,
    required this.vence,
    required this.respondido,
    this.animal,
    this.mascotaId,
  });

  factory Seguimiento.fromJson(Map<String, Object?> json) => Seguimiento(
    id: json['id']! as String,
    dia: (json['day']! as num).toInt(),
    vence: DateTime.parse(json['due_on']! as String),
    respondido: json['answered'] == true,
    animal: json['animal'] as String?,
    mascotaId: json['pet_id'] as String?,
  );

  final String id;

  /// 7, 30 o 90.
  final int dia;
  final DateTime vence;
  final bool respondido;
  final String? animal;
  final String? mascotaId;

  bool disponible(DateTime hoy) =>
      !respondido &&
      !DateTime(
        vence.year,
        vence.month,
        vence.day,
      ).isAfter(DateTime(hoy.year, hoy.month, hoy.day));
}

/// Calculadora de costos (03 §11): la persona pone sus propios montos por
/// mes (o por año, que se pasan a mes) y la app suma. No inventa precios.
class ItemCosto {
  const ItemCosto({required this.clave, this.monto = 0, this.anual = false});

  final String clave;
  final int monto;

  /// El monto es por año (vacunas, castración): se divide entre 12.
  final bool anual;

  double get porMes => anual ? monto / 12 : monto.toDouble();
}

/// Total por mes y por año.
({int mes, int anio}) totalCostos(Iterable<ItemCosto> items) {
  final mes = items.fold<double>(0, (s, i) => s + i.porMes);
  return (mes: mes.round(), anio: (mes * 12).round());
}
