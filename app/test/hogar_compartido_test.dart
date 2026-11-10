import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota/src/hogar/hogar_repositorio.dart';
import 'package:sosmascota/src/redireccion.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'cuenta_falsa.dart';
import 'funcionalidades_falsas.dart';
import 'helpers.dart';
import 'hogar_falso.dart';
import 'mascotas_falsas.dart';
import 'perfil_falso.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');
const _beto = Usuario(id: 'u2', email: 'beto@correo.com');

const _hogarDeAna = [
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

const _lunaDeAna = Mascota(
  id: 'm1',
  nombre: 'Luna',
  especieId: 2,
  duenoId: 'u1',
);

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

Future<void> _ir(WidgetTester tester, String ruta) async {
  await tester.pumpAndSettle();
  GoRouter.of(tester.element(find.byType(Scaffold).first)).go(ruta);
  await tester.pumpAndSettle();
}

Widget _app({
  required Usuario yo,
  required HogarFalso hogar,
  List<Mascota> mascotas = const [],
  Set<String> prendidas = const {Funcionalidades.hogar, Funcionalidades.perfil},
  List<Map<String, Object?>>? eventos,
}) => appDePrueba(
  cuenta: ServicioCuentaFalso(conectado: yo),
  perfiles: PerfilRepositorioFalso()..nombre = yo.id == 'u1' ? 'Ana' : 'Beto',
  hogar: hogar,
  mascotas: MascotasFalsas(mascotas),
  funcionalidades: FuncionalidadesFalsas(prendidas),
  eventos: eventos,
);

void main() {
  group('Mi hogar', () {
    testWidgets('invitar: arma el enlace y lo copia con un mensaje', (
      tester,
    ) async {
      _pantallaDeCelular(tester);
      final hogar = HogarFalso();
      final eventos = <Map<String, Object?>>[];
      String? copiado;
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        SystemChannels.platform,
        (llamada) async {
          if (llamada.method == 'Clipboard.setData') {
            copiado = (llamada.arguments as Map)['text'] as String;
          }
          return null;
        },
      );
      addTearDown(
        () => tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          SystemChannels.platform,
          null,
        ),
      );
      await tester.pumpWidget(_app(yo: _ana, hogar: hogar, eventos: eventos));
      await _ir(tester, '/hogar');

      expect(find.text('Todavía no invitaste a nadie.'), findsOneWidget);
      await _tocar(tester, find.text('Invitar a alguien'));
      expect(find.text('Invitación lista'), findsOneWidget);
      expect(
        find.text('https://huellamy.com/unirme/K7M2QX9PAB'),
        findsOneWidget,
      );
      await _tocar(tester, find.text('Copiar enlace'));
      expect(
        copiado,
        'Te invito a cuidar a mis mascotas en Huellamy: '
        'https://huellamy.com/unirme/K7M2QX9PAB',
      );
      expect(eventos.map((e) => e['name']), contains('household_invite'));
    });

    testWidgets('el dueño ve a los integrantes y puede sacar a uno', (
      tester,
    ) async {
      _pantallaDeCelular(tester);
      final hogar = HogarFalso(List.of(_hogarDeAna));
      await tester.pumpWidget(_app(yo: _ana, hogar: hogar));
      await _ir(tester, '/hogar');

      expect(find.text('Ana (vos)'), findsOneWidget);
      expect(find.text('Beto'), findsOneWidget);
      await _tocar(tester, find.byTooltip('Sacar del hogar'));
      expect(find.text('¿Sacar a Beto?'), findsOneWidget);
      await _tocar(
        tester,
        find.widgetWithText(FilledButton, 'Sacar del hogar'),
      );

      expect(hogar.lista.map((i) => i.usuarioId), ['u1']);
      expect(find.text('Beto'), findsNothing);
    });

    testWidgets('un integrante ve el hogar de otro y se puede ir', (
      tester,
    ) async {
      _pantallaDeCelular(tester);
      final hogar = HogarFalso(List.of(_hogarDeAna));
      final eventos = <Map<String, Object?>>[];
      await tester.pumpWidget(_app(yo: _beto, hogar: hogar, eventos: eventos));
      await _ir(tester, '/hogar');

      expect(find.text('Hogar de Ana'), findsOneWidget);
      expect(find.byTooltip('Sacar del hogar'), findsNothing);
      await _tocar(tester, find.text('Salir de este hogar'));
      await _tocar(tester, find.widgetWithText(FilledButton, 'Salir'));

      expect(hogar.lista.map((i) => i.usuarioId), ['u1']);
      expect(eventos.map((e) => e['name']), contains('household_leave'));
    });

    testWidgets('cuidador temporal: elige mascotas y días', (tester) async {
      _pantallaDeCelular(tester);
      final hogar = HogarFalso([
        ..._hogarDeAna,
        Integrante(
          hogarId: 'h1',
          usuarioId: 'u3',
          nombre: 'Caro',
          rol: RolHogar.tempCaregiver,
          accesoHasta: DateTime(2026, 10, 25),
        ),
      ]);
      final eventos = <Map<String, Object?>>[];
      await tester.pumpWidget(
        _app(
          yo: _ana,
          hogar: hogar,
          eventos: eventos,
          mascotas: const [
            _lunaDeAna,
            Mascota(id: 'm2', nombre: 'Toto', especieId: 1, duenoId: 'u1'),
          ],
        ),
      );
      await _ir(tester, '/hogar');
      expect(find.textContaining('Cuidador temporal hasta el'), findsOneWidget);

      await _tocar(tester, find.text('Invitar a un cuidador temporal'));
      await _tocar(tester, find.widgetWithText(CheckboxListTile, 'Toto'));
      await _tocar(tester, find.text('7 días'));
      await _tocar(tester, find.text('3 días').last);
      await _tocar(tester, find.text('Crear invitación'));

      final invitacion = hogar.invitaciones.single;
      expect(invitacion.dias, 3);
      expect(invitacion.mascotas, ['m1']);
      expect(find.text('Invitación lista'), findsOneWidget);
      expect(
        eventos.where((e) => e['name'] == 'household_invite').single['props'],
        {'rol': 'temp_caregiver'},
      );
    });

    testWidgets('sin la funcionalidad, "Mi hogar" no está disponible', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(yo: _ana, hogar: HogarFalso(), prendidas: const {}),
      );
      await _ir(tester, '/hogar');
      expect(find.text('Todavía no está disponible'), findsOneWidget);
    });
  });

  group('unirse con un enlace', () {
    testWidgets('se une y va a sus mascotas, aunque no tenga "Mi hogar"', (
      tester,
    ) async {
      final hogar = HogarFalso();
      final eventos = <Map<String, Object?>>[];
      await tester.pumpWidget(
        appDePrueba(
          cuenta: ServicioCuentaFalso(conectado: _beto),
          hogar: hogar,
          eventos: eventos,
        ),
      );
      await _ir(tester, '/unirme/K7M2QX9PAB');

      expect(find.text('Invitación a un hogar'), findsOneWidget);
      await _tocar(tester, find.text('Unirme'));
      expect(hogar.unidos, ['K7M2QX9PAB']);
      expect(eventos.map((e) => e['name']), contains('household_join'));
      expect(find.widgetWithText(AppBar, 'Mascotas'), findsOneWidget);
    });

    testWidgets('explica por qué no sirve', (tester) async {
      final hogar = HogarFalso()..fallarAlUnirse = ErrorInvitacion.noSirve;
      await tester.pumpWidget(
        appDePrueba(
          cuenta: ServicioCuentaFalso(conectado: _beto),
          hogar: hogar,
        ),
      );
      await _ir(tester, '/unirme/K7M2QX9PAB');
      await _tocar(tester, find.text('Unirme'));
      expect(find.textContaining('ya se usó o venció'), findsOneWidget);
    });

    testWidgets('un código mal escrito ni se intenta', (tester) async {
      await tester.pumpWidget(
        appDePrueba(cuenta: ServicioCuentaFalso(conectado: _beto)),
      );
      await _ir(tester, '/unirme/HOLA');
      expect(find.text('Unirme'), findsNothing);
      expect(find.textContaining('ya se usó o venció'), findsOneWidget);
    });

    test('un visitante primero ingresa', () {
      expect(
        redirigir(
          conectado: false,
          uri: Uri.parse('/unirme/K7M2QX9PAB'),
          funcionalidadActiva: (_) => false,
        ),
        '/ingresar?volver=%2Funirme%2FK7M2QX9PAB',
      );
    });

    test('el enlace de invitación', () {
      expect(
        enlaceInvitacion('https://app.ejemplo.uy/', 'ABCDEFGHJK'),
        'https://app.ejemplo.uy/unirme/ABCDEFGHJK',
      );
    });
  });

  group('mascota compartida', () {
    testWidgets('dice de quién es y no deja reportarla, borrarla ni cambiar '
        'el QR', (tester) async {
      _pantallaDeCelular(tester);
      await tester.pumpWidget(
        _app(
          yo: _beto,
          hogar: HogarFalso(List.of(_hogarDeAna)),
          mascotas: const [_lunaDeAna],
        ),
      );
      await _tocar(
        tester,
        find.descendant(
          of: find.byType(BarraInferior),
          matching: find.text('Mascotas'),
        ),
      );
      expect(find.textContaining('Compartida por Ana'), findsOneWidget);
      await _tocar(tester, find.widgetWithText(ListTile, 'Luna'));

      expect(find.text('Compartida por Ana'), findsOneWidget);
      expect(find.text('Se perdió: reportarla'), findsNothing);

      await _tocar(tester, find.text('Chapita QR'));
      expect(find.text('K7M2QX9P'), findsOneWidget);
      expect(find.text('Cambiar el código'), findsNothing);
      await _tocar(tester, find.byType(BackButton));

      await _tocar(tester, find.byTooltip('Editar'));
      // El formulario construye todos sus campos: el botón de borrar estaría.
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Guardar'));
      await tester.pumpAndSettle();
      expect(find.text('Borrar mascota'), findsNothing);
    });

    testWidgets('el dueño sí puede', (tester) async {
      _pantallaDeCelular(tester);
      await tester.pumpWidget(
        _app(
          yo: _ana,
          hogar: HogarFalso(List.of(_hogarDeAna)),
          mascotas: const [_lunaDeAna],
        ),
      );
      await _tocar(
        tester,
        find.descendant(
          of: find.byType(BarraInferior),
          matching: find.text('Mascotas'),
        ),
      );
      await _tocar(tester, find.widgetWithText(ListTile, 'Luna'));
      expect(find.text('Se perdió: reportarla'), findsOneWidget);
      expect(find.textContaining('Compartida'), findsNothing);
    });
  });

  testWidgets('Mi perfil: rol, mascotas a cargo y con quién comparte', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    await tester.pumpWidget(
      _app(
        yo: _beto,
        hogar: HogarFalso(List.of(_hogarDeAna)),
        mascotas: const [
          _lunaDeAna,
          Mascota(id: 'm2', nombre: 'Toto', especieId: 1, duenoId: 'u2'),
        ],
      ),
    );
    await _ir(tester, '/perfil');

    expect(find.text('Dueño o dueña de mascotas'), findsOneWidget);
    expect(find.text('Gratis'), findsOneWidget);
    expect(find.text('1 tuya · 1 compartida con vos'), findsOneWidget);
    expect(find.text('Toto'), findsOneWidget);
    expect(find.text('Luna'), findsOneWidget);
    expect(find.text('Compartida por Ana'), findsOneWidget);
    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Creó el hogar'), findsOneWidget);
    expect(find.text('Ver «Mi hogar»'), findsOneWidget);
  });
}
