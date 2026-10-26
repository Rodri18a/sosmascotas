import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../agenda/agenda_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../utiles/enlaces.dart';
import '../../veterinarias/veterinarias_repositorio.dart';
import 'reservar_turno.dart';

/// Modo comercio → Agenda (3.1, D104): prender el módulo, cómo da los turnos,
/// los días sin turnos y los turnos pedidos (confirmar, rechazar, atendido,
/// cancelar), en vivo.
class AgendaNegocio extends ConsumerWidget {
  const AgendaNegocio({required this.negocioId, super.key});

  final String negocioId;

  Future<void> _estado(
    BuildContext context,
    WidgetRef ref,
    Turno x,
    EstadoTurno estado,
  ) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref.read(agendaRepositorioProvider).cambiarEstado(x.id, estado);
      ref
          .read(metricasProvider)
          .track(
            Eventos.bookingStatus,
            businessId: negocioId,
            props: {'estado': estado.base, 'quien': 'negocio'},
          );
    } on Object catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(textoError(t, e))));
    }
    ref.invalidate(turnosDelNegocioProvider(negocioId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    ref.listen(turnosEnVivoProvider(negocioId), (_, _) {
      ref.invalidate(turnosDelNegocioProvider(negocioId));
    });
    final prendido =
        ref
            .watch(modulosPrendidosProvider(negocioId))
            .value
            ?.contains(Modulo.agenda) ??
        false;
    final ahora = ref.watch(relojProvider)();
    return RefreshIndicator(
      onRefresh: () => ref.refresh(turnosDelNegocioProvider(negocioId).future),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: SwitchListTile(
              title: Text(t.agendaModulo),
              subtitle: Text(t.agendaModuloAyuda),
              value: prendido,
              onChanged: (si) async {
                final mensajes = ScaffoldMessenger.of(context);
                try {
                  // Sin configuración guardada, la agenda no toma turnos.
                  final ajustes = await ref.read(
                    miAgendaProvider(negocioId).future,
                  );
                  if (si && !ajustes.configurada) {
                    await ref
                        .read(agendaRepositorioProvider)
                        .guardarAgenda(negocioId, ajustes);
                  }
                  await ref
                      .read(veterinariasRepositorioProvider)
                      .prenderModulo(negocioId, Modulo.agenda, si);
                  ref.read(metricasProvider).track(Eventos.moduleToggle);
                } on Object {
                  mensajes.showSnackBar(
                    SnackBar(content: Text(t.errorDesconocido)),
                  );
                }
                ref
                  ..invalidate(modulosPrendidosProvider(negocioId))
                  ..invalidate(miAgendaProvider(negocioId))
                  ..invalidate(condicionesAgendaProvider(negocioId));
              },
            ),
          ),
          if (prendido) ...[
            _Ajustes(negocioId: negocioId),
            _Bloqueados(negocioId: negocioId),
          ],
          const SizedBox(height: 16),
          Text(t.agendaTurnos, style: tema.textTheme.titleMedium),
          switch (ref.watch(turnosDelNegocioProvider(negocioId))) {
            AsyncData(value: final lista) when lista.isEmpty => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(t.agendaSinTurnos),
            ),
            AsyncData(value: final lista) => Column(
              children: [
                for (final x in lista)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            textoCuando(context, x.inicio),
                            style: tema.textTheme.titleSmall,
                          ),
                          Text(
                            [
                              t.agendaCliente(
                                x.cliente?.isNotEmpty ?? false
                                    ? x.cliente!
                                    : '—',
                                [x.mascota, x.especie].nonNulls.join(', '),
                              ),
                              ?x.servicio,
                              ?x.nota,
                              textoEstadoTurno(t, x.estado),
                            ].join('\n'),
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (x.estado == EstadoTurno.pendiente) ...[
                                FilledButton(
                                  onPressed: () => _estado(
                                    context,
                                    ref,
                                    x,
                                    EstadoTurno.confirmado,
                                  ),
                                  child: Text(t.agendaConfirmar),
                                ),
                                OutlinedButton(
                                  onPressed: () => _estado(
                                    context,
                                    ref,
                                    x,
                                    EstadoTurno.rechazado,
                                  ),
                                  child: Text(t.agendaRechazar),
                                ),
                              ],
                              if (x.puedeMarcarAtendido(ahora))
                                FilledButton.tonal(
                                  onPressed: () => _estado(
                                    context,
                                    ref,
                                    x,
                                    EstadoTurno.atendido,
                                  ),
                                  child: Text(t.agendaAtendido),
                                ),
                              if (x.estado == EstadoTurno.confirmado)
                                TextButton(
                                  onPressed: () => _estado(
                                    context,
                                    ref,
                                    x,
                                    EstadoTurno.cancelado,
                                  ),
                                  child: Text(t.agendaCancelar),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            AsyncError() => Text(t.errorSinConexion),
            _ => const Center(child: CircularProgressIndicator()),
          },
        ],
      ),
    );
  }
}

