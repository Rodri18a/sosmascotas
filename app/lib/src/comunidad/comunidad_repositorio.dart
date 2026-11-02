import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

enum ErrorComunidad { prohibido, noMiembro, limite, noQuiere, otro }

class ComunidadException implements Exception {
  const ComunidadException(this.motivo);

  final ErrorComunidad motivo;

  @override
  String toString() => 'ComunidadException($motivo)';
}

/// Comunidad por raza y especie (3.4, D116). Se reemplaza en las pruebas.
abstract interface class ComunidadRepositorio {
  Future<List<Grupo>> grupos();

  /// El grupo de una raza de mis mascotas (se crea si no existe).
  Future<String> grupoDeRaza(int razaId);

  Future<void> unirme(String grupoId, {required bool unirme});

  Future<List<Publicacion>> publicaciones(String grupoId);

  /// `null` si no existe o está oculta.
  Future<Publicacion?> publicacion(String id);

  Future<String> publicar({
    required String grupoId,
    required TipoPublicacion tipo,
    required String texto,
    List<String> fotos = const [],
  });

  Future<void> comentar(String publicacionId, String texto);

  /// Preguntas de todos los grupos (D134), con filtro de tema y búsqueda.
  Future<List<Publicacion>> preguntas({TemaPregunta? tema, String? buscar});

  /// Pregunta en [grupoId] (o en «Preguntas generales»); me suma si hace falta.
  Future<String> preguntar({
    required TemaPregunta tema,
    required String texto,
    String? grupoId,
  });

  /// Quien preguntó marca (o desmarca, con `null`) la respuesta que le sirvió.
  Future<void> marcarRespuesta(String preguntaId, String? comentarioId);

  /// [tipo]: `post` o `comment`.
  Future<void> borrar(String tipo, String id);

  /// [tipo]: `post` o `comment`.
  Future<void> reportar(String tipo, String id, String motivo);

  /// Saluda a quien escribió la publicación o el comentario.
  Future<void> saludar(String tipo, String id, String mensaje);

  Future<List<Saludo>> misSaludos();

  /// Aceptar devuelve el id del chat; rechazar, `null`.
  Future<String?> responderSaludo(String id, {required bool aceptar});

  /// Sube una foto ya preparada (sin EXIF) y devuelve su ruta.
  Future<String> subirFoto(Uint8List jpeg);

  String urlFoto(String ruta);
}

class SupabaseComunidadRepositorio implements ComunidadRepositorio {
  SupabaseComunidadRepositorio(this._cliente);

  final SupabaseClient _cliente;

  static const _bucket = 'community-photos';

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on PostgrestException catch (e) {
      throw ComunidadException(switch (e.code) {
        '22023' when e.message.contains('prohibido') =>
          ErrorComunidad.prohibido,
        '22023' when e.message.contains('no quiere') => ErrorComunidad.noQuiere,
        '42501' when e.message.contains('Unite') => ErrorComunidad.noMiembro,
        '54000' => ErrorComunidad.limite,
        _ => ErrorComunidad.otro,
      });
    }
  }

  List<Map<String, Object?>> _filas(Object? datos) => [
    for (final f in (datos as List?) ?? const [])
      (f as Map).cast<String, Object?>(),
  ];

  @override
  Future<List<Grupo>> grupos() async => _filas(
    await _cliente.rpc<List<dynamic>>('grupos'),
  ).map(Grupo.fromJson).toList();

  @override
  Future<String> grupoDeRaza(int razaId) => _traducir(
    () => _cliente.rpc<String>('grupo_de_raza', params: {'p_raza': razaId}),
  );

  @override
  Future<void> unirme(String grupoId, {required bool unirme}) => _traducir(
    () => _cliente.rpc<void>(
      'unirme_grupo',
      params: {'p_grupo': grupoId, 'p_unirme': unirme},
    ),
  );

  @override
  Future<List<Publicacion>> publicaciones(String grupoId) async => _filas(
    await _cliente.rpc<List<dynamic>>(
      'publicaciones_de',
      params: {'p_grupo': grupoId},
    ),
  ).map(Publicacion.fromJson).toList();

  @override
  Future<Publicacion?> publicacion(String id) async {
    final datos = await _cliente.rpc<Map<String, dynamic>?>(
      'publicacion',
      params: {'p_id': id},
    );
    return datos == null
        ? null
        : Publicacion.fromJson(datos.cast<String, Object?>());
  }

  @override
  Future<String> publicar({
    required String grupoId,
    required TipoPublicacion tipo,
    required String texto,
    List<String> fotos = const [],
  }) => _traducir(
    () => _cliente.rpc<String>(
      'publicar',
      params: {
        'p_grupo': grupoId,
        'p_tipo': tipo.base,
        'p_texto': texto,
        'p_fotos': fotos,
      },
    ),
  );

  @override
  Future<void> comentar(String publicacionId, String texto) => _traducir(
    () => _cliente.rpc<String>(
      'comentar',
      params: {'p_post': publicacionId, 'p_texto': texto},
    ),
  );

  @override
  Future<List<Publicacion>> preguntas({
    TemaPregunta? tema,
    String? buscar,
  }) async => _filas(
    await _cliente.rpc<List<dynamic>>(
      'preguntas',
      params: {'p_tema': tema?.base, 'p_buscar': buscar},
    ),
  ).map((f) => Publicacion.fromJson({...f, 'kind': 'question'})).toList();

  @override
  Future<String> preguntar({
    required TemaPregunta tema,
    required String texto,
    String? grupoId,
  }) => _traducir(
    () => _cliente.rpc<String>(
      'preguntar',
      params: {'p_tema': tema.base, 'p_texto': texto, 'p_grupo': grupoId},
    ),
  );

  @override
  Future<void> marcarRespuesta(String preguntaId, String? comentarioId) =>
      _traducir(
        () => _cliente.rpc<void>(
          'marcar_respuesta',
          params: {'p_post': preguntaId, 'p_comentario': comentarioId},
        ),
      );

  @override
  Future<void> borrar(String tipo, String id) => _traducir(
    () => _cliente.rpc<void>(
      'borrar_de_comunidad',
      params: {'p_tipo': tipo, 'p_id': id},
    ),
  );

  @override
  Future<void> reportar(String tipo, String id, String motivo) async {
    try {
      await _cliente.from('flags').insert({
        'target_type': tipo,
        'target_id': id,
        'reason': motivo,
      });
    } on PostgrestException catch (e) {
      // Ya lo había reportado: cuenta una sola vez.
      if (e.code != '23505') rethrow;
    }
  }

  @override
  Future<void> saludar(String tipo, String id, String mensaje) => _traducir(
    () => _cliente.rpc<String>(
      'saludar',
      params: {'p_tipo': tipo, 'p_id': id, 'p_mensaje': mensaje},
    ),
  );

  @override
  Future<List<Saludo>> misSaludos() async => _filas(
    await _cliente.rpc<List<dynamic>>('mis_saludos'),
  ).map(Saludo.fromJson).toList();

  @override
  Future<String?> responderSaludo(String id, {required bool aceptar}) =>
      _traducir(
        () => _cliente.rpc<String?>(
          'responder_saludo',
          params: {'p_id': id, 'p_aceptar': aceptar},
        ),
      );

  @override
  Future<String> subirFoto(Uint8List jpeg) async {
    final usuario = _cliente.auth.currentUser;
    if (usuario == null) throw StateError('Hace falta una sesión');
    final ruta = '${usuario.id}/${generarAnonId()}.jpg';
    await _cliente.storage
        .from(_bucket)
        .uploadBinary(
          ruta,
          jpeg,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return ruta;
  }

  @override
  String urlFoto(String ruta) =>
      _cliente.storage.from(_bucket).getPublicUrl(ruta);
}

