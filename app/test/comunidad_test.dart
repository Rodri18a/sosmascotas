import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/comunidad/comunidad_repositorio.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comunidad_falsa.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'mascotas_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

final _grupos = [
  Grupo.fromJson({
    'id': 'perros',
    'kind': 'species',
    'name': 'Perros',
    'icon': '🐶',
    'species_id': 1,
    'miembros': 20,
    'publicaciones_semana': 2,
    'soy_miembro': true,
  }),
  Grupo.fromJson({
    'id': 'mayores',
    'kind': 'topic',
    'name': 'Mascotas mayores',
    'miembros': 0,
    'soy_miembro': false,
  }),
];

final _publicacion = Publicacion(
  id: 'p1',
  tipo: TipoPublicacion.pregunta,
  texto: '¿Cada cuánto lo baño?',
  creada: DateTime(2026, 10, 28, 9),
  autor: 'Leo',
  cantidadComentarios: 1,
  grupoId: 'perros',
  grupoNombre: 'Perros',
  soyMiembro: true,
  comentarios: [
    Comentario(
      id: 'c1',
      texto: 'Una vez al mes',
      autor: 'Sol',
      creado: DateTime(2026, 10, 28, 10),
    ),
  ],
);

Future<void> _abrir(
  WidgetTester tester, {
  required ComunidadFalsa comunidad,
  List<Map<String, Object?>>? eventos,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      comunidad: comunidad,
      ahora: DateTime(2026, 10, 28, 12),
      eventos: eventos,
      mascotas: MascotasFalsas([
        const Mascota(id: 'm1', nombre: 'Toby', especieId: 1, razaId: 2),
        const Mascota(id: 'm2', nombre: 'Luna', especieId: 1, razaId: 1),
      ]),
      funcionalidades: FuncionalidadesFalsas({Funcionalidades.grupos}),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _ir(WidgetTester tester, String ruta) async {
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(ruta);
  await tester.pumpAndSettle();
}

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('grupos: los míos, por especie y temas, y el de mi raza '
      '(no "Mestizo")', (tester) async {
    final comunidad = ComunidadFalsa(grupos: _grupos);
    final eventos = <Map<String, Object?>>[];
    await _abrir(tester, comunidad: comunidad, eventos: eventos);
    await _ir(tester, '/grupos');

    expect(find.text('Tus grupos'), findsOneWidget);
    expect(find.text('Temas', skipOffstage: false), findsOneWidget);
    expect(
      find.text('20 integrantes · 2 publicaciones esta semana'),
      findsWidgets,
    );
    // Toby es Labrador; Luna, mestiza: solo se sugiere el de Labrador.
    expect(find.widgetWithText(ActionChip, 'Mestizo'), findsNothing);
    await _tocar(tester, find.widgetWithText(ActionChip, 'Labrador'));
    expect(comunidad.razasPedidas, [2]);
    expect(comunidad.uniones.single, ('raza-2', true));
    expect(eventos.where((e) => e['name'] == 'group_join').single['props'], {
      'tipo': 'breed',
    });
  });

  testWidgets('publicar: frena venta o cruza antes de mandar', (tester) async {
    final comunidad = ComunidadFalsa(grupos: _grupos, detalle: _publicacion);
    final eventos = <Map<String, Object?>>[];
    await _abrir(tester, comunidad: comunidad, eventos: eventos);
    await _ir(tester, '/grupos/perros');
    await _tocar(tester, find.text('Publicar'));

    await tester.enterText(find.byType(TextField), 'Vendo cachorros');
    await _tocar(tester, find.widgetWithText(FilledButton, 'Publicar'));
    expect(find.textContaining('no se publican ventas'), findsOneWidget);
    expect(comunidad.publicadas, isEmpty);

    await _tocar(tester, find.text('Consejo'));
    await tester.enterText(
      find.byType(TextField),
      'Probá con juguetes de goma',
    );
    await _tocar(tester, find.widgetWithText(FilledButton, 'Publicar'));
    expect(comunidad.publicadas.single, {
      'grupo': 'perros',
      'tipo': TipoPublicacion.consejo,
      'texto': 'Probá con juguetes de goma',
      'fotos': <String>[],
    });
    expect(eventos.where((e) => e['name'] == 'post_create').single['props'], {
      'tipo': 'tip',
      'fotos': 0,
    });
  });

  testWidgets('un grupo del que no soy parte: unirme', (tester) async {
    final comunidad = ComunidadFalsa(grupos: _grupos);
    await _abrir(tester, comunidad: comunidad);
    await _ir(tester, '/grupos/mayores');
    expect(find.text('Publicar'), findsNothing);
    await _tocar(tester, find.text('Unirme al grupo'));
    expect(comunidad.uniones.single, ('mayores', true));
  });

  testWidgets('publicación: comentar, saludar y reportar', (tester) async {
    final comunidad = ComunidadFalsa(grupos: _grupos, detalle: _publicacion);
    await _abrir(tester, comunidad: comunidad);
    await _ir(tester, '/publicacion/p1');

    expect(find.text('Una vez al mes'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'Depende del pelo');
    await _tocar(tester, find.byIcon(Icons.send_outlined));
    expect(comunidad.comentarios.single, ('p1', 'Depende del pelo'));

    await _tocar(tester, find.text('Opciones'));
    await _tocar(tester, find.text('Saludar'));
    await _tocar(tester, find.text('Mandar el saludo'));
    expect(comunidad.saludados.single.$1, 'post');
    expect(comunidad.saludados.single.$2, 'p1');

    await _tocar(tester, find.byTooltip('Opciones'));
    await _tocar(tester, find.text('Reportar: vende o cruza animales'));
    expect(comunidad.reportes.single, ('comment', 'c1', 'venta'));
  });

  testWidgets('si la persona no quiere chatear, lo dice', (tester) async {
    final comunidad = ComunidadFalsa(grupos: _grupos, detalle: _publicacion)
      ..fallar = const ComunidadException(ErrorComunidad.noQuiere);
    await _abrir(tester, comunidad: comunidad);
    await _ir(tester, '/publicacion/p1');
    await _tocar(tester, find.text('Opciones'));
    await _tocar(tester, find.text('Saludar'));
    await _tocar(tester, find.text('Mandar el saludo'));
    expect(
      find.text('Esa persona no quiere chatear por ahora.'),
      findsOneWidget,
    );
  });

  testWidgets('saludos: aceptar abre el chat; los mandados esperan', (
    tester,
  ) async {
    final comunidad = ComunidadFalsa(
      saludos: [
        Saludo(
          id: 's1',
          recibido: true,
          persona: 'Leo',
          mensaje: '¡Hola! Mi perro también es labrador',
          publicacionTexto: '¿Cada cuánto lo baño?',
          estado: EstadoSaludo.pendiente,
          creado: DateTime(2026, 10, 28, 9),
        ),
        Saludo(
          id: 's2',
          recibido: false,
          persona: 'Sol',
          mensaje: 'Hola',
          estado: EstadoSaludo.pendiente,
          creado: DateTime(2026, 10, 28, 8),
        ),
      ],
    );
    await _abrir(tester, comunidad: comunidad);
    await _ir(tester, '/saludos');
    expect(find.text('Leo te saluda'), findsOneWidget);
    expect(find.text('Saludaste a Sol'), findsOneWidget);
    expect(find.text('Esperando respuesta'), findsOneWidget);
    await _tocar(tester, find.text('Aceptar y abrir el chat'));
    expect(comunidad.respuestas.single, ('s1', true));
  });
}
