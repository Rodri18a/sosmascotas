import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'mapa_vista.dart';

/// Estilo de OpenFreeMap (gratis, sin cuenta ni clave, basado en OpenStreetMap).
/// Decisión P6 / D54. Si hiciera falta cambiarlo, es solo esta línea.
const estiloMapa = 'https://tiles.openfreemap.org/styles/liberty';

String _hex(Color c) =>
    '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

class MapaMapLibre extends StatefulWidget {
  const MapaMapLibre({required this.config, super.key});

  final MapaVista config;

  @override
  State<MapaMapLibre> createState() => _MapaMapLibreState();
}

class _MapaMapLibreState extends State<MapaMapLibre> {
  MapLibreMapController? _control;
  bool _estiloListo = false;
  final _pinsPorCirculo = <String, Pin>{};
  Circle? _circuloSeleccion;

  @override
  void didUpdateWidget(MapaMapLibre anterior) {
    super.didUpdateWidget(anterior);
    if (!_mismosPins(anterior.config.pins, widget.config.pins)) {
      unawaited(_dibujarPins());
    }
    if (anterior.config.seleccion != widget.config.seleccion) {
      unawaited(_dibujarSeleccion());
    }
  }

  @override
  void dispose() {
    _control?.onCircleTapped.remove(_alTocarCirculo);
    super.dispose();
  }

  static bool _mismosPins(List<Pin> a, List<Pin> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _alTocarCirculo(Circle circulo) {
    final pin = _pinsPorCirculo[circulo.id];
    if (pin != null) widget.config.onTocarPin?.call(pin);
  }

  Future<void> _dibujarPins() async {
    final control = _control;
    if (control == null || !_estiloListo) return;
    final anteriores = control.circles
        .where((c) => c.id != _circuloSeleccion?.id)
        .toList();
    if (anteriores.isNotEmpty) await control.removeCircles(anteriores);
    _pinsPorCirculo.clear();
    for (final pin in widget.config.pins) {
      final circulo = await control.addCircle(
        CircleOptions(
          geometry: LatLng(pin.punto.lat, pin.punto.lng),
          circleRadius: 9,
          circleColor: _hex(coloresPin[pin.tipo]!),
          circleStrokeWidth: 2,
          circleStrokeColor: '#FFFFFF',
        ),
      );
      _pinsPorCirculo[circulo.id] = pin;
    }
  }

  Future<void> _dibujarSeleccion() async {
    final control = _control;
    if (control == null || !_estiloListo) return;
    if (_circuloSeleccion case final anterior?) {
      await control.removeCircle(anterior);
      _circuloSeleccion = null;
    }
    final punto = widget.config.seleccion;
    if (punto == null) return;
    _circuloSeleccion = await control.addCircle(
      CircleOptions(
        geometry: LatLng(punto.lat, punto.lng),
        circleRadius: 12,
        circleColor: '#1F8A5B',
        circleOpacity: 0.85,
        circleStrokeWidth: 3,
        circleStrokeColor: '#FFFFFF',
      ),
    );
  }

  Future<void> _avisarZonaVisible() async {
    final control = _control;
    final callback = widget.config.onCamaraQuieta;
    if (control == null || callback == null) return;
    final region = await control.getVisibleRegion();
    callback(
      Limites(
        minLat: region.southwest.latitude,
        minLng: region.southwest.longitude,
        maxLat: region.northeast.latitude,
        maxLng: region.northeast.longitude,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.config;
    return MapLibreMap(
      styleString: estiloMapa,
      initialCameraPosition: CameraPosition(
        target: LatLng(c.centro.lat, c.centro.lng),
        zoom: c.zoom,
      ),
      compassEnabled: false,
      tiltGesturesEnabled: false,
      rotateGesturesEnabled: false,
      attributionButtonPosition: AttributionButtonPosition.bottomLeft,
      onMapCreated: (control) {
        _control = control;
        control.onCircleTapped.add(_alTocarCirculo);
      },
      onStyleLoadedCallback: () async {
        _estiloListo = true;
        await _dibujarPins();
        await _dibujarSeleccion();
        await _avisarZonaVisible();
      },
      onCameraIdle: _avisarZonaVisible,
      onMapClick: (_, latLng) =>
          c.onTocarMapa?.call(Punto(latLng.latitude, latLng.longitude)),
    );
  }
}
