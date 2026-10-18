import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Ingreso al portal con código o enlace por correo (la misma cuenta que en
/// la app). Se reemplaza en las pruebas.
abstract interface class SesionAdmin {
  /// Correo de la sesión actual (`null` sin sesión).
  String? get correo;

  Stream<String?> get cambios;

  Future<void> enviarCodigo(String correo);

  Future<void> verificar(String correo, String codigo);

  Future<void> salir();
}

class SupabaseSesionAdmin implements SesionAdmin {
  SupabaseSesionAdmin(this._auth);

  final GoTrueClient _auth;

  @override
  String? get correo => _auth.currentUser?.email;

  @override
  Stream<String?> get cambios =>
      _auth.onAuthStateChange.map((e) => e.session?.user.email);

  @override
  Future<void> enviarCodigo(String correo) => _auth.signInWithOtp(
    email: correo.trim(),
    // Si el correo trae un enlace, vuelve al portal (no a la app).
    emailRedirectTo: kIsWeb ? Uri.base.origin : null,
    shouldCreateUser: false,
  );

  @override
  Future<void> verificar(String correo, String codigo) => _auth.verifyOTP(
    email: correo.trim(),
    token: codigo.trim(),
    type: OtpType.email,
  );

  @override
  Future<void> salir() => _auth.signOut();
}

final sesionProvider = Provider<SesionAdmin>(
  (ref) => throw UnimplementedError('Falta configurar la sesión'),
);

final correoProvider = StreamProvider<String?>((ref) async* {
  final sesion = ref.watch(sesionProvider);
  yield sesion.correo;
  yield* sesion.cambios;
});
