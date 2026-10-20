import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/sos/sos_detalle_screen.dart';
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
  List<Novedad> novedades = const [],
  ResumenComunidad resumen = const ResumenComunidad(),
  NoticiasFalsas? repo,
  bool visitante = false,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: visitante ? null : _ana),
      mascotas: MascotasFalsas(mascotas),
      noticias:
          repo ??
          NoticiasFalsas(
            [_paraGatos, _paraTodas, _patrocinada],
            novedades,
            resumen,
          ),
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

  testWidgets('Comunidad: resumen y novedades, filtradas por especie', (
    tester,
  ) async {
    await _abrir(
      tester,
      mascotas: const [Mascota(id: 'm1', nombre: 'Luna', especieId: 2)],
      resumen: const ResumenComunidad(reencuentros: 2, lugaresVerificados: 1),
      novedades: [
        Novedad(
          id: 'r1',
          tipo: TipoNovedad.reencuentro,
          fecha: DateTime(2026, 10, 20),
          nombre: 'Lola',
          detalle: 'lost',
          especieId: 1,
          cantidad: 3,
        ),
        Novedad(
          id: 'r2',
          tipo: TipoNovedad.reencuentro,
          fecha: DateTime(2026, 10, 19),
          detalle: 'found',
          especieId: 2,
        ),
        Novedad(
          id: 'a1',
          tipo: TipoNovedad.adopcion,
          fecha: DateTime(2026, 10, 18),
          especieId: 2,
          cantidad: 3,
        ),
        Novedad(
          id: 'c1',
          tipo: TipoNovedad.comercio,
          fecha: DateTime(2026, 10, 17),
          nombre: 'Vet Pando',
          detalle: 'vet',
        ),
      ],
    );
    await _tocar(tester, find.text('Noticias'));
    await _tocar(tester, find.text('Comunidad'));

    expect(find.text('Últimos 30 días en la comunidad'), findsOneWidget);
    expect(find.text('2 mascotas volvieron a casa'), findsOneWidget);
    expect(find.text('1 lugar verificado en el mapa'), findsOneWidget);
    expect(find.textContaining('adopciones concretadas'), findsNothing);

    expect(find.text('¡Lola volvió a casa! 🎉'), findsOneWidget);
    expect(find.textContaining('Estuvo 3 días perdida.'), findsOneWidget);
    expect(
      find.text('Una mascota encontrada volvió con su familia 🏡'),
      findsOneWidget,
    );
    expect(find.text('3 mascotas encontraron un hogar 💛'), findsOneWidget);
    expect(find.text('Nuevo lugar verificado: Vet Pando'), findsOneWidget);
    expect(find.text('Gatos y el calor'), findsNothing, reason: 'otra sección');

    await _tocar(tester, find.text('🐱 Gato'));
    expect(find.text('¡Lola volvió a casa! 🎉'), findsNothing);
    expect(find.text('Nuevo lugar verificado: Vet Pando'), findsOneWidget);
  });

  testWidgets('Comunidad vacía explica qué va a aparecer', (tester) async {
    await _abrir(tester);
    await _tocar(tester, find.text('Noticias'));
    await _tocar(tester, find.text('Comunidad'));
    expect(find.textContaining('Todavía no hay novedades'), findsOneWidget);
    expect(find.text('Últimos 30 días en la comunidad'), findsNothing);
  });

  testWidgets('reaccionar a una noticia: poner, cambiar y quitar', (
    tester,
  ) async {
    final repo = NoticiasFalsas([_paraTodas]);
    repo.reaccionesGuardadas['n2'] = const Reacciones(
      totales: {Reaccion.alegra: 2},
    );
    await _abrir(tester, repo: repo);
    await _tocar(tester, find.text('Noticias'));
    expect(find.text('❤️ 2'), findsOneWidget, reason: 'totales en la tarjeta');

    await _tocar(tester, find.text('Campaña de vacunación'));
    expect(find.text('❤️ Me alegra · 2'), findsOneWidget);
    await _tocar(tester, find.text('🎉 ¡Qué bueno!'));
    expect(find.text('🎉 ¡Qué bueno! · 1'), findsOneWidget);
    await _tocar(tester, find.text('❤️ Me alegra · 2'));
    expect(find.text('❤️ Me alegra · 3'), findsOneWidget);
    expect(find.text('🎉 ¡Qué bueno!'), findsOneWidget, reason: 'se cambió');
    await _tocar(tester, find.text('❤️ Me alegra · 3'));
    expect(find.text('❤️ Me alegra · 2'), findsOneWidget, reason: 'se quitó');
    expect(repo.reaccionesEnviadas, [
      ('n2', Reaccion.festejo),
      ('n2', Reaccion.alegra),
      ('n2', null),
    ]);
  });

  testWidgets('un visitante tiene que ingresar para reaccionar', (
    tester,
  ) async {
    final repo = NoticiasFalsas([_paraTodas]);
    await _abrir(tester, repo: repo, visitante: true);
    await _tocar(tester, find.text('Noticias'));
    await _tocar(tester, find.text('Campaña de vacunación'));
    await _tocar(tester, find.text('❤️ Me alegra'));
    expect(
      find.text('Para reaccionar a las noticias necesitás una cuenta.'),
      findsOneWidget,
    );
    expect(repo.reaccionesEnviadas, isEmpty);
  });

  testWidgets('Comunidad: un reencuentro abre el detalle con reacciones', (
    tester,
  ) async {
    final repo = NoticiasFalsas(const [], [
      Novedad(
        id: 'r1',
        tipo: TipoNovedad.reencuentro,
        fecha: DateTime(2026, 10, 20),
        nombre: 'Lola',
        detalle: 'lost',
      ),
    ]);
    await _abrir(tester, repo: repo);
    await _tocar(tester, find.text('Noticias'));
    await _tocar(tester, find.text('Comunidad'));
    await _tocar(tester, find.text('¡Lola volvió a casa! 🎉'));
    await _tocar(tester, find.text('🙏 Gracias'));
    expect(repo.reaccionesEnviadas, [('r1', Reaccion.gracias)]);
  });

  testWidgets('Comunidad: una perdida lleva a su reporte (sin reacciones)', (
    tester,
  ) async {
    final repo = NoticiasFalsas(const [], [
      Novedad(
        id: 's1',
        tipo: TipoNovedad.perdida,
        fecha: DateTime(2026, 10, 20),
        origenId: 's1',
        nombre: 'Toby',
        cantidad: 2,
      ),
    ]);
    await _abrir(tester, repo: repo);
    await _tocar(tester, find.text('Noticias'));
    await _tocar(tester, find.text('Comunidad'));
    expect(find.text('Se busca a Toby'), findsOneWidget);
    expect(find.textContaining('Lleva 2 días perdida.'), findsOneWidget);
    await _tocar(tester, find.text('Se busca a Toby'));
    expect(find.byType(SosDetalleScreen), findsOneWidget);
    expect(find.text('¿Qué te pareció?'), findsNothing);
  });
}
