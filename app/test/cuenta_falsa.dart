import 'dart:async';

import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';

/// Servicio de cuenta en memoria para las pruebas (sin red).
class ServicioCuentaFalso implements ServicioCuenta {
  ServicioCuentaFalso({Usuario? conectado}) : _actual = conectado;

  final _cambios = StreamController<Usuario?>.broadcast();
  Usuario? _actual;

  final correosEnviados = <String>[];
  final redirecciones = <String?>[];
  String codigoCorrecto = '123456';
  ErrorCuenta? fallarCon;
  int ingresosConGoogle = 0;

  void conectar(Usuario? usuario) {
    _actual = usuario;
    _cambios.add(usuario);
  }

  void _quizasFallar() {
    if (fallarCon case final tipo?) throw CuentaException(tipo);
  }

  @override
  Usuario? get actual => _actual;

  @override
  Stream<Usuario?> get cambios => _cambios.stream;

  @override
  Future<void> enviarCodigo(String email, {String? redirigirA}) async {
    _quizasFallar();
    correosEnviados.add(email);
    redirecciones.add(redirigirA);
  }

  @override
  Future<void> verificarCodigo(String email, String codigo) async {
    _quizasFallar();
    if (codigo != codigoCorrecto) {
      throw const CuentaException(ErrorCuenta.codigoInvalido);
    }
    conectar(Usuario(id: 'usuario-1', email: email));
  }

  @override
  Future<void> ingresarConGoogle({String? redirigirA}) async {
    _quizasFallar();
    ingresosConGoogle++;
  }

  @override
  Future<void> salir() async => conectar(null);
}
