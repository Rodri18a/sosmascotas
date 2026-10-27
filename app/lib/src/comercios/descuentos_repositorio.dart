import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../cuenta/servicio_cuenta.dart';

/// Por qué no se pudo pedir, cargar o canjear un descuento.
enum ErrorDescuento {
  sinPro,
  soloVerificados,
  demasiados,
  noDisponible,
  codigoInexistente,
  usadoHoy,
  vencido,
  sinConexion,
}

class DescuentoException implements Exception {
  const DescuentoException(this.motivo);
  final ErrorDescuento motivo;
}

/// Lo que ve la persona: `pro` si puede pedir códigos.
typedef DescuentosParaMi = ({bool pro, List<DescuentoPro> descuentos});

/// Lo que ve el comercio: `puede` si puede ofrecer descuentos.
typedef DescuentosDelNegocio = ({bool puede, List<DescuentoPro> descuentos});

/// Descuentos para Pro (2.11, D113). Se reemplaza en las pruebas.
abstract interface class DescuentosRepositorio {
  /// Los de mi zona, o los de [negocioId].
  Future<DescuentosParaMi> paraMi({String? negocioId});

  /// Devuelve el código para mostrar en el local. Solo con Pro.
  Future<String> pedir(String descuentoId);

  Future<DescuentosDelNegocio> delNegocio(String negocioId);

  /// [datos]: id (para editar), title, description, active.
  Future<void> guardar(String negocioId, Map<String, Object?> datos);

  Future<CanjeDescuento> canjear(String negocioId, String codigo);
}

class SupabaseDescuentos implements DescuentosRepositorio {
  SupabaseDescuentos(this._cliente);

  final SupabaseClient _cliente;

  Future<T> _traducir<T>(Future<T> Function() accion) async {
    try {
      return await accion();
    } on PostgrestException catch (e) {
      throw DescuentoException(switch ((e.code, e.message)) {
        ('54000', _) => ErrorDescuento.demasiados,
        (_, 'sin_pro') => ErrorDescuento.sinPro,
        (_, 'solo_verificados') => ErrorDescuento.soloVerificados,
        (_, 'codigo_inexistente') => ErrorDescuento.codigoInexistente,
        (_, 'usado_hoy') => ErrorDescuento.usadoHoy,
        (_, 'descuento_vencido') => ErrorDescuento.vencido,
        _ => ErrorDescuento.noDisponible,
      });
    } on Exception {
      throw const DescuentoException(ErrorDescuento.sinConexion);
    }
  }

  List<DescuentoPro> _lista(Map<String, dynamic> r) => [
    for (final f in (r['descuentos'] as List?) ?? const [])
      DescuentoPro.fromJson((f as Map).cast<String, Object?>()),
  ];

  @override
  Future<DescuentosParaMi> paraMi({String? negocioId}) async {
    final r = await _cliente.rpc<Map<String, dynamic>>(
      'descuentos_pro',
      params: {'p_business': ?negocioId},
    );
    return (pro: r['pro'] == true, descuentos: _lista(r));
  }

  @override
  Future<String> pedir(String descuentoId) => _traducir(
    () => _cliente.rpc<String>(
      'pedir_descuento_pro',
      params: {'p_discount': descuentoId},
    ),
  );

  @override
  Future<DescuentosDelNegocio> delNegocio(String negocioId) async {
    final r = await _cliente.rpc<Map<String, dynamic>>(
      'mis_descuentos_pro',
      params: {'p_business': negocioId},
    );
    return (puede: r['puede'] == true, descuentos: _lista(r));
  }

  @override
  Future<void> guardar(String negocioId, Map<String, Object?> datos) =>
      _traducir(
        () => _cliente.rpc<String>(
          'guardar_descuento_pro',
          params: {'p_business': negocioId, 'p': datos},
        ),
      );

  @override
  Future<CanjeDescuento> canjear(String negocioId, String codigo) =>
      _traducir(() async {
        final r = await _cliente.rpc<Map<String, dynamic>>(
          'canjear_descuento_pro',
          params: {'p_business': negocioId, 'p_code': codigo},
        );
        return (
          titulo: r['title'] as String? ?? '',
          cliente: switch (r['cliente']) {
            final String c when c.isNotEmpty => c,
            _ => null,
          },
        );
      });
}

class DescuentosSinConfigurar implements DescuentosRepositorio {
  const DescuentosSinConfigurar();

  static const _error = DescuentoException(ErrorDescuento.sinConexion);

  @override
  Future<DescuentosParaMi> paraMi({String? negocioId}) async =>
      (pro: false, descuentos: const <DescuentoPro>[]);

  @override
  Future<String> pedir(String descuentoId) => throw _error;

  @override
  Future<DescuentosDelNegocio> delNegocio(String negocioId) async =>
      (puede: false, descuentos: const <DescuentoPro>[]);

  @override
  Future<void> guardar(String negocioId, Map<String, Object?> datos) =>
      throw _error;

  @override
  Future<CanjeDescuento> canjear(String negocioId, String codigo) =>
      throw _error;
}

final descuentosRepositorioProvider = Provider<DescuentosRepositorio>((ref) {
  final cliente = ref.watch(supabaseClientProvider);
  return cliente == null
      ? const DescuentosSinConfigurar()
      : SupabaseDescuentos(cliente);
});

/// Los de mi zona (se vuelve a pedir al cambiar de cuenta).
final descuentosParaMiProvider = FutureProvider<DescuentosParaMi>((ref) {
  ref.watch(usuarioActualProvider);
  return ref.watch(descuentosRepositorioProvider).paraMi();
});

final descuentosNegocioProvider =
    FutureProvider.family<DescuentosDelNegocio, String>(
      (ref, negocioId) =>
          ref.watch(descuentosRepositorioProvider).delNegocio(negocioId),
    );
