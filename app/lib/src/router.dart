import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'cuenta/servicio_cuenta.dart';
import 'features/ajustes/ajustes_screen.dart';
import 'features/ayuda/ayuda_screen.dart';
import 'features/ingresar/ingresar_screen.dart';
import 'features/mapa/mapa_screen.dart';
import 'features/mascotas/mascotas_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/sos/sos_screen.dart';
import 'redireccion.dart';

/// Direcciones de la app. También son las direcciones web (enlaces compartibles).
abstract final class Rutas {
  static const mapa = '/mapa';
  static const sos = '/sos';
  static const mascotas = '/mascotas';
  static const ayuda = '/ayuda';
  static const ajustes = '/ajustes';
  static const ingresar = '/ingresar';

  /// Rutas que un visitante no puede ver: se le pide ingresar y después vuelve.
  static const requierenCuenta = <String>[];

  /// Pantalla de ingreso que, al terminar, vuelve a [destino].
  static String ingresarYVolverA(String destino) =>
      Uri(path: ingresar, queryParameters: {'volver': destino}).toString();
}

GoRoute _pestana(String ruta, GoRouterWidgetBuilder builder) =>
    GoRoute(path: ruta, builder: builder);

final routerProvider = Provider<GoRouter>((ref) {
  // Al iniciar o cerrar sesión se vuelven a evaluar las redirecciones.
  final cambioDeSesion = ValueNotifier<bool>(ref.read(conectadoProvider));
  ref
    ..listen(
      conectadoProvider,
      (_, conectado) => cambioDeSesion.value = conectado,
    )
    ..onDispose(cambioDeSesion.dispose);

  final router = GoRouter(
    initialLocation: Rutas.mapa,
    refreshListenable: cambioDeSesion,
    redirect: (context, state) =>
        redirigir(conectado: ref.read(conectadoProvider), uri: state.uri),
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
      GoRoute(
        path: Rutas.ingresar,
        builder: (context, state) =>
            IngresarScreen(volver: state.uri.queryParameters['volver']),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
});
