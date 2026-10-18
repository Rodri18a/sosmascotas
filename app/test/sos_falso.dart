import 'dart:typed_data';

import 'package:sosmascota/src/sos/sos_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

class SosFalso implements SosRepositorio {
  SosFalso({
    this.pins = const [],
    this.listaCercanos = const [],
    Map<String, SosDetalle> detalles = const {},
  }) : detalles = {...detalles};

  final List<Pin> pins;
  final Map<String, SosDetalle> detalles;
  final avisosEnviados = <({String sosId, String mensaje, String contacto})>[];
  final whatsappActivado = <String, String?>{};
  final cerrados = <String, bool>{};
  final reportados = <String, String>{};
  List<MiSos> mios = const [];
  final List<SosResumen> listaCercanos;
  final zonasConsultadas = <Limites>[];
  final creados = <NuevoSos>[];
  final fotosSubidas = <Uint8List>[];
  ErrorSos? fallarCon;
  final difundidos = <String>[];

  /// `false` simula que la función no respondió (hay que reintentar).
  bool difusionResponde = true;

  @override
  Future<String> subirFoto(Uint8List jpeg) async {
    fotosSubidas.add(jpeg);
    return 'sos-photos/u1/foto-${fotosSubidas.length}.jpg';
  }

  @override
  Future<String> crear(NuevoSos sos) async {
    if (fallarCon case final tipo?) throw SosException(tipo);
    creados.add(sos);
    final id = 'sos-${creados.length}';
    // Como la base: lo publicado se puede abrir enseguida.
    detalles[id] ??= SosDetalle(
      id: id,
      tipo: sos.tipo,
      estado: EstadoSos.activo,
      especie: 'Mascota',
      especieIcono: '🐾',
      cuando: DateTime(2026, 10, 16),
      zona: sos.ubicacion,
      fotos: sos.fotos,
      esMio: true,
      nombre: sos.nombre,
    );
    return id;
  }

  @override
  Future<bool> difundirEnZona(String id) async {
    difundidos.add(id);
    return difusionResponde;
  }

  @override
  Future<List<MiSos>> misSos() async => mios;

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

  @override
  Future<bool> reportarContenido(String sosId, {required String motivo}) async {
    if (fallarCon case final tipo?) throw SosException(tipo);
    if (reportados.containsKey(sosId)) return false;
    reportados[sosId] = motivo;
    return true;
  }

  final seguidos = <String>{};

  @override
  Future<bool> sigo(String sosId) async => seguidos.contains(sosId);

  @override
  Future<void> seguir(String sosId, {required bool seguir}) async =>
      seguir ? seguidos.add(sosId) : seguidos.remove(sosId);

  @override
  Future<void> cerrar(String id, {required bool resuelto}) async {
    cerrados[id] = resuelto;
    final d = detalles[id];
    if (d != null) {
      detalles[id] = SosDetalle(
        id: d.id,
        tipo: d.tipo,
        estado: resuelto ? EstadoSos.resuelto : EstadoSos.archivado,
        especie: d.especie,
        especieIcono: d.especieIcono,
        cuando: d.cuando,
        zona: d.zona,
        fotos: d.fotos,
        esMio: d.esMio,
        nombre: d.nombre,
      );
    }
  }
}
