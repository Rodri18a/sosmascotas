import 'package:flutter/material.dart';

/// Pantalla provisoria hasta que exista la navegación base (paso 0.1.5).
/// Los textos pasan a i18n en el paso 0.1.6.
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🐾', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text('SOS Mascota', style: textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text('Base técnica lista', style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }
}
