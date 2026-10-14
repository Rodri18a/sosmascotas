import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'mascotas_repositorio.dart';

/// Mascota elegida en la fila superior (la que se precarga en un SOS, por ejemplo).
class MascotaActiva extends Notifier<String?> {
  @override
  String? build() => null;

  void elegir(String id) => state = id;
}

final mascotaActivaIdProvider = NotifierProvider<MascotaActiva, String?>(
  MascotaActiva.new,
);

/// La mascota activa, o la primera si no se eligió ninguna.
final mascotaActivaProvider = Provider<Mascota?>((ref) {
  final lista = ref.watch(misMascotasProvider).value ?? const <Mascota>[];
  final id = ref.watch(mascotaActivaIdProvider);
  return lista.where((m) => m.id == id).firstOrNull ?? lista.firstOrNull;
});
