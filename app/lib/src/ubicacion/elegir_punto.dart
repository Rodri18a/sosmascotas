import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../l10n/l10n.dart';
import '../mapa/mapa_vista.dart';
import '../metricas/metricas.dart';
import '../sos/sos_repositorio.dart';
import 'mi_posicion.dart';

/// Mapa chico para marcar un punto en un formulario (D145). Con
/// [marcarAlAbrir], si todavía no hay punto, lo deja marcado donde está la
/// persona (lo que se informa suele pasar ahí mismo); tocando el mapa se
/// cambia. Siempre ofrece «📍 Donde estoy». Sin permiso o sin GPS, queda como
/// antes: el mapa en la zona y se toca a mano. La posición exacta queda en el
/// aparato: cada formulario decide qué publica (un SOS, la zona corrida).
class ElegirPunto extends ConsumerStatefulWidget {
  const ElegirPunto({
    required this.pantalla,
    required this.seleccion,
    required this.onCambio,
    this.marcarAlAbrir = false,
    this.zoom = 15,
    this.alto = 260,
    super.key,
  });

  /// Para las métricas: `sos`, `marcar_lugar`, `evento`, `denuncia`, `negocio`.
  final String pantalla;
  final Punto? seleccion;
  final ValueChanged<Punto> onCambio;
  final bool marcarAlAbrir;
  final double zoom;
  final double alto;

  @override
  ConsumerState<ElegirPunto> createState() => _ElegirPuntoState();
}

enum _Estado { aMano, buscando, dondeEstas, sinPosicion }

class _ElegirPuntoState extends ConsumerState<ElegirPunto> {
  /// Se mueve solo con el GPS: tocar el mapa no lo recentra.
  late Punto _centro = widget.seleccion ?? ref.read(miZonaProvider);
  int _vueltas = 0;
  _Estado _estado = _Estado.aMano;

  /// Para medir una sola vez si se cambió el punto que puso el GPS.
  bool _cambioMedido = false;

  @override
  void initState() {
    super.initState();
    if (widget.marcarAlAbrir && widget.seleccion == null) {
      unawaited(_irADondeEstoy(alAbrir: true));
    }
  }

  Future<void> _irADondeEstoy({bool alAbrir = false}) async {
    setState(() => _estado = _Estado.buscando);
    final p = await ref.read(posicionActualProvider)();
    if (!mounted) return;
    final metricas = ref.read(metricasProvider);
    if (p == null) {
      setState(() => _estado = _Estado.sinPosicion);
      metricas.track(
        Eventos.locationMe,
        props: {'pantalla': widget.pantalla, 'resultado': 'sin_posicion'},
      );
      return;
    }
    // Si mientras esperaba el GPS la persona ya tocó el mapa, manda lo suyo.
    if (alAbrir && widget.seleccion != null) {
      setState(() => _estado = _Estado.aMano);
      return;
    }
    final punto = Punto(p.lat, p.lng);
    setState(() {
      _centro = punto;
      _vueltas++;
      _estado = _Estado.dondeEstas;
      _cambioMedido = false;
    });
    widget.onCambio(punto);
    metricas.track(
      alAbrir ? Eventos.locationPrefill : Eventos.locationMe,
      props: {'pantalla': widget.pantalla, 'resultado': 'gps'},
    );
  }

  void _alTocar(Punto punto) {
    if (_estado == _Estado.dondeEstas && !_cambioMedido) {
      _cambioMedido = true;
      ref
          .read(metricasProvider)
          .track(Eventos.locationChanged, props: {'pantalla': widget.pantalla});
    }
    setState(() => _estado = _Estado.aMano);
    widget.onCambio(punto);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final chico = Theme.of(context).textTheme.bodySmall;
    final aviso = switch (_estado) {
      _Estado.buscando => t.ubicacionBuscando,
      _Estado.dondeEstas => t.ubicacionMarcadaDondeEstas,
      _Estado.sinPosicion => t.ubicacionSinPosicion,
      _Estado.aMano => widget.seleccion != null ? t.sosUbicacionMarcada : null,
    };
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: widget.alto,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: MapaVista(
              centro: _centro,
              vueltaAlCentro: _vueltas,
              zoom: widget.zoom,
              seleccion: widget.seleccion,
              onTocarMapa: _alTocar,
            ),
          ),
        ),
        Row(
          children: [
            Expanded(
              child: aviso == null
                  ? const SizedBox()
                  : Text(aviso, style: chico),
            ),
            TextButton.icon(
              onPressed: _estado == _Estado.buscando ? null : _irADondeEstoy,
              icon: const Icon(Icons.my_location_outlined),
              label: Text(t.ubicacionDondeEstoy),
            ),
          ],
        ),
      ],
    );
  }
}
