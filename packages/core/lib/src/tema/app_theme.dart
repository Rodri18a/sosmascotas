import 'package:flutter/material.dart';

import 'paleta.dart';

/// Tema de la app en modo claro y oscuro (Material 3), armado desde la paleta
/// de la marca (Huellitas, D126).
abstract final class AppTheme {
  static ThemeData get claro => tema(Paleta.cielo, Brightness.light);

  static ThemeData get oscuro => tema(Paleta.cielo, Brightness.dark);

  static ThemeData tema(Paleta paleta, Brightness brillo) {
    final c = paleta.modo(brillo);
    final colores = esquema(c, brillo);
    const radio = BorderRadius.all(Radius.circular(12));
    const tamanoBoton = Size(64, 48); // Áreas táctiles cómodas (accesibilidad).

    final base = ThemeData(
      colorScheme: colores,
      fontFamily: paleta.fuenteTexto,
      scaffoldBackgroundColor: colores.surface,
      extensions: [ColoresMarca.de(c)],
      // La barra de arriba, del mismo color que la de abajo (D94).
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: c.barra,
        foregroundColor: c.sobreBarra,
        scrolledUnderElevation: 1,
      ),
      // La única TabBar va dentro de una barra de arriba (Adopción).
      tabBarTheme: TabBarThemeData(
        labelColor: c.sobreBarra,
        unselectedLabelColor: c.sobreBarra.withValues(alpha: 0.8),
        indicatorColor: c.sobreBarra,
        dividerColor: Colors.transparent,
      ),
      // 8 px entre tarjetas seguidas: con margen cero quedaban pegadas en
      // las pantallas que no agregaban el espacio a mano.
      cardTheme: const CardThemeData(
        margin: EdgeInsets.symmetric(vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: tamanoBoton,
          shape: const RoundedRectangleBorder(borderRadius: radio),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: tamanoBoton,
          shape: const RoundedRectangleBorder(borderRadius: radio),
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        border: OutlineInputBorder(borderRadius: radio),
      ),
      navigationBarTheme: NavigationBarThemeData(
        indicatorColor: colores.primaryContainer,
      ),
    );
    return base.copyWith(
      textTheme: _conTitulos(
        base.textTheme,
        paleta.fuenteTitulos,
        paleta.pesoTitulos,
      ),
    );
  }

  /// Roles de Material con los colores exactos de la paleta. Los contenedores
  /// salen de la semilla; las superficies, del fondo de la paleta mezclado de a
  /// poco con el texto (así sirven para cualquier paleta y el texto contrasta).
  static ColorScheme esquema(ColoresModo c, Brightness brillo) {
    final oscuro = brillo == Brightness.dark;
    Color hacia(double t) => Color.lerp(c.fondo, c.texto, t)!;
    return ColorScheme.fromSeed(
      seedColor: c.primario,
      brightness: brillo,
      dynamicSchemeVariant: DynamicSchemeVariant.fidelity,
    ).copyWith(
      primary: c.primario,
      onPrimary: c.sobrePrimario,
      secondary: c.acento,
      onSecondary: c.sobreAcento,
      error: c.error,
      onError: c.sobreError,
      surface: c.fondo,
      onSurface: c.texto,
      onSurfaceVariant: c.textoSuave,
      surfaceContainerLowest: oscuro
          ? Color.lerp(c.fondo, const Color(0xFF000000), 0.3)
          : const Color(0xFFFFFFFF),
      surfaceContainerLow: oscuro
          ? hacia(0.04)
          : Color.lerp(c.fondo, const Color(0xFFFFFFFF), 0.5),
      surfaceContainer: hacia(oscuro ? 0.07 : 0.03),
      surfaceContainerHigh: hacia(oscuro ? 0.10 : 0.06),
      surfaceContainerHighest: hacia(oscuro ? 0.14 : 0.09),
    );
  }

  /// Títulos con la tipografía y el peso de títulos de la paleta.
  static TextTheme _conTitulos(TextTheme t, String fuente, FontWeight peso) {
    TextStyle? titulo(TextStyle? s) =>
        s?.copyWith(fontFamily: fuente, fontWeight: peso);
    return t.copyWith(
      displayLarge: titulo(t.displayLarge),
      displayMedium: titulo(t.displayMedium),
      displaySmall: titulo(t.displaySmall),
      headlineLarge: titulo(t.headlineLarge),
      headlineMedium: titulo(t.headlineMedium),
      headlineSmall: titulo(t.headlineSmall),
      titleLarge: titulo(t.titleLarge),
    );
  }
}
