import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../adopcion/apadrinamiento_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../widgets/explicacion_corta.dart';
import '../../widgets/volver.dart';

String textoErrorApadrinamiento(AppLocalizations t, ErrorApadrinamiento e) =>
    switch (e) {
      ErrorApadrinamiento.soloVerificados => t.apadrinarSoloVerificados,
      ErrorApadrinamiento.noDisponible => t.apadrinarNoDisponible,
      ErrorApadrinamiento.yaHayUno => t.apadrinarYaHayUno,
      ErrorApadrinamiento.limite => t.apadrinarLimite,
      ErrorApadrinamiento.noSePuede => t.errorDesconocido,
      ErrorApadrinamiento.sinConexion => t.errorSinConexion,
    };

String _estado(AppLocalizations t, EstadoApadrinamiento e) => switch (e) {
  EstadoApadrinamiento.pendiente => t.apadrinarPendiente,
  EstadoApadrinamiento.activo => t.apadrinarActivo,
  EstadoApadrinamiento.rechazado => t.apadrinarRechazado,
  EstadoApadrinamiento.terminado => t.apadrinarTerminado,
};

/// Modo comercio → Apadrinar (3.4b, D108). Un comercio verificado ofrece
/// apadrinar a un refugio o a una feria suya; un refugio responde los
/// ofrecimientos que recibe.
class ApadrinamientoScreen extends ConsumerStatefulWidget {
  const ApadrinamientoScreen({required this.negocioId, super.key});

  final String negocioId;

  @override
  ConsumerState<ApadrinamientoScreen> createState() => _ApadrinamientoState();
}

class _ApadrinamientoState extends ConsumerState<ApadrinamientoScreen> {
  Future<void> _hacer(
    Future<void> Function(ApadrinamientoRepositorio repo) accion, {
    required String estado,
  }) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await accion(ref.read(apadrinamientoRepositorioProvider));
      ref
          .read(metricasProvider)
          .track(
            Eventos.sponsorshipStatus,
            businessId: widget.negocioId,
            props: {'estado': estado},
          );
      ref.invalidate(apadrinamientoNegocioProvider(widget.negocioId));
    } on ApadrinamientoException catch (e) {
      mensajes.showSnackBar(
        SnackBar(content: Text(textoErrorApadrinamiento(t, e.motivo))),
      );
    }
  }

  Future<void> _ofrecer(RefugioParaApadrinar r) async {
    final oferta = await showDialog<(String, String?)>(
      context: context,
      builder: (_) => _Ofrecer(refugio: r),
    );
    if (oferta == null) return;
    await _hacer(
      (repo) => repo.ofrecer(
        negocioId: widget.negocioId,
        refugioId: r.id,
        aporte: oferta.$1,
        eventoId: oferta.$2,
      ),
      estado: 'pending',
    );
  }

  Widget _tarjeta(Apadrinamiento a, {required bool soyRefugio}) {
    final t = context.t;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [a.otro, ?a.evento].join(' · '),
              style: Theme.of(context).textTheme.titleSmall,
            ),
            Text('«${a.aporte}»'),
            Text(_estado(t, a.estado)),
            Wrap(
              spacing: 8,
              children: [
                if (soyRefugio &&
                    a.estado == EstadoApadrinamiento.pendiente) ...[
                  FilledButton(
                    onPressed: () => _hacer(
                      (repo) => repo.responder(a.id, aceptar: true),
                      estado: 'active',
                    ),
                    child: Text(t.apadrinarAceptar),
                  ),
                  TextButton(
                    onPressed: () => _hacer(
                      (repo) => repo.responder(a.id, aceptar: false),
                      estado: 'declined',
                    ),
                    child: Text(t.apadrinarRechazar),
                  ),
                ],
                if (a.estado == EstadoApadrinamiento.activo ||
                    (!soyRefugio && a.estado == EstadoApadrinamiento.pendiente))
                  TextButton(
                    onPressed: () =>
                        _hacer((repo) => repo.terminar(a.id), estado: 'ended'),
                    child: Text(
                      a.estado == EstadoApadrinamiento.activo
                          ? t.apadrinarTerminar
                          : t.apadrinarRetirar,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.apadrinarTitulo),
      ),
      body: switch (ref.watch(
        apadrinamientoNegocioProvider(widget.negocioId),
      )) {
        AsyncData(value: final d) when d.esRefugio => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ExplicacionCorta(
              id: 'apadrinar_refugio_ayuda',
              corta: t.apadrinarRefugioAyudaCorta,
              larga: t.apadrinarRefugioAyuda,
              estilo: tema.textTheme.bodySmall,
            ),
            if (d.recibidos.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(t.apadrinarSinRecibidos),
              ),
            for (final a in d.recibidos) _tarjeta(a, soyRefugio: true),
          ],
        ),
        AsyncData(value: final d) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            ExplicacionCorta(
              id: 'apadrinar_ayuda',
              corta: t.apadrinarAyudaCorta,
              larga: t.apadrinarAyuda,
              estilo: tema.textTheme.bodySmall,
            ),
            if (!d.puedeOfrecer)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(t.apadrinarSoloVerificados),
              ),
            if (d.ofrecidos.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(t.apadrinarTuyos, style: tema.textTheme.titleMedium),
              for (final a in d.ofrecidos) _tarjeta(a, soyRefugio: false),
            ],
            if (d.puedeOfrecer) ...[
              const SizedBox(height: 16),
              Text(t.apadrinarRefugios, style: tema.textTheme.titleMedium),
              if (d.refugios.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Text(t.apadrinarSinRefugios),
                ),
              for (final r in d.refugios)
                Card(
                  child: ListTile(
                    title: Text(r.nombre),
                    subtitle: Text(
                      [
                        ?r.direccion,
                        if (r.eventos.isNotEmpty)
                          t.apadrinarEventos(r.eventos.length),
                      ].join(' · '),
                    ),
                    trailing: FilledButton.tonal(
                      onPressed: () => _ofrecer(r),
                      child: Text(t.apadrinarOfrecer),
                    ),
                  ),
                ),
            ],
          ],
        ),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        _ => Center(child: Text(t.errorSinConexion)),
      },
    );
  }
}

