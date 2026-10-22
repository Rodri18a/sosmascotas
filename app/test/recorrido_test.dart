import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/features/shell/app_shell.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import 'avisos_falsos.dart';
import 'cuenta_falsa.dart';
import 'helpers.dart';
import 'mascotas_falsas.dart';
import 'perfil_falso.dart';
import 'qr_falso.dart';
import 'sos_falso.dart';

/// Recorridos completos (paso 0.8.2): de la primera apertura a la acción,
/// pasando por todas las pantallas como lo haría una persona.

const _web = 'https://web.ejemplo.uy';

void _pantallaDeCelular(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1080, 2400)
    ..devicePixelRatio = 3;
  addTearDown(tester.view.reset);
}

Future<void> _ver(WidgetTester tester, Finder objetivo) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await tester.pumpAndSettle();
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
}

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  await _ver(tester, objetivo);
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

Future<void> _pestana(WidgetTester tester, String nombre) => _tocar(
  tester,
  find.descendant(of: find.byType(BarraInferior), matching: find.text(nombre)),
);

/// Lo que la app copia al portapapeles.
List<String> _portapapeles(WidgetTester tester) {
  final copiado = <String>[];
  tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
    SystemChannels.platform,
    (llamada) async {
      if (llamada.method == 'Clipboard.setData') {
        copiado.add((llamada.arguments as Map)['text'] as String);
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
  return copiado;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('dueño nuevo: cuenta, términos, mascota, QR, se pierde y '
      'comparte el reporte', (tester) async {
    _pantallaDeCelular(tester);
    final cuenta = ServicioCuentaFalso();
    final perfiles = PerfilRepositorioFalso(aceptoTerminos: false);
    final mascotas = MascotasFalsas();
    final sos = SosFalso();
    final eventos = <Map<String, Object?>>[];
    final copiado = _portapapeles(tester);
    await tester.pumpWidget(
      appDePrueba(
        cuenta: cuenta,
        perfiles: perfiles,
        mascotas: mascotas,
        qr: QrFalso(),
        sos: sos,
        eventos: eventos,
        urlPublica: _web,
        selectorFoto: (_) async =>
            img.encodeJpg(img.Image(width: 40, height: 30)),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Visitante: quiere cargar su mascota y se le pide una cuenta.
    await _pestana(tester, 'Mascotas');
    await _tocar(tester, find.text('Agregar mascota'));
    await _tocar(
      tester,
      find.widgetWithText(FilledButton, 'Ingresar o crear cuenta'),
    );
    await tester.enterText(find.byType(TextField), 'ana@correo.com');
    await _tocar(tester, find.text('Enviarme el código'));
    expect(cuenta.correosEnviados, ['ana@correo.com']);
    await tester.enterText(find.byType(TextField), '123456');
    await _tocar(tester, find.widgetWithText(FilledButton, 'Ingresar'));

    // 2. Cuenta nueva: términos y privacidad antes de seguir.
    expect(find.widgetWithText(AppBar, 'Antes de empezar'), findsOneWidget);
    final aceptar = find.widgetWithText(FilledButton, 'Aceptar y continuar');
    // La casilla y el botón están al final de la lista (se construyen al bajar).
    await tester.scrollUntilVisible(
      aceptar,
      300,
      scrollable: find.byType(Scrollable).last,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox));
    await tester.pumpAndSettle();
    await _tocar(tester, aceptar);
    expect(perfiles.aceptaciones, 1);

    // 3. Vuelve a lo que quería hacer: cargar la mascota.
    expect(find.widgetWithText(AppBar, 'Nueva mascota'), findsOneWidget);
    await _tocar(tester, find.text('Agregar foto'));
    await _tocar(tester, find.text('Elegir de la galería'));
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Nombre'),
      'Luna',
    );
    await _tocar(tester, find.text('🐱 Gato'));
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));
    final luna = mascotas.mascotas.single;
    expect(luna.nombre, 'Luna');
    expect(luna.fotoPath, isNotNull);
    expect(find.widgetWithText(AppBar, 'Luna'), findsOneWidget);

    // 4. Chapita QR: el código lleva a la web pública configurada.
    await _tocar(tester, find.text('Chapita QR'));
    final qr = tester.widget<QrImageView>(find.byType(QrImageView));
    expect(qr.semanticsLabel, 'QR de Luna');
    expect(find.text('K7M2QX9P'), findsOneWidget);
    await _tocar(tester, find.byType(BackButton));

    // 5. Se pierde: el reporte sale con sus datos.
    await _tocar(tester, find.text('Se perdió: reportarla'));
    expect(find.widgetWithText(AppBar, 'Nuevo reporte'), findsOneWidget);
    await _tocar(tester, find.byKey(const ValueKey('mapa-tocar')));
    await _tocar(tester, find.widgetWithText(FilledButton, 'Publicar'));
    debugPrint(
      'TEXTOS: ${tester.widgetList<Text>(find.byType(Text)).map((t) => t.data).toList()}',
    );
    final reporte = sos.creados.single;
    expect(reporte.tipo, TipoSos.perdida);
    expect(reporte.mascotaId, luna.id);
    expect(reporte.nombre, 'Luna');
    expect(sos.difundidos, hasLength(1), reason: 'avisa a quienes están cerca');
    expect(find.widgetWithText(AppBar, 'Reporte'), findsOneWidget);

    // 6. Comparte el enlace: es de la web pública, nunca de localhost.
    await _tocar(tester, find.text('Compartir'));
    expect(copiado, hasLength(1));
    expect(copiado.single, startsWith('$_web/s/'));

    expect(
      eventos.map((e) => e['name']),
      containsAll(['signup', 'pet_create']),
    );
  });

  testWidgets('alguien escanea la chapita: el dueño ve el aviso con los datos '
      'de quien la encontró y decide contactarlo (contacto inverso)', (
    tester,
  ) async {
    _pantallaDeCelular(tester);
    final avisos = AvisosFalsos([
      Aviso(
        id: 'a1',
        desdeQr: true,
        mascotaId: 'm1',
        nombreRemitente: 'Carla',
        contactoRemitente: '099 555 666',
        mensaje: 'La encontré en la plaza, está bien.',
        estado: EstadoAviso.nuevo,
        creado: DateTime(2026, 10, 16, 10, 30),
        lat: -34.7171,
        lng: -55.9581,
      ),
    ]);
    final eventos = <Map<String, Object?>>[];
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(
          conectado: const Usuario(id: 'u1', email: 'ana@correo.com'),
        ),
        mascotas: MascotasFalsas([
          const Mascota(id: 'm1', nombre: 'Luna', especieId: 2),
        ]),
        avisos: avisos,
        eventos: eventos,
      ),
    );
    await tester.pumpAndSettle();

    await _tocar(tester, find.byTooltip('Avisos'));
    expect(find.textContaining('La encontré en la plaza'), findsOneWidget);
    expect(find.textContaining('Carla'), findsWidgets);

    await _tocar(tester, find.byTooltip('Más opciones'));
    await _tocar(tester, find.text('Ya lo contacté'));
    expect(avisos.avisos.single.estado, EstadoAviso.respondido);
    expect(eventos.map((e) => e['name']), contains('alert_reply'));
  });

  test('ninguna configuración de ejemplo apunta a localhost', () {
    for (final archivo in Directory('config').listSync().whereType<File>()) {
      if (!archivo.path.endsWith('.example.json')) continue;
      final datos = jsonDecode(archivo.readAsStringSync()) as Map;
      final publica = datos['PUBLIC_BASE_URL'] as String?;
      expect(publica, startsWith('https://'), reason: archivo.path);
    }
  });
}
