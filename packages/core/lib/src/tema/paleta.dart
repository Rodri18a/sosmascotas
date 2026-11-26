import 'package:flutter/material.dart';

/// Colores de un modo (claro u oscuro) de una paleta de la marca.
///
/// Cada par texto/fondo tiene contraste ≥ 4,5:1 (lo verifica `tema_test.dart`).
/// Detalle y valores en `docs/23-guia-visual.md` (D146); temas Pro en `docs/14-brief-identidad-visual.md` §10.
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
    Color? barra,
    Color? sobreBarra,
    Color? simbolo,
    this.superficies,
  }) : _barra = barra,
       _sobreBarra = sobreBarra,
       _simbolo = simbolo;

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

  final Color? _barra;
  final Color? _sobreBarra;
  final Color? _simbolo;

  /// Superficies y contenedores con colores fijos (tema Moderno, D171). Sin
  /// ellas, salen del fondo, el texto y la semilla (los demás temas).
  final Superficies? superficies;

  /// Fondo de la barra de arriba y de la de abajo: el primario, salvo en
  /// Blanco y negro, que las tiene blancas.
  Color get barra => _barra ?? primario;
  Color get sobreBarra => _sobreBarra ?? sobrePrimario;

  /// Color del símbolo de la marca: botón redondo del Mapa y logo.
  /// Lleva íconos blancos encima; en los temas Pro es el primario.
  Color get simbolo => _simbolo ?? primario;

  /// Íconos sobre [simbolo]: blanco en Huellamy (3:1 o más, como pide un
  /// ícono); en los temas Pro, el de sobre el primario.
  Color get sobreSimbolo =>
      _simbolo == null ? sobrePrimario : const Color(0xFFFFFFFF);
}

/// Superficies fijas de un tema que no las arma de la semilla (Moderno, D171).
@immutable
class Superficies {
  const Superficies({
    required this.tarjeta,
    required this.chip,
    required this.borde,
    required this.contorno,
    required this.contenedorPrimario,
    required this.sobreContenedorPrimario,
    required this.franja,
    required this.sobreFranja,
    required this.degradado,
    required this.sobreDegradadoSuave,
  });

  /// Tarjetas, barras, diálogos y hojas.
  final Color tarjeta;

  /// Chips y bloques secundarios.
  final Color chip;

  /// Bordes finos de tarjetas, campos y separadores.
  final Color borde;

  /// Bordes más marcados.
  final Color contorno;

  final Color contenedorPrimario;
  final Color sobreContenedorPrimario;

  /// Franjas suaves e indicador de la barra de abajo.
  final Color franja;
  final Color sobreFranja;

  /// Degradé del menú lateral y de la pantalla de ingreso (texto blanco).
  final List<Color> degradado;

  /// Subtítulos sobre el degradé (el título va en blanco).
  final Color sobreDegradadoSuave;
}

/// Cómo se arman las piezas del tema: el de Huellamy (barras de color,
/// tarjetas con sombra, botones en píldora) o el Moderno (barras blancas
/// con una línea, tarjetas con borde fino, botones de radio 16; D171).
enum EstiloTema { huellamy, moderno }

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
/// [cielo] es la de la marca y la de todos; [faro], [vecinos], [pop] y
/// [blancoNegro] son temas del plan Pro (D62, D120). Detalle en `docs/14-brief-identidad-visual.md` §10.
@immutable
class Paleta {
  const Paleta({
    required this.id,
    required this.claro,
    required this.oscuro,
    required this.fuenteTitulos,
    required this.fuenteTexto,
    this.pesoTitulos = FontWeight.w600,
    this.fuentesADescargar = const [],
    this.estilo = EstiloTema.huellamy,
  });

  /// Identificador estable (se guarda en el dispositivo y va en las métricas).
  final String id;
  final ColoresModo claro;
  final ColoresModo oscuro;
  final String fuenteTitulos;
  final String fuenteTexto;

  /// Peso de los títulos: las tipografías de los temas Pro solo traen SemiBold.
  final FontWeight pesoTitulos;

  /// Vacía si las tipografías ya vienen con la app (Huellamy, Moderno).
  final List<ArchivoFuente> fuentesADescargar;

  final EstiloTema estilo;

  /// La de la marca primero; el orden es el del selector de Ajustes.
  static const todas = [cielo, moderno, faro, vecinos, pop, blancoNegro];

  /// Las que puede elegir cualquiera (D172): Moderno y la de la marca. Las
  /// demás son del plan Pro.
  static const gratuitas = [moderno, cielo];

  /// La que trae la app si la persona nunca eligió (D172).
  static const porDefecto = moderno;

