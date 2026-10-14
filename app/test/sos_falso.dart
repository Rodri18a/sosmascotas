import 'dart:typed_data';

import 'package:sosmascota/src/sos/sos_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

class SosFalso implements SosRepositorio {
  SosFalso({this.pins = const [], this.listaCercanos = const []});

  final List<Pin> pins;
  final List<SosResumen> listaCercanos;
  final zonasConsultadas = <Limites>[];
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
  Future<List<Pin>> enZona(Limites zona) async {
    zonasConsultadas.add(zona);
    return pins;
  }

  @override
  Future<List<SosResumen>> cercanos(Punto punto) async => listaCercanos;

  @override
  String? urlFoto(String? ruta) => null;
}
