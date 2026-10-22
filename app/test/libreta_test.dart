import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota/src/redireccion.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'libreta_falsa.dart';
import 'mascotas_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');
const _luna = Mascota(id: 'm1', nombre: 'Luna', especieId: 2);

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

/// Abre la ficha de Luna con la libreta [prendida] o no.
Future<void> _abrirFicha(
  WidgetTester tester, {
  required LibretaFalsa libreta,
  bool prendida = true,
  List<Map<String, Object?>>? eventos,
  DateTime? ahora,
}) async {
  _pantallaDeCelular(tester);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      mascotas: MascotasFalsas([_luna]),
      libreta: libreta,
      funcionalidades: FuncionalidadesFalsas({
        if (prendida) Funcionalidades.libreta,
      }),
      eventos: eventos,
      ahora: ahora ?? DateTime(2026, 9, 20, 10),
    ),
  );
  await tester.pumpAndSettle();
  await _tocar(
    tester,
    find.descendant(
      of: find.byType(BarraInferior),
      matching: find.text('Mascotas'),
    ),
  );
  await _tocar(tester, find.widgetWithText(ListTile, 'Luna'));
  expect(find.widgetWithText(AppBar, 'Luna'), findsOneWidget);
  await _bajarALaLibreta(tester);
}

/// La libreta está al final de la ficha (la lista la construye al bajar).
Future<void> _bajarALaLibreta(WidgetTester tester) async {
  await tester.scrollUntilVisible(
    find.text('Chapita QR'),
    300,
    scrollable: find.byType(Scrollable).last,
  );
  await tester.drag(find.byType(Scrollable).last, const Offset(0, -2000));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('apagada: la ficha no muestra la libreta', (tester) async {
    await _abrirFicha(tester, libreta: LibretaFalsa(), prendida: false);
    expect(find.text('Libreta sanitaria'), findsNothing);
    expect(find.text('Chapita QR'), findsOneWidget);
  });

  testWidgets('cargar una vacuna: queda con la fecha de hoy y se ve en la '
      'ficha', (tester) async {
    final libreta = LibretaFalsa();
    final eventos = <Map<String, Object?>>[];
    await _abrirFicha(tester, libreta: libreta, eventos: eventos);
    expect(find.text('Libreta sanitaria'), findsOneWidget);
    expect(find.textContaining('Anotá vacunas'), findsOneWidget);

    await _tocar(tester, find.text('Agregar a la libreta'));
    expect(find.widgetWithText(AppBar, 'Nuevo registro'), findsOneWidget);
    // Sin nombre no se guarda.
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));
    expect(find.text('Escribí qué fue.'), findsOneWidget);
    expect(libreta.registros, isEmpty);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre'),
      'Antirrábica',
    );
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));

    final vacuna = libreta.registros.single;
    expect(vacuna.tipo, TipoRegistroSalud.vaccine);
    expect(vacuna.mascotaId, 'm1');
    expect(vacuna.fecha, DateUtils.dateOnly(DateTime.now()));
    // Sin próxima fecha no hay semáforo.
    expect(find.textContaining('Falta'), findsNothing);
    expect(find.widgetWithText(AppBar, 'Luna'), findsOneWidget);
    expect(find.text('Vacunas'), findsOneWidget);
    expect(find.text('Antirrábica'), findsOneWidget);
    expect(
      eventos.where((e) => e['name'] == 'health_record_create').single['props'],
      {'tipo': 'vaccine'},
    );
  });

  testWidgets('una alergia no pide fecha', (tester) async {
    final libreta = LibretaFalsa();
    await _abrirFicha(tester, libreta: libreta);
    await _tocar(tester, find.text('Agregar a la libreta'));
    await _tocar(tester, find.text('Alergia'));

    expect(find.text('Fecha'), findsNothing);
    expect(find.text('Próxima dosis o control'), findsNothing);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre'),
      'Pollo',
    );
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));

    final alergia = libreta.registros.single;
    expect(alergia.tipo, TipoRegistroSalud.allergy);
    expect(alergia.fecha, isNull);
    expect(find.text('Alergias'), findsOneWidget);
  });

  testWidgets('editar y borrar un registro', (tester) async {
    final libreta = LibretaFalsa([
      RegistroSalud(
        id: 'r1',
        mascotaId: 'm1',
        tipo: TipoRegistroSalud.deworming,
        nombre: 'Pipeta',
        fecha: DateTime(2026, 9, 10),
        proxima: DateTime(2026, 10, 10),
      ),
    ]);
    await _abrirFicha(tester, libreta: libreta);
    expect(find.text('Desparasitaciones'), findsOneWidget);
    expect(find.textContaining('Próxima:'), findsOneWidget);
    expect(find.text('Faltan 20 días'), findsOneWidget);

    await _tocar(tester, find.text('Pipeta'));
    expect(find.widgetWithText(AppBar, 'Editar registro'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Notas'),
      'Marca X',
    );
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));
    expect(libreta.registros.single.notas, 'Marca X');
    expect(libreta.registros.single.proxima, DateTime(2026, 10, 10));

    await _tocar(tester, find.text('Pipeta'));
    await _tocar(tester, find.text('Borrar registro'));
    expect(find.text('¿Borrar «Pipeta»?'), findsOneWidget);
    await _tocar(tester, find.widgetWithText(FilledButton, 'Borrar'));
    expect(libreta.registros, isEmpty);
    expect(find.widgetWithText(AppBar, 'Luna'), findsOneWidget);
    expect(find.textContaining('Anotá vacunas'), findsOneWidget);
  });

  testWidgets('sin internet avisa y no cierra el formulario', (tester) async {
    final libreta = LibretaFalsa();
    await _abrirFicha(tester, libreta: libreta);
    await _tocar(tester, find.text('Agregar a la libreta'));
    libreta.fallar = true;
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre'),
      'Control anual',
    );
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));

    expect(find.textContaining('No pudimos conectarnos'), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Nuevo registro'), findsOneWidget);
  });

  testWidgets('semáforo: lo vencido sale arriba y la dosis vieja ya no '
      'cuenta', (tester) async {
    RegistroSalud vacuna(String id, DateTime fecha, DateTime proxima) =>
        RegistroSalud(
          id: id,
          mascotaId: 'm1',
          tipo: TipoRegistroSalud.vaccine,
          nombre: id,
          fecha: fecha,
          proxima: proxima,
        );
    await _abrirFicha(
      tester,
      ahora: DateTime(2026, 10, 17, 9),
      libreta: LibretaFalsa([
        vacuna('Séxtuple', DateTime(2025, 10, 14), DateTime(2026, 10, 14)),
        vacuna('Triple', DateTime(2026, 4), DateTime(2026, 10, 22)),
        vacuna('Antirrábica', DateTime(2026, 9), DateTime(2027, 9)),
        RegistroSalud(
          id: 'vieja',
          mascotaId: 'm1',
          tipo: TipoRegistroSalud.vaccine,
          nombre: 'Antirrábica',
          fecha: DateTime(2025, 9),
          proxima: DateTime(2026, 9),
        ),
      ]),
    );

    // Arriba, lo más urgente: la Séxtuple vencida (en el aviso y en la lista).
    expect(find.text('Venció hace 3 días'), findsNWidgets(2));
    expect(find.text('Faltan 5 días'), findsOneWidget);
    expect(find.text('Faltan 319 días'), findsOneWidget);
    // La Antirrábica de 2025 tenía la próxima en 2026-09, pero ya se dio la
    // nueva: no aparece como vencida.
    expect(find.textContaining('Venció hace 4'), findsNothing);
  });

  group('rutas', () {
    test('sin la funcionalidad, el formulario lleva a "no disponible"', () {
      expect(
        redirigir(
          conectado: true,
          uri: Uri.parse('/libreta/m1/nuevo'),
          funcionalidadActiva: (_) => false,
        ),
        '/no-disponible?volver=%2Flibreta%2Fm1%2Fnuevo',
      );
      expect(
        redirigir(
          conectado: true,
          uri: Uri.parse('/libreta/m1/nuevo'),
          funcionalidadActiva: (clave) => clave == Funcionalidades.libreta,
        ),
        isNull,
      );
    });

    test('un visitante primero ingresa', () {
      expect(
        redirigir(
          conectado: false,
          uri: Uri.parse('/libreta/m1/r1'),
          funcionalidadActiva: (_) => true,
        ),
        '/ingresar?volver=%2Flibreta%2Fm1%2Fr1',
      );
    });
  });
}
