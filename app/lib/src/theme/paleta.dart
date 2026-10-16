import 'package:flutter/material.dart';

/// Colores de un modo (claro u oscuro) de una paleta de la marca.
///
/// Cada par texto/fondo tiene contraste ≥ 4,5:1 (lo verifica `tema_test.dart`).
/// Detalle y valores en `docs/14-brief-identidad-visual.md` §10.
@immutable
class ColoresModo {
  const ColoresModo({
    required this.fondo,
    required this.texto,
    required this.textoSuave,
    required this.primario,
    required this.sobrePrimario,
    required this.acento,
    required this.sobreAcento,
    required this.error,
    required this.sobreError,
    required this.exito,
    required this.urgencia,
  });

  final Color fondo;
  final Color texto;
  final Color textoSuave;

  /// Botones, enlaces y elementos principales.
  final Color primario;
  final Color sobrePrimario;

  /// SOS y lo destacado. Solo de relleno: como texto no siempre contrasta.
  final Color acento;
  final Color sobreAcento;

  final Color error;
  final Color sobreError;

  /// Texto o ícono de "abierto ahora" y confirmaciones.
  final Color exito;

  /// Texto o ícono de "urgencias / 24 h" (el pin ámbar no contrasta como texto).
  final Color urgencia;
}

/// Archivo de una tipografía que se descarga al elegir un tema Pro
/// (se sirve desde `app/web/fuentes/`, no viene dentro de la app).
@immutable
class ArchivoFuente {
  const ArchivoFuente(this.familia, this.archivo);

  final String familia;
  final String archivo;
}

/// Una identidad visual completa: colores de los dos modos y tipografías.
///
/// [cielo] es la de la marca y la de todos; [faro], [vecinos] y [pop] son
/// temas del plan Pro (D62). Detalle en `docs/14-brief-identidad-visual.md` §10.
@immutable
class Paleta {
  const Paleta({
    required this.id,
    required this.claro,
    required this.oscuro,
    required this.fuenteTitulos,
    required this.fuenteTexto,
    this.fuentesADescargar = const [],
  });

  /// Identificador estable (se guarda en el dispositivo y va en las métricas).
  final String id;
  final ColoresModo claro;
  final ColoresModo oscuro;
  final String fuenteTitulos;
  final String fuenteTexto;

  /// Vacía si las tipografías ya vienen con la app (Cielo).
  final List<ArchivoFuente> fuentesADescargar;

  /// Cielo primero; el orden es el del selector de Ajustes.
  static const todas = [cielo, faro, vecinos, pop];

  /// La paleta con ese id, o Cielo si no existe (por ejemplo, un id viejo).
  static Paleta porId(String? id) =>
      todas.firstWhere((p) => p.id == id, orElse: () => cielo);

  ColoresModo modo(Brightness brillo) =>
      brillo == Brightness.dark ? oscuro : claro;

  /// Identidad de la marca: C · Cielo (D62).
  static const cielo = Paleta(
    id: 'cielo',
    claro: ColoresModo(
      fondo: Color(0xFFF6F4EF), // hueso
      texto: Color(0xFF102A35), // tinta
      textoSuave: Color(0xFF4A5F68),
      primario: Color(0xFF0F5E7A), // azul petróleo
      sobrePrimario: Color(0xFFFFFFFF),
      acento: Color(0xFFFF7A59), // coral
      sobreAcento: Color(0xFF102A35),
      error: Color(0xFFB3261E),
      sobreError: Color(0xFFFFFFFF),
      exito: Color(0xFF17705F),
      urgencia: Color(0xFF9A4A00),
    ),
    oscuro: ColoresModo(
      fondo: Color(0xFF0E1E26),
      texto: Color(0xFFECE9E2),
      textoSuave: Color(0xFFA9B8BE),
      primario: Color(0xFF7CC4DE),
      sobrePrimario: Color(0xFF0E1E26),
      acento: Color(0xFFFF8A6B),
      sobreAcento: Color(0xFF0E1E26),
      error: Color(0xFFFF8A80),
      sobreError: Color(0xFF0E1E26),
      exito: Color(0xFF5ED3BF),
      urgencia: Color(0xFFFFB238),
    ),
    fuenteTitulos: 'Sora',
    fuenteTexto: 'SourceSans3',
  );

  /// Tema Pro A · Faro: señal de rescate (naranja y azul noche).
  static const faro = Paleta(
    id: 'faro',
    claro: ColoresModo(
      fondo: Color(0xFFFFF8F0),
      texto: Color(0xFF14213D),
      textoSuave: Color(0xFF4F566B),
      primario: Color(0xFF14213D),
      sobrePrimario: Color(0xFFFFFFFF),
      acento: Color(0xFFF25C05),
      sobreAcento: Color(0xFF14213D),
      error: Color(0xFFB3261E),
      sobreError: Color(0xFFFFFFFF),
      exito: Color(0xFF1F7A70),
      urgencia: Color(0xFF9A4A00),
    ),
    oscuro: ColoresModo(
      fondo: Color(0xFF0F1626),
      texto: Color(0xFFF3EEE8),
      textoSuave: Color(0xFFB3B8C6),
      primario: Color(0xFF9DB4E8),
      sobrePrimario: Color(0xFF0F1626),
      acento: Color(0xFFFF8A3D),
      sobreAcento: Color(0xFF0F1626),
      error: Color(0xFFFF8A80),
      sobreError: Color(0xFF0F1626),
      exito: Color(0xFF4FC3B5),
      urgencia: Color(0xFFFFB238),
    ),
    fuenteTitulos: 'BricolageGrotesque',
    fuenteTexto: 'AtkinsonHyperlegible',
    fuentesADescargar: [
      ArchivoFuente('BricolageGrotesque', 'BricolageGrotesque-SemiBold.ttf'),
      ArchivoFuente('AtkinsonHyperlegible', 'AtkinsonHyperlegible-Regular.ttf'),
      ArchivoFuente('AtkinsonHyperlegible', 'AtkinsonHyperlegible-Bold.ttf'),
    ],
  );

