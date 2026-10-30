import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/negocios_repositorio.dart';
import '../../comercios/reporte_pdf.dart';
import '../../metricas/metricas.dart';
import '../../utiles/descargar.dart';
import '../../widgets/volver.dart';

/// Estadísticas del comercio (2.3, D101): este mes contra el anterior, las
/// últimas 12 semanas y mes a mes. Con el plan Básico, solo el resumen.
class EstadisticasScreen extends ConsumerWidget {
  const EstadisticasScreen({required this.negocioId, super.key});

  final String negocioId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.estadisticasTitulo),
        actions: [
          // Reporte mensual en PDF (portal de empresas, 2.10, D114): con
          // las estadísticas completas (Destacado y Plus).
          if (ref.watch(estadisticasNegocioProvider(negocioId)).value
              case final e? when e.completo && e.meses.isNotEmpty)
            IconButton(
              tooltip: t.reporteDescargar,
              onPressed: () => _reporte(context, ref, e),
              icon: const Icon(Icons.picture_as_pdf_outlined),
            ),
        ],
      ),
      body: switch (ref.watch(estadisticasNegocioProvider(negocioId))) {
        AsyncData(:final value) => RefreshIndicator(
          onRefresh: () =>
              ref.refresh(estadisticasNegocioProvider(negocioId).future),
          child: _Contenido(e: value),
        ),
        AsyncError() => Center(child: Text(t.errorSinConexion)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }

  /// El último mes completo (o el actual, si es el primero) contra el anterior.
  Future<void> _reporte(
    BuildContext context,
    WidgetRef ref,
    EstadisticasNegocio e,
  ) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    final fechas = MaterialLocalizations.of(context);
    final i = e.meses.length >= 2 ? e.meses.length - 2 : e.meses.length - 1;
    final mes = e.meses[i];
    final antes = i > 0 ? e.meses[i - 1] : null;
    String nombreMes(DateTime m) => fechas.formatMonthYear(m);
    final comercio = (ref.read(misNegociosProvider).value ?? const [])
        .where((n) => n.id == negocioId)
        .firstOrNull
        ?.comercio
        .nombre;
    final pdf = await reporteMensualPdf(
      titulo: t.reporteTitulo(nombreMes(mes.mes)),
      subtitulo: comercio ?? '',
      encabezadoAntes: antes == null ? '' : nombreMes(antes.mes),
      encabezadoAhora: nombreMes(mes.mes),
      filas: [
        for (final (metrica, texto) in [
          (MetricasComercio.aperturas, t.estadisticasAperturas),
          (MetricasComercio.personas, t.estadisticasPersonas),
          (MetricasComercio.contactos, t.estadisticasContactos),
          (MetricasComercio.favoritos, t.estadisticasFavoritos),
          (MetricasComercio.visitas, t.estadisticasVisitas),
          (MetricasComercio.chats, t.estadisticasChats),
          (MetricasComercio.catalogo, t.estadisticasCatalogo),
          (MetricasComercio.pedidos, t.estadisticasPedidos),
          (MetricasComercio.pagina, t.estadisticasPagina),
          (MetricasComercio.resenas, t.estadisticasResenas),
        ])
          (texto, mes[metrica], antes?[metrica] ?? 0),
      ],
      privacidad: t.estadisticasPrivacidad,
      pie: t.historialPie(fechas.formatMediumDate(DateTime.now())),
      normal: await rootBundle.load('assets/fuentes/SourceSans3-Regular.ttf'),
      negrita: await rootBundle.load('assets/fuentes/SourceSans3-Bold.ttf'),
    );
    final ok = descargarArchivo(
      pdf,
      'reporte-${mes.mes.year}-${mes.mes.month.toString().padLeft(2, '0')}.pdf',
      'application/pdf',
    );
    if (ok) {
      ref
          .read(metricasProvider)
          .track(Eventos.reportDownload, businessId: negocioId);
    } else {
      mensajes.showSnackBar(SnackBar(content: Text(t.historialNoDisponible)));
    }
  }
}

