import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/textos_comercio.dart';
import '../../cuenta/con_cuenta.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../eventos/eventos_repositorio.dart';
import '../../mascotas/catalogo.dart';
import '../../mascotas/mascota_elegida.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../noticias/noticias_repositorio.dart';
import '../../router.dart';
import '../../utiles/enlaces.dart';
import '../../widgets/boton_ajustes.dart';
import '../../widgets/boton_avisos.dart';
import '../../widgets/boton_mensajes.dart';
import '../eventos/eventos.dart';
import '../menu/menu_principal.dart';
import '../sos/sos_detalle_screen.dart';

/// Noticias (2.8, D83): filtradas por las especies de mis mascotas, con las
/// patrocinadas siempre marcadas "Promocionado · «marca»". La sección
/// Comunidad (D86) muestra lo que pasa en la app: reencuentros, adopciones,
/// lugares verificados, eventos y las perdidas que se siguen buscando. A las
/// noticias y novedades se puede reaccionar (D87). Es la primera pestaña y
/// la ve cualquiera; reaccionar pide ingresar (D94).
class NoticiasScreen extends ConsumerStatefulWidget {
  const NoticiasScreen({super.key});

  @override
  ConsumerState<NoticiasScreen> createState() => _NoticiasScreenState();
}

class _NoticiasScreenState extends ConsumerState<NoticiasScreen> {
  /// Especie elegida en los chips; `null` = "Todas". Hasta tocar uno, manda
  /// la mascota elegida en el menú (D88).
  int? _especie;
  bool _tocoChip = false;

  bool _comunidad = false;

  @override
  void initState() {
    super.initState();
    // Los totales de reacciones se traen de a tanda, al llegar cada lista.
    ref
      ..listenManual(noticiasProvider, (_, s) {
        if (s.value case final lista?) {
          ref.read(reaccionesProvider.notifier).cargar([
            for (final n in lista) n.id,
          ]);
        }
      }, fireImmediately: true)
      ..listenManual(novedadesProvider, (_, s) {
        if (s.value case final lista?) {
          ref.read(reaccionesProvider.notifier).cargar([
            for (final n in lista)
              if (n.admiteReacciones) n.id,
          ]);
        }
      }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final mascotas = ref.watch(misMascotasProvider).value ?? const <Mascota>[];
    final especies = ref.watch(especiesProvider).value ?? const <Especie>[];
    final mias = [
      for (final e in especies)
        if (mascotas.any((m) => m.especieId == e.id)) e,
    ];
    final especie = _tocoChip ? _especie : ref.watch(especieElegidaProvider);
    final filtro = especie == null ? const <int>{} : {especie};

    return Scaffold(
      drawer: const MenuPrincipal(),
      appBar: AppBar(
        title: Text(t.noticiasTitulo),
        actions: const [BotonMensajes(), BotonAvisos(), BotonAjustes()],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(reaccionesProvider);
          if (_comunidad) {
            ref
              ..invalidate(novedadesProvider)
              ..invalidate(resumenComunidadProvider)
              ..invalidate(eventosCercanosProvider);
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
                      selected: especie == null,
                      onSelected: (_) => setState(() {
                        _tocoChip = true;
                        _especie = null;
                      }),
                    ),
                    for (final e in mias) ...[
                      const SizedBox(width: 6),
                      ChoiceChip(
                        label: Text('${e.icono} ${e.nombre}'),
                        selected: especie == e.id,
                        onSelected: (_) => setState(() {
                          _tocoChip = true;
                          _especie = e.id;
                        }),
                      ),
                    ],
                  ],
                ),
              ),
            if (_comunidad) ...[
              // Próximos eventos de la zona, arriba de las novedades (D94).
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SeccionEventos(),
              ),
              _Comunidad(filtro: filtro),
            ] else
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
              TotalesReacciones(id: n.id),
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
    useRootNavigator: true,
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
              const SizedBox(height: 20),
              BarraReacciones(id: n.id),
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
    TipoNovedad.perdida => (
      nombre == null ? t.comunidadSeBuscaSinNombre : t.comunidadSeBusca(nombre),
      '${t.comunidadPerdidaDias(n.cantidad ?? 0)} ${t.comunidadPerdidaAyuda}',
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
    TipoNovedad.perdida => Icons.search,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final n = novedad;
    final (titulo, bajada) = textosNovedad(context, n);
    final url = ref.watch(noticiasRepositorioProvider).urlFoto(n.fotoPath);
    final perdida = n.tipo == TipoNovedad.perdida;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: InkWell(
        // Una perdida abre su reporte (para avisar o "Seguirlo", D74); lo
        // demás, el detalle con las reacciones.
        onTap: switch (n.origenId) {
          // Encima de Noticias (la ruta /sos/:id está dentro de las pestañas
          // y empujarla desde acá duplica la barra): la flecha vuelve acá.
          final sos? when perdida => () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SosDetalleScreen(sosId: sos),
            ),
          ),
          _ when perdida => null,
          _ => () => abrirNovedad(context, ref, n),
        },
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
                      MaterialLocalizations.of(
                        context,
                      ).formatMediumDate(n.fecha),
                      style: tema.textTheme.bodySmall,
                    ),
                    if (n.admiteReacciones) TotalesReacciones(id: n.id),
                  ],
                ),
              ),
              if (perdida) const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

