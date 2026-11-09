import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'app.dart';
import 'config/env_provider.dart';
import 'config/supabase_providers.dart';
import 'dos_apps/dos_apps.dart';
import 'metricas/metricas.dart';
import 'router.dart';

/// Arranca Huellamy o, con [comercio], Huellamy Comercios (D129).
Future<void> arrancar({bool comercio = false}) async {
  WidgetsFlutterBinding.ensureInitialized();
  // Direcciones limpias en la web (/sos en vez de /#/sos). El hosting debe
  // devolver index.html para cualquier ruta (Cloudflare Pages lo hace solo).
  usePathUrlStrategy();
  final env = AppEnv.fromEnvironment();
  final supabase = await iniciarSupabase(
    env.supabaseUrl,
    env.supabasePublishableKey,
  );
  final anonId = await obtenerAnonId(await SharedPreferences.getInstance());
  final metricas = Metricas.conSupabase(supabase, anonId: anonId)
    ..track(Eventos.appOpen, props: {if (comercio) 'app': 'comercios'});
  runApp(
    ProviderScope(
      overrides: [
        appEnvProvider.overrideWithValue(env),
        supabaseClientProvider.overrideWithValue(supabase),
        metricasProvider.overrideWithValue(metricas),
        if (comercio) ...[
          esAppComercioProvider.overrideWithValue(true),
          rutaInicialProvider.overrideWithValue(Rutas.negocio),
        ],
      ],
      child: const SosMascotaApp(),
    ),
  );
}
