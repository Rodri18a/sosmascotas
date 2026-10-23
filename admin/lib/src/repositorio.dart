import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart' show fechaIso;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'modelos.dart';

/// Todo lo que hace el portal contra la base. Cada función de la base vuelve
/// a verificar el rol `admin` (D76): esta capa no decide permisos. Se
/// reemplaza en las pruebas.
abstract interface class AdminRepositorio {
  Future<bool> esAdmin();

  Future<Panel> panel({int dias = 30});

  /// Demanda sin cubrir de los últimos [dias] (1.8.7).
  Future<Demanda> demanda({int dias = 30});

  Future<List<ItemModeracion>> moderacion();

  /// [accion]: `aprobar` o `eliminar`.
  Future<void> moderar(String tipo, String id, String accion, {String? motivo});

  /// [tipo]: `warning` o `block`; [dias] null = sin fin.
  Future<void> sancionar(
    String usuarioId,
    String tipo, {
    String? motivo,
    int? dias,
  });

  Future<Map<String, Object?>> historial(String usuarioId);

  Future<void> levantarSancion(String sancionId);

  Future<List<LugarAdmin>> lugares({String? buscar});

  /// Crea (sin `id`) o actualiza. Devuelve el id.
  Future<String> guardarLugar(Map<String, Object?> datos);

  Future<List<Prospecto>> prospectos();

  Future<void> guardarProspecto(Prospecto prospecto);

  Future<List<EntradaAyuda>> ayuda();

  /// Reclamos, disputas, verificaciones y pedidos de RENAC (1.3, D77).
  Future<List<PendienteComercio>> pendientesComercios();

  Future<void> resolverComercio(
    String tipo,
    String id, {
    required bool aprobar,
    String? motivo,
  });

  /// Socio Fundador hasta [hasta] (null: deja de serlo).
  Future<void> socioFundador(String negocioId, DateTime? hasta);

  /// Plan del comercio (`basic`, `featured`, `plus`) hasta que haya cobros (2.2).
  Future<void> planComercio(String negocioId, String plan);

  /// Publicaciones de adopción en revisión (2 camadas en 12 meses, 06).
  Future<List<Map<String, Object?>>> adopcionesEnRevision();

  Future<void> revisarAdopcion(String id, {required bool aprobar});

  /// Denuncias de maltrato (2.7, D80).
  Future<List<Map<String, Object?>>> denuncias();

  /// [estado]: `new`, `referred` (derivada) o `closed`.
  Future<void> estadoDenuncia(String id, String estado, {String? nota});

  /// Noticias (2.8, D83): todas, también borradores y ocultas.
  Future<List<Map<String, Object?>>> noticias();

  /// Crea (sin `id`) o actualiza una noticia.
  Future<void> guardarNoticia(Map<String, Object?> datos);

  /// Novedades de la comunidad (D86): las que se generan solas.
  Future<List<Map<String, Object?>>> novedades();

  Future<void> estadoNovedad(String id, {required bool visible});

  /// Crea (sin `id`) o actualiza una entrada de la Ayuda.
  Future<void> guardarAyuda(Map<String, Object?> datos);

  /// Lotes de chapitas físicas (1.8b.1, D95), el más nuevo primero, con
  /// activadas y escaneos.
  Future<List<Map<String, Object?>>> lotes();

  /// Crea un lote de [cantidad] códigos (1 a 500). Devuelve su id.
  Future<String> crearLote({
    required int cantidad,
    String? productor,
    String? material,
    num? costo,
    String? nota,
  });

  /// Los códigos del lote, en orden, para el productor.
  Future<List<String>> codigosLote(String loteId);

  /// Pedidos de chapitas con retiro en la veterinaria (1.8b.4, D98): los
  /// abiertos primero, los más viejos arriba.
  Future<List<Map<String, Object?>>> pedidosChapita();

  /// Le asigna a un pedido nuevo un código libre de un lote y lo manda.
  Future<void> enviarPedidoChapita(String pedidoId, String codigo);

  Future<void> cancelarPedidoChapita(String pedidoId, {String? motivo});
}

class SupabaseAdminRepositorio implements AdminRepositorio {
  SupabaseAdminRepositorio(this._cliente);

  final SupabaseClient _cliente;

  List<Map<String, Object?>> _filas(Object? datos) => [
    for (final f in (datos as List?) ?? const [])
      (f as Map).cast<String, Object?>(),
  ];

  @override
  Future<bool> esAdmin() async =>
      (await _cliente.rpc<bool?>('es_admin')) ?? false;

  @override
  Future<Panel> panel({int dias = 30}) async => Panel(
    ((await _cliente.rpc<Map<String, dynamic>>(
      'admin_panel',
      params: {'p_dias': dias},
    ))).cast<String, Object?>(),
  );

  @override
  Future<Demanda> demanda({int dias = 30}) async => Demanda.fromJson(
    (await _cliente.rpc<Map<String, dynamic>>(
      'admin_demanda',
      params: {'p_dias': dias},
    )).cast<String, Object?>(),
  );

