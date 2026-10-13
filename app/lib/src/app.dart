import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'config/env_provider.dart';
import 'router.dart';

class SosMascotaApp extends ConsumerWidget {
  const SosMascotaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(appEnvProvider);
    final router = ref.watch(routerProvider);

    // El tema completo (claro/oscuro) llega en el paso 0.1.5.
    return MaterialApp.router(
      title: 'SOS Mascota',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: const Color(0xFF1F8A5B)),
      routerConfig: router,
      builder: (context, child) => env.isProd
          ? child!
          : Banner(
              message: 'DEV',
              location: BannerLocation.topEnd,
              child: child!,
            ),
    );
  }
}
