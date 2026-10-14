import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

/// Motivo por el que no se pudo publicar un SOS.
enum ErrorSos { limiteDiario, datosInvalidos, demasiadosAvisos, sinConexion }

class SosException implements Exception {
  const SosException(this.tipo);

  final ErrorSos tipo;
}

/// Reportes SOS. Se reemplaza en las pruebas.
abstract interface class SosRepositorio {
  /// Sube una foto ya preparada (sin EXIF). Devuelve `sos-photos/<usuario>/<archivo>`.
  Future<String> subirFoto(Uint8List jpeg);

  /// Publica el SOS y devuelve su id.
  Future<String> crear(NuevoSos sos);

  Future<List<MiSos>> misSos();

  /// Pines de los SOS activos en la zona (datos mínimos).
  Future<List<Pin>> enZona(Limites zona);

  /// SOS activos más cercanos a [punto] (hasta 50 km).
  Future<List<SosResumen>> cercanos(Punto punto);

  /// Detalle público (`null` si no existe o está oculto).
  Future<SosDetalle?> detalle(String id);

  /// "Avisar al dueño" desde la app (con sesión: no hace falta anti-bots).
  Future<void> avisarAlDueno({
    required String sosId,
    required String mensaje,
    required String nombre,
    required String contacto,
  });

  /// El autor cierra su reporte: ¡apareció! ([resuelto] = true) o archivado.
  Future<void> cerrar(String id, {required bool resuelto});

  /// WhatsApp directo opcional en un reporte propio (desactivado por defecto).
  Future<void> mostrarWhatsapp(
    String sosId, {
    required String? numero,
    required bool activo,
  });

  /// Reporta el SOS a moderación (con 3 personas distintas se oculta solo).
  /// Devuelve `false` si esta persona ya lo había reportado.
  Future<bool> reportarContenido(String sosId, {required String motivo});

  /// Enlace público de una foto guardada como `bucket/usuario/archivo`.
  String? urlFoto(String? ruta);
}

