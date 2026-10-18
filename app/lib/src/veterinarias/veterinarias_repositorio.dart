import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';

/// Una veterinaria con la que el dueño puede compartir una mascota: la que
/// marcó como "mi veterinaria" o una con la que ya la compartió.
class VeterinariaCompartible {
  const VeterinariaCompartible({
    required this.id,
    required this.nombre,
    required this.compartida,
  });

  final String id;
  final String nombre;
  final bool compartida;
}

/// Errores que la app explica (la base los marca con su código).
enum ErrorVeterinarias { soloPlus, limite, otro }

class VeterinariasException implements Exception {
  const VeterinariasException(this.tipo);

  final ErrorVeterinarias tipo;
}

ErrorVeterinarias _tipoDe(PostgrestException e) => switch (e.code) {
  '42501' => ErrorVeterinarias.soloPlus,
  '54000' => ErrorVeterinarias.limite,
  _ => ErrorVeterinarias.otro,
};

/// Socios de la veterinaria y "Busco veterinaria" (2.6, D81). Se reemplaza
/// en las pruebas.
abstract interface class VeterinariasRepositorio {
  // Lado del comercio.
  Future<Set<Modulo>> modulosPrendidos(String negocioId);
  Future<void> prenderModulo(String negocioId, Modulo modulo, bool prendido);
  Future<List<Socio>> socios(String negocioId);
  Future<void> recordar(
    String negocioId,
    String mascotaId,
    String titulo,
    DateTime cuando,
  );
  Future<List<Demanda>> demanda(String negocioId);

  /// Devuelve a cuántas mascotas llegó.
  Future<int> enviarPropuesta(String negocioId, String mensaje);
  Future<List<ResultadoPropuesta>> resultados(String negocioId);

  // Lado del dueño.
  Future<List<VeterinariaCompartible>> compartibles(String mascotaId);
  Future<void> compartir(String mascotaId, String negocioId, bool compartir);
  Future<EstadoBusqueda> estadoBusqueda(String mascotaId);
  Future<void> buscar(String mascotaId, bool quiero);
  Future<void> ahoraNo(String mascotaId);
  Future<List<Propuesta>> propuestas(String mascotaId);
  Future<void> responder(String propuestaId, String mascotaId, bool acepto);
}

class SupabaseVeterinariasRepositorio implements VeterinariasRepositorio {
  SupabaseVeterinariasRepositorio(this._cliente);

  final SupabaseClient _cliente;

  Future<T> _rpc<T>(String funcion, Map<String, Object?> params) async {
    try {
      return await _cliente.rpc<T>(funcion, params: params);
    } on PostgrestException catch (e) {
      throw VeterinariasException(_tipoDe(e));
    }
  }

  Future<List<Map<String, Object?>>> _filas(
    String funcion,
    Map<String, Object?> params,
  ) async => [
    for (final f in await _rpc<List<dynamic>>(funcion, params))
      (f as Map).cast<String, Object?>(),
  ];

  @override
  Future<Set<Modulo>> modulosPrendidos(String negocioId) async {
    final filas = await _cliente
        .from('business_modules')
        .select('module')
        .eq('business_id', negocioId)
        .eq('enabled', true);
    return {for (final f in filas) ?Modulo.values.asNameMap()[f['module']]};
  }

  @override
  Future<void> prenderModulo(String negocioId, Modulo modulo, bool prendido) =>
      _rpc<void>('prender_modulo', {
        'p_business': negocioId,
        'p_modulo': modulo.name,
        'p_prendido': prendido,
      });

  @override
  Future<List<Socio>> socios(String negocioId) async => [
    for (final f in await _filas('mis_socios', {'p_business': negocioId}))
      Socio.fromJson(f),
  ];

  @override
  Future<void> recordar(
    String negocioId,
    String mascotaId,
    String titulo,
    DateTime cuando,
  ) => _rpc<void>('recordar_a_socio', {
    'p_business': negocioId,
    'p_pet': mascotaId,
    'p_titulo': titulo,
    'p_cuando': cuando.toUtc().toIso8601String(),
  });

  @override
  Future<List<Demanda>> demanda(String negocioId) async => [
    for (final f in await _filas('demanda_de_veterinaria', {
      'p_business': negocioId,
    }))
      Demanda.fromJson(f),
  ];

  @override
  Future<int> enviarPropuesta(String negocioId, String mensaje) => _rpc<int>(
    'enviar_propuesta_veterinaria',
    {'p_business': negocioId, 'p_mensaje': mensaje},
  );

  @override
  Future<List<ResultadoPropuesta>> resultados(String negocioId) async => [
    for (final f in await _filas('resultados_propuestas', {
      'p_business': negocioId,
    }))
      ResultadoPropuesta.fromJson(f),
  ];

