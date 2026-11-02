import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

Promocion _p(String id) => Promocion(id: id, titulo: id, texto: id);

void main() {
  test('lee la del muro con el punto del comercio', () {
    final p = Promocion.fromJson({
      'id': 'p1',
      'business_id': 'b1',
      'negocio': 'Pet Shop Pando',
      'title': '10% en alimento',
      'body': 'Toda la semana',
      'photo_path': 'b1/frente.jpg',
      'lat': -34.71,
      'lng': -55.95,
    });
    expect(p.negocio, 'Pet Shop Pando');
    expect(p.punto, const Punto(-34.71, -55.95));
    expect(p.vigente, isTrue);
  });

  test('topes del plan: Destacado 1, Plus 2, Gratis ninguna', () {
    expect(Promocion.topeDelPlan('featured'), 1);
    expect(Promocion.topeDelPlan('plus'), 2);
    expect(Promocion.topeDelPlan('basic'), 0);
  });

  test('se intercala una cada 4, hasta 3', () {
    final muro = intercalarPromociones(List.generate(14, (i) => 'n$i'), [
      _p('a'),
      _p('b'),
      _p('c'),
      _p('d'),
    ]);
    final promos = [
      for (final x in muro)
        if (x is Promocion) x.id,
    ];
    expect(promos, ['a', 'b', 'c']);
    expect(muro[4], isA<Promocion>());
    expect(muro.whereType<String>(), hasLength(14));
  });

  test('con pocas noticias igual se ve una, al final', () {
    final muro = intercalarPromociones(['n0', 'n1'], [_p('a')]);
    expect(muro.last, isA<Promocion>());
    expect(intercalarPromociones(<String>[], [_p('a')]), isEmpty);
  });
}
