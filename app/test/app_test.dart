import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sosmascota/src/app.dart';
import 'package:sosmascota/src/config/env_provider.dart';
import 'package:sosmascota/src/config/supabase_providers.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

const _url = 'https://abc.supabase.co';

Widget _app({
  AppFlavor flavor = AppFlavor.dev,
  bool conSupabase = false,
  int respuestaSalud = 200,
}) => ProviderScope(
  overrides: [
    appEnvProvider.overrideWithValue(
      AppEnv(
        flavor: flavor,
        supabaseUrl: conSupabase ? _url : '',
        supabasePublishableKey: conSupabase ? 'sb_publishable_prueba' : '',
      ),
    ),
    supabaseClientProvider.overrideWithValue(null),
    httpClientProvider.overrideWithValue(
      MockClient((pedido) async {
        expect(pedido.url.toString(), '$_url/auth/v1/health');
        expect(pedido.headers['apikey'], 'sb_publishable_prueba');
        return http.Response('{}', respuestaSalud);
      }),
    ),
  ],
  child: const SosMascotaApp(),
);

void main() {
  testWidgets('arranca en la pantalla de inicio', (tester) async {
    await tester.pumpWidget(_app());

    expect(find.text('SOS Mascota'), findsOneWidget);
  });

  testWidgets('muestra la marca DEV solo en desarrollo', (tester) async {
    await tester.pumpWidget(_app());
    expect(find.byType(Banner), findsOneWidget);

    await tester.pumpWidget(_app(flavor: AppFlavor.prod, conSupabase: true));
    expect(find.byType(Banner), findsNothing);
  });

  group('indicador de conexión', () {
    testWidgets('avisa si falta la configuración', (tester) async {
      await tester.pumpWidget(_app());
      await tester.pump();

      expect(find.textContaining('Falta configurar Supabase'), findsOneWidget);
    });

    testWidgets('muestra conectado si Supabase responde', (tester) async {
      await tester.pumpWidget(_app(conSupabase: true));
      await tester.pump();

      expect(find.text('Conectado a Supabase dev ✅'), findsOneWidget);
    });

    testWidgets('muestra sin conexión si Supabase falla', (tester) async {
      await tester.pumpWidget(_app(conSupabase: true, respuestaSalud: 503));
      await tester.pump();

      expect(find.text('Sin conexión a Supabase ❌'), findsOneWidget);
    });

    testWidgets('no se muestra en producción', (tester) async {
      await tester.pumpWidget(_app(flavor: AppFlavor.prod, conSupabase: true));
      await tester.pump();

      expect(find.byType(Chip), findsNothing);
    });
  });
}
