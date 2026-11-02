import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../metricas/metricas.dart';
import '../../noticias/noticias_repositorio.dart';
import '../../utiles/enlaces.dart';
import 'noticias_screen.dart';

/// Carrusel de banners arriba del Inicio (D128): pasa solo cada 3 segundos,
/// también se desliza con el dedo y se frena mientras alguien lo toca. Si el
/// sistema pide reducir el movimiento, no pasa solo. Sin banners no ocupa
/// lugar.
class CarruselBanners extends ConsumerWidget {
  const CarruselBanners({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      switch (ref.watch(bannersProvider)) {
        AsyncData(:final value) when value.isNotEmpty => Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: _Carrusel(banners: value),
            ),
          ),
        ),
        _ => const SizedBox.shrink(),
      };
}

class _Carrusel extends ConsumerStatefulWidget {
  const _Carrusel({required this.banners});

  final List<BannerInicio> banners;

  @override
  ConsumerState<_Carrusel> createState() => _CarruselState();
}

class _CarruselState extends ConsumerState<_Carrusel> {
  static const intervalo = Duration(seconds: 3);

  /// Arranca lejos del cero para poder ir siempre hacia adelante (después
  /// del último viene el primero, sin volver para atrás).
  static const _inicio = 1000;

  late final _paginas = PageController(initialPage: _inicio);
  Timer? _timer;
  var _actual = 0;
  var _tocando = false;

  int get _cantidad => widget.banners.length;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(intervalo, (_) => _pasar());
  }

  @override
  void dispose() {
    _timer?.cancel();
    _paginas.dispose();
    super.dispose();
  }

  void _pasar() {
    if (!mounted || _tocando || _cantidad < 2 || !_paginas.hasClients) return;
    // Quieto si se pidió menos movimiento o si la pestaña no está a la vista.
    if (MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled) {
      return;
    }
    unawaited(
      _paginas.nextPage(
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      ),
    );
  }

  Future<void> _abrir(BannerInicio b) async {
    ref
        .read(metricasProvider)
        .track(Eventos.bannerOpen, props: {'patrocinado': b.patrocinado});
    if (b.enlace case final enlace?) {
      await ref.read(abrirEnlaceProvider)(Uri.parse(enlace));
      return;
    }
    if (b.noticiaId case final id?) {
      final noticias = await ref.read(noticiasProvider.future);
      for (final n in noticias) {
        if (n.id == id) {
          if (mounted) await abrirNoticia(context, ref, n);
          return;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final repo = ref.watch(noticiasRepositorioProvider);
    return Column(
      children: [
        Listener(
          onPointerDown: (_) => _tocando = true,
          onPointerUp: (_) => _tocando = false,
          onPointerCancel: (_) => _tocando = false,
          child: AspectRatio(
            aspectRatio: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: PageView.builder(
                controller: _paginas,
                onPageChanged: (i) => setState(() => _actual = i % _cantidad),
                // Con uno solo no se desliza.
                itemCount: _cantidad < 2 ? 1 : null,
                itemBuilder: (context, i) {
                  final b = widget.banners[(_cantidad < 2 ? 0 : i) % _cantidad];
                  return _Pagina(
                    banner: b,
                    url: repo.urlFoto('banners/${b.imagen}'),
                    onTap: b.enlace == null && b.noticiaId == null
                        ? null
                        : () => _abrir(b),
                  );
                },
              ),
            ),
          ),
        ),
        if (_cantidad > 1)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: ExcludeSemantics(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _cantidad; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      width: i == _actual ? 18 : 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: i == _actual
                            ? tema.colorScheme.primary
                            : tema.colorScheme.outlineVariant,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _Pagina extends StatelessWidget {
  const _Pagina({required this.banner, required this.url, this.onTap});

  final BannerInicio banner;
  final String? url;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    // Sin imagen (o si no carga), el título sobre el color de la marca.
    final respaldo = ColoredBox(
      color: tema.colorScheme.primaryContainer,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            banner.titulo,
            textAlign: TextAlign.center,
            style: tema.textTheme.titleLarge?.copyWith(
              color: tema.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ),
    );
    return Semantics(
      button: onTap != null,
      label: banner.titulo,
      child: InkWell(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            switch (url) {
              final u? => Image.network(
                u,
                fit: BoxFit.cover,
                excludeFromSemantics: true,
                errorBuilder: (_, _, _) => respaldo,
              ),
              null => ExcludeSemantics(child: respaldo),
            },
            if (banner.patrocinado)
              Positioned(
                top: 8,
                left: 8,
                child: EtiquetaPromocionado(marca: banner.marca),
              ),
          ],
        ),
      ),
    );
  }
}
