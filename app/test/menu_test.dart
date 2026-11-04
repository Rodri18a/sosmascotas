import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'mascota_elegida_falsa.dart';
import 'mascotas_falsas.dart';
import 'noticias_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');
const _toby = Mascota(id: 'm1', nombre: 'Toby', especieId: 1);
const _luna = Mascota(id: 'm2', nombre: 'Luna', especieId: 2);

final _paraPerros = Noticia(
  id: 'n1',
  titulo: 'Paseos con calor',
  cuerpo: 'Mejor temprano o de noche.',
  publicada: DateTime(2026, 10, 19),
  especieIds: const [1],
);
final _paraGatos = Noticia(
  id: 'n2',
  titulo: 'Gatos y el calor',
  cuerpo: 'Agua fresca y sombra todo el día.',
  publicada: DateTime(2026, 10, 18),
  especieIds: const [2],
);

Future<void> _abrir(
  WidgetTester tester, {
  bool visitante = false,
  AlmacenMascotaElegidaFalso? almacen,
  List<Map<String, Object?>>? metricas,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      inicio: Rutas.inicio,
      cuenta: ServicioCuentaFalso(conectado: visitante ? null : _ana),
      mascotas: MascotasFalsas([_toby, _luna]),
      noticias: NoticiasFalsas([_paraPerros, _paraGatos]),
      almacenMascotaElegida: almacen,
      eventos: metricas,
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.noticias,
        Funcionalidades.adopcion,
      }),
    ),
  );
  await abrirMenu(tester);
}

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('un visitante ve "Ingresá" y las secciones, sin mascotas', (
    tester,
  ) async {
    await _abrir(tester, visitante: true);
    expect(find.text('Ingresá o creá tu cuenta'), findsOneWidget);
    expect(find.text('Ver todo para'), findsNothing);
    expect(
      find.descendant(of: find.byType(Drawer), matching: find.text('Noticias')),
      findsNothing,
      reason: 'es una pestaña (D94)',
    );
    await bajarEnMenu(tester, find.text('Adoptar o dar en adopción'));
    expect(find.text('Avisos'), findsNothing, reason: 'necesita cuenta');
    await bajarEnMenu(tester, find.text('Ajustes'));
  });

  testWidgets('con cuenta: mis datos y elegir una mascota', (tester) async {
    final almacen = AlmacenMascotaElegidaFalso();
    final metricas = <Map<String, Object?>>[];
    await _abrir(tester, almacen: almacen, metricas: metricas);
    expect(find.text('ana@correo.com'), findsOneWidget);
    expect(find.text('Ver todo para'), findsOneWidget);

    await _tocar(tester, find.text('Luna'));
    expect(find.textContaining('para la especie de Luna'), findsOneWidget);
    // Sin «Mis mascotas» en el menú: está en la fila de cada mascota (D142).
    expect(find.text('Ver su ficha'), findsNothing);
    expect(find.text('Reportar que se perdió'), findsNothing);
    expect(almacen.guardadas['u1'], 'm2', reason: 'queda guardada');
    expect(
      metricas.map((e) => e['name']),
      containsAll(['menu_open', 'pet_select']),
    );

  });

  testWidgets('la elegida se recuerda al volver a abrir', (tester) async {
    await _abrir(tester, almacen: AlmacenMascotaElegidaFalso({'u1': 'm1'}));
    expect(find.textContaining('para la especie de Toby'), findsOneWidget);
    await _tocar(
      tester,
      find.descendant(of: find.byType(Drawer), matching: find.text('Todas')),
    );
    expect(find.textContaining('lo de todas tus mascotas'), findsOneWidget);
  });

  testWidgets('una opción cierra el menú y abre la sección', (tester) async {
    await _abrir(tester);
    await bajarEnMenu(tester, find.text('Hogar de tránsito'));
    await _tocar(tester, find.text('Hogar de tránsito'));
    expect(find.byType(Drawer), findsNothing);
    expect(find.text('Hogar de tránsito'), findsWidgets);
  });

  testWidgets('las secciones van en grupos con título (1.2)', (tester) async {
    await _abrir(tester);
    final enMenu = find.descendant(
      of: find.byType(Drawer),
      matching: find.text('Mapa'),
    );
    expect(enMenu, findsOneWidget);
    for (final texto in [
      'Mapa y lugares',
      'Comunidad',
      'Adopción',
      'Hogar de tránsito',
      'Turnos y pedidos',
      'Mis pedidos',
      'Mi cuenta',
    ]) {
      await bajarEnMenu(
        tester,
        find.descendant(of: find.byType(Drawer), matching: find.text(texto)),
      );
    }
    expect(
      find.descendant(
        of: find.byType(Drawer),
        matching: find.text('Próximos eventos'),
      ),
      findsNothing,
      reason: 'la funcionalidad de eventos está apagada',
    );
  });

  testWidgets('un visitante no ve los grupos que piden cuenta', (tester) async {
    await _abrir(tester, visitante: true);
    await bajarEnMenu(tester, find.text('Ajustes'));
    expect(find.text('Mi cuenta'), findsOneWidget, reason: 'tiene Ajustes');
    expect(find.text('Turnos y pedidos'), findsNothing);
    expect(find.text('Hogar de tránsito'), findsNothing);
    expect(find.text('Mensajes'), findsNothing);
  });

  testWidgets('tocar Mapa cambia de pestaña y anota la opción', (tester) async {
    final metricas = <Map<String, Object?>>[];
    await _abrir(tester, metricas: metricas);
    await _tocar(
      tester,
      find.descendant(of: find.byType(Drawer), matching: find.text('Mapa')),
    );
    expect(find.byType(Drawer), findsNothing);
    expect(
      metricas
          .where((e) => e['name'] == 'menu_item_open')
          .map((e) => e['props']),
      [
        {'item': 'mapa'},
      ],
    );
  });
}
