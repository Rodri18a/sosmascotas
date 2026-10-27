import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

enum ErrorCuidados { sinLugar, limite, soloPlus, noSePuede, otro }

class CuidadosException implements Exception {
  const CuidadosException(this.motivo);

  final ErrorCuidados motivo;

  @override
  String toString() => 'CuidadosException($motivo)';
}

/// Contratar paseadores, hoteles y cuidadores (3.3, D115). Se reemplaza en
/// las pruebas.
abstract interface class CuidadosRepositorio {
  /// `null` si el prestador no ofrece nada.
  Future<CondicionesCuidados?> condiciones(String negocioId);

  Future<String> pedir({
    required String negocioId,
    required TipoCuidado tipo,
    required DateTime desde,
    required DateTime hasta,
    required List<String> mascotaIds,
    FranjaCuidado? franja,
    String? nota,
  });

  Future<List<Cuidado>> misCuidados();

  Future<List<Cuidado>> cuidadosDelNegocio(String negocioId);

  /// Aceptar devuelve el id del chat; rechazar, `null`.
  Future<String?> responder(String cuidadoId, {required bool aceptar});

  Future<void> cambiarEstado(String cuidadoId, EstadoCuidado estado);

  Future<AjustesCuidados> misAjustes(String negocioId);

  Future<void> guardarAjustes(String negocioId, AjustesCuidados ajustes);

  /// Cambios en vivo: `null` = Mis cuidados; si no, los del prestador.
  Stream<void> enVivo({String? negocioId});
}

class SupabaseCuidadosRepositorio implements CuidadosRepositorio {
  SupabaseCuidadosRepositorio(this._cliente);

  final SupabaseClient _cliente;

  List<Cuidado> _lista(List<dynamic> filas) => [
    for (final f in filas) Cuidado.fromJson((f as Map).cast<String, Object?>()),
  ];

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on PostgrestException catch (e) {
      throw CuidadosException(switch (e.code) {
        '54000' => ErrorCuidados.limite,
        '22023' when e.message.contains('lugar') => ErrorCuidados.sinLugar,
        '22023' => ErrorCuidados.noSePuede,
        '42501' when e.message.contains('Plus') => ErrorCuidados.soloPlus,
        _ => ErrorCuidados.otro,
      });
    }
  }

  /// Push a la otra parte. Si falla, el pedido ya quedó guardado.
  Future<void> _avisar(String cuidadoId) async {
    try {
      await _cliente.functions.invoke(
        'care-alert',
        body: {'request_id': cuidadoId},
      );
    } on Exception {
      // Sin push: se ve igual en la lista.
    }
  }

  @override
  Future<CondicionesCuidados?> condiciones(String negocioId) async {
    final datos = await _cliente.rpc<Map<String, dynamic>?>(
      'condiciones_cuidados',
      params: {'p_negocio': negocioId},
    );
    return datos == null
        ? null
        : CondicionesCuidados.fromJson(datos.cast<String, Object?>());
  }

  @override
  Future<String> pedir({
    required String negocioId,
    required TipoCuidado tipo,
    required DateTime desde,
    required DateTime hasta,
    required List<String> mascotaIds,
    FranjaCuidado? franja,
    String? nota,
  }) async {
    final id = await _traducir(
      () => _cliente.rpc<String>(
        'pedir_cuidado',
        params: {
          'p_negocio': negocioId,
          'p_tipo': tipo.base,
          'p_desde': fechaCuidado(desde),
          'p_hasta': fechaCuidado(hasta),
          'p_mascotas': mascotaIds,
          'p_franja': franja?.base,
          'p_nota': nota,
        },
      ),
    );
    unawaited(_avisar(id));
    return id;
  }

  @override
  Future<List<Cuidado>> misCuidados() async =>
      _lista(await _cliente.rpc<List<dynamic>>('mis_cuidados'));

  @override
  Future<List<Cuidado>> cuidadosDelNegocio(String negocioId) async => _lista(
    await _cliente.rpc<List<dynamic>>(
      'cuidados_del_negocio',
      params: {'p_negocio': negocioId},
    ),
  );

  @override
  Future<String?> responder(String cuidadoId, {required bool aceptar}) async {
    final chat = await _traducir(
      () => _cliente.rpc<String?>(
        'responder_cuidado',
        params: {'p_id': cuidadoId, 'p_aceptar': aceptar},
      ),
    );
    unawaited(_avisar(cuidadoId));
    return chat;
  }

  @override
  Future<void> cambiarEstado(String cuidadoId, EstadoCuidado estado) async {
    await _traducir(
      () => _cliente.rpc<void>(
        'cambiar_estado_cuidado',
        params: {'p_id': cuidadoId, 'p_estado': estado.base},
      ),
    );
    unawaited(_avisar(cuidadoId));
  }

  @override
  Future<AjustesCuidados> misAjustes(String negocioId) async =>
      AjustesCuidados.fromJson(
        (await _cliente.rpc<Map<String, dynamic>>(
          'mis_ajustes_cuidados',
          params: {'p_negocio': negocioId},
        )).cast<String, Object?>(),
      );

  @override
  Future<void> guardarAjustes(String negocioId, AjustesCuidados ajustes) =>
      _traducir(
        () => _cliente.rpc<void>(
          'guardar_cuidados',
          params: {'p_negocio': negocioId, 'p': ajustes.toJson()},
        ),
      );

  @override
  Stream<void> enVivo({String? negocioId}) {
    final yo = _cliente.auth.currentUser?.id;
    if (yo == null && negocioId == null) return const Stream.empty();
    late final RealtimeChannel canal;
    final salida = StreamController<void>(
      onCancel: () => _cliente.removeChannel(canal),
    );
    canal = _cliente
        .channel(
          negocioId == null
              ? 'cuidados:cliente:$yo'
              : 'cuidados:negocio:$negocioId',
          opts: const RealtimeChannelConfig(private: true),
        )
        .onBroadcast(event: 'cuidado', callback: (_) => salida.add(null))
        .subscribe();
    return salida.stream;
  }
}

