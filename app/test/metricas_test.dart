import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota/src/metricas/metricas.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

void main() {
  group('Metricas.track', () {
    test('envía el evento con los datos de la instalación', () async {
      final enviados = <Map<String, Object?>>[];
      Metricas(
        anonId: 'anon-1',
        plataforma: 'web',
        enviar: (fila) async => enviados.add(fila),
        usuarioActual: () => 'usuario-1',
      ).track(Eventos.appOpen, props: {'origen': 'prueba'}, zoneId: 1);
      await Future<void>.delayed(Duration.zero);

      expect(enviados, [
        {
          'name': 'app_open',
          'anon_id': 'anon-1',
          'user_id': 'usuario-1',
          'platform': 'web',
          'props': {'origen': 'prueba'},
          'zone_id': 1,
        },
      ]);
    });

    test('no manda los campos opcionales vacíos', () async {
      final enviados = <Map<String, Object?>>[];
      Metricas(
        anonId: 'anon-1',
        plataforma: 'android',
        enviar: (fila) async => enviados.add(fila),
      ).track(Eventos.appOpen);
      await Future<void>.delayed(Duration.zero);

      expect(enviados.single.keys, isNot(contains('zone_id')));
      expect(enviados.single['user_id'], isNull);
    });

    test('si el envío falla, no rompe la app', () async {
      final metricas = Metricas(
        anonId: 'anon-1',
        plataforma: 'web',
        enviar: (fila) async => throw Exception('sin internet'),
      );

      expect(() => metricas.track(Eventos.appOpen), returnsNormally);
      await Future<void>.delayed(Duration.zero);
    });

    test('sin Supabase configurado no envía nada', () {
      final metricas = Metricas.conSupabase(null, anonId: 'anon-1');

      expect(() => metricas.track(Eventos.appOpen), returnsNormally);
    });

    test('un nombre inválido se detecta en desarrollo', () {
      final metricas = Metricas(
        anonId: 'anon-1',
        plataforma: 'web',
        enviar: (fila) async {},
      );

      expect(() => metricas.track('App Open'), throwsA(isA<AssertionError>()));
    });
  });

  group('obtenerAnonId', () {
    test('se crea una vez y después se reutiliza', () async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      final primero = await obtenerAnonId(prefs);
      final segundo = await obtenerAnonId(prefs);

      expect(primero, segundo);
      expect(primero, hasLength(36));
    });
  });
}
