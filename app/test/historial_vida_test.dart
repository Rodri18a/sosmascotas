import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'historial_falso.dart';
import 'mascotas_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');
const _luna = Mascota(id: 'm1', nombre: 'Luna', especieId: 2, duenoId: 'u1');

final _pdf = Uint8List.fromList(utf8.encode('%PDF-1.4 estudio'));

Future<List<Map<String, Object?>>> _abrirFicha(
  WidgetTester tester,
  HistorialFalso historial, {
  Uint8List? documento,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final eventos = <Map<String, Object?>>[];
  await tester.pumpWidget(
    appDePrueba(
      inicio: Rutas.fichaMascota(_luna.id),
      cuenta: ServicioCuentaFalso(conectado: _ana),
      mascotas: MascotasFalsas([_luna]),
      historial: historial,
      eventos: eventos,
      selectorFoto: (_) async =>
          img.encodeJpg(img.Image(width: 40, height: 30)),
      selectorDocumento: () async => documento,
      funcionalidades: FuncionalidadesFalsas({Funcionalidades.historial}),
    ),
  );
  await tester.pumpAndSettle();
  return eventos;
}

/// Baja hasta [objetivo] si todavía no se armó (la ficha es una lista larga).
Future<void> _ver(WidgetTester tester, Finder objetivo) async {
  if (objetivo.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      objetivo,
      300,
      scrollable: find.byType(Scrollable).first,
    );
  }
  await tester.ensureVisible(objetivo);
}

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  await _ver(tester, objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('cargar una operación con una foto y un PDF', (tester) async {
    final historial = HistorialFalso();
    final eventos = await _abrirFicha(tester, historial, documento: _pdf);
    await _ver(tester, find.text('Historial de vida'));
    await _tocar(tester, find.text('Agregar al historial'));

    await _tocar(tester, find.widgetWithText(ChoiceChip, 'Operación'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Título'),
      'Castración',
    );
    await _tocar(tester, find.text('Foto'));
    await _tocar(tester, find.text('Elegir de la galería'));
    await _tocar(tester, find.text('PDF'));
    expect(find.text('Fotos y documentos (2 de 4)'), findsOneWidget);
    await _tocar(tester, find.text('Guardar'));

    expect(historial.guardados.single.titulo, 'Castración');
    expect(historial.guardados.single.tipo, TipoAcontecimiento.surgery);
    expect(historial.guardados.single.adjuntos, ['m1/a0.jpg', 'm1/a1.pdf']);
    // De vuelta en la ficha, en la línea de tiempo.
    expect(find.text('Castración'), findsOneWidget);
    expect(find.text('Adjunto 2'), findsOneWidget);
    expect(
      eventos.where((e) => e['name'] == 'life_event_create').single['props'],
      {'kind': 'surgery'},
    );
    expect(
      eventos
          .where((e) => e['name'] == 'life_event_file_add')
          .map((e) => (e['props']! as Map)['type']),
      ['photo', 'pdf'],
    );
  });

  testWidgets('un archivo que no es PDF no se suma; hasta 4 adjuntos', (
    tester,
  ) async {
    final historial = HistorialFalso([
      AcontecimientoVida(
        id: 'v1',
        mascotaId: 'm1',
        tipo: TipoAcontecimiento.illness,
        titulo: 'Otitis',
        fecha: DateTime(2026, 5, 3),
        adjuntos: const ['m1/x.jpg', 'm1/y.jpg', 'm1/z.pdf'],
      ),
    ]);
    await _abrirFicha(
      tester,
      historial,
      documento: Uint8List.fromList(utf8.encode('no soy un pdf')),
    );
    await _tocar(tester, find.text('Otitis'));
    await _tocar(tester, find.text('PDF'));
    expect(find.text('Ese archivo no se puede usar.'), findsOneWidget);

    await _tocar(tester, find.text('Foto'));
    await _tocar(tester, find.text('Elegir de la galería'));
    expect(find.text('Fotos y documentos (4 de 4)'), findsOneWidget);
    expect(
      find.text('Llegaste a 4: quitá uno para sumar otro.'),
      findsOneWidget,
    );
    final foto = tester.widget<OutlinedButton>(
      find.ancestor(
        of: find.text('Foto'),
        matching: find.byType(OutlinedButton),
      ),
    );
    expect(foto.onPressed, isNull);
  });

  testWidgets('quitar un adjunto lo borra al guardar; borrar borra todo', (
    tester,
  ) async {
    final historial = HistorialFalso([
      AcontecimientoVida(
        id: 'v1',
        mascotaId: 'm1',
        tipo: TipoAcontecimiento.accident,
        titulo: 'Fractura',
        fecha: DateTime(2026, 1, 9),
        adjuntos: const ['m1/rx.pdf', 'm1/pata.jpg'],
      ),
    ]);
    await _abrirFicha(tester, historial);
    await _tocar(tester, find.text('Fractura'));
    await _tocar(tester, find.byTooltip('Quitar').first);
    await _tocar(tester, find.text('Guardar'));
    expect(historial.guardados.single.adjuntos, ['m1/pata.jpg']);
    expect(historial.borrados, ['m1/rx.pdf']);

    await _tocar(tester, find.text('Fractura'));
    await _tocar(tester, find.text('Borrar del historial'));
    await _tocar(tester, find.widgetWithText(FilledButton, 'Borrar'));
    expect(historial.guardados, isEmpty);
    expect(historial.borrados, ['m1/rx.pdf', 'm1/pata.jpg']);
    expect(find.text('Fractura'), findsNothing);
  });

  testWidgets('un adjunto se abre con un enlace que vence', (tester) async {
    final historial = HistorialFalso([
      AcontecimientoVida(
        id: 'v1',
        mascotaId: 'm1',
        tipo: TipoAcontecimiento.diagnosis,
        titulo: 'Ecografía',
        fecha: DateTime(2026, 2, 1),
        adjuntos: const ['m1/eco.pdf'],
      ),
    ]);
    final abiertos = <Uri>[];
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      appDePrueba(
        inicio: Rutas.fichaMascota(_luna.id),
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas([_luna]),
        historial: historial,
        enlacesAbiertos: abiertos,
        funcionalidades: FuncionalidadesFalsas({Funcionalidades.historial}),
      ),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.widgetWithText(ActionChip, 'Adjunto 1'));
    expect(abiertos, [Uri.parse('https://firmado/m1/eco.pdf')]);
  });
}
