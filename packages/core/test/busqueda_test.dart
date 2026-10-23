import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  test('normaliza tildes, mayúsculas y espacios', () {
    expect(normalizarBusqueda('  Peluquería   CANINA '), 'peluqueria canina');
    expect(normalizarBusqueda('Baño'), 'bano');
  });

  group('rubroDeBusqueda', () {
    test('reconoce rubros y sinónimos', () {
      expect(rubroDeBusqueda('veterinaria'), Categoria.vet);
      expect(rubroDeBusqueda('Peluquería'), Categoria.grooming);
      expect(rubroDeBusqueda('baño para perros'), Categoria.grooming);
      expect(rubroDeBusqueda('guardería'), Categoria.hotel);
      expect(rubroDeBusqueda('adiestrador'), Categoria.trainer);
      expect(rubroDeBusqueda('refugio'), Categoria.shelter);
      expect(rubroDeBusqueda('pet shop'), Categoria.petshop);
    });

    test('mientras se escribe ya reconoce el rubro', () {
      expect(rubroDeBusqueda('pelu'), Categoria.grooming);
      expect(rubroDeBusqueda('veter'), Categoria.vet);
    });

    test('gana el sinónimo más largo', () {
      expect(rubroDeBusqueda('agroveterinaria'), Categoria.agro);
    });

    test('un nombre propio no es un rubro', () {
      expect(rubroDeBusqueda('San Roque'), isNull);
      expect(rubroDeBusqueda('Barros Blancos'), isNull);
      expect(rubroDeBusqueda('a'), isNull);
    });
  });

  group('textoParaMetrica', () {
    test('saca números y arrobas, y corta', () {
      expect(textoParaMetrica('Fisioterapia 099 123 456'), 'fisioterapia');
      expect(textoParaMetrica('ana@correo.com'), 'ana correo.com');
      expect(textoParaMetrica('x' * 80), hasLength(maximoTextoMetrica));
    });

    test('si no queda nada, no se guarda', () {
      expect(textoParaMetrica('099123456'), isNull);
      expect(textoParaMetrica(' '), isNull);
    });
  });
}
