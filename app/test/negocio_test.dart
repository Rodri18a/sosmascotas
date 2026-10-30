import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/comercios/comercios_repositorio.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'comercios_falsos.dart';
import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

MiNegocio _negocio({
  String tipo = 'grooming',
  String verificacion = 'unverified',
}) => MiNegocio.fromJson({
  'id': 'b1',
  'name': 'Peluquería Luna',
  'business_type': tipo,
  'kind': 'local',
  'lat': -34.71,
  'lng': -55.95,
  'hours': {
    'mon': [
      ['09:00', '18:00'],
    ],
  },
  'verification': verificacion,
  'plan': 'basic',
  'status': 'active',
});

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

Future<void> _ir(WidgetTester tester, String ruta) async {
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(ruta);
  await tester.pumpAndSettle();
}

Future<void> _abrir(
  WidgetTester tester, {
  NegociosFalsos? negocios,
  ComerciosFalsos? comercios,
  bool prendida = true,
  List<Map<String, Object?>>? eventos,
}) async {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appDePrueba(
      cuenta: ServicioCuentaFalso(conectado: _ana),
      negocios: negocios,
      comercios: comercios,
      eventos: eventos,
      funcionalidades: FuncionalidadesFalsas({
        if (prendida) ...{
          Funcionalidades.comercios,
          Funcionalidades.mapaCompleto,
        },
      }),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('sin la funcionalidad no aparece "Mi negocio"', (tester) async {
    await _abrir(tester, prendida: false);
    await _ir(tester, '/ajustes');
    expect(find.text('Mi negocio'), findsNothing);
    await _ir(tester, '/negocio');
    expect(find.text('Todavía no está disponible'), findsOneWidget);
  });

  testWidgets('alta con local: aparece al instante como no verificado', (
    tester,
  ) async {
    final negocios = NegociosFalsos();
    final eventos = <Map<String, Object?>>[];
    await _abrir(tester, negocios: negocios, eventos: eventos);
    await _ir(tester, '/ajustes');
    await _tocar(tester, find.text('Mi negocio'));

    expect(find.widgetWithText(AppBar, 'Sumar mi negocio'), findsOneWidget);
    await _tocar(tester, find.widgetWithText(FilledButton, 'Sumar al mapa'));
    expect(find.textContaining('Escribí el nombre'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del negocio'),
      'Peluquería Luna',
    );
    await _tocar(tester, find.widgetWithText(ChoiceChip, 'Peluquería'));
    await _tocar(tester, find.widgetWithText(FilledButton, 'Sumar al mapa'));
    expect(find.text('Tocá el mapa para marcar dónde está.'), findsOneWidget);

    await _tocar(tester, find.byKey(const ValueKey('mapa-tocar')));
    await _tocar(tester, find.widgetWithText(FilledButton, 'Sumar al mapa'));

    final alta = negocios.altas.single;
    expect(alta['name'], 'Peluquería Luna');
    expect(alta['business_type'], 'grooming');
    expect(alta['kind'], 'local');
    expect(alta['lat'], -34.72);
    expect((alta['hours']! as Map).keys, ['mon', 'tue', 'wed', 'thu', 'fri']);
    expect(find.widgetWithText(AppBar, 'Peluquería Luna'), findsOneWidget);
    expect(find.textContaining('No verificado'), findsOneWidget);
    expect(
      eventos.where((e) => e['name'] == 'business_create').single['props'],
      {'tipo': 'grooming', 'modalidad': 'local'},
    );
  });

  testWidgets('alta a domicilio: sin mapa, con zona de trabajo', (
    tester,
  ) async {
    final negocios = NegociosFalsos();
    await _abrir(tester, negocios: negocios);
    await _ir(tester, '/negocio/alta');
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre del negocio'),
      'Paseos Toby',
    );
    await _tocar(tester, find.text('A domicilio'));
    expect(find.text('Tocá el mapa donde está tu local.'), findsNothing);
    await tester.enterText(
      find.widgetWithText(TextField, 'Zona donde trabajás'),
      'Pando y alrededores',
    );
    await _tocar(tester, find.widgetWithText(FilledButton, 'Sumar al mapa'));

    final alta = negocios.altas.single;
    expect(alta['kind'], 'domicilio');
    expect(alta['coverage'], 'Pando y alrededores');
    expect(alta['lat'], isNull);
  });

  testWidgets('panel con los contadores', (tester) async {
    await _abrir(tester, negocios: NegociosFalsos([_negocio(tipo: 'vet')]));
    await _ir(tester, '/negocio');
    expect(find.text('40'), findsOneWidget);
    expect(find.textContaining('25 en los 30 días anteriores'), findsOneWidget);
    expect(find.text('Llamar: 6'), findsOneWidget);
    expect(find.text('Te eligieron como su veterinaria'), findsOneWidget);
  });

  testWidgets('con dos negocios, se cambia tocando el título', (tester) async {
    final otro = MiNegocio.fromJson({
      'id': 'b2',
      'name': 'Veterinaria Sol',
      'business_type': 'vet',
      'kind': 'local',
      'plan': 'basic',
      'status': 'active',
    });
    await _abrir(tester, negocios: NegociosFalsos([_negocio(), otro]));
    await _ir(tester, '/negocio');
    expect(find.widgetWithText(AppBar, 'Peluquería Luna'), findsOneWidget);
    // En el celular, «Volver al modo dueño» es solo el ícono.
    expect(find.byTooltip('Volver al modo dueño'), findsOneWidget);
    expect(
      find.widgetWithText(TextButton, 'Volver al modo dueño'),
      findsNothing,
    );
    await _tocar(tester, find.byIcon(Icons.arrow_drop_down_outlined));
    await _tocar(tester, find.text('Veterinaria Sol').last);
    expect(find.widgetWithText(AppBar, 'Veterinaria Sol'), findsOneWidget);
  });

  testWidgets('módulos: "No aplica" o "Llega con el plan Plus"', (
    tester,
  ) async {
    await _abrir(tester, negocios: NegociosFalsos([_negocio()]));
    await _ir(tester, '/negocio');
    await _tocar(tester, find.text('Agenda'));
    expect(find.textContaining('Llega con el plan Plus'), findsOneWidget);
    await _tocar(tester, find.text('Catálogo'));
    expect(find.text('No aplica para tu tipo de negocio.'), findsOneWidget);
  });

  testWidgets('pedir la verificación con el RUT y editar la ficha', (
    tester,
  ) async {
    final negocios = NegociosFalsos([_negocio()]);
    await _abrir(tester, negocios: negocios);
    await _ir(tester, '/negocio');
    await _tocar(
      tester,
      find.descendant(
        of: find.byType(NavigationBar),
        matching: find.text('Negocio'),
      ),
    );

    await _tocar(tester, find.text('Pedir la insignia ✔️'));
    await tester.enterText(
      find.widgetWithText(TextField, 'RUT (12 números)'),
      '123',
    );
    await _tocar(tester, find.text('Enviar reclamo'));
    expect(find.text('El RUT tiene 12 números.'), findsOneWidget);
    expect(negocios.verificaciones, isEmpty);

    await _tocar(tester, find.text('Pedir la insignia ✔️'));
    await tester.enterText(
      find.widgetWithText(TextField, 'RUT (12 números)'),
      '21 234567 0019',
    );
    await _tocar(tester, find.text('Enviar reclamo'));
    expect(negocios.verificaciones.single.$1, 'b1');

    await tester.enterText(
      find.widgetWithText(TextField, 'Descripción (opcional)'),
      'Baños y cortes',
    );
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar cambios'));
    final (id, datos) = negocios.ediciones.single;
    expect(id, 'b1');
    expect(datos['description'], 'Baños y cortes');
    expect(datos['status'], 'active');
    expect(datos.containsKey('promo'), isFalse, reason: 'plan Básico');
  });

  testWidgets('lugar sin reclamar: "¿Es tu negocio?" lleva al alta', (
    tester,
  ) async {
    final comercios = ComerciosFalsos()
      ..sinReclamar = [
        const LugarSinReclamar(
          id: 'trainer:1',
          categoria: Categoria.trainer,
          punto: Punto(-34.72, -55.95),
          marcas: 2,
        ),
      ];
    final eventos = <Map<String, Object?>>[];
    await _abrir(tester, comercios: comercios, eventos: eventos);
    await tester.tap(find.byKey(const ValueKey('mapa-mover')));
    await tester.pumpAndSettle();

    await _tocar(
      tester,
      find.byKey(const ValueKey('pin-sin-reclamar:trainer:1')),
    );
    expect(find.text('Adiestrador sin reclamar'), findsOneWidget);
    expect(find.text('Marcado por 2 personas'), findsOneWidget);
    final apertura = eventos.where((e) => e['name'] == 'unclaimed_open').single;
    expect(apertura['target_id'], '1');
    expect(apertura['props'], {'tipo': 'trainer'});
    await _tocar(tester, find.text('¿Es tu negocio? Dalo de alta'));
    expect(find.widgetWithText(AppBar, 'Sumar mi negocio'), findsOneWidget);
    final chip = tester.widget<ChoiceChip>(
      find.widgetWithText(ChoiceChip, 'Adiestrador'),
    );
    expect(chip.selected, isTrue);
  });

  testWidgets('marcar un lugar desde el mapa', (tester) async {
    final comercios = ComerciosFalsos();
    final eventos = <Map<String, Object?>>[];
    await _abrir(tester, comercios: comercios, eventos: eventos);
    await _tocar(tester, find.text('Marcar un lugar'));

    await _tocar(tester, find.widgetWithText(ChoiceChip, 'Petshop'));
    await _tocar(tester, find.widgetWithText(FilledButton, 'Marcar'));
    expect(find.text('Tocá el mapa para marcar dónde queda.'), findsOneWidget);
    await _tocar(tester, find.byKey(const ValueKey('mapa-tocar')));
    await _tocar(tester, find.widgetWithText(FilledButton, 'Marcar'));

    expect(comercios.marcados.single.$1, Categoria.petshop);
    expect(eventos.map((e) => e['name']), contains('place_mark'));
  });

  testWidgets('marcar dos veces el mismo lugar lo explica', (tester) async {
    final comercios = ComerciosFalsos()..fallarCon = ErrorLugar.yaMarcado;
    await _abrir(tester, comercios: comercios);
    await _ir(tester, '/lugares/marcar');
    await _tocar(tester, find.byKey(const ValueKey('mapa-tocar')));
    await _tocar(tester, find.widgetWithText(FilledButton, 'Marcar'));
    expect(find.text('Ya marcaste este lugar.'), findsOneWidget);
  });

  testWidgets('"¿Es tu negocio? Reclamalo" en un lugar sin dueño', (
    tester,
  ) async {
    final comercios = ComerciosFalsos([
      const Comercio(
        id: 'b9',
        nombre: 'Petshop del Centro',
        tipo: 'petshop',
        punto: Punto(-34.72, -55.95),
        horario: Horario({}),
      ),
    ]);
    await _abrir(tester, comercios: comercios);
    await tester.tap(find.byKey(const ValueKey('mapa-mover')));
    await tester.pumpAndSettle();
    await _tocar(tester, find.byKey(const ValueKey('pin-b9')));

    await _tocar(tester, find.text('¿Es tu negocio? Reclamalo'));
    await tester.enterText(
      find.widgetWithText(TextField, 'RUT (12 números)'),
      '211111110019',
    );
    await _tocar(tester, find.text('Enviar reclamo'));
    expect(comercios.reclamos.single, ('b9', '211111110019', null));
    expect(find.textContaining('Recibimos tu reclamo'), findsOneWidget);
  });
}