class CuidadosSinConfigurar implements CuidadosRepositorio {
  const CuidadosSinConfigurar();

  @override
  Future<CondicionesCuidados?> condiciones(String negocioId) async => null;

  @override
  Future<String> pedir({
    required String negocioId,
    required TipoCuidado tipo,
    required DateTime desde,
    required DateTime hasta,
    required List<String> mascotaIds,
    FranjaCuidado? franja,
    String? nota,
  }) => throw const CuidadosException(ErrorCuidados.otro);

  @override
  Future<List<Cuidado>> misCuidados() async => const [];

  @override
  Future<List<Cuidado>> cuidadosDelNegocio(String negocioId) async => const [];

  @override
  Future<String?> responder(String cuidadoId, {required bool aceptar}) async =>
      null;

  @override
  Future<void> cambiarEstado(String cuidadoId, EstadoCuidado estado) async {}

  @override
  Future<AjustesCuidados> misAjustes(String negocioId) async =>
      const AjustesCuidados();

  @override
  Future<void> guardarAjustes(
    String negocioId,
    AjustesCuidados ajustes,
  ) async {}

  @override
  Stream<void> enVivo({String? negocioId}) => const Stream.empty();
}

final cuidadosRepositorioProvider = Provider<CuidadosRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const CuidadosSinConfigurar()
      : SupabaseCuidadosRepositorio(cliente);
});

final condicionesCuidadosProvider =
    FutureProvider.family<CondicionesCuidados?, String>(
      (ref, negocioId) =>
          ref.watch(cuidadosRepositorioProvider).condiciones(negocioId),
    );

final misCuidadosProvider = FutureProvider<List<Cuidado>>((ref) {
  if (ref.watch(usuarioActualProvider).value == null) return const [];
  return ref.watch(cuidadosRepositorioProvider).misCuidados();
});

final cuidadosDelNegocioProvider = FutureProvider.family<List<Cuidado>, String>(
  (ref, negocioId) =>
      ref.watch(cuidadosRepositorioProvider).cuidadosDelNegocio(negocioId),
);

final misAjustesCuidadosProvider =
    FutureProvider.family<AjustesCuidados, String>(
      (ref, negocioId) =>
          ref.watch(cuidadosRepositorioProvider).misAjustes(negocioId),
    );

final cuidadosEnVivoProvider = StreamProvider.autoDispose.family<void, String?>(
  (ref, negocioId) =>
      ref.watch(cuidadosRepositorioProvider).enVivo(negocioId: negocioId),
);
