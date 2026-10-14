import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sosmascota/src/app.dart';
import 'package:sosmascota/src/config/env_provider.dart';
import 'package:sosmascota/src/config/supabase_providers.dart';
import 'package:sosmascota/src/metricas/metricas.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

const urlPrueba = 'https://abc.supabase.co';
const clavePrueba = 'sb_publishable_prueba';

/// La app completa con dependencias de prueba (sin red real).
Widget appDePrueba({
  AppFlavor flavor = AppFlavor.dev,
  bool conSupabase = false,
  int respuestaSalud = 200,
}) => ProviderScope(
  overrides: [
    appEnvProvider.overrideWithValue(
      AppEnv(
        flavor: flavor,
        supabaseUrl: conSupabase ? urlPrueba : '',
        supabasePublishableKey: conSupabase ? clavePrueba : '',
      ),
    ),
    supabaseClientProvider.overrideWithValue(null),
    metricasProvider.overrideWithValue(
      Metricas(anonId: 'anon-prueba', plataforma: 'web', enviar: null),
    ),
    httpClientProvider.overrideWithValue(
      MockClient((pedido) async {
        assert(pedido.url.toString() == '$urlPrueba/auth/v1/health');
        assert(pedido.headers['apikey'] == clavePrueba);
        return http.Response('{}', respuestaSalud);
      }),
    ),
  ],
  child: const SosMascotaApp(),
);
