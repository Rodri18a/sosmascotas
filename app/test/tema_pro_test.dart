import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'perfil_falso.dart';
import 'tema_falso.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

FuncionalidadesFalsas _temasPro() =>
    FuncionalidadesFalsas({Funcionalidades.temasPro});

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Color _primario(WidgetTester tester) =>
    Theme.of(tester.element(find.byType(Scaffold).first)).colorScheme.primary;

Future<void> _abrirAjustes(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await abrirAjustesDesdeMenu(tester);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('con plan Gratis no aparece el tema y se ve Cielo', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        funcionalidades: _temasPro(),
        // Aunque haya un tema guardado de cuando tenía Pro.
        almacenTema: AlmacenTemaFalso('pop'),
      ),
    );
    await _abrirAjustes(tester);

    expect(find.text('Tema de colores'), findsNothing);
    expect(_primario(tester), Paleta.cielo.claro.primario);
  });

  testWidgets('con plan Pro se elige Faro, se guarda y se mide', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final almacen = AlmacenTemaFalso();
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        perfiles: PerfilRepositorioFalso(plan: Plan.pro),
        funcionalidades: _temasPro(),
        almacenTema: almacen,
        eventos: eventos,
      ),
    );
    await _abrirAjustes(tester);

    expect(find.text('Huellitas · beneficio de tu plan Pro'), findsOneWidget);
    await tester.tap(find.text('Tema de colores'));
    await tester.pumpAndSettle();
    expect(find.text('Elegí cómo se ve la app'), findsOneWidget);
    for (final nombre in [
      'Huellitas',
      'Faro',
      'Vecinos',
      'Pop',
      'Blanco y negro',
    ]) {
      expect(find.text(nombre), findsOneWidget);
    }

    await tester.tap(find.text('Faro'));
    await tester.pumpAndSettle();

    expect(_primario(tester), Paleta.faro.claro.primario);
    expect(almacen.guardado, 'faro');
    final cambio = eventos.singleWhere((e) => e['name'] == 'theme_change');
    expect(cambio['props'], {'theme': 'faro'});
  });

  testWidgets('Blanco y negro: las barras de arriba y de abajo son blancas', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        perfiles: PerfilRepositorioFalso(plan: Plan.pro),
        funcionalidades: _temasPro(),
        almacenTema: AlmacenTemaFalso('blanco_negro'),
      ),
    );
    await tester.pumpAndSettle();

    final tema = Theme.of(tester.element(find.byType(Scaffold).first));
    expect(tema.appBarTheme.backgroundColor, const Color(0xFFFFFFFF));
    expect(tema.appBarTheme.foregroundColor, const Color(0xFF111111));
    final barraAbajo = tester.widget<PhysicalShape>(
      find.byWidgetPredicate(
        (w) =>
            w is PhysicalShape && '${w.clipper.runtimeType}' == '_RecorteBarra',
      ),
    );
    expect(barraAbajo.color, const Color(0xFFFFFFFF));
  });

  testWidgets('con plan Familia arranca con el tema guardado', (tester) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        perfiles: PerfilRepositorioFalso(plan: Plan.family),
        funcionalidades: _temasPro(),
        almacenTema: AlmacenTemaFalso('vecinos'),
      ),
    );
    await tester.pumpAndSettle();

    expect(_primario(tester), Paleta.vecinos.claro.primario);
  });

  testWidgets('con plan Pro pero temas_pro apagada no aparece y se ve Cielo', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        perfiles: PerfilRepositorioFalso(plan: Plan.pro),
        almacenTema: AlmacenTemaFalso('pop'),
        eventos: eventos,
      ),
    );
    await _abrirAjustes(tester);

    expect(find.text('Tema de colores'), findsNothing);
    expect(_primario(tester), Paleta.cielo.claro.primario);
    // Ajustes muestra otras funcionalidades graduales: solo la de temas.
    final exposicion = eventos.singleWhere(
      (e) =>
          e['name'] == 'feature_exposure' &&
          (e['props']! as Map)['key'] == 'temas_pro',
    );
    expect(exposicion['props'], {'key': 'temas_pro', 'variante': 'apagada'});
  });

  testWidgets('un visitante ve Cielo', (tester) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        funcionalidades: _temasPro(),
        almacenTema: AlmacenTemaFalso('pop'),
      ),
    );
    await tester.pumpAndSettle();

    expect(_primario(tester), Paleta.cielo.claro.primario);
  });

  test('un id desconocido vuelve a Cielo', () {
    expect(Paleta.porId('naranja'), Paleta.cielo);
    expect(Paleta.porId(null), Paleta.cielo);
    expect(Paleta.porId('pop'), Paleta.pop);
  });

  test('cada tema Pro trae sus tipografías para descargar; Huellitas no', () {
    expect(Paleta.cielo.fuentesADescargar, isEmpty);
    // Las de Huellitas (Nunito y Nunito Sans) ya vienen con la app.
    const incluidas = {'Nunito', 'NunitoSans'};
    for (final p in [Paleta.faro, Paleta.vecinos, Paleta.pop]) {
      final familias = p.fuentesADescargar.map((a) => a.familia).toSet();
      expect(
        familias,
        {p.fuenteTitulos, p.fuenteTexto}.difference(incluidas),
        reason: p.id,
      );
      for (final a in p.fuentesADescargar) {
        expect(File('web/fuentes/${a.archivo}').existsSync(), isTrue);
      }
    }
  });
}
