import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart'
    show EstadisticasNegocio, fechaIso;
import 'package:supabase_flutter/supabase_flutter.dart';

import 'modelos.dart';

/// Todo lo que hace el portal contra la base. Cada función de la base vuelve
/// a verificar el rol `admin` (D76): esta capa no decide permisos. Se
/// reemplaza en las pruebas.
abstract interface class AdminRepositorio {
  /// `admin`, `moderator`, `sales` o null si no es del equipo (3.6, D109).
  Future<String?> rolEquipo();

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

  /// Lugares sin reclamar agrupados como en el mapa, con cuántas personas
  /// los marcaron y las aperturas de los últimos [dias] (1.8.5, D99).
  Future<List<Map<String, Object?>>> sinReclamar({int dias = 30});

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

  /// Resultados del comercio, los mismos que ve su dueño (2.3, D101).
  Future<EstadisticasNegocio> resultadosComercio(String negocioId);

  /// Datos para una propuesta (2.4, D102): por rubro, o para un comercio.
  Future<Propuesta> propuesta({String? rubro, String? negocioId});

  /// Deja anotado en `admin_actions` que se armó una propuesta.
  Future<void> registrarPropuesta(String rubro, {String? negocioId});

  Future<List<CasoExito>> casos();

  Future<void> guardarCaso(CasoExito caso);

  Future<void> borrarCaso(String id);

  /// Planes pagos con cobro manual (2.2, D103).
  Future<List<Suscripcion>> suscripciones();

  Future<Ingresos> ingresos();

  Future<void> crearSuscripcion({
    required String negocioId,
    required String plan,
    required double precio,
    required DateTime hasta,
    bool fundador = false,
    String? notas,
  });

  /// Devuelve hasta cuándo queda pago.
  Future<DateTime> registrarPago(
    String suscripcionId, {
    required double monto,
    required String metodo,
    String? referencia,
    int meses = 1,
  });

  Future<void> cancelarSuscripcion(String suscripcionId, {String? motivo});

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

  /// Sponsors de lotes de chapitas (2.9, D105), con cuántos lotes y chapitas.
  Future<List<Map<String, Object?>>> sponsors();

  /// Crea (sin `id`) o actualiza un sponsor. Devuelve su id.
  Future<String> guardarSponsor(Map<String, Object?> datos);

  /// Sube el logo al bucket público y devuelve la ruta para el sponsor.
  Future<String> subirLogo(Uint8List bytes, String tipo);

  /// Le pone (o le quita, con null) el sponsor a un lote.
  Future<void> sponsorLote(String loteId, String? sponsorId);

  /// Sus lotes con activadas, escaneos y reencuentros, para mandarle.
  Future<Map<String, Object?>> reporteSponsor(String sponsorId);

  /// Pasa [cantidad] chapitas libres del lote a una veterinaria verificada.
  /// Devuelve los códigos que hay que entregarle.
  Future<List<String>> asignarStock(
    String loteId,
    String negocioId,
    int cantidad,
  );

  /// Una chapita del stock que no se usó vuelve a quedar libre.
  Future<void> quitarStock(String codigo);

  /// Stock por veterinaria: recibidas, disponibles y activadas.
  Future<List<Map<String, Object?>>> stock();

  /// El equipo del portal con su rol (3.6, D109).
  Future<List<Map<String, Object?>>> equipo();

  /// [rol]: `admin`, `moderator`, `sales` o `user` (sacarlo del equipo).
  Future<void> ponerRol(String correo, String rol);

  /// Zonas con usuarios, mascotas, lugares y SOS activos.
  Future<List<Map<String, Object?>>> zonas();

  /// Crea (sin `id`) o actualiza una zona; el área es un rectángulo.
  Future<void> guardarZona(Map<String, Object?> datos);

  /// Lo que hizo el equipo en los últimos [dias] (hasta 500 acciones).
  Future<List<Map<String, Object?>>> auditoria({int dias = 30, String? accion});
}

class SupabaseAdminRepositorio implements AdminRepositorio {
  SupabaseAdminRepositorio(this._cliente);

  final SupabaseClient _cliente;

  List<Map<String, Object?>> _filas(Object? datos) => [
    for (final f in (datos as List?) ?? const [])
      (f as Map).cast<String, Object?>(),
  ];

