import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  final json = <String, Object?>{
    'id': 'n1',
    'title': 'Vacunación antirrábica',
    'body': 'Se viene la campaña.\n\nLlevá la libreta.',
    'source': 'MGAP',
    'link': 'https://www.gub.uy/',
    'species_ids': [1, 2],
    'sponsored': true,
    'sponsor_name': 'Marca',
    'published_at': '2026-10-20T12:00:00Z',
  };

  test('se lee de la base', () {
    final n = Noticia.fromJson(json);
    expect(n.titulo, 'Vacunación antirrábica');
    expect(n.especieIds, [1, 2]);
    expect(n.patrocinada, isTrue);
    expect(n.marca, 'Marca');
    expect(n.resumen, 'Se viene la campaña. Llevá la libreta.');
  });

  test('regla de especie: para todas, para la mía o sin mascotas', () {
    final n = Noticia.fromJson(json);
    expect(n.esPara({1}), isTrue);
    expect(n.esPara({8}), isFalse);
    expect(n.esPara({}), isTrue);
    final todas = Noticia.fromJson({...json, 'species_ids': <int>[]});
    expect(todas.esPara({8}), isTrue);
  });

  test('el resumen corta los textos largos', () {
    final n = Noticia.fromJson({...json, 'body': 'a' * 300});
    expect(n.resumen.length, 138);
    expect(n.resumen.endsWith('…'), isTrue);
  });
}
