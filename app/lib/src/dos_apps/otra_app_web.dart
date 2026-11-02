import 'package:web/web.dart' as web;

/// En la web, la otra app está en el mismo sitio (D129).
void abrirOtraApp(String direccion) => web.window.location.assign(direccion);
