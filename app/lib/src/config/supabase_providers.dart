import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'env_provider.dart';

/// Inicia Supabase con la configuración del entorno.
/// Devuelve `null` si falta la configuración (solo puede pasar en desarrollo).
Future<SupabaseClient?> iniciarSupabase(
  String url,
  String publishableKey,
) async {
  if (url.isEmpty || publishableKey.isEmpty) return null;
  final supabase = await Supabase.initialize(
    url: url,
    publishableKey: publishableKey,
  );
  return supabase.client;
}

/// Cliente de Supabase para toda la app. Se define en `main()` con un override.
/// Es `null` en desarrollo mientras no esté completo `config/dev.json`.
final supabaseClientProvider = Provider<SupabaseClient?>(
  (ref) =>
      throw UnimplementedError('supabaseClientProvider se define en main()'),
);

/// Cliente HTTP (reemplazable en las pruebas).
final httpClientProvider = Provider<http.Client>((ref) {
  final client = http.Client();
  ref.onDispose(client.close);
  return client;
});

/// Estado de la conexión con Supabase.
enum EstadoConexion { sinConfigurar, conectado, sinConexion }

/// Comprueba que Supabase responda, usando el chequeo de salud del servicio de login.
final estadoConexionProvider = FutureProvider<EstadoConexion>((ref) async {
  final env = ref.watch(appEnvProvider);
  if (!env.hasSupabase) return EstadoConexion.sinConfigurar;

  final client = ref.watch(httpClientProvider);
  try {
    final respuesta = await client
        .get(
          Uri.parse('${env.supabaseUrl}/auth/v1/health'),
          headers: {'apikey': env.supabasePublishableKey},
        )
        .timeout(const Duration(seconds: 10));
    return respuesta.statusCode == 200
        ? EstadoConexion.conectado
        : EstadoConexion.sinConexion;
  } on Exception {
    return EstadoConexion.sinConexion;
  }
});
