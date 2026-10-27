import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta/perfil_repositorio.dart';
import 'cuenta/servicio_cuenta.dart';
import 'features/adopcion/adopcion_screen.dart';
import 'features/adopcion/apadrinamiento_screen.dart';
import 'features/adopcion/pack_screen.dart';
import 'features/adopcion/transito_screen.dart';
import 'features/agenda/cuidados.dart';
import 'features/agenda/reservar_turno.dart';
import 'features/ajustes/ajustes_screen.dart';
import 'features/ajustes/plan_usuario_screen.dart';
import 'features/avisos/avisos_screen.dart';
import 'features/ayuda/ayuda_screen.dart';
import 'features/chapitas/pedido_chapita.dart';
import 'features/chat/chat_screen.dart';
import 'features/consentimiento/consentimiento_screen.dart';
import 'features/eventos/eventos.dart';
import 'features/hogar/hogar_screen.dart';
import 'features/ingresar/ingresar_screen.dart';
import 'features/legal/legal_screen.dart';
import 'features/libreta/libreta.dart';
import 'features/mapa/buscar_lugares.dart';
import 'features/mapa/mapa_screen.dart';
import 'features/mapa/marcar_lugar.dart';
import 'features/mascotas/activar_chapita_screen.dart';
import 'features/mascotas/ficha_mascota_screen.dart';
import 'features/mascotas/mascota_form_screen.dart';
import 'features/mascotas/mascotas_screen.dart';
import 'features/mascotas/qr_mascota_screen.dart';
import 'features/negocio/descuentos_screen.dart';
import 'features/negocio/estadisticas_screen.dart';
import 'features/negocio/negocio_screen.dart';
import 'features/negocio/plan_screen.dart';
import 'features/no_disponible/no_disponible_screen.dart';
import 'features/noticias/noticias_screen.dart';
import 'features/perfil/perfil_screen.dart';
import 'features/recordatorios/recordatorios.dart';
import 'features/renac/renac.dart';
import 'features/shell/app_shell.dart';
import 'features/sos/sos_detalle_screen.dart';
import 'features/sos/sos_nuevo_screen.dart';
import 'features/sos/sos_screen.dart';
import 'features/tienda/catalogo_screen.dart';
import 'features/tienda/servicios.dart';
import 'features/veterinarias/socios_screen.dart';
import 'funcionalidades/funcionalidades_activas.dart';
import 'legal/legal.dart';
import 'redireccion.dart';
import 'sos/sos_repositorio.dart';

/// Direcciones de la app. También son las direcciones web (enlaces compartibles).
abstract final class Rutas {
  static const mapa = '/mapa';
  static const sos = '/sos';
  static const mascotas = '/mascotas';
  static const ayuda = '/ayuda';
  static const ajustes = '/ajustes';
  static const ingresar = '/ingresar';
  static const avisos = '/avisos';
  static const consentimiento = '/consentimiento';
  static const legal = '/legal';
  static const terminos = '/legal/terminos';
  static const privacidad = '/legal/privacidad';
  static const sosNuevo = '/sos/nuevo';
  static const mascotaNueva = '/mascotas/nueva';
  static const noDisponible = '/no-disponible';
  static const libreta = '/libreta';
  static const recordatorios = '/recordatorios';
  static const hogar = '/hogar';
  static const unirme = '/unirme';
  static const activar = '/activar';
  static const perfil = '/perfil';
  static const chats = '/chats';
  static const negocio = '/negocio';
  static const adopcion = '/adopcion';
  static const noticias = '/noticias';
  static const misPedidos = '/pedidos';
  static const miPlan = '/mi-plan';
  static const misTurnos = '/turnos';
  static String reservarTurno(String negocioId) =>
      '$misTurnos/reservar/$negocioId';
  static const misCuidados = '/cuidados';
  static String pedirCuidado(String negocioId) =>
      '$misCuidados/pedir/$negocioId';
  static const _tienda = '/tienda';
  static String tienda(String negocioId) => '$_tienda/$negocioId';
  static const denuncia = '/denuncia';
  static const nuevoEvento = '/eventos/nuevo';
  static const marcarLugar = '/lugares/marcar';
  static const guiaRenac = '/renac';
  static const buscarLugares = '/buscar';
  static const _chapitas = '/chapitas';
  static String pedirChapita(String mascotaId) => '$_chapitas/pedir/$mascotaId';
  static String chapitasNegocio(String id) => '$negocio/chapitas/$id';
  static const hogarTransito = '$adopcion/transito';
  static const packAdopcion = '$adopcion/pack';
  static String packNegocio(String id) => '$negocio/pack/$id';
  static String descuentosNegocio(String id) => '$negocio/descuentos/$id';
  static const descuentosPro = '/descuentos';
  static String apadrinar(String id) => '$negocio/apadrinar/$id';
  static String transitoRefugio(String id) => '$negocio/transito/$id';