  @override
  Future<List<ItemModeracion>> moderacion() async => _filas(
    await _cliente.rpc<List<dynamic>>('admin_moderacion'),
  ).map(ItemModeracion.fromJson).toList();

  @override
  Future<void> moderar(
    String tipo,
    String id,
    String accion, {
    String? motivo,
  }) => _cliente.rpc<void>(
    'admin_moderar',
    params: {
      'p_tipo': tipo,
      'p_id': id,
      'p_accion': accion,
      'p_motivo': motivo,
    },
  );

  @override
  Future<void> sancionar(
    String usuarioId,
    String tipo, {
    String? motivo,
    int? dias,
  }) => _cliente.rpc<String>(
    'admin_sancionar',
    params: {
      'p_user': usuarioId,
      'p_tipo': tipo,
      'p_motivo': motivo,
      'p_dias': dias,
    },
  );

  @override
  Future<Map<String, Object?>> historial(String usuarioId) async =>
      (await _cliente.rpc<Map<String, dynamic>>(
        'admin_historial_usuario',
        params: {'p_user': usuarioId},
      )).cast<String, Object?>();

  @override
  Future<void> levantarSancion(String sancionId) => _cliente.rpc<void>(
    'admin_levantar_sancion',
    params: {'p_sancion': sancionId},
  );

  @override
  Future<List<LugarAdmin>> lugares({String? buscar}) async => _filas(
    await _cliente.rpc<List<dynamic>>(
      'admin_lugares',
      params: {'p_buscar': buscar},
    ),
  ).map(LugarAdmin.fromJson).toList();

  @override
  Future<String> guardarLugar(Map<String, Object?> datos) =>
      _cliente.rpc<String>('admin_guardar_lugar', params: {'p': datos});

  @override
  Future<List<Prospecto>> prospectos() async =>
      (await _cliente
              .from('prospects')
              .select()
              .order('next_contact', ascending: true, nullsFirst: false))
          .map(Prospecto.fromJson)
          .toList();

  @override
  Future<void> guardarProspecto(Prospecto prospecto) => prospecto.id.isEmpty
      ? _cliente.from('prospects').insert(prospecto.toJson())
      : _cliente
            .from('prospects')
            .update(prospecto.toJson())
            .eq('id', prospecto.id);

  @override
  Future<List<PendienteComercio>> pendientesComercios() async => _filas(
    await _cliente.rpc<List<dynamic>>('admin_pendientes_comercios'),
  ).map(PendienteComercio.fromJson).toList();

  @override
  Future<void> resolverComercio(
    String tipo,
    String id, {
    required bool aprobar,
    String? motivo,
  }) => _cliente.rpc<void>(
    'admin_resolver_comercio',
    params: {
      'p_tipo': tipo,
      'p_id': id,
      'p_aprobar': aprobar,
      'p_motivo': motivo,
    },
  );

  @override
  Future<void> socioFundador(String negocioId, DateTime? hasta) =>
      _cliente.rpc<void>(
        'admin_socio_fundador',
        params: {
          'p_business': negocioId,
          'p_hasta': hasta == null ? null : fechaIso(hasta),
        },
      );

  @override
  Future<void> planComercio(String negocioId, String plan) =>
      _cliente.rpc<void>(
        'admin_plan_comercio',
        params: {'p_business': negocioId, 'p_plan': plan},
      );

  @override
  Future<List<Map<String, Object?>>> adopcionesEnRevision() async =>
      _filas(await _cliente.rpc<List<dynamic>>('admin_adopciones_en_revision'));

  @override
  Future<void> revisarAdopcion(String id, {required bool aprobar}) =>
      _cliente.rpc<void>(
        'admin_revisar_adopcion',
        params: {'p_id': id, 'p_aprobar': aprobar},
      );

  @override
  Future<List<Map<String, Object?>>> denuncias() async =>
      _filas(await _cliente.rpc<List<dynamic>>('admin_denuncias'));

  @override
  Future<void> estadoDenuncia(String id, String estado, {String? nota}) =>
      _cliente.rpc<void>(
        'admin_estado_denuncia',
        params: {'p_id': id, 'p_estado': estado, 'p_nota': nota},
      );

  @override
  Future<List<Map<String, Object?>>> noticias() async =>
      _filas(await _cliente.rpc<List<dynamic>>('admin_noticias'));

  @override
  Future<void> guardarNoticia(Map<String, Object?> datos) =>
      _cliente.rpc<String>('admin_guardar_noticia', params: {'p': datos});

  @override
  Future<List<Map<String, Object?>>> novedades() async =>
      _filas(await _cliente.rpc<List<dynamic>>('admin_novedades'));

  @override
  Future<void> estadoNovedad(String id, {required bool visible}) =>
      _cliente.rpc<void>(
        'admin_estado_novedad',
        params: {'p_id': id, 'p_estado': visible ? 'visible' : 'hidden'},
      );

  @override
  Future<List<EntradaAyuda>> ayuda() async =>
      (await _cliente
              .from('help_directory')
              .select()
              .order('kind')
              .order('sort'))
          .map(EntradaAyuda.fromJson)
          .toList();

