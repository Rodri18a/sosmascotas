import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

enum ErrorAgenda { ocupado, limite, soloPlus, noSePuede, otro }

class AgendaException implements Exception {
  const AgendaException(this.motivo);

  final ErrorAgenda motivo;

  @override
  String toString() => 'AgendaException($motivo)';
}

/// Agenda de turnos (3.1, D104). Se reemplaza en las pruebas.
abstract interface class AgendaRepositorio {
  /// `null` si el comercio no toma turnos.
  Future<CondicionesAgenda?> condiciones(String negocioId);

  Future<List<HorarioLibre>> horariosLibres(
    String negocioId,
    DateTime dia, {
    String? servicioId,
  });

  Future<String> reservar({
    required String negocioId,
    required String mascotaId,
    required DateTime inicio,
    String? servicioId,
    String? nota,
  });

  Future<List<Turno>> misTurnos();

  Future<List<Turno>> turnosDelNegocio(String negocioId);

  Future<void> cambiarEstado(String turnoId, EstadoTurno estado);

  Future<AjustesAgenda> miAgenda(String negocioId);

  Future<void> guardarAgenda(String negocioId, AjustesAgenda ajustes);

  Future<void> bloquearDia(
    String negocioId,
    DateTime dia, {
    String? nota,
    bool bloquear = true,
  });

  /// Cambios en vivo: `null` = Mis turnos; si no, los del comercio.
  Stream<void> enVivo({String? negocioId});
}

String _fecha(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}'
    '-${d.day.toString().padLeft(2, '0')}';

class SupabaseAgendaRepositorio implements AgendaRepositorio {
  SupabaseAgendaRepositorio(this._cliente);

  final SupabaseClient _cliente;

  List<Turno> _turnos(List<dynamic> filas) => [
    for (final f in filas) Turno.fromJson((f as Map).cast<String, Object?>()),
  ];

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on PostgrestException catch (e) {
      throw AgendaException(switch (e.code) {
        '54000' => ErrorAgenda.limite,
        '22023' when e.message.contains('libre') => ErrorAgenda.ocupado,
        '22023' => ErrorAgenda.noSePuede,
        '42501' when e.message.contains('Plus') => ErrorAgenda.soloPlus,
        _ => ErrorAgenda.otro,
      });
    }
  }

  /// Push a la otra parte. Si falla, el turno ya quedó guardado.
  Future<void> _avisar(String turnoId) async {
    try {
      await _cliente.functions.invoke(
        'booking-alert',
        body: {'booking_id': turnoId},
      );
    } on Exception {
      // Sin push: se ve igual en la lista.
    }
  }

  @override
  Future<CondicionesAgenda?> condiciones(String negocioId) async {
    final datos = await _cliente.rpc<Map<String, dynamic>?>(
      'condiciones_agenda',
      params: {'p_negocio': negocioId},
    );
    return datos == null
        ? null
        : CondicionesAgenda.fromJson(datos.cast<String, Object?>());
  }

  @override
  Future<List<HorarioLibre>> horariosLibres(
    String negocioId,
    DateTime dia, {
    String? servicioId,
  }) async => [
    for (final f in await _cliente.rpc<List<dynamic>>(
      'horarios_libres',
      params: {
        'p_negocio': negocioId,
        'p_dia': _fecha(dia),
        'p_servicio': servicioId,
      },
    ))
      HorarioLibre.fromJson((f as Map).cast<String, Object?>()),
  ];

  @override
  Future<String> reservar({
    required String negocioId,
    required String mascotaId,
    required DateTime inicio,
    String? servicioId,
    String? nota,
  }) async {
    final id = await _traducir(
      () => _cliente.rpc<String>(
        'reservar_turno',
        params: {
          'p_negocio': negocioId,
          'p_mascota': mascotaId,
          'p_inicio': inicio.toUtc().toIso8601String(),
          'p_servicio': servicioId,
          'p_nota': nota,
        },
      ),
    );
    unawaited(_avisar(id));
    return id;
  }

  @override
  Future<List<Turno>> misTurnos() async =>
      _turnos(await _cliente.rpc<List<dynamic>>('mis_turnos'));

  @override
  Future<List<Turno>> turnosDelNegocio(String negocioId) async => _turnos(
    await _cliente.rpc<List<dynamic>>(
      'turnos_del_negocio',
      params: {'p_negocio': negocioId},
    ),
  );

  @override
  Future<void> cambiarEstado(String turnoId, EstadoTurno estado) async {
    await _traducir(
      () => _cliente.rpc<void>(
        'cambiar_estado_turno',
        params: {'p_id': turnoId, 'p_estado': estado.base},
      ),
    );
    unawaited(_avisar(turnoId));
  }

  @override
  Future<AjustesAgenda> miAgenda(String negocioId) async =>
      AjustesAgenda.fromJson(
        (await _cliente.rpc<Map<String, dynamic>>(
          'mi_agenda',
          params: {'p_negocio': negocioId},
        )).cast<String, Object?>(),
      );

  @override
  Future<void> guardarAgenda(String negocioId, AjustesAgenda ajustes) =>
      _traducir(
        () => _cliente.rpc<void>(
          'guardar_agenda',
          params: {'p_negocio': negocioId, 'p': ajustes.toJson()},
        ),
      );

  @override
  Future<void> bloquearDia(
    String negocioId,
    DateTime dia, {
    String? nota,
    bool bloquear = true,
  }) => _traducir(
    () => _cliente.rpc<void>(
      'bloquear_dia',
      params: {
        'p_negocio': negocioId,
        'p_dia': _fecha(dia),
        'p_nota': nota,
        'p_bloquear': bloquear,
      },
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
              ? 'turnos:cliente:$yo'
              : 'turnos:negocio:$negocioId',
          opts: const RealtimeChannelConfig(private: true),
        )
        .onBroadcast(event: 'turno', callback: (_) => salida.add(null))
        .subscribe();
    return salida.stream;
  }
}

