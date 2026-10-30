import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/perfil_repositorio.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../hogar/hogar_repositorio.dart';
import '../../hogar/tareas_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../utiles/enlaces.dart';
import '../recordatorios/recordatorios.dart';

IconData iconoTarea(TipoTarea tipo) => switch (tipo) {
  TipoTarea.walk => Icons.directions_walk_outlined,
  TipoTarea.food => Icons.restaurant_outlined,
  TipoTarea.bath => Icons.bathtub_outlined,
  TipoTarea.vet => Icons.local_hospital_outlined,
  TipoTarea.other => Icons.task_alt_outlined,
};

String textoTipoTarea(AppLocalizations t, TipoTarea tipo) => switch (tipo) {
  TipoTarea.walk => t.tareaPaseo,
  TipoTarea.food => t.tareaComida,
  TipoTarea.bath => t.tareaBano,
  TipoTarea.vet => t.tareaVeterinaria,
  TipoTarea.other => t.tareaOtra,
};

/// Quiénes pueden cuidar a la mascota (y por lo tanto recibir una tarea):
/// su dueño y los integrantes del hogar del dueño. Sin hogar, solo yo.
Map<String, String> cuidadoresDe(
  Mascota mascota,
  List<Integrante> integrantes,
  String yo,
  String miNombre,
) {
  final dueno = mascota.duenoId ?? yo;
  final hogar = integrantes
      .where((i) => i.esDueno && i.usuarioId == dueno)
      .firstOrNull
      ?.hogarId;
  return {
    yo: miNombre,
    if (hogar != null)
      for (final i in integrantes)
        if (i.hogarId == hogar && i.usuarioId != yo)
          i.usuarioId: i.nombre ?? '',
  };
}

/// Tareas de hoy dentro de la ficha (paso 1.6.3, D71).
class TarjetaTareas extends ConsumerWidget {
  const TarjetaTareas({required this.mascota, super.key});

  final Mascota mascota;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final yo = ref.watch(usuarioActualProvider).value?.id;
    final ahora = ref.watch(relojProvider)();
    final nombres = ref.watch(nombresDelHogarProvider);
    final tareas = ref.watch(tareasDeHoyProvider(mascota.id));

    String nombre(String? id) => nombres[id] ?? '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ListTile(
              leading: const Icon(Icons.checklist_outlined),
              title: Text(t.tareasTitulo, style: tema.textTheme.titleMedium),
            ),
            switch (tareas) {
              AsyncData(value: final lista) when lista.isEmpty => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(t.tareasVacio),
              ),
              AsyncData(value: final lista) => Column(
                children: [
                  for (final tarea in lista)
                    CheckboxListTile(
                      secondary: Icon(iconoTarea(tarea.tipo)),
                      value: tarea.hecha,
                      title: Text(
                        [
                          textoTipoTarea(t, tarea.tipo),
                          ?tarea.nota,
                        ].join(' · '),
                      ),
                      subtitle: Text(switch (tarea) {
                        Tarea(hechaPor: final por?, hechaEn: final en?) =>
                          por == yo
                              ? t.tareaHechaPorVos(
                                  textoCuando(context, en, ahora),
                                )
                              : t.tareaHechaPor(
                                  nombre(por),
                                  textoCuando(context, en, ahora),
                                ),
                        Tarea(asignadaA: final a?) when a == yo =>
                          t.tareaTeToca,
                        Tarea(asignadaA: final a?) => t.tareaLeToca(nombre(a)),
                        _ => t.tareaSinAsignar,
                      }),
                      onChanged: (marcar) =>
                          _marcar(context, ref, tarea, marcar ?? false),
                    ),
                ],
              ),
              AsyncLoading() => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator()),
              ),
              _ => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(t.errorSinConexion),
              ),
            },
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: OutlinedButton.icon(
                onPressed: yo == null ? null : () => _nueva(context, ref, yo),
                icon: const Icon(Icons.add_task_outlined),
                label: Text(t.tareasAgregar),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _marcar(
    BuildContext context,
    WidgetRef ref,
    Tarea tarea,
    bool hecha,
  ) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref.read(tareasRepositorioProvider).marcar(tarea.id, hecha: hecha);
      if (hecha) {
        ref
            .read(metricasProvider)
            .track(Eventos.taskDone, props: {'tipo': tarea.tipo.name});
      }
    } on Exception {
      mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
    }
    ref.invalidate(tareasDeHoyProvider(mascota.id));
  }

  Future<void> _nueva(BuildContext context, WidgetRef ref, String yo) async {
    final t = context.t;
    final integrantes =
        ref.read(integrantesProvider).value ?? const <Integrante>[];
    final miNombre = ref.read(perfilProvider).value?.nombre ?? '';
    final cuidadores = cuidadoresDe(mascota, integrantes, yo, miNombre);
    final tarea = await showModalBottomSheet<Tarea>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FormularioTarea(
        mascotaId: mascota.id,
        cuidadores: cuidadores,
        yo: yo,
        hoy: ref.read(relojProvider)(),
      ),
    );
    if (tarea == null || !context.mounted) return;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref.read(tareasRepositorioProvider).crear(tarea);
      ref
          .read(metricasProvider)
          .track(Eventos.taskCreate, props: {'tipo': tarea.tipo.name});
    } on Exception {
      mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
    }
    ref.invalidate(tareasDeHoyProvider(mascota.id));
  }
}