  @override
  Future<String?> rolEquipo() => _cliente.rpc<String?>('mi_rol_equipo');

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
  Future<List<Map<String, Object?>>> sinReclamar({int dias = 30}) async =>
      _filas(
        await _cliente.rpc<List<dynamic>>(
          'admin_sin_reclamar',
          params: {'p_dias': dias},
        ),
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
  Future<EstadisticasNegocio> resultadosComercio(String negocioId) async =>
      EstadisticasNegocio.fromJson(
        (await _cliente.rpc<Map<String, dynamic>>(
          'estadisticas_negocio',
          params: {'p_id': negocioId},
        )).cast<String, Object?>(),
      );

  @override
  Future<Propuesta> propuesta({String? rubro, String? negocioId}) async =>
      Propuesta(
        (await _cliente.rpc<Map<String, dynamic>>(
          'admin_propuesta',
          params: {'p_rubro': ?rubro, 'p_negocio': ?negocioId},
        )).cast<String, Object?>(),
      );

  @override
  Future<void> registrarPropuesta(String rubro, {String? negocioId}) =>
      _cliente.rpc<void>(
        'admin_registrar_propuesta',
        params: {'p_rubro': rubro, 'p_negocio': negocioId},
      );

  @override
  Future<List<CasoExito>> casos() async => _filas(
    await _cliente.rpc<List<dynamic>>('admin_casos'),
  ).map(CasoExito.fromJson).toList();

  @override
  Future<void> guardarCaso(CasoExito caso) =>
      _cliente.rpc<void>('admin_guardar_caso', params: {'p': caso.toJson()});

  @override
  Future<void> borrarCaso(String id) =>
      _cliente.rpc<void>('admin_borrar_caso', params: {'p_id': id});

  @override
  Future<List<Suscripcion>> suscripciones() async => _filas(
    await _cliente.rpc<List<dynamic>>('admin_suscripciones'),
  ).map(Suscripcion.fromJson).toList();

  @override
  Future<Ingresos> ingresos() async => Ingresos.fromJson(
    (await _cliente.rpc<Map<String, dynamic>>(
      'admin_ingresos',
    )).cast<String, Object?>(),
  );

  @override
  Future<void> crearSuscripcion({
    required String negocioId,
    required String plan,
    required double precio,
    required DateTime hasta,
    bool fundador = false,
    String? notas,
  }) => _cliente.rpc<void>(
    'admin_crear_suscripcion',
    params: {
      'p_business': negocioId,
      'p_plan': plan,
      'p_precio': precio,
      'p_hasta': fechaIso(hasta),
      'p_founder': fundador,
      'p_notas': notas,
    },
  );

  @override
  Future<DateTime> registrarPago(
    String suscripcionId, {
    required double monto,
    required String metodo,
    String? referencia,
    int meses = 1,
  }) async => DateTime.parse(
    await _cliente.rpc<String>(
      'admin_registrar_pago',
      params: {
        'p_sub': suscripcionId,
        'p_monto': monto,
        'p_metodo': metodo,
        'p_referencia': referencia,
        'p_meses': meses,
      },
    ),
  );

  @override
  Future<void> cancelarSuscripcion(String suscripcionId, {String? motivo}) =>
      _cliente.rpc<void>(
        'admin_cancelar_suscripcion',
        params: {'p_sub': suscripcionId, 'p_motivo': motivo},
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

  @override
  Future<List<Map<String, Object?>>> sponsors() async =>
      _filas(await _cliente.rpc<List<dynamic>>('admin_sponsors'));

  @override
  Future<String> guardarSponsor(Map<String, Object?> datos) =>
      _cliente.rpc<String>('admin_guardar_sponsor', params: {'p': datos});

  @override
  Future<String> subirLogo(Uint8List bytes, String tipo) async {
    final ruta =
        'logo-${DateTime.now().millisecondsSinceEpoch}.'
        '${switch (tipo) {
          'image/png' => 'png',
          'image/webp' => 'webp',
          _ => 'jpg',
        }}';
    await _cliente.storage
        .from('sponsor-logos')
        .uploadBinary(ruta, bytes, fileOptions: FileOptions(contentType: tipo));
    return ruta;
  }

