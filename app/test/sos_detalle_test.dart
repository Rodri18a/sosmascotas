import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'helpers.dart';
import 'noticias_falsas.dart';
import 'sos_falso.dart';

const _beto = Usuario(id: 'u2', email: 'beto@correo.com');

SosDetalle _detalle({bool mio = false, String? whatsapp}) => SosDetalle(
  id: 's1',
  tipo: TipoSos.perdida,
  estado: EstadoSos.activo,
  especie: 'Perro',
  especieIcono: '🐶',
  nombre: 'Firulais',
  raza: 'Labrador',
  color: 'Negro',
  senas: 'Collar rojo',
  tieneMicrochip: true,
  cuando: DateTime(2026, 10, 13),
  zona: const Punto(-34.72, -55.95),
  fotos: const ['sos-photos/u1/a.jpg'],
  esMio: mio,
  whatsapp: whatsapp,
);

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

/// Abre el detalle del SOS s1 desde la lista de la pestaña SOS.
Future<void> _abrirDetalle(WidgetTester tester) async {
  await tester.pumpAndSettle();
  await tester.tap(
    find.descendant(of: find.byType(BarraInferior), matching: find.text('SOS')),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Se perdió: Firulais'));
  await tester.pumpAndSettle();
}

Future<void> _ver(WidgetTester tester, Finder objetivo) async {
  await tester.scrollUntilVisible(
    objetivo,
    150,
    scrollable: find.byType(Scrollable).first,
  );
  await tester.pumpAndSettle();
}

final _enLista = SosResumen(
  id: 's1',
  tipo: TipoSos.perdida,
  especie: 'Perro',
  especieIcono: '🐶',
  nombre: 'Firulais',
  cuando: DateTime(2026, 10, 13),
  distanciaMetros: 300,
);

void main() {
  testWidgets('el detalle muestra los datos y el consejo para quien la vea', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        sos: SosFalso(listaCercanos: [_enLista], detalles: {'s1': _detalle()}),
      ),
    );
    await _abrirDetalle(tester);

    expect(find.text('🐶 Perro · Labrador · Negro'), findsOneWidget);
    expect(find.text('Collar rojo'), findsOneWidget);
    expect(find.textContaining('Recompensa'), findsNothing, reason: 'D119');
    expect(find.textContaining('llevala a una veterinaria'), findsOneWidget);
  });

  testWidgets('un visitante que quiere avisar ve por qué hace falta cuenta', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        sos: SosFalso(listaCercanos: [_enLista], detalles: {'s1': _detalle()}),
      ),
    );
    await _abrirDetalle(tester);

    await _ver(tester, find.text('Avisar al dueño'));
    await tester.tap(find.text('Avisar al dueño'));
    await tester.pumpAndSettle();

    expect(find.text('Necesitás una cuenta'), findsOneWidget);
    expect(find.textContaining('sin cuenta'), findsOneWidget);
  });

  testWidgets('con cuenta, avisa al dueño dejando su contacto', (tester) async {
    _pantallaDeCelular(tester);
    final sos = SosFalso(
      listaCercanos: [_enLista],
      detalles: {'s1': _detalle()},
    );
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _beto),
        sos: sos,
      ),
    );
    await _abrirDetalle(tester);
    await _ver(tester, find.text('Avisar al dueño'));
    await tester.tap(find.text('Avisar al dueño'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Mensaje (dónde y cuándo la viste)'),
      'La vi en la plaza hace 10 minutos',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tu nombre'),
      'Beto',
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Tu teléfono o WhatsApp'),
      '098 765 432',
    );
    await tester.tap(find.text('Enviar aviso'));
    await tester.pumpAndSettle();
    expect(find.textContaining('tenés que aceptar'), findsOneWidget);
    expect(sos.avisosEnviados, isEmpty);

    await tester.tap(find.byType(Checkbox));
    await tester.tap(find.text('Enviar aviso'));
    await tester.pumpAndSettle();

    expect(sos.avisosEnviados.single.contacto, '098 765 432');
    expect(find.text('¡Gracias! Tu aviso le llegó.'), findsOneWidget);
  });

  testWidgets('el WhatsApp directo (si el dueño lo activó) avisa del riesgo', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        sos: SosFalso(
          listaCercanos: [_enLista],
          detalles: {'s1': _detalle(whatsapp: '099 111 222')},
        ),
      ),
    );
    await _abrirDetalle(tester);
    await _ver(tester, find.widgetWithText(OutlinedButton, 'WhatsApp'));
    await tester.tap(find.widgetWithText(OutlinedButton, 'WhatsApp'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Nunca pidas ni mandes plata'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
  });

  testWidgets(
    'el autor no ve "Avisar al dueño" y recibe el consejo del RENAC',
    (tester) async {
      _pantallaDeCelular(tester);
      final eventos = <Map<String, Object?>>[];
      await tester.pumpWidget(
        appDePrueba(
          cuenta: ServicioCuentaFalso(conectado: _beto),
          eventos: eventos,
          sos: SosFalso(
            listaCercanos: [_enLista],
            detalles: {'s1': _detalle(mio: true)},
          ),
        ),
      );
      await _abrirDetalle(tester);

      expect(find.textContaining('RENAC'), findsOneWidget);
      await _ver(tester, find.text('Compartir'));
      expect(find.text('Avisar al dueño'), findsNothing);

      String? copiado;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (llamada) async {
          if (llamada.method == 'Clipboard.setData') {
            final datos = llamada.arguments as Map<Object?, Object?>;
            copiado = datos['text'] as String?;
          }
          return null;
        },
      );
      await tester.tap(find.text('Compartir'));
      await tester.pumpAndSettle();
      // (El aviso "Enlace copiado" depende de la respuesta del portapapeles,
      // que en las pruebas no llega dentro del ciclo de pumpAndSettle.)
      expect(copiado, 'https://huellamy.com/s/s1');
      // Compartir cuenta para «Difusor» en Tus huellas (D138).
      expect(
        eventos.where((e) => e['name'] == 'sos_share').single['target_id'],
        's1',
      );
    },
  );

  testWidgets('el autor marca "¡Apareció!" y el reporte queda resuelto', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final sos = SosFalso(
      listaCercanos: [_enLista],
      detalles: {'s1': _detalle(mio: true)},
    );
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _beto),
        sos: sos,
      ),
    );
    await _abrirDetalle(tester);

    await _ver(tester, find.widgetWithText(FilledButton, '¡Apareció!'));
    await tester.tap(find.widgetWithText(FilledButton, '¡Apareció!'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('¡Apareció!'),
      ),
    );
    await tester.pumpAndSettle();

    expect(sos.cerrados, {'s1': true});
    // Se ofrece compartir en Comunidad, sin la funcionalidad gradual (D94).
    expect(find.text('¿Compartís la buena noticia?'), findsOneWidget);
    await tester.tap(find.text('Ahora no'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.textContaining('ya está resuelto'),
      -150,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.textContaining('ya está resuelto'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, '¡Apareció!'), findsNothing);
  });

  testWidgets('al resolver, comparte el reencuentro solo si el dueño quiere', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final sos = SosFalso(
      listaCercanos: [_enLista],
      detalles: {'s1': _detalle(mio: true)},
    );
    final noticias = NoticiasFalsas()..reaccionesDeMiReencuentroTotal = 4;
    final metricas = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _beto),
        sos: sos,
        noticias: noticias,
        eventos: metricas,
      ),
    );
    await _abrirDetalle(tester);

    await _ver(tester, find.widgetWithText(FilledButton, '¡Apareció!'));
    await tester.tap(find.widgetWithText(FilledButton, '¡Apareció!'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.text('¡Apareció!'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('¿Compartís la buena noticia?'), findsOneWidget);
    expect(noticias.compartidos, isEmpty, reason: 'sin respuesta, no');
    await tester.tap(find.text('Compartir').last);
    await tester.pumpAndSettle();
    expect(noticias.compartidos, {'s1'});

    // Se puede quitar después desde el mismo reporte.
    final interruptor = find.widgetWithText(
      SwitchListTile,
      'Compartido en Comunidad',
    );
    await _ver(tester, interruptor);
    expect(tester.widget<SwitchListTile>(interruptor).value, isTrue);
    // Ve cuántos reaccionaron (D87), nunca quiénes.
    expect(
      find.textContaining('A 4 personas les alegró la noticia'),
      findsOneWidget,
    );
    await tester.tap(interruptor);
    await tester.pumpAndSettle();
    expect(noticias.compartidos, isEmpty);
    expect(tester.widget<SwitchListTile>(interruptor).value, isFalse);
    expect(metricas.map((e) => e['name']), contains('community_unshare'));
  });

  testWidgets('un visitante que quiere reportar ve por qué hace falta cuenta', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        sos: SosFalso(listaCercanos: [_enLista], detalles: {'s1': _detalle()}),
      ),
    );
    await _abrirDetalle(tester);

    await _ver(tester, find.text('Reportar publicación'));
    await tester.tap(find.text('Reportar publicación'));
    await tester.pumpAndSettle();

    expect(find.text('Necesitás una cuenta'), findsOneWidget);
    expect(find.textContaining('evitamos reportes falsos'), findsOneWidget);
  });

  testWidgets('con cuenta, reporta la publicación una sola vez', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final eventos = <Map<String, Object?>>[];
    final sos = SosFalso(
      listaCercanos: [_enLista],
      detalles: {'s1': _detalle()},
    );
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _beto),
        sos: sos,
        eventos: eventos,
      ),
    );
    await _abrirDetalle(tester);

    Future<void> reportar() async {
      await _ver(tester, find.text('Reportar publicación'));
      await tester.tap(find.text('Reportar publicación'));
      await tester.pumpAndSettle();
    }

    await reportar();
    await tester.tap(find.text('Enviar reporte'));
    await tester.pumpAndSettle();
    expect(find.text('Elegí un motivo.'), findsOneWidget);
    expect(sos.reportados, isEmpty);

    await tester.tap(find.text('Parece una estafa'));
    await tester.enterText(find.byType(TextField).last, 'Pide plata');
    await tester.tap(find.text('Enviar reporte'));
    await tester.pumpAndSettle();

    expect(sos.reportados, {'s1': 'estafa: Pide plata'});
    expect(find.text('Gracias, lo vamos a revisar.'), findsOneWidget);
    expect(
      eventos.where((e) => e['name'] == 'content_flag').single['target_id'],
      's1',
    );

    // Segundo intento: no se duplica.
    ScaffoldMessenger.of(
      tester.element(find.byType(ListView)),
    ).removeCurrentSnackBar();
    await reportar();
    await tester.tap(find.text('Spam o publicidad'));
    await tester.tap(find.text('Enviar reporte'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ya habías reportado'), findsOneWidget);
    expect(eventos.where((e) => e['name'] == 'content_flag'), hasLength(1));
  });

  testWidgets('el autor no ve "Reportar publicación"', (tester) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _beto),
        sos: SosFalso(
          listaCercanos: [_enLista],
          detalles: {'s1': _detalle(mio: true)},
        ),
      ),
    );
    await _abrirDetalle(tester);
    await _ver(tester, find.text('Compartir'));
    expect(find.text('Reportar publicación'), findsNothing);
  });

  testWidgets('la pestaña SOS muestra "Mis reportes"', (tester) async {
    final sos = SosFalso()
      ..mios = [
        MiSos(
          id: 's1',
          tipo: TipoSos.perdida,
          estado: EstadoSos.activo,
          creado: DateTime(2026, 10, 14),
          ubicacion: centroPando,
          nombre: 'Firulais',
        ),
      ];
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _beto),
        sos: sos,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(BarraInferior),
        matching: find.text('SOS'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mis reportes'), findsOneWidget);
    expect(find.text('1 reporte · 1 activo'), findsOneWidget);
    // Arranca cerrado (D150): el estado se ve al abrirlo.
    expect(find.text('Activo'), findsNothing);
    await tester.tap(find.text('Mis reportes'));
    await tester.pumpAndSettle();
    expect(find.text('Activo'), findsOneWidget);
  });
}
