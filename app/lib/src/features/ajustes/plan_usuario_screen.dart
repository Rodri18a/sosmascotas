import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/plan_usuario_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../widgets/volver.dart';

String textoPlanUsuario(AppLocalizations t, Plan p) => switch (p) {
  Plan.free => t.miPlanGratis,
  Plan.pro => t.miPlanPro,
  Plan.family => t.miPlanFamilia,
};

String _incluye(AppLocalizations t, Plan p) => switch (p) {
  Plan.free => t.miPlanIncluyeGratis,
  Plan.pro => t.miPlanIncluyePro,
  Plan.family => t.miPlanIncluyeFamilia,
};

/// «Mi plan» (2.1, D111): qué incluye cada plan, el propio, cuándo vence y
/// pedir Pro o Familia (lo activa la administración: el cobro es manual).
class PlanUsuarioScreen extends ConsumerWidget {
  const PlanUsuarioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.miPlanTitulo),
      ),
      body: switch (ref.watch(miPlanUsuarioProvider)) {
        AsyncData(value: final p?) => _Contenido(p: p),
        AsyncData() || AsyncError() => Center(child: Text(t.errorSinConexion)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class _Contenido extends ConsumerWidget {
  const _Contenido({required this.p});

  final MiPlanUsuario p;

  Future<void> _pedir(BuildContext context, WidgetRef ref, Plan plan) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref.read(planUsuarioRepositorioProvider).pedir(plan);
      ref
        ..read(
          metricasProvider,
        ).track(Eventos.planRequest, props: {'plan': plan.name})
        ..invalidate(miPlanUsuarioProvider);
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
      for (final plan in Plan.values)
        if (plan.index > p.efectivo.index) plan,
    ];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.workspace_premium_outlined),
            title: Text(
              t.planActual(textoPlanUsuario(t, p.efectivo)),
              style: tema.textTheme.titleMedium,
            ),
            subtitle: Text(
              [
                _incluye(t, p.efectivo),
                if (p.porHogar) t.miPlanPorHogar,
                if (p.vence case final v? when !p.porHogar && p.esPro)
                  switch (p.estado) {
                    _ when p.prueba => t.miPlanPrueba(
                      fechas.formatMediumDate(v),
                    ),
                    EstadoPlan.conAtraso => t.miPlanVencido(
                      fechas.formatMediumDate(v),
                    ),
                    EstadoPlan.cancelado => t.miPlanVolverGratis(
                      fechas.formatMediumDate(v),
                    ),
                    _ => t.planVence(fechas.formatMediumDate(v)),
                  },
                if (p.limiteMascotas case final limite?)
                  t.miPlanMascotas(p.mascotas, limite),
              ].join('\n\n'),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(t.miPlanSiempreGratis, style: tema.textTheme.bodySmall),
        const SizedBox(height: 8),
        Card(
          child: ListTile(
            leading: const Icon(Icons.local_offer_outlined),
            title: Text(t.descuentosTitulo),
            subtitle: Text(t.descuentosTarjeta),
            trailing: const Icon(Icons.chevron_right_outlined),
            onTap: () => context.push(Rutas.descuentosPro),
          ),
        ),
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
                    Text(
                      textoPlanUsuario(t, plan),
                      style: tema.textTheme.titleSmall,
                    ),
                    Text(_incluye(t, plan)),
                    if (plan == Plan.family && !p.pruebaFamiliaUsada) ...[
                      const SizedBox(height: 4),
                      Text(
                        t.miPlanPruebaFamilia,
                        style: tema.textTheme.bodySmall,
                      ),
                    ],
                    const SizedBox(height: 8),
                    if (p.pedidoAbierto == plan)
                      Text(t.miPlanPedido(textoPlanUsuario(t, plan)))
                    else
                      FilledButton.tonal(
                        onPressed: p.pedidoAbierto != null
                            ? null
                            : () => _pedir(context, ref, plan),
                        child: Text(t.planQuiero(textoPlanUsuario(t, plan))),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(t.planComoSePaga, style: tema.textTheme.bodySmall),
        ],
      ],
    );
  }
}
