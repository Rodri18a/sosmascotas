import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/inicio/inicio_screen.dart';

/// Rutas de la app. La navegación con barra inferior llega en el paso 0.1.5.
final routerProvider = Provider<GoRouter>(
  (ref) => GoRouter(
    routes: [
      GoRoute(path: '/', builder: (context, state) => const InicioScreen()),
    ],
  ),
);
