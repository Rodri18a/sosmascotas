import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'equipo_falso.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'tienda_falsa.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

MiNegocio _negocio({String rol = 'owner', String plan = 'plus'}) =>
    MiNegocio.fromJson({
      'id': 'b1',
      'name': 'Pet Shop Luna',
      'business_type': 'petshop',
      'kind': 'local',
      'lat': -34.71,
      'lng': -55.95,
      'verification': 'verified',
      'plan': plan,
      'status': 'active',
      'rol': rol,
    });

Future<void> _abrir(
  WidgetTester tester, {
  required List<MiNegocio> negocios,
  required EquipoFalso equipo,
  String ruta = '/negocio',
}) async {
  tester.view
    ..physicalSize = const Size(400, 850)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      negocios: NegociosFalsos(negocios),
      tienda: TiendaFalsa(),
      equipo: equipo,
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.comercios,
        Funcionalidades.catalogo,
        Funcionalidades.planes,
        Funcionalidades.equipo,
      }),
    ),
  );
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(ruta);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('el dueño invita desde el panel con un enlace', (tester) async {
    final equipo = EquipoFalso();
    await _abrir(tester, negocios: [_negocio()], equipo: equipo);
    await tester.tap(find.text('Equipo'));
    await tester.pumpAndSettle();
    expect(find.text('Todavía no sumaste a nadie.'), findsOneWidget);
    await tester.tap(find.text('Invitar a alguien'));
    await tester.pumpAndSettle();
    expect(find.textContaining('/equipo/ABCD2345'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Invitaciones sin usar'), findsOneWidget);
    await tester.tap(find.text('Anular'));
    await tester.pumpAndSettle();
    expect(equipo.invitaciones, isEmpty);
    expect(find.text('Invitaciones sin usar'), findsNothing);
  });

  testWidgets('sin Plus, el panel avisa que el equipo es del plan Plus', (
    tester,
  ) async {
    await _abrir(
      tester,
      negocios: [_negocio(plan: 'basic')],
      equipo: EquipoFalso(),
    );
    expect(find.text('El equipo es del plan Plus.'), findsOneWidget);
  });

  testWidgets('el dueño saca a alguien del equipo', (tester) async {
    final equipo = EquipoFalso(
      personas: [
        PersonaEquipo(
          userId: 'u2',
          nombre: 'Beto',
          desde: DateTime(2026, 10, 28),
        ),
      ],
    );
    await _abrir(
      tester,
      negocios: [_negocio()],
      equipo: equipo,
      ruta: '/negocio/equipo/b1',
    );
    expect(find.text('Beto'), findsOneWidget);
    await tester.tap(find.text('Sacar del equipo'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Sacar del equipo'));
    await tester.pumpAndSettle();
    expect(equipo.personas, isEmpty);
    expect(find.text('Beto'), findsNothing);
  });

  testWidgets('el empleado ve el equipo en vez de la ficha y no lo del dueño', (
    tester,
  ) async {
    await _abrir(
      tester,
      negocios: [_negocio(rol: 'employee')],
      equipo: EquipoFalso(
        soyTitular: false,
        personas: [
          PersonaEquipo(
            userId: 'u1',
            nombre: 'Ana',
            desde: DateTime(2026, 10, 28),
            soyYo: true,
          ),
        ],
      ),
    );
    // Ni plan ni la tarjeta para armar el equipo.
    expect(find.text('Tu plan: Plus'), findsNothing);
    expect(find.text('Invitar a alguien'), findsNothing);
    // La última pestaña es Equipo, no la ficha.
    expect(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Negocio'),
      ),
      findsNothing,
    );
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Equipo'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ana (vos)'), findsOneWidget);
    expect(find.text('Dejar el equipo'), findsOneWidget);
    // Carga productos, pero no prende el catálogo.
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Catálogo'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Catálogo y pedidos'), findsNothing);
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('el dueño sí ve el interruptor del catálogo', (tester) async {
    await _abrir(tester, negocios: [_negocio()], equipo: EquipoFalso());
    await tester.tap(
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Catálogo'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Catálogo y pedidos'), findsOneWidget);
  });

  testWidgets('con el enlace, se suma al equipo y abre el modo comercio', (
    tester,
  ) async {
    final equipo = EquipoFalso();
    await _abrir(
      tester,
      negocios: [_negocio(rol: 'employee')],
      equipo: equipo,
      ruta: '/equipo/abcd2345',
    );
    await tester.tap(find.text('Unirme al equipo'));
    await tester.pumpAndSettle();
    expect(equipo.unidos, ['ABCD2345']);
    expect(find.text('Modo comercio'), findsOneWidget);
  });

  testWidgets('un código que no sirve se explica', (tester) async {
    await _abrir(
      tester,
      negocios: const [],
      equipo: EquipoFalso(),
      ruta: '/equipo/hola',
    );
    expect(
      find.text(
        'Este código no existe, ya se usó o venció. Pedile uno nuevo al dueño.',
      ),
      findsOneWidget,
    );
    expect(find.text('Unirme al equipo'), findsNothing);
  });
}
