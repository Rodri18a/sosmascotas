import 'package:sosmascota/src/comercios/descuentos_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

class DescuentosFalsos implements DescuentosRepositorio {
  DescuentosFalsos({this.pro = false, this.puede = true});

  bool pro;
  bool puede;
  var lista = <DescuentoPro>[
    const DescuentoPro(
      id: 'd1',
      titulo: '10 % en baños',
      negocioId: 'b1',
      negocio: 'Peluquería Luna',
      direccion: 'Artigas 123',
    ),
  ];
  final pedidos = <String>[];
  final guardados = <Map<String, Object?>>[];
  final canjes = <String>[];

  @override
  Future<DescuentosParaMi> paraMi({String? negocioId}) async =>
      (pro: pro, descuentos: lista);

  @override
  Future<String> pedir(String descuentoId) async {
    if (!pro) throw const DescuentoException(ErrorDescuento.sinPro);
    pedidos.add(descuentoId);
    lista = [
      for (final d in lista)
        d.id == descuentoId
            ? DescuentoPro(
                id: d.id,
                titulo: d.titulo,
                negocioId: d.negocioId,
                negocio: d.negocio,
                codigo: 'ABC234',
              )
            : d,
    ];
    return 'ABC234';
  }

  @override
  Future<DescuentosDelNegocio> delNegocio(String negocioId) async =>
      (puede: puede, descuentos: lista);

  @override
  Future<void> guardar(String negocioId, Map<String, Object?> datos) async =>
      guardados.add(datos);

  @override
  Future<CanjeDescuento> canjear(String negocioId, String codigo) async {
    if (codigo == 'HOY000') {
      throw const DescuentoException(ErrorDescuento.usadoHoy);
    }
    canjes.add(codigo);
    return (titulo: '10 % en baños', cliente: 'Ana');
  }
}
