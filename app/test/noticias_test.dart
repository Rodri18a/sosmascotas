import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/bienvenida/bienvenida_screen.dart';
import 'package:sosmascota/src/features/noticias/noticias_screen.dart';
import 'package:sosmascota/src/features/sos/sos_detalle_screen.dart';
import 'package:sosmascota/src/router.dart';
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
  List<Mascota> mascotas = const [],
  List<Uri>? enlaces,
  List<Map<String, Object?>>? metricas,
  List<Novedad> novedades = const [],
  ResumenComunidad resumen = const ResumenComunidad(),
  NoticiasFalsas? repo,
  bool visitante = false,
  bool menosMovimiento = false,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  tester.platformDispatcher.accessibilityFeaturesTestValue =
      FakeAccessibilityFeatures(disableAnimations: menosMovimiento);
  addTearDown(tester.platformDispatcher.clearAccessibilityFeaturesTestValue);
  await tester.pumpWidget(
    appDePrueba(
      inicio: Rutas.inicio,
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
      // Sin ninguna funcionalidad gradual: Noticias es para todos (D94).
      funcionalidades: FuncionalidadesFalsas(),
    ),
  );
  await tester.pumpAndSettle();
}

const _bannerAdopcion = BannerInicio(
  id: 'b1',
  titulo: 'Jornada de adopción',
  imagen: 'b1.jpg',
  enlace: 'https://huellitas.uy/adopcion',
);
const _bannerPromo = BannerInicio(
  id: 'b2',
  titulo: 'Baño y corte',
  imagen: 'b2.jpg',
  noticiaId: 'n2',
  patrocinado: true,
  marca: 'Pet Pando',
);

