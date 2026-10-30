import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../metricas/metricas.dart';
import '../../theme/paleta.dart';

/// Pestañas de la barra inferior, en el orden de las ramas del router (D94).
enum Pestana { noticias, sos, mapa, mascotas, ayuda }

/// Estructura con la barra inferior. Cada pestaña conserva su estado al cambiar.
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  final StatefulNavigationShell navigationShell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: BarraInferior(
        actual: Pestana.values[navigationShell.currentIndex],
        onElegir: (p) {
          final misma = p.index == navigationShell.currentIndex;
          if (!misma) {
            ref
                .read(metricasProvider)
                .track(Eventos.tabOpen, props: {'tab': p.name});
          }
          // Tocar la pestaña activa vuelve a su pantalla inicial.
          navigationShell.goBranch(p.index, initialLocation: misma);
        },
      ),
    );
  }
}

/// Barra inferior: Noticias · SOS · (Mapa) · Mascotas · Ayuda (D94). El Mapa
/// es un botón redondo que sobresale de la barra, que se curva para dejarle
/// lugar. La barra reserva también la parte que sobresale: así el botón nunca
/// tapa el contenido de la pantalla (por ejemplo, un "Guardar" al final).
class BarraInferior extends StatelessWidget {
  const BarraInferior({
    required this.actual,
    required this.onElegir,
    super.key,
  });

  final Pestana actual;
  final ValueChanged<Pestana> onElegir;

  static const _alto = 68.0;
  static const _diametro = 64.0;

  /// Cuánto sobresale el botón por encima de la barra: la mitad.
  static const _sobresale = _diametro / 2;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final colores = Theme.of(context).colorScheme;
    final abajo = MediaQuery.paddingOf(context).bottom;
    Widget item(Pestana p, IconData icono, IconData elegido, String texto) =>
        Expanded(
          child: _ItemBarra(
            icono: actual == p ? elegido : icono,
            texto: texto,
            elegido: actual == p,
            onTap: () => onElegir(p),
          ),
        );

    return SizedBox(
      height: _sobresale + _alto + abajo,
      child: Stack(
        children: [
          Positioned.fill(
            top: _sobresale,
            child: PhysicalShape(
              clipper: const _RecorteBarra(radio: _sobresale + 6),
              // Del mismo color que el botón del Mapa (pedido del dueño),
              // salvo en Blanco y negro, que tiene la barra blanca (D120).
              color: context.marca.barra,
              elevation: 3,
              shadowColor: colores.shadow,
              child: Padding(
                padding: EdgeInsets.only(bottom: abajo),
                child: Row(
                  children: [
                    item(
                      Pestana.noticias,
                      Icons.article_outlined,
                      Icons.article,
                      t.noticiasTitulo,
                    ),
                    item(
                      Pestana.sos,
                      Icons.place_outlined,
                      Icons.place,
                      t.pestanaSos,
                    ),
                    // Lugar del botón del Mapa, con su nombre debajo (también
                    // se puede tocar; el lector de pantalla lo anuncia en el
                    // botón).
                    Expanded(
                      child: ExcludeSemantics(
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTap: () => onElegir(Pestana.mapa),
                          child: Align(
                            alignment: Alignment.bottomCenter,
                            child: Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: _Etiqueta(
                                texto: t.pestanaMapa,
                                elegido: actual == Pestana.mapa,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    item(
                      Pestana.mascotas,
                      Icons.pets_outlined,
                      Icons.pets,
                      t.barraMascotas,
                    ),
                    item(
                      Pestana.ayuda,
                      Icons.help_outline,
                      Icons.help,
                      t.pestanaAyuda,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: _BotonMapa(
              diametro: _diametro,
              elegido: actual == Pestana.mapa,
              onPressed: () => onElegir(Pestana.mapa),
            ),
          ),
        ],
      ),
    );
  }
}

/// Rectángulo de la barra con el hueco curvo arriba, en el medio.
class _RecorteBarra extends CustomClipper<Path> {
  const _RecorteBarra({required this.radio});

  final double radio;

  @override
  Path getClip(Size size) => const CircularNotchedRectangle().getOuterPath(
    Offset.zero & size,
    Rect.fromCircle(center: Offset(size.width / 2, 0), radius: radio),
  );

  @override
  bool shouldReclip(_RecorteBarra anterior) => anterior.radio != radio;
}

class _ItemBarra extends StatelessWidget {
  const _ItemBarra({
    required this.icono,
    required this.texto,
    required this.elegido,
    required this.onTap,
  });

  final IconData icono;
  final String texto;
  final bool elegido;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final sobre = context.marca.sobreBarra;
    return Semantics(
      button: true,
      selected: elegido,
      label: texto,
      excludeSemantics: true,
      child: InkResponse(
        onTap: onTap,
        containedInkWell: true,
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: elegido ? sobre.withValues(alpha: 0.2) : null,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(icono, color: sobre),
              ),
              const SizedBox(height: 4),
              _Etiqueta(texto: texto, elegido: elegido),
            ],
          ),
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta({required this.texto, required this.elegido});

  final String texto;
  final bool elegido;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Text(
      texto,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: tema.textTheme.labelMedium?.copyWith(
        color: context.marca.sobreBarra,
        fontWeight: elegido ? FontWeight.w700 : FontWeight.w500,
      ),
    );
  }
}

/// El botón redondo del Mapa, en el color principal de la marca.
class _BotonMapa extends StatelessWidget {
  const _BotonMapa({
    required this.diametro,
    required this.elegido,
    required this.onPressed,
  });

  final double diametro;
  final bool elegido;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: elegido,
      label: context.t.pestanaMapa,
      excludeSemantics: true,
      child: SizedBox.square(
        dimension: diametro,
        child: Material(
          shape: const CircleBorder(),
          color: colores.primary,
          elevation: elegido ? 6 : 3,
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onPressed,
            child: Icon(
              elegido ? Icons.map : Icons.map_outlined,
              size: 30,
              color: colores.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
