import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/app.dart';
import 'src/repositorio.dart';
import 'src/sesion.dart';

/// Portal de administración (etapa 1.8, D76). Usa la misma base y las mismas
/// cuentas que la app; el permiso lo decide la base (rol `admin`).
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final env = AppEnv.fromEnvironment();
  await Supabase.initialize(
    url: env.supabaseUrl,
    publishableKey: env.supabasePublishableKey,
  );
  final cliente = Supabase.instance.client;
  runApp(
    ProviderScope(
      overrides: [
        adminRepositorioProvider.overrideWithValue(
          SupabaseAdminRepositorio(cliente),
        ),
        sesionProvider.overrideWithValue(SupabaseSesionAdmin(cliente.auth)),
      ],
      child: const AdminApp(),
    ),
  );
}
