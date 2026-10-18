import 'dart:async';
import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

/// Chat interno (etapa 1.4, D73). Se reemplaza en las pruebas.
abstract interface class ChatRepositorio {
  Future<List<Conversacion>> misConversaciones();

  /// Abre (o reusa) el chat con quien publicó un SOS. Devuelve su id.
  Future<String> iniciarDesdeSos(String sosId);

  /// Abre (o reusa) el chat con un comercio que tiene dueño (1.4.3).
  Future<String> iniciarConNegocio(String comercioId);

  /// Los últimos mensajes, del más viejo al más nuevo.
  Future<List<Mensaje>> mensajes(String conversacionId);

  /// Mensajes nuevos al instante (Realtime).
  Stream<Mensaje> nuevos(String conversacionId);

  Future<void> enviarTexto(String conversacionId, String texto);

  /// Foto ya preparada (sin EXIF).
  Future<void> enviarFoto(String conversacionId, Uint8List jpeg);

  Future<void> enviarUbicacion(String conversacionId, double lat, double lng);

  Future<void> marcarLeido(String conversacionId);

  Future<void> bloquear(String conversacionId, {required bool bloquear});

  Future<void> reportar(String mensajeId, String motivo);

  /// Enlace temporal para ver una foto del bucket privado.
  Future<String?> urlFoto(String ruta);
}

class SupabaseChatRepositorio implements ChatRepositorio {
  SupabaseChatRepositorio(this._cliente);

  final SupabaseClient _cliente;

  static const _bucket = 'chat-photos';

  String get _yo =>
      _cliente.auth.currentUser?.id ??
      (throw StateError('Hace falta una sesión'));

  @override
  Future<List<Conversacion>> misConversaciones() async {
    final filas = await _cliente.rpc<List<dynamic>>('mis_conversaciones');
    return [
      for (final f in filas)
        Conversacion.fromJson((f as Map).cast<String, Object?>()),
    ];
  }

  @override
  Future<String> iniciarDesdeSos(String sosId) =>
      _cliente.rpc<String>('iniciar_chat_sos', params: {'p_sos': sosId});

  @override
  Future<String> iniciarConNegocio(String comercioId) => _cliente.rpc<String>(
    'iniciar_chat_negocio',
    params: {'p_business': comercioId},
  );

  @override
  Future<List<Mensaje>> mensajes(String conversacionId) async {
    final filas = await _cliente
        .from('messages')
        .select()
        .eq('conversation_id', conversacionId)
        .order('created_at', ascending: false)
        .limit(200);
    return filas.map(Mensaje.fromJson).toList().reversed.toList();
  }

  @override
  Stream<Mensaje> nuevos(String conversacionId) {
    late final RealtimeChannel canal;
    final salida = StreamController<Mensaje>(
      onCancel: () => _cliente.removeChannel(canal),
    );
    canal = _cliente
        .channel('chat:$conversacionId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'messages',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'conversation_id',
            value: conversacionId,
          ),
          callback: (cambio) => salida.add(Mensaje.fromJson(cambio.newRecord)),
        )
        .subscribe();
    return salida.stream;
  }

  Future<void> _insertar(Map<String, Object?> fila) =>
      _cliente.from('messages').insert(fila);

  @override
  Future<void> enviarTexto(String conversacionId, String texto) =>
      _insertar({'conversation_id': conversacionId, 'body': texto.trim()});

  @override
  Future<void> enviarFoto(String conversacionId, Uint8List jpeg) async {
    // Carpeta <yo>/<conversación> (lo exige la política del bucket).
    final ruta = '$_yo/$conversacionId/${generarAnonId()}.jpg';
    await _cliente.storage
        .from(_bucket)
        .uploadBinary(
          ruta,
          jpeg,
          fileOptions: const FileOptions(contentType: 'image/jpeg'),
        );
    await _insertar({
      'conversation_id': conversacionId,
      'attachment_path': ruta,
    });
  }

  @override
  Future<void> enviarUbicacion(String conversacionId, double lat, double lng) =>
      _insertar({'conversation_id': conversacionId, 'lat': lat, 'lng': lng});

  @override
  Future<void> marcarLeido(String conversacionId) => _cliente
      .from('conversation_members')
      .update({'last_read_at': DateTime.now().toUtc().toIso8601String()})
      .eq('conversation_id', conversacionId)
      .eq('user_id', _yo);

  @override
  Future<void> bloquear(String conversacionId, {required bool bloquear}) =>
      _cliente
          .from('conversation_members')
          .update({'blocked': bloquear})
          .eq('conversation_id', conversacionId)
          .eq('user_id', _yo);

  @override
  Future<void> reportar(String mensajeId, String motivo) =>
      _cliente.from('flags').insert({
        'target_type': 'message',
        'target_id': mensajeId,
        'reason': motivo,
      });

  @override
  Future<String?> urlFoto(String ruta) async {
    try {
      return await _cliente.storage.from(_bucket).createSignedUrl(ruta, 3600);
    } on Exception {
      return null;
    }
  }
}

class ChatSinConfigurar implements ChatRepositorio {
  const ChatSinConfigurar();

  @override
  Future<List<Conversacion>> misConversaciones() async => const [];

  @override
  Future<String> iniciarDesdeSos(String sosId) =>
      throw StateError('Supabase no está configurado');

  @override
  Future<String> iniciarConNegocio(String comercioId) =>
      throw StateError('Supabase no está configurado');

  @override
  Future<List<Mensaje>> mensajes(String conversacionId) async => const [];

  @override
  Stream<Mensaje> nuevos(String conversacionId) => const Stream.empty();

  @override
  Future<void> enviarTexto(String conversacionId, String texto) async {}

  @override
  Future<void> enviarFoto(String conversacionId, Uint8List jpeg) async {}

  @override
  Future<void> enviarUbicacion(
    String conversacionId,
    double lat,
    double lng,
  ) async {}

  @override
  Future<void> marcarLeido(String conversacionId) async {}

  @override
  Future<void> bloquear(
    String conversacionId, {
    required bool bloquear,
  }) async {}

  @override
  Future<void> reportar(String mensajeId, String motivo) async {}

  @override
  Future<String?> urlFoto(String ruta) async => null;
}

final chatRepositorioProvider = Provider<ChatRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const ChatSinConfigurar()
      : SupabaseChatRepositorio(cliente);
});

final conversacionesProvider = FutureProvider<List<Conversacion>>((ref) async {
  final usuario = ref.watch(usuarioActualProvider).value;
  if (usuario == null) return const [];
  return ref.watch(chatRepositorioProvider).misConversaciones();
});

/// Mensajes de una conversación: los guardados y, después, los que llegan.
final mensajesProvider = StreamProvider.family<List<Mensaje>, String>((
  ref,
  conversacionId,
) async* {
  final repo = ref.watch(chatRepositorioProvider);
  var lista = await repo.mensajes(conversacionId);
  yield lista;
  await for (final nuevo in repo.nuevos(conversacionId)) {
    lista = sumarMensajes(lista, [nuevo]);
    yield lista;
  }
});
