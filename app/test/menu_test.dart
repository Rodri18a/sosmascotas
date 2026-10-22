import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
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
    expect(find.text('Adoptar o dar en adopción'), findsOneWidget);
    expect(find.text('Avisos'), findsNothing, reason: 'necesita cuenta');
    expect(find.text('Ajustes'), findsWidgets);
  });

  testWidgets('con cuenta: mis datos y elegir una mascota', (tester) async {
    final almacen = AlmacenMascotaElegidaFalso();
    final metricas = <Map<String, Object?>>[];
    await _abrir(tester, almacen: almacen, metricas: metricas);
    expect(find.text('ana@correo.com'), findsOneWidget);
    expect(find.text('Ver todo para'), findsOneWidget);
    expect(find.text('Ver su ficha'), findsNothing, reason: 'son todas');

    await _tocar(tester, find.text('Luna'));
    expect(find.textContaining('para la especie de Luna'), findsOneWidget);
    expect(find.text('Ver su ficha'), findsOneWidget);
    expect(find.text('Chapita QR'), findsOneWidget);
    expect(find.text('Reportar que se perdió'), findsOneWidget);
    expect(almacen.guardadas['u1'], 'm2', reason: 'queda guardada');
    expect(
      metricas.map((e) => e['name']),
      containsAll(['menu_open', 'pet_select']),
    );

    // Noticias (en la barra) se abre filtrada por gatos.
    await tester.tapAt(const Offset(10, 300)); // cierra el menú
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Noticias'));
    expect(find.text('Gatos y el calor'), findsOneWidget);
    expect(find.text('Paseos con calor'), findsNothing);
    // Los chips la pueden cambiar.
    await _tocar(tester, find.text('Todas'));
    expect(find.text('Paseos con calor'), findsOneWidget);
  });

  testWidgets('la elegida se recuerda al volver a abrir', (tester) async {
    await _abrir(tester, almacen: AlmacenMascotaElegidaFalso({'u1': 'm1'}));
    expect(find.textContaining('para la especie de Toby'), findsOneWidget);
    await _tocar(tester, find.text('Todas'));
    expect(find.text('Ver su ficha'), findsNothing);
  });

  testWidgets('una opción cierra el menú y abre la sección', (tester) async {
    await _abrir(tester);
    await _tocar(tester, find.text('Ver todo para'));
    await _tocar(tester, find.text('Toby'));
    await _tocar(tester, find.text('Ver su ficha'));
    expect(find.byType(Drawer), findsNothing);
    expect(find.text('Toby'), findsWidgets);
  });
}
