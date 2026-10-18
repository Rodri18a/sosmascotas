import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'chat_falso.dart';
import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'resenas_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

const _peluqueria = Comercio(
  id: 'b1',
  nombre: 'Peluquería Luna',
  tipo: 'grooming',
  punto: Punto(-34.72, -55.95),
  horario: Horario({}),
  tieneDuenio: true,
);

final _deBeto = Resena(
  id: 'r1',
  estrellas: 4,
  comentario: 'Muy buena atención',
  creada: DateTime(2026, 10, 10),
  autor: 'Beto',
);

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

Future<void> _abrirFicha(
  WidgetTester tester, {
  required ResenasFalsas resenas,
  ChatFalso? chat,
  List<Map<String, Object?>>? eventos,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      comercios: ComerciosFalsos([_peluqueria]),
      resenas: resenas,
      chat: chat,
      eventos: eventos,
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.mapaCompleto,
        Funcionalidades.resenas,
        Funcionalidades.chat,
        Funcionalidades.comercios,
      }),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(const ValueKey('mapa-mover')));
  await tester.pumpAndSettle();
  await _tocar(tester, find.byKey(const ValueKey('pin-b1')));
}

void main() {
  testWidgets('sin contacto real no se puede reseñar', (tester) async {
    await _abrirFicha(tester, resenas: ResenasFalsas(iniciales: [_deBeto]));
    expect(find.text('Muy buena atención'), findsOneWidget);
    expect(find.textContaining('4,0 ★ · 1 reseña'), findsOneWidget);
    expect(find.text('Escribir una reseña'), findsNothing);
    expect(find.textContaining('después de escribirle'), findsOneWidget);
  });

  testWidgets('con contacto real: escribir una reseña de 3 estrellas', (
    tester,
  ) async {
    final resenas = ResenasFalsas(iniciales: [_deBeto], puedo: true);
    final eventos = <Map<String, Object?>>[];
    await _abrirFicha(tester, resenas: resenas, eventos: eventos);
    await _tocar(tester, find.text('Escribir una reseña'));
    await _tocar(tester, find.byTooltip('3 estrellas'));
    await tester.enterText(find.byType(TextField).last, 'Bien, pero tardaron');
    await _tocar(tester, find.text('Publicar'));

    final mia = resenas.resenas.firstWhere((r) => r.mia);
    expect(mia.estrellas, 3);
    expect(mia.comentario, 'Bien, pero tardaron');
    expect(find.text('Tu reseña'), findsOneWidget);
    expect(find.text('Editar mi reseña'), findsOneWidget);
    expect(eventos.where((e) => e['name'] == 'review_create').single['props'], {
      'estrellas': 3,
    });
  });

  testWidgets('reportar una reseña ajena', (tester) async {
    final resenas = ResenasFalsas(iniciales: [_deBeto]);
    await _abrirFicha(tester, resenas: resenas);
    await _tocar(tester, find.byTooltip('Reportar reseña'));
    expect(resenas.reportadas, ['r1']);
  });

  testWidgets('escribirle al comercio por chat', (tester) async {
    final chat = ChatFalso();
    await _abrirFicha(tester, resenas: ResenasFalsas(), chat: chat);
    await _tocar(tester, find.text('Escribir por chat'));
    expect(chat.iniciados, ['negocio:b1']);
  });

  testWidgets('el comercio responde desde su panel', (tester) async {
    tester.view
      ..physicalSize = const Size(1080, 2400)
      ..devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    final resenas = ResenasFalsas(iniciales: [_deBeto]);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        resenas: resenas,
        negocios: NegociosFalsos([
          MiNegocio.fromJson({
            'id': 'b1',
            'name': 'Peluquería Luna',
            'business_type': 'grooming',
            'kind': 'local',
            'lat': -34.71,
            'lng': -55.95,
            'hours': {},
            'verification': 'verified',
            'status': 'active',
          }),
        ]),
        funcionalidades: FuncionalidadesFalsas({
          Funcionalidades.comercios,
          Funcionalidades.resenas,
        }),
      ),
    );
    await tester.pumpAndSettle();
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/negocio');
    await tester.pumpAndSettle();

    expect(find.text('Muy buena atención'), findsOneWidget);
    await _tocar(tester, find.widgetWithText(TextButton, 'Responder'));
    await tester.enterText(find.byType(TextField).last, '¡Gracias, Beto!');
    await _tocar(tester, find.widgetWithText(FilledButton, 'Responder'));
    expect(resenas.respuestas.single, ('r1', '¡Gracias, Beto!'));
  });
}
