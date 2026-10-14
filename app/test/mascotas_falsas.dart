import 'dart:typed_data';

import 'package:sosmascota/src/mascotas/catalogo.dart';
import 'package:sosmascota/src/mascotas/mascotas_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

class CatalogoFalso implements CatalogoRepositorio {
  @override
  Future<List<Especie>> especies() async => const [
    Especie(id: 1, slug: 'dog', nombre: 'Perro', icono: '🐶'),
    Especie(id: 2, slug: 'cat', nombre: 'Gato', icono: '🐱'),
    Especie(id: 10, slug: 'other', nombre: 'Otro', icono: '🐾'),
  ];

  @override
  Future<List<Raza>> razas(int especieId) async => switch (especieId) {
    1 => const [
      Raza(id: 1, especieId: 1, nombre: 'Mestizo'),
      Raza(id: 2, especieId: 1, nombre: 'Labrador'),
    ],
    2 => const [Raza(id: 3, especieId: 2, nombre: 'Siamés')],
    _ => const [],
  };
}

/// Mascotas en memoria para las pruebas.
class MascotasFalsas implements MascotasRepositorio {
  MascotasFalsas([List<Mascota>? iniciales]) : mascotas = [...?iniciales];

  final List<Mascota> mascotas;
  final fotosSubidas = <Uint8List>[];
  bool fallar = false;
  int _siguiente = 1;

  @override
  Future<List<Mascota>> misMascotas() async => List.of(mascotas);

  @override
  Future<Mascota> crear(Mascota mascota) async {
    if (fallar) throw Exception('sin internet');
    final guardada = Mascota.fromJson({
      ...mascota.toJson(),
      'id': 'mascota-${_siguiente++}',
    });
    mascotas.add(guardada);
    return guardada;
  }

  @override
  Future<Mascota> actualizar(Mascota mascota) async {
    if (fallar) throw Exception('sin internet');
    final guardada = Mascota.fromJson({...mascota.toJson(), 'id': mascota.id});
    mascotas[mascotas.indexWhere((m) => m.id == mascota.id)] = guardada;
    return guardada;
  }

  @override
  Future<void> borrar(String id) async =>
      mascotas.removeWhere((m) => m.id == id);

  @override
  Future<String> subirFoto(Uint8List jpeg) async {
    fotosSubidas.add(jpeg);
    return 'usuario-1/foto-${fotosSubidas.length}.jpg';
  }

  /// Sin red en las pruebas: nunca hay enlace.
  @override
  String? urlFoto(String? ruta) => null;
}
