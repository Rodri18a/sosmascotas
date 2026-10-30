import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/negocios_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../widgets/volver.dart';
import 'negocio_screen.dart' show textoPlan;

/// «Tu plan» en el modo comercio (2.2, D103): qué incluye, cuándo vence, los
/// pagos, el antes y después, y pedir un plan pago (lo llama la
/// administración: el cobro es manual).
class PlanScreen extends ConsumerWidget {
  const PlanScreen({required this.negocioId, super.key});

  final String negocioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.planTitulo),
      ),
      body: switch (ref.watch(miPlanProvider(negocioId))) {
        AsyncData(:final value) => _Contenido(negocioId: negocioId, p: value),
        AsyncError() => Center(child: Text(t.errorSinConexion)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Contenido extends ConsumerWidget {
  const _Contenido({required this.negocioId, required this.p});

  final String negocioId;
  final MiPlan p;

  String _incluye(AppLocalizations t, PlanComercio plan) => switch (plan) {
    PlanComercio.basic => t.planIncluyeBasico,
    PlanComercio.featured => t.planIncluyeDestacado,
    PlanComercio.plus => t.planIncluyePlus,
  };

  Future<void> _pedir(
    BuildContext context,
    WidgetRef ref,
    PlanComercio plan,
  ) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref.read(negociosRepositorioProvider).pedirPlan(negocioId, plan);
      ref
        ..read(metricasProvider).track(
          Eventos.planRequest,
          businessId: negocioId,
          props: {'plan': plan.name},
        )
        ..invalidate(miPlanProvider(negocioId));
      mensajes.showSnackBar(SnackBar(content: Text(t.planPedido)));
    } on Exception catch (e) {
      mensajes.showSnackBar(
        SnackBar(
          content: Text(
            e.toString().contains('23505')
                ? t.planPedidoAbierto
                : t.errorSinConexion,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final fechas = MaterialLocalizations.of(context);
    final mejores = [
      for (final plan in PlanComercio.values)
        if (plan.index > p.plan.index) plan,
    ];
    final ad = p.antesYDespues;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: Text(
              t.planActual(textoPlan(t, p.plan)),
              style: tema.textTheme.titleMedium,
            ),
            subtitle: Text(
              [
                _incluye(t, p.plan),
                if (p.socioFundadorHasta case final f?
                    when p.fundador || p.estado == null)
                  t.planFundador(fechas.formatMediumDate(f)),
                if (p.vence case final v? when p.esPago)
                  switch (p.estado) {
                    EstadoPlan.conAtraso => t.planVencido(
                      fechas.formatMediumDate(v),
                    ),
                    EstadoPlan.cancelado => t.planCancelado(
                      fechas.formatMediumDate(v),
                    ),
                    _ => t.planVence(fechas.formatMediumDate(v)),
                  },
                if (p.esPago && p.precio > 0)
                  t.planPrecio(p.precio.toStringAsFixed(0)),
              ].join('\n\n'),
            ),
          ),
        ),
        if (ad != null) ...[
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.trending_up_outlined),
              title: Text(t.planAntesDespues),
              subtitle: Text(
                t.planAntesDespuesTexto(
                  ad.dias,
                  ad.aperturasDespues,
                  ad.contactosDespues,
                  ad.aperturasAntes,
                  ad.contactosAntes,
                ),
              ),
            ),
          ),
        ],
        if (mejores.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(t.planMejorar, style: tema.textTheme.titleMedium),
          for (final plan in mejores)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(textoPlan(t, plan), style: tema.textTheme.titleSmall),
                    Text(_incluye(t, plan)),
                    const SizedBox(height: 8),
                    FilledButton.tonal(
                      onPressed: p.pedidoAbierto
                          ? null
                          : () => _pedir(context, ref, plan),
                      child: Text(t.planQuiero(textoPlan(t, plan))),
                    ),
                  ],
                ),
              ),
            ),
          Text(
            p.pedidoAbierto ? t.planPedidoAbierto : t.planComoSePaga,
            style: tema.textTheme.bodySmall,
          ),
        ],
        if (p.pagos.isNotEmpty) ...[
          const SizedBox(height: 16),
          Text(t.planPagos, style: tema.textTheme.titleMedium),
          Card(
            child: Column(
              children: [
                for (final pago in p.pagos)
                  ListTile(
                    dense: true,
                    leading: const Icon(Icons.receipt_outlined),
                    title: Text(
                      t.planPago(
                        fechas.formatMediumDate(pago.fecha),
                        pago.monto.toStringAsFixed(0),
                        pago.meses,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
