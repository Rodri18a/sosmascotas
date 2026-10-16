import 'package:sosmascota/src/funcionalidades/funcionalidades_activas.dart';

/// La base de las funcionalidades en memoria. Con [fallar], no responde
/// (como sin conexión).
class FuncionalidadesFalsas implements FuncionalidadesRepositorio {
  FuncionalidadesFalsas([Set<String> activas = const {}])
    : activas = {...activas};

  Set<String> activas;
  bool fallar = false;
  final pedidos = <Map<String, String>>[];

  @override
  Future<Set<String>> prendidas({
    required String anonId,
    required String plataforma,
    required String version,
  }) async {
    pedidos.add({
      'anonId': anonId,
      'plataforma': plataforma,
      'version': version,
    });
    if (fallar) throw Exception('sin conexión');
    return {...activas};
  }
}

/// Lo guardado en el dispositivo, en memoria.
class CacheFuncionalidadesFalsa implements CacheFuncionalidades {
  CacheFuncionalidadesFalsa({this.usuario, this.claves});

  String? usuario;
  Set<String>? claves;

  @override
  Future<Set<String>?> leer(String? usuarioId) async =>
      usuarioId == usuario ? claves : null;

  @override
  Future<void> guardar(String? usuarioId, Set<String> prendidas) async {
    usuario = usuarioId;
    claves = prendidas;
  }
}
