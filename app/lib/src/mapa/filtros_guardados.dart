import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// «Mis filtros» del mapa (plan Pro, 2.11, D112): se guardan en el
/// dispositivo, por cuenta, y el mapa abre con ellos.
abstract interface class AlmacenFiltros {
  Future<FiltrosMapa?> leer(String cuenta);
  Future<void> guardar(String cuenta, FiltrosMapa filtros);
}

class AlmacenFiltrosLocal implements AlmacenFiltros {
  const AlmacenFiltrosLocal();

  static String _clave(String cuenta) => 'mapa.filtros.$cuenta';

  @override
  Future<FiltrosMapa?> leer(String cuenta) async {
    final texto = (await SharedPreferences.getInstance()).getString(
      _clave(cuenta),
    );
    if (texto == null) return null;
    try {
      return FiltrosMapa.fromJson(
        (jsonDecode(texto) as Map<String, dynamic>).cast(),
      );
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> guardar(String cuenta, FiltrosMapa filtros) async =>
      (await SharedPreferences.getInstance()).setString(
        _clave(cuenta),
        jsonEncode(filtros.toJson()),
      );
}

final almacenFiltrosProvider = Provider<AlmacenFiltros>(
  (ref) => const AlmacenFiltrosLocal(),
);