/// Detalle de una novedad: la foto grande, el texto y las reacciones.
Future<void> abrirNovedad(BuildContext context, WidgetRef ref, Novedad n) {
  ref
      .read(metricasProvider)
      .track(Eventos.newsOpen, props: {'comunidad': n.tipo.name});
  final url = ref.read(noticiasRepositorioProvider).urlFoto(n.fotoPath);
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final tema = Theme.of(context);
      final (titulo, bajada) = textosNovedad(context, n);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (url != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(titulo, style: tema.textTheme.titleLarge),
              if (bajada.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(bajada),
              ],
              const SizedBox(height: 4),
              Text(
                MaterialLocalizations.of(context).formatMediumDate(n.fecha),
                style: tema.textTheme.bodySmall,
              ),
              if (n.admiteReacciones) ...[
                const SizedBox(height: 20),
                BarraReacciones(id: n.id),
              ],
            ],
          ),
        ),
      );
    },
  );
}

String textoReaccion(AppLocalizations t, Reaccion r) => switch (r) {
  Reaccion.alegra => t.reaccionAlegra,
  Reaccion.festejo => t.reaccionFestejo,
  Reaccion.gracias => t.reaccionGracias,
};

/// Totales chicos para las tarjetas ("❤️ 3   🎉 1"); nada si no hay.
class TotalesReacciones extends ConsumerWidget {
  const TotalesReacciones({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(reaccionesProvider.select((m) => m[id]));
    if (r == null || r.total == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        [
          for (final x in Reaccion.values)
            if (r.cuantas(x) > 0) '${x.emoji} ${r.cuantas(x)}',
        ].join('   '),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

/// Las reacciones para tocar (D87): una por persona; tocar la mía la quita.
/// Sin comentarios a propósito. Un visitante tiene que ingresar.
class BarraReacciones extends ConsumerWidget {
  const BarraReacciones({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final r =
        ref.watch(reaccionesProvider.select((m) => m[id])) ??
        const Reacciones();

    Future<void> tocar(Reaccion x) async {
      if (!ref.read(conectadoProvider)) {
        await abrirConCuenta(
          context,
          ref,
          destino: Rutas.noticias,
          motivo: t.reaccionesMotivoCuenta,
        );
        return;
      }
      final mensajes = ScaffoldMessenger.of(context);
      try {
        await ref.read(reaccionesProvider.notifier).tocar(id, x);
      } on Exception {
        mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.reaccionesTitulo, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final x in Reaccion.values)
              ChoiceChip(
                showCheckmark: false,
                label: Text(
                  [
                    '${x.emoji} ${textoReaccion(t, x)}',
                    if (r.cuantas(x) > 0) '${r.cuantas(x)}',
                  ].join(' · '),
                ),
                selected: r.mia == x,
                onSelected: (_) => tocar(x),
              ),
          ],
        ),
      ],
    );
  }
}
