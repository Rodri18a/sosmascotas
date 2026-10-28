import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../agenda/cuidados_repositorio.dart';
import '../../comercios/negocios_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../utiles/enlaces.dart';
import '../../veterinarias/veterinarias_repositorio.dart';
import 'cuidados.dart';

/// Modo comercio → Agenda → Paseos y estadías (3.3, D115): qué ofrece el
/// paseador u hotel y los pedidos (aceptar abre el chat, rechazar, terminado,
/// cancelar), en vivo. Necesita la agenda prendida (06 «Módulos»).
class CuidadosNegocio extends ConsumerWidget {
  const CuidadosNegocio({required this.negocioId, super.key});

  final String negocioId;

  Future<void> _responder(
    BuildContext context,
    WidgetRef ref,
    Cuidado x, {
    required bool aceptar,
  }) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      final chat = await ref
          .read(cuidadosRepositorioProvider)
          .responder(x.id, aceptar: aceptar);
      ref
          .read(metricasProvider)
          .track(
            Eventos.careStatus,
            businessId: negocioId,
            props: {
              'estado': aceptar ? 'accepted' : 'rejected',
              'quien': 'negocio',
            },
          );
      ref.invalidate(cuidadosDelNegocioProvider(negocioId));
      // El chat del comercio es del dueño (D117): el equipo no lo abre.
      if (chat != null &&
          context.mounted &&
          ref.read(esTitularProvider(negocioId))) {
        await context.push(Rutas.chat(chat));
      }
    } on Object catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(textoErrorCuidado(t, e))));
      ref.invalidate(cuidadosDelNegocioProvider(negocioId));
    }
  }

  Future<void> _estado(
    BuildContext context,
    WidgetRef ref,
    Cuidado x,
    EstadoCuidado estado,
  ) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref.read(cuidadosRepositorioProvider).cambiarEstado(x.id, estado);
      ref
          .read(metricasProvider)
          .track(
            Eventos.careStatus,
            businessId: negocioId,
            props: {'estado': estado.base, 'quien': 'negocio'},
          );
    } on Object catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(textoErrorCuidado(t, e))));
    }
    ref.invalidate(cuidadosDelNegocioProvider(negocioId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    ref.listen(cuidadosEnVivoProvider(negocioId), (_, _) {
      ref.invalidate(cuidadosDelNegocioProvider(negocioId));
    });
    final hoy = ref.watch(relojProvider)();
    final titular = ref.watch(esTitularProvider(negocioId));
    return RefreshIndicator(
      onRefresh: () =>
          ref.refresh(cuidadosDelNegocioProvider(negocioId).future),
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Sin la agenda prendida no aparece «Contratar» en la ficha.
          if (!(ref
                  .watch(modulosPrendidosProvider(negocioId))
                  .value
                  ?.contains(Modulo.agenda) ??
              true))
            Card(
              color: tema.colorScheme.tertiaryContainer,
              child: ListTile(
                leading: const Icon(Icons.info_outline),
                title: Text(t.cuidadosPrenderAgenda),
              ),
            ),
          if (titular) _AjustesCuidados(negocioId: negocioId),
          const SizedBox(height: 16),
          Text(t.cuidadosPedidos, style: tema.textTheme.titleMedium),
          switch (ref.watch(cuidadosDelNegocioProvider(negocioId))) {
            AsyncData(value: final lista) when lista.isEmpty => Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(t.cuidadosSinPedidos),
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
                            '${textoTipoCuidado(t, x.tipo)} · '
                            '${textoFechas(context, x)}',
                            style: tema.textTheme.titleSmall,
                          ),
                          Text(
                            [
                              t.agendaCliente(
                                x.cliente?.isNotEmpty ?? false
                                    ? x.cliente!
                                    : '—',
                                x.mascotas.join(', '),
                              ),
                              ?x.nota,
                              textoEstadoCuidado(t, x.estado),
                            ].join('\n'),
                          ),
                          Wrap(
                            spacing: 8,
                            children: [
                              if (x.estado == EstadoCuidado.pendiente) ...[
                                FilledButton(
                                  onPressed: () => _responder(
                                    context,
                                    ref,
                                    x,
                                    aceptar: true,
                                  ),
                                  child: Text(t.cuidadosAceptar),
                                ),
                                OutlinedButton(
                                  onPressed: () => _responder(
                                    context,
                                    ref,
                                    x,
                                    aceptar: false,
                                  ),
                                  child: Text(t.agendaRechazar),
                                ),
                              ],
                              if (x.chatId case final chat? when titular)
                                FilledButton.tonalIcon(
                                  onPressed: () =>
                                      context.push(Rutas.chat(chat)),
                                  icon: const Icon(Icons.chat_outlined),
                                  label: Text(t.cuidadoChat),
                                ),
                              if (x.puedeTerminar(hoy))
                                FilledButton.tonal(
                                  onPressed: () => _estado(
                                    context,
                                    ref,
                                    x,
                                    EstadoCuidado.terminado,
                                  ),
                                  child: Text(t.cuidadosTerminado),
                                ),
                              if (x.estado == EstadoCuidado.aceptado)
                                TextButton(
                                  onPressed: () => _estado(
                                    context,
                                    ref,
                                    x,
                                    EstadoCuidado.cancelado,
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

class _AjustesCuidados extends ConsumerStatefulWidget {
  const _AjustesCuidados({required this.negocioId});

  final String negocioId;

  @override
  ConsumerState<_AjustesCuidados> createState() => _AjustesCuidadosState();
}

class _AjustesCuidadosState extends ConsumerState<_AjustesCuidados> {
  AjustesCuidados? _editados;
  final _condiciones = TextEditingController();
  var _cargadas = false;

  @override
  void dispose() {
    _condiciones.dispose();
    super.dispose();
  }

  Widget _opcion(
    String titulo,
    int valor,
    List<int> opciones,
    String Function(int) texto,
    void Function(int) cambiar,
  ) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(titulo),
    trailing: DropdownButton<int>(
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

  Future<void> _guardar(AjustesCuidados a) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(cuidadosRepositorioProvider)
          .guardarAjustes(widget.negocioId, a);
      ref
        ..read(metricasProvider).track(
          Eventos.careSave,
          businessId: widget.negocioId,
          props: {'tipos': a.tipos.length, 'cupo': a.cupo},
        )
        ..invalidate(misAjustesCuidadosProvider(widget.negocioId))
        ..invalidate(condicionesCuidadosProvider(widget.negocioId));
      setState(() => _editados = null);
      mensajes.showSnackBar(SnackBar(content: Text(t.agendaGuardada)));
    } on Object catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(textoErrorCuidado(t, e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final guardados = ref
        .watch(misAjustesCuidadosProvider(widget.negocioId))
        .value;
    if (guardados == null) return const LinearProgressIndicator();
    if (!_cargadas) {
      _condiciones.text = guardados.condiciones ?? '';
      _cargadas = true;
    }
    final a = _editados ?? guardados;
    void cambiar(AjustesCuidados nuevo) => setState(() => _editados = nuevo);
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.cuidadosQueOfreces,
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text(
              t.cuidadosQueOfrecesAyuda,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Wrap(
              spacing: 8,
              children: [
                for (final x in TipoCuidado.values)
                  FilterChip(
                    label: Text(textoTipoCuidado(t, x)),
                    selected: a.tipos.contains(x),
                    onSelected: (si) => cambiar(
                      a.copyWith(
                        tipos: si ? {...a.tipos, x} : ({...a.tipos}..remove(x)),
                      ),
                    ),
                  ),
              ],
            ),
            if (a.tipos.any((x) => x.ocupaLugar))
              _opcion(
                t.cuidadosCupo,
                a.cupo,
                const [1, 2, 3, 4, 5, 6, 8, 10, 12, 15, 20, 30],
                (v) => '$v',
                (v) => cambiar(a.copyWith(cupo: v)),
              ),
            _opcion(
              t.agendaDiasAdelante,
              a.diasAdelante,
              const [7, 14, 30, 60, 90, 180],
              t.agendaDias,
              (v) => cambiar(a.copyWith(diasAdelante: v)),
            ),
            _opcion(
              t.cuidadosMaximoDias,
              a.maximoDias,
              const [1, 3, 7, 15, 30, 60],
              t.agendaDias,
              (v) => cambiar(a.copyWith(maximoDias: v)),
            ),
            TextField(
              controller: _condiciones,
              maxLength: 300,
              maxLines: 2,
              decoration: InputDecoration(labelText: t.cuidadosCondiciones),
              onChanged: (v) => cambiar(a.copyWith(condiciones: v)),
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
