import 'package:flutter/material.dart';

import '../../l10n/l10n.dart';

/// Contenido provisorio de una pantalla que todavía no está hecha.
class EnConstruccion extends StatelessWidget {
  const EnConstruccion({
    required this.icono,
    required this.descripcion,
    required String this.paso,
    this.accion,
    super.key,
  });

  /// Estado vacío (pantalla hecha, pero sin contenido todavía).
  const EnConstruccion.vacio({
    required this.icono,
    required this.descripcion,
    this.accion,
    super.key,
  }) : paso = null;

  final IconData icono;
  final String descripcion;

  /// Paso de `PROGRESO.md` en el que se construye esta pantalla.
  final String? paso;

  /// Botón opcional debajo del texto (por ejemplo, "Agregar mascota").
  final Widget? accion;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    // Desplazable: en pantallas chicas o con letra grande no se corta.
    return Center(
      child: SingleChildScrollView(
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
            if (paso case final paso?) ...[
              const SizedBox(height: 8),
              Text(
                context.t.enConstruccionPaso(paso),
                style: tema.textTheme.bodySmall?.copyWith(
                  color: tema.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            if (accion case final accion?) ...[
              const SizedBox(height: 24),
              accion,
            ],
          ],
        ),
      ),
    );
  }
}
