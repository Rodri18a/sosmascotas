import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

/// Noticias (2.8, D83). Se reemplaza en las pruebas.
abstract interface class NoticiasRepositorio {
  /// Las publicadas, de la más nueva a la más vieja (también visitantes).
  Future<List<Noticia>> noticias();

  /// Novedades de la comunidad (D86), de la más nueva a la más vieja.
  Future<List<Novedad>> novedades();

  Future<ResumenComunidad> resumen();

  /// El autor de un SOS resuelto comparte (o quita) el reencuentro.
  Future<void> compartirReencuentro(String sosId, {required bool compartir});

  Future<bool> reencuentroCompartido(String sosId);

  /// Totales de reacciones (y la mía) de noticias o novedades (D87).
  Future<Map<String, Reacciones>> reacciones(List<String> ids);

  /// Reacciona (o quita la reacción con `null`) a una noticia o novedad.
  Future<void> reaccionar(String id, Reaccion? reaccion);

  /// Cuántas personas reaccionaron al reencuentro que compartí.
  Future<int> reaccionesDeMiReencuentro(String sosId);

  /// Enlace público de una foto `<bucket>/<ruta>` (o `null`).
  String? urlFoto(String? ruta);
}

class SupabaseNoticiasRepositorio implements NoticiasRepositorio {
  SupabaseNoticiasRepositorio(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<List<Noticia>> noticias() async {
    // Se traen todas (hasta 60) y el filtro por especie se hace en la app:
    // cambiar el chip no vuelve a consultar.
    final filas = await _cliente.rpc<List<dynamic>>('noticias');
    return [
      for (final f in filas)
        Noticia.fromJson((f as Map).cast<String, Object?>()),
    ];
  }

  @override
  Future<List<Novedad>> novedades() async {
    final filas = await _cliente.rpc<List<dynamic>>('novedades_comunidad');
    return [
      for (final f in filas)
        ?Novedad.fromJson((f as Map).cast<String, Object?>()),
    ];
  }

  @override
  Future<ResumenComunidad> resumen() async {
    final filas = await _cliente.rpc<List<dynamic>>('resumen_comunidad');
    return filas.isEmpty
        ? const ResumenComunidad()
        : ResumenComunidad.fromJson((filas.first as Map).cast());
  }

  @override
  Future<void> compartirReencuentro(String sosId, {required bool compartir}) =>
      _cliente.rpc<void>(
        compartir ? 'compartir_reencuentro' : 'quitar_reencuentro',
        params: {'p_sos': sosId},
      );

  @override
  Future<bool> reencuentroCompartido(String sosId) async =>
      await _cliente.rpc<bool>(
        'reencuentro_compartido',
        params: {'p_sos': sosId},
      ) ==
      true;

  @override
  Future<Map<String, Reacciones>> reacciones(List<String> ids) async {
    if (ids.isEmpty) return const {};
    final filas = await _cliente.rpc<List<dynamic>>(
      'reacciones',
      params: {'p_ids': ids},
    );
    return {
      for (final f in filas)
        if ((f as Map).cast<String, Object?>() case final fila)
          fila['id']! as String: Reacciones.fromJson(fila),
    };
  }

  @override
  Future<void> reaccionar(String id, Reaccion? reaccion) => _cliente.rpc<void>(
    'reaccionar',
    params: {'p_id': id, 'p_tipo': reaccion?.name},
  );

  @override
  Future<int> reaccionesDeMiReencuentro(String sosId) async =>
      ((await _cliente.rpc<num?>(
                'reacciones_de_mi_reencuentro',
                params: {'p_sos': sosId},
              )) ??
              0)
          .toInt();

  @override
  String? urlFoto(String? ruta) {
    if (ruta == null) return null;
    final corte = ruta.indexOf('/');
    if (corte <= 0) return null;
    return _cliente.storage
        .from(ruta.substring(0, corte))
        .getPublicUrl(ruta.substring(corte + 1));
  }
}

class NoticiasSinConfigurar implements NoticiasRepositorio {
  const NoticiasSinConfigurar();

  @override
  Future<List<Noticia>> noticias() async => const [];

  @override
  Future<List<Novedad>> novedades() async => const [];

  @override
  Future<ResumenComunidad> resumen() async => const ResumenComunidad();

  @override
  Future<void> compartirReencuentro(
    String sosId, {
    required bool compartir,
  }) async {}

  @override
  Future<bool> reencuentroCompartido(String sosId) async => false;

  @override
  Future<Map<String, Reacciones>> reacciones(List<String> ids) async =>
      const {};

  @override
  Future<void> reaccionar(String id, Reaccion? reaccion) async {}

  @override
  Future<int> reaccionesDeMiReencuentro(String sosId) async => 0;

  @override
  String? urlFoto(String? ruta) => null;
}

final noticiasRepositorioProvider = Provider<NoticiasRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const NoticiasSinConfigurar()
      : SupabaseNoticiasRepositorio(cliente);
});

final noticiasProvider = FutureProvider<List<Noticia>>(
  (ref) => ref.watch(noticiasRepositorioProvider).noticias(),
);

final novedadesProvider = FutureProvider<List<Novedad>>(
  (ref) => ref.watch(noticiasRepositorioProvider).novedades(),
);

final resumenComunidadProvider = FutureProvider<ResumenComunidad>(
  (ref) => ref.watch(noticiasRepositorioProvider).resumen(),
);

/// ¿El reencuentro de este SOS mío está compartido en la comunidad?
final reencuentroCompartidoProvider = FutureProvider.family<bool, String>(
  (ref, sosId) =>
      ref.watch(noticiasRepositorioProvider).reencuentroCompartido(sosId),
);

/// Cuántas personas reaccionaron al reencuentro que compartí.
final reaccionesDeMiReencuentroProvider = FutureProvider.family<int, String>(
  (ref, sosId) =>
      ref.watch(noticiasRepositorioProvider).reaccionesDeMiReencuentro(sosId),
);

/// Reacciones de las noticias y novedades que se vieron (D87), por id. Se
/// cargan de a tandas y al tocar una se ve el cambio enseguida (si falla,
/// vuelve como estaba).
final reaccionesProvider =
    NotifierProvider<ReaccionesNotifier, Map<String, Reacciones>>(
      ReaccionesNotifier.new,
    );

class ReaccionesNotifier extends Notifier<Map<String, Reacciones>> {
  @override
  Map<String, Reacciones> build() {
    // "La mía" cambia al entrar o salir de la cuenta.
    ref
      ..watch(noticiasRepositorioProvider)
      ..watch(conectadoProvider);
    return const {};
  }

  /// Trae las que todavía no están (sin conexión, quedan sin totales).
  Future<void> cargar(Iterable<String> ids) async {
    final faltan = [
      for (final id in ids)
        if (!state.containsKey(id)) id,
    ];
    if (faltan.isEmpty) return;
    try {
      final leidas = await ref
          .read(noticiasRepositorioProvider)
          .reacciones(faltan);
      state = {
        ...state,
        for (final id in faltan) id: leidas[id] ?? const Reacciones(),
      };
    } on Exception {
      // Sin totales hasta la próxima vez.
    }
  }

  /// Pone, cambia o quita mi reacción. Lanza si no se pudo guardar.
  Future<void> tocar(String id, Reaccion reaccion) async {
    final antes = state[id] ?? const Reacciones();
    final despues = antes.tocar(reaccion);
    state = {...state, id: despues};
    try {
      await ref.read(noticiasRepositorioProvider).reaccionar(id, despues.mia);
    } on Exception {
      state = {...state, id: antes};
      rethrow;
    }
  }
}
