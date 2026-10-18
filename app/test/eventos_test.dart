import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'eventos_falsos.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

final _jornada = Evento(
  id: 'e1',
  tipo: TipoEvento.castracion,
  titulo: 'Jornada de castración',
  desde: DateTime(2026, 11, 7, 10),
  hasta: DateTime(2026, 11, 7, 17),
  punto: const Punto(-34.72, -55.95),
  organizador: 'Veterinaria Centro',
);

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

Future<void> _abrir(
  WidgetTester tester, {
  EventosFalsos? eventos,
  NegociosFalsos? negocios,
  List<Map<String, Object?>>? metricas,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      eventosRepo: eventos,
      negocios: negocios,
      eventos: metricas,
      selectorFoto: (_) async =>
          img.encodeJpg(img.Image(width: 40, height: 30)),
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.eventos,
        Funcionalidades.comercios,
      }),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el evento aparece en el mapa y abre su ficha', (tester) async {
    await _abrir(tester, eventos: EventosFalsos([_jornada]));
    await tester.tap(find.byKey(const ValueKey('mapa-mover')));
    await tester.pumpAndSettle();
    await _tocar(tester, find.byKey(const ValueKey('pin-evento:e1')));
    expect(find.text('Jornada de castración'), findsWidgets);
    expect(find.text('Organiza: Veterinaria Centro'), findsOneWidget);
    expect(find.text('Cómo llegar'), findsOneWidget);
  });

  testWidgets('Ayuda: próximos eventos y denunciar maltrato', (tester) async {
    final eventos = EventosFalsos([_jornada]);
    final metricas = <Map<String, Object?>>[];
    await _abrir(tester, eventos: eventos, metricas: metricas);
    await _ir(tester, '/ayuda');
    expect(find.text('Jornada de castración'), findsOneWidget);

    await _tocar(tester, find.text('Denunciar maltrato'));
    expect(
      find.textContaining('no reemplaza la denuncia oficial'),
      findsOneWidget,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Qué pasa (cuanto más detalle, mejor)'),
      'Mal',
    );
    await _tocar(tester, find.text('Enviar denuncia'));
    expect(find.textContaining('Contá un poco más'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Qué pasa (cuanto más detalle, mejor)'),
      'Perro atado sin agua desde hace días',
    );
    await _tocar(tester, find.byKey(const ValueKey('mapa-tocar')));
    await _tocar(tester, find.text('Agregar foto'));
    await _tocar(tester, find.text('Elegir de la galería'));
    await _tocar(tester, find.text('Enviar denuncia'));

    final (texto, punto, fotos) = eventos.denuncias.single;
    expect(texto, startsWith('Perro atado'));
    expect(punto, const Punto(-34.72, -55.95));
    expect(fotos, ['u1/denuncia.jpg']);
    expect(metricas.map((e) => e['name']), contains('abuse_report'));
  });

  testWidgets('un negocio verificado publica un evento', (tester) async {
    final eventos = EventosFalsos();
    await _abrir(
      tester,
      eventos: eventos,
      negocios: NegociosFalsos([
        MiNegocio.fromJson({
          'id': 'b1',
          'name': 'Veterinaria Centro',
          'business_type': 'vet',
          'kind': 'local',
          'lat': -34.71,
          'lng': -55.95,
          'hours': {},
          'verification': 'verified',
          'status': 'active',
        }),
      ]),
    );
    await _ir(tester, '/negocio');
    await _tocar(
      tester,
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Negocio'),
      ),
    );
    await _tocar(tester, find.text('Publicar un evento'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Título'),
      'Jornada de vacunación',
    );
    await _tocar(
      tester,
      find.widgetWithText(FilledButton, 'Publicar un evento'),
    );

    final publicado = eventos.publicados.single;
    expect(publicado['business_id'], 'b1');
    expect(publicado['title'], 'Jornada de vacunación');
    expect(publicado['lat'], -34.71);
  });
}
