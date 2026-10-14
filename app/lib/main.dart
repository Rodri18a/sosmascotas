import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'src/app.dart';
import 'src/config/env_provider.dart';
import 'src/config/supabase_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Direcciones limpias en la web (/sos en vez de /#/sos). El hosting debe
  // devolver index.html para cualquier ruta (Cloudflare Pages lo hace solo).
  usePathUrlStrategy();
  final env = AppEnv.fromEnvironment();
  final supabase = await iniciarSupabase(
    env.supabaseUrl,
    env.supabasePublishableKey,
  );
  runApp(
    ProviderScope(
      overrides: [
        appEnvProvider.overrideWithValue(env),
        supabaseClientProvider.overrideWithValue(supabase),
      ],
      child: const SosMascotaApp(),
    ),
  );
}