  @override
  Future<void> sponsorLote(String loteId, String? sponsorId) =>
      _cliente.rpc<void>(
        'admin_sponsor_lote',
        params: {'p_lote': loteId, 'p_sponsor': sponsorId},
      );

  @override
  Future<Map<String, Object?>> reporteSponsor(String sponsorId) async =>
      (await _cliente.rpc<Map<String, dynamic>>(
        'admin_reporte_sponsor',
        params: {'p_sponsor': sponsorId},
      )).cast<String, Object?>();

  @override
  Future<List<String>> asignarStock(
    String loteId,
    String negocioId,
    int cantidad,
  ) async => [
    for (final c in await _cliente.rpc<List<dynamic>>(
      'admin_asignar_stock',
      params: {
        'p_lote': loteId,
        'p_business': negocioId,
        'p_cantidad': cantidad,
      },
    ))
      c as String,
  ];

  @override
  Future<void> quitarStock(String codigo) =>
      _cliente.rpc<void>('admin_quitar_stock', params: {'p_code': codigo});

  @override
  Future<List<Map<String, Object?>>> stock() async =>
      _filas(await _cliente.rpc<List<dynamic>>('admin_stock'));

  @override
  Future<List<Map<String, Object?>>> equipo() async =>
      _filas(await _cliente.rpc<List<dynamic>>('admin_equipo'));

  @override
  Future<void> ponerRol(String correo, String rol) => _cliente.rpc<void>(
    'admin_poner_rol',
    params: {'p_email': correo, 'p_rol': rol},
  );

  @override
  Future<List<Map<String, Object?>>> zonas() async =>
      _filas(await _cliente.rpc<List<dynamic>>('admin_zonas'));

  @override
  Future<void> guardarZona(Map<String, Object?> datos) =>
      _cliente.rpc<int>('admin_guardar_zona', params: {'p': datos});

  @override
  Future<List<Map<String, Object?>>> auditoria({
    int dias = 30,
    String? accion,
  }) async => _filas(
    await _cliente.rpc<List<dynamic>>(
      'admin_auditoria',
      params: {'p_dias': dias, 'p_accion': accion},
    ),
  );
}

/// Se sobrescribe en `main.dart` (y en las pruebas).
final adminRepositorioProvider = Provider<AdminRepositorio>(
  (ref) => throw UnimplementedError('Falta configurar el repositorio'),
);

final rolEquipoProvider = FutureProvider<String?>(
  (ref) => ref.watch(adminRepositorioProvider).rolEquipo(),
);

final equipoProvider = FutureProvider<List<Map<String, Object?>>>(
  (ref) => ref.watch(adminRepositorioProvider).equipo(),
);

final zonasProvider = FutureProvider<List<Map<String, Object?>>>(
  (ref) => ref.watch(adminRepositorioProvider).zonas(),
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

final suscripcionesProvider = FutureProvider<List<Suscripcion>>(
  (ref) => ref.watch(adminRepositorioProvider).suscripciones(),
);

final ingresosProvider = FutureProvider<Ingresos>(
  (ref) => ref.watch(adminRepositorioProvider).ingresos(),
);

final casosProvider = FutureProvider<List<CasoExito>>(
  (ref) => ref.watch(adminRepositorioProvider).casos(),
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

final sinReclamarProvider = FutureProvider<List<Map<String, Object?>>>(
  (ref) => ref.watch(adminRepositorioProvider).sinReclamar(),
);

final lotesProvider = FutureProvider<List<Map<String, Object?>>>(
  (ref) => ref.watch(adminRepositorioProvider).lotes(),
);

final sponsorsProvider = FutureProvider<List<Map<String, Object?>>>(
  (ref) => ref.watch(adminRepositorioProvider).sponsors(),
);

final stockProvider = FutureProvider<List<Map<String, Object?>>>(
  (ref) => ref.watch(adminRepositorioProvider).stock(),
);

/// Dirección de la web pública: va dentro de cada chapita (`<base>/m/<código>`).
/// Se sobrescribe en `main.dart` con `PUBLIC_BASE_URL`.
final urlPublicaProvider = Provider<String>((ref) => 'https://sosmascotas.uy');