void main() {
  testWidgets('carrusel: arriba del Inicio, pasa solo cada 3 segundos y '
      'abre su enlace o su noticia', (tester) async {
    final enlaces = <Uri>[];
    final metricas = <Map<String, Object?>>[];
    await _abrir(
      tester,
      enlaces: enlaces,
      metricas: metricas,
      repo: NoticiasFalsas(
        [_paraGatos, _paraTodas],
        const [],
        const ResumenComunidad(),
        const [_bannerAdopcion, _bannerPromo],
      ),
    );
    expect(find.text('Jornada de adopción'), findsOneWidget);
    expect(find.text('Baño y corte'), findsNothing);
    expect(
      tester.getTopLeft(find.text('Jornada de adopción')).dy,
      lessThan(
        tester.getTopLeft(find.textContaining('Todavía no hay novedades')).dy,
      ),
      reason: 'va arriba de la Comunidad',
    );

    await tester.tap(find.text('Jornada de adopción'));
    await tester.pumpAndSettle();
    expect(enlaces, [Uri.parse('https://huellitas.uy/adopcion')]);

    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.text('Baño y corte'), findsOneWidget);
    expect(find.text('Promocionado · Pet Pando'), findsOneWidget);

    await tester.tap(find.text('Baño y corte'));
    await tester.pumpAndSettle();
    expect(find.text('Llevá la libreta sanitaria.'), findsWidgets);
    expect(metricas.where((e) => e['name'] == 'banner_open'), hasLength(2));
  });

  testWidgets('carrusel: sin banners no ocupa lugar; con menos movimiento '
      'no pasa solo', (tester) async {
    await _abrir(tester);
    expect(find.byType(PageView), findsNothing);

    await tester.pumpWidget(const SizedBox());
    await _abrir(
      tester,
      repo: NoticiasFalsas(
        [_paraTodas],
        const [],
        const ResumenComunidad(),
        const [_bannerAdopcion, _bannerPromo],
      ),
      menosMovimiento: true,
    );
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();
    expect(find.text('Jornada de adopción'), findsOneWidget);
  });

  testWidgets('Inicio (D139): sin Noticias · Comunidad ni chips de especie; '
      'las noticias solo llegan por el carrusel', (tester) async {
    await _abrir(
      tester,
      mascotas: const [Mascota(id: 'm1', nombre: 'Luna', especieId: 2)],
    );
    expect(find.byType(SegmentedButton<bool>), findsNothing);
    expect(find.byType(ChoiceChip), findsNothing);
    expect(find.text('Gatos y el calor'), findsNothing);
    expect(find.text('Campaña de vacunación'), findsNothing);
    expect(find.textContaining('Todavía no hay novedades'), findsOneWidget);
  });

  testWidgets('Inicio (D140, D141): eventos, preguntas y después el resumen; '
      'sin la explicación de la Comunidad', (tester) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      appDePrueba(
        inicio: Rutas.inicio,
        cuenta: ServicioCuentaFalso(conectado: _ana),
        noticias: NoticiasFalsas(
          const [],
          const [],
          const ResumenComunidad(reencuentros: 2),
        ),
        funcionalidades: FuncionalidadesFalsas({Funcionalidades.preguntas}),
      ),
    );
    await tester.pumpAndSettle();
    final eventos = tester.getTopLeft(find.text('Próximos eventos')).dy;
    final resumen = tester
        .getTopLeft(find.text('Últimos 30 días en la comunidad'))
        .dy;
    final preguntas = tester.getTopLeft(find.text('¿Tenés una duda?')).dy;
    expect(eventos, lessThan(preguntas));
    expect(preguntas, lessThan(resumen));
    expect(find.textContaining('Se arma sola'), findsNothing);
  });

  testWidgets('una noticia abierta desde un banner: "Leer más" registra la '
      'métrica', (tester) async {
    final enlaces = <Uri>[];
    final metricas = <Map<String, Object?>>[];
    await _abrir(
      tester,
      enlaces: enlaces,
      metricas: metricas,
      repo: NoticiasFalsas(
        [_paraTodas],
        const [],
        const ResumenComunidad(),
        const [_bannerPromo],
      ),
    );
    await _tocar(tester, find.text('Baño y corte'));
    expect(find.text('Llevá la libreta sanitaria.'), findsWidgets);
    await _tocar(tester, find.text('Leer más'));
    expect(enlaces, [Uri.parse('https://www.gub.uy/')]);
    expect(
      metricas.map((e) => e['name']),
      containsAll(['banner_open', 'news_open', 'news_link']),
    );
  });

  testWidgets('Comunidad: resumen y novedades de todas las especies', (
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

    expect(find.text('Últimos 30 días en la comunidad'), findsOneWidget);
    // Solo reencuentros y perdidas, uno al lado del otro (D141).
    expect(find.text('volvieron a casa'), findsOneWidget);
    expect(find.text('siguen en búsqueda'), findsOneWidget);
    expect(
      tester.getCenter(find.text('volvieron a casa')).dx,
      lessThan(tester.getCenter(find.text('siguen en búsqueda')).dx),
    );
    expect(find.textContaining('lugar verificado en el mapa'), findsNothing);
    expect(find.textContaining('adopciones concretadas'), findsNothing);

    expect(find.text('¡Lola volvió a casa! 🎉'), findsOneWidget);
    expect(find.textContaining('Estuvo 3 días perdida.'), findsOneWidget);
    expect(
      find.textContaining('Gracias a todos'),
      findsNothing,
      reason:
          'la tarjeta va en una línea; el agradecimiento queda en el detalle',
    );
    expect(
      find.text('Una mascota encontrada volvió con su familia 🏡'),
      findsOneWidget,
    );
    expect(find.text('3 mascotas encontraron un hogar 💛'), findsOneWidget);
    expect(find.text('Nuevo lugar verificado: Vet Pando'), findsOneWidget);
    expect(find.text('Gatos y el calor'), findsNothing, reason: 'sin noticias');
  });

  testWidgets('Comunidad vacía explica qué va a aparecer', (tester) async {
    await _abrir(tester);
    expect(find.textContaining('Todavía no hay novedades'), findsOneWidget);
    expect(find.text('Últimos 30 días en la comunidad'), findsNothing);
  });

  testWidgets('reaccionar a una noticia: poner, cambiar y quitar', (
    tester,
  ) async {
    final repo = NoticiasFalsas(
      [_paraTodas],
      const [],
      const ResumenComunidad(),
      const [_bannerPromo],
    );
    repo.reaccionesGuardadas['n2'] = const Reacciones(
      totales: {Reaccion.alegra: 2},
    );
    await _abrir(tester, repo: repo);
    await _tocar(tester, find.text('Baño y corte'));
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
    final repo = NoticiasFalsas(
      [_paraTodas],
      const [],
      const ResumenComunidad(),
      const [_bannerPromo],
    );
    await _abrir(tester, repo: repo, visitante: true);
    await _tocar(tester, find.text('Baño y corte'));
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
    expect(find.text('Se busca a Toby'), findsOneWidget);
    expect(find.textContaining('Lleva 2 días perdida.'), findsOneWidget);
    await _tocar(tester, find.text('Se busca a Toby'));
    expect(find.byType(SosDetalleScreen), findsOneWidget);
    expect(find.text('¿Qué te pareció?'), findsNothing);
  });
  testWidgets('Inicio (D147): las últimas 5 novedades con título y «Ver todas» '
      'abre la lista completa', (tester) async {
    final metricas = <Map<String, Object?>>[];
    await _abrir(
      tester,
      metricas: metricas,
      novedades: [
        for (var i = 1; i <= 8; i++)
          Novedad(
            id: 'c$i',
            tipo: TipoNovedad.comercio,
            fecha: DateTime(2026, 10, 30 - i),
            nombre: 'Vet $i',
            detalle: 'vet',
          ),
      ],
    );

    expect(find.text('Últimas novedades de la comunidad'), findsOneWidget);
    for (var i = 1; i <= 5; i++) {
      expect(find.text('Nuevo lugar verificado: Vet $i'), findsOneWidget);
    }
    expect(find.text('Nuevo lugar verificado: Vet 6'), findsNothing);

    await _tocar(tester, find.text('Ver todas'));
    expect(find.byType(NovedadesScreen), findsOneWidget);
    expect(
      metricas.where((e) => e['name'] == 'community_see_all'),
      hasLength(1),
    );
    for (var i = 1; i <= 8; i++) {
      await tester.scrollUntilVisible(
        find.text('Nuevo lugar verificado: Vet $i'),
        200,
        scrollable: find.byType(Scrollable).last,
      );
    }
    expect(find.text('Ver todas'), findsNothing);
  });

  testWidgets('Inicio (D147): con 5 novedades o menos no hay «Ver todas»', (
    tester,
  ) async {
    await _abrir(
      tester,
      novedades: [
        Novedad(
          id: 'c1',
          tipo: TipoNovedad.comercio,
          fecha: DateTime(2026, 10, 20),
          nombre: 'Vet Pando',
          detalle: 'vet',
        ),
      ],
    );
    expect(find.text('Nuevo lugar verificado: Vet Pando'), findsOneWidget);
    expect(find.text('Ver todas'), findsNothing);
  });

  testWidgets('Inicio (D154): acceso a Adopción si está prendida, con '
      'métrica', (tester) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final metricas = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        inicio: Rutas.inicio,
        cuenta: ServicioCuentaFalso(conectado: _ana),
        noticias: NoticiasFalsas(const [], const [], const ResumenComunidad()),
        eventos: metricas,
        funcionalidades: FuncionalidadesFalsas({Funcionalidades.adopcion}),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Adopción y hogar de tránsito'), findsOneWidget);
    await _tocar(tester, find.byKey(const Key('acceso-adopcion')));
    expect(find.text('Adopción responsable'), findsOneWidget);
    expect(
      metricas
          .where((e) => e['name'] == 'adoption_shortcut')
          .map((e) => e['props']),
      [
        {'desde': 'inicio'},
      ],
    );
  });

  testWidgets('Inicio (D154): sin Adopción prendida no hay acceso', (
    tester,
  ) async {
    await _abrir(tester);
    expect(find.byKey(const Key('acceso-adopcion')), findsNothing);
  });

  testWidgets('Comunidad: borde rojo si se sigue buscando, verde si volvió a '
      'casa y sin borde lo demás', (tester) async {
    await _abrir(
      tester,
      novedades: [
        Novedad(
          id: 's1',
          tipo: TipoNovedad.perdida,
          fecha: DateTime(2026, 10, 20),
          origenId: 's1',
          nombre: 'Toby',
          cantidad: 2,
        ),
        Novedad(
          id: 'r1',
          tipo: TipoNovedad.reencuentro,
          fecha: DateTime(2026, 10, 19),
          nombre: 'Lola',
          detalle: 'lost',
        ),
        Novedad(
          id: 'c1',
          tipo: TipoNovedad.comercio,
          fecha: DateTime(2026, 10, 18),
          nombre: 'Vet Pando',
          detalle: 'vet',
        ),
      ],
    );
    final tema = Theme.of(tester.element(find.text('Se busca a Toby')));
    BorderSide borde(String tipo) {
      final tarjeta = tester.widget<Card>(
        find.byKey(Key('novedad-borde-$tipo')),
      );
      return (tarjeta.shape! as RoundedRectangleBorder).side;
    }

    expect(borde('perdida').color, tema.colorScheme.error);
    expect(borde('reencuentro').color, tema.extension<ColoresMarca>()!.exito);
    expect(find.byKey(const Key('novedad-borde-comercio')), findsNothing);
  });

  testWidgets('Inicio del visitante: sin el bloque de bienvenida', (
    tester,
  ) async {
    await _abrir(tester, visitante: true);
    expect(find.text('¡Hola! Somos Huellamy'), findsNothing);
  });

  testWidgets('Bienvenida de la primera vez: se marca vista y «Mirar sin '
      'cuenta» lleva al Inicio', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final metricas = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        inicio: Rutas.bienvenida,
        cuenta: ServicioCuentaFalso(),
        eventos: metricas,
        funcionalidades: FuncionalidadesFalsas(),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('¡Hola! Somos Huellamy'), findsOneWidget);
    expect(bienvenidaVista(await SharedPreferences.getInstance()), isTrue);

    await tester.ensureVisible(find.text('Mirar sin cuenta'));
    await tester.tap(find.text('Mirar sin cuenta'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('bienvenida')), findsNothing);
    expect(
      metricas.map((e) => e['name']),
      containsAllInOrder(['welcome_view', 'welcome_skip']),
    );
  });
}
