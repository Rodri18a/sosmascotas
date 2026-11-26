import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/mapa/mapa_screen.dart';
import 'package:sosmascota/src/features/renac/renac.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'mascotas_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

/// Abre la ficha de [mascota] con la funcionalidad `renac` [prendida] o no.
Future<void> _abrirFicha(
  WidgetTester tester, {
  required MascotasFalsas mascotas,
  required String nombre,
  bool prendida = true,
  List<Map<String, Object?>>? eventos,
  List<Uri>? enlaces,
}) async {
  _pantallaDeCelular(tester);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      mascotas: mascotas,
      funcionalidades: FuncionalidadesFalsas({
        if (prendida) Funcionalidades.renac,
      }),
      eventos: eventos,
      enlacesAbiertos: enlaces,
      ahora: DateTime(2026, 10, 23, 10),
    ),
  );
  await tester.pumpAndSettle();
  await _tocar(
    tester,
    find.descendant(
      of: find.byType(BarraInferior),
      matching: find.text('Mascotas'),
    ),
  );
  await _tocar(tester, find.widgetWithText(ListTile, nombre));
  expect(find.widgetWithText(AppBar, nombre), findsOneWidget);
}

void main() {
  testWidgets('apagada: ni la tarjeta ni la pregunta del formulario', (
    tester,
  ) async {
    await _abrirFicha(
      tester,
      mascotas: MascotasFalsas([
        const Mascota(id: 'm1', nombre: 'Toby', especieId: 1),
      ]),
      nombre: 'Toby',
      prendida: false,
    );
    expect(find.byType(TarjetaRenac), findsNothing);
    await _tocar(tester, find.byTooltip('Editar'));
    expect(find.text('¿Está registrada en el RENAC?'), findsNothing);
  });

  testWidgets('un ave no tiene RENAC', (tester) async {
    await _abrirFicha(
      tester,
      mascotas: MascotasFalsas([
        const Mascota(id: 'm1', nombre: 'Pipo', especieId: 10),
      ]),
      nombre: 'Pipo',
    );
    expect(find.byType(TarjetaRenac), findsNothing);
  });

  testWidgets('sin registrar: recuerda, abre la guía y "Ya la registré" lo '
      'guarda', (tester) async {
    final mascotas = MascotasFalsas([
      const Mascota(
        id: 'm1',
        nombre: 'Toby',
        especieId: 1,
        renac: EstadoRenac.notRegistered,
      ),
    ]);
    final eventos = <Map<String, Object?>>[];
    final enlaces = <Uri>[];
    await _abrirFicha(
      tester,
      mascotas: mascotas,
      nombre: 'Toby',
      eventos: eventos,
      enlaces: enlaces,
    );
    expect(find.text('No está registrada en el RENAC'), findsOneWidget);
    expect(find.textContaining('Registrar a Toby'), findsOneWidget);

    await _tocar(tester, find.text('Verificar en el RENAC'));
    expect(enlaces.single, consultaRenac);
    expect(
      eventos.where((e) => e['name'] == 'renac_verify_click'),
      hasLength(1),
    );

    await _tocar(tester, find.text('Cómo registrarla'));
    expect(find.widgetWithText(AppBar, 'Registro nacional'), findsOneWidget);
    expect(eventos.where((e) => e['name'] == 'renac_guide_open'), hasLength(1));
    await _tocar(tester, find.byType(BackButton));

    await _tocar(tester, find.text('Ya la registré'));
    expect(mascotas.mascotas.single.renac, EstadoRenac.registered);
    expect(find.text('Registrada en el RENAC'), findsOneWidget);
    expect(find.text('Ya la registré'), findsNothing);
    expect(
      eventos.where((e) => e['name'] == 'renac_status_set').single['props'],
      {'estado': 'registered'},
    );
  });

  testWidgets('cachorro de menos de 90 días: no insiste', (tester) async {
    await _abrirFicha(
      tester,
      mascotas: MascotasFalsas([
        Mascota(
          id: 'm1',
          nombre: 'Toby',
          especieId: 1,
          nacimiento: DateTime(2026, 9, 1),
        ),
      ]),
      nombre: 'Toby',
    );
    expect(find.text('¿Está registrada en el RENAC?'), findsOneWidget);
    expect(find.textContaining('a partir de los 90 días'), findsOneWidget);
    expect(find.textContaining('Registrar a Toby'), findsNothing);
  });

  testWidgets('el formulario guarda el estado declarado', (tester) async {
    final mascotas = MascotasFalsas([
      const Mascota(id: 'm1', nombre: 'Michi', especieId: 2),
    ]);
    final eventos = <Map<String, Object?>>[];
    await _abrirFicha(
      tester,
      mascotas: mascotas,
      nombre: 'Michi',
      eventos: eventos,
    );
    await _tocar(tester, find.byTooltip('Editar'));
    final noSe = find.descendant(
      of: find.byType(SegmentedButton<EstadoRenac?>),
      matching: find.text('No sé'),
    );
    await _tocar(tester, noSe);
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));

    expect(mascotas.mascotas.single.renac, EstadoRenac.unknown);
    expect(
      find.text('No sabés si está registrada en el RENAC'),
      findsOneWidget,
    );
    expect(
      eventos.where((e) => e['name'] == 'renac_status_set').single['props'],
      {'estado': 'unknown'},
    );
  });

  testWidgets('la guía lleva al mapa con "Coloca microchip" puesto', (
    tester,
  ) async {
    await _abrirFicha(
      tester,
      mascotas: MascotasFalsas([
        const Mascota(id: 'm1', nombre: 'Toby', especieId: 1),
      ]),
      nombre: 'Toby',
    );
    await _tocar(tester, find.text('Cómo registrarla'));
    await _tocar(tester, find.text('Ver veterinarias que colocan microchip'));
    final mapa = tester.widget<MapaScreen>(find.byType(MapaScreen));
    expect(mapa.colocaMicrochip, isTrue);
  });
}
