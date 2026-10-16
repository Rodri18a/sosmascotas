/// Nombres de los eventos de métricas (tabla `events`).
/// La lista completa está en docs/08-arquitectura.md, sección Métricas.
/// Formato obligatorio (lo valida también la base): minúsculas, números y `_`.
abstract final class Eventos {
  static const appOpen = 'app_open';
  static const signup = 'signup';
  static const accountDelete = 'account_delete';
  static const petCreate = 'pet_create';
  static const alertReply = 'alert_reply';
  static const contentFlag = 'content_flag';
  static const alertZoneSet = 'alert_zone_set';
  static const alertZoneClear = 'alert_zone_clear';
  static const placeOpen = 'place_open';
  static const placeClick = 'place_click';
  static const helpClick = 'help_click';
  static const themeChange = 'theme_change';
  static const featureExposure = 'feature_exposure';
  static const pwaPrompt = 'pwa_prompt';
  static const pwaInstalled = 'pwa_installed';
}

/// Valida el nombre de un evento con la misma regla que la base de datos.
bool nombreDeEventoValido(String nombre) =>
    RegExp(r'^[a-z][a-z0-9_]{1,62}$').hasMatch(nombre);
