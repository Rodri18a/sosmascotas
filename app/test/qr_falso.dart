import 'package:sosmascota/src/qr/qr_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

class QrFalso implements QrRepositorio {
  QrFalso({this.listaEscaneos = const []});

  final List<Escaneo> listaEscaneos;
  final Map<String, QrTag> porMascota = {};
  int regeneraciones = 0;

  /// Sin internet al leer (paso 1.5.6).
  bool sinConexion = false;

  @override
  Future<QrTag?> qrActivo(String mascotaId) async {
    if (sinConexion) throw Exception('sin internet');
    return porMascota[mascotaId] ??= QrTag(
      id: 'qr-$mascotaId',
      codigo: 'K7M2QX9P',
      activo: true,
      mascotaId: mascotaId,
    );
  }

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

  /// Chapitas sin activar que "existen" en la base.
  final libres = <String>{'H4PZ7KQ2', 'W3RT8NM5'};
  final vinculadas = <QrTag>[];

  @override
  Future<List<QrTag>> chapitas(String mascotaId) async => [
    for (final c in vinculadas)
      if (c.mascotaId == mascotaId && c.activo) c,
  ];

  @override
  Future<void> activarChapita(String codigo, String mascotaId) async {
    if (vinculadas.any((c) => c.codigo == codigo)) {
      throw const ChapitaFallida(ErrorChapita.usada);
    }
    if (!libres.remove(codigo)) {
      throw const ChapitaFallida(ErrorChapita.inexistente);
    }
    vinculadas.add(
      QrTag(
        id: 'ch-$codigo',
        codigo: codigo,
        activo: true,
        mascotaId: mascotaId,
      ),
    );
  }

  @override
  Future<void> desvincularChapita(String tagId) async {
    final i = vinculadas.indexWhere((c) => c.id == tagId);
    final c = vinculadas[i];
    vinculadas[i] = QrTag(
      id: c.id,
      codigo: c.codigo,
      activo: false,
      mascotaId: c.mascotaId,
    );
  }
}
