/// Datos de la app web de Firebase (push). Son públicos por diseño, pero se
/// pasan por `config/<entorno>.json` como el resto de la configuración.
class ConfigFirebase {
  const ConfigFirebase({
    required this.apiKey,
    required this.appId,
    required this.messagingSenderId,
    required this.projectId,
    required this.vapidKey,
  });

  /// Lee la configuración pasada al compilar (`null` si no hay Firebase).
  static ConfigFirebase? fromEnvironment() => parse(
    apiKey: const String.fromEnvironment('FIREBASE_API_KEY'),
    appId: const String.fromEnvironment('FIREBASE_APP_ID'),
    messagingSenderId: const String.fromEnvironment(
      'FIREBASE_MESSAGING_SENDER_ID',
    ),
    projectId: const String.fromEnvironment('FIREBASE_PROJECT_ID'),
    vapidKey: const String.fromEnvironment('FIREBASE_VAPID_KEY'),
  );

  /// Sin ningún dato: `null` (la app funciona sin avisos push).
  /// Con algunos datos y otros no: error, para no fallar en silencio.
  static ConfigFirebase? parse({
    required String apiKey,
    required String appId,
    required String messagingSenderId,
    required String projectId,
    required String vapidKey,
  }) {
    final valores = {
      'FIREBASE_API_KEY': apiKey.trim(),
      'FIREBASE_APP_ID': appId.trim(),
      'FIREBASE_MESSAGING_SENDER_ID': messagingSenderId.trim(),
      'FIREBASE_PROJECT_ID': projectId.trim(),
      'FIREBASE_VAPID_KEY': vapidKey.trim(),
    };
    final faltan = [
      for (final MapEntry(:key, :value) in valores.entries)
        if (value.isEmpty) key,
    ];
    if (faltan.length == valores.length) return null;
    if (faltan.isNotEmpty) {
      throw StateError('Configuración de Firebase incompleta: $faltan');
    }
    return ConfigFirebase(
      apiKey: valores['FIREBASE_API_KEY']!,
      appId: valores['FIREBASE_APP_ID']!,
      messagingSenderId: valores['FIREBASE_MESSAGING_SENDER_ID']!,
      projectId: valores['FIREBASE_PROJECT_ID']!,
      vapidKey: valores['FIREBASE_VAPID_KEY']!,
    );
  }

  final String apiKey;
  final String appId;
  final String messagingSenderId;
  final String projectId;

  /// Clave pública de "Certificados push web" (Cloud Messaging).
  final String vapidKey;
}
