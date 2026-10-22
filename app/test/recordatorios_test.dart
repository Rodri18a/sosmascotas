import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota/src/recordatorios/avisador.dart';
import 'package:sosmascota/src/redireccion.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'libreta_falsa.dart';
import 'mascotas_falsas.dart';
import 'recordatorios_falsos.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');
const _luna = Mascota(id: 'm1', nombre: 'Luna', especieId: 2);

/// Sábado 17/10/2026, 10:20.
final _ahora = DateTime(2026, 10, 17, 10, 20);

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

Widget _app({
  required RecordatoriosFalsos recordatorios,
  AvisadorFalso? avisador,
  bool prendida = true,
  List<Map<String, Object?>>? eventos,
  LibretaFalsa? libreta,
}) => appDePrueba(
  cuenta: ServicioCuentaFalso(conectado: _ana),
  mascotas: MascotasFalsas([_luna]),
  recordatorios: recordatorios,
  avisador: avisador,
  libreta: libreta,
  funcionalidades: FuncionalidadesFalsas({
    if (prendida) Funcionalidades.recordatorios,
    if (libreta != null) Funcionalidades.libreta,
  }),
  eventos: eventos,
  ahora: _ahora,
);

Future<void> _abrirFicha(WidgetTester tester, Widget app) async {
  _pantallaDeCelular(tester);
  await tester.pumpWidget(app);
  await tester.pumpAndSettle();
  await _tocar(
    tester,
    find.descendant(
      of: find.byType(BarraInferior),
      matching: find.text('Mascotas'),
    ),
  );
  await _tocar(tester, find.widgetWithText(ListTile, 'Luna'));
  await tester.drag(find.byType(Scrollable).last, const Offset(0, -3000));
  await tester.pumpAndSettle();
}

Recordatorio _antibiotico({bool activo = true}) => Recordatorio(
  id: 'r1',
  mascotaId: 'm1',
  tipo: TipoRecordatorio.medication,
  titulo: 'Antibiótico',
  dosis: '1/2 comprimido',
  frecuencia: const CadaHoras(12),
  inicio: DateTime(2026, 10, 16, 8),
  fin: DateTime(2026, 10, 22),
  activo: activo,
);

