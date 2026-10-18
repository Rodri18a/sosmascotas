import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

/// Por qué no se pudo publicar o pedir.
enum ErrorAdopcion { limite, noDisponible, datos, sinConexion }

class AdopcionException implements Exception {
  const AdopcionException(this.motivo);
  final ErrorAdopcion motivo;
}

/// Adopción responsable (2.0, D79). Se reemplaza en las pruebas.
abstract interface class AdopcionRepositorio {
  Future<List<AnimalAdopcion>> disponibles({int? especieId});

  Future<PerfilAdoptante?> miPerfil();

  Future<void> guardarPerfil(PerfilAdoptante perfil);

  /// Foto ya preparada (sin EXIF). Devuelve la ruta en el bucket.
  Future<String> subirFoto(Uint8List jpeg);

  String urlFoto(String ruta);

  /// [publicacion]: description, requirements, shelter_id, aporte…;
  /// [animales]: uno, o varios si es una camada.
  Future<String> publicar(
    Map<String, Object?> publicacion,
    List<Map<String, Object?>> animales,
  );

  Future<void> meInteresa(String animalId, {String? mensaje});

  Future<List<SolicitudAdopcion>> misSolicitudes();

  Future<List<SolicitudRecibida>> recibidas();

  Future<void> avanzar(String solicitudId, EtapaAdopcion etapa);

  Future<void> nota(String solicitudId, String nota);

  /// Devuelve el id de la mascota que pasa a la cuenta.
  Future<String> aceptarCompromiso(String solicitudId, String version);

  Future<List<Seguimiento>> misSeguimientos();

  Future<void> responderSeguimiento(
    String id,
    String respuesta, {
    String? foto,
  });
}

class SupabaseAdopcionRepositorio implements AdopcionRepositorio {
  SupabaseAdopcionRepositorio(this._cliente);

  final SupabaseClient _cliente;

  static const _bucket = 'adoption-photos';

  List<Map<String, Object?>> _filas(Object? datos) => [
    for (final f in (datos as List?) ?? const [])
      (f as Map).cast<String, Object?>(),
  ];

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on PostgrestException catch (e) {
      throw AdopcionException(switch (e.code) {
        '54000' => ErrorAdopcion.limite,
        'P0002' => ErrorAdopcion.noDisponible,
        _ => ErrorAdopcion.datos,
      });
    } on Exception {
      throw const AdopcionException(ErrorAdopcion.sinConexion);
    }
  }

  @override
  Future<List<AnimalAdopcion>> disponibles({int? especieId}) async => _filas(
    await _cliente.rpc<List<dynamic>>(
      'adopciones_disponibles',
      params: {'p_especie': especieId},
    ),
  ).map(AnimalAdopcion.fromJson).toList();

  @override
  Future<PerfilAdoptante?> miPerfil() async {
    final fila = await _cliente.from('adopter_profiles').select().maybeSingle();
    return fila == null ? null : PerfilAdoptante.fromJson(fila);
  }

  @override
  Future<void> guardarPerfil(PerfilAdoptante perfil) => _cliente
      .from('adopter_profiles')
      .upsert({...perfil.toJson(), 'user_id': _cliente.auth.currentUser?.id});

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

  @override
  Future<String> publicar(
    Map<String, Object?> publicacion,
    List<Map<String, Object?>> animales,
  ) => _traducir(
    () => _cliente.rpc<String>(
      'publicar_adopcion',
      params: {'p': publicacion, 'p_animales': animales},
    ),
  );

  @override
  Future<void> meInteresa(String animalId, {String? mensaje}) => _traducir(
    () => _cliente.rpc<String>(
      'me_interesa',
      params: {'p_animal': animalId, 'p_mensaje': mensaje},
    ),
  );

  @override
  Future<List<SolicitudAdopcion>> misSolicitudes() async => _filas(
    await _cliente.rpc<List<dynamic>>('mis_solicitudes_adopcion'),
  ).map(SolicitudAdopcion.fromJson).toList();

  @override
  Future<List<SolicitudRecibida>> recibidas() async => _filas(
    await _cliente.rpc<List<dynamic>>('solicitudes_recibidas'),
  ).map(SolicitudRecibida.fromJson).toList();

  @override
  Future<void> avanzar(String solicitudId, EtapaAdopcion etapa) => _traducir(
    () => _cliente.rpc<void>(
      'avanzar_solicitud',
      params: {'p_id': solicitudId, 'p_etapa': etapa.name},
    ),
  );

  @override
  Future<void> nota(String solicitudId, String nota) => _cliente.rpc<void>(
    'nota_de_solicitud',
    params: {'p_id': solicitudId, 'p_nota': nota},
  );

  @override
  Future<String> aceptarCompromiso(String solicitudId, String version) =>
      _traducir(
        () => _cliente.rpc<String>(
          'aceptar_compromiso',
          params: {'p_id': solicitudId, 'p_version': version},
        ),
      );

  @override
  Future<List<Seguimiento>> misSeguimientos() async => _filas(
    await _cliente.rpc<List<dynamic>>('mis_seguimientos'),
  ).map(Seguimiento.fromJson).toList();

  @override
  Future<void> responderSeguimiento(
    String id,
    String respuesta, {
    String? foto,
  }) => _traducir(
    () => _cliente.rpc<void>(
      'responder_seguimiento',
      params: {'p_id': id, 'p_respuesta': respuesta, 'p_foto': foto},
    ),
  );
}

