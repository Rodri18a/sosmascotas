import 'package:flutter/material.dart';

/// Verde de la marca (provisorio hasta la identidad del paso 0.0.9b).
const colorMarca = Color(0xFF1F8A5B);

/// Tema de la app en modo claro y oscuro (Material 3).
abstract final class AppTheme {
  static ThemeData get claro => _tema(Brightness.light);

  static ThemeData get oscuro => _tema(Brightness.dark);

  static ThemeData _tema(Brightness brillo) {
    final colores = ColorScheme.fromSeed(
      seedColor: colorMarca,
      brightness: brillo,
    );
    const radio = BorderRadius.all(Radius.circular(12));
    const tamanoBoton = Size(64, 48); // Áreas táctiles cómodas (accesibilidad).

    return ThemeData(
      colorScheme: colores,
      scaffoldBackgroundColor: colores.surface,
      appBarTheme: AppBarTheme(
        centerTitle: false,
        backgroundColor: colores.surface,
        foregroundColor: colores.onSurface,
        scrolledUnderElevation: 1,
      ),
      cardTheme: const CardThemeData(
        margin: EdgeInsets.zero,
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
  }
}
