import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota/src/sos/cartel_sos_pdf.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'helpers.dart';
import 'sos_falso.dart';

ByteData _fuente(String nombre) =>
    ByteData.sublistView(File('assets/fuentes/$nombre.ttf').readAsBytesSync());

SosDetalle _detalle({EstadoSos estado = EstadoSos.activo}) => SosDetalle(
  id: 's1',
  tipo: TipoSos.perdida,
  estado: estado,
  especie: 'Perro',
  especieIcono: '🐶',
  nombre: 'Firulais',
  cuando: DateTime(2026, 10, 13),
  zona: const Punto(-34.72, -55.95),
  fotos: const [],
  esMio: false,
);

final _enLista = SosResumen(
  id: 's1',
  tipo: TipoSos.perdida,
  especie: 'Perro',
  especieIcono: '🐶',
  nombre: 'Firulais',
  cuando: DateTime(2026, 10, 13),
  distanciaMetros: 300,
);

Future<void> _abrirDetalle(WidgetTester tester, SosDetalle detalle) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      sos: SosFalso(listaCercanos: [_enLista], detalles: {'s1': detalle}),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(of: find.byType(BarraInferior), matching: find.text('SOS')),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Se perdió: Firulais'));
  await tester.pumpAndSettle();
}

void main() {
  test('arma un cartel A4 con acentos, sin foto y con el QR', () async {
    final bytes = await cartelSosPdf(
      url: 'https://sosmascota.uy/s/s1',
      perdida: true,
      foto: switch (Platform.environment['CARTEL_FOTO']) {
        final ruta? => File(ruta).readAsBytesSync(),
        null => null,
      },
      normal: _fuente('NunitoSans-Regular'),
      negrita: _fuente('NunitoSans-Bold'),
      textos: (
        titulo: 'SE BUSCA',
        subtitulo: 'Firulais',
        datos: 'Perro · Labrador · Macho · Negro',
        senas: 'Señas: collar rojo',
        descripcion: 'Es miedoso con los fuegos artificiales.',
        cuando: 'Falta desde el 13 de octubre',
        donde: 'Vista por última vez: Centro, cerca de la plaza',
        escanea: '¿La viste? Escaneá el QR.',
        privacidad: 'No hace falta la app.',
        pie: 'Huellitas · sosmascota.uy/s/s1',
      ),
    );
    expect(latin1.decode(bytes.sublist(0, 5)), '%PDF-');
    final salida = Platform.environment['CARTEL_SALIDA'];
    if (salida != null) File(salida).writeAsBytesSync(bytes);
  });

  testWidgets('en un reporte activo se arma el cartel, con dónde la vieron', (
    tester,
  ) async {
    await _abrirDetalle(tester, _detalle());
    final boton = find.text('Imprimir cartel');
    await tester.scrollUntilVisible(
      boton,
      150,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.ensureVisible(boton);
    await tester.pumpAndSettle();
    await tester.tap(boton);
    await tester.pumpAndSettle();

    expect(find.textContaining('No lleva tu teléfono'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Centro');
    await tester.tap(find.text('Armar el cartel'));
    await tester.pumpAndSettle();
    // En las pruebas no hay navegador: avisa que se descarga desde la web.
    expect(find.textContaining('Probá desde la web'), findsOneWidget);
  });

  testWidgets('en un reporte resuelto no hay cartel', (tester) async {
    await _abrirDetalle(tester, _detalle(estado: EstadoSos.resuelto));
    expect(find.text('Imprimir cartel'), findsNothing);
  });
}
