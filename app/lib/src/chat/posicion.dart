import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

typedef Posicion = ({double lat, double lng});

/// Ubicación exacta de este momento, solo cuando la persona decide mandarla
/// por el chat (D73). Pide el permiso si hace falta. Se reemplaza en las
/// pruebas.
final posicionActualProvider = Provider<Future<Posicion?> Function()>(
  (ref) => () async {
    try {
      var permiso = await Geolocator.checkPermission();
      if (permiso == LocationPermission.denied) {
        permiso = await Geolocator.requestPermission();
      }
      if (permiso == LocationPermission.denied ||
          permiso == LocationPermission.deniedForever) {
        return null;
      }
      final p = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return (lat: p.latitude, lng: p.longitude);
    } on Object {
      return null;
    }
  },
);
