import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../l10n/l10n.dart';
import '../../router.dart';

/// Se ve al entrar por un enlace a una funcionalidad gradual que todavía no le
/// llegó a esta persona (D64).
class NoDisponibleScreen extends StatelessWidget {
  const NoDisponibleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.hourglass_empty_outlined,
                size: 56,
                color: tema.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                t.noDisponibleTitulo,
                style: tema.textTheme.headlineSmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(t.noDisponibleTexto, textAlign: TextAlign.center),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: () => context.go(Rutas.mapa),
                child: Text(t.noDisponibleIrAlMapa),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
