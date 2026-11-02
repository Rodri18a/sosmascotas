import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'noticias_falsas.dart';
import 'promociones_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

final _noticias = [
  for (var i = 0; i < 5; i++)
    Noticia(
      id: 'n$i',
      titulo: 'Noticia $i',
      cuerpo: 'Texto de la noticia $i.',
      publicada: DateTime(2026, 11, 1, 10 - i),
    ),
];

const _promo = Promocion(
  id: 'p1',
  negocioId: 'b9',
  negocio: 'Pet Shop Pando',
  titulo: '10% en alimento',
  texto: 'Toda la semana, en todas las marcas.',
  punto: Punto(-34.71, -55.95),
);

MiNegocio _negocio(String plan) => MiNegocio.fromJson({
  'id': 'b1',
  'name': 'Pet Shop Luna',
  'business_type': 'petshop',
  'kind': 'local',
  'lat': -34.71,
  'lng': -55.95,
  'verification': 'verified',
  'plan': plan,
  'status': 'active',
  'photos': ['b1/frente.jpg'],
});

Future<List<Map<String, Object?>>> _abrir(
  WidgetTester tester, {
  required PromocionesFalsas promociones,
  String inicio = Rutas.inicio,
  NegociosFalsos? negocios,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final eventos = <Map<String, Object?>>[];
  await tester.pumpWidget(
    appDePrueba(
      inicio: inicio,
      cuenta: ServicioCuentaFalso(conectado: _ana),
      noticias: NoticiasFalsas(_noticias),
      promociones: promociones,
      negocios: negocios,
      eventos: eventos,
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.noticias,
        Funcionalidades.promociones,
        Funcionalidades.comercios,
      }),
    ),
  );
  await tester.pumpAndSettle();
  return eventos;
}

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  if (objetivo.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      objetivo,
      300,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('en el muro sale marcada «Promocionado» y se cuenta una vista', (
    tester,
  ) async {
    final eventos = await _abrir(
      tester,
      promociones: PromocionesFalsas(cerca: [_promo]),
    );
    final etiqueta = find.text('Promocionado · Pet Shop Pando');
    await tester.scrollUntilVisible(
      etiqueta,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(etiqueta, findsOneWidget);
    expect(find.text('10% en alimento'), findsOneWidget);
    // Va después de la cuarta noticia.
    expect(
      tester.getTopLeft(etiqueta).dy,
      greaterThan(tester.getTopLeft(find.text('Noticia 3')).dy),
    );
    final vistas = eventos.where((e) => e['name'] == 'promo_view').toList();
    expect(vistas, hasLength(1));
    expect(vistas.single['business_id'], 'b9');
  });

  testWidgets('se puede reportar', (tester) async {
    final promociones = PromocionesFalsas(cerca: [_promo]);
    await _abrir(tester, promociones: promociones);
    await _tocar(tester, find.byTooltip('Reportar esta promoción'));
    await _tocar(tester, find.text('Es engañosa'));
    expect(promociones.reportadas, [('p1', 'Es engañosa')]);
    expect(find.text('Gracias, la vamos a revisar.'), findsOneWidget);
  });

  testWidgets('el comercio Destacado publica su promoción desde el panel', (
    tester,
  ) async {
    final promociones = PromocionesFalsas();
    final eventos = await _abrir(
      tester,
      promociones: promociones,
      inicio: Rutas.negocio,
      negocios: NegociosFalsos([_negocio('featured')]),
    );
    await _tocar(
      tester,
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Negocio'),
      ),
    );
    await _tocar(tester, find.text('Nueva promoción'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Título (por ejemplo: 10% en alimento)'),
      '2x1 en piedras',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Detalle'),
      'Hasta agotar stock.',
    );
    await _tocar(tester, find.text('15 días'));
    await _tocar(tester, find.text('Foto 1'));
    await _tocar(tester, find.text('Publicar'));

    expect(promociones.guardadas.single, {
      'id': null,
      'negocio': 'b1',
      'titulo': '2x1 en piedras',
      'texto': 'Hasta agotar stock.',
      'dias': 15,
      'foto': 'b1/frente.jpg',
    });
    expect(find.text('2x1 en piedras'), findsOneWidget);
    expect(
      find.text('Nueva promoción'),
      findsNothing,
      reason: 'Destacado tiene 1 vigente',
    );
    expect(eventos.map((e) => e['name']), contains('promo_create'));
  });

  testWidgets('con el plan Gratis se explica qué incluye Destacado', (
    tester,
  ) async {
    await _abrir(
      tester,
      promociones: PromocionesFalsas(),
      inicio: Rutas.negocio,
      negocios: NegociosFalsos([_negocio('basic')]),
    );
    await _tocar(
      tester,
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Negocio'),
      ),
    );
    await tester.scrollUntilVisible(
      find.text('Promoción en el muro'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.textContaining('Con Destacado o Plus'), findsOneWidget);
    expect(find.text('Nueva promoción'), findsNothing);
  });
}
