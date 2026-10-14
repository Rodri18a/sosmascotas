import 'dart:typed_data';

import 'package:sosmascota/src/sos/sos_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

class SosFalso implements SosRepositorio {
  final creados = <NuevoSos>[];
  final fotosSubidas = <Uint8List>[];
  ErrorSos? fallarCon;

  @override
  Future<String> subirFoto(Uint8List jpeg) async {
    fotosSubidas.add(jpeg);
    return 'sos-photos/u1/foto-${fotosSubidas.length}.jpg';
  }

  @override
  Future<String> crear(NuevoSos sos) async {
    if (fallarCon case final tipo?) throw SosException(tipo);
    creados.add(sos);
    return 'sos-${creados.length}';
  }

  @override
  Future<List<MiSos>> misSos() async => const [];

  @override
  String? urlFoto(String? ruta) => null;
}
