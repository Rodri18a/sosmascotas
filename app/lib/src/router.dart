import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/ajustes/ajustes_screen.dart';
import 'features/ayuda/ayuda_screen.dart';
import 'features/mapa/mapa_screen.dart';
import 'features/mascotas/mascotas_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/sos/sos_screen.dart';

/// Direcciones de la app. También son las direcciones web (enlaces compartibles).
abstract final class Rutas {
  static const mapa = '/mapa';
  static const sos = '/sos';
  static const mascotas = '/mascotas';
  static const ayuda = '/ayuda';
  static const ajustes = '/ajustes';
}

GoRoute _pestana(String ruta, GoRouterWidgetBuilder builder) =>
    GoRoute(path: ruta, builder: builder);

final routerProvider = Provider<GoRouter>((ref) {
  final router = GoRouter(
    initialLocation: Rutas.mapa,
    redirect: (context, state) => state.uri.path == '/' ? Rutas.mapa : null,
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [_pestana(Rutas.mapa, (_, _) => const MapaScreen())],
          ),
          StatefulShellBranch(
            routes: [_pestana(Rutas.sos, (_, _) => const SosScreen())],
          ),
          StatefulShellBranch(
            routes: [
              _pestana(Rutas.mascotas, (_, _) => const MascotasScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [_pestana(Rutas.ayuda, (_, _) => const AyudaScreen())],
          ),
        ],
      ),
      GoRoute(
        path: Rutas.ajustes,
        builder: (context, state) => const AjustesScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
