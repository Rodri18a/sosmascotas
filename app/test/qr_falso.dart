import 'package:sosmascota/src/qr/qr_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

class QrFalso implements QrRepositorio {
  QrFalso({this.listaEscaneos = const []});

  final List<Escaneo> listaEscaneos;
  final Map<String, QrTag> porMascota = {};
  int regeneraciones = 0;

  @override
  Future<QrTag?> qrActivo(String mascotaId) async =>
      porMascota[mascotaId] ??= QrTag(
        id: 'qr-$mascotaId',
        codigo: 'K7M2QX9P',
        activo: true,
        mascotaId: mascotaId,
      );

  @override
  Future<String> regenerar(String mascotaId) async {
    regeneraciones++;
    final nuevo = QrTag(
      id: 'qr-$mascotaId-$regeneraciones',
      codigo: 'NUEVO${regeneraciones.toString().padLeft(3, '2')}',
      activo: true,
      mascotaId: mascotaId,
    );
    porMascota[mascotaId] = nuevo;
    return nuevo.codigo;
  }

  @override
  Future<void> guardarNota(String qrId, String? nota) async {
    final entrada = porMascota.entries.firstWhere((e) => e.value.id == qrId);
    porMascota[entrada.key] = QrTag(
      id: qrId,
      codigo: entrada.value.codigo,
      activo: true,
      mascotaId: entrada.key,
      notaPublica: nota,
    );
  }

  @override
  Future<List<Escaneo>> escaneos(String mascotaId) async => listaEscaneos;
}
