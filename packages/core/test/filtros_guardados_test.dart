import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('los filtros se guardan y se leen igual', () {
    const f = FiltrosMapa(
      categorias: {Categoria.vet, Categoria.petshop},
      distancia: Distancia.km2,
      abiertoAhora: true,
      soloFavoritos: true,
      porMascotaActiva: false,
    );
    final leido = FiltrosMapa.fromJson(f.toJson());
    expect(leido.categorias, {Categoria.vet, Categoria.petshop});
    expect(leido.distancia, Distancia.km2);
    expect(leido.abiertoAhora, isTrue);
    expect(leido.soloFavoritos, isTrue);
    expect(leido.porMascotaActiva, isFalse);
    expect(leido.activos, f.activos);
  });

  test('lo que no se reconoce queda como por defecto', () {
    final leido = FiltrosMapa.fromJson({
      'categorias': ['vet', 'nave_espacial'],
      'distancia': 'lejisimo',
    });
    expect(leido.categorias, {Categoria.vet});
    expect(leido.distancia, Distancia.todo);
    expect(leido.porMascotaActiva, isTrue);
  });
}