  @override
  Future<List<VeterinariaCompartible>> compartibles(String mascotaId) async {
    final compartidas = await _cliente
        .from('pet_vet_shares')
        .select('business_id, revoked_at, businesses(name)')
        .eq('pet_id', mascotaId);
    final mia = await _cliente
        .from('user_places')
        .select('business_id, businesses(name)')
        .eq('is_my_vet', true);
    final porId = <String, VeterinariaCompartible>{};
    for (final f in [...mia, ...compartidas]) {
      final id = f['business_id']! as String;
      final nombre = ((f['businesses'] as Map?)?['name'] as String?) ?? '';
      final compartida = f.containsKey('revoked_at') && f['revoked_at'] == null;
      porId[id] = VeterinariaCompartible(
        id: id,
        nombre: nombre,
        compartida: compartida || (porId[id]?.compartida ?? false),
      );
    }
    return porId.values.toList();
  }

  @override
  Future<void> compartir(String mascotaId, String negocioId, bool compartir) =>
      _rpc<void>('compartir_con_veterinaria', {
        'p_pet': mascotaId,
        'p_business': negocioId,
        'p_compartir': compartir,
      });

  @override
  Future<EstadoBusqueda> estadoBusqueda(String mascotaId) async =>
      EstadoBusqueda.fromJson(
        (await _rpc<Object?>('estado_busco_veterinaria', {'p_pet': mascotaId})
                as Map?)
            ?.cast<String, Object?>(),
      );

  @override
  Future<void> buscar(String mascotaId, bool quiero) =>
      _rpc<void>('busco_veterinaria', {'p_pet': mascotaId, 'p_quiero': quiero});

  @override
  Future<void> ahoraNo(String mascotaId) =>
      _rpc<void>('ahora_no_busco_veterinaria', {'p_pet': mascotaId});

  @override
  Future<List<Propuesta>> propuestas(String mascotaId) async => [
    for (final f in await _filas('propuestas_para', {'p_pet': mascotaId}))
      Propuesta.fromJson(f),
  ];

  @override
  Future<void> responder(String propuestaId, String mascotaId, bool acepto) =>
      _rpc<Object?>('responder_propuesta', {
        'p_proposal': propuestaId,
        'p_pet': mascotaId,
        'p_acepto': acepto,
      });
}

class VeterinariasSinConfigurar implements VeterinariasRepositorio {
  const VeterinariasSinConfigurar();

  @override
  Future<Set<Modulo>> modulosPrendidos(String negocioId) async => const {};

  @override
  Future<void> prenderModulo(
    String negocioId,
    Modulo modulo,
    bool prendido,
  ) async {}

  @override
  Future<List<Socio>> socios(String negocioId) async => const [];

  @override
  Future<void> recordar(
    String negocioId,
    String mascotaId,
    String titulo,
    DateTime cuando,
  ) async {}

  @override
  Future<List<Demanda>> demanda(String negocioId) async => const [];

  @override
  Future<int> enviarPropuesta(String negocioId, String mensaje) async => 0;

  @override
  Future<List<ResultadoPropuesta>> resultados(String negocioId) async =>
      const [];

  @override
  Future<List<VeterinariaCompartible>> compartibles(String mascotaId) async =>
      const [];

  @override
  Future<void> compartir(
    String mascotaId,
    String negocioId,
    bool compartir,
  ) async {}

  @override
  Future<EstadoBusqueda> estadoBusqueda(String mascotaId) async =>
      const EstadoBusqueda();

  @override
  Future<void> buscar(String mascotaId, bool quiero) async {}

  @override
  Future<void> ahoraNo(String mascotaId) async {}

  @override
  Future<List<Propuesta>> propuestas(String mascotaId) async => const [];

  @override
  Future<void> responder(
    String propuestaId,
    String mascotaId,
    bool acepto,
  ) async {}
}

final veterinariasRepositorioProvider = Provider<VeterinariasRepositorio>((
  ref,
) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const VeterinariasSinConfigurar()
      : SupabaseVeterinariasRepositorio(cliente);
});

final modulosPrendidosProvider = FutureProvider.family<Set<Modulo>, String>(
  (ref, id) => ref.watch(veterinariasRepositorioProvider).modulosPrendidos(id),
);

final sociosProvider = FutureProvider.family<List<Socio>, String>(
  (ref, id) => ref.watch(veterinariasRepositorioProvider).socios(id),
);

final demandaProvider = FutureProvider.family<List<Demanda>, String>(
  (ref, id) => ref.watch(veterinariasRepositorioProvider).demanda(id),
);

final resultadosPropuestasProvider =
    FutureProvider.family<List<ResultadoPropuesta>, String>(
      (ref, id) => ref.watch(veterinariasRepositorioProvider).resultados(id),
    );

final compartiblesProvider =
    FutureProvider.family<List<VeterinariaCompartible>, String>(
      (ref, id) => ref.watch(veterinariasRepositorioProvider).compartibles(id),
    );

final estadoBusquedaProvider = FutureProvider.family<EstadoBusqueda, String>(
  (ref, id) => ref.watch(veterinariasRepositorioProvider).estadoBusqueda(id),
);

final propuestasProvider = FutureProvider.family<List<Propuesta>, String>(
  (ref, id) => ref.watch(veterinariasRepositorioProvider).propuestas(id),
);