class ComunidadSinConfigurar implements ComunidadRepositorio {
  const ComunidadSinConfigurar();

  @override
  Future<List<Grupo>> grupos() async => const [];

  @override
  Future<String> grupoDeRaza(int razaId) =>
      throw const ComunidadException(ErrorComunidad.otro);

  @override
  Future<void> unirme(String grupoId, {required bool unirme}) async {}

  @override
  Future<List<Publicacion>> publicaciones(String grupoId) async => const [];

  @override
  Future<Publicacion?> publicacion(String id) async => null;

  @override
  Future<String> publicar({
    required String grupoId,
    required TipoPublicacion tipo,
    required String texto,
    List<String> fotos = const [],
  }) => throw const ComunidadException(ErrorComunidad.otro);

  @override
  Future<void> comentar(String publicacionId, String texto) async {}

  @override
  Future<List<Publicacion>> preguntas({
    TemaPregunta? tema,
    String? buscar,
  }) async => const [];

  @override
  Future<String> preguntar({
    required TemaPregunta tema,
    required String texto,
    String? grupoId,
  }) => throw const ComunidadException(ErrorComunidad.otro);

  @override
  Future<void> marcarRespuesta(String preguntaId, String? comentarioId) async {}

  @override
  Future<void> borrar(String tipo, String id) async {}

  @override
  Future<void> reportar(String tipo, String id, String motivo) async {}

  @override
  Future<void> saludar(String tipo, String id, String mensaje) async {}

  @override
  Future<List<Saludo>> misSaludos() async => const [];

  @override
  Future<String?> responderSaludo(String id, {required bool aceptar}) async =>
      null;

  @override
  Future<String> subirFoto(Uint8List jpeg) =>
      throw const ComunidadException(ErrorComunidad.otro);

  @override
  String urlFoto(String ruta) => ruta;
}

final comunidadRepositorioProvider = Provider<ComunidadRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const ComunidadSinConfigurar()
      : SupabaseComunidadRepositorio(cliente);
});

final gruposProvider = FutureProvider<List<Grupo>>((ref) {
  ref.watch(usuarioActualProvider);
  return ref.watch(comunidadRepositorioProvider).grupos();
});

final publicacionesProvider = FutureProvider.family<List<Publicacion>, String>((
  ref,
  grupoId,
) {
  ref.watch(usuarioActualProvider);
  return ref.watch(comunidadRepositorioProvider).publicaciones(grupoId);
});

final publicacionProvider = FutureProvider.family<Publicacion?, String>((
  ref,
  id,
) {
  ref.watch(usuarioActualProvider);
  return ref.watch(comunidadRepositorioProvider).publicacion(id);
});

final misSaludosProvider = FutureProvider<List<Saludo>>((ref) {
  if (ref.watch(usuarioActualProvider).value == null) return const [];
  return ref.watch(comunidadRepositorioProvider).misSaludos();
});