class AdopcionSinConfigurar implements AdopcionRepositorio {
  const AdopcionSinConfigurar();

  @override
  Future<List<AnimalAdopcion>> disponibles({int? especieId}) async => const [];

  @override
  Future<PerfilAdoptante?> miPerfil() async => null;

  @override
  Future<void> guardarPerfil(PerfilAdoptante perfil) async {}

  @override
  Future<String> subirFoto(Uint8List jpeg) =>
      throw StateError('Supabase no está configurado');

  @override
  String urlFoto(String ruta) => '';

  @override
  Future<String> publicar(
    Map<String, Object?> publicacion,
    List<Map<String, Object?>> animales,
  ) => throw const AdopcionException(ErrorAdopcion.sinConexion);

  @override
  Future<void> meInteresa(String animalId, {String? mensaje}) =>
      throw const AdopcionException(ErrorAdopcion.sinConexion);

  @override
  Future<List<SolicitudAdopcion>> misSolicitudes() async => const [];

  @override
  Future<List<SolicitudRecibida>> recibidas() async => const [];

  @override
  Future<void> avanzar(String solicitudId, EtapaAdopcion etapa) async {}

  @override
  Future<void> nota(String solicitudId, String nota) async {}

  @override
  Future<String> aceptarCompromiso(String solicitudId, String version) =>
      throw const AdopcionException(ErrorAdopcion.sinConexion);

  @override
  Future<List<Seguimiento>> misSeguimientos() async => const [];

  @override
  Future<void> responderSeguimiento(
    String id,
    String respuesta, {
    String? foto,
  }) async {}
}

final adopcionRepositorioProvider = Provider<AdopcionRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const AdopcionSinConfigurar()
      : SupabaseAdopcionRepositorio(cliente);
});

final especieAdopcionProvider = NotifierProvider<EspecieAdopcion, int?>(
  EspecieAdopcion.new,
);

class EspecieAdopcion extends Notifier<int?> {
  @override
  int? build() => null;

  void elegir(int? especie) => state = especie;
}

final disponiblesProvider = FutureProvider<List<AnimalAdopcion>>(
  (ref) => ref
      .watch(adopcionRepositorioProvider)
      .disponibles(especieId: ref.watch(especieAdopcionProvider)),
);

final perfilAdoptanteProvider = FutureProvider<PerfilAdoptante?>((ref) {
  if (ref.watch(usuarioActualProvider).value == null) return null;
  return ref.watch(adopcionRepositorioProvider).miPerfil();
});

final misSolicitudesProvider = FutureProvider<List<SolicitudAdopcion>>((ref) {
  if (ref.watch(usuarioActualProvider).value == null) return const [];
  return ref.watch(adopcionRepositorioProvider).misSolicitudes();
});

final recibidasProvider = FutureProvider<List<SolicitudRecibida>>((ref) {
  if (ref.watch(usuarioActualProvider).value == null) return const [];
  return ref.watch(adopcionRepositorioProvider).recibidas();
});

final misSeguimientosProvider = FutureProvider<List<Seguimiento>>((ref) {
  if (ref.watch(usuarioActualProvider).value == null) return const [];
  return ref.watch(adopcionRepositorioProvider).misSeguimientos();
});
