import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/textos_comercio.dart';
import '../../mascotas/catalogo.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../noticias/noticias_repositorio.dart';
import '../../utiles/enlaces.dart';
import '../eventos/eventos.dart';

/// Noticias (2.8, D83): filtradas por las especies de mis mascotas, con las
/// patrocinadas siempre marcadas "Promocionado · «marca»". La sección
/// Comunidad (D86) muestra lo que pasa en la app: reencuentros, adopciones,
/// lugares verificados y eventos.
class NoticiasScreen extends ConsumerStatefulWidget {
  const NoticiasScreen({super.key});

  @override
  ConsumerState<NoticiasScreen> createState() => _NoticiasScreenState();
}

class _NoticiasScreenState extends ConsumerState<NoticiasScreen> {
  /// Especie elegida en los chips; `null` = "Todas".
  int? _especie;

  bool _comunidad = false;

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
          if (_comunidad) {
            ref
              ..invalidate(novedadesProvider)
              ..invalidate(resumenComunidadProvider);
            await ref.read(novedadesProvider.future);
          } else {
            ref.invalidate(noticiasProvider);
            await ref.read(noticiasProvider.future);
          }
        },
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: SegmentedButton<bool>(
                segments: [
                  ButtonSegment(
                    value: false,
                    icon: const Icon(Icons.newspaper_outlined),
                    label: Text(t.noticiasSeccionNoticias),
                  ),
                  ButtonSegment(
                    value: true,
                    icon: const Icon(Icons.diversity_3_outlined),
                    label: Text(t.noticiasSeccionComunidad),
                  ),
                ],
                selected: {_comunidad},
                onSelectionChanged: (s) => setState(() => _comunidad = s.first),
              ),
            ),
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
            if (_comunidad)
              _Comunidad(filtro: filtro)
            else
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

/// Sección Comunidad (D86): resumen de los últimos 30 días y novedades.
class _Comunidad extends ConsumerWidget {
  const _Comunidad({required this.filtro});

  final Set<int> filtro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final resumen = ref.watch(resumenComunidadProvider).value;
    final enResumen = resumen == null
        ? const <(IconData, String)>[]
        : [
            if (resumen.reencuentros > 0)
              (
                Icons.home_outlined,
                t.comunidadResumenReencuentros(resumen.reencuentros),
              ),
            if (resumen.adopciones > 0)
              (
                Icons.favorite_outline,
                t.comunidadResumenAdopciones(resumen.adopciones),
              ),
            if (resumen.perdidasActivas > 0)
              (
                Icons.search,
                t.comunidadResumenPerdidas(resumen.perdidasActivas),
              ),
            if (resumen.lugaresVerificados > 0)
              (
                Icons.verified_outlined,
                t.comunidadResumenLugares(resumen.lugaresVerificados),
              ),
          ];
    final colorResumen = tema.colorScheme.onPrimaryContainer;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
          child: Text(t.comunidadExplicacion, style: tema.textTheme.bodySmall),
        ),
        if (enResumen.isNotEmpty)
          Card(
            margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            color: tema.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    t.comunidadResumenTitulo,
                    style: tema.textTheme.titleMedium?.copyWith(
                      color: colorResumen,
                    ),
                  ),
                  for (final (icono, texto) in enResumen)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Row(
                        children: [
                          Icon(icono, size: 20, color: colorResumen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              texto,
                              style: TextStyle(color: colorResumen),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        switch (ref.watch(novedadesProvider)) {
          AsyncData(:final value) => () {
            final lista = [
              for (final n in value)
                if (n.esPara(filtro)) n,
            ];
            return lista.isEmpty
                ? Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(t.comunidadVacio, textAlign: TextAlign.center),
                  )
                : Column(
                    children: [
                      for (final n in lista) TarjetaNovedad(novedad: n),
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
    );
  }
}

/// Título y bajada de una novedad, armados con los textos de la app.
(String, String) textosNovedad(BuildContext context, Novedad n) {
  final t = context.t;
  final nombre = n.nombre;
  return switch (n.tipo) {
    TipoNovedad.reencuentro when n.eraPerdida => (
      nombre == null
          ? t.comunidadVolvioACasaSinNombre
          : t.comunidadVolvioACasa(nombre),
      [
        if (n.cantidad case final dias?) t.comunidadDiasPerdida(dias),
        t.comunidadGracias,
      ].join(' '),
    ),
    TipoNovedad.reencuentro => (
      nombre == null
          ? t.comunidadVolvioConSuFamiliaSinNombre
          : t.comunidadVolvioConSuFamilia(nombre),
      t.comunidadGracias,
    ),
    TipoNovedad.adopcion => (
      nombre == null
          ? t.comunidadAdoptados(n.cantidad ?? 1)
          : t.comunidadAdoptado(nombre),
      t.comunidadAdopcionDetalle,
    ),
    TipoNovedad.comercio => (
      t.comunidadLugarNuevo(nombre ?? ''),
      switch (n.categoria) {
        final c? => textoCategoria(t, c),
        null => '',
      },
    ),
    TipoNovedad.evento => (
      t.comunidadEvento(nombre ?? ''),
      [
        if (n.tipoEvento case final e?) textoTipoEvento(t, e),
        if (n.desde case final d?)
          MaterialLocalizations.of(context).formatMediumDate(d),
      ].join(' · '),
    ),
  };
}

class TarjetaNovedad extends ConsumerWidget {
  const TarjetaNovedad({required this.novedad, super.key});

  final Novedad novedad;

  static IconData _icono(TipoNovedad tipo) => switch (tipo) {
    TipoNovedad.reencuentro => Icons.celebration_outlined,
    TipoNovedad.adopcion => Icons.volunteer_activism_outlined,
    TipoNovedad.comercio => Icons.verified_outlined,
    TipoNovedad.evento => Icons.event_outlined,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final n = novedad;
    final (titulo, bajada) = textosNovedad(context, n);
    final url = ref.watch(noticiasRepositorioProvider).urlFoto(n.fotoPath);
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: tema.colorScheme.secondaryContainer,
              foregroundImage: url == null ? null : NetworkImage(url),
              child: Icon(
                _icono(n.tipo),
                color: tema.colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(titulo, style: tema.textTheme.titleMedium),
                  if (bajada.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(bajada),
                  ],
                  const SizedBox(height: 6),
                  Text(
                    MaterialLocalizations.of(context).formatMediumDate(n.fecha),
                    style: tema.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
