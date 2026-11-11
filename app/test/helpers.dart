import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sosmascota/src/adopcion/adopcion_repositorio.dart';
import 'package:sosmascota/src/adopcion/apadrinamiento_repositorio.dart';
import 'package:sosmascota/src/adopcion/pack_repositorio.dart';
import 'package:sosmascota/src/adopcion/transito_repositorio.dart';
import 'package:sosmascota/src/agenda/agenda_repositorio.dart';
import 'package:sosmascota/src/agenda/cuidados_repositorio.dart';
import 'package:sosmascota/src/app.dart';
import 'package:sosmascota/src/avisos/avisos_repositorio.dart';
import 'package:sosmascota/src/ayuda/ayuda_repositorio.dart';
import 'package:sosmascota/src/chat/chat_repositorio.dart';
import 'package:sosmascota/src/comercios/comercios_repositorio.dart';
import 'package:sosmascota/src/comercios/descuentos_repositorio.dart';
import 'package:sosmascota/src/comercios/equipo_repositorio.dart';
import 'package:sosmascota/src/comercios/mis_lugares.dart';
import 'package:sosmascota/src/comercios/negocios_repositorio.dart';
import 'package:sosmascota/src/comercios/promociones_repositorio.dart';
import 'package:sosmascota/src/comercios/resenas_repositorio.dart';
import 'package:sosmascota/src/comunidad/comunidad_repositorio.dart';
import 'package:sosmascota/src/config/env_provider.dart';
import 'package:sosmascota/src/config/supabase_providers.dart';
import 'package:sosmascota/src/cuenta/huellas_repositorio.dart';
import 'package:sosmascota/src/cuenta/perfil_repositorio.dart';
import 'package:sosmascota/src/cuenta/plan_usuario_repositorio.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/dos_apps/dos_apps.dart';
import 'package:sosmascota/src/eventos/eventos_repositorio.dart';
import 'package:sosmascota/src/fotos/selector_documento.dart';
import 'package:sosmascota/src/fotos/selector_foto.dart';
import 'package:sosmascota/src/funcionalidades/funcionalidades_activas.dart';
import 'package:sosmascota/src/hogar/hogar_repositorio.dart';
import 'package:sosmascota/src/hogar/tareas_repositorio.dart';
import 'package:sosmascota/src/instalar/servicio_instalacion.dart';
import 'package:sosmascota/src/mapa/filtros_guardados.dart';
import 'package:sosmascota/src/mapa/mapa_vista.dart';
import 'package:sosmascota/src/mascotas/catalogo.dart';
import 'package:sosmascota/src/mascotas/enlaces_historial_repositorio.dart';
import 'package:sosmascota/src/mascotas/historial_repositorio.dart';
import 'package:sosmascota/src/mascotas/libreta_repositorio.dart';
import 'package:sosmascota/src/mascotas/mascotas_repositorio.dart';
import 'package:sosmascota/src/mascotas/transferencias_repositorio.dart';
import 'package:sosmascota/src/metricas/metricas.dart';
import 'package:sosmascota/src/noticias/noticias_repositorio.dart';
import 'package:sosmascota/src/push/servicio_push.dart';
import 'package:sosmascota/src/qr/pedidos_chapita_repositorio.dart';
import 'package:sosmascota/src/qr/qr_repositorio.dart';
import 'package:sosmascota/src/recordatorios/avisador.dart';
import 'package:sosmascota/src/recordatorios/recordatorios_repositorio.dart';
import 'package:sosmascota/src/recorrido/recorrido.dart';
import 'package:sosmascota/src/router.dart';
import 'package:sosmascota/src/sos/sos_repositorio.dart';
import 'package:sosmascota/src/theme/tema_elegido.dart';
import 'package:sosmascota/src/tienda/tienda_repositorio.dart';
import 'package:sosmascota/src/ubicacion/mi_posicion.dart';
import 'package:sosmascota/src/ubicacion/servicio_ubicacion.dart';
import 'package:sosmascota/src/utiles/enlaces.dart';
import 'package:sosmascota/src/utiles/respaldo.dart';
import 'package:sosmascota/src/veterinarias/veterinarias_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'adopcion_falsa.dart';
import 'agenda_falsa.dart';
import 'apadrinamiento_falso.dart';
import 'avisos_falsos.dart';
import 'ayuda_falsa.dart';
import 'chat_falso.dart';
import 'comercios_falsos.dart';
import 'comunidad_falsa.dart';
import 'cuenta_falsa.dart';
import 'cuidados_falsos.dart';
import 'descuentos_falsos.dart';
import 'enlaces_historial_falsos.dart';
import 'equipo_falso.dart';
import 'eventos_falsos.dart';
import 'filtros_falsos.dart';
import 'funcionalidades_falsas.dart';
import 'historial_falso.dart';
import 'hogar_falso.dart';
import 'instalacion_falsa.dart';
import 'libreta_falsa.dart';
import 'mapa_falso.dart';
import 'mascotas_falsas.dart';
import 'noticias_falsas.dart';
import 'pack_falso.dart';
import 'pedidos_chapita_falsos.dart';
import 'perfil_falso.dart';
import 'plan_usuario_falso.dart';
import 'promociones_falsas.dart';
import 'qr_falso.dart';
import 'recordatorios_falsos.dart';
import 'resenas_falsas.dart';
import 'respaldo_falso.dart';
import 'sos_falso.dart';
import 'tareas_falsas.dart';
import 'tema_falso.dart';
import 'tienda_falsa.dart';
import 'transferencias_falsas.dart';
import 'transito_falso.dart';
import 'veterinarias_falsas.dart';

