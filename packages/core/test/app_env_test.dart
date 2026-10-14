import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  group('AppEnv.parse', () {
    test('desarrollo sin Supabase es válido', () {
      final env = AppEnv.parse(
        flavor: 'dev',
        supabaseUrl: '',
        supabasePublishableKey: '',
      );

      expect(env.flavor, AppFlavor.dev);
      expect(env.isProd, isFalse);
      expect(env.hasSupabase, isFalse);
    });

    test('producción con Supabase es válido y limpia espacios', () {
      final env = AppEnv.parse(
        flavor: ' prod ',
        supabaseUrl: ' https://abc.supabase.co ',
        supabasePublishableKey: 'clave',
      );

      expect(env.isProd, isTrue);
      expect(env.supabaseUrl, 'https://abc.supabase.co');
      expect(env.hasSupabase, isTrue);
    });

    test('producción sin Supabase falla', () {
      expect(
        () => AppEnv.parse(
          flavor: 'prod',
          supabaseUrl: '',
          supabasePublishableKey: '',
        ),
        throwsStateError,
      );
    });

    test('un entorno desconocido falla', () {
      expect(
        () => AppEnv.parse(
          flavor: 'staging',
          supabaseUrl: '',
          supabasePublishableKey: '',
        ),
        throwsArgumentError,
      );
    });
  });
}
