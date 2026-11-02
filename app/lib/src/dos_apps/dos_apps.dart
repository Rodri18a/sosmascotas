import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../router.dart';
import 'otra_app_otro.dart' if (dart.library.js_interop) 'otra_app_web.dart';

/// Dos apps, un proyecto (D129): Huellitas para las personas y Huellitas
/// Comercios para los negocios. Comparten el código y la cuenta; la de
/// comercios entra por `main_comercio.dart`, abre en el panel del negocio y
/// usa el azul de los comercios.
final esAppComercioProvider = Provider<bool>((_) => false);

/// Dónde vive cada app en la web (mismo sitio: comparten la sesión).
abstract final class DireccionesApps {
  static const personas = '/';
  static const comercios = '/comercios/';
}

/// Abre la otra app (en la web, cambiando de dirección). `null` donde
/// todavía no hay otra app instalable (Android y iPhone): ahí el negocio
/// sigue dentro de la misma app. Se reemplaza en las pruebas.
final abrirOtraAppProvider = Provider<void Function(String direccion)?>(
  (_) => abrirOtraApp,
);

/// «Mi negocio» desde la app de las personas: en la web abre Huellitas
/// Comercios; si no, el panel dentro de la misma app.
void irAMiNegocio(BuildContext context, WidgetRef ref) {
  if (ref.read(abrirOtraAppProvider) case final abrir?
      when !ref.read(esAppComercioProvider)) {
    abrir(DireccionesApps.comercios);
  } else {
    context.push(Rutas.negocio);
  }
}

/// Desde el negocio, de vuelta a lo de las personas: en la app de comercios
/// (web) abre Huellitas; si no, el inicio de la misma app.
void irAHuellitas(BuildContext context, WidgetRef ref) {
  if (ref.read(abrirOtraAppProvider) case final abrir?
      when ref.read(esAppComercioProvider)) {
    abrir(DireccionesApps.personas);
  } else {
    context.go(Rutas.inicio);
  }
}
