import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../mascotas/catalogo.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../noticias/noticias_repositorio.dart';
import '../../utiles/enlaces.dart';

/// Noticias (2.8, D83): filtradas por las especies de mis mascotas, con las
/// patrocinadas siempre marcadas "Promocionado · «marca»".
class NoticiasScreen extends ConsumerStatefulWidget {
  const NoticiasScreen({super.key});

  @override
  ConsumerState<NoticiasScreen> createState() => _NoticiasScreenState();
}

class _NoticiasScreenState extends ConsumerState<NoticiasScreen> {
  /// Especie elegida en los chips; `null` = "Todas".
  int? _especie;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final mascotas = ref.watch(misMascotasProvider).value ?? const <Mascota>[];
    final especies = ref.watch(especiesProvider).value ?? const <Especie>[];
    final mias = [
      for (final e in especies)
        if (mascotas.any((m) => m.especieId == e.id)) e,
    ];
    final filtro = _especie == null ? const <int>{} : {_especie!};

    return Scaffold(
      appBar: AppBar(title: Text(t.noticiasTitulo)),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(noticiasProvider);
          await ref.read(noticiasProvider.future);
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            if (mias.isNotEmpty)
              SizedBox(
                height: 56,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  children: [
                    ChoiceChip(
                      label: Text(t.noticiasTodas),
                      selected: _especie == null,
                      onSelected: (_) => setState(() => _especie = null),
                    ),
                    for (final e in mias) ...[
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: Text('${e.icono} ${e.nombre}'),
                        selected: _especie == e.id,
                        onSelected: (_) => setState(() => _especie = e.id),
                      ),
                    ],
                  ],
                ),
              ),
            switch (ref.watch(noticiasProvider)) {
              AsyncData(:final value) => () {
                final lista = [
                  for (final n in value)
                    if (n.esPara(filtro)) n,
                ];
                return lista.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          t.noticiasVacio,
                          textAlign: TextAlign.center,
                        ),
                      )
                    : Column(
                        children: [
                          for (final n in lista) TarjetaNoticia(noticia: n),
                        ],
                      );
              }(),
              AsyncError() => Padding(
                padding: const EdgeInsets.all(32),
                child: Text(t.errorSinConexion, textAlign: TextAlign.center),
              ),
              _ => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              ),
            },
          ],
        ),
      ),
    );
  }
}

/// "Promocionado · «marca»": siempre visible en las patrocinadas.
class EtiquetaPromocionado extends StatelessWidget {
  const EtiquetaPromocionado({required this.marca, super.key});

  final String? marca;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: tema.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        context.t.noticiasPromocionado(marca ?? ''),
        style: tema.textTheme.labelSmall?.copyWith(
          color: tema.colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}

class TarjetaNoticia extends ConsumerWidget {
  const TarjetaNoticia({required this.noticia, super.key});

  final Noticia noticia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final n = noticia;
    final pie = [
      MaterialLocalizations.of(context).formatMediumDate(n.publicada),
      ?n.fuente,
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: InkWell(
        onTap: () => abrirNoticia(context, ref, n),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (n.patrocinada) ...[
                EtiquetaPromocionado(marca: n.marca),
                const SizedBox(height: 8),
              ],
              Text(n.titulo, style: tema.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(n.resumen),
              const SizedBox(height: 8),
              Text(pie, style: tema.textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// La noticia completa, con "Leer más" si tiene enlace.
Future<void> abrirNoticia(BuildContext context, WidgetRef ref, Noticia n) {
  ref
      .read(metricasProvider)
      .track(Eventos.newsOpen, props: {'patrocinada': n.patrocinada});
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final t = context.t;
      final tema = Theme.of(context);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (n.patrocinada) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: EtiquetaPromocionado(marca: n.marca),
                ),
                const SizedBox(height: 8),
              ],
              Text(n.titulo, style: tema.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                [
                  MaterialLocalizations.of(
                    context,
                  ).formatMediumDate(n.publicada),
                  ?n.fuente,
                ].join(' · '),
                style: tema.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text(n.cuerpo),
              if (n.enlace case final enlace?) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    ref
                        .read(metricasProvider)
                        .track(
                          Eventos.newsLink,
                          props: {'patrocinada': n.patrocinada},
                        );
                    ref.read(abrirEnlaceProvider)(Uri.parse(enlace));
                  },
                  icon: const Icon(Icons.open_in_new),
                  label: Text(t.noticiasLeerMas),
                ),
              ],
            ],
          ),
        ),
      );
    },
  );
}
