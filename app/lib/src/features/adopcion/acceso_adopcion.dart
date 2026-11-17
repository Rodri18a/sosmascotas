import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../widgets/ilustracion.dart';

/// Acceso a Adopción fuera del menú ☰ (D154): una tarjeta en el Inicio y un
/// enlace discreto al final de SOS, sin mezclar las listas. [desde] va en la
/// métrica (`inicio` o `sos`). No se muestra si la adopción está apagada.
class AccesoAdopcion extends ConsumerWidget {
  const AccesoAdopcion({required this.desde, super.key});

  final String desde;

  void _abrir(BuildContext context, WidgetRef ref) {
    ref
        .read(metricasProvider)
        .track(Eventos.adoptionShortcut, props: {'desde': desde});
    context.push(Rutas.adopcion);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!ref.watch(funcionalidadActivaProvider(Funcionalidades.adopcion))) {
      return const SizedBox.shrink();
    }
    final t = context.t;
    if (desde == 'sos') {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
        child: Column(
          children: [
            Text(
              t.adopcionAccesoSosPregunta,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            TextButton.icon(
              key: const Key('acceso-adopcion'),
              icon: const Icon(Icons.volunteer_activism_outlined),
              label: Text(t.adopcionAccesoSosBoton),
              onPressed: () => _abrir(context, ref),
            ),
          ],
        ),
      );
    }
    // Tarjeta ilustrada con el cachorro y el gatito (D162).
    final tema = Theme.of(context);
    return Card(
      key: const Key('acceso-adopcion'),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: InkWell(
        onTap: () => _abrir(context, ref),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                t.adopcionAccesoTitulo,
                textAlign: TextAlign.center,
                style: tema.textTheme.titleMedium?.copyWith(
                  color: tema.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              const ImagenIlustracion(Ilustracion.adopta, alto: 110),
              const SizedBox(height: 8),
              Text(t.adopcionAccesoAyuda, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _abrir(context, ref),
                icon: const Icon(Icons.favorite_outline),
                label: Text(t.adopcionAccesoBoton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