class SupabaseSosRepositorio implements SosRepositorio {
  SupabaseSosRepositorio(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<String> subirFoto(Uint8List jpeg) async {
    final usuario = _cliente.auth.currentUser;
    if (usuario == null) throw StateError('Hace falta una sesión');
    final ruta = '${usuario.id}/${generarAnonId()}.jpg';
    await _cliente.storage
        .from('sos-photos')
        .uploadBinary(
          ruta,
          jpeg,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return 'sos-photos/$ruta';
  }

  @override
  Future<String> crear(NuevoSos sos) async {
    try {
      return await _cliente.rpc<String>(
        'crear_sos',
        params: {'p': sos.toJson()},
      );
    } on PostgrestException catch (e) {
      throw SosException(
        e.message.contains('limite_diario')
            ? ErrorSos.limiteDiario
            : ErrorSos.datosInvalidos,
      );
    } on Exception {
      throw const SosException(ErrorSos.sinConexion);
    }
  }

  @override
  Future<List<MiSos>> misSos() async {
    final filas = await _cliente.rpc<List<dynamic>>('mis_sos');
    return filas.cast<Map<String, dynamic>>().map(MiSos.fromJson).toList();
  }

  @override
  Future<List<Pin>> enZona(Limites zona) async {
    final filas = await _cliente.rpc<List<dynamic>>(
      'sos_en_zona',
      params: {
        'p_min_lat': zona.minLat,
        'p_min_lng': zona.minLng,
        'p_max_lat': zona.maxLat,
        'p_max_lng': zona.maxLng,
      },
    );
    return filas.cast<Map<String, dynamic>>().map(pinDeSos).toList();
  }

  @override
  Future<List<SosResumen>> cercanos(Punto punto) async {
    final filas = await _cliente.rpc<List<dynamic>>(
      'sos_cercanos',
      params: {'p_lat': punto.lat, 'p_lng': punto.lng},
    );
    return filas.cast<Map<String, dynamic>>().map(SosResumen.fromJson).toList();
  }

  @override
  Future<SosDetalle?> detalle(String id) async {
    final datos = await _cliente.rpc<Map<String, dynamic>>(
      'sos_publico',
      params: {'p_id': id},
    );
    return datos['status'] == 'not_found' ? null : SosDetalle.fromJson(datos);
  }

  @override
  Future<void> avisarAlDueno({
    required String sosId,
    required String mensaje,
    required String nombre,
    required String contacto,
  }) async {
    try {
      await _cliente.functions.invoke(
        'owner-alert',
        body: {
          'target_type': 'sos',
          'report_id': sosId,
          'message': mensaje,
          'sender_name': nombre,
          'sender_contact': contacto,
          'consent': true,
        },
      );
    } on FunctionException catch (e) {
      throw SosException(
        e.status == 429 ? ErrorSos.demasiadosAvisos : ErrorSos.datosInvalidos,
      );
    } on Exception {
      throw const SosException(ErrorSos.sinConexion);
    }
  }

  @override
  Future<void> cerrar(String id, {required bool resuelto}) =>
      _cliente.rpc<void>(
        'cerrar_sos',
        params: {'p_id': id, 'p_estado': resuelto ? 'resolved' : 'archived'},
      );

  @override
  Future<void> mostrarWhatsapp(
    String sosId, {
    required String? numero,
    required bool activo,
  }) async {
    if (activo) {
      await _cliente.rpc<void>(
        'guardar_mi_whatsapp',
        params: {'p_whatsapp': numero},
      );
    }
    await _cliente.rpc<void>(
      'activar_whatsapp_en_sos',
      params: {'p_sos_id': sosId, 'p_activo': activo},
    );
  }

  @override
  Future<bool> reportarContenido(
    String sosId, {
    required String motivo,
  }) async {
    try {
      await _cliente.from('flags').insert({
        'target_type': 'sos',
        'target_id': sosId,
        'reason': motivo,
      });
      return true;
    } on PostgrestException catch (e) {
      // 23505: ya existe el reporte de esta persona (unique).
      if (e.code == '23505') return false;
      throw const SosException(ErrorSos.datosInvalidos);
    } on Exception {
      throw const SosException(ErrorSos.sinConexion);
    }
  }

  @override
  String? urlFoto(String? ruta) {
    if (ruta == null) return null;
    final corte = ruta.indexOf('/');
    if (corte <= 0) return null;
    return _cliente.storage
        .from(ruta.substring(0, corte))
        .getPublicUrl(ruta.substring(corte + 1));
  }
}

class SosSinConfigurar implements SosRepositorio {
  const SosSinConfigurar();

  @override
  Future<String> subirFoto(Uint8List jpeg) =>
      throw const SosException(ErrorSos.sinConexion);

  @override
  Future<String> crear(NuevoSos sos) =>
      throw const SosException(ErrorSos.sinConexion);

  @override
  Future<List<MiSos>> misSos() async => const [];

  @override
  Future<List<Pin>> enZona(Limites zona) async => const [];

  @override
  Future<List<SosResumen>> cercanos(Punto punto) async => const [];

  @override
  Future<SosDetalle?> detalle(String id) async => null;

  @override
  Future<void> avisarAlDueno({
    required String sosId,
    required String mensaje,
    required String nombre,
    required String contacto,
  }) => throw const SosException(ErrorSos.sinConexion);

  @override
  Future<void> cerrar(String id, {required bool resuelto}) async {}

  @override
  Future<void> mostrarWhatsapp(
    String sosId, {
    required String? numero,
    required bool activo,
  }) async {}

  @override
  Future<bool> reportarContenido(String sosId, {required String motivo}) =>
      throw const SosException(ErrorSos.sinConexion);

  @override
  String? urlFoto(String? ruta) => null;
}

final sosRepositorioProvider = Provider<SosRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const SosSinConfigurar()
      : SupabaseSosRepositorio(cliente);
});

final misSosProvider = FutureProvider<List<MiSos>>((ref) async {
  if (ref.watch(usuarioActualProvider).value == null) return const [];
  return ref.watch(sosRepositorioProvider).misSos();
});

/// Punto de referencia para "cerca tuyo". Hasta que la persona comparta su zona
/// (paso 0.6.2), es el centro de Pando.
final miZonaProvider = Provider<Punto>((ref) => centroPando);

final sosCercanosProvider = FutureProvider<List<SosResumen>>(
  (ref) =>
      ref.watch(sosRepositorioProvider).cercanos(ref.watch(miZonaProvider)),
);

final sosDetalleProvider = FutureProvider.family<SosDetalle?, String>(
  (ref, id) => ref.watch(sosRepositorioProvider).detalle(id),
);
