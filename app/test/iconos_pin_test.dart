import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/mapa/dibujo_pin.dart';
import 'package:sosmascota/src/mapa/mapa_vista.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'tema_test.dart' show contraste;

const _punto = Punto(-34.72, -55.95);

Pin _pin(TipoPin tipo, [Categoria? categoria]) =>
    Pin(id: 'p', tipo: tipo, punto: _punto, categoria: categoria);

void main() {
  test('cada rubro tiene su propio ícono (D82)', () {
    final iconos = Categoria.values.map(iconoCategoria).toSet();
    expect(iconos, hasLength(Categoria.values.length));
    expect(iconoCategoria(Categoria.grooming), Icons.content_cut);
    expect(iconoCategoria(Categoria.petshop), Icons.shopping_cart);
    expect(iconoCategoria(Categoria.petFriendly), Icons.pets);
    expect(iconoCategoria(Categoria.agro), Icons.agriculture);
  });

  test('perdidos y encontrados: lupa roja o verde', () {
    final perdido = aspectoDePin(_pin(TipoPin.perdido))!;
    final encontrado = aspectoDePin(_pin(TipoPin.encontrado))!;
    expect(perdido.icono, Icons.search);
    expect(encontrado.icono, Icons.search);
    expect(perdido.fondo, coloresPin[TipoPin.perdido]);
    expect(encontrado.fondo, coloresPin[TipoPin.encontrado]);
  });

  test('un lugar sin reclamar es gris con el ícono de su rubro', () {
    final peluqueria = aspectoDePin(
      _pin(TipoPin.sinReclamar, Categoria.grooming),
    )!;
    expect(peluqueria.icono, Icons.content_cut);
    expect(peluqueria.fondo, colorSinReclamar);
    final confirmada = aspectoDePin(
      _pin(TipoPin.comercio, Categoria.grooming),
    )!;
    expect(confirmada.icono, Icons.content_cut);
    expect(confirmada.fondo, coloresPin[TipoPin.comercio]);
    // Más chico que uno confirmado: no compite con los lugares reales.
    expect(peluqueria.diametro, lessThan(confirmada.diametro));
  });

  test('eventos con calendario y grupos sin ícono', () {
    expect(aspectoDePin(_pin(TipoPin.evento))!.icono, Icons.event);
    expect(aspectoDePin(_pin(TipoPin.grupo)), isNull);
  });

  test('el ícono contrasta con el pin (≥ 3:1)', () {
    for (final tipo in TipoPin.values) {
      final aspecto = aspectoDePin(_pin(tipo));
      if (aspecto == null) continue;
      expect(
        contraste(aspecto.colorIcono, aspecto.fondo),
        greaterThanOrEqualTo(3),
        reason: tipo.name,
      );
    }
  });

  test('los pines iguales comparten imagen; los distintos, no', () {
    final a = aspectoDePin(_pin(TipoPin.comercio, Categoria.hotel))!;
    final b = aspectoDePin(_pin(TipoPin.comercio, Categoria.hotel))!;
    final c = aspectoDePin(_pin(TipoPin.sinReclamar, Categoria.hotel))!;
    expect(a.clave, b.clave);
    expect(a.clave, isNot(c.clave));
  });

  testWidgets('dibuja el pin a la densidad de la pantalla', (tester) async {
    final aspecto = aspectoDePin(_pin(TipoPin.comercio, Categoria.petshop))!;
    final bytes = (await tester.runAsync(
      () => dibujarPin(aspecto, escala: 3),
    ))!;
    final imagen = (await tester.runAsync(() async {
      final codec = await ui.instantiateImageCodec(bytes);
      return (await codec.getNextFrame()).image;
    }))!;
    expect(imagen.width, (aspecto.diametro * 3).ceil());
    expect(imagen.height, (aspecto.diametro * 3).ceil());
  });
}
