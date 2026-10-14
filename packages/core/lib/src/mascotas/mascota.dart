/// Sexo de la mascota (valores iguales a la base: `pet_sex`).
enum Sexo { male, female, unknown }

/// Mascota de un dueño (tabla `pets`).
class Mascota {
  const Mascota({
    required this.id,
    required this.nombre,
    required this.especieId,
    this.razaId,
    this.razaOtra,
    this.sexo = Sexo.unknown,
    this.color,
    this.senas,
    this.nacimiento,
    this.fotoPath,
    this.microchip,
    this.castrada,
    this.notas,
  });

  factory Mascota.fromJson(Map<String, Object?> json) => Mascota(
    id: json['id']! as String,
    nombre: json['name']! as String,
    especieId: (json['species_id']! as num).toInt(),
    razaId: (json['breed_id'] as num?)?.toInt(),
    razaOtra: json['breed_other'] as String?,
    sexo: Sexo.values.asNameMap()[json['sex']] ?? Sexo.unknown,
    color: json['color'] as String?,
    senas: json['marks'] as String?,
    nacimiento: switch (json['birth']) {
      final String fecha => DateTime.parse(fecha),
      _ => null,
    },
    fotoPath: json['photo_path'] as String?,
    microchip: json['microchip'] as String?,
    castrada: json['neutered'] as bool?,
    notas: json['notes'] as String?,
  );

  final String id;
  final String nombre;
  final int especieId;
  final int? razaId;
  final String? razaOtra;
  final Sexo sexo;
  final String? color;
  final String? senas;
  final DateTime? nacimiento;
  final String? fotoPath;
  final String? microchip;
  final bool? castrada;
  final String? notas;

  /// Columnas editables (sin `id` ni `owner_id`, que pone la base).
  Map<String, Object?> toJson() => {
    'name': nombre.trim(),
    'species_id': especieId,
    'breed_id': razaId,
    'breed_other': _vacioANulo(razaOtra),
    'sex': sexo.name,
    'color': _vacioANulo(color),
    'marks': _vacioANulo(senas),
    'birth': nacimiento == null ? null : fechaIso(nacimiento!),
    'photo_path': fotoPath,
    'microchip': _vacioANulo(microchip),
    'neutered': castrada,
    'notes': _vacioANulo(notas),
  };

  Mascota copyWith({String? fotoPath}) => Mascota(
    id: id,
    nombre: nombre,
    especieId: especieId,
    razaId: razaId,
    razaOtra: razaOtra,
    sexo: sexo,
    color: color,
    senas: senas,
    nacimiento: nacimiento,
    fotoPath: fotoPath ?? this.fotoPath,
    microchip: microchip,
    castrada: castrada,
    notas: notas,
  );

  static String? _vacioANulo(String? texto) {
    final limpio = texto?.trim();
    return limpio == null || limpio.isEmpty ? null : limpio;
  }
}

/// `2026-10-14` (solo la fecha, sin hora ni zona).
String fechaIso(DateTime fecha) =>
    '${fecha.year.toString().padLeft(4, '0')}-'
    '${fecha.month.toString().padLeft(2, '0')}-'
    '${fecha.day.toString().padLeft(2, '0')}';

/// Edad en años y meses cumplidos a la fecha [hoy].
({int anios, int meses}) edad(DateTime nacimiento, DateTime hoy) {
  var meses = (hoy.year - nacimiento.year) * 12 + hoy.month - nacimiento.month;
  if (hoy.day < nacimiento.day) meses--;
  if (meses < 0) meses = 0;
  return (anios: meses ~/ 12, meses: meses % 12);
}

/// Resultado de validar un número de microchip.
enum ValidacionMicrochip { valido, vacio, noSonQuinceNumeros }

/// Microchip ISO 11784/11785: 15 números (se ignoran espacios y guiones).
ValidacionMicrochip validarMicrochip(String? texto) {
  final limpio = normalizarMicrochip(texto);
  if (limpio.isEmpty) return ValidacionMicrochip.vacio;
  return RegExp(r'^[0-9]{15}$').hasMatch(limpio)
      ? ValidacionMicrochip.valido
      : ValidacionMicrochip.noSonQuinceNumeros;
}

String normalizarMicrochip(String? texto) =>
    (texto ?? '').replaceAll(RegExp(r'[\s-]'), '');
