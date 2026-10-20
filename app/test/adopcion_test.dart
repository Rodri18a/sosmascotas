import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:image/image.dart' as img;
import 'package:sosmascota/src/adopcion/adopcion_repositorio.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'adopcion_falsa.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'mascotas_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

const _pelusa = AnimalAdopcion(
  id: 'a1',
  publicacionId: 'p1',
  nombre: 'Pelusa',
  especieId: 1,
  edadMeses: 30,
  tamano: 'grande',
  necesitaPatio: true,
  fotos: ['u2/pelusa.jpg'],
  deRefugio: true,
  refugio: 'Refugio Patitas',
  aporte: 800,
  aporteCubre: 'castración y vacunas',
);

const _depto = PerfilAdoptante(
  vivienda: 'apartamento',
  patio: false,
  horasSolo: 4,
  ninos: false,
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
  WidgetTester tester,
  AdopcionFalsa adopcion, {
  List<Map<String, Object?>>? eventos,
  bool prendida = true,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      adopcion: adopcion,
      mascotas: MascotasFalsas([
        const Mascota(id: 'm-adoptada', nombre: 'Pelusa', especieId: 1),
      ]),
      eventos: eventos,
      selectorFoto: (_) async =>
          img.encodeJpg(img.Image(width: 40, height: 30)),
      funcionalidades: FuncionalidadesFalsas({
        if (prendida) Funcionalidades.adopcion,
      }),
      ahora: DateTime(2026, 10, 25, 10),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('la entrada está en el menú y lleva a los animales', (
    tester,
  ) async {
    await _abrir(tester, AdopcionFalsa(animales: const [_pelusa]));
    await abrirMenu(tester);
    await _tocar(tester, find.text('Adoptar o dar en adopción'));
    expect(find.text('Pelusa'), findsOneWidget);
    expect(
      find.textContaining('2 años · Grande · Refugio Patitas'),
      findsOneWidget,
    );
  });

  testWidgets('sin la funcionalidad no hay entrada', (tester) async {
    await _abrir(tester, AdopcionFalsa(), prendida: false);
    await _ir(tester, '/ayuda');
    await abrirMenu(tester);
    expect(find.text('Adoptar o dar en adopción'), findsNothing);
  });

  testWidgets('ficha: aporte transparente, compatibilidad y "Me interesa"', (
    tester,
  ) async {
    final adopcion = AdopcionFalsa(animales: const [_pelusa], perfil: _depto);
    final eventos = <Map<String, Object?>>[];
    await _abrir(tester, adopcion, eventos: eventos);
    await _ir(tester, '/adopcion/animal/a1');

    expect(
      find.textContaining(r'Aporte: $800 — cubre castración'),
      findsOneWidget,
    );
    expect(find.textContaining('Ojo: necesita patio'), findsOneWidget);
    await _tocar(tester, find.widgetWithText(FilledButton, 'Me interesa'));
    await tester.enterText(find.byType(TextField).last, 'Tengo tiempo');
    await _tocar(tester, find.widgetWithText(FilledButton, 'Me interesa').last);

    expect(adopcion.interesados.single, ('a1', 'Tengo tiempo'));
    expect(eventos.map((e) => e['name']), contains('adoption_interest'));
  });

  testWidgets('sin perfil de adoptante, primero lo completa', (tester) async {
    final adopcion = AdopcionFalsa(animales: const [_pelusa]);
    await _abrir(tester, adopcion);
    await _ir(tester, '/adopcion/animal/a1');
    await _tocar(tester, find.widgetWithText(FilledButton, 'Me interesa'));

    expect(
      find.widgetWithText(AppBar, 'Mi perfil de adoptante'),
      findsOneWidget,
    );
    await _tocar(tester, find.text('Apartamento'));
    await _tocar(tester, find.text('Guardar perfil'));
    expect(adopcion.perfil!.vivienda, 'apartamento');
    expect(adopcion.interesados, isEmpty);
  });

  testWidgets('dar en adopción: sin foto no; con foto se publica', (
    tester,
  ) async {
    final adopcion = AdopcionFalsa();
    await _abrir(tester, adopcion);
    await _ir(tester, '/adopcion/publicar');
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre (opcional)'),
      'Toby',
    );
    await _tocar(tester, find.text('Publicar'));
    expect(
      find.text('Cada animal necesita al menos una foto.'),
      findsOneWidget,
    );

    await _tocar(tester, find.text('Agregar foto'));
    await _tocar(tester, find.text('Elegir de la galería'));
    await _tocar(tester, find.text('Publicar'));
    final (_, animales) = adopcion.publicadas.single;
    expect(animales.single['name'], 'Toby');
    expect(animales.single['photos'], ['u1/foto.jpg']);
  });

  testWidgets('el límite de 2 publicaciones se explica', (tester) async {
    final adopcion = AdopcionFalsa()..fallarCon = ErrorAdopcion.limite;
    await _abrir(tester, adopcion);
    await _ir(tester, '/adopcion/publicar');
    await _tocar(tester, find.text('Agregar foto'));
    await _tocar(tester, find.text('Elegir de la galería'));
    await _tocar(tester, find.text('Publicar'));
    expect(
      find.textContaining('Ya tenés 2 publicaciones activas'),
      findsOneWidget,
    );
  });

  testWidgets('compromiso: se lee, se acepta y pasa a mis mascotas', (
    tester,
  ) async {
    final adopcion = AdopcionFalsa(
      solicitudes: const [
        SolicitudAdopcion(
          id: 's1',
          animalId: 'a1',
          nombre: 'Pelusa',
          especieId: 1,
          etapa: EtapaAdopcion.agreement,
        ),
      ],
    );
    final eventos = <Map<String, Object?>>[];
    await _abrir(tester, adopcion, eventos: eventos);
    await _ir(tester, '/adopcion');
    await _tocar(tester, find.text('Mis solicitudes'));
    await _tocar(tester, find.text('Ver y aceptar el compromiso'));

    expect(find.textContaining('Castración'), findsWidgets);
    final adoptar = find.widgetWithText(FilledButton, 'Adoptar');
    expect(tester.widget<FilledButton>(adoptar).onPressed, isNull);
    await _tocar(tester, find.text('Leí y acepto el compromiso'));
    await _tocar(tester, adoptar);

    expect(adopcion.compromisos.single, ('s1', 'borrador-2026-10'));
    expect(find.widgetWithText(AppBar, 'Pelusa'), findsOneWidget);
    expect(eventos.map((e) => e['name']), contains('adoption_commit'));
  });

  testWidgets('quien publica ve la compatibilidad y avanza la solicitud', (
    tester,
  ) async {
    final adopcion = AdopcionFalsa(
      animales: const [_pelusa],
      recibidasLista: const [
        SolicitudRecibida(
          id: 's1',
          animalId: 'a1',
          animal: 'Pelusa',
          etapa: EtapaAdopcion.interest,
          adoptante: 'Beto',
          perfil: _depto,
          mensaje: 'Me encantaría',
        ),
      ],
    );
    await _abrir(tester, adopcion);
    await _ir(tester, '/adopcion');
    await _tocar(tester, find.text('Dar en adopción'));
    await _tocar(tester, find.text('Pelusa · De Beto'));

    expect(find.text('«Me encantaría»'), findsOneWidget);
    expect(find.textContaining('Ojo: necesita patio'), findsOneWidget);
    await _tocar(tester, find.text('Pasar a «Cuestionario»'));
    expect(adopcion.avances.single, ('s1', EtapaAdopcion.questionnaire));
  });

  testWidgets('seguimiento a los 7 días', (tester) async {
    final adopcion = AdopcionFalsa(
      seguimientos: [
        Seguimiento(
          id: 'f1',
          dia: 7,
          vence: DateTime(2026, 10, 25),
          respondido: false,
          animal: 'Pelusa',
        ),
        Seguimiento(
          id: 'f2',
          dia: 30,
          vence: DateTime(2026, 11, 17),
          respondido: false,
          animal: 'Pelusa',
        ),
      ],
    );
    await _abrir(tester, adopcion);
    await _ir(tester, '/adopcion');
    await _tocar(tester, find.text('Mis solicitudes'));

    expect(find.text('A los 7 días'), findsOneWidget);
    expect(find.text('A los 30 días'), findsNothing);
    await _tocar(tester, find.text('Seguimiento: ¿cómo va Pelusa?'));
    await tester.enterText(find.byType(TextField).last, 'Se adaptó muy bien');
    await _tocar(tester, find.text('Enviar'));
    expect(adopcion.respuestas.single, ('f1', 'Se adaptó muy bien'));
  });

  testWidgets('calculadora: la persona pone sus montos', (tester) async {
    await _abrir(tester, AdopcionFalsa());
    await _ir(tester, '/adopcion/calculadora');
    await tester.enterText(
      find.widgetWithText(TextField, 'Comida (por mes)'),
      '1500',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Vacunas (por año)'),
      '1200',
    );
    await tester.pumpAndSettle();
    expect(find.text(r'Total: $1600 por mes · $19200 por año'), findsOneWidget);
  });
}
