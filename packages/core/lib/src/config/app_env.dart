import 'config_firebase.dart';

/// Entorno en el que corre la app.
enum AppFlavor { dev, prod }

/// Configuración por entorno.
///
/// Los valores llegan al compilar con `--dart-define-from-file=config/<entorno>.json`.
/// Esos archivos **no se suben al repositorio**: solo los `*.example.json`.
class AppEnv {
  const AppEnv({
    required this.flavor,
    required this.supabaseUrl,
    required this.supabasePublishableKey,
    this.urlPublica = 'https://sosmascotas.uy',
    this.firebase,
  });

  /// Lee la configuración pasada al compilar.
  factory AppEnv.fromEnvironment() => AppEnv.parse(
    flavor: const String.fromEnvironment('APP_FLAVOR', defaultValue: 'dev'),
    supabaseUrl: const String.fromEnvironment('SUPABASE_URL'),
    supabasePublishableKey: const String.fromEnvironment(
      'SUPABASE_PUBLISHABLE_KEY',
    ),
    urlPublica: const String.fromEnvironment(
      'PUBLIC_BASE_URL',
      defaultValue: 'https://sosmascotas.uy',
    ),
    firebase: ConfigFirebase.fromEnvironment(),
  );

  /// Valida los valores crudos. En producción Supabase es obligatorio;
  /// en desarrollo puede faltar hasta que exista el proyecto (paso 0.1.4).
  factory AppEnv.parse({
    required String flavor,
    required String supabaseUrl,
    required String supabasePublishableKey,
    String urlPublica = 'https://sosmascotas.uy',
    ConfigFirebase? firebase,
  }) {
    final parsedFlavor = AppFlavor.values.asNameMap()[flavor.trim()];
    if (parsedFlavor == null) {
      throw ArgumentError.value(
        flavor,
        'APP_FLAVOR',
        'Debe ser "dev" o "prod"',
      );
    }
    final env = AppEnv(
      flavor: parsedFlavor,
      supabaseUrl: supabaseUrl.trim(),
      supabasePublishableKey: supabasePublishableKey.trim(),
      urlPublica: urlPublica.trim(),
      firebase: firebase,
    );
    if (env.isProd && !env.hasSupabase) {
      throw StateError(
        'Producción necesita SUPABASE_URL y SUPABASE_PUBLISHABLE_KEY',
      );
    }
    return env;
  }

  final AppFlavor flavor;
  final String supabaseUrl;
  final String supabasePublishableKey;

  /// Dirección de la web pública (páginas del QR y de los SOS).
  final String urlPublica;

  /// Push web (Firebase). `null`: la app funciona sin avisos push.
  final ConfigFirebase? firebase;

  bool get isProd => flavor == AppFlavor.prod;

  bool get hasSupabase =>
      supabaseUrl.isNotEmpty && supabasePublishableKey.isNotEmpty;
}