  /// Búsqueda de lugares cerca de [desde] (el centro del mapa).
  static String buscar(Punto desde) => Uri(
    path: buscarLugares,
    queryParameters: {'lat': '${desde.lat}', 'lng': '${desde.lng}'},
  ).toString();

  /// El mapa con el filtro "Coloca microchip" ya puesto (guía del RENAC).
  static const mapaColocaMicrochip = '$mapa?filtro=microchip';

  /// Rutas detrás de una funcionalidad gradual (comienzo de la ruta → clave de
  /// `Funcionalidades`). Quien entra sin tenerla prendida ve "Todavía no está
  /// disponible" (D64).
  static const conFuncionalidad = <String, String>{
    '$libreta/': Funcionalidades.libreta,
    '$recordatorios/': Funcionalidades.recordatorios,
    hogar: Funcionalidades.hogar,
    perfil: Funcionalidades.perfil,
    chats: Funcionalidades.chat,
    // Antes que `negocio`: gana el primer comienzo que coincide.
    '$negocio/socios/': Funcionalidades.veterinarias,
    '$negocio/servicios/': Funcionalidades.catalogo,
    '$negocio/chapitas/': Funcionalidades.pedidoChapitas,
    '$negocio/transito/': Funcionalidades.adopcion,
    '$negocio/pack/': Funcionalidades.adopcion,
    '$negocio/descuentos/': Funcionalidades.planesUsuario,
    descuentosPro: Funcionalidades.planesUsuario,
    '$negocio/apadrinar/': Funcionalidades.adopcion,
    '$negocio/estadisticas/': Funcionalidades.estadisticas,
    '$negocio/plan/': Funcionalidades.planes,
    negocio: Funcionalidades.comercios,
    adopcion: Funcionalidades.adopcion,
    denuncia: Funcionalidades.eventos,
    nuevoEvento: Funcionalidades.eventos,
    marcarLugar: Funcionalidades.comercios,
    guiaRenac: Funcionalidades.renac,
    buscarLugares: Funcionalidades.busqueda,
    '$_chapitas/': Funcionalidades.pedidoChapitas,
    misTurnos: Funcionalidades.agenda,
    misCuidados: Funcionalidades.cuidados,
    miPlan: Funcionalidades.planesUsuario,
  };

  /// Rutas que un visitante no puede ver: se le pide ingresar y después vuelve.
  static const requierenCuenta = <String>[
    sosNuevo,
    '$mascotas/',
    avisos,
    '$libreta/',
    '$recordatorios/',
    hogar,
    '$unirme/',
    '$activar/',
    perfil,
    chats,
    negocio,
    marcarLugar,
    '$adopcion/perfil',
    '$adopcion/publicar',
    '$adopcion/compromiso',
    hogarTransito,
    packAdopcion,
    denuncia,
    nuevoEvento,
    misPedidos,
    '$_chapitas/',
    misTurnos,
    misCuidados,
    miPlan,
  ];

  static String fichaMascota(String id) => '$mascotas/$id';
  static String detalleSos(String id) => '$sos/$id';

  /// Reportar perdida una mascota propia (con sus datos cargados).
  static String reportarMascota(String mascotaId) =>
      Uri(path: sosNuevo, queryParameters: {'mascota': mascotaId}).toString();
  static String editarMascota(String id) => '$mascotas/$id/editar';
  static String qrMascota(String id) => '$mascotas/$id/qr';
  static String nuevoRegistroSalud(String mascotaId) =>
      '$libreta/$mascotaId/nuevo';
  static String editarRegistroSalud(String mascotaId, String id) =>
      '$libreta/$mascotaId/$id';
  static String chat(String id) => '$chats/$id';
  static String sociosNegocio(String id) => '$negocio/socios/$id';
  static String serviciosNegocio(String id) => '$negocio/servicios/$id';
  static String estadisticasNegocio(String id) => '$negocio/estadisticas/$id';
  static String planNegocio(String id) => '$negocio/plan/$id';
  static String altaNegocio({Categoria? rubro, Punto? punto}) => Uri(
    path: '$negocio/alta',
    queryParameters: {
      'rubro': ?rubro?.valor,
      if (punto != null) 'lat': '${punto.lat}',
      if (punto != null) 'lng': '${punto.lng}',
    },
  ).toString();
  static String nuevoRecordatorio(
    String mascotaId, {
    TipoRecordatorio? tipo,
    String? titulo,
    DateTime? fecha,
  }) => Uri(
    path: '$recordatorios/$mascotaId/nuevo',
    queryParameters: tipo == null
        ? null
        : {
            'tipo': tipo.name,
            'titulo': ?titulo,
            if (fecha != null) 'fecha': fechaIso(fecha),
          },
  ).toString();
  static String editarRecordatorio(String mascotaId, String id) =>
      '$recordatorios/$mascotaId/$id';

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
  // Al iniciar o cerrar sesión, al cambiar el consentimiento o al cambiar las
  // funcionalidades prendidas, se vuelven a evaluar las redirecciones.
  final cambio = ValueNotifier<(bool, bool, EstadoFuncionalidades)>((
    ref.read(conectadoProvider),
    ref.read(necesitaConsentimientoProvider),
    ref.read(funcionalidadesProvider),
  ));
  void actualizar() => cambio.value = (
    ref.read(conectadoProvider),
    ref.read(necesitaConsentimientoProvider),
    ref.read(funcionalidadesProvider),
  );
  ref
    ..listen(conectadoProvider, (_, _) => actualizar())
    ..listen(necesitaConsentimientoProvider, (_, _) => actualizar())
    ..listen(funcionalidadesProvider, (_, _) => actualizar())
    ..onDispose(cambio.dispose);