class _FormularioTarea extends StatefulWidget {
  const _FormularioTarea({
    required this.mascotaId,
    required this.cuidadores,
    required this.yo,
    required this.hoy,
  });

  final String mascotaId;
  final Map<String, String> cuidadores;
  final String yo;
  final DateTime hoy;

  @override
  State<_FormularioTarea> createState() => _FormularioTareaState();
}

class _FormularioTareaState extends State<_FormularioTarea> {
  final _nota = TextEditingController();
  var _tipo = TipoTarea.walk;
  var _manana = false;
  late String? _para = widget.yo;

  @override
  void dispose() {
    _nota.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        0,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.tareaNueva, style: tema.textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tipo in TipoTarea.values)
                  ChoiceChip(
                    avatar: Icon(iconoTarea(tipo), size: 18),
                    label: Text(textoTipoTarea(t, tipo)),
                    selected: tipo == _tipo,
                    onSelected: (_) => setState(() => _tipo = tipo),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nota,
              maxLength: 80,
              decoration: InputDecoration(
                labelText: t.tareaNota,
                helperText: t.tareaNotaAyuda,
              ),
            ),
            const SizedBox(height: 8),
            Text(t.tareaCuando, style: tema.textTheme.titleSmall),
            const SizedBox(height: 8),
            SegmentedButton<bool>(
              segments: [
                ButtonSegment(value: false, label: Text(t.tareaHoy)),
                ButtonSegment(value: true, label: Text(t.tareaManana)),
              ],
              selected: {_manana},
              onSelectionChanged: (s) => setState(() => _manana = s.first),
            ),
            if (widget.cuidadores.length > 1) ...[
              const SizedBox(height: 16),
              DropdownButtonFormField<String?>(
                initialValue: _para,
                decoration: InputDecoration(labelText: t.tareaAsignar),
                items: [
                  DropdownMenuItem(value: null, child: Text(t.tareaNadie)),
                  for (final MapEntry(key: id, value: nombre)
                      in widget.cuidadores.entries)
                    DropdownMenuItem(
                      value: id,
                      child: Text(
                        id == widget.yo
                            ? t.hogarVos(nombre)
                            : (nombre.isEmpty ? t.hogarSinNombre : nombre),
                      ),
                    ),
                ],
                onChanged: (v) => setState(() => _para = v),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                Tarea(
                  id: '',
                  mascotaId: widget.mascotaId,
                  tipo: _tipo,
                  nota: _nota.text,
                  dia: DateUtils.dateOnly(
                    widget.hoy.add(Duration(days: _manana ? 1 : 0)),
                  ),
                  asignadaA: _para,
                ),
              ),
              child: Text(t.tareaCrear),
            ),
          ],
        ),
      ),
    );
  }
}
