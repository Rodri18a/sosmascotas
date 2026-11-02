import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comunidad_falsa.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

final _vacuna = Publicacion(
  id: 'q1',
  tipo: TipoPublicacion.pregunta,
  texto: '¿Cada cuánto se da la vacuna antirrábica?',
  creada: DateTime(2026, 10, 30),
  tema: TemaPregunta.salud,
  cantidadComentarios: 2,
  resuelta: true,
);
final _viaje = Publicacion(
  id: 'q2',
  tipo: TipoPublicacion.pregunta,
  texto: '¿Qué papeles necesito para viajar a Brasil?',
  creada: DateTime(2026, 10, 29),
  tema: TemaPregunta.viajes,
);
final _consejo = Publicacion(
  id: 'p3',
  tipo: TipoPublicacion.consejo,
  texto: 'Un consejo que no es pregunta',
  creada: DateTime(2026, 10, 28),
);

Future<List<Map<String, Object?>>> _abrir(
  WidgetTester tester,
  ComunidadFalsa comunidad, {
  String inicio = Rutas.preguntas,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  final eventos = <Map<String, Object?>>[];
  await tester.pumpWidget(
    appDePrueba(
      inicio: inicio,
      cuenta: ServicioCuentaFalso(conectado: _ana),
      comunidad: comunidad,
      eventos: eventos,
      ahora: DateTime(2026, 11, 2, 12),
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.grupos,
        Funcionalidades.preguntas,
      }),
    ),
  );
  await tester.pumpAndSettle();
  return eventos;
}

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets(
    'la lista muestra solo preguntas; se filtra por tema y se busca',
    (tester) async {
      final comunidad = ComunidadFalsa(
        publicaciones: [_vacuna, _viaje, _consejo],
      );
      final eventos = await _abrir(tester, comunidad);
      expect(find.text(_vacuna.texto), findsOneWidget);
      expect(find.text(_viaje.texto), findsOneWidget);
      expect(find.text(_consejo.texto), findsNothing);
      expect(find.textContaining('✓ Resuelta'), findsOneWidget);

      await _tocar(tester, find.widgetWithText(ChoiceChip, 'Viajes'));
      expect(find.text(_vacuna.texto), findsNothing);
      expect(find.text(_viaje.texto), findsOneWidget);

      // La fila de temas se corrió al tocar «Viajes»: se vuelve al principio.
      await tester.scrollUntilVisible(
        find.widgetWithText(ChoiceChip, 'Todas'),
        -200,
        scrollable: find
            .byWidgetPredicate(
              (w) => w is Scrollable && w.axisDirection == AxisDirection.right,
            )
            .last,
      );
      await _tocar(tester, find.widgetWithText(ChoiceChip, 'Todas'));
      await tester.enterText(find.byType(TextField), 'antirrábica');
      await tester.testTextInput.receiveAction(TextInputAction.search);
      await tester.pumpAndSettle();
      expect(find.text(_vacuna.texto), findsOneWidget);
      expect(find.text(_viaje.texto), findsNothing);
      expect(comunidad.busquedas.last, (null, 'antirrábica'));
      expect(eventos.map((e) => e['name']), contains('question_search'));
    },
  );

  testWidgets('preguntar: pide el tema y va a «Preguntas generales»', (
    tester,
  ) async {
    final comunidad = ComunidadFalsa()
      ..detalle = Publicacion(
        id: 'q1',
        tipo: TipoPublicacion.pregunta,
        texto: '¿Puede comer huevo?',
        creada: DateTime(2026, 11, 2),
        tema: TemaPregunta.alimentacion,
        esMia: true,
        soyMiembro: true,
        grupoId: 'g1',
        grupoNombre: 'Preguntas generales',
      );
    final eventos = await _abrir(tester, comunidad);
    await _tocar(tester, find.text('Preguntar'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Tu pregunta'),
      '¿Puede comer huevo?',
    );
    await _tocar(tester, find.text('Publicar pregunta'));
    expect(find.text('Elegí un tema y escribí tu pregunta.'), findsOneWidget);

    await _tocar(tester, find.widgetWithText(ChoiceChip, 'Alimentación'));
    await _tocar(tester, find.text('Publicar pregunta'));
    expect(comunidad.preguntadas, [
      (TemaPregunta.alimentacion, '¿Puede comer huevo?', null),
    ]);
    // Queda abierta, con su tema.
    expect(find.widgetWithText(AppBar, 'Preguntas generales'), findsOneWidget);
    expect(find.widgetWithText(Chip, 'Alimentación'), findsOneWidget);
    expect(
      eventos.where((e) => e['name'] == 'question_create').single['props'],
      {'topic': 'food'},
    );
  });

  testWidgets('quien preguntó marca la respuesta que le sirvió', (
    tester,
  ) async {
    final comunidad = ComunidadFalsa()
      ..detalle = Publicacion(
        id: 'q1',
        tipo: TipoPublicacion.pregunta,
        texto: '¿Cada cuánto se desparasita?',
        creada: DateTime(2026, 11, 1),
        tema: TemaPregunta.salud,
        esMia: true,
        soyMiembro: true,
        grupoId: 'g1',
        comentarios: [
          Comentario(
            id: 'c1',
            texto: 'Cada tres meses, según la veterinaria.',
            autor: 'Leo',
            creado: DateTime(2026, 11, 1, 10),
          ),
        ],
      );
    final eventos = await _abrir(
      tester,
      comunidad,
      inicio: Rutas.publicacionComunidad('q1'),
    );
    await _tocar(tester, find.text('Me sirvió'));
    expect(comunidad.marcadas, [('q1', 'c1')]);
    expect(eventos.map((e) => e['name']), contains('question_solved'));
  });

  testWidgets('en una pregunta se responde uniéndose sin salir', (
    tester,
  ) async {
    final comunidad = ComunidadFalsa()
      ..detalle = Publicacion(
        id: 'q2',
        tipo: TipoPublicacion.pregunta,
        texto: '¿Qué papeles necesito para viajar a Brasil?',
        creada: DateTime(2026, 11, 1),
        tema: TemaPregunta.viajes,
        grupoId: 'g1',
      );
    await _abrir(tester, comunidad, inicio: Rutas.publicacionComunidad('q2'));
    expect(find.text('Me sirvió'), findsNothing, reason: 'no es mía');
    await _tocar(tester, find.text('Unirme al grupo para responder'));
    expect(comunidad.uniones, [('g1', true)]);
  });
}