const urlPrueba = 'https://abc.supabase.co';
const clavePrueba = 'sb_publishable_prueba';

/// La app completa con dependencias de prueba (sin red real).
Widget appDePrueba({
  AppFlavor flavor = AppFlavor.dev,
  bool conSupabase = false,
  int respuestaSalud = 200,
  bool googleHabilitado = false,
  ServicioCuenta? cuenta,
  PerfilRepositorio? perfiles,
  List<Map<String, Object?>>? eventos,
  MascotasRepositorio? mascotas,
  LibretaRepositorio? libreta,
  HistorialRepositorio? historial,
  TransferenciasRepositorio? transferencias,
  EnlacesHistorialRepositorio? enlacesHistorial,
  PromocionesRepositorio? promociones,
  Huellas? huellas,
  SelectorDocumento? selectorDocumento,
  RecordatoriosRepositorio? recordatorios,
  AvisadorRecordatorios? avisador,
  AlmacenRespaldo? respaldo,
  HogarRepositorio? hogar,
  TareasRepositorio? tareas,
  ChatRepositorio? chat,
  MisLugaresRepositorio? misLugares,
  NegociosRepositorio? negocios,
  ResenasRepositorio? resenas,
  AdopcionRepositorio? adopcion,
  TransitoRepositorio? transito,
  PackAdopcionRepositorio? pack,
  ApadrinamientoRepositorio? apadrinamiento,
  EventosRepositorio? eventosRepo,
  VeterinariasRepositorio? veterinarias,
  NoticiasRepositorio? noticias,
  TiendaRepositorio? tienda,
  AgendaRepositorio? agenda,
  CuidadosRepositorio? cuidados,
  ComunidadRepositorio? comunidad,
  PlanUsuarioRepositorio? planUsuario,
  AlmacenFiltros? almacenFiltros,
  DescuentosRepositorio? descuentos,
  EquipoRepositorio? equipo,
  Posicion? posicion,
  Posicion? posicionSinPreguntar,
  SelectorFoto? selectorFoto,
  QrRepositorio? qr,
  PedidosChapitaRepositorio? pedidosChapita,
  AvisosRepositorio? avisos,
  SosRepositorio? sos,
  ServicioPush? push,
  ServicioUbicacion? ubicacion,
  ComerciosRepositorio? comercios,
  List<Uri>? enlacesAbiertos,
  DateTime? ahora,
  AyudaRepositorio? ayuda,
  AlmacenTema? almacenTema,
  FuncionalidadesRepositorio? funcionalidades,
  CacheFuncionalidades? cacheFuncionalidades,
  ServicioInstalacion? instalacion,
  AlmacenInstalacion? almacenInstalacion,
  String urlPublica = 'https://huellamy.com',
  // La mayoría de las pruebas se escribieron arrancando en el Mapa; las de
  // navegación arrancan donde abre la app de verdad (Rutas.inicio, D127).
  String inicio = Rutas.mapa,
  // Huellamy Comercios (D129) y la otra app que se abrió (en la web).
  bool appComercio = false,
  List<String>? otraAppAbierta,
  // Recorridos guiados (D130): por defecto ya vistos, para que no salgan solos.
  AlmacenRecorridos? recorridos,
}) => ProviderScope(
  overrides: [
    rutaInicialProvider.overrideWithValue(inicio),
    esAppComercioProvider.overrideWithValue(appComercio),
    abrirOtraAppProvider.overrideWithValue(otraAppAbierta?.add),
    urlComerciosProvider.overrideWithValue('https://comercios.huellamy.com'),
    // Por defecto, como si ya estuviera instalada: no se ofrece nada.
    servicioInstalacionProvider.overrideWithValue(
      instalacion ?? const InstalacionNoDisponible(),
    ),
    almacenInstalacionProvider.overrideWithValue(
      almacenInstalacion ?? AlmacenInstalacionFalso(),
    ),
    funcionalidadesRepositorioProvider.overrideWithValue(
      funcionalidades ?? FuncionalidadesFalsas(),
    ),
    cacheFuncionalidadesProvider.overrideWithValue(
      cacheFuncionalidades ?? CacheFuncionalidadesFalsa(),
    ),
    almacenTemaProvider.overrideWithValue(almacenTema ?? AlmacenTemaFalso()),
    almacenRecorridosProvider.overrideWithValue(
      recorridos ?? AlmacenRecorridosFalso(todosVistos: true),
    ),
    cargadorFuentesProvider.overrideWithValue(const FuentesFalsas()),
    sosRepositorioProvider.overrideWithValue(sos ?? SosFalso()),
    abrirEnlaceProvider.overrideWithValue((enlace) async {
      enlacesAbiertos?.add(enlace);
      return true;
    }),
    if (ahora != null) relojProvider.overrideWithValue(() => ahora),
    ayudaRepositorioProvider.overrideWithValue(ayuda ?? AyudaFalsa()),
    comerciosRepositorioProvider.overrideWithValue(
      comercios ?? ComerciosFalsos(),
    ),
    servicioPushProvider.overrideWithValue(push ?? const PushNoDisponible()),
    servicioUbicacionProvider.overrideWithValue(
      ubicacion ?? const UbicacionSinConfigurar(),
    ),
    // Mapa falso: las pruebas no dibujan el mapa real (WebGL).
    constructorMapaProvider.overrideWithValue(MapaFalso.new),
    avisosRepositorioProvider.overrideWithValue(avisos ?? AvisosFalsos()),
    qrRepositorioProvider.overrideWithValue(qr ?? QrFalso()),
    pedidosChapitaRepositorioProvider.overrideWithValue(
      pedidosChapita ?? PedidosChapitaFalsos(),
    ),
    catalogoRepositorioProvider.overrideWithValue(CatalogoFalso()),
    mascotasRepositorioProvider.overrideWithValue(mascotas ?? MascotasFalsas()),
    libretaRepositorioProvider.overrideWithValue(libreta ?? LibretaFalsa()),
    historialRepositorioProvider.overrideWithValue(
      historial ?? HistorialFalso(),
    ),
    cargarHuellasProvider.overrideWithValue(
      () async => huellas ?? const Huellas(),
    ),
    promocionesRepositorioProvider.overrideWithValue(
      promociones ?? PromocionesFalsas(),
    ),
    enlacesHistorialRepositorioProvider.overrideWithValue(
      enlacesHistorial ?? EnlacesHistorialFalsos(),
    ),
    transferenciasRepositorioProvider.overrideWithValue(
      transferencias ?? TransferenciasFalsas(),
    ),
    selectorDocumentoProvider.overrideWithValue(
      selectorDocumento ?? () async => null,
    ),
    recordatoriosRepositorioProvider.overrideWithValue(
      recordatorios ?? RecordatoriosFalsos(),
    ),
    hogarRepositorioProvider.overrideWithValue(hogar ?? HogarFalso()),
    tareasRepositorioProvider.overrideWithValue(tareas ?? TareasFalsas()),
    chatRepositorioProvider.overrideWithValue(chat ?? ChatFalso()),
    negociosRepositorioProvider.overrideWithValue(negocios ?? NegociosFalsos()),
    resenasRepositorioProvider.overrideWithValue(resenas ?? ResenasFalsas()),
    adopcionRepositorioProvider.overrideWithValue(adopcion ?? AdopcionFalsa()),
    transitoRepositorioProvider.overrideWithValue(transito ?? TransitoFalso()),
    packAdopcionRepositorioProvider.overrideWithValue(pack ?? PackFalso()),
    apadrinamientoRepositorioProvider.overrideWithValue(
      apadrinamiento ?? ApadrinamientoFalso(),
    ),
    eventosRepositorioProvider.overrideWithValue(
      eventosRepo ?? EventosFalsos(),
    ),
    veterinariasRepositorioProvider.overrideWithValue(
      veterinarias ?? VeterinariasFalsas(),
    ),
    noticiasRepositorioProvider.overrideWithValue(noticias ?? NoticiasFalsas()),
    tiendaRepositorioProvider.overrideWithValue(tienda ?? TiendaFalsa()),
    agendaRepositorioProvider.overrideWithValue(agenda ?? AgendaFalsa()),
    cuidadosRepositorioProvider.overrideWithValue(cuidados ?? CuidadosFalsos()),
    comunidadRepositorioProvider.overrideWithValue(
      comunidad ?? ComunidadFalsa(),
    ),
    equipoRepositorioProvider.overrideWithValue(equipo ?? EquipoFalso()),
    descuentosRepositorioProvider.overrideWithValue(
      descuentos ?? DescuentosFalsos(),
    ),
    almacenFiltrosProvider.overrideWithValue(
      almacenFiltros ?? AlmacenFiltrosFalso(),
    ),
    planUsuarioRepositorioProvider.overrideWithValue(
      planUsuario ?? PlanUsuarioFalso(),
    ),
    misLugaresRepositorioProvider.overrideWithValue(
      misLugares ?? MisLugaresFalsos(),
    ),
    posicionActualProvider.overrideWithValue(() async => posicion),
    posicionSinPreguntarProvider.overrideWithValue(
      () async => posicionSinPreguntar,
    ),
    almacenRespaldoProvider.overrideWithValue(
      respaldo ?? AlmacenRespaldoFalso(),
    ),
    avisadorRecordatoriosProvider.overrideWithValue(
      avisador ?? AvisadorFalso(),
    ),
    selectorFotoProvider.overrideWithValue(selectorFoto ?? (_) async => null),
    servicioCuentaProvider.overrideWithValue(cuenta ?? ServicioCuentaFalso()),
    perfilRepositorioProvider.overrideWithValue(
      perfiles ?? PerfilRepositorioFalso(),
    ),
    appEnvProvider.overrideWithValue(
      AppEnv(
        flavor: flavor,
        supabaseUrl: conSupabase ? urlPrueba : '',
        supabasePublishableKey: conSupabase ? clavePrueba : '',
        urlPublica: urlPublica,
      ),
    ),
    supabaseClientProvider.overrideWithValue(null),
    metricasProvider.overrideWithValue(
      Metricas(
        anonId: 'anon-prueba',
        plataforma: 'web',
        enviar: eventos == null ? null : (fila) async => eventos.add(fila),
      ),
    ),
    httpClientProvider.overrideWithValue(
      MockClient((pedido) async {
        assert(pedido.headers['apikey'] == clavePrueba);
        return switch (pedido.url.toString()) {
          '$urlPrueba/auth/v1/health' => http.Response('{}', respuestaSalud),
          '$urlPrueba/auth/v1/settings' => http.Response(
            '{"external":{"email":true,"google":$googleHabilitado}}',
            200,
          ),
          _ => http.Response('no encontrado', 404),
        };
      }),
    ),
  ],
  child: const SosMascotaApp(),
);

