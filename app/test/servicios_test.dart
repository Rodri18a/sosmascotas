import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'tienda_falsa.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

Comercio _peluqueria(PlanComercio plan) => Comercio(
  id: 'pel',
  nombre: 'Peluquería Ejemplo',
  tipo: 'grooming',
  punto: const Punto(-34.72, -55.95),
  horario: const Horario({}),
  whatsapp: '099 000 015',
  plan: plan,
);

List<Servicio> _servicios() => const [
  Servicio(
    id: 's1',
    nombre: 'Baño y corte',
    descripcion: 'Incluye corte de uñas.',
    precio: 600,
    desde: true,
    duracionMinutos: 90,
  ),
  Servicio(id: 's2', nombre: 'Deslanado', duracionMinutos: 60),
  Servicio(id: 's3', nombre: 'Corte de uñas', precio: 150),
];

MiNegocio _miPeluqueria(String plan) => MiNegocio.fromJson({
  'id': 'pel',
  'name': 'Peluquería Ejemplo',
  'business_type': 'grooming',
  'kind': 'local',
  'lat': -34.72,
  'lng': -55.95,
  'verification': 'verified',
  'plan': plan,
  'status': 'active',
});

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

Future<void> _abrir(
  WidgetTester tester, {
  required TiendaFalsa tienda,
  PlanComercio plan = PlanComercio.plus,
  NegociosFalsos? negocios,
  List<Uri>? enlaces,
  List<Map<String, Object?>>? metricas,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      comercios: ComerciosFalsos([_peluqueria(plan)]),
      tienda: tienda,
      negocios: negocios,
      enlacesAbiertos: enlaces,
      eventos: metricas,
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.comercios,
        Funcionalidades.catalogo,
      }),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _abrirFicha(WidgetTester tester) async {
  await tester.tap(find.byKey(const ValueKey('mapa-mover')));
  await tester.pumpAndSettle();
  await _tocar(tester, find.byKey(const ValueKey('pin-pel')));
}

Future<void> _abrirNegocio(WidgetTester tester) async {
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/negocio');
  await tester.pumpAndSettle();
  await _tocar(tester, find.text('Negocio').last);
}

Future<void> _abrirMisServicios(WidgetTester tester) async {
  await _abrirNegocio(tester);
  await _tocar(tester, find.byKey(const ValueKey('abrir-servicios')));
}

void main() {
  testWidgets('la ficha de un comercio Plus muestra sus servicios y '
      '"Consultar" abre su WhatsApp con el servicio', (tester) async {
    final enlaces = <Uri>[];
    final metricas = <Map<String, Object?>>[];
    await _abrir(
      tester,
      tienda: TiendaFalsa(servicios: _servicios()),
      enlaces: enlaces,
      metricas: metricas,
    );
    await _abrirFicha(tester);

    expect(find.text('Servicios'), findsOneWidget);
    expect(
      find.text('Incluye corte de uñas.\n1 h 30 min · desde \$ 600'),
      findsOneWidget,
    );
    expect(find.text('1 h · Consultar precio'), findsOneWidget);
    expect(find.text(r'$ 150'), findsOneWidget);

    await _tocar(
      tester,
      find.descendant(
        of: find.byKey(const ValueKey('servicio-s2')),
        matching: find.text('Consultar'),
      ),
    );
    expect(enlaces.single.host, 'wa.me');
    expect(enlaces.single.path, '/59899000015');
    expect(enlaces.single.queryParameters['text'], contains('Deslanado'));
    expect(metricas.map((e) => e['name']), contains('service_ask'));
  });

  testWidgets('sin plan Plus, la ficha no muestra servicios', (tester) async {
    await _abrir(
      tester,
      tienda: TiendaFalsa(servicios: _servicios()),
      plan: PlanComercio.featured,
    );
    await _abrirFicha(tester);
    expect(find.text('Baño y corte'), findsNothing);
  });

  testWidgets('modo comercio: cargar un servicio con precio "desde" y '
      'duración', (tester) async {
    final tienda = TiendaFalsa();
    await _abrir(
      tester,
      tienda: tienda,
      negocios: NegociosFalsos([_miPeluqueria('plus')]),
    );
    await _abrirMisServicios(tester);
    expect(
      find.text('Todavía no cargaste servicios. Tocá «Agregar servicio».'),
      findsOneWidget,
    );

    await _tocar(tester, find.text('Agregar servicio'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre'),
      'Baño y corte',
    );
    await tester.enterText(find.widgetWithText(TextField, 'Precio'), '600');
    await _tocar(
      tester,
      find.text('Es un precio «desde» (cambia según el caso)'),
    );
    await _tocar(tester, find.text('Sin indicar'));
    await _tocar(tester, find.text('1 h 30 min').last);
    await _tocar(tester, find.text('Guardar'));

    final guardado = tienda.serviciosGuardados.single;
    expect(guardado.nombre, 'Baño y corte');
    expect(guardado.precio, 600);
    expect(guardado.desde, isTrue);
    expect(guardado.duracionMinutos, 90);
    expect(find.text('1 h 30 min · desde \$ 600'), findsOneWidget);
  });

  testWidgets('modo comercio sin Plus: se explica y no se cargan', (
    tester,
  ) async {
    await _abrir(
      tester,
      tienda: TiendaFalsa(),
      negocios: NegociosFalsos([_miPeluqueria('basic')]),
    );
    await _abrirMisServicios(tester);
    expect(
      find.text('Los servicios se publican con el plan Plus.'),
      findsWidgets,
    );
    expect(find.text('Agregar servicio'), findsNothing);
  });

  testWidgets('"Compartir mi página" solo con plan Plus (D90)', (tester) async {
    await _abrir(
      tester,
      tienda: TiendaFalsa(),
      negocios: NegociosFalsos([_miPeluqueria('plus')]),
    );
    await _abrirNegocio(tester);
    expect(find.byKey(const ValueKey('compartir-pagina')), findsOneWidget);
  });

  testWidgets('sin Plus no hay página para compartir', (tester) async {
    await _abrir(
      tester,
      tienda: TiendaFalsa(),
      negocios: NegociosFalsos([_miPeluqueria('featured')]),
    );
    await _abrirNegocio(tester);
    expect(find.byKey(const ValueKey('compartir-pagina')), findsNothing);
  });
}