class _Ofrecer extends StatefulWidget {
  const _Ofrecer({required this.refugio});

  final RefugioParaApadrinar refugio;

  @override
  State<_Ofrecer> createState() => _OfrecerState();
}

class _OfrecerState extends State<_Ofrecer> {
  final _aporte = TextEditingController();
  String? _evento;
  String? _error;

  @override
  void dispose() {
    _aporte.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final r = widget.refugio;
    return AlertDialog(
      title: Text(t.apadrinarA(r.nombre)),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (r.eventos.isNotEmpty)
              DropdownButtonFormField<String?>(
                initialValue: _evento,
                isExpanded: true,
                decoration: InputDecoration(labelText: t.apadrinarQue),
                items: [
                  DropdownMenuItem(child: Text(t.apadrinarAlRefugio)),
                  for (final e in r.eventos)
                    DropdownMenuItem(value: e.id, child: Text(e.titulo)),
                ],
                onChanged: (v) => setState(() => _evento = v),
              ),
            TextField(
              controller: _aporte,
              maxLength: 200,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: t.apadrinarAporte,
                hintText: t.apadrinarAporteEjemplo,
                errorText: _error,
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancelar),
        ),
        FilledButton(
          onPressed: () {
            if (_aporte.text.trim().length < 3) {
              setState(() => _error = t.apadrinarFaltaAporte);
              return;
            }
            Navigator.pop<(String, String?)>(context, (
              _aporte.text.trim(),
              _evento,
            ));
          },
          child: Text(t.apadrinarOfrecer),
        ),
      ],
    );
  }
}

/// "Apadrinado por …" en la ficha de un refugio o en un evento. No muestra
/// nada si no hay padrinos.
class LineaPadrinos extends ConsumerWidget {
  const LineaPadrinos({this.negocioId, this.eventoId, super.key});

  final String? negocioId;
  final String? eventoId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final padrinos =
        ref.watch(padrinosProvider((negocioId, eventoId))).value ??
        const <Padrino>[];
    if (padrinos.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.volunteer_activism_outlined, size: 18),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              context.t.apadrinadoPor(
                [
                  for (final p in padrinos) '${p.nombre} (${p.aporte})',
                ].join(', '),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// En el panel del modo comercio.
class TarjetaApadrinar extends StatelessWidget {
  const TarjetaApadrinar({
    required this.negocioId,
    required this.esRefugio,
    super.key,
  });

  final String negocioId;
  final bool esRefugio;

  @override
  Widget build(BuildContext context) => Card(
    child: ListTile(
      leading: const Icon(Icons.volunteer_activism_outlined),
      title: Text(
        esRefugio ? context.t.apadrinarPadrinos : context.t.apadrinarTitulo,
      ),
      subtitle: Text(
        esRefugio
            ? context.t.apadrinarTarjetaRefugio
            : context.t.apadrinarTarjeta,
      ),
      trailing: const Icon(Icons.chevron_right_outlined),
      onTap: () => context.push(Rutas.apadrinar(negocioId)),
    ),
  );
}
