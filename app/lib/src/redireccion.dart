import 'router.dart';

/// Decide a dónde redirigir antes de mostrar una ruta (o `null` para seguir).
/// Es una función pura para poder probarla sin la app.
String? redirigir({required bool conectado, required Uri uri}) {
  if (uri.path == '/') return Rutas.mapa;

  // Con sesión, la pantalla de ingreso ya no tiene sentido: volver a la acción.
  if (uri.path == Rutas.ingresar && conectado) {
    return volverSeguro(uri.queryParameters['volver']);
  }

  // Visitante en una pantalla que necesita cuenta: ingresar y después volver.
  if (!conectado && Rutas.requierenCuenta.any(uri.path.startsWith)) {
    return Rutas.ingresarYVolverA(uri.toString());
  }
  return null;
}

/// Solo se vuelve a rutas internas de la app (evita redirecciones a otros sitios).
String volverSeguro(String? destino) =>
    destino != null &&
        destino.startsWith('/') &&
        !destino.startsWith('//') &&
        !destino.startsWith(Rutas.ingresar)
    ? destino
    : Rutas.mapa;
