import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Nombres de las funcionalidades con habilitación gradual (tabla
/// `feature_flags`, D64). Ver docs/15-funcionalidades-graduales.md.
/// Formato obligatorio (lo valida también la base): minúsculas, números y `_`.
/// Cuando una lleva un tiempo en `todos` sin problemas, se borra de acá.
abstract final class Funcionalidades {
  static const temasPro = 'temas_pro';

  /// Libreta sanitaria (paso 1.5.1, Fase 1): oculta hasta el lanzamiento de la Fase 1.
  static const libreta = 'libreta';

  /// Recordatorios de medicación, comida y vacunas (pasos 1.5.3–1.5.5, Fase 1).
  static const recordatorios = 'recordatorios';

  /// Hogar compartido: "Mi hogar" e invitaciones (etapa 1.6, D69).
  static const hogar = 'hogar';

  /// Pantalla "Mi perfil" con rol, mascotas a cargo y hogar (D70).
  static const perfil = 'perfil';

  /// Las que ya están en `todos`: la app las da por prendidas aunque no pueda
  /// preguntarle a la base (sin conexión y sin nada guardado). Las demás, en
  /// ese caso, quedan apagadas (lo seguro).
  static const prendidasPorDefecto = <String>{};
}

/// Valida el nombre de una funcionalidad con la misma regla que la base.
bool nombreDeFuncionalidadValido(String nombre) =>
    RegExp(r'^[a-z][a-z0-9_]{2,40}$').hasMatch(nombre);

/// Número de 0 a 99 que le toca a [id] (la cuenta o, sin cuenta, el `anon_id`)
/// en la funcionalidad [clave]. Misma cuenta que `public.cubeta_funcionalidad()`:
/// primeros 8 caracteres hex de `md5('clave:id')` como entero sin signo, módulo 100.
int cubetaFuncionalidad(String clave, String id) {
  final b = md5.convert(utf8.encode('$clave:$id')).bytes;
  final entero = (b[0] << 24) | (b[1] << 16) | (b[2] << 8) | b[3];
  return entero % 100;
}

/// ¿A [id] le toca la funcionalidad con este porcentaje? Es estable: al subir
/// el porcentaje nadie la pierde, solo se suman personas.
bool entraEnPorcentaje(String clave, String id, int porcentaje) =>
    cubetaFuncionalidad(clave, id) < porcentaje;
