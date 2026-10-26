import 'package:sosmascota/src/adopcion/pack_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

/// Pack adopción en memoria, con las mismas reglas que la base.
class PackFalso implements PackAdopcionRepositorio {
  PackFalso({
    this.adopto = false,
    this.puedeDar = true,
    List<BeneficioAdopcion>? deLaZona,
    List<BeneficioAdopcion>? propios,
  }) : deLaZona = [...?deLaZona],
       propios = [...?propios];

  final bool adopto;
  final bool puedeDar;
  final List<BeneficioAdopcion> deLaZona;
  final List<BeneficioAdopcion> propios;
  final guardados = <Map<String, Object?>>[];

  /// Código → (beneficio, usado).
  final codigos = <String, (String, bool)>{};

  BeneficioAdopcion _conCodigo(BeneficioAdopcion b) {
    final c = codigos.entries.where((e) => e.value.$1 == b.id).firstOrNull;
    return BeneficioAdopcion(
      id: b.id,
      titulo: b.titulo,
      descripcion: b.descripcion,
      negocioId: b.negocioId,
      negocio: b.negocio,
      direccion: b.direccion,
      codigo: c?.key,
      usado: c?.value.$2 ?? false,
    );
  }

  @override
  Future<ListaBeneficios> beneficios() async => adopto
      ? (puede: true, beneficios: [for (final b in deLaZona) _conCodigo(b)])
      : (puede: false, beneficios: const <BeneficioAdopcion>[]);

  @override
  Future<String> pedir(String beneficioId) async {
    if (!adopto) throw const PackException(ErrorPack.sinAdopcion);
    final ya = codigos.entries.where((e) => e.value.$1 == beneficioId);
    if (ya.isNotEmpty) return ya.first.key;
    final codigo = 'K7M2Q${codigos.length}';
    codigos[codigo] = (beneficioId, false);
    return codigo;
  }

  @override
  Future<ListaBeneficios> delNegocio(String negocioId) async =>
      (puede: puedeDar, beneficios: List.of(propios));

  @override
  Future<void> guardar(String negocioId, Map<String, Object?> datos) async {
    if (!puedeDar) throw const PackException(ErrorPack.soloVerificados);
    guardados.add(datos);
    final b = BeneficioAdopcion(
      id: (datos['id'] as String?) ?? 'b${propios.length}',
      titulo: datos['title']! as String,
      descripcion: datos['description'] as String?,
      activo: datos['active'] != false,
    );
    final i = propios.indexWhere((x) => x.id == b.id);
    i < 0 ? propios.add(b) : propios[i] = b;
  }

  @override
  Future<CanjeBeneficio> canjear(String negocioId, String codigo) async {
    final c = codigos[codigo.toUpperCase()];
    if (c == null) throw const PackException(ErrorPack.codigoInexistente);
    if (c.$2) throw const PackException(ErrorPack.codigoUsado);
    codigos[codigo.toUpperCase()] = (c.$1, true);
    return (
      titulo: 'Primera consulta con 20 %',
      cliente: 'Ana',
      animal: 'Toto',
    );
  }
}
