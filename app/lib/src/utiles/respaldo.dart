import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../cuenta/servicio_cuenta.dart';

/// Copia local de lo último que se leyó de la base, para ver la ficha, la
/// libreta, los recordatorios y el QR sin internet (paso 1.5.6). Se guarda
/// por cuenta y se borra al cerrar sesión. Se reemplaza en las pruebas.
abstract interface class AlmacenRespaldo {
  Future<String?> leer(String clave);

  Future<void> guardar(String clave, String valor);

  Future<void> borrarTodo();
}

class AlmacenRespaldoLocal implements AlmacenRespaldo {
  const AlmacenRespaldoLocal();

  static const _prefijo = 'respaldo.';

  @override
  Future<String?> leer(String clave) async =>
      (await SharedPreferences.getInstance()).getString('$_prefijo$clave');

  @override
  Future<void> guardar(String clave, String valor) async =>
      (await SharedPreferences.getInstance()).setString(
        '$_prefijo$clave',
        valor,
      );

  @override
  Future<void> borrarTodo() async {
    final prefs = await SharedPreferences.getInstance();
    for (final clave in prefs.getKeys().where((c) => c.startsWith(_prefijo))) {
      await prefs.remove(clave);
    }
  }
}

final almacenRespaldoProvider = Provider<AlmacenRespaldo>(
  (ref) => const AlmacenRespaldoLocal(),
);

/// Pide [pedir]; si sale bien, guarda una copia; si falla (sin internet),
/// devuelve la última copia de esa cuenta o, si no hay, el error.
Future<T> conRespaldo<T>(
  Ref ref, {
  required String clave,
  required Future<T> Function() pedir,
  required Object? Function(T valor) aJson,
  required T Function(Object? json) deJson,
}) async {
  final almacen = ref.read(almacenRespaldoProvider);
  final usuario = ref.read(usuarioActualProvider).value?.id ?? 'visitante';
  final claveCompleta = '$usuario/$clave';
  try {
    final valor = await pedir();
    await almacen.guardar(claveCompleta, jsonEncode(aJson(valor)));
    return valor;
  } on Exception {
    final copia = await almacen.leer(claveCompleta);
    if (copia == null) rethrow;
    return deJson(jsonDecode(copia));
  }
}

/// Al cerrar sesión se borran las copias (un celular compartido no muestra
/// los datos de otra cuenta). Lo escucha la raíz de la app.
final limpiezaRespaldoProvider = Provider<void>((ref) {
  ref.listen(usuarioActualProvider, (antes, ahora) {
    final habia = antes?.value != null;
    final hay = ahora.value != null;
    if (habia && !hay && ahora.hasValue) {
      ref.read(almacenRespaldoProvider).borrarTodo();
    }
  });
});

List<Map<String, Object?>> listaJson(Object? json) => [
  for (final fila in json as List) (fila as Map).cast<String, Object?>(),
];
