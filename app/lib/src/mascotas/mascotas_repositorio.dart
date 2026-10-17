import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';
import '../utiles/respaldo.dart';

/// Mascotas del dueño con sesión. Se reemplaza en las pruebas.
abstract interface class MascotasRepositorio {
  Future<List<Mascota>> misMascotas();

  /// Crea la mascota y devuelve la versión guardada (con su id).
  Future<Mascota> crear(Mascota mascota);

  Future<Mascota> actualizar(Mascota mascota);

  Future<void> borrar(String id);

  /// Sube una foto ya preparada (sin EXIF) y devuelve su ruta en el bucket.
  Future<String> subirFoto(Uint8List jpeg);

  /// Enlace público de una foto (o `null` si no hay).
  String? urlFoto(String? ruta);
}

class SupabaseMascotasRepositorio implements MascotasRepositorio {
  SupabaseMascotasRepositorio(this._cliente);

  final SupabaseClient _cliente;

  static const _bucket = 'pet-photos';

  SupabaseQueryBuilder get _pets => _cliente.from('pets');

  @override
  Future<List<Mascota>> misMascotas() async {
    // En el orden en que se cargaron (`order` es descendente si no se aclara).
    final filas = await _pets.select().order('created_at', ascending: true);
    return filas.map(Mascota.fromJson).toList();
  }

  @override
  Future<Mascota> crear(Mascota mascota) async =>
      Mascota.fromJson(await _pets.insert(mascota.toJson()).select().single());

  @override
  Future<Mascota> actualizar(Mascota mascota) async => Mascota.fromJson(
    await _pets.update(mascota.toJson()).eq('id', mascota.id).select().single(),
  );

  @override
  Future<void> borrar(String id) async {
    final fila = await _pets
        .delete()
        .eq('id', id)
        .select('photo_path')
        .maybeSingle();
    final foto = fila?['photo_path'] as String?;
    if (foto != null) await _cliente.storage.from(_bucket).remove([foto]);
  }

  @override
  Future<String> subirFoto(Uint8List jpeg) async {
    final usuario = _cliente.auth.currentUser;
    if (usuario == null) throw StateError('Hace falta una sesión');
    // Carpeta del usuario (lo exige la política) y nombre al azar.
    final ruta = '${usuario.id}/${generarAnonId()}.jpg';
    await _cliente.storage
        .from(_bucket)
        .uploadBinary(
          ruta,
          jpeg,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return ruta;
  }

  @override
  String? urlFoto(String? ruta) =>
      ruta == null ? null : _cliente.storage.from(_bucket).getPublicUrl(ruta);
}

class MascotasSinConfigurar implements MascotasRepositorio {
  const MascotasSinConfigurar();

  @override
  Future<List<Mascota>> misMascotas() async => const [];

  @override
  Future<Mascota> crear(Mascota mascota) async => mascota;

  @override
  Future<Mascota> actualizar(Mascota mascota) async => mascota;

  @override
  Future<void> borrar(String id) async {}

  @override
  Future<String> subirFoto(Uint8List jpeg) =>
      throw StateError('Supabase no está configurado');

  @override
  String? urlFoto(String? ruta) => null;
}

final mascotasRepositorioProvider = Provider<MascotasRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const MascotasSinConfigurar()
      : SupabaseMascotasRepositorio(cliente);
});

/// Mascotas de la persona con sesión (vacío si es visitante).
final misMascotasProvider = FutureProvider<List<Mascota>>((ref) async {
  final usuario = ref.watch(usuarioActualProvider).value;
  if (usuario == null) return const [];
  final repo = ref.watch(mascotasRepositorioProvider);
  return conRespaldo(
    ref,
    clave: 'mascotas',
    pedir: repo.misMascotas,
    aJson: (lista) => [
      for (final m in lista) {...m.toJson(), 'id': m.id},
    ],
    deJson: (json) => listaJson(json).map(Mascota.fromJson).toList(),
  );
});

/// Una mascota propia por id (`null` si no existe o no es mía).
final mascotaProvider = Provider.family<AsyncValue<Mascota?>, String>(
  (ref, id) => ref
      .watch(misMascotasProvider)
      .whenData((lista) => lista.where((m) => m.id == id).firstOrNull),
);
