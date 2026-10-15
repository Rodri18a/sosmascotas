import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota/src/cuenta/servicio_cuenta.dart';
import 'package:sosmascota/src/sos/difusion_sos.dart';

import 'cuenta_falsa.dart';
import 'helpers.dart';
import 'sos_falso.dart';

const _ana = Usuario(id: 'u1', email: 'ana@correo.com');

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('si la función responde, no queda nada pendiente', () async {
    final sos = SosFalso();
    final difusion = DifusionSos(sos);

    await difusion.difundir('sos-1');
    await difusion.reintentarPendientes();

    expect(sos.difundidos, ['sos-1']);
  });

  test('sin conexión queda pendiente y se reintenta hasta que sale', () async {
    final sos = SosFalso()..difusionResponde = false;
    final difusion = DifusionSos(sos);

    await difusion.difundir('sos-1');
    await difusion.reintentarPendientes();
    expect(sos.difundidos, ['sos-1', 'sos-1']);

    sos.difusionResponde = true;
    await difusion.reintentarPendientes();
    await difusion.reintentarPendientes();
    expect(sos.difundidos, ['sos-1', 'sos-1', 'sos-1']);
  });

  testWidgets('al abrir la app con sesión reintenta los SOS pendientes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'sos.difusion_pendiente': ['sos-7'],
    });
    final sos = SosFalso();
    await tester.pumpWidget(
      appDePrueba(
        cuenta: ServicioCuentaFalso(conectado: _ana),
        sos: sos,
      ),
    );
    await tester.pumpAndSettle();

    expect(sos.difundidos, ['sos-7']);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('sos.difusion_pendiente'), isEmpty);
  });
}
