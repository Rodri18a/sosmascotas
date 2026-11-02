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

  /// Historial de vida de cada mascota (plan de mejoras 2.1, D131).
  static const historial = 'historial';

  /// Pasar una mascota a otra persona con su historial (2.2, D132).
  static const pasarMascota = 'pasar_mascota';

  /// Compartir el historial de solo lectura con un enlace que vence (D133).
  static const compartirHistorial = 'compartir_historial';

  /// Preguntas de la comunidad con temas y buscador (2.3, D134).
  static const preguntas = 'preguntas';

  /// Estado RENAC en la ficha y guía "Cómo registrar a tu mascota" (1.5.2b,
  /// D96).
  static const renac = 'renac';

  /// Recordatorios de medicación, comida y vacunas (pasos 1.5.3–1.5.5, Fase 1).
  static const recordatorios = 'recordatorios';

  /// Hogar compartido: "Mi hogar" e invitaciones (etapa 1.6, D69).
  static const hogar = 'hogar';

  /// Pantalla "Mi perfil" con rol, mascotas a cargo y hogar (D70).
  static const perfil = 'perfil';

  /// Chat interno, por ahora desde un SOS (etapa 1.4, D73).
  static const chat = 'chat';

  /// Mapa integral: rubros, filtros, lista, "sin local", grupos y favoritos
  /// (etapa 1.2, D75).
  static const mapaCompleto = 'mapa_completo';

  /// Pedido de chapita con retiro en la veterinaria (1.8b.4, D98).
  static const pedidoChapitas = 'pedido_chapitas';

  /// Búsqueda de lugares por nombre o rubro (1.8.7, D97).
  static const busqueda = 'busqueda';

  /// Comercios con cuenta: alta, reclamos, marcas y modo comercio (1.3, D77).
  static const comercios = 'comercios';

  /// Reseñas de comercios con contacto real (1.7, D78).
  static const resenas = 'resenas';

  /// Adopción responsable (etapa 2.0, D79).
  static const adopcion = 'adopcion';

  /// Eventos en el mapa y denuncias de maltrato (2.7, D80).
  static const eventos = 'eventos';

  /// Socios de la veterinaria y "Busco veterinaria" (2.6, D81).
  static const veterinarias = 'veterinarias';

  /// Noticias con contenido patrocinado (2.8, D83).
  static const noticias = 'noticias';

  /// Catálogo con "Consultar" y pedidos (2.5 y 3.2, D85).
  static const catalogo = 'catalogo';

  /// Estadísticas del comercio y reporte mensual (2.3, D101).
  static const estadisticas = 'estadisticas';

  /// Planes pagos del comercio: «Tu plan», pagos y pedir un plan (2.2, D103).
  static const planes = 'planes';

  /// Planes Pro y Familia de las personas: «Mi plan», tope de 5 mascotas en
  /// Gratis y hogar compartido con Familia (2.1, D111).
  static const planesUsuario = 'planes_usuario';

  /// Agenda de turnos: reservar, Mis turnos y la agenda del comercio (3.1,
  /// D104).
  static const agenda = 'agenda';

  /// Contratar paseadores, hoteles y cuidadores: pedir, Mis cuidados y los
  /// pedidos del prestador (3.3, D115).
  static const cuidados = 'cuidados';

  /// Grupos por raza y especie, publicaciones, comentarios y saludo previo
  /// al chat (3.4, D116).
  static const grupos = 'grupos';

  /// Equipo de la empresa: invitar con un código, sumarse y quitar (3.5,
  /// D117). Lo que hace el equipo ya adentro no depende de esta marca.
  static const equipo = 'equipo';

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
