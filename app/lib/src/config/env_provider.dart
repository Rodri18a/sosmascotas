import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Configuración del entorno. Se define en `main()` (y en las pruebas) con un override.
final appEnvProvider = Provider<AppEnv>(
  (ref) => throw UnimplementedError('appEnvProvider se define en main()'),
);
