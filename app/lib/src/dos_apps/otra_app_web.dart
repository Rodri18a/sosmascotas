import 'package:web/web.dart' as web;

/// En la web, la otra app es otra dirección (D156).
void abrirOtraApp(String direccion) => web.window.location.assign(direccion);
