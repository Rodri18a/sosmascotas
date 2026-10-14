import 'package:sosmascota/src/avisos/avisos_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

class AvisosFalsos implements AvisosRepositorio {
  AvisosFalsos([List<Aviso>? iniciales]) : avisos = [...?iniciales];

  final List<Aviso> avisos;

  @override
  Future<List<Aviso>> misAvisos() async => List.of(avisos);

  @override
  Future<void> cambiarEstado(String id, EstadoAviso estado) async {
    final i = avisos.indexWhere((a) => a.id == id);
    final a = avisos[i];
    avisos[i] = Aviso(
      id: a.id,
      desdeQr: a.desdeQr,
      mascotaId: a.mascotaId,
      nombreRemitente: a.nombreRemitente,
      contactoRemitente: a.contactoRemitente,
      mensaje: a.mensaje,
      estado: estado,
      creado: a.creado,
      lat: a.lat,
      lng: a.lng,
    );
  }

  @override
  Future<void> borrar(String id) async => avisos.removeWhere((a) => a.id == id);
}
