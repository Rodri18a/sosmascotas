import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../metricas/metricas.dart';
import '../../veterinarias/veterinarias_repositorio.dart';

/// En la ficha de la mascota (dueño, 2.6, D81): compartirla con su
/// veterinaria y "Busco veterinaria" con sus propuestas.
class TarjetaVeterinaria extends ConsumerWidget {
  const TarjetaVeterinaria({required this.mascota, super.key});

  final Mascota mascota;

  Future<void> _hacer(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function(VeterinariasRepositorio repo) accion,
    String evento,
  ) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await accion(ref.read(veterinariasRepositorioProvider));
      ref.read(metricasProvider).track(evento);
    } on Object {
      mensajes.showSnackBar(SnackBar(content: Text(t.errorDesconocido)));
    }
    ref
      ..invalidate(compartiblesProvider(mascota.id))
      ..invalidate(estadoBusquedaProvider(mascota.id))
      ..invalidate(propuestasProvider(mascota.id));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final id = mascota.id;
    final compartibles = ref.watch(compartiblesProvider(id)).value ?? const [];
    final estado =
        ref.watch(estadoBusquedaProvider(id)).value ?? const EstadoBusqueda();
    final propuestas = ref.watch(propuestasProvider(id)).value ?? const [];

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.local_hospital_outlined),
              title: Text(t.vetTitulo, style: tema.textTheme.titleMedium),
            ),
            if (compartibles.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  t.vetSinMiVeterinaria(mascota.nombre),
                  style: tema.textTheme.bodySmall,
                ),
              ),
            for (final v in compartibles)
              SwitchListTile(
                title: Text(t.vetCompartirCon(v.nombre)),
                subtitle: Text(t.vetCompartirAyuda),
                value: v.compartida,
                onChanged: (si) => _hacer(
                  context,
                  ref,
                  (repo) => repo.compartir(id, v.id, si),
                  Eventos.vetShare,
                ),
              ),
            if (estado.preguntar)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      t.vetBuscasPregunta(mascota.nombre),
                      style: tema.textTheme.titleSmall,
                    ),
                    Text(t.vetBuscasAyuda, style: tema.textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        FilledButton(
                          onPressed: () => _hacer(
                            context,
                            ref,
                            (repo) => repo.buscar(id, true),
                            Eventos.vetSearchOptIn,
                          ),
                          child: Text(t.vetBuscarSi),
                        ),
                        TextButton(
                          onPressed: () => _hacer(
                            context,
                            ref,
                            (repo) => repo.ahoraNo(id),
                            Eventos.vetSearchSnooze,
                          ),
                          child: Text(t.vetAhoraNo),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (estado.buscando)
              ListTile(
                leading: const Icon(Icons.travel_explore_outlined),
                title: Text(t.vetBuscando),
                trailing: TextButton(
                  onPressed: () => _hacer(
                    context,
                    ref,
                    (repo) => repo.buscar(id, false),
                    Eventos.vetSearchOptIn,
                  ),
                  child: Text(t.vetDejarDeBuscar),
                ),
              ),
            for (final p in propuestas)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      t.vetPropuestaDe(p.negocio),
                      style: tema.textTheme.titleSmall,
                    ),
                    Text(p.mensaje),
                    if (p.pendiente)
                      Wrap(
                        spacing: 8,
                        children: [
                          FilledButton.tonal(
                            onPressed: () => _hacer(
                              context,
                              ref,
                              (repo) => repo.responder(p.id, id, true),
                              Eventos.vetProposalAnswer,
                            ),
                            child: Text(t.vetAceptar),
                          ),
                          TextButton(
                            onPressed: () => _hacer(
                              context,
                              ref,
                              (repo) => repo.responder(p.id, id, false),
                              Eventos.vetProposalAnswer,
                            ),
                            child: Text(t.vetRechazar),
                          ),
                        ],
                      )
                    else
                      Text(
                        p.estado == EstadoPropuesta.aceptada
                            ? t.vetAceptada(p.negocio)
                            : t.vetRechazada,
                        style: tema.textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
