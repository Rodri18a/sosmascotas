import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../theme/paleta.dart';
import 'dibujo_pin.dart';
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

  /// Pines con ícono (D82): son símbolos con una imagen dibujada por la app.
  final _iconos = <Symbol>[];
  final _pinsPorIcono = <String, Pin>{};

  /// Imágenes ya registradas en el estilo del mapa (una por aspecto).
  final _imagenes = <String>{};

  /// Densidad de la pantalla, para dibujar los íconos nítidos.
  double _densidad = 1;

  /// Cada redibujo cancela al anterior si todavía no terminó.
  int _dibujo = 0;

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

  /// El número de un grupo está encima de su círculo: tocarlo es tocar el
  /// grupo. Los demás símbolos son pines con ícono.
  void _alTocarNumero(Symbol simbolo) {
    if (_gruposPorNumero[simbolo.id] case final circulo?) {
      _alTocarCirculo(circulo);
    } else if (_pinsPorIcono[simbolo.id] case final pin?) {
      widget.config.onTocarPin?.call(pin);
    }
  }

  /// Registra la imagen de [aspecto] la primera vez y devuelve su nombre.
  Future<String> _imagen(
    MapLibreMapController control,
    AspectoPin aspecto,
  ) async {
    final nombre = aspecto.clave;
    if (_imagenes.add(nombre)) {
      await control.addImage(
        nombre,
        await dibujarPin(aspecto, escala: _densidad),
      );
    }
    return nombre;
  }

  /// En Android y iPhone la imagen se toma con la densidad de la pantalla; en
  /// la web, a un píxel por punto: se achica para que mida lo mismo.
  double get _tamanioIcono => kIsWeb ? 1 / _densidad : 1;

  /// Orden de dibujo: los SOS arriba de todo, los sin reclamar abajo.
  static int _capa(Pin pin) => switch (pin.tipo) {
    TipoPin.perdido || TipoPin.encontrado => 3,
    TipoPin.evento => 2,
    TipoPin.sinReclamar => 0,
    _ => 1,
  };

  Future<void> _dibujarPins() async {
    final control = _control;
    if (control == null || !_estiloListo) return;
    final dibujo = ++_dibujo;
    // Las imágenes se preparan antes de borrar lo anterior: así el mapa no
    // queda vacío mientras se dibujan.
    final pins = widget.config.pins;
    final imagenes = <Pin, String>{};
    for (final pin in pins) {
      if (aspectoDePin(pin) case final aspecto?) {
        imagenes[pin] = await _imagen(control, aspecto);
      }
    }
    if (dibujo != _dibujo) return;
    final anteriores = control.circles
        .where((c) => c.id != _circuloSeleccion?.id)
        .toList();
    if (anteriores.isNotEmpty) await control.removeCircles(anteriores);
    final simbolos = [..._numeros, ..._iconos];
    if (simbolos.isNotEmpty) await control.removeSymbols(simbolos);
    _numeros.clear();
    _gruposPorNumero.clear();
    _iconos.clear();
    _pinsPorIcono.clear();
    _pinsPorCirculo.clear();
    final ordenados = [...pins]..sort((a, b) => _capa(a).compareTo(_capa(b)));
    for (final pin in ordenados) {
      if (imagenes[pin] case final imagen?) {
        final icono = await control.addSymbol(
          SymbolOptions(
            geometry: LatLng(pin.punto.lat, pin.punto.lng),
            iconImage: imagen,
            iconSize: _tamanioIcono,
            // La punta de la gota marca el lugar.
            iconAnchor: 'bottom',
            zIndex: _capa(pin),
          ),
        );
        _iconos.add(icono);
        _pinsPorIcono[icono.id] = pin;
        continue;
      }
      // Sin ícono solo quedan los grupos (1.2.6): círculo casi negro con el
      // número adentro.
      final circulo = await control.addCircle(
        CircleOptions(
          geometry: LatLng(pin.punto.lat, pin.punto.lng),
          circleRadius: 15,
          circleColor: _hex(colorDePin(pin.tipo)),
          circleStrokeWidth: 2,
          circleStrokeColor: '#FFFFFF',
        ),
      );
      _pinsPorCirculo[circulo.id] = pin;
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
    _densidad = MediaQuery.devicePixelRatioOf(context);
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
        // El estilo nuevo no trae las imágenes registradas antes.
        _imagenes.clear();
        // Los pines con ícono nunca se esconden por chocar entre sí o con
        // los nombres de las calles.
        final control = _control!;
        await control.setSymbolIconAllowOverlap(true);
        await control.setSymbolIconIgnorePlacement(true);
        await control.setSymbolTextAllowOverlap(true);
        await control.setSymbolTextIgnorePlacement(true);
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
