import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';
import '../sos/sos_repositorio.dart';

/// Eventos y denuncias de maltrato (2.7, D80). Se reemplaza en las pruebas.
abstract interface class EventosRepositorio {
  Future<List<Evento>> enZona(Limites zona);

  /// Solo comercios o refugios verificados (lo controla la base).
  Future<void> publicar(Map<String, Object?> evento);

  Future<void> cancelar(String id);

  /// Foto ya preparada (sin EXIF), en el bucket privado de denuncias.
  Future<String> subirFotoDenuncia(Uint8List jpeg);

  Future<void> denunciar(
    String descripcion, {
    Punto? punto,
    String? direccion,
    List<String> fotos = const [],
  });

  Future<List<Denuncia>> misDenuncias();
}

class SupabaseEventosRepositorio implements EventosRepositorio {
  SupabaseEventosRepositorio(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<List<Evento>> enZona(Limites zona) async {
    final filas = await _cliente.rpc<List<dynamic>>(
      'eventos_en_zona',
      params: {
        'p_min_lat': zona.minLat,
        'p_min_lng': zona.minLng,
        'p_max_lat': zona.maxLat,
        'p_max_lng': zona.maxLng,
      },
    );
    return [
      for (final f in filas)
        Evento.fromJson((f as Map).cast<String, Object?>()),
    ];
  }

  @override
  Future<void> publicar(Map<String, Object?> evento) =>
      _cliente.rpc<String>('publicar_evento', params: {'p': evento});

  @override
  Future<void> cancelar(String id) =>
      _cliente.rpc<void>('cancelar_evento', params: {'p_id': id});

  @override
  Future<String> subirFotoDenuncia(Uint8List jpeg) async {
    final usuario = _cliente.auth.currentUser;
    if (usuario == null) throw StateError('Hace falta una sesión');
    final ruta = '${usuario.id}/${generarAnonId()}.jpg';
    await _cliente.storage
        .from('abuse-photos')
        .uploadBinary(
          ruta,
          jpeg,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    return ruta;
  }

  @override
  Future<void> denunciar(
    String descripcion, {
    Punto? punto,
    String? direccion,
    List<String> fotos = const [],
  }) => _cliente.rpc<String>(
    'denunciar_maltrato',
    params: {
      'p_descripcion': descripcion,
      'p_lat': punto?.lat,
      'p_lng': punto?.lng,
      'p_direccion': direccion,
      'p_fotos': fotos,
    },
  );

  @override
  Future<List<Denuncia>> misDenuncias() async {
    final filas = await _cliente.rpc<List<dynamic>>('mis_denuncias');
    return [
      for (final f in filas)
        Denuncia.fromJson((f as Map).cast<String, Object?>()),
    ];
  }
}

class EventosSinConfigurar implements EventosRepositorio {
  const EventosSinConfigurar();

  @override
  Future<List<Evento>> enZona(Limites zona) async => const [];

  @override
  Future<void> publicar(Map<String, Object?> evento) async {}

  @override
  Future<void> cancelar(String id) async {}

  @override
  Future<String> subirFotoDenuncia(Uint8List jpeg) =>
      throw StateError('Supabase no está configurado');

  @override
  Future<void> denunciar(
    String descripcion, {
    Punto? punto,
    String? direccion,
    List<String> fotos = const [],
  }) async {}

  @override
  Future<List<Denuncia>> misDenuncias() async => const [];
}

final eventosRepositorioProvider = Provider<EventosRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const EventosSinConfigurar()
      : SupabaseEventosRepositorio(cliente);
});

/// Próximos eventos alrededor de la zona de la persona (para Ayuda).
final eventosCercanosProvider = FutureProvider<List<Evento>>((ref) {
  final c = ref.watch(miZonaProvider);
  return ref
      .watch(eventosRepositorioProvider)
      .enZona(
        Limites(
          minLat: c.lat - 0.2,
          minLng: c.lng - 0.25,
          maxLat: c.lat + 0.2,
          maxLng: c.lng + 0.25,
        ),
      );
});

final misDenunciasProvider = FutureProvider<List<Denuncia>>((ref) {
  if (ref.watch(usuarioActualProvider).value == null) return const [];
  return ref.watch(eventosRepositorioProvider).misDenuncias();
});