class _Contenido extends StatelessWidget {
  const _Contenido({required this.e});

  final EstadisticasNegocio e;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final actual = e.actual;
    final consultas =
        (actual?[MetricasComercio.consultasCatalogo] ?? 0) +
        (actual?[MetricasComercio.consultasServicios] ?? 0);
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(t.estadisticasEsteMes, style: tema.textTheme.titleMedium),
        const SizedBox(height: 8),
        if (e.sinDatos)
          Card(
            child: ListTile(
              leading: const Icon(Icons.insights_outlined),
              title: Text(t.estadisticasSinDatos),
            ),
          ),
        _Metrica(
          e: e,
          metrica: MetricasComercio.aperturas,
          icono: Icons.visibility_outlined,
          texto: t.estadisticasAperturas,
        ),
        _Metrica(
          e: e,
          metrica: MetricasComercio.contactos,
          icono: Icons.call_made_outlined,
          texto: t.estadisticasContactos,
          ayuda: t.estadisticasContactosAyuda,
        ),
        if (!e.completo) ...[
          const SizedBox(height: 8),
          Card(
            color: tema.colorScheme.secondaryContainer,
            child: ListTile(
              leading: const Icon(Icons.workspace_premium_outlined),
              title: Text(t.estadisticasSoloResumen),
            ),
          ),
        ] else ...[
          for (final (metrica, icono, texto) in [
            (
              MetricasComercio.personas,
              Icons.people_outline,
              t.estadisticasPersonas,
            ),
            (
              MetricasComercio.favoritos,
              Icons.favorite_border,
              t.estadisticasFavoritos,
            ),
            (
              MetricasComercio.visitas,
              Icons.where_to_vote_outlined,
              t.estadisticasVisitas,
            ),
            (
              MetricasComercio.chats,
              Icons.chat_bubble_outline,
              t.estadisticasChats,
            ),
            (
              MetricasComercio.catalogo,
              Icons.inventory_2_outlined,
              t.estadisticasCatalogo,
            ),
            (
              MetricasComercio.pedidos,
              Icons.receipt_long_outlined,
              t.estadisticasPedidos,
            ),
            (
              MetricasComercio.pagina,
              Icons.public_outlined,
              t.estadisticasPagina,
            ),
            (
              MetricasComercio.resenas,
              Icons.star_outline,
              t.estadisticasResenas,
            ),
          ])
            // Lo que nunca tuvo movimiento no ocupa lugar.
            if ((actual?[metrica] ?? 0) + (e.anterior?[metrica] ?? 0) > 0)
              _Metrica(e: e, metrica: metrica, icono: icono, texto: texto),
          if (consultas > 0)
            Card(
              child: ListTile(
                leading: const Icon(Icons.help_outline),
                title: Text('$consultas'),
                subtitle: Text(t.estadisticasConsultas),
              ),
            ),
          if (actual != null && actual.clics.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(t.estadisticasClics, style: tema.textTheme.titleMedium),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final MapEntry(:key, :value) in actual.clics.entries)
                      Text('${_textoClic(t, key)}: $value'),
                  ],
                ),
              ),
            ),
          ],
          if (e.semanas.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(t.estadisticasPorSemana, style: tema.textTheme.titleMedium),
            const SizedBox(height: 8),
            _Barras(
              etiquetas: [
                for (final s in e.semanas)
                  t.estadisticasSemanaDe(
                    MaterialLocalizations.of(
                      context,
                    ).formatShortMonthDay(s.semana),
                  ),
              ],
              aperturas: [for (final s in e.semanas) s.aperturas],
              contactos: [for (final s in e.semanas) s.contactos],
            ),
          ],
          if (e.meses.length > 2) ...[
            const SizedBox(height: 16),
            Text(t.estadisticasPorMes, style: tema.textTheme.titleMedium),
            Card(
              child: Column(
                children: [
                  for (final m in e.meses.reversed)
                    ListTile(
                      dense: true,
                      title: Text(
                        MaterialLocalizations.of(
                          context,
                        ).formatMonthYear(m.mes),
                      ),
                      trailing: Text(
                        '${t.estadisticasAperturas}: ${m[MetricasComercio.aperturas]} · '
                        '${t.estadisticasContactos}: ${m[MetricasComercio.contactos]}',
                      ),
                    ),
                ],
              ),
            ),
          ],
        ],
        const SizedBox(height: 16),
        Text(t.estadisticasPrivacidad, style: tema.textTheme.bodySmall),
      ],
    );
  }
}

