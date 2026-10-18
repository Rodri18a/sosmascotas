import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../theme/paleta.dart';
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
  final _numeros = <Symbol>[];
  final _gruposPorNumero = <String, Circle>{};
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
    _control?.onSymbolTapped.remove(_alTocarNumero);
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
    if (pin == null) return;
    // Un grupo (1.2.6) se abre acercando el mapa; los pines, con su ficha.
    if (pin.tipo == TipoPin.grupo) {
      final zoom = _control?.cameraPosition?.zoom ?? widget.config.zoom;
      unawaited(
        _control?.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(pin.punto.lat, pin.punto.lng),
            zoom + 2,
          ),
        ),
      );
      return;
    }
    widget.config.onTocarPin?.call(pin);
  }

  /// El número de un grupo está encima de su círculo: tocarlo es tocar el grupo.
  void _alTocarNumero(Symbol numero) {
    if (_gruposPorNumero[numero.id] case final circulo?) {
      _alTocarCirculo(circulo);
    }
  }

  Future<void> _dibujarPins() async {
    final control = _control;
    if (control == null || !_estiloListo) return;
    final anteriores = control.circles
        .where((c) => c.id != _circuloSeleccion?.id)
        .toList();
    if (anteriores.isNotEmpty) await control.removeCircles(anteriores);
    if (_numeros.isNotEmpty) {
      await control.removeSymbols(List.of(_numeros));
      _numeros.clear();
      _gruposPorNumero.clear();
    }
    _pinsPorCirculo.clear();
    for (final pin in widget.config.pins) {
      final grupo = pin.tipo == TipoPin.grupo;
      final circulo = await control.addCircle(
        CircleOptions(
          geometry: LatLng(pin.punto.lat, pin.punto.lng),
          circleRadius: grupo ? 15 : 9,
          circleColor: _hex(coloresPin[pin.tipo]!),
          circleStrokeWidth: 2,
          circleStrokeColor: grupo ? '#FFFFFF' : _hex(bordePin),
        ),
      );
      _pinsPorCirculo[circulo.id] = pin;
      if (grupo) {
        final numero = await control.addSymbol(
          SymbolOptions(
            geometry: LatLng(pin.punto.lat, pin.punto.lng),
            textField: '${pin.cantidad}',
            textColor: '#FFFFFF',
            textSize: 13,
          ),
        );
        _numeros.add(numero);
        _gruposPorNumero[numero.id] = circulo;
      }
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
        circleColor: _hex(Paleta.cielo.claro.primario),
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
        control.onSymbolTapped.add(_alTocarNumero);
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
