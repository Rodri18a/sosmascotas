import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/veterinarias/veterinarias_repositorio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'mascotas_falsas.dart';
import 'veterinarias_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

MiNegocio _vet({String plan = 'plus'}) => MiNegocio.fromJson({
  'id': 'b1',
  'name': 'Veterinaria Luna',
  'business_type': 'vet',
  'kind': 'local',
  'lat': -34.71,
  'lng': -55.95,
  'verification': 'verified',
  'plan': plan,
  'status': 'active',
});

final _propuesta = Propuesta(
  id: 'pr1',
  negocioId: 'b2',
  negocio: 'Veterinaria Sol',
  mensaje: 'Primera consulta sin cargo',
  estado: EstadoPropuesta.enviada,
  recibida: DateTime(2026, 10, 20),
);

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

/// La ficha es una lista perezosa: baja hasta la tarjeta de la veterinaria.
Future<void> _bajarATarjeta(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(
    find.text('Su veterinaria'),
    300,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

Future<void> _ir(WidgetTester tester, String ruta) async {
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(ruta);
  await tester.pumpAndSettle();
}

Future<void> _abrir(
  WidgetTester tester,
  VeterinariasFalsas veterinarias, {
  NegociosFalsos? negocios,
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
      veterinarias: veterinarias,
      negocios: negocios,
      eventos: eventos,
      mascotas: MascotasFalsas([
        const Mascota(id: 'm1', nombre: 'Toby', especieId: 1, duenoId: 'u1'),
      ]),
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.comercios,
        if (prendida) Funcionalidades.veterinarias,
      }),
      ahora: DateTime(2026, 10, 20, 9),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sin la funcionalidad, la ficha no muestra la tarjeta', (
    tester,
  ) async {
    await _abrir(
      tester,
      VeterinariasFalsas(estado: const EstadoBusqueda(preguntar: true)),
      prendida: false,
    );
    await _ir(tester, '/mascotas/m1');
    expect(find.text('¿Buscás veterinaria para Toby?'), findsNothing);
  });

  testWidgets('el dueño comparte a Toby con su veterinaria', (tester) async {
    final vets = VeterinariasFalsas(
      compartibles: const [
        VeterinariaCompartible(id: 'b1', nombre: 'Vet Luna', compartida: false),
      ],
    );
    final eventos = <Map<String, Object?>>[];
    await _abrir(tester, vets, eventos: eventos);
    await _ir(tester, '/mascotas/m1');
    await _bajarATarjeta(tester);
    await _tocar(tester, find.text('Compartir con Vet Luna'));
    expect(vets.compartidos.single, ('b1', true));
    expect(eventos.map((e) => e['name']), contains('vet_share'));
    final interruptor = tester.widget<SwitchListTile>(
      find.widgetWithText(SwitchListTile, 'Compartir con Vet Luna'),
    );
    expect(interruptor.value, isTrue);
  });

  testWidgets('"Busco veterinaria": sí y después dejar de buscar', (
    tester,
  ) async {
    final vets = VeterinariasFalsas(
      estado: const EstadoBusqueda(preguntar: true),
    );
    await _abrir(tester, vets);
    await _ir(tester, '/mascotas/m1');
    await _bajarATarjeta(tester);
    expect(find.text('¿Buscás veterinaria para Toby?'), findsOneWidget);
    await _tocar(tester, find.text('Sí, quiero propuestas'));
    expect(
      find.text('Estás recibiendo propuestas de veterinarias cercanas.'),
      findsOneWidget,
    );
    await _tocar(tester, find.text('Dejar de buscar'));
    expect(vets.estado.buscando, isFalse);
  });

  testWidgets('"Ahora no" deja de preguntar', (tester) async {
    final vets = VeterinariasFalsas(
      estado: const EstadoBusqueda(preguntar: true),
    );
    final eventos = <Map<String, Object?>>[];
    await _abrir(tester, vets, eventos: eventos);
    await _ir(tester, '/mascotas/m1');
    await _bajarATarjeta(tester);
    await _tocar(tester, find.text('Ahora no'));
    expect(vets.ahoraNoVeces, 1);
    expect(find.text('¿Buscás veterinaria para Toby?'), findsNothing);
    expect(eventos.map((e) => e['name']), contains('vet_search_snooze'));
  });

  testWidgets('el dueño acepta una propuesta', (tester) async {
    final vets = VeterinariasFalsas(
      estado: const EstadoBusqueda(buscando: true),
      propuestas: [_propuesta],
    );
    await _abrir(tester, vets);
    await _ir(tester, '/mascotas/m1');
    await _bajarATarjeta(tester);
    expect(find.text('Propuesta de Veterinaria Sol'), findsOneWidget);
    await _tocar(tester, find.text('Aceptar'));
    expect(vets.respuestas.single, ('pr1', true));
    expect(
      find.text('Aceptada: ahora Veterinaria Sol es su veterinaria.'),
      findsOneWidget,
    );
  });

  testWidgets('sin plan Plus, el módulo Socios no se prende', (tester) async {
    await _abrir(
      tester,
      VeterinariasFalsas(),
      negocios: NegociosFalsos([_vet(plan: 'basic')]),
    );
    await _ir(tester, '/negocio');
    await tester.scrollUntilVisible(
      find.text('Socios y «Busco veterinaria»'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await _tocar(tester, find.text('Socios y «Busco veterinaria»'));
    expect(find.text('Socios necesita el plan Plus.'), findsOneWidget);
    expect(
      tester.widget<SwitchListTile>(find.byType(SwitchListTile)).onChanged,
      isNull,
    );
  });

  testWidgets('con Plus: prende Socios, recuerda y manda una propuesta', (
    tester,
  ) async {
    final vets = VeterinariasFalsas(
      socios: [
        Socio(
          mascotaId: 'm9',
          nombre: 'Lola',
          especieId: 1,
          duenio: 'Beto',
          proximo: DateTime(2026, 11, 3),
          proximoQue: 'Vacuna antirrábica',
        ),
      ],
      demandaLista: const [Demanda(especieId: 1, cantidad: 7)],
    );
    final eventos = <Map<String, Object?>>[];
    await _abrir(
      tester,
      vets,
      negocios: NegociosFalsos([_vet()]),
      eventos: eventos,
    );
    await _ir(tester, '/negocio/socios/b1');
    await _tocar(tester, find.text('Módulo Socios'));
    expect(vets.prendidos, {Modulo.socios});

    expect(find.textContaining('De Beto · Próximo: Vacuna'), findsOneWidget);
    await _tocar(tester, find.byTooltip('Recordar'));
    await _tocar(tester, find.widgetWithText(FilledButton, 'Recordar'));
    final (mascota, titulo, cuando) = vets.recordados.single;
    expect((mascota, titulo), ('m9', 'Vacuna antirrábica'));
    expect(cuando, DateTime(2026, 10, 27, 10));
    expect(
      find.text('Listo: le va a sonar en el celular del dueño.'),
      findsOneWidget,
    );

    ScaffoldMessenger.of(
      tester.element(find.byType(Scaffold).last),
    ).removeCurrentSnackBar();
    expect(find.textContaining(': 7'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(
        TextField,
        'Tu propuesta (por ejemplo: primera consulta sin cargo)',
      ),
      'Primera consulta sin cargo',
    );
    await _tocar(tester, find.text('Enviar propuesta'));
    expect(vets.enviadas.single, 'Primera consulta sin cargo');
    expect(find.text('Le llegó a 4 mascotas.'), findsOneWidget);
    expect(find.text('4 enviadas · 0 vistas · 0 aceptadas'), findsOneWidget);
    expect(
      eventos.map((e) => e['name']),
      containsAll(['module_toggle', 'vet_remind', 'vet_proposal_send']),
    );
  });

  testWidgets('el límite de propuestas se explica', (tester) async {
    final vets = VeterinariasFalsas(prendidos: {Modulo.socios})
      ..fallarCon = ErrorVeterinarias.limite;
    await _abrir(tester, vets, negocios: NegociosFalsos([_vet()]));
    await _ir(tester, '/negocio/socios/b1');
    await tester.enterText(find.byType(TextField), 'Vacunación a domicilio');
    await _tocar(tester, find.text('Enviar propuesta'));
    expect(
      find.text('Como máximo podés mandar 2 propuestas por semana.'),
      findsOneWidget,
    );
  });
}
