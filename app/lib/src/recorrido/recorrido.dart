import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../l10n/l10n.dart';
import '../metricas/metricas.dart';

/// Pantallas con recorrido guiado (onboarding, plan de mejoras 1.3, D130).
enum PantallaRecorrido { inicio, sos, mapa, mascotas, urgencias, negocio }

/// Un paso del recorrido: ilumina la parte marcada con [marca] (o, sin marca,
/// va al centro de la pantalla) y la explica en una línea.
class PasoRecorrido {
  const PasoRecorrido({required this.titulo, required this.texto, this.marca});

  final String? marca;
  final String titulo;
  final String texto;
}

/// Qué recorridos ya se vieron en este dispositivo (cada uno sale solo una vez).
abstract interface class AlmacenRecorridos {
  Future<bool> visto(PantallaRecorrido pantalla);
  Future<void> marcarVisto(PantallaRecorrido pantalla);
}

class AlmacenRecorridosLocal implements AlmacenRecorridos {
  const AlmacenRecorridosLocal();

  String _clave(PantallaRecorrido p) => 'recorrido.${p.name}';

  @override
  Future<bool> visto(PantallaRecorrido pantalla) async =>
      (await SharedPreferences.getInstance()).getBool(_clave(pantalla)) ??
      false;

  @override
  Future<void> marcarVisto(PantallaRecorrido pantalla) async =>
      (await SharedPreferences.getInstance()).setBool(_clave(pantalla), true);
}

final almacenRecorridosProvider = Provider<AlmacenRecorridos>(
  (ref) => const AlmacenRecorridosLocal(),
);

/// Envuelve una pantalla: junta sus [MarcaRecorrido] y, la primera vez que se
/// abre, muestra su recorrido. Sin [pantalla] solo junta marcas (la barra de
/// abajo, que comparten todas las pestañas).
class ZonaRecorrido extends ConsumerStatefulWidget {
  const ZonaRecorrido({
    required this.child,
    this.pantalla,
    this.pasos,
    super.key,
  });

  final PantallaRecorrido? pantalla;
  final List<PasoRecorrido> Function(BuildContext context)? pasos;
  final Widget child;

  static ZonaRecorridoState? de(BuildContext context) =>
      context.findAncestorStateOfType<ZonaRecorridoState>();

  @override
  ConsumerState<ZonaRecorrido> createState() => ZonaRecorridoState();
}

class ZonaRecorridoState extends ConsumerState<ZonaRecorrido> {
  final _marcas = <String, BuildContext>{};

  void _anotar(String id, BuildContext marca) => _marcas[id] = marca;

  void _borrar(String id, BuildContext marca) {
    if (_marcas[id] == marca) _marcas.remove(id);
  }

  /// La parte marcada con [id], acá o en una zona de más afuera.
  BuildContext? _marca(String id) =>
      _marcas[id] ?? ZonaRecorrido.de(context)?._marca(id);

  /// Dónde está en la pantalla; `null` si no se ve (oculta o fuera de ella).
  Rect? _lugar(String id, Size pantalla) {
    final caja = _marca(id)?.findRenderObject();
    if (caja is! RenderBox || !caja.attached || !caja.hasSize) return null;
    if (caja.size.isEmpty) return null;
    final lugar = caja.localToGlobal(Offset.zero) & caja.size;
    final visible = lugar.intersect(Offset.zero & pantalla);
    return visible.width < 8 || visible.height < 8 ? null : visible;
  }

