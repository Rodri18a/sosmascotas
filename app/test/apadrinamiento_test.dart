import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/l10n/generated/app_localizations.dart';
import 'package:sosmascota/src/adopcion/apadrinamiento_repositorio.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/adopcion/apadrinamiento_screen.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'apadrinamiento_falso.dart';
import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  // Las listas arman lo de abajo recién al bajar.
  if (objetivo.evaluate().isEmpty) {
    await tester.scrollUntilVisible(
      objetivo,
      300,
      scrollable: find
          .descendant(
            of: find.byType(ListView),
            matching: find.byType(Scrollable),
          )
          .first,
    );
  }
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

MiNegocio _negocio(String tipo) => MiNegocio.fromJson({
  'id': 'n1',
  'name': tipo == 'shelter' ? 'Refugio Pando' : 'Pet Shop Pando',
  'business_type': tipo,
  'kind': 'local',
  'lat': -34.71,
  'lng': -55.95,
  'hours': const <String, Object?>{},
  'verification': 'verified',
  'plan': 'basic',
  'status': 'active',
});

Future<void> _abrir(
  WidgetTester tester, {
  required ApadrinamientoFalso apadrinamiento,
  required MiNegocio negocio,
  required String tarjeta,
}) async {
  _pantallaDeCelular(tester);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      apadrinamiento: apadrinamiento,
      negocios: NegociosFalsos([negocio]),
      funcionalidades: FuncionalidadesFalsas({
        Funcionalidades.adopcion,
        Funcionalidades.comercios,
      }),
    ),
  );
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/negocio');
  await tester.pumpAndSettle();
  await _tocar(tester, find.text(tarjeta));
}

void main() {
  testWidgets('un comercio verificado ofrece apadrinar una feria', (
    tester,
  ) async {
    final apadrinamiento = ApadrinamientoFalso(
      refugios: [
        RefugioParaApadrinar(
          id: 'r1',
          nombre: 'Refugio Pando',
          direccion: 'Ruta 8',
          eventos: [
            EventoParaApadrinar(
              id: 'e1',
              titulo: 'Feria de adopción',
              desde: DateTime(2026, 11, 8),
            ),
          ],
        ),
      ],
    );
    await _abrir(
      tester,
      apadrinamiento: apadrinamiento,
      negocio: _negocio('petshop'),
      tarjeta: 'Apadrinar un refugio',
    );
    expect(find.text('Refugio Pando'), findsOneWidget);
    expect(find.textContaining('1 evento próximo'), findsOneWidget);

    await _tocar(tester, find.text('Ofrecer'));
    await _tocar(
      tester,
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Ofrecer'),
      ),
    );
    expect(find.text('Contá qué aportás.'), findsOneWidget);

    await _tocar(tester, find.byType(DropdownButtonFormField<String?>));
    await _tocar(tester, find.text('Feria de adopción').last);
    await tester.enterText(
      find.widgetWithText(TextField, 'Qué aportás'),
      'Bolsas de alimento',
    );
    await _tocar(
      tester,
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Ofrecer'),
      ),
    );
    expect(apadrinamiento.ofrecidos.single, ('r1', 'Bolsas de alimento', 'e1'));
    expect(find.text('Esperando que el refugio responda'), findsOneWidget);

    await _tocar(tester, find.text('Retirar'));
    expect(apadrinamiento.terminados.single, 'o0');
  });

  testWidgets('el refugio acepta un ofrecimiento', (tester) async {
    final apadrinamiento = ApadrinamientoFalso(
      esRefugio: true,
      puedeOfrecer: false,
      recibidos: const [
        Apadrinamiento(
          id: 'a1',
          estado: EstadoApadrinamiento.pendiente,
          aporte: 'Alimento para 20 perros por mes',
          otro: 'Pet Shop Pando',
        ),
      ],
    );
    await _abrir(
      tester,
      apadrinamiento: apadrinamiento,
      negocio: _negocio('shelter'),
      tarjeta: 'Padrinos del refugio',
    );
    expect(find.text('Pet Shop Pando'), findsOneWidget);
    await _tocar(tester, find.text('Aceptar'));
    expect(apadrinamiento.respuestas.single, ('a1', true));
    expect(find.text('Activo: se ve en la ficha'), findsOneWidget);
  });

  testWidgets('la ficha del refugio dice quién lo apadrina', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          apadrinamientoRepositorioProvider.overrideWithValue(
            ApadrinamientoFalso(
              padrinosDe: {
                ('r1', null): const [
                  Padrino(nombre: 'Pet Shop Pando', aporte: 'Alimento'),
                ],
              },
            ),
          ),
        ],
        child: const MaterialApp(
          locale: Locale('es', 'UY'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Scaffold(
            body: Column(
              children: [
                LineaPadrinos(negocioId: 'r1'),
                // Sin padrinos no se muestra nada.
                LineaPadrinos(negocioId: 'r2'),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.text('Apadrinado por Pet Shop Pando (Alimento)'),
      findsOneWidget,
    );
    expect(find.textContaining('Apadrinado por'), findsOneWidget);
  });
}