  bool get esGratis => gratuitas.any((p) => p.id == id);

  /// La paleta con ese id, o la de la marca si no existe (por ejemplo, un id viejo).
  static Paleta porId(String? id) =>
      todas.firstWhere((p) => p.id == id, orElse: () => cielo);

  ColoresModo modo(Brightness brillo) =>
      brillo == Brightness.dark ? oscuro : claro;

  /// Identidad de la marca: Huellamy (D146, `docs/23-guia-visual.md`).
  /// Conserva el id `cielo` (D62) porque está guardado en los dispositivos.
  static const cielo = Paleta(
    id: 'cielo',
    claro: ColoresModo(
      fondo: Color(0xFFF0F8FE), // celeste muy claro
      texto: Color(0xFF13294B), // azul noche
      textoSuave: Color(0xFF4A5B72),
      primario: Color(0xFF0B4F94), // azul profundo: barras y botones
      sobrePrimario: Color(0xFFFFFFFF),
      acento: Color(0xFFE8923A), // naranja de Ami: SOS y destacados
      sobreAcento: Color(0xFF13294B),
      error: Color(0xFFB3261E),
      sobreError: Color(0xFFFFFFFF),
      exito: Color(0xFF17705F),
      urgencia: Color(0xFF9A4A00),
      // Azul brillante del logo (#1AA0EA), apenas más oscuro para que el
      // ícono blanco del botón del Mapa llegue a 3:1.
      simbolo: Color(0xFF1798DF),
    ),
    oscuro: ColoresModo(
      fondo: Color(0xFF0E1A26),
      texto: Color(0xFFE8F1F8),
      textoSuave: Color(0xFFA9BCCB),
      primario: Color(0xFF7CC4F5),
      sobrePrimario: Color(0xFF0E1A26),
      acento: Color(0xFFF5A75A),
      sobreAcento: Color(0xFF0E1A26),
      error: Color(0xFFFF8A80),
      sobreError: Color(0xFF0E1A26),
      exito: Color(0xFF5ED3BF),
      urgencia: Color(0xFFFFB238),
      simbolo: Color(0xFF1798DF),
    ),
    fuenteTitulos: 'Nunito',
    fuenteTexto: 'NunitoSans',
    pesoTitulos: FontWeight.w800,
  );

  /// Huellamy Comercios (D129, D146): la de la marca con el azul profundo
  /// también en el símbolo. No se elige en Ajustes (no está en [todas]).
  static const comercios = Paleta(
    id: 'comercios',
    claro: ColoresModo(
      fondo: Color(0xFFF0F8FE),
      texto: Color(0xFF13294B),
      textoSuave: Color(0xFF4A5B72),
      primario: Color(0xFF0B4F94),
      sobrePrimario: Color(0xFFFFFFFF),
      acento: Color(0xFFE8923A),
      sobreAcento: Color(0xFF13294B),
      error: Color(0xFFB3261E),
      sobreError: Color(0xFFFFFFFF),
      exito: Color(0xFF17705F),
      urgencia: Color(0xFF9A4A00),
      simbolo: Color(0xFF0B4F94),
    ),
    oscuro: ColoresModo(
      fondo: Color(0xFF0E1A26),
      texto: Color(0xFFE8F1F8),
      textoSuave: Color(0xFFA9BCCB),
      primario: Color(0xFF7CC4F5),
      sobrePrimario: Color(0xFF0E1A26),
      acento: Color(0xFFF5A75A),
      sobreAcento: Color(0xFF0E1A26),
      error: Color(0xFFFF8A80),
      sobreError: Color(0xFF0E1A26),
      exito: Color(0xFF5ED3BF),
      urgencia: Color(0xFFFFB238),
      simbolo: Color(0xFF0B4F94),
    ),
    fuenteTitulos: 'Nunito',
    fuenteTexto: 'NunitoSans',
    pesoTitulos: FontWeight.w800,
  );