  @override
  void initState() {
    super.initState();
    if (widget.pantalla != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_primeraVez());
      });
    }
  }

  Future<void> _primeraVez() async {
    final almacen = ref.read(almacenRecorridosProvider);
    final pantalla = widget.pantalla!;
    try {
      if (await almacen.visto(pantalla)) return;
    } on Exception catch (e) {
      debugPrint('No se pudo leer el recorrido visto: $e');
      return;
    }
    // Que la pantalla termine de cargar antes de iluminar sus partes.
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted || !_estaALaVista()) return;
    try {
      await almacen.marcarVisto(pantalla);
    } on Exception catch (e) {
      debugPrint('No se pudo guardar el recorrido visto: $e');
    }
    if (mounted) await mostrar(automatico: true);
  }

  /// Solo arranca solo si la pantalla es la que se está mirando.
  bool _estaALaVista() =>
      TickerMode.valuesOf(context).enabled &&
      (ModalRoute.of(context)?.isCurrent ?? true);

  /// Muestra el recorrido (solo, la primera vez, o desde el botón ?).
  Future<void> mostrar({bool automatico = false}) async {
    final pantalla = widget.pantalla;
    final armar = widget.pasos;
    if (pantalla == null || armar == null) return;
    final tamano = MediaQuery.sizeOf(context);
    final pasos = [
      for (final p in armar(context))
        if (p.marca == null)
          (p, null)
        else if (_lugar(p.marca!, tamano) case final lugar?)
          (p, lugar),
    ];
    if (pasos.isEmpty) return;
    ref
        .read(metricasProvider)
        .track(
          Eventos.tourStart,
          props: {'screen': pantalla.name, 'auto': automatico},
        );
    final sinMovimiento = MediaQuery.disableAnimationsOf(context);
    await Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder<void>(
        opaque: false,
        transitionDuration: sinMovimiento
            ? Duration.zero
            : const Duration(milliseconds: 200),
        reverseTransitionDuration: sinMovimiento
            ? Duration.zero
            : const Duration(milliseconds: 150),
        pageBuilder: (_, _, _) => _Recorrido(pantalla: pantalla, pasos: pasos),
        transitionsBuilder: (_, animacion, _, hijo) =>
            FadeTransition(opacity: animacion, child: hijo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// Marca una parte de la pantalla para que el recorrido la ilumine.
class MarcaRecorrido extends StatefulWidget {
  const MarcaRecorrido(this.id, {required this.child, super.key});

  final String id;
  final Widget child;

  @override
  State<MarcaRecorrido> createState() => _MarcaRecorridoState();
}

class _MarcaRecorridoState extends State<MarcaRecorrido> {
  ZonaRecorridoState? _zona;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _zona?._borrar(widget.id, context);
    _zona = ZonaRecorrido.de(context)?.._anotar(widget.id, context);
  }

  @override
  void dispose() {
    _zona?._borrar(widget.id, context);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _Recorrido extends ConsumerStatefulWidget {
  const _Recorrido({required this.pantalla, required this.pasos});

  final PantallaRecorrido pantalla;
  final List<(PasoRecorrido, Rect?)> pasos;

  @override
  ConsumerState<_Recorrido> createState() => _RecorridoState();
}

class _RecorridoState extends ConsumerState<_Recorrido> {
  var _actual = 0;
  var _termino = false;
  // En dispose ya no se puede usar ref.
  late final Metricas _metricas;

  @override
  void initState() {
    super.initState();
    _metricas = ref.read(metricasProvider);
  }

  bool get _ultimo => _actual == widget.pasos.length - 1;

  void _siguiente() {
    if (_ultimo) {
      _termino = true;
      _metricas.track(
        Eventos.tourFinish,
        props: {'screen': widget.pantalla.name},
      );
      Navigator.pop(context);
    } else {
      setState(() => _actual++);
    }
  }

  @override
  void dispose() {
    // Saltar, la flecha de volver del sistema o cerrar: se anota en qué paso.
    if (!_termino) {
      _metricas.track(
        Eventos.tourSkip,
        props: {'screen': widget.pantalla.name, 'step': _actual + 1},
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final (paso, lugar) = widget.pasos[_actual];
    final hueco = lugar?.inflate(6);
    final alto = MediaQuery.sizeOf(context).height;
    final arriba = hueco != null && hueco.center.dy > alto / 2;

    final globo = ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Card(
        margin: EdgeInsets.zero,
        elevation: 6,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 12, 8),
          child: Semantics(
            liveRegion: true,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  paso.titulo,
                  style: tema.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Text(paso.texto, style: tema.textTheme.bodyMedium),
                ),
                const SizedBox(height: 8),
                Semantics(
                  label: t.recorridoPaso(_actual + 1, widget.pasos.length),
                  child: ExcludeSemantics(
                    child: Row(
                      children: [
                        for (var i = 0; i < widget.pasos.length; i++)
                          Container(
                            width: i == _actual ? 16 : 6,
                            height: 6,
                            margin: const EdgeInsets.only(right: 4),
                            decoration: BoxDecoration(
                              color: i == _actual
                                  ? tema.colorScheme.primary
                                  : tema.colorScheme.outlineVariant,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    if (!_ultimo)
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: Text(t.recorridoSaltar),
                      ),
                    // Con letra grande, los botones bajan de renglón.
                    Expanded(
                      child: OverflowBar(
                        alignment: MainAxisAlignment.end,
                        overflowAlignment: OverflowBarAlignment.end,
                        spacing: 4,
                        children: [
                          if (_actual > 0)
                            TextButton(
                              onPressed: () => setState(() => _actual--),
                              child: Text(t.recorridoAtras),
                            ),
                          FilledButton(
                            onPressed: _siguiente,
                            child: Text(
                              _ultimo ? t.recorridoListo : t.recorridoSiguiente,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );

    return Stack(
      children: [
        // Tocar fuera del globo pasa al siguiente.
        Positioned.fill(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _siguiente,
            child: CustomPaint(painter: _Sombra(hueco: hueco)),
          ),
        ),
        Positioned(
          left: 16,
          right: 16,
          top: hueco == null ? 0 : (arriba ? null : hueco.bottom + 12),
          bottom: hueco == null ? 0 : (arriba ? alto - hueco.top + 12 : null),
          child: SafeArea(
            top: arriba || hueco == null,
            bottom: !arriba,
            child: Align(
              alignment: hueco == null
                  ? Alignment.center
                  : (arriba ? Alignment.bottomCenter : Alignment.topCenter),
              child: globo,
            ),
          ),
        ),
      ],
    );
  }
}

/// Oscurece la pantalla salvo [hueco], que queda iluminado y con un borde.
class _Sombra extends CustomPainter {
  const _Sombra({required this.hueco});

  final Rect? hueco;

  @override
  void paint(Canvas canvas, Size size) {
    final fondo = Path()..addRect(Offset.zero & size);
    final hueco = this.hueco;
    if (hueco == null) {
      canvas.drawPath(fondo, Paint()..color = const Color(0x99000000));
      return;
    }
    final redondeado = RRect.fromRectAndRadius(
      hueco,
      const Radius.circular(14),
    );
    canvas
      ..drawPath(
        Path.combine(
          PathOperation.difference,
          fondo,
          Path()..addRRect(redondeado),
        ),
        Paint()..color = const Color(0x99000000),
      )
      ..drawRRect(
        redondeado,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = const Color(0xFFFFFFFF),
      );
  }

  @override
  bool shouldRepaint(_Sombra anterior) => anterior.hueco != hueco;
}
