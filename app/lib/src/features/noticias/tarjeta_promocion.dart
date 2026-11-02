import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/comercios_repositorio.dart';
import '../../comercios/promociones_repositorio.dart';
import '../../cuenta/con_cuenta.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../mapa/ficha_comercio.dart';

/// Promoción de un comercio en el muro (plan de mejoras 3.1, D136): marcada
/// «Promocionado», abre la ficha del comercio y se puede reportar.
class TarjetaPromocion extends ConsumerStatefulWidget {
  const TarjetaPromocion({required this.promocion, super.key});

  final Promocion promocion;

  @override
  ConsumerState<TarjetaPromocion> createState() => _TarjetaPromocionState();
}

class _TarjetaPromocionState extends ConsumerState<TarjetaPromocion> {
  @override
  void initState() {
    super.initState();
    // Una vista por sesión y por promoción: para las estadísticas del comercio.
    final p = widget.promocion;
    if (ref.read(promocionesVistasProvider).add(p.id)) {
      ref
          .read(metricasProvider)
          .track(Eventos.promoView, targetId: p.id, businessId: p.negocioId);
    }
  }

  Future<void> _abrir() async {
    final p = widget.promocion;
    final mensajes = ScaffoldMessenger.of(context);
    final error = context.t.errorSinConexion;
    ref
        .read(metricasProvider)
        .track(Eventos.promoClick, targetId: p.id, businessId: p.negocioId);
    final punto = p.punto;
    if (punto == null) return;
    try {
      // La ficha del mapa: se busca el comercio en su mismo punto.
      const margen = 0.0005;
      final lugares = await ref
          .read(comerciosRepositorioProvider)
          .enZona(
            Limites(
              minLat: punto.lat - margen,
              minLng: punto.lng - margen,
              maxLat: punto.lat + margen,
              maxLng: punto.lng + margen,
            ),
          );
      final comercio = lugares.where((c) => c.id == p.negocioId).firstOrNull;
      if (comercio == null || !mounted) return;
      await mostrarFichaComercio(context, ref, comercio);
    } on Exception {
      mensajes.showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _reportar() async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    if (!await hayCuenta(
      context,
      ref,
      volverA: Rutas.inicio,
      motivo: t.promoReportarCuenta,
    )) {
      return;
    }
    if (!mounted) return;
    final motivo = await showDialog<String>(
      context: context,
      builder: (context) => SimpleDialog(
        title: Text(t.promoReportarTitulo),
        children: [
          for (final m in [
            t.promoMotivoEngano,
            t.promoMotivoAnimales,
            t.promoMotivoOtro,
          ])
            SimpleDialogOption(
              onPressed: () => Navigator.pop(context, m),
              child: Text(m),
            ),
        ],
      ),
    );
    if (motivo == null) return;
    try {
      await ref
          .read(promocionesRepositorioProvider)
          .reportar(widget.promocion.id, motivo);
      ref
          .read(metricasProvider)
          .track(Eventos.promoReport, targetId: widget.promocion.id);
      mensajes.showSnackBar(SnackBar(content: Text(t.promoReportada)));
    } on Exception {
      mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final p = widget.promocion;
    final foto = p.fotoPath;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: _abrir,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (foto != null)
              AspectRatio(
                aspectRatio: 2,
                child: Image.network(
                  ref.read(comerciosRepositorioProvider).urlFoto(foto),
                  fit: BoxFit.cover,
                  semanticLabel: p.negocio,
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 4, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          t.promoEtiqueta(p.negocio ?? ''),
                          style: tema.textTheme.labelMedium?.copyWith(
                            color: tema.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: t.promoReportarTitulo,
                        icon: const Icon(Icons.more_horiz_outlined),
                        onPressed: _reportar,
                      ),
                    ],
                  ),
                  Text(p.titulo, style: tema.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(p.texto),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