  /// Tema Pro B · Vecinos: el barrio (terracota y mostaza).
  static const vecinos = Paleta(
    id: 'vecinos',
    claro: ColoresModo(
      fondo: Color(0xFFFAF3E3),
      texto: Color(0xFF2B2118),
      textoSuave: Color(0xFF5E5246),
      primario: Color(0xFFB5462F),
      sobrePrimario: Color(0xFFFFFFFF),
      acento: Color(0xFFF2C14E),
      sobreAcento: Color(0xFF2B2118),
      error: Color(0xFFA8201A),
      sobreError: Color(0xFFFFFFFF),
      exito: Color(0xFF3E5C4A),
      urgencia: Color(0xFF8A4500),
    ),
    oscuro: ColoresModo(
      fondo: Color(0xFF1E1914),
      texto: Color(0xFFF4ECDD),
      textoSuave: Color(0xFFC2B6A3),
      primario: Color(0xFFE8836B),
      sobrePrimario: Color(0xFF1E1914),
      acento: Color(0xFFF2C14E),
      sobreAcento: Color(0xFF1E1914),
      error: Color(0xFFFF8A80),
      sobreError: Color(0xFF1E1914),
      exito: Color(0xFF8FC9A0),
      urgencia: Color(0xFFFFB238),
    ),
    fuenteTitulos: 'Fraunces',
    fuenteTexto: 'NunitoSans',
    fuentesADescargar: [
      ArchivoFuente('Fraunces', 'Fraunces-SemiBold.ttf'),
      ArchivoFuente('NunitoSans', 'NunitoSans-Regular.ttf'),
      ArchivoFuente('NunitoSans', 'NunitoSans-Bold.ttf'),
    ],
  );

  /// Tema Pro D · Pop: sticker y redes (violeta y amarillo).
  static const pop = Paleta(
    id: 'pop',
    claro: ColoresModo(
      fondo: Color(0xFFF3EEFF),
      texto: Color(0xFF17151F),
      textoSuave: Color(0xFF4D4860),
      primario: Color(0xFF5B2EBB),
      sobrePrimario: Color(0xFFFFFFFF),
      acento: Color(0xFFFFD23F),
      sobreAcento: Color(0xFF17151F),
      error: Color(0xFFB3261E),
      sobreError: Color(0xFFFFFFFF),
      exito: Color(0xFF17705F),
      urgencia: Color(0xFF8F4500),
    ),
    oscuro: ColoresModo(
      fondo: Color(0xFF17151F),
      texto: Color(0xFFF1EDFA),
      textoSuave: Color(0xFFB7B0C9),
      primario: Color(0xFFB49BFF),
      sobrePrimario: Color(0xFF17151F),
      acento: Color(0xFFFFD23F),
      sobreAcento: Color(0xFF17151F),
      error: Color(0xFFFF8A80),
      sobreError: Color(0xFF17151F),
      exito: Color(0xFF5ED3BF),
      urgencia: Color(0xFFFFB238),
    ),
    fuenteTitulos: 'Baloo2',
    fuenteTexto: 'Figtree',
    fuentesADescargar: [
      ArchivoFuente('Baloo2', 'Baloo2-SemiBold.ttf'),
      ArchivoFuente('Figtree', 'Figtree-Regular.ttf'),
      ArchivoFuente('Figtree', 'Figtree-Bold.ttf'),
    ],
  );
}

/// Colores de la marca que Material no tiene como rol propio.
/// Uso: `Theme.of(context).extension<ColoresMarca>()!` o `context.marca`.
@immutable
class ColoresMarca extends ThemeExtension<ColoresMarca> {
  const ColoresMarca({
    required this.acento,
    required this.sobreAcento,
    required this.exito,
    required this.urgencia,
  });

  factory ColoresMarca.de(ColoresModo c) => ColoresMarca(
    acento: c.acento,
    sobreAcento: c.sobreAcento,
    exito: c.exito,
    urgencia: c.urgencia,
  );

  final Color acento;
  final Color sobreAcento;
  final Color exito;
  final Color urgencia;

  @override
  ColoresMarca copyWith({
    Color? acento,
    Color? sobreAcento,
    Color? exito,
    Color? urgencia,
  }) => ColoresMarca(
    acento: acento ?? this.acento,
    sobreAcento: sobreAcento ?? this.sobreAcento,
    exito: exito ?? this.exito,
    urgencia: urgencia ?? this.urgencia,
  );

  @override
  ColoresMarca lerp(ColoresMarca? other, double t) {
    if (other == null) return this;
    return ColoresMarca(
      acento: Color.lerp(acento, other.acento, t)!,
      sobreAcento: Color.lerp(sobreAcento, other.sobreAcento, t)!,
      exito: Color.lerp(exito, other.exito, t)!,
      urgencia: Color.lerp(urgencia, other.urgencia, t)!,
    );
  }
}

extension ColoresMarcaContexto on BuildContext {
  ColoresMarca get marca => Theme.of(this).extension<ColoresMarca>()!;
}
