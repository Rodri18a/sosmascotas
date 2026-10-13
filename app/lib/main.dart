import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'src/app.dart';
import 'src/config/env_provider.dart';

void main() {
  final env = AppEnv.fromEnvironment();
  runApp(
    ProviderScope(
      overrides: [appEnvProvider.overrideWithValue(env)],
      child: const SosMascotaApp(),
    ),
  );
}