  /// Tema Moderno (D171): la estructura de la app de CAAMEPA (barras blancas
  /// con una línea, tarjetas con borde fino, botones de radio 16) con los
  /// colores del manual de marca de Huellamy (D174): verde azulado `#2E7B76`,
  /// verde profundo `#084847`, azul noche `#12323E` para el texto, celeste
  /// grisáceo `#ADC5CF` y coral `#F26B69` para el SOS. El rojo de error y el
  /// ámbar de urgencia no están en el manual: quedan los del lineamiento.
  static const moderno = Paleta(
    id: 'moderno',
    claro: ColoresModo(
      fondo: Color(0xFFF3F7F8), // fondo del manual
      texto: Color(0xFF12323E), // azul noche del manual
      textoSuave: Color(0xFF4D6570),
      primario: Color(0xFF2E7B76), // verde azulado del manual
      sobrePrimario: Color(0xFFFFFFFF),
      acento: Color(0xFFF26B69), // coral del manual: SOS y destacados
      sobreAcento: Color(0xFF12323E),
      error: Color(0xFFB91C1C),
      sobreError: Color(0xFFFFFFFF),
      exito: Color(0xFF2E7B76),
      urgencia: Color(0xFFB45309),
      barra: Color(0xFFFFFFFF),
      sobreBarra: Color(0xFF12323E),
      superficies: Superficies(
        tarjeta: Color(0xFFFFFFFF),
        chip: Color(0xFFE6EEF0),
        borde: Color(0xFFD5E1E5),
        contorno: Color(0xFFADC5CF), // celeste grisáceo del manual
        contenedorPrimario: Color(0xFFD8EAE8),
        sobreContenedorPrimario: Color(0xFF084847), // verde profundo
        franja: Color(0xFFE7F2F1),
        sobreFranja: Color(0xFF084847),
        degradado: [Color(0xFF084847), Color(0xFF2E7B76)],
        sobreDegradadoSuave: Color(0xFFD8EAE8),
      ),
    ),
    oscuro: ColoresModo(
      fondo: Color(0xFF0C1F26),
      texto: Color(0xFFF3F7F8),
      textoSuave: Color(0xFFADC5CF),
      primario: Color(0xFF5FB3AC),
      sobrePrimario: Color(0xFF062B2A),
      acento: Color(0xFFF26B69),
      sobreAcento: Color(0xFF0C1F26),
      error: Color(0xFFF87171),
      sobreError: Color(0xFF0C1F26),
      exito: Color(0xFF6FD1C4),
      urgencia: Color(0xFFFBBF24),
      barra: Color(0xFF12323E),
      sobreBarra: Color(0xFFF3F7F8),
      superficies: Superficies(
        tarjeta: Color(0xFF12323E),
        chip: Color(0xFF1B3A45),
        borde: Color(0xFF24505E),
        contorno: Color(0xFF3A6876),
        contenedorPrimario: Color(0xFF084847),
        sobreContenedorPrimario: Color(0xFFD8EAE8),
        franja: Color(0xFF084847),
        sobreFranja: Color(0xFFD8EAE8),
        degradado: [Color(0xFF084847), Color(0xFF2E7B76)],
        sobreDegradadoSuave: Color(0xFFD8EAE8),
      ),
    ),
    fuenteTitulos: 'Manrope',
    fuenteTexto: 'Manrope',
    pesoTitulos: FontWeight.w800,
    estilo: EstiloTema.moderno,
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
    fuentesADescargar: [ArchivoFuente('Fraunces', 'Fraunces-SemiBold.ttf')],
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

  /// Tema Pro · Blanco y negro (D120): sin color, con las barras blancas (en
  /// oscuro, negras). Error, éxito y urgencia conservan su color porque
  /// avisan algo; los pines del mapa no cambian en ningún tema.
  static const blancoNegro = Paleta(
    id: 'blanco_negro',
    claro: ColoresModo(
      fondo: Color(0xFFF4F4F4),
      texto: Color(0xFF111111),
      textoSuave: Color(0xFF555555),
      primario: Color(0xFF111111),
      sobrePrimario: Color(0xFFFFFFFF),
      acento: Color(0xFF2B2B2B),
      sobreAcento: Color(0xFFFFFFFF),
      error: Color(0xFFB3261E),
      sobreError: Color(0xFFFFFFFF),
      exito: Color(0xFF17705F),
      urgencia: Color(0xFF9A4A00),
      barra: Color(0xFFFFFFFF),
      sobreBarra: Color(0xFF111111),
    ),
    oscuro: ColoresModo(
      fondo: Color(0xFF0F0F0F),
      texto: Color(0xFFF2F2F2),
      textoSuave: Color(0xFFB0B0B0),
      primario: Color(0xFFF2F2F2),
      sobrePrimario: Color(0xFF0F0F0F),
      acento: Color(0xFFE0E0E0),
      sobreAcento: Color(0xFF0F0F0F),
      error: Color(0xFFFF8A80),
      sobreError: Color(0xFF0F0F0F),
      exito: Color(0xFF5ED3BF),
      urgencia: Color(0xFFFFB238),
      barra: Color(0xFF000000),
      sobreBarra: Color(0xFFF2F2F2),
    ),
    fuenteTitulos: 'Nunito',
    fuenteTexto: 'NunitoSans',
    pesoTitulos: FontWeight.w800,
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
    required this.barra,
    required this.sobreBarra,
    required this.simbolo,
    required this.sobreSimbolo,
    Color? barraElegido,
    Color? barraNoElegido,
    Color? barraIndicador,
    this.bordeBarra,
    this.degradado,
    this.sobreDegradadoSuave,
  }) : barraElegido = barraElegido ?? sobreBarra,
       barraNoElegido = barraNoElegido ?? sobreBarra,
       barraIndicador = barraIndicador ?? sobreBarra;

