import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';
import 'comunidad_falsa.dart';
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

final _novedades = [
  for (var i = 0; i < 7; i++)
    Novedad(
      id: 'c$i',
      tipo: TipoNovedad.comercio,
      fecha: DateTime(2026, 11, 1, 10 - i),
      nombre: 'Lugar $i',
      detalle: 'vet',
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
      noticias: NoticiasFalsas(_noticias, _novedades),
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
    // En Inicio va después de la tercera de las 5 novedades (D147).
    expect(
      tester.getTopLeft(etiqueta).dy,
      greaterThan(
        tester.getTopLeft(find.text('Nuevo lugar verificado: Lugar 2')).dy,
      ),
    );
    expect(
      tester.getTopLeft(etiqueta).dy,
      lessThan(
        tester.getTopLeft(find.text('Nuevo lugar verificado: Lugar 3')).dy,
      ),
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

  testWidgets('en Preguntas sale una cada 8 (3.2)', (tester) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      appDePrueba(
        inicio: Rutas.preguntas,
        cuenta: ServicioCuentaFalso(conectado: _ana),
        promociones: PromocionesFalsas(cerca: [_promo]),
        comunidad: ComunidadFalsa(
          publicaciones: [
            for (var i = 0; i < 9; i++)
              Publicacion(
                id: 'q$i',
                tipo: TipoPublicacion.pregunta,
                texto: 'Pregunta $i',
                creada: DateTime(2026, 11, 1, 10 - i),
                tema: TemaPregunta.salud,
              ),
          ],
        ),
        funcionalidades: FuncionalidadesFalsas({
          Funcionalidades.grupos,
          Funcionalidades.preguntas,
          Funcionalidades.promociones,
        }),
      ),
    );
    await tester.pumpAndSettle();
    final etiqueta = find.text('Promocionado · Pet Shop Pando');
    await tester.scrollUntilVisible(
      etiqueta,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(etiqueta, findsOneWidget);
    expect(
      tester.getTopLeft(etiqueta).dy,
      greaterThan(tester.getTopLeft(find.text('Pregunta 7')).dy),
    );
  });

  testWidgets('la vista de un banner se cuenta una vez, con su id (3.2)', (
    tester,
  ) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        inicio: Rutas.inicio,
        noticias: NoticiasFalsas(
          _noticias,
          const [],
          const ResumenComunidad(),
          const [BannerInicio(id: 'bn1', titulo: 'Jornada', imagen: 'a.png')],
        ),
        eventos: eventos,
        funcionalidades: FuncionalidadesFalsas({Funcionalidades.noticias}),
      ),
    );
    await tester.pumpAndSettle();
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    final vistas = eventos.where((e) => e['name'] == 'banner_view').toList();
    expect(vistas, hasLength(1));
    expect(vistas.single['target_id'], 'bn1');
  });
}
