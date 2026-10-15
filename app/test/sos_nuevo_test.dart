import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/sos/sos_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'helpers.dart';
import 'mascotas_falsas.dart';
import 'sos_falso.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');
const _luna = Mascota(
  id: 'm1',
  nombre: 'Luna',
  especieId: 2,
  razaId: 3,
  sexo: Sexo.female,
  color: 'Blanca',
  fotoPath: 'u1/luna.jpg',
  microchip: '858000000123456',
);

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _ver(WidgetTester tester, Finder objetivo) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
}

Future<void> _abrirFormulario(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(of: find.byType(NavigationBar), matching: find.text('SOS')),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(FloatingActionButton, 'Reportar'));
  await tester.pumpAndSettle();
}

Future<void> _publicar(WidgetTester tester) async {
  final publicar = find.widgetWithText(FilledButton, 'Publicar');
  await _ver(tester, publicar);
  await tester.tap(publicar);
  await tester.pumpAndSettle();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('perdí a Luna: se precarga su ficha y se publica con su foto', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final sos = SosFalso();
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas([_luna]),
        sos: sos,
      ),
    );
    await _abrirFormulario(tester);

    await tester.tap(find.widgetWithText(ChoiceChip, 'Luna'));
    await tester.pumpAndSettle();
    expect(find.text('Foto de su ficha'), findsOneWidget);

    await _ver(tester, find.byKey(const ValueKey('mapa-tocar')));
    await tester.tap(find.byKey(const ValueKey('mapa-tocar')));
    await tester.pumpAndSettle();
    expect(find.text('Lugar marcado ✔'), findsOneWidget);

    await _publicar(tester);

    final publicado = sos.creados.single;
    expect(publicado.tipo, TipoSos.perdida);
    expect(publicado.mascotaId, 'm1');
    expect(publicado.especieId, 2);
    expect(publicado.razaId, 3);
    expect(publicado.nombre, 'Luna');
    expect(publicado.tieneMicrochip, isTrue);
    expect(publicado.fotos, ['pet-photos/u1/luna.jpg']);
    expect(publicado.ubicacion, const Punto(-34.72, -55.95));
    expect(find.widgetWithText(AppBar, 'Reporte'), findsOneWidget);
    // Se avisa a quienes están cerca (Edge Function sos-zone-alert).
    expect(sos.difundidos, ['sos-1']);
  });

  testWidgets('encontré una mascota: pide foto, lugar y especie', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final sos = SosFalso();
    final foto = Uint8List.fromList(
      img.encodeJpg(img.Image(width: 20, height: 20)),
    );
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        sos: sos,
        selectorFoto: (_) async => foto,
      ),
    );
    await _abrirFormulario(tester);
    await tester.tap(find.text('Encontré una mascota'));
    await tester.pumpAndSettle();

    await _publicar(tester);
    expect(find.text('Elegí la especie.'), findsOneWidget);
    expect(sos.creados, isEmpty);

    await _ver(tester, find.text('🐶 Perro'));
    await tester.tap(find.text('🐶 Perro'));
    await tester.pumpAndSettle();
    await _publicar(tester);
    expect(find.text('Agregá al menos una foto.'), findsOneWidget);

    await _ver(tester, find.text('Agregar foto'));
    await tester.tap(find.text('Agregar foto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elegir de la galería'));
    await tester.pumpAndSettle();
    await _publicar(tester);
    expect(find.text('Marcá en el mapa dónde fue.'), findsOneWidget);

    await _ver(tester, find.byKey(const ValueKey('mapa-tocar')));
    await tester.tap(find.byKey(const ValueKey('mapa-tocar')));
    await tester.pumpAndSettle();
    await _publicar(tester);

    final publicado = sos.creados.single;
    expect(publicado.tipo, TipoSos.encontrada);
    expect(publicado.mascotaId, isNull);
    expect(publicado.fotos, ['sos-photos/u1/foto-1.jpg']);
    expect(sos.fotosSubidas, hasLength(1));
  });

  testWidgets('avisa si ya publicó 3 reportes hoy', (tester) async {
    _pantallaDeCelular(tester);
    final sos = SosFalso()..fallarCon = ErrorSos.limiteDiario;
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas([_luna]),
        sos: sos,
      ),
    );
    await _abrirFormulario(tester);
    await tester.tap(find.widgetWithText(ChoiceChip, 'Luna'));
    await tester.pumpAndSettle();
    await _ver(tester, find.byKey(const ValueKey('mapa-tocar')));
    await tester.tap(find.byKey(const ValueKey('mapa-tocar')));
    await tester.pumpAndSettle();

    await _publicar(tester);

    expect(find.textContaining('Ya publicaste 3 reportes hoy'), findsOneWidget);
  });

  testWidgets('desde la ficha, "Se perdió" abre el formulario con sus datos', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas([_luna]),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Mis mascotas'),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ListTile, 'Luna'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Se perdió: reportarla'),
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Se perdió: reportarla'));
    await tester.pumpAndSettle();

    expect(find.widgetWithText(AppBar, 'Nuevo reporte'), findsOneWidget);
    expect(find.text('Foto de su ficha'), findsOneWidget);
  });
}
