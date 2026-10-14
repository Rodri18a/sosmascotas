/// Nombres de los eventos de métricas (tabla `events`).
/// La lista completa está en docs/08-arquitectura.md, sección Métricas.
/// Formato obligatorio (lo valida también la base): minúsculas, números y `_`.
abstract final class Eventos {
  static const appOpen = 'app_open';
  static const signup = 'signup';
}

/// Valida el nombre de un evento con la misma regla que la base de datos.
bool nombreDeEventoValido(String nombre) =>
    RegExp(r'^[a-z][a-z0-9_]{1,62}$').hasMatch(nombre);
