import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Envía una fila a la tabla `events`. Se reemplaza en las pruebas.
typedef EnviarEvento = Future<void> Function(Map<String, Object?> fila);

/// Registra eventos de métricas anónimas (regla 9 de CLAUDE.md).
///
/// `track()` no espera ni falla: si no hay internet o Supabase no responde,
/// el evento se pierde sin afectar a la persona que usa la app.
class Metricas {
  Metricas({
    required this.anonId,
    required this.plataforma,
    required EnviarEvento? enviar,
    String? Function()? usuarioActual,
  }) : _enviar = enviar,
       _usuarioActual = usuarioActual ?? (() => null);

  /// Métricas reales sobre Supabase. Sin cliente (dev sin configurar), no envía nada.
  factory Metricas.conSupabase(
    SupabaseClient? cliente, {
    required String anonId,
  }) => Metricas(
    anonId: anonId,
    plataforma: plataformaActual(),
    enviar: cliente == null
        ? null
        : (fila) async => cliente.from('events').insert(fila),
    usuarioActual: () => cliente?.auth.currentUser?.id,
  );

  final String anonId;
  final String plataforma;
  final EnviarEvento? _enviar;
  final String? Function() _usuarioActual;

  void track(
    String nombre, {
    Map<String, Object?> props = const {},
    String? targetId,
    String? businessId,
    int? zoneId,
  }) {
    assert(nombreDeEventoValido(nombre), 'Nombre de evento inválido: $nombre');
    final enviar = _enviar;
    if (enviar == null) return;

    final fila = <String, Object?>{
      'name': nombre,
      'anon_id': anonId,
      'user_id': _usuarioActual(),
      'platform': plataforma,
      'props': props,
      'target_id': ?targetId,
      'business_id': ?businessId,
      'zone_id': ?zoneId,
    };
    unawaited(
      enviar(fila).catchError((Object error) {
        debugPrint('No se pudo registrar el evento $nombre: $error');
      }),
    );
  }
}

const _claveAnonId = 'metricas.anon_id';

/// Devuelve el id anónimo de esta instalación (lo crea la primera vez).
Future<String> obtenerAnonId(SharedPreferences prefs) async {
  final guardado = prefs.getString(_claveAnonId);
  if (guardado != null) return guardado;
  final nuevo = generarAnonId();
  await prefs.setString(_claveAnonId, nuevo);
  return nuevo;
}

/// Plataforma con los mismos valores que acepta la base.
String plataformaActual() => kIsWeb
    ? 'web'
    : switch (defaultTargetPlatform) {
        TargetPlatform.iOS => 'ios',
        _ => 'android',
      };

/// Métricas de la app. Se define en `main()` con un override.
final metricasProvider = Provider<Metricas>(
  (ref) => throw UnimplementedError('metricasProvider se define en main()'),
);
