import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

typedef Posicion = ({double lat, double lng});

/// Ubicación exacta de este momento. Pide el permiso si hace falta. Se usa
/// cuando la persona lo decide: mandarla por el chat (D73), el botón
/// «📍 Donde estoy» y el punto ya marcado al informar algo (D145). Nunca sale
/// del aparato salvo en el chat; un SOS publica la zona corrida. Se reemplaza
/// en las pruebas.
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
      return _leer();
    } on Object {
      return null;
    }
  },
);

/// Igual que [posicionActualProvider], pero sin preguntar: si el permiso no
/// está dado, devuelve `null`. Para centrar el Mapa al abrirlo (D145).
final posicionSinPreguntarProvider = Provider<Future<Posicion?> Function()>(
  (ref) => () async {
    try {
      final permiso = await Geolocator.checkPermission();
      if (permiso != LocationPermission.whileInUse &&
          permiso != LocationPermission.always) {
        return null;
      }
      return _leer();
    } on Object {
      return null;
    }
  },
);

Future<Posicion> _leer() async {
  final p = await Geolocator.getCurrentPosition(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      timeLimit: Duration(seconds: 20),
    ),
  );
  return (lat: p.latitude, lng: p.longitude);
}
