import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../l10n/l10n.dart';
import '../metricas/metricas.dart';
import '../router.dart';
import 'otra_app_otro.dart' if (dart.library.js_interop) 'otra_app_web.dart';

/// Dos apps, un proyecto (D129): Huellitas para las personas y Huellitas
/// Comercios para los negocios. Comparten el código y la cuenta, pero se
/// manejan por separado (D143): la de comercios entra por
/// `main_comercio.dart`, abre en el panel del negocio y usa el azul de los
/// comercios; desde ninguna de las dos se pasa a la otra.
final esAppComercioProvider = Provider<bool>((_) => false);

/// Dónde vive cada app en la web (mismo sitio: comparten la sesión).
abstract final class DireccionesApps {
  static const personas = '/';
  static const comercios = '/comercios/';
}

/// Abre la otra app (en la web, cambiando de dirección). `null` donde
/// todavía no hay otra app instalable (Android y iPhone). Se reemplaza en las
/// pruebas.
final abrirOtraAppProvider = Provider<void Function(String direccion)?>(
  (_) => abrirOtraApp,
);

/// «Mi negocio» y «¿Es tu negocio?» desde Huellitas: explica que eso se hace
/// en Huellitas Comercios y, donde se puede, la abre en [ruta] (D143). En
/// Huellitas Comercios abre la ruta ahí mismo.
Future<void> irAMiNegocio(
  BuildContext context,
  WidgetRef ref, {
  String ruta = Rutas.negocio,
}) async {
  if (ref.read(esAppComercioProvider)) {
    await context.push(ruta);
    return;
  }
  final t = context.t;
  final abrir = ref.read(abrirOtraAppProvider);
  ref.read(metricasProvider).track(Eventos.appComerciosAviso);
  final si = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.storefront_outlined),
      title: Text(t.appComerciosTitulo),
      content: Text(
        abrir == null
            ? '${t.appComerciosTexto}\n\n${t.appComerciosProximamente}'
            : t.appComerciosTexto,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(abrir == null ? t.instalarEntendido : t.cancelar),
        ),
        if (abrir != null)
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.appComerciosAbrir),
          ),
      ],
    ),
  );
  if (si == true && abrir != null) {
    // Las rutas de la otra app cuelgan de su dirección: /comercios/negocio…
    abrir('${DireccionesApps.comercios}${ruta.substring(1)}');
  }
}
