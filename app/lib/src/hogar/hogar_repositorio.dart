import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/env_provider.dart';
import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

/// Por qué no se pudo usar una invitación.
enum ErrorInvitacion { noSirve, propia, yaSos, lleno, sinConexion }

class InvitacionFallida implements Exception {
  const InvitacionFallida(this.motivo);
  final ErrorInvitacion motivo;
}

/// Hogar compartido (etapa 1.6, D69). Se reemplaza en las pruebas.
abstract interface class HogarRepositorio {
  /// Personas de los hogares de los que soy parte (incluido el dueño).
  Future<List<Integrante>> integrantes();

  /// Crea (si hace falta) mi hogar y una invitación. Devuelve el código.
  /// Con [diasCuidador] y [mascotas]: invitación de cuidador temporal
  /// (1.6.4, D72), con acceso solo a esas mascotas durante esos días.
  Future<String> invitar({int? diasCuidador, List<String>? mascotas});

  /// Usa un código de invitación. Lanza [InvitacionFallida].
  Future<void> unirme(String codigo);

  /// Saca a [usuarioId] de [hogarId] (dueño) o me voy (si soy yo).
  Future<void> sacar(String hogarId, String usuarioId);
}

class SupabaseHogarRepositorio implements HogarRepositorio {
  SupabaseHogarRepositorio(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<List<Integrante>> integrantes() async {
    final filas = await _cliente.rpc<List<dynamic>>(
      'integrantes_de_mis_hogares',
    );
    return [
      for (final f in filas)
        Integrante.fromJson((f as Map).cast<String, Object?>()),
    ];
  }

  @override
  Future<String> invitar({int? diasCuidador, List<String>? mascotas}) =>
      _cliente.rpc<String>(
        'invitar_al_hogar',
        params: diasCuidador == null
            ? const {}
            : {
                'p_rol': 'temp_caregiver',
                'p_dias': diasCuidador,
                'p_mascotas': mascotas,
              },
      );

  @override
  Future<void> unirme(String codigo) async {
    try {
      await _cliente.rpc<String>(
        'unirme_al_hogar',
        params: {'p_codigo': codigo},
      );
    } on PostgrestException catch (e) {
      throw InvitacionFallida(switch (e.code) {
        '22023' => ErrorInvitacion.propia,
        '23505' => ErrorInvitacion.yaSos,
        '54000' => ErrorInvitacion.lleno,
        _ => ErrorInvitacion.noSirve,
      });
    } on Exception {
      throw const InvitacionFallida(ErrorInvitacion.sinConexion);
    }
  }

  @override
  Future<void> sacar(String hogarId, String usuarioId) => _cliente
      .from('household_members')
      .delete()
      .eq('household_id', hogarId)
      .eq('user_id', usuarioId);
}

class HogarSinConfigurar implements HogarRepositorio {
  const HogarSinConfigurar();

  @override
  Future<List<Integrante>> integrantes() async => const [];

  @override
  Future<String> invitar({int? diasCuidador, List<String>? mascotas}) =>
      throw StateError('Supabase no está configurado');

  @override
  Future<void> unirme(String codigo) async =>
      throw const InvitacionFallida(ErrorInvitacion.sinConexion);

  @override
  Future<void> sacar(String hogarId, String usuarioId) async {}
}

final hogarRepositorioProvider = Provider<HogarRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const HogarSinConfigurar()
      : SupabaseHogarRepositorio(cliente);
});

final integrantesProvider = FutureProvider<List<Integrante>>((ref) async {
  final usuario = ref.watch(usuarioActualProvider).value;
  if (usuario == null) return const [];
  return ref.watch(hogarRepositorioProvider).integrantes();
});

/// Nombre visible de cada persona de mis hogares (para "Marcada por Ana").
final nombresDelHogarProvider = Provider<Map<String, String>>((ref) {
  final lista = ref.watch(integrantesProvider).value ?? const <Integrante>[];
  return {for (final i in lista) i.usuarioId: ?i.nombre};
});

/// Dirección de la app para armar el enlace de invitación: en la web, la
/// misma desde donde se abrió; si no, la web pública configurada.
final urlAppProvider = Provider<String>(
  (ref) => kIsWeb ? Uri.base.origin : ref.watch(appEnvProvider).urlPublica,
);

String enlaceInvitacion(String base, String codigo) =>
    '${base.replaceAll(RegExp(r'/+$'), '')}/unirme/$codigo';
