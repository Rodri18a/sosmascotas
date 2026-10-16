import 'router.dart';

/// Decide a dónde redirigir antes de mostrar una ruta (o `null` para seguir).
/// Es una función pura para poder probarla sin la app.
String? redirigir({
  required bool conectado,
  required Uri uri,
  bool necesitaConsentimiento = false,
  bool Function(String clave)? funcionalidadActiva,
  Map<String, String> rutasConFuncionalidad = Rutas.conFuncionalidad,
}) {
  if (uri.path == '/') return Rutas.mapa;

  // Con sesión pero sin aceptar los términos vigentes: primero el consentimiento
  // (los textos legales sí se pueden leer).
  if (conectado && necesitaConsentimiento) {
    final permitida =
        uri.path == Rutas.consentimiento || uri.path.startsWith(Rutas.legal);
    if (permitida) return null;
    final volver = uri.path == Rutas.ingresar
        ? volverSeguro(uri.queryParameters['volver'])
        : uri.toString();
    return Uri(
      path: Rutas.consentimiento,
      queryParameters: {'volver': volver},
    ).toString();
  }
  if (uri.path == Rutas.consentimiento) {
    return conectado ? volverSeguro(uri.queryParameters['volver']) : Rutas.mapa;
  }

  // Con sesión, la pantalla de ingreso ya no tiene sentido: volver a la acción.
  if (uri.path == Rutas.ingresar && conectado) {
    return volverSeguro(uri.queryParameters['volver']);
  }

  // Visitante en una pantalla que necesita cuenta: ingresar y después volver.
  if (!conectado && Rutas.requierenCuenta.any(uri.path.startsWith)) {
    return Rutas.ingresarYVolverA(uri.toString());
  }

  // Funcionalidad gradual que no le llegó (D64). Si después le llega (por
  // ejemplo, al terminar de cargar), vuelve sola a donde quería ir.
  String? claveDe(String ruta) => rutasConFuncionalidad.entries
      .where((e) => ruta.startsWith(e.key))
      .firstOrNull
      ?.value;
  final activa = funcionalidadActiva ?? ((_) => false);
  if (uri.path == Rutas.noDisponible) {
    final volver = uri.queryParameters['volver'];
    final clave = volver == null ? null : claveDe(Uri.parse(volver).path);
    return clave != null && activa(clave) ? volverSeguro(volver) : null;
  }
  final clave = claveDe(uri.path);
  if (clave != null && !activa(clave)) {
    return Uri(
      path: Rutas.noDisponible,
      queryParameters: {'volver': uri.toString()},
    ).toString();
  }
  return null;
}

/// Solo se vuelve a rutas internas de la app (evita redirecciones a otros sitios).
String volverSeguro(String? destino) =>
    destino != null &&
        destino.startsWith('/') &&
        !destino.startsWith('//') &&
        !destino.startsWith(Rutas.ingresar) &&
        !destino.startsWith(Rutas.consentimiento)
    ? destino
    : Rutas.mapa;
