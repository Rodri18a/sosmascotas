import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'chat_falso.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'sos_falso.dart';

const _beto = Usuario(id: 'u2', email: 'beto@correo.com');

final _conLuna = Conversacion(
  id: 'c1',
  tipo: 'sos',
  contextoId: 's1',
  ultimoMensajeEn: DateTime(2026, 10, 17, 10),
  otroId: 'u1',
  sosNombre: 'Luna',
  ultimoMensaje: 'Gracias',
  sinLeer: 2,
);

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

Future<void> _ir(WidgetTester tester, String ruta) async {
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(ruta);
  await tester.pumpAndSettle();
}

Widget _app({
  required ChatFalso chat,
  bool prendida = true,
  SosFalso? sos,
  List<Map<String, Object?>>? eventos,
}) => appDePrueba(
  cuenta: ServicioCuentaFalso(conectado: _beto),
  chat: chat,
  sos: sos,
  eventos: eventos,
  posicion: (lat: -34.71, lng: -55.95),
  funcionalidades: FuncionalidadesFalsas({if (prendida) Funcionalidades.chat}),
  ahora: DateTime(2026, 10, 17, 10, 20),
);

void main() {
  testWidgets('la lista nombra a quien publicó por la mascota y cuenta los '
      'no leídos', (tester) async {
    await tester.pumpWidget(_app(chat: ChatFalso(conversaciones: [_conLuna])));
    await tester.pumpAndSettle();
    // El botón de mensajes con 2 sin leer.
    expect(find.byTooltip('Mensajes'), findsOneWidget);
    expect(find.text('2'), findsWidgets);
    await _tocar(tester, find.byTooltip('Mensajes'));

    expect(find.text('Familia de Luna'), findsOneWidget);
    expect(find.text('Gracias'), findsOneWidget);
  });

  testWidgets('sin la funcionalidad no hay botón ni pantalla', (tester) async {
    await tester.pumpWidget(_app(chat: ChatFalso(), prendida: false));
    await tester.pumpAndSettle();
    expect(find.byTooltip('Mensajes'), findsNothing);
    await _ir(tester, '/chats');
    expect(find.text('Todavía no está disponible'), findsOneWidget);
  });

  testWidgets('escribir, recibir al instante, aviso de estafa y reportar', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final chat = ChatFalso(conversaciones: [_conLuna]);
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(_app(chat: chat, eventos: eventos));
    await _ir(tester, '/chats/c1');

    expect(find.widgetWithText(AppBar, 'Familia de Luna'), findsOneWidget);
    expect(find.textContaining('nunca pagues por adelantado'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'La vi en la plaza');
    await _tocar(tester, find.byTooltip('Enviar'));
    expect(chat.mensajesGuardados.single.texto, 'La vi en la plaza');
    expect(find.text('La vi en la plaza'), findsOneWidget);
    expect(eventos.map((e) => e['name']), contains('chat_message'));

    chat.llega('Te la devuelvo si me transferís 3000');
    await tester.pumpAndSettle();
    expect(find.text('Te la devuelvo si me transferís 3000'), findsOneWidget);
    expect(
      find.textContaining('Ojo: este mensaje habla de plata'),
      findsOneWidget,
    );
    expect(chat.leidos, contains('c1'));

    await _tocar(tester, find.byTooltip('Reportar mensaje'));
    await _tocar(tester, find.text('Me pide plata o datos'));
    expect(chat.reportados.single.$2, 'estafa');
    expect(find.text('Gracias. Lo vamos a revisar.'), findsOneWidget);
  });

  testWidgets('mandar la ubicación pide confirmación', (tester) async {
    _pantallaDeCelular(tester);
    final chat = ChatFalso(conversaciones: [_conLuna]);
    await tester.pumpWidget(_app(chat: chat));
    await _ir(tester, '/chats/c1');

    await _tocar(tester, find.byTooltip('Mandar mi ubicación'));
    expect(find.text('¿Mandar tu ubicación exacta?'), findsOneWidget);
    await _tocar(tester, find.widgetWithText(FilledButton, 'Mandar'));
    expect(chat.mensajesGuardados.single.lat, -34.71);
    expect(find.text('Ver en el mapa'), findsOneWidget);
  });

  testWidgets('bloquear corta la conversación', (tester) async {
    _pantallaDeCelular(tester);
    final chat = ChatFalso(conversaciones: [_conLuna]);
    await tester.pumpWidget(_app(chat: chat));
    await _ir(tester, '/chats/c1');

    await _tocar(tester, find.byIcon(Icons.more_vert));
    await _tocar(tester, find.text('Bloquear').last);
    await _tocar(tester, find.widgetWithText(FilledButton, 'Bloquear'));
    expect(find.text('Bloqueaste esta conversación.'), findsOneWidget);
    expect(find.byTooltip('Enviar'), findsNothing);
  });

  testWidgets('desde un SOS ajeno se abre el chat', (tester) async {
    _pantallaDeCelular(tester);
    final chat = ChatFalso(conversaciones: [_conLuna]);
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      _app(
        chat: chat,
        eventos: eventos,
        sos: SosFalso(
          detalles: {
            's1': SosDetalle(
              id: 's1',
              tipo: TipoSos.perdida,
              estado: EstadoSos.activo,
              especie: 'Perro',
              especieIcono: '🐶',
              nombre: 'Luna',
              cuando: DateTime(2026, 10, 13),
              zona: const Punto(-34.72, -55.95),
              fotos: const ['sos-photos/u1/a.jpg'],
              esMio: false,
            ),
          },
        ),
      ),
    );
    await _ir(tester, '/sos/s1');
    await _tocar(tester, find.text('Escribir por chat'));

    expect(chat.iniciados, ['s1']);
    expect(find.widgetWithText(AppBar, 'Familia de Luna'), findsOneWidget);
    expect(eventos.where((e) => e['name'] == 'chat_start').single['props'], {
      'tipo': 'sos',
    });
  });
}
