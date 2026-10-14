import 'dart:typed_data';

import 'package:sosmascota/src/sos/sos_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

class SosFalso implements SosRepositorio {
  SosFalso({
    this.pins = const [],
    this.listaCercanos = const [],
    this.detalles = const {},
  });

  final List<Pin> pins;
  final Map<String, SosDetalle> detalles;
  final avisosEnviados = <({String sosId, String mensaje, String contacto})>[];
  final whatsappActivado = <String, String?>{};
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

  @override
  Future<SosDetalle?> detalle(String id) async => detalles[id];

  @override
  Future<void> avisarAlDueno({
    required String sosId,
    required String mensaje,
    required String nombre,
    required String contacto,
  }) async {
    if (fallarCon case final tipo?) throw SosException(tipo);
    avisosEnviados.add((sosId: sosId, mensaje: mensaje, contacto: contacto));
  }

  @override
  Future<void> mostrarWhatsapp(
    String sosId, {
    required String? numero,
    required bool activo,
  }) async {
    whatsappActivado[sosId] = activo ? numero : null;
  }
}
