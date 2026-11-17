import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../modelos.dart';
import '../repositorio.dart';
import '../textos.dart';

/// Mensajes del formulario de la landing (0.8.6d, D158) y de soporte desde la
/// app (0.8.6b, D160): se responden desde el correo del equipo y acá se marcan respondidos o se archivan. Los de
/// comercios se pueden pasar al embudo de ventas.
class ContactosScreen extends ConsumerStatefulWidget {
  const ContactosScreen({super.key});

  @override
  ConsumerState<ContactosScreen> createState() => _ContactosScreenState();
}

class _ContactosScreenState extends ConsumerState<ContactosScreen> {
  var _estado = 'new';

  Future<void> _cambiar(ContactoLanding c, String estado) async {
    await ref.read(adminRepositorioProvider).estadoContacto(c.id, estado);
    ref.invalidate(contactosProvider);
  }

  Future<void> _aProspectos(ContactoLanding c) async {
    final repo = ref.read(adminRepositorioProvider);
    final aviso = ScaffoldMessenger.of(context);
    try {
      await repo.guardarProspecto(c.comoProspecto());
      await repo.estadoContacto(c.id, 'answered');
    } on Exception {
      // Por ejemplo, ventas sin zonas asignadas no carga prospectos (D110).
      aviso.showSnackBar(const SnackBar(content: Text(T.noSePudo)));
      return;
    }
    ref
      ..invalidate(prospectosProvider)
      ..invalidate(contactosProvider);
    aviso.showSnackBar(const SnackBar(content: Text(T.pasadoAProspectos)));
  }

  @override
  Widget build(BuildContext context) => switch (ref.watch(contactosProvider)) {
    AsyncData(value: final todos) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Wrap(
            spacing: 8,
            children: [
              for (final MapEntry(key: e, value: nombre)
                  in T.estadosContacto.entries)
                ChoiceChip(
                  label: Text(
                    '$nombre: ${todos.where((c) => c.estado == e).length}',
                  ),
                  selected: _estado == e,
                  onSelected: (_) => setState(() => _estado = e),
                ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Text(T.responderPorCorreo),
        ),
        Expanded(child: _lista(todos.where((c) => c.estado == _estado))),
      ],
    ),
    AsyncError() => Center(
      child: TextButton(
        onPressed: () => ref.invalidate(contactosProvider),
        child: const Text(T.reintentar),
      ),
    ),
    _ => const Center(child: CircularProgressIndicator()),
  };

  Widget _lista(Iterable<ContactoLanding> lista) {
    if (lista.isEmpty) return const Center(child: Text(T.sinContactos));
    final estilo = Theme.of(context).textTheme;
    final fechas = MaterialLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        for (final c in lista)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    [
                      T.tiposContacto[c.tipo] ?? c.tipo,
                      c.nombre,
                      ?c.comercio,
                    ].join(' · '),
                    style: estilo.titleSmall,
                  ),
                  SelectableText(c.correo),
                  Text(
                    '${fechas.formatShortDate(c.creado)} '
                    '${fechas.formatTimeOfDay(TimeOfDay.fromDateTime(c.creado))}',
                    style: estilo.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  SelectableText(c.mensaje),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      if (c.estado == 'new') ...[
                        FilledButton(
                          onPressed: () => _cambiar(c, 'answered'),
                          child: const Text(T.marcarRespondido),
                        ),
                        if (c.tipo == 'business')
                          OutlinedButton(
                            onPressed: () => _aProspectos(c),
                            child: const Text(T.pasarAProspectos),
                          ),
                      ],
                      if (c.estado != 'archived')
                        OutlinedButton(
                          onPressed: () => _cambiar(c, 'archived'),
                          child: const Text(T.archivar),
                        )
                      else
                        TextButton(
                          onPressed: () => _cambiar(c, 'new'),
                          child: const Text(T.volverANuevo),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
