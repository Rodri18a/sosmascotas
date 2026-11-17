import 'package:sosmascota/src/soporte/soporte_repositorio.dart';

class SoporteFalso implements SoporteRepositorio {
  SoporteFalso({this.whatsapp, this.limite = 5});

  final String? whatsapp;
  final int limite;
  final enviados = <String>[];

  @override
  Future<ContactoSoporte> contacto() async =>
      ContactoSoporte(whatsapp: whatsapp);

  @override
  Future<void> enviar(String mensaje) async {
    if (mensaje.trim().length < 5) {
      throw const SoporteException(ErrorSoporte.muyCorto);
    }
    if (enviados.length >= limite) {
      throw const SoporteException(ErrorSoporte.demasiados);
    }
    enviados.add(mensaje.trim());
  }
}
