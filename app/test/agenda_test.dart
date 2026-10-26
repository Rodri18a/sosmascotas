import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/agenda/agenda_repositorio.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'agenda_falsa.dart';
import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'mascotas_falsas.dart';
import 'veterinarias_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');
final _ahora = DateTime(2026, 10, 26, 10);

final _condiciones = CondicionesAgenda.fromJson({
  'slot_min': 30,
  'days_ahead': 7,
  'bloqueados': ['2026-10-27'],
  'servicios': [
    {'id': 's1', 'name': 'Baño y corte', 'duration_min': 90},
  ],
});

Turno _turno(
  String id, {
  required DateTime inicio,
  EstadoTurno estado = EstadoTurno.confirmado,
}) => Turno(
  id: id,
  negocioId: 'b1',
  negocio: 'Peluquería Luna',
  cliente: 'Ana',
  mascota: 'Toby',
  especie: 'Perro',
  servicio: 'Baño y corte',
  inicio: inicio,
  fin: inicio.add(const Duration(minutes: 90)),
  estado: estado,
);

Future<void> _abrir(
  WidgetTester tester, {
  required AgendaFalsa agenda,
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
      agenda: agenda,
      ahora: _ahora,
      eventos: eventos,
      negocios: negocios,
      veterinarias: veterinarias,
      mascotas: MascotasFalsas([
        const Mascota(id: 'm1', nombre: 'Toby', especieId: 1),
      ]),
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.agenda,
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

void main() {
  testWidgets('reservar: servicio, día (sin los bloqueados), hora y mascota', (
    tester,
  ) async {
    final agenda = AgendaFalsa(
      condicionesFijas: _condiciones,
      libres: [
        HorarioLibre(
          inicio: DateTime(2026, 10, 28, 9),
          fin: DateTime(2026, 10, 28, 10, 30),
        ),
      ],
    );
    final eventos = <Map<String, Object?>>[];
    await _abrir(tester, agenda: agenda, eventos: eventos);
    await _ir(tester, '/turnos/reservar/b1');

    await _tocar(tester, find.text('Baño y corte · 90 min'));
    // El 27 está bloqueado: no se ofrece.
    expect(find.text('27 oct'), findsNothing);
    await _tocar(tester, find.text('28 oct'));
    expect(agenda.consultas.last, (DateTime(2026, 10, 28), 's1'));
    await _tocar(tester, find.text('9:00'));
    await _tocar(tester, find.text('Toby'));
    await tester.enterText(find.byType(TextField), 'Es miedoso');
    await _tocar(tester, find.text('Pedir el turno'));

    expect(agenda.reservas.single, {
      'negocio': 'b1',
      'mascota': 'm1',
      'inicio': DateTime(2026, 10, 28, 9),
      'servicio': 's1',
      'nota': 'Es miedoso',
    });
    expect(
      eventos.where((e) => e['name'] == 'booking_create').single['props'],
      {'con_servicio': true},
    );
    expect(find.text('Mis turnos'), findsOneWidget);
  });

  testWidgets('si el horario se ocupó, lo dice y hay que elegir otro', (
    tester,
  ) async {
    final agenda = AgendaFalsa(
      condicionesFijas: _condiciones,
      libres: [
        HorarioLibre(
          inicio: DateTime(2026, 10, 28, 9),
          fin: DateTime(2026, 10, 28, 9, 30),
        ),
      ],
    )..fallarAlReservar = const AgendaException(ErrorAgenda.ocupado);
    await _abrir(tester, agenda: agenda);
    await _ir(tester, '/turnos/reservar/b1');
    await _tocar(tester, find.text('Consulta general'));
    await _tocar(tester, find.text('28 oct'));
    await _tocar(tester, find.text('9:00'));
    await _tocar(tester, find.text('Toby'));
    await _tocar(tester, find.text('Pedir el turno'));
    expect(
      find.text('Ese horario se acaba de ocupar. Elegí otro.'),
      findsOneWidget,
    );
    expect(find.text('Pedir el turno'), findsNothing);
  });

  testWidgets('mis turnos: se cancela con 2 horas o más, no después', (
    tester,
  ) async {
    final agenda = AgendaFalsa(
      mios: [
        _turno('lejos', inicio: DateTime(2026, 10, 28, 9)),
        _turno('cerca', inicio: DateTime(2026, 10, 26, 11)),
      ],
    );
    await _abrir(tester, agenda: agenda);
    await _ir(tester, '/turnos');
    expect(find.textContaining('Confirmado'), findsNWidgets(2));

    await _tocar(tester, find.text('Cancelar').last);
    expect(find.textContaining('Falta menos de 2 horas'), findsOneWidget);
    expect(agenda.cambios, isEmpty);

    await _tocar(tester, find.text('Cancelar').first);
    await _tocar(
      tester,
      find.widgetWithText(FilledButton, 'Cancelar el turno'),
    );
    expect(agenda.cambios.single, ('lejos', EstadoTurno.cancelado));
  });

  testWidgets('el comercio confirma un turno pendiente y ve la lista en vivo', (
    tester,
  ) async {
    final agenda = AgendaFalsa(
      delNegocio: [
        _turno(
          'p1',
          inicio: DateTime(2026, 10, 28, 9),
          estado: EstadoTurno.pendiente,
        ),
      ],
    )..ajustes = const AjustesAgenda(configurada: true);
    final negocios = NegociosFalsos([
      MiNegocio.fromJson({
        'id': 'b1',
        'name': 'Peluquería Luna',
        'business_type': 'grooming',
        'kind': 'local',
        'lat': -34.71,
        'lng': -55.95,
        'verification': 'verified',
        'plan': 'plus',
        'status': 'active',
      }),
    ]);
    await _abrir(
      tester,
      agenda: agenda,
      negocios: negocios,
      veterinarias: VeterinariasFalsas(prendidos: {Modulo.agenda}),
    );
    await _ir(tester, '/negocio?seccion=agenda');

    expect(find.text('Tomar turnos desde la app'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Confirmar'), 300);
    expect(find.textContaining('Ana · Toby, Perro'), findsOneWidget);
    await _tocar(tester, find.text('Confirmar'));
    expect(agenda.cambios.single, ('p1', EstadoTurno.confirmado));

    // Llega otro por Realtime: la lista se vuelve a pedir sola.
    agenda.delNegocio.add(
      _turno(
        'p2',
        inicio: DateTime(2026, 10, 29, 10),
        estado: EstadoTurno.pendiente,
      ),
    );
    agenda.avisarCambio();
    await tester.pumpAndSettle();
    expect(find.text('Confirmar'), findsNWidgets(2));
  });
}
