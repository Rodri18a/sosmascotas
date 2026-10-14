import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'avisos_falsos.dart';
import 'cuenta_falsa.dart';
import 'helpers.dart';
import 'mascotas_falsas.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');
const _luna = Mascota(id: 'm1', nombre: 'Luna', especieId: 2);

Aviso _aviso({EstadoAviso estado = EstadoAviso.nuevo}) => Aviso(
  id: 'a1',
  desdeQr: true,
  mascotaId: 'm1',
  nombreRemitente: 'Carla',
  contactoRemitente: '099 555 666',
  mensaje: 'La encontré en la plaza, está bien.',
  estado: estado,
  creado: DateTime(2026, 10, 14, 10, 30),
  lat: -34.7171,
  lng: -55.9581,
);

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

void main() {
  testWidgets('la campana muestra los avisos nuevos y la bandeja los marca '
      'como vistos', (tester) async {
    _pantallaDeCelular(tester);
    final avisos = AvisosFalsos([_aviso()]);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas([_luna]),
        avisos: avisos,
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('1')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Avisos'));
    await tester.pumpAndSettle();

    expect(find.text('Luna: aviso de Carla'), findsOneWidget);
    expect(find.text('La encontré en la plaza, está bien.'), findsOneWidget);
    expect(find.text('Contacto: 099 555 666'), findsOneWidget);
    expect(find.textContaining('Nunca pagues por adelantado'), findsOneWidget);
    expect(find.text('Llamar'), findsOneWidget);
    expect(find.text('WhatsApp'), findsOneWidget);
    expect(find.text('Ver ubicación'), findsOneWidget);
    expect(avisos.avisos.single.estado, EstadoAviso.visto);
  });

  testWidgets('"Ya lo contacté" lo marca y registra la métrica', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final avisos = AvisosFalsos([_aviso(estado: EstadoAviso.visto)]);
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas([_luna]),
        avisos: avisos,
        eventos: eventos,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Avisos'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Más opciones'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ya lo contacté'));
    await tester.pumpAndSettle();

    expect(avisos.avisos.single.estado, EstadoAviso.respondido);
    expect(eventos.map((e) => e['name']), contains('alert_reply'));
    expect(find.text('Ya lo contactaste'), findsOneWidget);
  });

  testWidgets('marcar como estafa oculta los botones de contacto', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final avisos = AvisosFalsos([_aviso(estado: EstadoAviso.visto)]);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        mascotas: MascotasFalsas([_luna]),
        avisos: avisos,
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Avisos'));
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Más opciones'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Es una estafa'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Es una estafa'));
    await tester.pumpAndSettle();

    expect(avisos.avisos.single.estado, EstadoAviso.estafa);
    expect(find.textContaining('Marcado como estafa'), findsOneWidget);
    expect(find.text('Llamar'), findsNothing);
  });

  testWidgets('un visitante no ve la campana', (tester) async {
    await tester.pumpWidget(appDePrueba());
    await tester.pumpAndSettle();

    expect(find.byTooltip('Avisos'), findsNothing);
  });
}
