import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'paleta.dart';

/// Tema de la app en modo claro y oscuro (Material 3), armado desde la paleta
/// de la marca (Huellamy, D146).
abstract final class AppTheme {
  static ThemeData get claro => tema(Paleta.cielo, Brightness.light);

  static ThemeData get oscuro => tema(Paleta.cielo, Brightness.dark);

  static ThemeData tema(Paleta paleta, Brightness brillo) {
    final c = paleta.modo(brillo);
    final colores = esquema(c, brillo);
    const radio = BorderRadius.all(Radius.circular(12));
    const tamanoBoton = Size(64, 48); // Áreas táctiles cómodas (accesibilidad).
    final oscuro = brillo == Brightness.dark;

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
      // las pantallas que no agregaban el espacio a mano. Tarjetas blancas
      // bien redondeadas con sombra suave azulada (D162).
      cardTheme: CardThemeData(
        margin: const EdgeInsets.symmetric(vertical: 4),
        elevation: oscuro ? 1 : 2,
        shadowColor: colores.primary.withValues(alpha: 0.25),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
      ),
      // Botones en píldora (D162).
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: tamanoBoton,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: tamanoBoton,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const StadiumBorder(),
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
    final conTitulos = base.copyWith(
      textTheme: _conTitulos(
        base.textTheme,
        paleta.fuenteTitulos,
        paleta.pesoTitulos,
      ),
    );
    return switch (c.superficies) {
      final s? when paleta.estilo == EstiloTema.moderno => _moderno(
        conTitulos,
        c,
        s,
        oscuro,
      ),
      _ => conTitulos,
    };
  }

