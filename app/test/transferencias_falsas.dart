import 'package:sosmascota/src/mascotas/transferencias_repositorio.dart';

/// Transferencias en memoria: un código por mascota.
class TransferenciasFalsas implements TransferenciasRepositorio {
  TransferenciasFalsas({this.conSos = false, this.recibible});

  /// Si la mascota tiene un SOS abierto (no se puede pasar).
  final bool conSos;

  /// Lo que devuelve el código «ABCDEFGHJK».
  final VistaTransferencia? recibible;

  final codigos = <String, String>{};
  final aceptados = <String>[];

  @override
  Future<CodigoAbierto?> abierto(String mascotaId) async =>
      switch (codigos[mascotaId]) {
        final c? => (codigo: c, vence: DateTime(2026, 11, 9)),
        null => null,
      };

  @override
  Future<String> crear(String mascotaId) async {
    if (conSos) {
      throw const TransferenciaException(ErrorTransferencia.sosAbierto);
    }
    return codigos[mascotaId] = 'K7M2Q9XPWA';
  }

  @override
  Future<void> cancelar(String mascotaId) async => codigos.remove(mascotaId);

  @override
  Future<VistaTransferencia?> ver(String codigo) async =>
      codigo.trim().toUpperCase() == 'ABCDEFGHJK' ? recibible : null;

  @override
  Future<String> aceptar(String codigo) async {
    final vista = await ver(codigo);
    if (vista == null) {
      throw const TransferenciaException(ErrorTransferencia.codigoInvalido);
    }
    aceptados.add(codigo);
    return vista.mascotaId;
  }
}