  final router = GoRouter(
    initialLocation: Rutas.mapa,
    refreshListenable: cambio,
    redirect: (context, state) => redirigir(
      conectado: ref.read(conectadoProvider),
      necesitaConsentimiento: ref.read(necesitaConsentimientoProvider),
      uri: state.uri,
      funcionalidadActiva: ref.read(funcionalidadesProvider).activa,
    ),
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(navigationShell: shell),
        branches: [
          // El orden es el de `Pestana` en la barra inferior (D94).
          StatefulShellBranch(
            routes: [
              _pestana(Rutas.noticias, (_, _) => const NoticiasScreen()),
            ],
          ),
          StatefulShellBranch(
            routes: [
              _pestana(
                Rutas.sos,
                (_, _) => const SosScreen(),
                hijas: [
                  GoRoute(
                    path: 'nuevo',
                    builder: (_, state) => SosNuevoScreen(
                      mascotaId: state.uri.queryParameters['mascota'],
                    ),
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (_, state) =>
                        SosDetalleScreen(sosId: state.pathParameters['id']!),
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              _pestana(
                Rutas.mapa,
                (_, state) => MapaScreen(
                  colocaMicrochip:
                      state.uri.queryParameters['filtro'] == 'microchip',
                ),
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
        path: Rutas.avisos,
        builder: (context, state) => const AvisosScreen(),
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
        path: '${Rutas.libreta}/:mascota/nuevo',
        builder: (_, state) =>
            RegistroSaludScreen(mascotaId: state.pathParameters['mascota']!),
      ),
      GoRoute(
        path: '${Rutas.libreta}/:mascota/:id',
        builder: (_, state) => RegistroSaludScreen(
          mascotaId: state.pathParameters['mascota']!,
          registroId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: '${Rutas.recordatorios}/:mascota/nuevo',
        builder: (_, state) => RecordatorioScreen(
          mascotaId: state.pathParameters['mascota']!,
          precarga: RecordatorioScreen.precargaDe(state.uri.queryParameters),
        ),
      ),
      GoRoute(
        path: '${Rutas.recordatorios}/:mascota/:id',
        builder: (_, state) => RecordatorioScreen(
          mascotaId: state.pathParameters['mascota']!,
          recordatorioId: state.pathParameters['id'],
        ),
      ),
      GoRoute(path: Rutas.hogar, builder: (_, _) => const HogarScreen()),
      GoRoute(path: Rutas.perfil, builder: (_, _) => const PerfilScreen()),
      GoRoute(
        path: Rutas.negocio,
        builder: (_, state) =>
            NegocioScreen(seccion: state.uri.queryParameters['seccion']),
        routes: [
          GoRoute(
            path: 'socios/:id',
            builder: (_, state) =>
                SociosScreen(negocioId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'plan/:id',
            builder: (_, state) =>
                PlanScreen(negocioId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'estadisticas/:id',
            builder: (_, state) =>
                EstadisticasScreen(negocioId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'chapitas/:id',
            builder: (_, state) =>
                ChapitasNegocioScreen(negocioId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'transito/:id',
            builder: (_, state) =>
                TransitoRefugioScreen(negocioId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'pack/:id',
            builder: (_, state) =>
                PackNegocioScreen(negocioId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'descuentos/:id',
            builder: (_, state) =>
                DescuentosNegocioScreen(negocioId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'apadrinar/:id',
            builder: (_, state) =>
                ApadrinamientoScreen(negocioId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'servicios/:id',
            builder: (_, state) =>
                ServiciosNegocioScreen(negocioId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'alta',
            builder: (_, state) {
              final q = state.uri.queryParameters;
              final lat = double.tryParse(q['lat'] ?? '');
              final lng = double.tryParse(q['lng'] ?? '');
              return AltaNegocioScreen(
                precarga: (
                  rubro: Categoria.leer(q['rubro']),
                  punto: lat == null || lng == null ? null : Punto(lat, lng),
                ),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: Rutas.adopcion,
        builder: (_, _) => const AdopcionScreen(),
        routes: [
          GoRoute(
            path: 'animal/:id',
            builder: (_, state) =>
                AnimalAdopcionScreen(animalId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: 'perfil',
            builder: (_, _) => const PerfilAdoptanteScreen(),
          ),
          GoRoute(path: 'guia', builder: (_, _) => const GuiaAdopcionScreen()),
          GoRoute(
            path: 'transito',
            builder: (_, _) => const HogarTransitoScreen(),
          ),
          GoRoute(path: 'pack', builder: (_, _) => const PackAdopcionScreen()),
          GoRoute(
            path: 'calculadora',
            builder: (_, _) => const CalculadoraCostosScreen(),
          ),
          GoRoute(
            path: 'publicar',
            builder: (_, _) => const PublicarAdopcionScreen(),
          ),
          GoRoute(
            path: 'compromiso/:id',
            builder: (_, state) => CompromisoAdopcionScreen(
              solicitudId: state.pathParameters['id']!,
            ),
          ),
        ],
      ),
      GoRoute(
        path: '${Rutas._chapitas}/pedir/:mascota',
        builder: (_, state) =>
            PedirChapitaScreen(mascotaId: state.pathParameters['mascota']!),
      ),
      GoRoute(
        path: Rutas.buscarLugares,
        builder: (_, state) => BuscarLugaresScreen(
          desde: switch ((
            double.tryParse(state.uri.queryParameters['lat'] ?? ''),
            double.tryParse(state.uri.queryParameters['lng'] ?? ''),
          )) {
            (final lat?, final lng?) => Punto(lat, lng),
            _ => ref.read(miZonaProvider),
          },
        ),
      ),
      GoRoute(
        path: Rutas.guiaRenac,
        builder: (_, _) => const GuiaRenacScreen(),
      ),
      GoRoute(path: Rutas.denuncia, builder: (_, _) => const DenunciaScreen()),
      GoRoute(
        path: '${Rutas._tienda}/:id',
        builder: (_, state) => CatalogoScreen(
          negocioId: state.pathParameters['id']!,
          comercio: state.extra is Comercio ? state.extra! as Comercio : null,
        ),
      ),
      GoRoute(
        path: Rutas.misTurnos,
        builder: (_, _) => const MisTurnosScreen(),
        routes: [
          GoRoute(
            path: 'reservar/:id',
            builder: (_, state) =>
                ReservarTurnoScreen(negocioId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: Rutas.misCuidados,
        builder: (_, _) => const MisCuidadosScreen(),
        routes: [
          GoRoute(
            path: 'pedir/:id',
            builder: (_, state) =>
                PedirCuidadoScreen(negocioId: state.pathParameters['id']!),
          ),
        ],
      ),
      GoRoute(
        path: Rutas.misPedidos,
        builder: (_, _) => const MisPedidosScreen(),
      ),
      GoRoute(path: Rutas.miPlan, builder: (_, _) => const PlanUsuarioScreen()),
      GoRoute(
        path: Rutas.descuentosPro,
        builder: (_, _) => const DescuentosProScreen(),
      ),
      GoRoute(
        path: Rutas.nuevoEvento,
        builder: (_, state) {
          final q = state.uri.queryParameters;
          final lat = double.tryParse(q['lat'] ?? '');
          final lng = double.tryParse(q['lng'] ?? '');
          return EventoFormScreen(
            comercioId: q['negocio'] ?? '',
            punto: lat == null || lng == null ? null : Punto(lat, lng),
          );
        },
      ),
      GoRoute(
        path: Rutas.marcarLugar,
        builder: (_, _) => const MarcarLugarScreen(),
      ),
      GoRoute(
        path: Rutas.chats,
        builder: (_, _) => const ConversacionesScreen(),
        routes: [
          GoRoute(
            path: ':id',
            builder: (_, state) =>
                ChatScreen(conversacionId: state.pathParameters['id']!),
          ),
        ],
      ),
      // Sin funcionalidad: quien recibe la invitación tiene que poder unirse
      // aunque todavía no tenga "Mi hogar" prendido.
      GoRoute(
        path: '${Rutas.unirme}/:codigo',
        builder: (_, state) =>
            UnirmeScreen(codigo: state.pathParameters['codigo']!),
      ),
      // Enlace de la página de una chapita sin activar (1.8b.2, D95).
      GoRoute(
        path: '${Rutas.activar}/:codigo',
        builder: (_, state) =>
            ActivarChapitaScreen(codigo: state.pathParameters['codigo']!),
      ),
      GoRoute(
        path: Rutas.noDisponible,
        builder: (_, _) => const NoDisponibleScreen(),
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
