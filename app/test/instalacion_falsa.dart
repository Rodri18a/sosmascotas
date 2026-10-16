import 'dart:async';

import 'package:sosmascota/src/instalar/servicio_instalacion.dart';

/// Navegador falso: decide si hay aviso, si es iPhone y qué elige la persona.
class InstalacionFalsa implements ServicioInstalacion {
  InstalacionFalsa({
    this.yaInstalada = false,
    this.puedeMostrarAviso = false,
    this.esIphone = false,
    this.acepta = true,
  });

  @override
  bool yaInstalada;

  @override
  bool puedeMostrarAviso;

  @override
  bool esIphone;

  bool acepta;
  int avisosMostrados = 0;
  final _cambios = StreamController<void>.broadcast();

  /// Como el evento `appinstalled` (por ejemplo, desde el menú del navegador).
  void instalarDesdeElNavegador() {
    yaInstalada = true;
    puedeMostrarAviso = false;
    _cambios.add(null);
  }

  @override
  Future<bool> mostrarAviso() async {
    avisosMostrados++;
    puedeMostrarAviso = false;
    if (acepta) yaInstalada = true;
    return acepta;
  }

  @override
  Stream<void> get cambios => _cambios.stream;
}

class AlmacenInstalacionFalso implements AlmacenInstalacion {
  AlmacenInstalacionFalso({this.aperturas = 0, this.estaDescartada = false});

  int aperturas;
  bool estaDescartada;

  @override
  Future<int> sumarApertura() async => ++aperturas;

  @override
  Future<bool> descartada() async => estaDescartada;

  @override
  Future<void> descartar() async => estaDescartada = true;
}