  /// Tema Moderno (D171, estilo de la app de CAAMEPA): barras blancas con una
  /// línea abajo, tarjetas blancas con borde fino y esquinas muy redondeadas,
  /// botones planos de radio 16 y casi sin sombras. Tamaños y pesos de letra
  /// del lineamiento (títulos y botones en 800).
  static ThemeData _moderno(
    ThemeData base,
    ColoresModo c,
    Superficies s,
    bool oscuro,
  ) {
    final colores = base.colorScheme;
    const radio16 = BorderRadius.all(Radius.circular(16));
    const radio24 = BorderRadius.all(Radius.circular(24));
    const tamanoBoton = Size(64, 52);
    const textoBoton = TextStyle(fontSize: 17, fontWeight: FontWeight.w800);
    TextStyle estilo(double tam, FontWeight peso, {double? alto}) => TextStyle(
      fontFamily: 'Manrope',
      fontSize: tam,
      fontWeight: peso,
      height: alto == null ? null : alto / tam,
    );
    final t = base.textTheme;
    final texto = t.copyWith(
      headlineMedium: t.headlineMedium?.merge(estilo(28, FontWeight.w800)),
      headlineSmall: t.headlineSmall?.merge(estilo(22, FontWeight.w800)),
      titleLarge: t.titleLarge?.merge(estilo(20, FontWeight.w800)),
      titleMedium: t.titleMedium?.merge(estilo(17, FontWeight.w700)),
      titleSmall: t.titleSmall?.merge(estilo(15, FontWeight.w700)),
      bodyLarge: t.bodyLarge?.merge(estilo(16, FontWeight.w400, alto: 23)),
      bodyMedium: t.bodyMedium?.merge(estilo(14, FontWeight.w400, alto: 20)),
      labelLarge: t.labelLarge?.merge(estilo(15, FontWeight.w600)),
    );
    final barraSistema = oscuro
        ? SystemUiOverlayStyle.light
        : SystemUiOverlayStyle.dark;
    final campoBorde = OutlineInputBorder(
      borderRadius: radio16,
      borderSide: BorderSide(color: s.borde),
    );
    return base.copyWith(
      textTheme: texto,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        toolbarHeight: 64,
        backgroundColor: s.tarjeta,
        foregroundColor: c.texto,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        shape: Border(bottom: BorderSide(color: s.borde)),
        iconTheme: IconThemeData(color: c.textoSuave),
        actionsIconTheme: IconThemeData(color: c.textoSuave),
        titleTextStyle: estilo(20, FontWeight.w800).copyWith(color: c.texto),
        systemOverlayStyle: barraSistema.copyWith(
          statusBarColor: Colors.transparent,
          systemNavigationBarColor: Colors.transparent,
          systemNavigationBarContrastEnforced: false,
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colores.primary,
        unselectedLabelColor: c.textoSuave,
        indicatorColor: colores.primary,
        dividerColor: s.borde,
        labelStyle: estilo(15, FontWeight.w800),
      ),
      cardTheme: CardThemeData(
        color: s.tarjeta,
        surfaceTintColor: Colors.transparent,
        margin: const EdgeInsets.symmetric(vertical: 4),
        elevation: 0.5,
        shadowColor: const Color(0xFF000000).withValues(alpha: 0.15),
        shape: RoundedRectangleBorder(
          borderRadius: radio24,
          side: BorderSide(color: s.borde),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: tamanoBoton,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const RoundedRectangleBorder(borderRadius: radio16),
          elevation: 0,
          textStyle: textoBoton,
          disabledBackgroundColor: Color.lerp(
            colores.primary,
            colores.surface,
            0.5,
          ),
          disabledForegroundColor: colores.onPrimary.withValues(alpha: 0.7),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: tamanoBoton,
          shape: const RoundedRectangleBorder(borderRadius: radio16),
          elevation: 0,
          textStyle: textoBoton,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: tamanoBoton,
          padding: const EdgeInsets.symmetric(horizontal: 24),
          shape: const RoundedRectangleBorder(borderRadius: radio16),
          backgroundColor: s.tarjeta,
          foregroundColor: c.texto,
          side: BorderSide(color: s.borde),
          textStyle: textoBoton,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colores.primary,
          textStyle: estilo(15, FontWeight.w600),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.fondo,
        contentPadding: const EdgeInsets.all(16),
        constraints: const BoxConstraints(minHeight: 52),
        border: campoBorde,
        enabledBorder: campoBorde,
        focusedBorder: campoBorde.copyWith(
          borderSide: BorderSide(color: colores.primary, width: 2),
        ),
        errorBorder: campoBorde.copyWith(
          borderSide: BorderSide(color: colores.error),
        ),
        focusedErrorBorder: campoBorde.copyWith(
          borderSide: BorderSide(color: colores.error, width: 2),
        ),
        labelStyle: TextStyle(color: c.textoSuave),
        floatingLabelStyle: TextStyle(
          color: c.texto,
          fontWeight: FontWeight.w600,
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: s.chip,
        side: BorderSide.none,
        shape: const StadiumBorder(),
        labelStyle: estilo(13, FontWeight.w600).copyWith(color: c.texto),
      ),
      listTileTheme: ListTileThemeData(
        shape: const RoundedRectangleBorder(borderRadius: radio24),
        iconColor: colores.primary,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: s.tarjeta,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: radio24),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: s.tarjeta,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: s.tarjeta,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: radio16),
      ),
      drawerTheme: DrawerThemeData(
        backgroundColor: c.fondo,
        surfaceTintColor: Colors.transparent,
      ),
      dividerTheme: DividerThemeData(color: s.borde),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: s.tarjeta,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        indicatorColor: s.franja,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (estados) => estilo(12, FontWeight.w800).copyWith(
            color: estados.contains(WidgetState.selected)
                ? colores.primary
                : c.textoSuave,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (estados) => IconThemeData(
            color: estados.contains(WidgetState.selected)
                ? colores.primary
                : c.textoSuave,
          ),
        ),
      ),
    );
  }

  /// Roles de Material con los colores exactos de la paleta. Los contenedores
  /// salen de la semilla; las superficies, del fondo de la paleta mezclado de a
  /// poco con el texto (así sirven para cualquier paleta y el texto contrasta).
  /// Si la paleta trae [Superficies] (Moderno), se usan esas.
  static ColorScheme esquema(ColoresModo c, Brightness brillo) {
    final oscuro = brillo == Brightness.dark;
    Color hacia(double t) => Color.lerp(c.fondo, c.texto, t)!;
    final base =
        ColorScheme.fromSeed(
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
    final s = c.superficies;
    if (s == null) return base;
    return base.copyWith(
      primaryContainer: s.contenedorPrimario,
      onPrimaryContainer: s.sobreContenedorPrimario,
      secondaryContainer: s.franja,
      onSecondaryContainer: s.sobreFranja,
      tertiary: c.exito,
      surfaceContainerLowest: s.tarjeta,
      surfaceContainerLow: s.tarjeta,
      surfaceContainer: s.chip,
      surfaceContainerHigh: s.chip,
      surfaceContainerHighest: s.chip,
      outline: s.contorno,
      outlineVariant: s.borde,
      surfaceTint: Colors.transparent,
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