class _Ajustes extends ConsumerStatefulWidget {
  const _Ajustes({required this.negocioId});

  final String negocioId;

  @override
  ConsumerState<_Ajustes> createState() => _AjustesState();
}

class _AjustesState extends ConsumerState<_Ajustes> {
  AjustesAgenda? _editados;

  Widget _opcion<T>(
    String titulo,
    T valor,
    List<T> opciones,
    String Function(T) texto,
    void Function(T) cambiar,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(titulo),
    trailing: DropdownButton<T>(
      value: opciones.contains(valor) ? valor : null,
      hint: Text(texto(valor)),
      items: [
        for (final o in opciones)
          DropdownMenuItem(value: o, child: Text(texto(o))),
      ],
      onChanged: (v) {
        if (v != null) cambiar(v);
      },
    ),
  );

  Future<void> _guardar(AjustesAgenda a) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(agendaRepositorioProvider)
          .guardarAgenda(widget.negocioId, a);
      ref
        ..read(metricasProvider).track(
          Eventos.agendaSave,
          businessId: widget.negocioId,
          props: {'slot': a.minutosPorTurno, 'a_la_vez': a.aLaVez},
        )
        ..invalidate(miAgendaProvider(widget.negocioId))
        ..invalidate(condicionesAgendaProvider(widget.negocioId));
      setState(() => _editados = null);
      mensajes.showSnackBar(SnackBar(content: Text(t.agendaGuardada)));
    } on Object catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(textoError(t, e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final guardados = ref.watch(miAgendaProvider(widget.negocioId)).value;
    if (guardados == null) return const LinearProgressIndicator();
    final a = _editados ?? guardados;
    void cambiar(AjustesAgenda nuevo) => setState(() => _editados = nuevo);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.agendaConfigurar,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            _opcion<int>(
              t.agendaDuracion,
              a.minutosPorTurno,
              const [15, 20, 30, 45, 60, 90, 120],
              t.agendaMinutos,
              (v) => cambiar(a.copyWith(minutosPorTurno: v)),
            ),
            _opcion<int>(
              t.agendaALaVez,
              a.aLaVez,
              const [1, 2, 3, 4, 5],
              (v) => '$v',
              (v) => cambiar(a.copyWith(aLaVez: v)),
            ),
            _opcion<int>(
              t.agendaAnticipacion,
              a.anticipacionMinutos,
              const [0, 60, 120, 240, 720, 1440],
              (v) => t.agendaHoras(v ~/ 60),
              (v) => cambiar(a.copyWith(anticipacionMinutos: v)),
            ),
            _opcion<int>(
              t.agendaDiasAdelante,
              a.diasAdelante,
              const [7, 14, 30, 60, 90],
              t.agendaDias,
              (v) => cambiar(a.copyWith(diasAdelante: v)),
            ),
            Text(
              t.agendaHorarioAyuda,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton(
                onPressed: _editados == null ? null : () => _guardar(a),
                child: Text(t.agendaGuardar),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bloqueados extends ConsumerWidget {
  const _Bloqueados({required this.negocioId});

  final String negocioId;

  Future<void> _cambiar(
    BuildContext context,
    WidgetRef ref,
    DateTime dia, {
    required bool bloquear,
  }) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(agendaRepositorioProvider)
          .bloquearDia(negocioId, dia, bloquear: bloquear);
    } on Object catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(textoError(t, e))));
    }
    ref
      ..invalidate(miAgendaProvider(negocioId))
      ..invalidate(condicionesAgendaProvider(negocioId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final bloqueados =
        ref.watch(miAgendaProvider(negocioId)).value?.bloqueados ?? const [];
    final fechas = MaterialLocalizations.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.agendaBloqueados,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            if (bloqueados.isEmpty) Text(t.agendaSinBloqueados),
            Wrap(
              spacing: 8,
              children: [
                for (final b in bloqueados)
                  InputChip(
                    label: Text(
                      [fechas.formatMediumDate(b.dia), ?b.nota].join(' · '),
                    ),
                    onDeleted: () =>
                        _cambiar(context, ref, b.dia, bloquear: false),
                  ),
              ],
            ),
            TextButton.icon(
              onPressed: () async {
                final hoy = ref.read(relojProvider)();
                final dia = await showDatePicker(
                  context: context,
                  firstDate: hoy,
                  lastDate: DateTime(hoy.year + 1, hoy.month, hoy.day),
                  helpText: t.agendaBloquear,
                );
                if (dia != null && context.mounted) {
                  await _cambiar(context, ref, dia, bloquear: true);
                }
              },
              icon: const Icon(Icons.event_busy_outlined),
              label: Text(t.agendaBloquear),
            ),
          ],
        ),
      ),
    );
  }
}
