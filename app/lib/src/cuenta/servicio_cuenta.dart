import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';

/// Persona con sesión iniciada.
@immutable
class Usuario {
  const Usuario({required this.id, this.email});

  final String id;
  final String? email;

  @override
  bool operator ==(Object other) =>
      other is Usuario && other.id == id && other.email == email;

  @override
  int get hashCode => Object.hash(id, email);
}

/// Motivos por los que puede fallar una acción de la cuenta.
enum ErrorCuenta {
  demasiadosIntentos,
  codigoInvalido,
  sinConexion,
  noConfigurado,
  desconocido,
}

class CuentaException implements Exception {
  const CuentaException(this.tipo, [this.detalle]);

  final ErrorCuenta tipo;
  final String? detalle;

  @override
  String toString() => 'CuentaException($tipo, $detalle)';
}

/// Login y sesión. Se reemplaza en las pruebas por una versión falsa.
abstract interface class ServicioCuenta {
  Usuario? get actual;

  /// Emite el usuario actual cada vez que cambia la sesión.
  Stream<Usuario?> get cambios;

  /// Envía un correo con enlace (y código, cuando haya proveedor de correo).
  Future<void> enviarCodigo(String email, {String? redirigirA});

  Future<void> verificarCodigo(String email, String codigo);

  Future<void> ingresarConGoogle({String? redirigirA});

  Future<void> salir();

  /// Borra la cuenta y todos sus datos (Edge Function `delete-account`).
  Future<void> borrarCuenta();
}

class SupabaseServicioCuenta implements ServicioCuenta {
  SupabaseServicioCuenta(this._cliente);

  final SupabaseClient _cliente;

  GoTrueClient get _auth => _cliente.auth;

  static Usuario? _aUsuario(User? u) =>
      u == null ? null : Usuario(id: u.id, email: u.email);

  @override
  Usuario? get actual => _aUsuario(_auth.currentUser);

  @override
  Stream<Usuario?> get cambios =>
      _auth.onAuthStateChange.map((e) => _aUsuario(e.session?.user)).distinct();

  @override
  Future<void> enviarCodigo(String email, {String? redirigirA}) => _traducir(
    () => _auth.signInWithOtp(email: email, emailRedirectTo: redirigirA),
  );

  @override
  Future<void> verificarCodigo(String email, String codigo) => _traducir(
    () => _auth.verifyOTP(email: email, token: codigo, type: OtpType.email),
  );

  @override
  Future<void> ingresarConGoogle({String? redirigirA}) => _traducir(
    () => _auth.signInWithOAuth(OAuthProvider.google, redirectTo: redirigirA),
  );

  @override
  Future<void> salir() => _traducir(_auth.signOut);

  @override
  Future<void> borrarCuenta() async {
    try {
      await _cliente.functions.invoke('delete-account');
    } on FunctionException catch (e) {
      throw CuentaException(ErrorCuenta.desconocido, '${e.status}');
    } on Exception catch (e) {
      throw CuentaException(ErrorCuenta.sinConexion, e.toString());
    }
    // La cuenta ya no existe: cerrar la sesión local.
    await _traducir(() => _auth.signOut(scope: SignOutScope.local));
  }

  static Future<void> _traducir(Future<Object?> Function() accion) async {
    try {
      await accion();
    } on AuthException catch (e) {
      throw CuentaException(_tipoDeError(e), e.message);
    } on Exception catch (e) {
      throw CuentaException(ErrorCuenta.sinConexion, e.toString());
    }
  }

  static ErrorCuenta _tipoDeError(AuthException e) {
    final codigo = e.code ?? '';
    if (e.statusCode == '429' || codigo.contains('rate_limit')) {
      return ErrorCuenta.demasiadosIntentos;
    }
    if (codigo == 'otp_expired' || codigo == 'invalid_credentials') {
      return ErrorCuenta.codigoInvalido;
    }
    if (e is AuthRetryableFetchException) return ErrorCuenta.sinConexion;
    return ErrorCuenta.desconocido;
  }
}

/// Para desarrollo sin Supabase configurado: nadie puede ingresar.
class ServicioCuentaSinConfigurar implements ServicioCuenta {
  const ServicioCuentaSinConfigurar();

  @override
  Usuario? get actual => null;

  @override
  Stream<Usuario?> get cambios => const Stream.empty();

  static Never _falla() =>
      throw const CuentaException(ErrorCuenta.noConfigurado);

  @override
  Future<void> enviarCodigo(String email, {String? redirigirA}) async =>
      _falla();

  @override
  Future<void> verificarCodigo(String email, String codigo) async => _falla();

  @override
  Future<void> ingresarConGoogle({String? redirigirA}) async => _falla();

  @override
  Future<void> salir() async {}

  @override
  Future<void> borrarCuenta() async => _falla();
}

final servicioCuentaProvider = Provider<ServicioCuenta>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const ServicioCuentaSinConfigurar()
      : SupabaseServicioCuenta(cliente);
});

/// Usuario con sesión, o `null` si es visitante.
final usuarioActualProvider = StreamProvider<Usuario?>((ref) async* {
  final servicio = ref.watch(servicioCuentaProvider);
  yield servicio.actual;
  yield* servicio.cambios;
});

/// ¿Hay sesión iniciada? Mientras carga, se considera visitante.
final conectadoProvider = Provider<bool>(
  (ref) => ref.watch(usuarioActualProvider).value != null,
);
