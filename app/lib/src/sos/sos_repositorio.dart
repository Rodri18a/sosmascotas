import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

/// Motivo por el que no se pudo publicar un SOS.
enum ErrorSos { limiteDiario, datosInvalidos, sinConexion }

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
