import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'cuenta/perfil_repositorio.dart';
import 'cuenta/servicio_cuenta.dart';
import 'features/ajustes/ajustes_screen.dart';
import 'features/ayuda/ayuda_screen.dart';
import 'features/consentimiento/consentimiento_screen.dart';
import 'features/ingresar/ingresar_screen.dart';
import 'features/legal/legal_screen.dart';
import 'features/mapa/mapa_screen.dart';
import 'features/mascotas/ficha_mascota_screen.dart';
import 'features/mascotas/mascota_form_screen.dart';
import 'features/mascotas/mascotas_screen.dart';
import 'features/mascotas/qr_mascota_screen.dart';
import 'features/shell/app_shell.dart';
import 'features/sos/sos_nuevo_screen.dart';
import 'features/sos/sos_screen.dart';
import 'legal/legal.dart';
import 'redireccion.dart';

/// Direcciones de la app. También son las direcciones web (enlaces compartibles).
abstract final class Rutas {
  static const mapa = '/mapa';
  static const sos = '/sos';
  static const mascotas = '/mascotas';
  static const ayuda = '/ayuda';
  static const ajustes = '/ajustes';
  static const ingresar = '/ingresar';
  static const consentimiento = '/consentimiento';
  static const legal = '/legal';
  static const terminos = '/legal/terminos';
  static const privacidad = '/legal/privacidad';
  static const sosNuevo = '/sos/nuevo';
  static const mascotaNueva = '/mascotas/nueva';

  /// Rutas que un visitante no puede ver: se le pide ingresar y después vuelve.
  static const requierenCuenta = <String>[sosNuevo, '$mascotas/'];

  static String fichaMascota(String id) => '$mascotas/$id';
  static String editarMascota(String id) => '$mascotas/$id/editar';
  static String qrMascota(String id) => '$mascotas/$id/qr';

  /// Pantalla de ingreso que, al terminar, vuelve a [destino].
  static String ingresarYVolverA(String destino) =>
      Uri(path: ingresar, queryParameters: {'volver': destino}).toString();
}

GoRoute _pestana(
  String ruta,
  GoRouterWidgetBuilder builder, {
  List<RouteBase> hijas = const [],
}) => GoRoute(path: ruta, builder: builder, routes: hijas);

/// Ruta hija: [ruta] completa (p. ej. `/sos/nuevo`) dentro de su pestaña.
GoRoute _hija(String ruta, Widget pantalla) =>
    GoRoute(path: ruta.split('/').last, builder: (_, _) => pantalla);

final routerProvider = Provider<GoRouter>((ref) {
  // Al iniciar o cerrar sesión, o al cambiar el consentimiento, se vuelven a
  // evaluar las redirecciones.
  final cambio = ValueNotifier<(bool, bool)>((
    ref.read(conectadoProvider),
    ref.read(necesitaConsentimientoProvider),
  ));
  void actualizar() => cambio.value = (
    ref.read(conectadoProvider),
    ref.read(necesitaConsentimientoProvider),
  );
  ref
    ..listen(conectadoProvider, (_, _) => actualizar())
    ..listen(necesitaConsentimientoProvider, (_, _) => actualizar())
    ..onDispose(cambio.dispose);

  final router = GoRouter(
    initialLocation: Rutas.mapa,
    refreshListenable: cambio,
    redirect: (context, state) => redirigir(
      conectado: ref.read(conectadoProvider),
      necesitaConsentimiento: ref.read(necesitaConsentimientoProvider),
      uri: state.uri,
    ),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(
            routes: [_pestana(Rutas.mapa, (_, _) => const MapaScreen())],
          ),
          StatefulShellBranch(
            routes: [
              _pestana(
                Rutas.sos,
                (_, _) => const SosScreen(),
                hijas: [_hija(Rutas.sosNuevo, const SosNuevoScreen())],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              _pestana(
                Rutas.mascotas,
                (_, _) => const MascotasScreen(),
                hijas: [
                  _hija(Rutas.mascotaNueva, const MascotaFormScreen()),
                  GoRoute(
                    path: ':id',
                    builder: (_, state) => FichaMascotaScreen(
                      mascotaId: state.pathParameters['id']!,
                    ),
                    routes: [
                      GoRoute(
                        path: 'editar',
                        builder: (_, state) => MascotaFormScreen(
                          mascotaId: state.pathParameters['id'],
                        ),
                      ),
                      GoRoute(
                        path: 'qr',
                        builder: (_, state) => QrMascotaScreen(
                          mascotaId: state.pathParameters['id']!,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
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
        path: Rutas.consentimiento,
        builder: (context, state) =>
            ConsentimientoScreen(volver: state.uri.queryParameters['volver']),
      ),
      GoRoute(
        path: Rutas.terminos,
        builder: (_, _) =>
            const LegalScreen(documento: DocumentoLegal.terminos),
      ),
      GoRoute(
        path: Rutas.privacidad,
        builder: (_, _) =>
            const LegalScreen(documento: DocumentoLegal.privacidad),
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
