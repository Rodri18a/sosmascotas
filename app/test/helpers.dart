import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sosmascota/src/app.dart';
import 'package:sosmascota/src/config/env_provider.dart';
import 'package:sosmascota/src/config/supabase_providers.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/metricas/metricas.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';

const urlPrueba = 'https://abc.supabase.co';
const clavePrueba = 'sb_publishable_prueba';

/// La app completa con dependencias de prueba (sin red real).
Widget appDePrueba({
  AppFlavor flavor = AppFlavor.dev,
  bool conSupabase = false,
  int respuestaSalud = 200,
  bool googleHabilitado = false,
  ServicioCuenta? cuenta,
}) => ProviderScope(
  overrides: [
    servicioCuentaProvider.overrideWithValue(cuenta ?? ServicioCuentaFalso()),
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
        assert(pedido.headers['apikey'] == clavePrueba);
        return switch (pedido.url.toString()) {
          '$urlPrueba/auth/v1/health' => http.Response('{}', respuestaSalud),
          '$urlPrueba/auth/v1/settings' => http.Response(
            '{"external":{"email":true,"google":$googleHabilitado}}',
            200,
          ),
          _ => http.Response('no encontrado', 404),
        };
      }),
    ),
  ],
  child: const SosMascotaApp(),
);
