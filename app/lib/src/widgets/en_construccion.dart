import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

/// Contenido provisorio de una pantalla que todavía no está hecha.
class EnConstruccion extends StatelessWidget {
  const EnConstruccion({
    required this.icono,
    required this.descripcion,
    required this.paso,
    super.key,
  });

  final IconData icono;
  final String descripcion;

  /// Paso de `PROGRESO.md` en el que se construye esta pantalla.
  final String paso;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 64, color: tema.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              descripcion,
              textAlign: TextAlign.center,
              style: tema.textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              context.t.enConstruccionPaso(paso),
              style: tema.textTheme.bodySmall?.copyWith(
                color: tema.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
