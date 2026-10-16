import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sosmascota/src/app.dart';
import 'package:sosmascota/src/avisos/avisos_repositorio.dart';
import 'package:sosmascota/src/ayuda/ayuda_repositorio.dart';
import 'package:sosmascota/src/comercios/comercios_repositorio.dart';
import 'package:sosmascota/src/config/env_provider.dart';
import 'package:sosmascota/src/config/supabase_providers.dart';
import 'package:sosmascota/src/cuenta/perfil_repositorio.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/fotos/selector_foto.dart';
import 'package:sosmascota/src/funcionalidades/funcionalidades_activas.dart';
import 'package:sosmascota/src/instalar/servicio_instalacion.dart';
import 'package:sosmascota/src/mapa/mapa_vista.dart';
import 'package:sosmascota/src/mascotas/catalogo.dart';
import 'package:sosmascota/src/mascotas/mascotas_repositorio.dart';
import 'package:sosmascota/src/metricas/metricas.dart';
import 'package:sosmascota/src/push/servicio_push.dart';
import 'package:sosmascota/src/qr/qr_repositorio.dart';
import 'package:sosmascota/src/sos/sos_repositorio.dart';
import 'package:sosmascota/src/theme/tema_elegido.dart';
import 'package:sosmascota/src/ubicacion/servicio_ubicacion.dart';
import 'package:sosmascota/src/utiles/enlaces.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'avisos_falsos.dart';
import 'ayuda_falsa.dart';
import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'instalacion_falsa.dart';
import 'mapa_falso.dart';
import 'mascotas_falsas.dart';
import 'perfil_falso.dart';
import 'qr_falso.dart';
import 'sos_falso.dart';
import 'tema_falso.dart';

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
  SelectorFoto? selectorFoto,
  QrRepositorio? qr,
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
  String urlPublica = 'https://sosmascotas.uy',
}) => ProviderScope(
  overrides: [
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
    catalogoRepositorioProvider.overrideWithValue(CatalogoFalso()),
    mascotasRepositorioProvider.overrideWithValue(mascotas ?? MascotasFalsas()),
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
