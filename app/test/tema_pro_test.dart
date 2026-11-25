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

/// Un texto dentro del selector de temas (la fila de Ajustes también dice
/// el nombre del tema elegido).
Finder _enSelector(String texto) =>
    find.descendant(of: find.byType(BottomSheet), matching: find.text(texto));

Future<void> _abrirAjustes(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await abrirAjustesDesdeMenu(tester);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('con plan Gratis se elige entre Moderno y Huellamy; un tema '
      'Pro guardado vuelve al de por defecto (Moderno)', (tester) async {
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

    expect(_primario(tester), Paleta.moderno.claro.primario);
    await tester.tap(find.text('Tema de colores'));
    await tester.pumpAndSettle();
    expect(_enSelector('Huellamy'), findsOneWidget);
    expect(_enSelector('Moderno'), findsOneWidget);
    for (final pro in ['Faro', 'Vecinos', 'Pop', 'Blanco y negro']) {
      expect(find.text(pro), findsNothing);
    }
  });

  testWidgets('Moderno viene por defecto (D172) y sin plan se puede volver '
      'a Huellamy, sin «beneficio de tu plan Pro»', (tester) async {
    _pantallaDeCelular(tester);
    final almacen = AlmacenTemaFalso();
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        almacenTema: almacen,
      ),
    );
    await _abrirAjustes(tester);
    await tester.tap(find.text('Tema de colores'));
    await tester.pumpAndSettle();
    expect(_primario(tester), Paleta.moderno.claro.primario);
    await tester.tap(_enSelector('Huellamy'));
    await tester.pumpAndSettle();

    expect(_primario(tester), Paleta.cielo.claro.primario);
    expect(almacen.guardado, 'cielo');
    await tester.tapAt(const Offset(20, 20));
    await tester.pumpAndSettle();
    expect(find.text('Huellamy'), findsOneWidget);
    expect(find.textContaining('beneficio de tu plan Pro'), findsNothing);
  });

  testWidgets('un visitante también elige el tema desde Ajustes', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final almacen = AlmacenTemaFalso();
    await tester.pumpWidget(appDePrueba(almacenTema: almacen));
    await _abrirAjustes(tester);
    await tester.tap(find.text('Tema de colores'));
    await tester.pumpAndSettle();
    await tester.tap(_enSelector('Huellamy'));
    await tester.pumpAndSettle();

    expect(_primario(tester), Paleta.cielo.claro.primario);
    expect(almacen.guardado, 'cielo');
  });

  testWidgets('quien eligió Huellamy arranca con Huellamy', (tester) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(almacenTema: AlmacenTemaFalso('cielo')),
    );
    await tester.pumpAndSettle();

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

    expect(find.text('Moderno'), findsOneWidget);
    await tester.tap(find.text('Tema de colores'));
    await tester.pumpAndSettle();
    expect(find.text('Elegí cómo se ve la app'), findsOneWidget);
    for (final nombre in [
      'Huellamy',
      'Moderno',
      'Faro',
      'Vecinos',
      'Pop',
      'Blanco y negro',
    ]) {
      expect(_enSelector(nombre), findsOneWidget);
    }

    await tester.tap(_enSelector('Faro'));
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

  testWidgets('con plan Pro pero temas_pro apagada solo están Huellamy y '
      'Moderno, y un tema Pro guardado vuelve a Moderno', (tester) async {
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

    expect(_primario(tester), Paleta.moderno.claro.primario);
    await tester.tap(find.text('Tema de colores'));
    await tester.pumpAndSettle();
    expect(_enSelector('Moderno'), findsOneWidget);
    expect(find.text('Pop'), findsNothing);
    // Ajustes muestra otras funcionalidades graduales: solo la de temas.
    final exposicion = eventos.singleWhere(
      (e) =>
          e['name'] == 'feature_exposure' &&
          (e['props']! as Map)['key'] == 'temas_pro',
    );
    expect(exposicion['props'], {'key': 'temas_pro', 'variante': 'apagada'});
  });

  testWidgets('un visitante con un tema Pro guardado ve Moderno', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        funcionalidades: _temasPro(),
        almacenTema: AlmacenTemaFalso('pop'),
      ),
    );
    await tester.pumpAndSettle();

    expect(_primario(tester), Paleta.moderno.claro.primario);
  });

  test('un id desconocido vuelve a Cielo', () {
    expect(Paleta.porId('naranja'), Paleta.cielo);
    expect(Paleta.porId(null), Paleta.cielo);
    expect(Paleta.porId('pop'), Paleta.pop);
  });

  test('cada tema Pro trae sus tipografías para descargar; Huellamy no', () {
    expect(Paleta.cielo.fuentesADescargar, isEmpty);
    // Las de Huellamy (Nunito y Nunito Sans) ya vienen con la app.
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
