import 'package:sosmascota/src/mascotas/enlaces_historial_repositorio.dart';

/// Enlaces del historial en memoria.
class EnlacesHistorialFalsos implements EnlacesHistorialRepositorio {
  final enlaces = <String, List<EnlaceHistorial>>{};
  final pedidos = <int>[];

  @override
  Future<List<EnlaceHistorial>> vigentes(String mascotaId) async => [
    ...?enlaces[mascotaId],
  ];

  @override
  Future<String> crear(String mascotaId, int dias) async {
    pedidos.add(dias);
    final token = 'tok${pedidos.length}'.padRight(22, 'x');
    (enlaces[mascotaId] ??= []).add((
      id: 'e${pedidos.length}',
      token: token,
      vence: DateTime(2026, 11, 2).add(Duration(days: dias)),
      vistas: 0,
    ));
    return token;
  }

  @override
  Future<void> cortar(String id) async {
    for (final lista in enlaces.values) {
      lista.removeWhere((e) => e.id == id);
    }
  }
}
