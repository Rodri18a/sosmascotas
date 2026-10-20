import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'mascotas_falsas.dart';
import 'noticias_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

final _paraGatos = Noticia(
  id: 'n1',
  titulo: 'Gatos y el calor',
  cuerpo: 'Agua fresca y sombra todo el día.',
  publicada: DateTime(2026, 10, 19),
  especieIds: const [2],
);
final _paraTodas = Noticia(
  id: 'n2',
  titulo: 'Campaña de vacunación',
  cuerpo: 'Llevá la libreta sanitaria.',
  publicada: DateTime(2026, 10, 18),
  fuente: 'MGAP',
  enlace: 'https://www.gub.uy/',
);
final _patrocinada = Noticia(
  id: 'n3',
  titulo: 'Alimento para cachorros',
  cuerpo: 'Una guía para elegir el alimento.',
  publicada: DateTime(2026, 10, 17),
  especieIds: const [1],
  patrocinada: true,
  marca: 'Marca Perruna',
);

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

Future<void> _abrir(
  WidgetTester tester, {
  bool conFuncionalidad = true,
  List<Mascota> mascotas = const [],
  List<Uri>? enlaces,
  List<Map<String, Object?>>? metricas,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      mascotas: MascotasFalsas(mascotas),
      noticias: NoticiasFalsas([_paraGatos, _paraTodas, _patrocinada]),
      enlacesAbiertos: enlaces,
      eventos: metricas,
      funcionalidades: FuncionalidadesFalsas({
        if (conFuncionalidad) Funcionalidades.noticias,
      }),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Ayuda').last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sin la funcionalidad no hay entrada en Ayuda', (tester) async {
    await _abrir(tester, conFuncionalidad: false);
    expect(find.text('Noticias'), findsNothing);
  });

  testWidgets('desde Ayuda: todas, con la patrocinada marcada', (tester) async {
    await _abrir(tester);
    await _tocar(tester, find.text('Noticias'));
    expect(find.text('Gatos y el calor'), findsOneWidget);
    expect(find.text('Campaña de vacunación'), findsOneWidget);
    expect(find.text('Alimento para cachorros'), findsOneWidget);
    expect(find.text('Promocionado · Marca Perruna'), findsOneWidget);
  });

  testWidgets('los chips filtran por la especie de mis mascotas', (
    tester,
  ) async {
    await _abrir(
      tester,
      mascotas: const [Mascota(id: 'm1', nombre: 'Luna', especieId: 2)],
    );
    await _tocar(tester, find.text('Noticias'));
    await _tocar(tester, find.text('🐱 Gato'));
    expect(find.text('Gatos y el calor'), findsOneWidget);
    expect(find.text('Campaña de vacunación'), findsOneWidget, reason: 'todas');
    expect(find.text('Alimento para cachorros'), findsNothing);
    await _tocar(tester, find.text('Todas'));
    expect(find.text('Alimento para cachorros'), findsOneWidget);
  });

  testWidgets('abrir una noticia y "Leer más" registran la métrica', (
    tester,
  ) async {
    final enlaces = <Uri>[];
    final metricas = <Map<String, Object?>>[];
    await _abrir(tester, enlaces: enlaces, metricas: metricas);
    await _tocar(tester, find.text('Noticias'));
    await _tocar(tester, find.text('Campaña de vacunación'));
    expect(find.text('Llevá la libreta sanitaria.'), findsWidgets);
    await _tocar(tester, find.text('Leer más'));
    expect(enlaces, [Uri.parse('https://www.gub.uy/')]);
    expect(
      metricas.map((e) => e['name']),
      containsAll(['news_open', 'news_link']),
    );
  });

  testWidgets('la ruta está detrás de la funcionalidad', (tester) async {
    await _abrir(tester, conFuncionalidad: false);
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/noticias');
    await tester.pumpAndSettle();
    expect(find.text('Gatos y el calor'), findsNothing);
  });
}
