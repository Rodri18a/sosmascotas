import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/mapa/buscar_lugares.dart';
import 'package:sosmascota/src/features/mapa/ficha_comercio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

const _vet = Comercio(
  id: 'vet',
  nombre: 'Veterinaria San Roque',
  punto: Punto(-34.717, -55.958),
  horario: Horario({}),
);
const _pelu = Comercio(
  id: 'pelu',
  nombre: 'Guau Estética',
  tipo: 'grooming',
  punto: Punto(-34.720, -55.950),
  horario: Horario({}),
);

/// Abre el mapa con la búsqueda [prendida] o no.
Future<void> _abrirMapa(
  WidgetTester tester, {
  required ComerciosFalsos comercios,
  bool prendida = true,
  Set<String> otras = const {},
  List<Map<String, Object?>>? eventos,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      comercios: comercios,
      funcionalidades: FuncionalidadesFalsas({
        if (prendida) Funcionalidades.busqueda,
        ...otras,
      }),
      eventos: eventos,
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _buscar(WidgetTester tester, String texto) async {
  await tester.tap(find.byTooltip('Buscar lugares'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byType(TextField), texto);
  // Pausa entre letras y la de la métrica.
  await tester.pump(const Duration(milliseconds: 500));
  await tester.pump(const Duration(milliseconds: 1600));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('apagada: el mapa no tiene la lupa', (tester) async {
    await _abrirMapa(tester, comercios: ComerciosFalsos(), prendida: false);
    expect(find.byTooltip('Buscar lugares'), findsNothing);
  });

  testWidgets('por nombre, sin tildes, y abre la ficha', (tester) async {
    final comercios = ComerciosFalsos([_vet, _pelu]);
    final eventos = <Map<String, Object?>>[];
    await _abrirMapa(tester, comercios: comercios, eventos: eventos);
    await _buscar(tester, 'san roque');

    expect(find.byType(BuscarLugaresScreen), findsOneWidget);
    expect(find.text('Veterinaria San Roque'), findsOneWidget);
    expect(find.text('Guau Estética'), findsNothing);
    final busqueda = eventos.where((e) => e['name'] == 'search').single;
    expect(busqueda['props'], {'resultados': 1});
    expect(busqueda['zone_id'], 1);

    await tester.tap(find.text('Veterinaria San Roque'));
    await tester.pumpAndSettle();
    expect(find.byType(FichaComercio), findsOneWidget);
  });

  testWidgets('por rubro: "peluquería" encuentra la estética', (tester) async {
    final comercios = ComerciosFalsos([_vet, _pelu]);
    final eventos = <Map<String, Object?>>[];
    await _abrirMapa(tester, comercios: comercios, eventos: eventos);
    await _buscar(tester, 'Peluquería');

    expect(comercios.busquedas.last, ('Peluquería', Categoria.grooming));
    expect(find.text('Guau Estética'), findsOneWidget);
    expect(find.textContaining('Incluye peluquerías'), findsOneWidget);
    expect(eventos.where((e) => e['name'] == 'search').single['props'], {
      'rubro': 'grooming',
      'resultados': 1,
    });
  });

  testWidgets('sin resultados: guarda el texto sin números y ofrece marcar', (
    tester,
  ) async {
    final eventos = <Map<String, Object?>>[];
    await _abrirMapa(
      tester,
      comercios: ComerciosFalsos([_vet]),
      otras: {Funcionalidades.comercios},
      eventos: eventos,
    );
    await _buscar(tester, 'Fisioterapia 099123456');

    expect(find.textContaining('No encontramos lugares'), findsOneWidget);
    expect(find.text('Marcar un lugar'), findsOneWidget);
    expect(eventos.where((e) => e['name'] == 'search').single['props'], {
      'resultados': 0,
      'texto': 'fisioterapia',
    });
  });

  testWidgets('rubro sin lugares: no guarda el texto', (tester) async {
    final eventos = <Map<String, Object?>>[];
    await _abrirMapa(
      tester,
      comercios: ComerciosFalsos([_vet]),
      eventos: eventos,
    );
    await _buscar(tester, 'guardería');

    expect(find.textContaining('Todavía no hay hoteles'), findsOneWidget);
    // Sin los comercios prendidos no se ofrece marcar.
    expect(find.text('Marcar un lugar'), findsNothing);
    expect(eventos.where((e) => e['name'] == 'search').single['props'], {
      'rubro': 'hotel',
      'resultados': 0,
    });
  });
}