String _textoClic(AppLocalizations t, String tipo) => switch (tipo) {
  'llamar' => t.clicLlamar,
  'whatsapp' => t.clicWhatsapp,
  'como_llegar' => t.clicComoLlegar,
  'web' => t.clicWeb,
  'instagram' => t.clicInstagram,
  _ => tipo,
};

class _Metrica extends StatelessWidget {
  const _Metrica({
    required this.e,
    required this.metrica,
    required this.icono,
    required this.texto,
    this.ayuda,
  });

  final EstadisticasNegocio e;
  final String metrica;
  final IconData icono;
  final String texto;
  final String? ayuda;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final v = e.variacion(metrica);
    final comparacion = switch (v) {
      _ when e.anterior == null => null,
      Variacion(porcentaje: null) => t.estadisticasNuevo(v.antes),
      Variacion(sube: true, :final porcentaje?) => t.estadisticasMasQue(
        porcentaje,
      ),
      Variacion(baja: true, :final porcentaje?) => t.estadisticasMenosQue(
        -porcentaje,
      ),
      _ => t.estadisticasIgual,
    };
    return Card(
      child: ListTile(
        leading: Icon(icono),
        title: Text('${v.ahora}', style: tema.textTheme.titleLarge),
        subtitle: Text([texto, ?ayuda, ?comparacion].join('\n')),
        // Color y texto: la flecha nunca es la única pista (accesibilidad).
        trailing: v.sube
            ? Icon(Icons.trending_up_outlined, color: tema.colorScheme.primary)
            : v.baja
            ? Icon(Icons.trending_down_outlined, color: tema.colorScheme.error)
            : null,
      ),
    );
  }
}

/// Barras simples por semana: aperturas (llenas) y contactos (más oscuras).
class _Barras extends StatelessWidget {
  const _Barras({
    required this.etiquetas,
    required this.aperturas,
    required this.contactos,
  });

  final List<String> etiquetas;
  final List<int> aperturas;
  final List<int> contactos;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colores = Theme.of(context).colorScheme;
    final maximo = [...aperturas, 1].reduce((a, b) => a > b ? a : b);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 120,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (var i = 0; i < aperturas.length; i++)
                    Expanded(
                      child: Semantics(
                        label:
                            '${etiquetas[i]}: ${t.estadisticasAperturas} '
                            '${aperturas[i]}, ${t.estadisticasContactos} '
                            '${contactos[i]}',
                        child: Tooltip(
                          message:
                              '${etiquetas[i]}\n${t.estadisticasAperturas}: '
                              '${aperturas[i]}\n${t.estadisticasContactos}: '
                              '${contactos[i]}',
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                FractionallySizedBox(
                                  heightFactor: aperturas[i] / maximo,
                                  child: Container(
                                    color: colores.primaryContainer,
                                  ),
                                ),
                                FractionallySizedBox(
                                  heightFactor:
                                      (contactos[i] > aperturas[i]
                                          ? aperturas[i]
                                          : contactos[i]) /
                                      maximo,
                                  child: Container(color: colores.primary),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 16,
              children: [
                _Leyenda(
                  color: colores.primaryContainer,
                  texto: t.estadisticasAperturas,
                ),
                _Leyenda(
                  color: colores.primary,
                  texto: t.estadisticasContactos,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Leyenda extends StatelessWidget {
  const _Leyenda({required this.color, required this.texto});

  final Color color;
  final String texto;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 12, height: 12, color: color),
      const SizedBox(width: 4),
      Text(texto),
    ],
  );
}
