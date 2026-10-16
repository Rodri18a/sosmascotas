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

/// Una identidad visual completa: colores de los dos modos y tipografías.
///
/// Por ahora solo existe [cielo]; Faro, Vecinos y Pop llegan como temas del
/// plan Pro en el paso 0.8.0a (D62).
@immutable
class Paleta {
  const Paleta({
    required this.claro,
    required this.oscuro,
    required this.fuenteTitulos,
    required this.fuenteTexto,
  });

  final ColoresModo claro;
  final ColoresModo oscuro;
  final String fuenteTitulos;
  final String fuenteTexto;

  ColoresModo modo(Brightness brillo) =>
      brillo == Brightness.dark ? oscuro : claro;

  /// Identidad de la marca: C · Cielo (D62).
  static const cielo = Paleta(
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