void main() {
  testWidgets('apagada: la ficha no muestra recordatorios', (tester) async {
    await _abrirFicha(
      tester,
      _app(recordatorios: RecordatoriosFalsos(), prendida: false),
    );
    expect(find.text('Recordatorios'), findsNothing);
  });

  testWidgets('remedio cada 8 horas: arranca en la próxima hora en punto', (
    tester,
  ) async {
    final recordatorios = RecordatoriosFalsos();
    final eventos = <Map<String, Object?>>[];
    await _abrirFicha(
      tester,
      _app(recordatorios: recordatorios, eventos: eventos),
    );
    expect(find.textContaining('Programá remedios'), findsOneWidget);

    await _tocar(tester, find.text('Agregar recordatorio'));
    expect(find.widgetWithText(AppBar, 'Nuevo recordatorio'), findsOneWidget);
    expect(find.text('hoy a las 11:00'), findsOneWidget);
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));
    expect(find.text('Escribí de qué es el recordatorio.'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Remedio'),
      'Antibiótico',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Dosis (opcional)'),
      '1/2 comprimido',
    );
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));

    final r = recordatorios.recordatorios.single;
    expect(r.frecuencia, isA<CadaHoras>().having((f) => f.horas, 'horas', 8));
    expect(r.inicio, DateTime(2026, 10, 17, 11));
    expect(r.dosis, '1/2 comprimido');
    expect(
      find.text('1/2 comprimido · Próxima: hoy a las 11:00'),
      findsOneWidget,
    );
    expect(
      eventos.where((e) => e['name'] == 'reminder_create').single['props'],
      {'tipo': 'medication'},
    );
  });

  testWidgets('todos los días: hace falta al menos un horario', (tester) async {
    final recordatorios = RecordatoriosFalsos();
    await _abrirFicha(tester, _app(recordatorios: recordatorios));
    await _tocar(tester, find.text('Agregar recordatorio'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Remedio'),
      'Gotas',
    );
    await _tocar(tester, find.text('Todos los días'));
    expect(find.text('8:00'), findsOneWidget);
    expect(find.text('20:00'), findsOneWidget);

    await _tocar(tester, find.byTooltip('Quitar 8:00'));
    await _tocar(tester, find.byTooltip('Quitar 20:00'));
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));
    expect(find.text('Agregá al menos un horario.'), findsOneWidget);
    expect(recordatorios.recordatorios, isEmpty);
  });

  testWidgets('algunos días: arranca con el día de hoy', (tester) async {
    final recordatorios = RecordatoriosFalsos();
    await _abrirFicha(tester, _app(recordatorios: recordatorios));
    await _tocar(tester, find.text('Agregar recordatorio'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Remedio'),
      'Pipeta',
    );
    await _tocar(tester, find.text('Algunos días'));
    await _tocar(tester, find.byTooltip('Quitar 8:00'));
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));

    final f = recordatorios.recordatorios.single.frecuencia as Semanal;
    expect(f.dias, {DateTime.saturday});
    expect(f.horarios, [const HoraDelDia(20, 0)]);
    expect(find.textContaining('Próxima: hoy a las 20:00'), findsOneWidget);
  });

  testWidgets('comida: todos los días o algunos días, con porción', (
    tester,
  ) async {
    final recordatorios = RecordatoriosFalsos();
    await _abrirFicha(tester, _app(recordatorios: recordatorios));
    await _tocar(tester, find.text('Agregar recordatorio'));
    await _tocar(tester, find.widgetWithText(ChoiceChip, 'Comida'));

    expect(find.text('Cada X horas'), findsNothing);
    expect(find.text('8:00'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Comida'),
      'Balanceado',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Porción (opcional)'),
      '1 taza',
    );
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));

    final r = recordatorios.recordatorios.single;
    expect(r.tipo, TipoRecordatorio.food);
    expect(r.dosis, '1 taza');
    expect((r.frecuencia as Diaria).horarios, const [
      HoraDelDia(8, 0),
      HoraDelDia(20, 0),
    ]);
    expect(find.text('1 taza · Próxima: hoy a las 20:00'), findsOneWidget);
  });

  testWidgets('vacuna: una sola vez, sin dosis ni frecuencia', (tester) async {
    final recordatorios = RecordatoriosFalsos();
    await _abrirFicha(tester, _app(recordatorios: recordatorios));
    await _tocar(tester, find.text('Agregar recordatorio'));
    await _tocar(tester, find.widgetWithText(ChoiceChip, 'Vacuna'));

    expect(find.text('Dosis (opcional)'), findsNothing);
    expect(find.text('Todos los días'), findsNothing);
    expect(find.text('Hasta'), findsNothing);
    expect(find.text('Cuándo'), findsOneWidget);
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Vacuna'),
      'Séxtuple',
    );
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));

    final r = recordatorios.recordatorios.single;
    expect(r.tipo, TipoRecordatorio.vaccine);
    expect(r.frecuencia, isA<UnaVez>());
    expect(r.dosis, isNull);
    expect(r.inicio, DateTime(2026, 10, 17, 11));
  });

  testWidgets('"Recordarme" desde la libreta: la vacuna ese día a las 9', (
    tester,
  ) async {
    final recordatorios = RecordatoriosFalsos();
    await _abrirFicha(
      tester,
      _app(
        recordatorios: recordatorios,
        libreta: LibretaFalsa([
          RegistroSalud(
            id: 'v1',
            mascotaId: 'm1',
            tipo: TipoRegistroSalud.vaccine,
            nombre: 'Antirrábica',
            fecha: DateTime(2025, 11, 1),
            proxima: DateTime(2026, 11, 1),
          ),
        ]),
      ),
    );
    await _tocar(tester, find.byTooltip('Recordarme Antirrábica'));

    expect(find.widgetWithText(AppBar, 'Nuevo recordatorio'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Vacuna'))
          .selected,
      isTrue,
    );
    expect(find.widgetWithText(TextFormField, 'Antirrábica'), findsOneWidget);
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));

    final r = recordatorios.recordatorios.single;
    expect(r.titulo, 'Antirrábica');
    expect(r.frecuencia, isA<UnaVez>());
    expect(r.inicio, DateTime(2026, 11, 1, 9));
  });

  testWidgets('"Ya se la di": marca la toma, se puede deshacer y queda en el '
      'historial', (tester) async {
    final recordatorios = RecordatoriosFalsos([_antibiotico()]);
    final eventos = <Map<String, Object?>>[];
    await _abrirFicha(
      tester,
      _app(recordatorios: recordatorios, eventos: eventos),
    );

    // La de las 8 no se marcó: se ofrece hasta 12 h después.
    await _tocar(tester, find.text('✅ Ya se la di (8:00)'));
    expect(recordatorios.tomas.single.prevista, DateTime(2026, 10, 17, 8));
    expect(find.text('Listo, quedó anotado.'), findsOneWidget);
    expect(find.textContaining('Ya se la di'), findsNothing);
    expect(eventos.where((e) => e['name'] == 'reminder_done').single['props'], {
      'tipo': 'medication',
    });

    await _tocar(tester, find.text('Deshacer'));
    expect(recordatorios.tomas, isEmpty);
    expect(find.text('✅ Ya se la di (8:00)'), findsOneWidget);

    await _tocar(tester, find.text('✅ Ya se la di (8:00)'));
    await _tocar(tester, find.text('Antibiótico'));
    await tester.drag(find.byType(Scrollable).last, const Offset(0, -3000));
    await tester.pumpAndSettle();
    expect(find.text('Historial'), findsOneWidget);
    expect(find.text('hoy a las 8:00'), findsOneWidget);
    expect(find.text('Marcada hoy a las 10:20'), findsOneWidget);
  });

  testWidgets('comida: "Ya comió"', (tester) async {
    final recordatorios = RecordatoriosFalsos([
      Recordatorio(
        id: 'c1',
        mascotaId: 'm1',
        tipo: TipoRecordatorio.food,
        titulo: 'Balanceado',
        frecuencia: const Diaria([HoraDelDia(10, 0)]),
        inicio: DateTime(2026, 10, 1),
      ),
    ]);
    await _abrirFicha(tester, _app(recordatorios: recordatorios));
    expect(find.text('✅ Ya comió (10:00)'), findsOneWidget);
  });

  testWidgets('pausar y borrar', (tester) async {
    final recordatorios = RecordatoriosFalsos([_antibiotico()]);
    await _abrirFicha(tester, _app(recordatorios: recordatorios));
    expect(
      find.text('1/2 comprimido · Próxima: hoy a las 20:00'),
      findsOneWidget,
    );

    await _tocar(tester, find.text('Antibiótico'));
    expect(find.widgetWithText(AppBar, 'Editar recordatorio'), findsOneWidget);
    await _tocar(tester, find.text('Avisarme'));
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));
    expect(recordatorios.recordatorios.single.activo, isFalse);
    expect(find.text('1/2 comprimido · Pausado'), findsOneWidget);

    await _tocar(tester, find.text('Antibiótico'));
    await _tocar(tester, find.text('Borrar recordatorio'));
    await _tocar(tester, find.widgetWithText(FilledButton, 'Borrar'));
    expect(recordatorios.recordatorios, isEmpty);
    expect(find.textContaining('Programá remedios'), findsOneWidget);
  });

  testWidgets('un tratamiento que ya terminó lo dice', (tester) async {
    final terminado = Recordatorio(
      id: 'r1',
      mascotaId: 'm1',
      tipo: TipoRecordatorio.medication,
      titulo: 'Antiinflamatorio',
      frecuencia: const CadaHoras(24),
      inicio: DateTime(2026, 10, 10, 9),
      fin: DateTime(2026, 10, 14),
    );
    await _abrirFicha(
      tester,
      _app(recordatorios: RecordatoriosFalsos([terminado])),
    );
    expect(find.text('Terminado'), findsOneWidget);
  });

  testWidgets('pide el permiso de avisos del navegador', (tester) async {
    final avisador = AvisadorFalso(estado: PermisoAvisos.sinPedir);
    await _abrirFicha(
      tester,
      _app(
        recordatorios: RecordatoriosFalsos([_antibiotico()]),
        avisador: avisador,
      ),
    );
    await _tocar(tester, find.text('Activar avisos'));
    expect(avisador.pedidos, 1);
    expect(find.text('Activar avisos'), findsNothing);
    expect(find.textContaining('mientras la app esté abierta'), findsOneWidget);
  });

  group('avisos programados', () {
    testWidgets('las tomas de las próximas 24 h, con el nombre de la mascota', (
      tester,
    ) async {
      final avisador = AvisadorFalso();
      await tester.pumpWidget(
        _app(
          recordatorios: RecordatoriosFalsos([
            _antibiotico(),
            _antibiotico(activo: false),
          ]),
          avisador: avisador,
        ),
      );
      await tester.pumpAndSettle();

      expect(avisador.programados.map((a) => a.cuando), [
        DateTime(2026, 10, 17, 20),
        DateTime(2026, 10, 18, 8),
      ]);
      final primero = avisador.programados.first;
      expect(primero.titulo, 'Antibiótico para Luna');
      expect(primero.cuerpo, '1/2 comprimido');
      expect(primero.ruta, '/mascotas/m1');
    });

    testWidgets('una toma marcada antes de la hora ya no avisa', (
      tester,
    ) async {
      final avisador = AvisadorFalso();
      final recordatorios = RecordatoriosFalsos([_antibiotico()]);
      await recordatorios.marcar('r1', DateTime(2026, 10, 17, 20));
      await tester.pumpWidget(
        _app(recordatorios: recordatorios, avisador: avisador),
      );
      await tester.pumpAndSettle();
      expect(avisador.programados.map((a) => a.cuando), [
        DateTime(2026, 10, 18, 8),
      ]);
    });

    testWidgets('sin la funcionalidad no se programa nada', (tester) async {
      final avisador = AvisadorFalso()
        ..programados = [
          AvisoProgramado(
            id: 'viejo',
            cuando: DateTime(2026, 10, 17, 12),
            titulo: 'x',
            cuerpo: 'x',
            ruta: '/',
          ),
        ];
      await tester.pumpWidget(
        _app(
          recordatorios: RecordatoriosFalsos([_antibiotico()]),
          avisador: avisador,
          prendida: false,
        ),
      );
      await tester.pumpAndSettle();
      expect(avisador.programados, isEmpty);
      expect(
        ProviderScope.containerOf(
          tester.element(find.byType(MaterialApp)),
        ).exists(programadorRecordatoriosProvider),
        isTrue,
      );
    });
  });

  test(
    'las pantallas de recordatorios necesitan cuenta y la funcionalidad',
    () {
      expect(
        redirigir(
          conectado: false,
          uri: Uri.parse('/recordatorios/m1/nuevo'),
          funcionalidadActiva: (_) => true,
        ),
        '/ingresar?volver=%2Frecordatorios%2Fm1%2Fnuevo',
      );
      expect(
        redirigir(
          conectado: true,
          uri: Uri.parse('/recordatorios/m1/nuevo'),
          funcionalidadActiva: (_) => false,
        ),
        '/no-disponible?volver=%2Frecordatorios%2Fm1%2Fnuevo',
      );
    },
  );
}
