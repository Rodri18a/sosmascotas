import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../l10n/l10n.dart';
import '../cuenta/perfil_repositorio.dart';
import '../metricas/metricas.dart';
import 'servicio_ubicacion.dart';

/// Recién activados los avisos: si todavía no tiene zona, explica para qué
/// se usa y, si acepta, pide el permiso. Nunca se pide la ubicación sin
/// contexto (al abrir la app o el mapa).
Future<void> ofrecerZonaAvisos(BuildContext context, WidgetRef ref) async {
  final Perfil? perfil;
  final EstadoUbicacion estado;
  try {
    perfil = await ref.read(perfilProvider.future);
    estado = await ref.read(servicioUbicacionProvider).estado();
  } on Exception catch (e) {
    // Los avisos ya quedaron activados: la zona se puede elegir en Ajustes.
    debugPrint('[ubicacion] No se pudo ofrecer la zona: $e');
    return;
  }
  if (perfil == null || perfil.zonaAvisosEn != null) return;
  if (estado != EstadoUbicacion.sinPedir &&
      estado != EstadoUbicacion.permitida) {
    return;
  }
  if (!context.mounted) return;
  final t = context.t;
  final acepta = await showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.location_on_outlined),
      title: Text(t.ubicacionDialogoTitulo),
      content: Text(t.ubicacionDialogoTexto),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(t.ubicacionAhoraNo),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text(t.ubicacionUsar),
        ),
      ],
    ),
  );
  if ((acepta ?? false) && context.mounted) await activarZona(context, ref);
}

/// Pide el permiso, guarda la zona y avisa cómo quedó.
Future<void> activarZona(BuildContext context, WidgetRef ref) async {
  final mensajero = ScaffoldMessenger.of(context);
  final t = context.t;
  try {
    final estado = await ref.read(servicioUbicacionProvider).activar();
    if (estado == EstadoUbicacion.permitida) {
      ref.read(metricasProvider).track(Eventos.alertZoneSet);
    }
    final mensaje = switch (estado) {
      EstadoUbicacion.permitida => t.ubicacionGuardadaOk,
      EstadoUbicacion.bloqueada => t.ubicacionBloqueada,
      EstadoUbicacion.noDisponible => t.ubicacionNoDisponible,
      _ => null, // Cerró el cartel sin elegir: no insistir.
    };
    if (mensaje != null) {
      // Reemplaza el "¡Listo!" de los avisos, si sigue a la vista.
      mensajero
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(mensaje)));
    }
  } catch (e) {
    // Sin señal de GPS, tiempo agotado o sin conexión con la base.
    debugPrint('[ubicacion] No se pudo guardar la zona: $e');
    mensajero.showSnackBar(SnackBar(content: Text(t.ubicacionError)));
  }
  ref
    ..invalidate(estadoUbicacionProvider)
    ..invalidate(perfilProvider);
}

/// "Zona para avisos" en Ajustes: si está guardada y permite borrarla.
class TileZonaAvisos extends ConsumerWidget {
  const TileZonaAvisos({required this.perfil, super.key});

  final Perfil perfil;

  Future<void> _borrar(BuildContext context, WidgetRef ref) async {
    final mensajero = ScaffoldMessenger.of(context);
    final t = context.t;
    try {
      await ref.read(servicioUbicacionProvider).borrar();
      ref.read(metricasProvider).track(Eventos.alertZoneClear);
      mensajero.showSnackBar(SnackBar(content: Text(t.ubicacionBorradaOk)));
    } on Exception catch (e) {
      debugPrint('[ubicacion] No se pudo borrar la zona: $e');
      mensajero.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
    }
    ref.invalidate(perfilProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(estadoUbicacionProvider).value;
    if (estado == null || estado == EstadoUbicacion.sinConfigurar) {
      return const SizedBox.shrink();
    }
    final t = context.t;
    final guardada = perfil.zonaAvisosEn != null;
    final puedePedir =
        estado == EstadoUbicacion.sinPedir ||
        estado == EstadoUbicacion.permitida;
    return ListTile(
      leading: const Icon(Icons.location_on_outlined),
      title: Text(t.ubicacionTitulo),
      subtitle: Text(switch (estado) {
        _ when guardada => t.ubicacionGuardada,
        EstadoUbicacion.bloqueada => t.ubicacionBloqueada,
        EstadoUbicacion.noDisponible => t.ubicacionNoDisponible,
        _ => t.ubicacionSinGuardar,
      }),
      isThreeLine: true,
      trailing: guardada
          ? TextButton(
              onPressed: () => _borrar(context, ref),
              child: Text(t.ubicacionBorrar),
            )
          : puedePedir
          ? TextButton(
              onPressed: () => activarZona(context, ref),
              child: Text(t.ubicacionUsar),
            )
          : null,
    );
  }
}
