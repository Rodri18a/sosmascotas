import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/perfil_repositorio.dart';
import '../cuenta/servicio_cuenta.dart';

/// Permiso de ubicación en este dispositivo.
enum EstadoUbicacion {
  /// Sin Supabase (desarrollo) o en las pruebas: no se muestra nada.
  sinConfigurar,

  /// El navegador o el dispositivo no da la ubicación.
  noDisponible,

  sinPedir,
  permitida,

  /// El permiso se negó: hay que habilitarlo desde el navegador.
  bloqueada,
}

/// Zona aproximada de la persona para los avisos de SOS cercanos. Del
/// dispositivo solo sale la celda de la grilla ([zonaAproximada]), nunca la
/// ubicación exacta. Se reemplaza en las pruebas.
abstract interface class ServicioUbicacion {
  Future<EstadoUbicacion> estado();

  /// Pide el permiso (si hace falta) y guarda la zona.
  Future<EstadoUbicacion> activar();

  /// Al abrir la app: si el permiso ya está dado, actualiza la zona sin
  /// preguntar nada. No hace nada si la persona borró su zona. Devuelve si
  /// guardó.
  Future<bool> renovar();

  /// Borra la zona guardada: dejan de llegar avisos por cercanía.
  Future<void> borrar();
}

class UbicacionGeolocator implements ServicioUbicacion {
  UbicacionGeolocator(this._cliente);

  final SupabaseClient _cliente;

  // Por cuenta: en un celular compartido cada una decide lo suyo.
  String get _claveBorrada =>
      'ubicacion.borrada.${_cliente.auth.currentUser?.id}';
  String get _claveUltima =>
      'ubicacion.ultima.${_cliente.auth.currentUser?.id}';

  @override
  Future<EstadoUbicacion> estado() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        return EstadoUbicacion.noDisponible;
      }
      return switch (await Geolocator.checkPermission()) {
        LocationPermission.denied => EstadoUbicacion.sinPedir,
        LocationPermission.deniedForever => EstadoUbicacion.bloqueada,
        LocationPermission.unableToDetermine => EstadoUbicacion.sinPedir,
        LocationPermission.whileInUse ||
        LocationPermission.always => EstadoUbicacion.permitida,
      };
    } on Exception catch (e) {
      debugPrint('[ubicacion] No se pudo leer el permiso: $e');
      return EstadoUbicacion.noDisponible;
    }
  }

  @override
  Future<EstadoUbicacion> activar() async {
    var permiso = await estado();
    if (permiso == EstadoUbicacion.sinPedir) {
      permiso = switch (await Geolocator.requestPermission()) {
        LocationPermission.whileInUse ||
        LocationPermission.always => EstadoUbicacion.permitida,
        LocationPermission.deniedForever => EstadoUbicacion.bloqueada,
        // En la web, cerrar el cartel o negar se ven igual.
        _ => await estado(),
      };
    }
    if (permiso != EstadoUbicacion.permitida) return permiso;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveBorrada);
    await _guardar(prefs);
    return permiso;
  }

  @override
  Future<bool> renovar() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_claveBorrada) ?? false) return false;
    if (await estado() != EstadoUbicacion.permitida) return false;
    // Como mucho una vez por hora.
    final ultima = prefs.getInt(_claveUltima) ?? 0;
    final ahora = DateTime.now().millisecondsSinceEpoch;
    if (ahora - ultima < const Duration(hours: 1).inMilliseconds) return false;
    await _guardar(prefs);
    return true;
  }

  Future<void> _guardar(SharedPreferences prefs) async {
    if (_cliente.auth.currentUser == null) {
      throw StateError('Hace falta una sesión para guardar la zona');
    }
    final posicion = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        // Baja precisión alcanza (se redondea a ~500 m) y gasta menos batería.
        accuracy: LocationAccuracy.low,
        timeLimit: Duration(seconds: 20),
      ),
    );
    final zona = zonaAproximada(Punto(posicion.latitude, posicion.longitude));
    await _cliente.rpc<void>(
      'guardar_zona_aproximada',
      params: {'p_lat': zona.lat, 'p_lng': zona.lng, 'p_origen': 'gps'},
    );
    await prefs.setInt(_claveUltima, DateTime.now().millisecondsSinceEpoch);
  }

  @override
  Future<void> borrar() async {
    await _cliente.rpc<void>('borrar_zona_aproximada');
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_claveBorrada, true);
    await prefs.remove(_claveUltima);
  }
}

/// Sin Supabase configurado (o en las pruebas): no se guarda ninguna zona.
class UbicacionSinConfigurar implements ServicioUbicacion {
  const UbicacionSinConfigurar();

  @override
  Future<EstadoUbicacion> estado() async => EstadoUbicacion.sinConfigurar;

  @override
  Future<EstadoUbicacion> activar() async => EstadoUbicacion.sinConfigurar;

  @override
  Future<bool> renovar() async => false;

  @override
  Future<void> borrar() async {}
}

final servicioUbicacionProvider = Provider<ServicioUbicacion>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const UbicacionSinConfigurar()
      : UbicacionGeolocator(cliente);
});

final estadoUbicacionProvider = FutureProvider<EstadoUbicacion>(
  (ref) => ref.watch(servicioUbicacionProvider).estado(),
);

/// Al abrir la app o iniciar sesión, actualiza la zona si el permiso ya está
/// dado. Se mantiene vivo desde la raíz de la app.
final renovarUbicacionProvider = Provider<void>((ref) {
  ref.listen(usuarioActualProvider, (_, usuario) {
    if (usuario.value == null) return;
    unawaited(
      ref
          .read(servicioUbicacionProvider)
          .renovar()
          .then((guardo) {
            if (guardo) ref.invalidate(perfilProvider);
          })
          .catchError((Object e) {
            debugPrint('[ubicacion] No se pudo renovar la zona: $e');
          }),
    );
  }, fireImmediately: true);
});