  @override
  Future<void> guardarAyuda(Map<String, Object?> datos) {
    final id = datos['id'] as String?;
    final fila = {...datos}..remove('id');
    return id == null || id.isEmpty
        ? _cliente.from('help_directory').insert({...fila, 'zone_id': null})
        : _cliente.from('help_directory').update(fila).eq('id', id);
  }

  @override
  Future<List<Map<String, Object?>>> lotes() async =>
      _filas(await _cliente.rpc<List<dynamic>>('admin_lotes'));

  @override
  Future<String> crearLote({
    required int cantidad,
    String? productor,
    String? material,
    num? costo,
    String? nota,
  }) => _cliente.rpc<String>(
    'admin_crear_lote',
    params: {
      'p_cantidad': cantidad,
      'p_productor': productor,
      'p_material': material,
      'p_costo': costo,
      'p_nota': nota,
    },
  );

  @override
  Future<List<String>> codigosLote(String loteId) async => [
    for (final f in _filas(
      await _cliente.rpc<List<dynamic>>(
        'admin_codigos_lote',
        params: {'p_lote': loteId},
      ),
    ))
      f['code']! as String,
  ];

  @override
  Future<List<Map<String, Object?>>> pedidosChapita() async =>
      _filas(await _cliente.rpc<List<dynamic>>('admin_pedidos_chapita'));

  @override
  Future<void> enviarPedidoChapita(String pedidoId, String codigo) =>
      _cliente.rpc<void>(
        'admin_enviar_pedido_chapita',
        params: {'p_id': pedidoId, 'p_code': codigo},
      );

  @override
  Future<void> cancelarPedidoChapita(String pedidoId, {String? motivo}) =>
      _cliente.rpc<void>(
        'admin_cancelar_pedido_chapita',
        params: {'p_id': pedidoId, 'p_motivo': motivo},
      );
}

/// Se sobrescribe en `main.dart` (y en las pruebas).
final adminRepositorioProvider = Provider<AdminRepositorio>(
  (ref) => throw UnimplementedError('Falta configurar el repositorio'),
);

final esAdminProvider = FutureProvider<bool>(
  (ref) => ref.watch(adminRepositorioProvider).esAdmin(),
);

final diasPanelProvider = NotifierProvider<DiasPanel, int>(DiasPanel.new);

class DiasPanel extends Notifier<int> {
  @override
  int build() => 30;

  void elegir(int dias) => state = dias;
}

final panelProvider = FutureProvider<Panel>(
  (ref) => ref
      .watch(adminRepositorioProvider)
      .panel(dias: ref.watch(diasPanelProvider)),
);

final demandaProvider = FutureProvider<Demanda>(
  (ref) => ref
      .watch(adminRepositorioProvider)
      .demanda(dias: ref.watch(diasPanelProvider)),
);

final moderacionProvider = FutureProvider<List<ItemModeracion>>(
  (ref) => ref.watch(adminRepositorioProvider).moderacion(),
);

final lugaresProvider = FutureProvider.family<List<LugarAdmin>, String>(
  (ref, buscar) => ref
      .watch(adminRepositorioProvider)
      .lugares(buscar: buscar.trim().isEmpty ? null : buscar.trim()),
);

final prospectosProvider = FutureProvider<List<Prospecto>>(
  (ref) => ref.watch(adminRepositorioProvider).prospectos(),
);

final pendientesComerciosProvider = FutureProvider<List<PendienteComercio>>(
  (ref) => ref.watch(adminRepositorioProvider).pendientesComercios(),
);

final adopcionesEnRevisionProvider = FutureProvider<List<Map<String, Object?>>>(
  (ref) => ref.watch(adminRepositorioProvider).adopcionesEnRevision(),
);

final denunciasProvider = FutureProvider<List<Map<String, Object?>>>(
  (ref) => ref.watch(adminRepositorioProvider).denuncias(),
);

final noticiasProvider = FutureProvider<List<Map<String, Object?>>>(
  (ref) => ref.watch(adminRepositorioProvider).noticias(),
);

final novedadesProvider = FutureProvider<List<Map<String, Object?>>>(
  (ref) => ref.watch(adminRepositorioProvider).novedades(),
);

final ayudaProvider = FutureProvider<List<EntradaAyuda>>(
  (ref) => ref.watch(adminRepositorioProvider).ayuda(),
);

final pedidosChapitaProvider = FutureProvider<List<Map<String, Object?>>>(
  (ref) => ref.watch(adminRepositorioProvider).pedidosChapita(),
);

final lotesProvider = FutureProvider<List<Map<String, Object?>>>(
  (ref) => ref.watch(adminRepositorioProvider).lotes(),
);

/// Dirección de la web pública: va dentro de cada chapita (`<base>/m/<código>`).
/// Se sobrescribe en `main.dart` con `PUBLIC_BASE_URL`.
final urlPublicaProvider = Provider<String>((ref) => 'https://sosmascotas.uy');
