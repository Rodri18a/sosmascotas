import 'package:sosmascota/src/mascotas/mascota_elegida.dart';

/// La mascota elegida en memoria (sin tocar el dispositivo).
class AlmacenMascotaElegidaFalso implements AlmacenMascotaElegida {
  AlmacenMascotaElegidaFalso([Map<String, String?>? inicial])
    : guardadas = {...?inicial};

  final Map<String, String?> guardadas;

  @override
  Future<String?> leer(String usuarioId) async => guardadas[usuarioId];

  @override
  Future<void> guardar(String usuarioId, String? mascotaId) async =>
      guardadas[usuarioId] = mascotaId;
}
