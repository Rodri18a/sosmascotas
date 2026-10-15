import 'dart:math' as math;

import 'mapa.dart';

/// Alto de la celda de la zona aproximada, en grados de latitud (~500 m).
const altoCeldaZona = 0.0045;

/// Centro de la celda de ~500 m que contiene [punto]: es lo único que sale
/// del dispositivo, nunca la ubicación exacta (D56).
///
/// Filas de [altoCeldaZona] de latitud; el ancho en longitud se ajusta según
/// la latitud de la fila para que la celda mida ~500 m también de este a
/// oeste. Misma cuenta que `public.celda_zona()` en la base.
Punto zonaAproximada(Punto punto) {
  final lat = ((punto.lat / altoCeldaZona).floor() + 0.5) * altoCeldaZona;
  final pasoLng = altoCeldaZona / math.cos(lat * math.pi / 180);
  final lng = ((punto.lng / pasoLng).floor() + 0.5) * pasoLng;
  return Punto(_seisDecimales(lat), _seisDecimales(lng));
}

double _seisDecimales(double v) => double.parse(v.toStringAsFixed(6));