/// Abre el menú ☰ de la pestaña que se está viendo (D88).
Future<void> abrirMenu(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(find.byIcon(Icons.menu).last);
  await tester.pumpAndSettle();
}

/// Baja en el menú ☰ hasta que se vea [objetivo] (el menú es largo: las
/// opciones de abajo se arman recién al llegar).
Future<void> bajarEnMenu(WidgetTester tester, Finder objetivo) async {
  await tester.scrollUntilVisible(
    objetivo,
    200,
    scrollable: find.descendant(
      of: find.byType(Drawer),
      matching: find.byType(Scrollable),
    ),
  );
  await tester.pumpAndSettle();
}

/// Recorridos vistos, en memoria.
class AlmacenRecorridosFalso implements AlmacenRecorridos {
  AlmacenRecorridosFalso({this.todosVistos = false});

  final bool todosVistos;
  final vistos = <PantallaRecorrido>{};

  @override
  Future<bool> visto(PantallaRecorrido pantalla) async =>
      todosVistos || vistos.contains(pantalla);

  @override
  Future<void> marcarVisto(PantallaRecorrido pantalla) async =>
      vistos.add(pantalla);
}

/// Abre Ajustes desde el menú ☰ (arriba a la derecha va el botón ?, D130).
Future<void> abrirAjustesDesdeMenu(WidgetTester tester) async {
  await abrirMenu(tester);
  final ajustes = find.descendant(
    of: find.byType(Drawer),
    matching: find.text('Ajustes'),
  );
  await bajarEnMenu(tester, ajustes);
  await tester.tap(ajustes);
  await tester.pumpAndSettle();
}
