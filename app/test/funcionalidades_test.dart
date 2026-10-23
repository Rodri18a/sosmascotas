import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/config/version.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/funcionalidades/funcionalidades_activas.dart';
import 'package:sosmascota/src/redireccion.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

EstadoFuncionalidades _estado(WidgetTester tester) => ProviderScope.containerOf(
  tester.element(find.byType(MaterialApp)),
).read(funcionalidadesProvider);

/// Una pantalla de prueba con un botón detrás de la marca 'chat'.
class _ConChat extends StatelessWidget {
  const _ConChat();

  @override
  Widget build(BuildContext context) => const Column(
    children: [
      SiFuncionalidad(
        'chat',
        sinoMostrar: Text('sin chat'),
        child: Text('botón de chat'),
      ),
      SiFuncionalidad('chat', child: Text('otro lugar con chat')),
    ],
  );
}

Widget _conChat({
  required FuncionalidadesFalsas base,
  List<Map<String, Object?>>? eventos,
  CacheFuncionalidadesFalsa? cache,
}) => appDePrueba(
  cuenta: ServicioCuentaFalso(conectado: _ana),
  funcionalidades: base,
  cacheFuncionalidades: cache,
  eventos: eventos,
);

Future<void> _mostrarChat(WidgetTester tester) async {
  await tester.pumpAndSettle();
  final navegador = tester.state<NavigatorState>(find.byType(Navigator).first);
  unawaited(
    navegador.push(MaterialPageRoute<void>(builder: (_) => const _ConChat())),
  );
  await tester.pumpAndSettle();
}

/// Exposiciones de `chat` (las pantallas de fondo anotan las suyas).
List<Object?> _exposiciones(List<Map<String, Object?>> eventos) => eventos
    .where((e) => e['name'] == 'feature_exposure')
    .map((e) => e['props'])
    .where((p) => (p as Map?)?['key'] == 'chat')
    .toList();

