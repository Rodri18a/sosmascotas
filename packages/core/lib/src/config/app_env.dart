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
    required this.supabaseAnonKey,
  });

  /// Lee la configuración pasada al compilar.
  factory AppEnv.fromEnvironment() => AppEnv.parse(
    flavor: const String.fromEnvironment('APP_FLAVOR', defaultValue: 'dev'),
    supabaseUrl: const String.fromEnvironment('SUPABASE_URL'),
    supabaseAnonKey: const String.fromEnvironment('SUPABASE_ANON_KEY'),
  );

  /// Valida los valores crudos. En producción Supabase es obligatorio;
  /// en desarrollo puede faltar hasta que exista el proyecto (paso 0.1.4).
  factory AppEnv.parse({
    required String flavor,
    required String supabaseUrl,
    required String supabaseAnonKey,
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
      supabaseAnonKey: supabaseAnonKey.trim(),
    );
    if (env.isProd && !env.hasSupabase) {
      throw StateError('Producción necesita SUPABASE_URL y SUPABASE_ANON_KEY');
    }
    return env;
  }

  final AppFlavor flavor;
  final String supabaseUrl;
  final String supabaseAnonKey;

  bool get isProd => flavor == AppFlavor.prod;

  bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
}
