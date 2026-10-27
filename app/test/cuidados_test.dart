import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/agenda/cuidados_negocio.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'cuidados_falsos.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'mascotas_falsas.dart';
import 'veterinarias_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');
final _ahora = DateTime(2026, 10, 28, 10);

final _condiciones = CondicionesCuidados.fromJson({
  'kinds': ['walk', 'boarding'],
  'days_ahead': 30,
  'max_days': 1,
  'conditions': 'Vacunas al día',
  'completos': <String>[],
});

Cuidado _cuidado(
  String id, {
  required DateTime desde,
  EstadoCuidado estado = EstadoCuidado.aceptado,
  String? chat,
}) => Cuidado(
  id: id,
  negocioId: 'b1',
  negocio: 'Hotel Canino',
  cliente: 'Ana',
  mascotas: const ['Toby (Perro)'],
  tipo: TipoCuidado.estadia,
  desde: desde,
  hasta: desde.add(const Duration(days: 2)),
  estado: estado,
  chatId: chat,
);

Future<void> _abrir(
  WidgetTester tester, {
  required CuidadosFalsos cuidados,
  List<Map<String, Object?>>? eventos,
  NegociosFalsos? negocios,
  VeterinariasFalsas? veterinarias,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      cuidados: cuidados,
      ahora: _ahora,
      eventos: eventos,
      negocios: negocios,
      veterinarias: veterinarias,
      mascotas: MascotasFalsas([
        const Mascota(id: 'm1', nombre: 'Toby', especieId: 1),
        const Mascota(id: 'm2', nombre: 'Michi', especieId: 2),
      ]),
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.agenda,
        Funcionalidades.cuidados,
        Funcionalidades.comercios,
      }),
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

/// Elige un día en el selector de fecha (un solo día por pedido).
Future<void> _elegirDia(WidgetTester tester, int dia) async {
  await _tocar(tester, find.text('Elegir las fechas'));
  await tester.tap(find.text('$dia'));
  await tester.pumpAndSettle();
  await tester.tap(find.text('ACEPTAR'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('pedir un paseo: servicio, día, momento y mascotas', (
    tester,
  ) async {
    final cuidados = CuidadosFalsos(condicionesFijas: _condiciones);
    final eventos = <Map<String, Object?>>[];
    await _abrir(tester, cuidados: cuidados, eventos: eventos);
    await _ir(tester, '/cuidados/pedir/b1');

    expect(find.text('Vacunas al día'), findsOneWidget);
    await _tocar(tester, find.text('Paseo'));
    await _elegirDia(tester, 30);
    await _tocar(tester, find.text('De mañana'));
    await _tocar(tester, find.text('Toby'));
    await _tocar(tester, find.text('Michi'));
    await tester.enterText(find.byType(TextField), 'Tira de la correa');
    await _tocar(tester, find.text('Enviar el pedido'));

    expect(cuidados.pedidos.single, {
      'negocio': 'b1',
      'tipo': TipoCuidado.paseo,
      'desde': DateTime(2026, 10, 30),
      'hasta': DateTime(2026, 10, 30),
      'mascotas': ['m1', 'm2'],
      'franja': FranjaCuidado.manana,
      'nota': 'Tira de la correa',
    });
    expect(eventos.where((e) => e['name'] == 'care_request').single['props'], {
      'tipo': 'walk',
      'dias': 1,
      'mascotas': 2,
    });
    expect(find.text('Mis paseos y estadías'), findsOneWidget);
  });

  testWidgets('sin lugar: lo dice antes de pedir y no deja enviar', (
    tester,
  ) async {
    final cuidados = CuidadosFalsos(
      condicionesFijas: CondicionesCuidados.fromJson({
        'kinds': ['boarding'],
        'days_ahead': 30,
        'max_days': 1,
        'completos': ['2026-10-30'],
      }),
    );
    await _abrir(tester, cuidados: cuidados);
    await _ir(tester, '/cuidados/pedir/b1');
    await _tocar(tester, find.text('Estadía'));
    await _elegirDia(tester, 30);
    expect(find.textContaining('No le queda lugar'), findsOneWidget);
    await _tocar(tester, find.text('Toby'));
    await _tocar(tester, find.text('Enviar el pedido'));
    expect(cuidados.pedidos, isEmpty);
  });

  testWidgets('mis paseos y estadías: chat si aceptó y cancelar hasta el '
      'día anterior', (tester) async {
    final cuidados = CuidadosFalsos(
      mios: [
        _cuidado('lejos', desde: DateTime(2026, 10, 30), chat: 'chat1'),
        _cuidado('hoy', desde: DateTime(2026, 10, 28)),
      ],
    );
    await _abrir(tester, cuidados: cuidados);
    await _ir(tester, '/cuidados');
    expect(find.text('Abrir el chat'), findsOneWidget);

    await _tocar(tester, find.text('Cancelar').last);
    expect(find.textContaining('Ya empezó'), findsOneWidget);
    expect(cuidados.cambios, isEmpty);

    await _tocar(tester, find.text('Cancelar').first);
    await _tocar(
      tester,
      find.widgetWithText(FilledButton, 'Cancelar el pedido'),
    );
    expect(cuidados.cambios.single, ('lejos', EstadoCuidado.cancelado));
  });

  testWidgets('el hotel configura qué ofrece y acepta un pedido (abre el '
      'chat)', (tester) async {
    final cuidados = CuidadosFalsos(
      delNegocio: [
        _cuidado(
          'p1',
          desde: DateTime(2026, 11, 2),
          estado: EstadoCuidado.pendiente,
        ),
      ],
    );
    final negocios = NegociosFalsos([
      MiNegocio.fromJson({
        'id': 'b1',
        'name': 'Hotel Canino',
        'business_type': 'hotel',
        'kind': 'local',
        'lat': -34.71,
        'lng': -55.95,
        'verification': 'verified',
        'plan': 'plus',
        'status': 'active',
      }),
    ]);
    final eventos = <Map<String, Object?>>[];
    await _abrir(
      tester,
      cuidados: cuidados,
      eventos: eventos,
      negocios: negocios,
      veterinarias: VeterinariasFalsas(prendidos: {Modulo.agenda}),
    );
    await _ir(tester, '/negocio?seccion=agenda');

    expect(find.text('Paseos y estadías'), findsOneWidget);
    expect(find.textContaining('prendé «Tomar turnos'), findsNothing);
    await _tocar(tester, find.widgetWithText(FilterChip, 'Estadía'));
    await _tocar(tester, find.text('Guardar'));
    expect(cuidados.guardados.single.tipos, {TipoCuidado.estadia});
    expect(eventos.where((e) => e['name'] == 'care_save').single['props'], {
      'tipos': 1,
      'cupo': 5,
    });

    await tester.scrollUntilVisible(
      find.text('Aceptar y abrir el chat'),
      300,
      scrollable: find
          .descendant(
            of: find.byType(CuidadosNegocio),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    expect(find.textContaining('Ana · Toby (Perro)'), findsOneWidget);
    await _tocar(tester, find.text('Aceptar y abrir el chat'));
    expect(cuidados.respuestas.single, ('p1', true));

    // En Turnos sigue la agenda de siempre.
    await _ir(tester, '/negocio?seccion=agenda');
    await _tocar(tester, find.text('Turnos'));
    expect(find.text('Tomar turnos desde la app'), findsOneWidget);
  });
}
