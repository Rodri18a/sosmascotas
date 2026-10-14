import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../legal/legal.dart';
import 'servicio_cuenta.dart';

/// Lectura y edición del perfil propio. Se reemplaza en las pruebas.
abstract interface class PerfilRepositorio {
  Future<Perfil?> obtener(String id);

  Future<void> aceptarTerminos(String id, String version);

  Future<void> actualizar(String id, {String? nombre, int? radioAvisosKm});
}

class SupabasePerfilRepositorio implements PerfilRepositorio {
  SupabasePerfilRepositorio(this._cliente);

  final SupabaseClient _cliente;

  SupabaseQueryBuilder get _perfiles => _cliente.from('profiles');

  @override
  Future<Perfil?> obtener(String id) async {
    final fila = await _perfiles.select().eq('id', id).maybeSingle();
    return fila == null ? null : Perfil.fromJson(fila);
  }

  @override
  Future<void> aceptarTerminos(String id, String version) => _perfiles
      .update({
        'terms_version': version,
        'terms_accepted_at': DateTime.now().toUtc().toIso8601String(),
      })
      .eq('id', id);

  @override
  Future<void> actualizar(String id, {String? nombre, int? radioAvisosKm}) =>
      _perfiles
          .update({'display_name': ?nombre, 'alert_radius_km': ?radioAvisosKm})
          .eq('id', id);
}

/// Sin Supabase configurado no hay perfiles.
class PerfilRepositorioSinConfigurar implements PerfilRepositorio {
  const PerfilRepositorioSinConfigurar();

  @override
  Future<Perfil?> obtener(String id) async => null;

  @override
  Future<void> aceptarTerminos(String id, String version) async {}

  @override
  Future<void> actualizar(
    String id, {
    String? nombre,
    int? radioAvisosKm,
  }) async {}
}

final perfilRepositorioProvider = Provider<PerfilRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const PerfilRepositorioSinConfigurar()
      : SupabasePerfilRepositorio(cliente);
});

/// Perfil de la persona con sesión (`null` si es visitante).
final perfilProvider = FutureProvider<Perfil?>((ref) async {
  final usuario = ref.watch(usuarioActualProvider).value;
  if (usuario == null) return null;
  return ref.watch(perfilRepositorioProvider).obtener(usuario.id);
});

/// ¿Tiene sesión pero todavía no aceptó la versión vigente de los términos?
final necesitaConsentimientoProvider = Provider<bool>((ref) {
  final perfil = ref.watch(perfilProvider).value;
  return perfil != null && !perfil.aceptoTerminos(versionTerminos);
});
