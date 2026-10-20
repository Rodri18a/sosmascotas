import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'helpers.dart';
import 'mascotas_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Lleva [objetivo] a la vista (el formulario construye todos sus campos).
Future<void> _verHasta(WidgetTester tester, Finder objetivo) async {
  // Sin foco: si no, el campo enfocado vuelve a desplazar la pantalla hacia él.
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
}

Future<void> _irAMisMascotas(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Mis mascotas'),
    ),
  );
  await tester.pumpAndSettle();
}

/// Una foto con ubicación GPS, como las que saca un celular.
Uint8List _fotoConGps() {
  final foto = img.Image(width: 40, height: 30)
    ..exif.gpsIfd.gpsLatitude = -34.7171
    ..exif.gpsIfd.gpsLongitude = -55.9581;
  return img.encodeJpg(foto);
}

const _luna = Mascota(
  id: 'm1',
  nombre: 'Luna',
  especieId: 2,
  razaId: 3,
  sexo: Sexo.female,
);
const _toto = Mascota(id: 'm2', nombre: 'Toto', especieId: 1, razaId: 2);

void main() {
  testWidgets('cargar una mascota con foto: se sube sin GPS y se ve su ficha', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final mascotas = MascotasFalsas();
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: mascotas,
        eventos: eventos,
        selectorFoto: (_) async => _fotoConGps(),
      ),
    );
    await _irAMisMascotas(tester);
    expect(find.textContaining('Todavía no cargaste'), findsOneWidget);

    await tester.tap(find.text('Agregar mascota'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Nueva mascota'), findsOneWidget);

    await tester.tap(find.text('Agregar foto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elegir de la galería'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre'),
      'Firulais',
    );
    await tester.tap(find.text('🐶 Perro'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(DropdownButtonFormField<int>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Labrador').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Macho'));

    final microchip = find.widgetWithText(TextFormField, 'Microchip');
    await _verHasta(tester, microchip);
    await tester.enterText(microchip, '858 000 000 123 456');

    final guardar = find.widgetWithText(FilledButton, 'Guardar');
    await _verHasta(tester, guardar);
    await tester.tap(guardar);
    await tester.pumpAndSettle();

    final guardada = mascotas.mascotas.single;
    expect(guardada.nombre, 'Firulais');
    expect(guardada.especieId, 1);
    expect(guardada.razaId, 2);
    expect(guardada.sexo, Sexo.male);
    expect(guardada.microchip, '858000000123456');
    expect(guardada.fotoPath, isNotNull);
    final subida = img.decodeJpg(mascotas.fotosSubidas.single)!;
    expect(
      subida.exif.gpsIfd.isEmpty,
      isTrue,
      reason: 'la foto no debe tener GPS',
    );
    expect(eventos.map((e) => e['name']), contains('pet_create'));

    expect(find.widgetWithText(AppBar, 'Firulais'), findsOneWidget);
    expect(find.text('Labrador'), findsOneWidget);
    expect(find.text('858000000123456'), findsOneWidget);
  });

  testWidgets('pide nombre y especie, y valida el microchip', (tester) async {
    _pantallaDeCelular(tester);
    final mascotas = MascotasFalsas();
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: mascotas,
      ),
    );
    await _irAMisMascotas(tester);
    await tester.tap(find.text('Agregar mascota'));
    await tester.pumpAndSettle();

    final microchip = find.widgetWithText(TextFormField, 'Microchip');
    await _verHasta(tester, microchip);
    await tester.enterText(microchip, '12345');
    final guardar = find.widgetWithText(FilledButton, 'Guardar');
    await _verHasta(tester, guardar);
    await tester.tap(guardar);
    await tester.pumpAndSettle();

    expect(find.text('Elegí la especie.'), findsOneWidget);
    expect(mascotas.mascotas, isEmpty);

    await _verHasta(tester, find.text('🐱 Gato'));
    await tester.tap(find.text('🐱 Gato'));
    await tester.pumpAndSettle();
    await _verHasta(tester, guardar);
    await tester.tap(guardar);
    await tester.pumpAndSettle();

    expect(find.text('El microchip tiene 15 números.'), findsOneWidget);
    // Volver arriba del todo, donde está el nombre.
    await tester.drag(
      find.byType(SingleChildScrollView).first,
      const Offset(0, 3000),
    );
    await tester.pumpAndSettle();
    expect(find.text('Escribí el nombre de tu mascota.'), findsOneWidget);
    expect(mascotas.mascotas, isEmpty);
  });

  testWidgets('editar y borrar una mascota', (tester) async {
    _pantallaDeCelular(tester);
    final mascotas = MascotasFalsas([_luna]);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: mascotas,
      ),
    );
    await _irAMisMascotas(tester);
    await tester.tap(find.widgetWithText(ListTile, 'Luna'));
    await tester.pumpAndSettle();
    expect(find.text('Siamés'), findsOneWidget);

    await tester.tap(find.byTooltip('Editar'));
    await tester.pumpAndSettle();
    final color = find.widgetWithText(TextFormField, 'Color');
    await _verHasta(tester, color);
    await tester.enterText(color, 'Blanca y gris');
    final guardar = find.widgetWithText(FilledButton, 'Guardar');
    await _verHasta(tester, guardar);
    await tester.tap(guardar);
    await tester.pumpAndSettle();
    expect(mascotas.mascotas.single.color, 'Blanca y gris');
    expect(mascotas.mascotas.single.sexo, Sexo.female, reason: 'no se pierde');

    await tester.tap(find.byTooltip('Editar'));
    await tester.pumpAndSettle();
    final borrar = find.text('Borrar mascota');
    await _verHasta(tester, borrar);
    await tester.tap(borrar);
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Borrar'));
    await tester.pumpAndSettle();

    expect(mascotas.mascotas, isEmpty);
    expect(find.widgetWithText(AppBar, 'Mis mascotas'), findsOneWidget);
  });

  testWidgets('salir con una foto sin guardar pregunta antes', (tester) async {
    _pantallaDeCelular(tester);
    final mascotas = MascotasFalsas([_luna]);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: mascotas,
        selectorFoto: (_) async => _fotoConGps(),
      ),
    );
    await _irAMisMascotas(tester);
    await tester.tap(find.widgetWithText(ListTile, 'Luna'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Editar'));
    await tester.pumpAndSettle();

    // Sin cambios (solo tocar un campo) sale directo.
    await tester.tap(find.widgetWithText(TextFormField, 'Nombre'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('¿Salir sin guardar?'), findsNothing);
    expect(find.widgetWithText(AppBar, 'Luna'), findsOneWidget);

    await tester.tap(find.byTooltip('Editar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Agregar foto'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Elegir de la galería'));
    await tester.pumpAndSettle();

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    expect(find.text('¿Salir sin guardar?'), findsOneWidget);
    await tester.tap(find.text('Seguir editando'));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Editar mascota'), findsOneWidget);

    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Salir sin guardar').last);
    await tester.pumpAndSettle();
    expect(find.widgetWithText(AppBar, 'Luna'), findsOneWidget);
    expect(mascotas.fotosSubidas, isEmpty);
    expect(mascotas.mascotas.single.fotoPath, isNull);
  });

  testWidgets('la fila superior elige la mascota activa', (tester) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas([_luna, _toto]),
      ),
    );
    await _irAMisMascotas(tester);

    Text nombreEnFila(String nombre) => tester.widget<Text>(
      find
          .descendant(of: find.byType(Semantics), matching: find.text(nombre))
          .first,
    );
    expect(nombreEnFila('Luna').style?.fontWeight, FontWeight.bold);

    await tester.tap(find.text('Toto').first);
    await tester.pumpAndSettle();

    expect(nombreEnFila('Toto').style?.fontWeight, FontWeight.bold);
    expect(nombreEnFila('Luna').style?.fontWeight, FontWeight.normal);
  });

  testWidgets('un visitante ve la invitación a cargar su mascota', (
    tester,
  ) async {
    await tester.pumpWidget(appDePrueba());
    await _irAMisMascotas(tester);

    expect(find.text('Agregar mascota'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsNothing);
  });
}
