import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_provider.dart';
import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';
import '../dos_apps/dos_apps.dart';
import '../metricas/metricas.dart';

/// Estado de los avisos push en este dispositivo.
enum EstadoPush {
  /// Sin Firebase configurado (desarrollo): no se muestra nada de push.
  sinConfigurar,

  /// Navegador sin soporte, o iPhone sin instalar la app en la pantalla de
  /// inicio.
  noDisponible,

  /// Todavía no se pidió el permiso.
  sinPedir,

  activado,

  /// El permiso se negó: hay que habilitarlo desde el navegador.
  bloqueado,

  /// La persona los apagó desde la app (el permiso sigue dado).
  apagado,
}

/// Avisos push (Firebase Cloud Messaging). Se reemplaza en las pruebas.
abstract interface class ServicioPush {
  Future<EstadoPush> estado();

  /// Pide el permiso (si hace falta) y guarda el token de este dispositivo.
  Future<EstadoPush> activar();

  /// Deja de recibir avisos en este dispositivo.
  Future<void> apagar();

  /// Si los avisos están activados, vuelve a guardar el token (al abrir la
  /// app o al iniciar sesión; el token puede cambiar).
  Future<void> renovar();

  /// Antes de cerrar sesión: este dispositivo deja de recibir los avisos de
  /// la cuenta.
  Future<void> olvidarDispositivo();
}

class FirebasePush implements ServicioPush {
  FirebasePush(this._cliente, this._config, {this.comercio = false});

  final SupabaseClient _cliente;

  /// Huellamy Comercios: sus dispositivos reciben los avisos del negocio y
  /// los de Huellamy, el resto (D156).
  final bool comercio;
  final ConfigFirebase _config;

  static const _claveApagado = 'push.apagado';
  static const _claveToken = 'push.token';

  Future<FirebaseMessaging?>? _iniciando;
  StreamSubscription<String>? _renovacion;

  /// Inicia Firebase una sola vez. `null` si este navegador no admite push.
  Future<FirebaseMessaging?> _mensajeria() => _iniciando ??= () async {
    // En la Fase 0 solo la PWA; Android y iPhone nativos llegan en la Fase 1.
    if (!kIsWeb) return null;
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: _config.apiKey,
        appId: _config.appId,
        messagingSenderId: _config.messagingSenderId,
        projectId: _config.projectId,
      ),
    );
    final mensajeria = FirebaseMessaging.instance;
    if (!await mensajeria.isSupported()) return null;
    _renovacion = mensajeria.onTokenRefresh.listen(_guardar);
    return mensajeria;
  }();

  Future<void> _guardar(String token) async {
    if (_cliente.auth.currentUser == null) {
      throw StateError('Hace falta una sesión para guardar el token');
    }
    await _cliente.rpc<void>(
      'guardar_push_token',
      params: {
        'p_token': token,
        'p_platform': plataformaActual(),
        'p_app': comercio ? 'comercios' : 'personas',
      },
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_claveToken, token);
  }

  @override
  Future<EstadoPush> estado() async {
    final mensajeria = await _mensajeria();
    if (mensajeria == null) return EstadoPush.noDisponible;
    final prefs = await SharedPreferences.getInstance();
    final permiso = await mensajeria.getNotificationSettings();
    return switch (permiso.authorizationStatus) {
      AuthorizationStatus.denied => EstadoPush.bloqueado,
      AuthorizationStatus.notDetermined => EstadoPush.sinPedir,
      _ when prefs.getBool(_claveApagado) ?? false => EstadoPush.apagado,
      // Permiso dado pero sin token guardado (falló antes): hay que reintentar.
      _ when prefs.getString(_claveToken) == null => EstadoPush.sinPedir,
      _ => EstadoPush.activado,
    };
  }

  @override
  Future<EstadoPush> activar() async {
    final mensajeria = await _mensajeria();
    if (mensajeria == null) return EstadoPush.noDisponible;
    final permiso = await mensajeria.requestPermission();
    debugPrint('[push] permiso: ${permiso.authorizationStatus.name}');
    if (permiso.authorizationStatus == AuthorizationStatus.denied) {
      return EstadoPush.bloqueado;
    }
    if (permiso.authorizationStatus == AuthorizationStatus.notDetermined) {
      return EstadoPush.sinPedir; // Cerró el cartel sin elegir.
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_claveApagado);
    final token = await mensajeria.getToken(vapidKey: _config.vapidKey);
    // Sin token guardado no llega ningún aviso: no decir "¡Listo!".
    if (token == null) throw StateError('Firebase no devolvió un token');
    debugPrint('[push] token obtenido (${token.length} caracteres)');
    await _guardar(token);
    debugPrint('[push] token guardado');
    return EstadoPush.activado;
  }

  @override
  Future<void> apagar() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_claveApagado, true);
    await olvidarDispositivo();
    await (await _mensajeria())?.deleteToken();
    await prefs.remove(_claveToken);
  }

  @override
  Future<void> renovar() async {
    if (await estado() != EstadoPush.activado) return;
    final token = await (await _mensajeria())?.getToken(
      vapidKey: _config.vapidKey,
    );
    if (token != null) await _guardar(token);
  }

  @override
  Future<void> olvidarDispositivo() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(_claveToken);
    if (token == null || _cliente.auth.currentUser == null) return;
    await _cliente.from('push_tokens').delete().eq('token', token);
  }

  void cerrar() => unawaited(_renovacion?.cancel());
}

/// Sin Firebase configurado (o en las pruebas): no hay avisos push.
class PushNoDisponible implements ServicioPush {
  const PushNoDisponible();

  @override
  Future<EstadoPush> estado() async => EstadoPush.sinConfigurar;

  @override
  Future<EstadoPush> activar() async => EstadoPush.sinConfigurar;

  @override
  Future<void> apagar() async {}

  @override
  Future<void> renovar() async {}

  @override
  Future<void> olvidarDispositivo() async {}
}

final servicioPushProvider = Provider<ServicioPush>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  final config = ref.watch(appEnvProvider).firebase;
  if (cliente == null || config == null) return const PushNoDisponible();
  final servicio = FirebasePush(
    cliente,
    config,
    comercio: ref.watch(esAppComercioProvider),
  );
  ref.onDispose(servicio.cerrar);
  return servicio;
});

final estadoPushProvider = FutureProvider<EstadoPush>(
  (ref) => ref.watch(servicioPushProvider).estado(),
);

/// Al abrir la app o iniciar sesión, renueva el token si los avisos están
/// activados. Se mantiene vivo desde la raíz de la app.
final renovarPushProvider = Provider<void>((ref) {
  ref.listen(usuarioActualProvider, (_, usuario) {
    if (usuario.value == null) return;
    unawaited(
      ref.read(servicioPushProvider).renovar().catchError((Object e) {
        debugPrint('No se pudo renovar el token de push: $e');
      }),
    );
  }, fireImmediately: true);
});