void main() {
  group('SiFuncionalidad', () {
    testWidgets('prendida muestra el contenido y anota una sola exposición', (
      tester,
    ) async {
      final eventos = <Map<String, Object?>>[];
      await tester.pumpWidget(
        _conChat(base: FuncionalidadesFalsas({'chat'}), eventos: eventos),
      );
      await _mostrarChat(tester);

      expect(find.text('botón de chat'), findsOneWidget);
      expect(find.text('otro lugar con chat'), findsOneWidget);
      expect(_exposiciones(eventos), [
        {'key': 'chat', 'variante': 'prendida'},
      ]);
    });

    testWidgets('apagada muestra la alternativa y anota la variante apagada', (
      tester,
    ) async {
      final eventos = <Map<String, Object?>>[];
      await tester.pumpWidget(
        _conChat(base: FuncionalidadesFalsas(), eventos: eventos),
      );
      await _mostrarChat(tester);

      expect(find.text('sin chat'), findsOneWidget);
      expect(find.text('botón de chat'), findsNothing);
      expect(find.text('otro lugar con chat'), findsNothing);
      expect(_exposiciones(eventos), [
        {'key': 'chat', 'variante': 'apagada'},
      ]);
    });

    testWidgets('sin conexión ni nada guardado: apagada y sin exposición', (
      tester,
    ) async {
      final eventos = <Map<String, Object?>>[];
      await tester.pumpWidget(
        _conChat(
          base: FuncionalidadesFalsas({'chat'})..fallar = true,
          eventos: eventos,
        ),
      );
      await _mostrarChat(tester);

      expect(find.text('sin chat'), findsOneWidget);
      expect(_estado(tester).conocidas, isFalse);
      expect(_exposiciones(eventos), isEmpty);
    });
  });

  group('consulta y caché', () {
    testWidgets(
      'pregunta con el anon_id, la plataforma y la versión, y guarda',
      (tester) async {
        final base = FuncionalidadesFalsas({'chat'});
        final cache = CacheFuncionalidadesFalsa();
        await tester.pumpWidget(_conChat(base: base, cache: cache));
        await tester.pumpAndSettle();

        expect(base.pedidos.last, {
          'anonId': 'anon-prueba',
          'plataforma': 'web',
          'version': versionApp,
        });
        expect(cache.usuario, 'u1');
        expect(cache.claves, {'chat'});
        expect(_estado(tester).activa('chat'), isTrue);
      },
    );

    testWidgets('sin conexión usa lo último guardado de esa cuenta', (
      tester,
    ) async {
      await tester.pumpWidget(
        _conChat(
          base: FuncionalidadesFalsas()..fallar = true,
          cache: CacheFuncionalidadesFalsa(usuario: 'u1', claves: {'chat'}),
        ),
      );
      await _mostrarChat(tester);

      expect(find.text('botón de chat'), findsOneWidget);
      expect(_estado(tester).conocidas, isTrue);
    });

    testWidgets('lo guardado de otra cuenta no se usa', (tester) async {
      await tester.pumpWidget(
        _conChat(
          base: FuncionalidadesFalsas()..fallar = true,
          cache: CacheFuncionalidadesFalsa(usuario: 'otra', claves: {'chat'}),
        ),
      );
      await _mostrarChat(tester);

      expect(find.text('sin chat'), findsOneWidget);
    });

    testWidgets('al cerrar sesión vuelve a preguntar como visitante', (
      tester,
    ) async {
      final cuenta = ServicioCuentaFalso(conectado: _ana);
      final base = FuncionalidadesFalsas({'chat'});
      final cache = CacheFuncionalidadesFalsa();
      await tester.pumpWidget(
        appDePrueba(
          cuenta: cuenta,
          funcionalidades: base,
          cacheFuncionalidades: cache,
        ),
      );
      await tester.pumpAndSettle();
      expect(_estado(tester).activa('chat'), isTrue);

      base.activas = {};
      cuenta.conectar(null);
      await tester.pumpAndSettle();

      expect(_estado(tester).activa('chat'), isFalse);
      expect(cache.usuario, isNull);
      expect(base.pedidos, hasLength(2));
    });

    testWidgets('al volver a la app no pregunta de nuevo enseguida', (
      tester,
    ) async {
      final base = FuncionalidadesFalsas();
      await tester.pumpWidget(_conChat(base: base));
      await tester.pumpAndSettle();
      final antes = base.pedidos.length;

      tester.binding
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.paused)
        ..handleAppLifecycleStateChanged(AppLifecycleState.hidden)
        ..handleAppLifecycleStateChanged(AppLifecycleState.inactive)
        ..handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(base.pedidos.length, antes);
    });
  });

  group('rutas', () {
    bool soloChat(String clave) => clave == 'chat';
    const rutas = {'/chat': 'chat', '/resenas': 'resenas'};

    test('una ruta apagada lleva a "no disponible" y recuerda a dónde iba', () {
      expect(
        redirigir(
          conectado: true,
          uri: Uri.parse('/resenas/12'),
          funcionalidadActiva: soloChat,
          rutasConFuncionalidad: rutas,
        ),
        '/no-disponible?volver=%2Fresenas%2F12',
      );
    });

    test('una ruta prendida se abre', () {
      expect(
        redirigir(
          conectado: true,
          uri: Uri.parse('/chat/3'),
          funcionalidadActiva: soloChat,
          rutasConFuncionalidad: rutas,
        ),
        isNull,
      );
    });

    test('"no disponible" vuelve sola cuando la funcionalidad llega', () {
      final uri = Uri.parse('/no-disponible?volver=%2Fchat%2F3');
      expect(
        redirigir(
          conectado: true,
          uri: uri,
          funcionalidadActiva: soloChat,
          rutasConFuncionalidad: rutas,
        ),
        '/chat/3',
      );
      expect(
        redirigir(
          conectado: true,
          uri: uri,
          funcionalidadActiva: (_) => false,
          rutasConFuncionalidad: rutas,
        ),
        isNull,
      );
    });

    test(
      'un visitante primero ingresa y después se evalúa la funcionalidad',
      () {
        expect(
          redirigir(
            conectado: false,
            uri: Uri.parse('/avisos'),
            funcionalidadActiva: (_) => false,
            rutasConFuncionalidad: {'/avisos': 'chat'},
          ),
          '/ingresar?volver=%2Favisos',
        );
      },
    );

    testWidgets('la pantalla "no disponible" lleva al mapa', (tester) async {
      await tester.pumpWidget(appDePrueba());
      await tester.pumpAndSettle();
      GoRouter.of(
        tester.element(find.byType(Scaffold).first),
      ).go('/no-disponible');
      await tester.pumpAndSettle();

      expect(find.text('Todavía no está disponible'), findsOneWidget);
      await tester.tap(find.text('Ir al mapa'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Mapa'), findsOneWidget);
    });
  });

  test('versionApp coincide con pubspec.yaml', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final version = RegExp(
      r'^version: ([0-9.]+)',
      multiLine: true,
    ).firstMatch(pubspec)!.group(1);
    expect(versionApp, version);
  });

  test('las funcionalidades por defecto tienen nombres válidos', () {
    expect(
      Funcionalidades.prendidasPorDefecto.every(nombreDeFuncionalidadValido),
      isTrue,
    );
  });
}