  factory ColoresMarca.de(ColoresModo c) {
    final s = c.superficies;
    return ColoresMarca(
      acento: c.acento,
      sobreAcento: c.sobreAcento,
      exito: c.exito,
      urgencia: c.urgencia,
      barra: c.barra,
      sobreBarra: c.sobreBarra,
      simbolo: c.simbolo,
      sobreSimbolo: c.sobreSimbolo,
      // Moderno: la pestaña elegida en el primario sobre una píldora suave;
      // las demás, en el texto secundario.
      barraElegido: s == null ? null : c.primario,
      barraNoElegido: s == null ? null : c.textoSuave,
      barraIndicador: s?.franja,
      bordeBarra: s?.borde,
      degradado: s?.degradado,
      sobreDegradadoSuave: s?.sobreDegradadoSuave,
    );
  }

  final Color acento;
  final Color sobreAcento;
  final Color exito;
  final Color urgencia;

  /// Barras de arriba y de abajo.
  final Color barra;
  final Color sobreBarra;

  /// Botón redondo del Mapa y logo.
  final Color simbolo;
  final Color sobreSimbolo;

  /// Ícono y etiqueta de la pestaña elegida y de las demás, y la píldora de
  /// la elegida. En Huellamy, el color sobre la barra (la píldora, con
  /// transparencia).
  final Color barraElegido;
  final Color barraNoElegido;
  final Color barraIndicador;

  /// Línea fina que separa las barras blancas del contenido (Moderno).
  final Color? bordeBarra;

  /// Degradé del menú lateral y de la pantalla de ingreso (Moderno).
  final List<Color>? degradado;
  final Color? sobreDegradadoSuave;

  @override
  ColoresMarca copyWith({
    Color? acento,
    Color? sobreAcento,
    Color? exito,
    Color? urgencia,
    Color? barra,
    Color? sobreBarra,
    Color? simbolo,
    Color? sobreSimbolo,
  }) => ColoresMarca(
    acento: acento ?? this.acento,
    sobreAcento: sobreAcento ?? this.sobreAcento,
    exito: exito ?? this.exito,
    urgencia: urgencia ?? this.urgencia,
    barra: barra ?? this.barra,
    sobreBarra: sobreBarra ?? this.sobreBarra,
    simbolo: simbolo ?? this.simbolo,
    sobreSimbolo: sobreSimbolo ?? this.sobreSimbolo,
    barraElegido: barraElegido,
    barraNoElegido: barraNoElegido,
    barraIndicador: barraIndicador,
    bordeBarra: bordeBarra,
    degradado: degradado,
    sobreDegradadoSuave: sobreDegradadoSuave,
  );

  @override
  ColoresMarca lerp(ColoresMarca? other, double t) {
    if (other == null) return this;
    return ColoresMarca(
      acento: Color.lerp(acento, other.acento, t)!,
      sobreAcento: Color.lerp(sobreAcento, other.sobreAcento, t)!,
      exito: Color.lerp(exito, other.exito, t)!,
      urgencia: Color.lerp(urgencia, other.urgencia, t)!,
      barra: Color.lerp(barra, other.barra, t)!,
      sobreBarra: Color.lerp(sobreBarra, other.sobreBarra, t)!,
      simbolo: Color.lerp(simbolo, other.simbolo, t)!,
      sobreSimbolo: Color.lerp(sobreSimbolo, other.sobreSimbolo, t)!,
      barraElegido: Color.lerp(barraElegido, other.barraElegido, t),
      barraNoElegido: Color.lerp(barraNoElegido, other.barraNoElegido, t),
      barraIndicador: Color.lerp(barraIndicador, other.barraIndicador, t),
      bordeBarra: t < 0.5 ? bordeBarra : other.bordeBarra,
      degradado: t < 0.5 ? degradado : other.degradado,
      sobreDegradadoSuave: t < 0.5
          ? sobreDegradadoSuave
          : other.sobreDegradadoSuave,
    );
  }
}

extension ColoresMarcaContexto on BuildContext {
  ColoresMarca get marca => Theme.of(this).extension<ColoresMarca>()!;
}
