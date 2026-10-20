import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../cuenta/servicio_cuenta.dart';
import 'mascotas_repositorio.dart';

/// Dónde se guarda la mascota elegida en el menú (D88). Solo en este
/// dispositivo y junto con la cuenta: otra cuenta no la usa.
abstract interface class AlmacenMascotaElegida {
  Future<String?> leer(String usuarioId);
  Future<void> guardar(String usuarioId, String? mascotaId);
}

class AlmacenMascotaElegidaLocal implements AlmacenMascotaElegida {
  const AlmacenMascotaElegidaLocal();

  static const _clave = 'mascota.elegida';

  @override
  Future<String?> leer(String usuarioId) async {
    final texto = (await SharedPreferences.getInstance()).getString(_clave);
    if (texto == null) return null;
    final datos = jsonDecode(texto);
    if (datos is! Map || datos['usuario'] != usuarioId) return null;
    return datos['mascota'] as String?;
  }

  @override
  Future<void> guardar(String usuarioId, String? mascotaId) async =>
      (await SharedPreferences.getInstance()).setString(
        _clave,
        jsonEncode({'usuario': usuarioId, 'mascota': mascotaId}),
      );
}

final almacenMascotaElegidaProvider = Provider<AlmacenMascotaElegida>(
  (ref) => const AlmacenMascotaElegidaLocal(),
);

/// Id de la mascota elegida en el menú (`null` = todas).
final mascotaElegidaIdProvider = NotifierProvider<MascotaElegida, String?>(
  MascotaElegida.new,
);

class MascotaElegida extends Notifier<String?> {
  @override
  String? build() {
    final usuario = ref.watch(usuarioActualProvider).value?.id;
    if (usuario != null) _cargar(usuario);
    return null;
  }

  Future<void> _cargar(String usuario) async {
    final id = await ref.read(almacenMascotaElegidaProvider).leer(usuario);
    if (ref.mounted && id != null) state = id;
  }

  Future<void> elegir(String? mascotaId) async {
    state = mascotaId;
    final usuario = ref.read(usuarioActualProvider).value?.id;
    if (usuario != null) {
      await ref.read(almacenMascotaElegidaProvider).guardar(usuario, mascotaId);
    }
  }
}

/// La mascota elegida, si sigue entre las mías (si se borró, ninguna).
final mascotaElegidaProvider = Provider<Mascota?>((ref) {
  final id = ref.watch(mascotaElegidaIdProvider);
  if (id == null) return null;
  final mascotas = ref.watch(misMascotasProvider).value ?? const <Mascota>[];
  return mascotas.where((m) => m.id == id).firstOrNull;
});

/// Especie de la mascota elegida: filtra Noticias, Comunidad y Adopción.
final especieElegidaProvider = Provider<int?>(
  (ref) => ref.watch(mascotaElegidaProvider)?.especieId,
);