class AgendaSinConfigurar implements AgendaRepositorio {
  const AgendaSinConfigurar();

  @override
  Future<CondicionesAgenda?> condiciones(String negocioId) async => null;

  @override
  Future<List<HorarioLibre>> horariosLibres(
    String negocioId,
    DateTime dia, {
    String? servicioId,
  }) async => const [];

  @override
  Future<String> reservar({
    required String negocioId,
    required String mascotaId,
    required DateTime inicio,
    String? servicioId,
    String? nota,
  }) => throw const AgendaException(ErrorAgenda.otro);

  @override
  Future<List<Turno>> misTurnos() async => const [];

  @override
  Future<List<Turno>> turnosDelNegocio(String negocioId) async => const [];

  @override
  Future<void> cambiarEstado(String turnoId, EstadoTurno estado) async {}

  @override
  Future<AjustesAgenda> miAgenda(String negocioId) async =>
      const AjustesAgenda();

  @override
  Future<void> guardarAgenda(String negocioId, AjustesAgenda ajustes) async {}

  @override
  Future<void> bloquearDia(
    String negocioId,
    DateTime dia, {
    String? nota,
    bool bloquear = true,
  }) async {}

  @override
  Stream<void> enVivo({String? negocioId}) => const Stream.empty();
}

final agendaRepositorioProvider = Provider<AgendaRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const AgendaSinConfigurar()
      : SupabaseAgendaRepositorio(cliente);
});

final condicionesAgendaProvider =
    FutureProvider.family<CondicionesAgenda?, String>(
      (ref, negocioId) =>
          ref.watch(agendaRepositorioProvider).condiciones(negocioId),
    );

final horariosLibresProvider = FutureProvider.autoDispose
    .family<List<HorarioLibre>, (String, DateTime, String?)>(
      (ref, clave) => ref
          .watch(agendaRepositorioProvider)
          .horariosLibres(clave.$1, clave.$2, servicioId: clave.$3),
    );

final misTurnosProvider = FutureProvider<List<Turno>>((ref) {
  if (ref.watch(usuarioActualProvider).value == null) return const [];
  return ref.watch(agendaRepositorioProvider).misTurnos();
});

final turnosDelNegocioProvider = FutureProvider.family<List<Turno>, String>(
  (ref, negocioId) =>
      ref.watch(agendaRepositorioProvider).turnosDelNegocio(negocioId),
);

final miAgendaProvider = FutureProvider.family<AjustesAgenda, String>(
  (ref, negocioId) => ref.watch(agendaRepositorioProvider).miAgenda(negocioId),
);

final turnosEnVivoProvider = StreamProvider.autoDispose.family<void, String?>(
  (ref, negocioId) =>
      ref.watch(agendaRepositorioProvider).enVivo(negocioId: negocioId),
);
