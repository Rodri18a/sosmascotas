import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/hogar/tareas.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'hogar_falso.dart';
import 'mascotas_falsas.dart';
import 'tareas_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');
const _luna = Mascota(id: 'm1', nombre: 'Luna', especieId: 2, duenoId: 'u1');
const _hogar = [
  Integrante(
    hogarId: 'h1',
    usuarioId: 'u1',
    nombre: 'Ana',
    rol: RolHogar.owner,
  ),
  Integrante(
    hogarId: 'h1',
    usuarioId: 'u2',
    nombre: 'Beto',
    rol: RolHogar.member,
  ),
];
final _hoy = DateTime(2026, 10, 17);

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

Future<void> _abrirFicha(
  WidgetTester tester, {
  required TareasFalsas tareas,
  List<Integrante> hogar = _hogar,
  List<Map<String, Object?>>? eventos,
  bool prendida = true,
}) async {
  _pantallaDeCelular(tester);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      mascotas: MascotasFalsas([_luna]),
      hogar: HogarFalso(List.of(hogar)),
      tareas: tareas,
      funcionalidades: FuncionalidadesFalsas({
        if (prendida) Funcionalidades.hogar,
      }),
      eventos: eventos,
      ahora: DateTime(2026, 10, 17, 10, 20),
    ),
  );
  await tester.pumpAndSettle();
  await _tocar(
    tester,
    find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text('Mis mascotas'),
    ),
  );
  await _tocar(tester, find.widgetWithText(ListTile, 'Luna'));
  await tester.drag(find.byType(Scrollable).last, const Offset(0, -3000));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('apagada: no hay tareas en la ficha', (tester) async {
    await _abrirFicha(tester, tareas: TareasFalsas(), prendida: false);
    expect(find.text('Tareas de hoy'), findsNothing);
  });

  testWidgets('crear una tarea para otra persona del hogar y marcarla', (
    tester,
  ) async {
    final tareas = TareasFalsas();
    final eventos = <Map<String, Object?>>[];
    await _abrirFicha(tester, tareas: tareas, eventos: eventos);
    expect(find.textContaining('Repartan el paseo'), findsOneWidget);

    await _tocar(tester, find.text('Agregar tarea'));
    await _tocar(tester, find.widgetWithText(ChoiceChip, 'Comida'));
    await _tocar(tester, find.text('Ana (vos)'));
    await _tocar(tester, find.text('Beto').last);
    await _tocar(tester, find.widgetWithText(FilledButton, 'Agregar'));

    final tarea = tareas.tareas.single;
    expect(tarea.tipo, TipoTarea.food);
    expect(tarea.asignadaA, 'u2');
    expect(tarea.dia, _hoy);
    expect(find.text('Le toca a Beto'), findsOneWidget);

    await _tocar(tester, find.byType(Checkbox));
    expect(tareas.tareas.single.hechaPor, 'u1');
    expect(find.text('La hiciste vos hoy a las 10:20'), findsOneWidget);
    expect(
      eventos.map((e) => e['name']),
      containsAll(['task_create', 'task_done']),
    );
  });

  testWidgets('se ve quién la hizo', (tester) async {
    await _abrirFicha(
      tester,
      tareas: TareasFalsas(
        iniciales: [
          Tarea(
            id: 't1',
            mascotaId: 'm1',
            tipo: TipoTarea.walk,
            dia: _hoy,
            nota: 'a la plaza',
            asignadaA: 'u2',
            hechaPor: 'u2',
            hechaEn: DateTime(2026, 10, 17, 9),
          ),
          Tarea(id: 't2', mascotaId: 'm1', tipo: TipoTarea.bath, dia: _hoy),
          Tarea(
            id: 't3',
            mascotaId: 'm1',
            tipo: TipoTarea.walk,
            dia: _hoy.add(const Duration(days: 1)),
          ),
        ],
      ),
    );
    expect(find.text('Paseo · a la plaza'), findsOneWidget);
    expect(find.text('Hecha por Beto hoy a las 9:00'), findsOneWidget);
    expect(find.text('Cualquiera la puede hacer'), findsOneWidget);
    // La de mañana no está en "hoy".
    expect(find.text('Paseo'), findsNothing);
  });

  testWidgets('sin hogar no se elige a quién le toca', (tester) async {
    await _abrirFicha(tester, tareas: TareasFalsas(), hogar: const []);
    await _tocar(tester, find.text('Agregar tarea'));
    expect(find.text('Le toca a'), findsNothing);
  });

  test('cuidadores: yo y el hogar del dueño de la mascota', () {
    expect(cuidadoresDe(_luna, _hogar, 'u1', 'Ana'), {
      'u1': 'Ana',
      'u2': 'Beto',
    });
    const deOtro = Mascota(id: 'm9', nombre: 'X', especieId: 1, duenoId: 'u9');
    expect(cuidadoresDe(deOtro, _hogar, 'u1', 'Ana'), {'u1': 'Ana'});
  });
}
