import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_admin/src/app.dart';
import 'package:sosmascota_admin/src/modelos.dart';
import 'package:sosmascota_admin/src/pantallas/chapitas.dart';
import 'package:sosmascota_admin/src/pantallas/lugares.dart';
import 'package:sosmascota_admin/src/pantallas/propuestas.dart';
import 'package:sosmascota_admin/src/pantallas/sponsors.dart';
import 'package:sosmascota_admin/src/repositorio.dart';
import 'package:sosmascota_admin/src/sesion.dart';
import 'package:sosmascota_core/sosmascota_core.dart' show EstadisticasNegocio;

class SesionFalsa implements SesionAdmin {
  SesionFalsa([this.correo]);

  @override
  String? correo;
  final _cambios = StreamController<String?>.broadcast();
  final codigosPedidos = <String>[];

  @override
  Stream<String?> get cambios => _cambios.stream;

  @override
  Future<void> enviarCodigo(String correo) async => codigosPedidos.add(correo);

  @override
  Future<void> verificar(String correo, String codigo) async {
    if (codigo != '123456') throw Exception('código incorrecto');
    this.correo = correo;
    _cambios.add(correo);
  }

  @override
  Future<void> salir() async {
    correo = null;
    _cambios.add(null);
  }
}

class RepoFalso implements AdminRepositorio {
  RepoFalso({this.admin = true, this.rol});

  bool admin;

  /// Si no se dice, `admin` o nadie según [admin].
  String? rol;
  final moderados = <(String, String, String)>[];
  final sanciones = <(String, String, int?)>[];
  final lugaresGuardados = <Map<String, Object?>>[];
  final prospectosGuardados = <Prospecto>[];
  final ayudaGuardada = <Map<String, Object?>>[];
  var cola = <ItemModeracion>[
    const ItemModeracion(
      tipo: 'message',
      id: 'm1',
      autorId: 'u9',
      autorNombre: 'Estafador',
      texto: 'Transferime 3000 y te la devuelvo',
      estado: 'reported',
      reportes: 1,
      motivos: ['estafa'],
    ),
  ];

  @override
  Future<String?> rolEquipo() async => rol ?? (admin ? 'admin' : null);

  @override
  Future<Panel> panel({int dias = 30}) async => const Panel({
    'usuarios': 120,
    'activos_mes': 45,
    'sos_activos': 3,
    'sos_dias_hasta_resolver': 2.5,
    'comercios_por_rubro': {'vet': 5, 'petshop': 2},
    'comercios_por_estado': {'unverified': 6, 'verified': 1},
  });

  @override
  Future<Demanda> demanda({int dias = 30}) async => Demanda.fromJson({
    'por_rubro': [
      {
        'rubro': 'grooming',
        'busquedas': 85,
        'sin_resultados': 60,
        'lugares': 1,
      },
    ],
    'textos_sin_resultado': [
      {'texto': 'fisioterapia', 'veces': 7},
    ],
  });

  @override
  Future<List<ItemModeracion>> moderacion() async => cola;

  @override
  Future<void> moderar(
    String tipo,
    String id,
    String accion, {
    String? motivo,
  }) async {
    moderados.add((tipo, id, accion));
    cola = [];
  }

  @override
  Future<void> sancionar(
    String usuarioId,
    String tipo, {
    String? motivo,
    int? dias,
  }) async => sanciones.add((usuarioId, tipo, dias));

  @override
  Future<Map<String, Object?>> historial(String usuarioId) async => {
    'nombre': 'Estafador',
    'sanciones': <Object>[],
  };

  @override
  Future<void> levantarSancion(String sancionId) async {}

  @override
  Future<List<LugarAdmin>> lugares({String? buscar}) async => [
    ...lugaresExtra,
    LugarAdmin.fromJson({
      'id': 'b1',
      'business_type': 'vet',
      'kind': 'local',
      'name': 'Veterinaria Centro',
      'lat': -34.71,
      'lng': -55.95,
      'hours': <String, Object?>{},
      'verification': 'unverified',
      'renac_operator': false,
      'status': 'active',
      'aperturas_30d': 14,
      'favoritos': 3,
    }),
  ];

  @override
  Future<String> guardarLugar(Map<String, Object?> datos) async {
    lugaresGuardados.add(datos);
    return 'b1';
  }

  @override
  Future<List<Prospecto>> prospectos() async => prospectosGuardados;

  @override
  Future<void> guardarProspecto(Prospecto prospecto) async =>
      prospectosGuardados.add(prospecto);

  @override
  Future<List<EntradaAyuda>> ayuda() async => const [];

  final gruposGuardados = <Map<String, Object?>>[];

  @override
  Future<List<GrupoAdmin>> grupos() async => const [
    GrupoAdmin(id: 'g1', tipo: 'species', nombre: 'Perros', icono: '🐶'),
  ];

  @override
  Future<void> guardarGrupo(Map<String, Object?> datos) async =>
      gruposGuardados.add(datos);

  var pendientes = <PendienteComercio>[
    const PendienteComercio(
      tipo: 'claim',
      id: 'c1',
      negocioId: 'b2',
      negocio: 'Petshop del Centro',
      rubro: 'petshop',
      usuarioNombre: 'Beto',
      rut: '211111110019',
    ),
  ];
  final resueltos = <(String, String, bool)>[];
  final fundadores = <(String, DateTime?)>[];

  @override
  Future<List<PendienteComercio>> pendientesComercios() async => pendientes;

  @override
  Future<void> resolverComercio(
    String tipo,
    String id, {
    required bool aprobar,
    String? motivo,
  }) async {
    resueltos.add((tipo, id, aprobar));
    pendientes = [];
  }

  @override
  Future<void> socioFundador(String negocioId, DateTime? hasta) async =>
      fundadores.add((negocioId, hasta));

  final planes = <(String, String)>[];

  @override
  Future<void> planComercio(String negocioId, String plan) async =>
      planes.add((negocioId, plan));

  final propuestasRegistradas = <(String, String?)>[];
  final casosGuardados = <CasoExito>[];
  List<CasoExito> casosFijos = const [];

  @override
  Future<Propuesta> propuesta({String? rubro, String? negocioId}) async =>
      Propuesta({
        'rubro': rubro,
        'dias': 30,
        'zona': 'Pando y alrededores',
        'audiencia': {
          'usuarios': 120,
          'activos': null,
          'mascotas': [
            {'especie': 'Perro', 'cantidad': 80},
            {'especie': 'Gato', 'cantidad': null},
          ],
        },
        'demanda': {'busquedas': 85, 'sin_resultados': 40},
        'oferta': {'lugares': 1, 'verificados': 0, 'pagos': 0},
        'rubro_aperturas': 300,
        'negocio': negocioId == null
            ? null
            : {
                'nombre': 'Veterinaria Centro',
                'aperturas': 14,
                'contactos': 3,
                'favoritos': 2,
              },
        'casos': [
          {
            'comercio': 'Pet Shop Luna',
            'cita': 'Nos llaman más desde la app.',
            'numeros': 'De 40 a 140 aperturas por mes',
          },
        ],
      });

  @override
  Future<void> registrarPropuesta(String rubro, {String? negocioId}) async =>
      propuestasRegistradas.add((rubro, negocioId));

  @override
  Future<List<CasoExito>> casos() async => casosFijos;

  @override
  Future<void> guardarCaso(CasoExito caso) async => casosGuardados.add(caso);

  @override
  Future<void> borrarCaso(String id) async {}

  final planesCreados = <Map<String, Object?>>[];
  final pagos = <(String, double, String, int)>[];
  final bajas = <String>[];
  List<Suscripcion> suscripcionesFijas = [
    Suscripcion.fromJson({
      'id': 's1',
      'business_id': 'b1',
      'comercio': 'Veterinaria Centro',
      'rubro': 'vet',
      'plan': 'featured',
      'status': 'past_due',
      'period_end': '2026-10-20',
      'founder': false,
      'price': '600.00',
      'pagado': '600.00',
    }),
  ];

  @override
  Future<List<Suscripcion>> suscripciones() async => suscripcionesFijas;

  @override
  Future<Ingresos> ingresos() async => Ingresos.fromJson({
    'por_mes': [
      {'mes': '2026-09-01', 'plan': 'featured', 'total': 600, 'pagos': 1},
    ],
    'vigentes': {'featured': 1},
    'por_mes_esperado': 600,
  });

  @override
  Future<void> crearSuscripcion({
    required String negocioId,
    required String plan,
    required double precio,
    required DateTime hasta,
    bool fundador = false,
    String? notas,
  }) async => planesCreados.add({
    'negocio': negocioId,
    'plan': plan,
    'precio': precio,
    'hasta': hasta,
    'fundador': fundador,
  });

  @override
  Future<DateTime> registrarPago(
    String suscripcionId, {
    required double monto,
    required String metodo,
    String? referencia,
    int meses = 1,
  }) async {
    pagos.add((suscripcionId, monto, metodo, meses));
    return DateTime(2026, 11, 26);
  }

  @override
  Future<void> cancelarSuscripcion(
    String suscripcionId, {
    String? motivo,
  }) async => bajas.add(suscripcionId);

  final planesPersonas = <(String, String, double)>[];
  final pedidosDescartados = <String>[];

  @override
  Future<List<Suscripcion>> suscripcionesUsuarios() async => [
    Suscripcion.deUsuario({
      'id': 'su1',
      'user_id': 'u5',
      'email': 'lu@x.uy',
      'nombre': 'Lucía',
      'plan': 'family',
      'status': 'active',
      'period_end': '2026-11-26',
      'trial': true,
      'price': 0,
      'pagado': 0,
    }),
  ];

  @override
  Future<void> crearSuscripcionUsuario({
    required String correo,
    required String plan,
    required double precio,
    required DateTime hasta,
    String? notas,
  }) async {
    if (correo == 'nadie@x.uy') throw Exception('sin_cuenta');
    planesPersonas.add((correo, plan, precio));
  }

  @override
  Future<List<Map<String, Object?>>> pedidosPlanUsuario() async => [
    if (!pedidosDescartados.contains('pp1'))
      {'id': 'pp1', 'email': 'ana@x.uy', 'nombre': 'Ana', 'plan': 'pro'},
  ];

  @override
  Future<void> descartarPedidoPlan(String id) async =>
      pedidosDescartados.add(id);

  @override
  Future<EstadisticasNegocio> resultadosComercio(String negocioId) async =>
      EstadisticasNegocio.fromJson({
        'completo': true,
        'meses': [
          {
            'mes': '2026-10-01',
            'metricas': {
              'place_open': 340,
              'place_open_people': 280,
              'contactos': 52,
            },
          },
        ],
      });

  @override
  Future<List<Map<String, Object?>>> adopcionesEnRevision() async => const [];

  @override
  Future<void> revisarAdopcion(String id, {required bool aprobar}) async {}

  final estadosDenuncia = <(String, String)>[];

  @override
  Future<List<Map<String, Object?>>> denuncias() async => [
    if (estadosDenuncia.isEmpty)
      {
        'id': 'd1',
        'status': 'new',
        'description': 'Perro atado sin agua',
        'reporter': 'Beto',
        'photos': <String>[],
      },
  ];

  final noticiasGuardadas = <Map<String, Object?>>[];

  @override
  Future<List<Map<String, Object?>>> noticias() async => [
    {
      'id': 'n1',
      'title': 'Campaña de vacunación',
      'status': 'published',
      'sponsored': false,
      'species_ids': <int>[],
    },
    ...noticiasGuardadas,
  ];

  final bannersGuardados = <Map<String, Object?>>[];
  final bannersSubidos = <(int, String)>[];

  final espaciosPedidos = <int>[];

  @override
  Future<List<Map<String, Object?>>> espacios(int dias) async {
    espaciosPedidos.add(dias);
    return [
      {
        'tipo': 'promo',
        'id': 'p1',
        'titulo': '10% en alimento',
        'de_quien': 'Pet Shop Pando',
        'estado': 'active',
        'vistas': 200,
        'personas': 150,
        'toques': 12,
      },
      {
        'tipo': 'banner',
        'id': 'b1',
        'titulo': 'Jornada de adopción',
        'de_quien': null,
        'estado': 'published',
        'vistas': 0,
        'personas': 0,
        'toques': 0,
      },
    ];
  }

  @override
  Future<List<Map<String, Object?>>> banners() async => [
    {
      'id': 'b1',
      'title': 'Jornada de adopción',
      'image_path': 'banner-1.jpg',
      'status': 'published',
      'sort_order': 0,
      'sponsored': false,
      'starts_at': '2026-11-01T03:00:00+00:00',
    },
    ...bannersGuardados,
  ];

  @override
  Future<void> guardarBanner(Map<String, Object?> datos) async =>
      bannersGuardados.add({...datos, 'id': 'b${bannersGuardados.length + 2}'});

  @override
  Future<String> subirBanner(Uint8List bytes, String tipo) async {
    bannersSubidos.add((bytes.length, tipo));
    return 'banner-2.jpg';
  }

  @override
  String urlBanner(String ruta) => 'https://ejemplo.invalid/$ruta';

  final novedadesCambiadas = <(String, bool)>[];

  @override
  Future<List<Map<String, Object?>>> novedades() async => [
    {
      'id': 'c1',
      'kind': 'reencuentro',
      'name': 'Lola',
      'status': 'visible',
      'created_at': '2026-10-20T13:00:00+00:00',
    },
  ];

  @override
  Future<void> estadoNovedad(String id, {required bool visible}) async =>
      novedadesCambiadas.add((id, visible));

  @override
  Future<void> guardarNoticia(Map<String, Object?> datos) async =>
      noticiasGuardadas.add({
        ...datos,
        'id': 'n${noticiasGuardadas.length + 2}',
      });

  @override
  Future<void> estadoDenuncia(String id, String estado, {String? nota}) async =>
      estadosDenuncia.add((id, estado));

  @override
  Future<void> guardarAyuda(Map<String, Object?> datos) async =>
      ayudaGuardada.add(datos);

  final lotesCreados = <Map<String, Object?>>[];

  @override
  Future<List<Map<String, Object?>>> lotes() async => [
    for (final (i, l) in lotesCreados.indexed)
      {
        'id': 'l$i',
        'quantity': l['cantidad'],
        'producer': l['productor'],
        'unit_cost': l['costo'],
        'created_at': '2026-10-22T12:00:00Z',
        'activadas': 0,
        'escaneos': 0,
      },
  ];

  @override
  Future<String> crearLote({
    required int cantidad,
    String? productor,
    String? material,
    num? costo,
    String? nota,
  }) async {
    lotesCreados.add({
      'cantidad': cantidad,
      'productor': productor,
      'material': material,
      'costo': costo,
    });
    return 'l${lotesCreados.length - 1}';
  }

  @override
  Future<List<String>> codigosLote(String loteId) async => [
    'ABCD2345',
    'WXYZ6789',
  ];

  @override
  Future<List<Map<String, Object?>>> sinReclamar({int dias = 30}) async => [
    {
      'grupo': 'grooming:m1',
      'category': 'grooming',
      'lat': -34.72,
      'lng': -55.95,
      'marcas': 23,
      'aperturas': 140,
      'primera_marca': '2026-10-20T12:00:00Z',
      'google_link': null,
    },
  ];

  final pedidos = <Map<String, Object?>>[
    {
      'id': 'o1',
      'number': 7,
      'pet_name': 'Toby',
      'engraving': 'Toby',
      'business_name': 'Vete Pando',
      'status': 'new',
    },
    {
      'id': 'o2',
      'number': 8,
      'pet_name': 'Michi',
      'engraving': 'Michi',
      'business_name': 'Vete Pando',
      'status': 'delivered',
    },
  ];
  final enviados = <(String, String)>[];
  final cancelados = <String>[];

  @override
  Future<List<Map<String, Object?>>> pedidosChapita() async => pedidos;

  @override
  Future<void> enviarPedidoChapita(String pedidoId, String codigo) async {
    if (codigo != 'ABCD2345') throw Exception('chapita_no_disponible');
    enviados.add((pedidoId, codigo));
    pedidos[0] = {...pedidos[0], 'status': 'sent', 'code': codigo};
  }

  @override
  Future<void> cancelarPedidoChapita(String pedidoId, {String? motivo}) async =>
      cancelados.add(pedidoId);

  final lugaresExtra = <LugarAdmin>[];
  final sponsorsGuardados = <Map<String, Object?>>[];
  final logosSubidos = <(int, String)>[];
  final sponsorsDeLote = <(String, String?)>[];
  final stockAsignado = <(String, String, int)>[];
  final stockQuitado = <String>[];

  @override
  Future<List<Map<String, Object?>>> sponsors() async => [
    for (final (i, s) in sponsorsGuardados.indexed)
      {'id': 's$i', 'lotes': 0, 'chapitas': 0, ...s},
  ];

  @override
  Future<String> guardarSponsor(Map<String, Object?> datos) async {
    sponsorsGuardados.add(datos);
    return 's${sponsorsGuardados.length - 1}';
  }

  @override
  Future<String> subirLogo(Uint8List bytes, String tipo) async {
    logosSubidos.add((bytes.length, tipo));
    return 'logo-1.png';
  }

  @override
  Future<void> sponsorLote(String loteId, String? sponsorId) async =>
      sponsorsDeLote.add((loteId, sponsorId));

  @override
  Future<Map<String, Object?>> reporteSponsor(String sponsorId) async => {
    'name': 'Marca',
    'lotes': [
      {
        'id': 'l0',
        'created_at': '2026-10-22T12:00:00Z',
        'quantity': 50,
        'material': 'PLA',
        'activadas': 31,
        'escaneos': 12,
        'reencuentros': 2,
      },
    ],
  };

  @override
  Future<List<String>> asignarStock(
    String loteId,
    String negocioId,
    int cantidad,
  ) async {
    stockAsignado.add((loteId, negocioId, cantidad));
    return [for (var i = 0; i < cantidad; i++) 'STK0000$i'];
  }

  @override
  Future<void> quitarStock(String codigo) async => stockQuitado.add(codigo);

  final rolesPuestos = <(String, String)>[];
  final zonasGuardadas = <Map<String, Object?>>[];

  @override
  Future<List<Map<String, Object?>>> equipo() async => [
    {
      'user_id': 'u0',
      'email': 'admin@sosmascotas.uy',
      'rol': 'admin',
      'yo': true,
      'ultima_accion': '2026-10-26T12:00:00Z',
    },
    {
      'user_id': 'u7',
      'email': 'mod@sosmascotas.uy',
      'rol': 'moderator',
      'zonas': [
        for (final id in zonasDe['u7'] ?? const <int>[])
          {'id': id, 'name': id == 1 ? 'Pando' : 'Zona $id'},
      ],
    },
    for (final (correo, rol) in rolesPuestos)
      if (rol != 'user') {'user_id': correo, 'email': correo, 'rol': rol},
  ];

  /// Zonas de cada integrante (D110).
  final zonasDe = <String, List<int>>{};

  /// Lo que devuelve `misZonas()`: null, todas.
  List<String>? misZonasFalsas;

  @override
  Future<void> zonasIntegrante(String userId, List<int> zonas) async =>
      zonasDe[userId] = zonas;

  @override
  Future<List<String>?> misZonas() async => misZonasFalsas;

  @override
  Future<void> ponerRol(String correo, String rol) async {
    if (correo == 'nadie@x.uy') throw Exception('sin_cuenta');
    rolesPuestos.add((correo, rol));
  }

  @override
  Future<List<Map<String, Object?>>> zonas() async => [
    {
      'id': 1,
      'slug': 'pando',
      'name': 'Pando',
      'active': true,
      'usuarios': 120,
      'mascotas': 150,
      'lugares': 30,
      'sos_activos': 2,
    },
  ];

  @override
  Future<void> guardarZona(Map<String, Object?> datos) async {
    if ((datos['lat_min'] as num? ?? 0) >= (datos['lat_max'] as num? ?? 1)) {
      throw Exception('area_invalida');
    }
    zonasGuardadas.add(datos);
  }

  @override
  Future<List<Map<String, Object?>>> auditoria({
    int dias = 30,
    String? accion,
  }) async => [
    for (final a in [
      {
        'id': 1,
        'created_at': '2026-10-26T12:00:00Z',
        'action': 'poner_rol',
        'target_type': 'user',
        'target_id': 'u9',
        'detail': {'ahora': 'sales'},
        'quien': 'admin@sosmascotas.uy',
      },
      {
        'id': 2,
        'created_at': '2026-10-26T11:00:00Z',
        'action': 'moderar_aprobar',
        'quien': 'mod@sosmascotas.uy',
      },
    ])
      if (accion == null || a['action'] == accion) a,
  ];

  @override
  Future<List<Map<String, Object?>>> stock() async => [
    for (final (_, negocio, cantidad) in stockAsignado)
      {
        'business_id': negocio,
        'business_name': 'Vete Verificada',
        'recibidas': cantidad,
        'disponibles': cantidad,
        'activadas': 0,
      },
  ];
}

Widget _portal({
  required SesionFalsa sesion,
  required RepoFalso repo,
  List<(String, String)>? descargas,
  List<String>? enlaces,
}) => ProviderScope(
  overrides: [
    abrirEnlaceProvider.overrideWithValue((url) => enlaces?.add(url)),
    sesionProvider.overrideWithValue(sesion),
    adminRepositorioProvider.overrideWithValue(repo),
    urlPublicaProvider.overrideWithValue('https://web.ejemplo.uy/'),
    descargarTextoProvider.overrideWithValue(
      (nombre, contenido) => descargas?.add((nombre, contenido)),
    ),
    elegirImagenProvider.overrideWithValue(
      () async => (bytes: Uint8List(2048), tipo: 'image/png'),
    ),
    descargarHtmlProvider.overrideWithValue(
      (nombre, html) => descargas?.add((nombre, html)),
    ),
    hoyProvider.overrideWithValue(() => DateTime(2026, 10, 26)),
  ],
  child: const AdminApp(),
);

void _pantallaGrande(WidgetTester tester) {
  tester.view
    ..physicalSize = const Size(1400, 1000)
    ..devicePixelRatio = 1;
  addTearDown(tester.view.reset);
}

Future<void> _tocar(WidgetTester tester, Finder objetivo) async {
  await tester.pumpAndSettle();
  await tester.ensureVisible(objetivo);
  await tester.pumpAndSettle();
  await tester.tap(objetivo);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('ingresar con el código', (tester) async {
    _pantallaGrande(tester);
    final sesion = SesionFalsa();
    await tester.pumpWidget(_portal(sesion: sesion, repo: RepoFalso()));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'admin@sosmascotas.uy');
    await _tocar(tester, find.text('Enviarme el código'));
    expect(sesion.codigosPedidos, ['admin@sosmascotas.uy']);
    await tester.enterText(find.byType(TextField).last, '000000');
    await _tocar(tester, find.text('Entrar'));
    expect(find.textContaining('No se pudo'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '123456');
    await _tocar(tester, find.text('Entrar'));
    expect(find.text('Usuarios'), findsOneWidget);
  });

  testWidgets('sin rol admin no se ve nada', (tester) async {
    _pantallaGrande(tester);
    await tester.pumpWidget(
      _portal(
        sesion: SesionFalsa('ana@correo.com'),
        repo: RepoFalso(admin: false),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('no tiene permiso'), findsOneWidget);
    expect(find.text('Moderación'), findsNothing);
  });

  testWidgets('panel con los indicadores', (tester) async {
    _pantallaGrande(tester);
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: RepoFalso()),
    );
    await tester.pumpAndSettle();
    expect(find.text('120'), findsOneWidget);
    expect(find.text('2,5'), findsOneWidget);
    expect(find.text('Veterinaria: 5'), findsOneWidget);
    expect(find.text('Verificado: 1'), findsOneWidget);
    expect(find.text('Demanda sin cubrir'), findsOneWidget);
    expect(
      find.text('Peluquería: 85 búsquedas (60 sin resultados) · 1 en el mapa'),
      findsOneWidget,
    );
    expect(find.text('«fisioterapia»: 7'), findsOneWidget);
  });

  testWidgets('moderación: eliminar el mensaje y bloquear al autor', (
    tester,
  ) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: repo),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Moderación'));

    expect(find.textContaining('Transferime'), findsOneWidget);
    await _tocar(
      tester,
      find.widgetWithText(OutlinedButton, 'Bloquear 30 días'),
    );
    await tester.enterText(find.byType(TextField).last, 'Pedía plata');
    await _tocar(tester, find.text('Confirmar'));
    expect(repo.sanciones.single, ('u9', 'block', 30));

    await _tocar(tester, find.widgetWithText(FilledButton, 'Eliminar'));
    await _tocar(tester, find.text('Confirmar'));
    expect(repo.moderados.single, ('message', 'm1', 'eliminar'));
    expect(find.text('No hay nada para moderar.'), findsOneWidget);
  });

  testWidgets('lugares: verificar y marcar Operador RENAC', (tester) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: repo),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Lugares'));

    expect(find.textContaining('14 aperturas'), findsOneWidget);
    await _tocar(tester, find.text('Veterinaria Centro'));
    await _tocar(tester, find.text('Verificado ✔️'));
    await _tocar(tester, find.text('Operador RENAC (coloca microchip)'));
    await _tocar(tester, find.text('Guardar'));

    final guardado = repo.lugaresGuardados.single;
    expect(guardado['id'], 'b1');
    expect(guardado['verification'], 'verified');
    expect(guardado['renac_operator'], isTrue);
    expect(guardado['lat'], -34.71);
  });

  testWidgets('lugares: poner el plan Plus', (tester) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: repo),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Lugares'));
    await _tocar(tester, find.text('Veterinaria Centro'));
    await _tocar(tester, find.text('Plan…'));
    await _tocar(tester, find.text('Plus (módulos, como Socios)'));
    expect(repo.planes.single, ('b1', 'plus'));
  });

  testWidgets('lugares: resultados del comercio (2.3)', (tester) async {
    _pantallaGrande(tester);
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: RepoFalso()),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Lugares'));
    await _tocar(tester, find.text('Veterinaria Centro'));
    await _tocar(tester, find.text('Resultados'));
    expect(find.text('Resultados · Veterinaria Centro'), findsOneWidget);
    expect(find.text('2026-10'), findsOneWidget);
    expect(find.text('340'), findsOneWidget);
    expect(find.text('52'), findsOneWidget);
  });

  testWidgets('propuestas: por rubro, se ve el resumen y se descarga (2.4)', (
    tester,
  ) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    final descargas = <(String, String)>[];
    await tester.pumpWidget(
      _portal(
        sesion: SesionFalsa('admin@x.uy'),
        repo: repo,
        descargas: descargas,
      ),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Propuestas'));
    await _tocar(tester, find.text('Ver datos'));
    expect(find.text('Elegí un rubro o un comercio.'), findsOneWidget);

    await _tocar(tester, find.byType(DropdownButtonFormField<String>).first);
    await _tocar(tester, find.text('Peluquería').last);
    await _tocar(tester, find.text('Ver datos'));
    expect(
      find.textContaining(
        'Búsquedas del rubro (30 días): 85 (40 sin resultados)',
      ),
      findsOneWidget,
    );
    expect(find.textContaining('Casos de éxito del rubro: 1'), findsOneWidget);

    await _tocar(tester, find.text('Descargar para imprimir'));
    final (nombre, html) = descargas.single;
    expect(nombre, 'propuesta-peluqueria-2026-10-26.html');
    expect(html, contains('Huellitas para Peluquería'));
    expect(html, contains('85</b>búsquedas'));
    expect(repo.propuestasRegistradas.single, ('grooming', null));
  });

  testWidgets('casos de éxito: sin permiso no se publica', (tester) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: repo),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Propuestas'));
    await _tocar(tester, find.text('Nuevo caso'));
    await _tocar(tester, find.text('Guardar'));
    expect(find.textContaining('Faltan el comercio'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre'),
      'Pet Shop Luna',
    );
    await _tocar(tester, find.byType(DropdownButtonFormField<String>).last);
    await _tocar(tester, find.text('Petshop').last);
    await tester.enterText(
      find.widgetWithText(TextField, 'Lo que dijo'),
      'Desde que estamos en la app nos llaman más.',
    );
    // El interruptor de publicar está apagado hasta tener el permiso.
    final publicar = find.widgetWithText(
      SwitchListTile,
      'Publicado (se usa en las propuestas)',
    );
    expect(tester.widget<SwitchListTile>(publicar).onChanged, isNull);
    await _tocar(tester, find.text('Guardar'));
    final caso = repo.casosGuardados.single;
    expect(caso.comercio, 'Pet Shop Luna');
    expect(caso.rubro, 'petshop');
    expect(caso.permiso, isFalse);
    expect(caso.publicado, isFalse);
  });

  testWidgets('planes: ingresos, registrar un pago y dar de baja (2.2)', (
    tester,
  ) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: repo),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Planes'));
    expect(
      find.textContaining('Vigentes: Destacado 1 · Plus 0'),
      findsOneWidget,
    );
    expect(
      find.textContaining('9/2026 · Destacado: \$ 600 (1)'),
      findsOneWidget,
    );
    expect(find.textContaining('Destacado · Con atraso'), findsOneWidget);

    await _tocar(tester, find.text('Registrar pago').first);
    await _tocar(tester, find.text('Meses que paga'));
    await _tocar(tester, find.text('3').last);
    await _tocar(
      tester,
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Registrar pago'),
      ),
    );
    expect(repo.pagos.single, ('s1', 600.0, 'transfer', 3));
    expect(
      find.textContaining('queda pago hasta el 26/11/2026'),
      findsOneWidget,
    );

    await _tocar(tester, find.text('Dar de baja'));
    await _tocar(
      tester,
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Dar de baja'),
      ),
    );
    expect(repo.bajas.single, 's1');
  });

  testWidgets('planes: un plan nuevo pide comercio y fecha', (tester) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: repo),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Planes'));
    await _tocar(tester, find.text('Nuevo plan pago'));
    await _tocar(tester, find.text('Guardar'));
    expect(find.text('Elegí el comercio, el plan y la fecha.'), findsOneWidget);
    expect(repo.planesCreados, isEmpty);
  });

  testWidgets('planes de personas: pedidos, prueba y activar (2.1)', (
    tester,
  ) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: repo),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Planes'));
    await _tocar(tester, find.text('Personas'));
    expect(find.text('Lucía · lu@x.uy'), findsOneWidget);
    expect(find.textContaining('Prueba gratis'), findsOneWidget);
    expect(find.text('Ana pidió Pro'), findsOneWidget);

    await _tocar(tester, find.text('Activar'));
    final campos = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(campos.first).controller!.text, 'ana@x.uy');
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));
    expect(find.textContaining('Falta el correo'), findsOneWidget);
    await _tocar(
      tester,
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.textContaining('Vence el'),
      ),
    );
    await _tocar(tester, find.text('ACEPTAR'));
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));
    expect(repo.planesPersonas.single, ('ana@x.uy', 'pro', 0.0));

    await _tocar(tester, find.text('Descartar'));
    expect(repo.pedidosDescartados.single, 'pp1');
    expect(find.text('Ana pidió Pro'), findsNothing);
  });

  testWidgets('lugares: sin coordenadas no se guarda un local', (tester) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: repo),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Lugares'));
    await _tocar(tester, find.text('Nuevo lugar'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre'),
      'Peluquería Nueva',
    );
    await _tocar(tester, find.text('Guardar'));
    expect(repo.lugaresGuardados, isEmpty);
    expect(find.textContaining('datos inválidos'), findsOneWidget);
  });

  testWidgets('prospectos: cargar uno en el embudo', (tester) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: repo),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Prospectos'));
    expect(find.text('Todavía no hay prospectos.'), findsOneWidget);

    await _tocar(tester, find.text('Nuevo prospecto'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre'),
      'Peluquería Canina Pando',
    );
    await _tocar(tester, find.text('Guardar'));
    expect(repo.prospectosGuardados.single.nombre, 'Peluquería Canina Pando');
    expect(repo.prospectosGuardados.single.toJson()['stage'], 'prospect');
  });

  testWidgets('Ayuda: cargar un refugio con el enlace de adopciones', (
    tester,
  ) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: repo),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.byIcon(Icons.volunteer_activism_outlined));
    await _tocar(tester, find.text('Nueva entrada'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre'),
      'Refugio Patitas',
    );
    await tester.enterText(
      find.widgetWithText(
        TextField,
        'Enlace (https://…), por ejemplo, adopciones',
      ),
      'https://patitas.uy/adopciones',
    );
    await _tocar(tester, find.text('Guardar'));
    expect(repo.ayudaGuardada.single, containsPair('kind', 'refugio'));
    expect(
      repo.ayudaGuardada.single,
      containsPair('link', 'https://patitas.uy/adopciones'),
    );
  });

  testWidgets('grupos: crear un tema nuevo (3.4)', (tester) async {
    _pantallaGrande(tester);
    final repo = RepoFalso(rol: 'moderator');
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('mod@x.uy'), repo: repo),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.byIcon(Icons.forum_outlined));
    expect(find.text('Perros'), findsOneWidget);
    await _tocar(tester, find.text('Nuevo grupo'));
    await tester.enterText(
      find.widgetWithText(TextField, 'Nombre'),
      'Viajar con mascotas',
    );
    await _tocar(tester, find.text('Guardar'));
    expect(repo.gruposGuardados.single, {
      'kind': 'topic',
      'name': 'Viajar con mascotas',
      'description': '',
      'icon': '',
      'status': 'active',
    });
  });

  testWidgets('salir vuelve al ingreso', (tester) async {
    _pantallaGrande(tester);
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: RepoFalso()),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.byTooltip('Salir'));
    expect(find.text('Enviarme el código'), findsOneWidget);
  });

  testWidgets('comercios: aprobar un reclamo', (tester) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: repo),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Comercios'));
    expect(find.text('Reclamo de un lugar sin dueño'), findsOneWidget);
    expect(find.text('RUT: 211111110019'), findsOneWidget);
    await _tocar(tester, find.widgetWithText(FilledButton, 'Aprobar'));
    expect(repo.resueltos.single, ('claim', 'c1', true));
    expect(find.text('No hay reclamos ni pedidos pendientes.'), findsOneWidget);
  });

  testWidgets('denuncias: derivar una nueva', (tester) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: repo),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Denuncias'));
    expect(find.text('Perro atado sin agua'), findsOneWidget);
    await _tocar(tester, find.text('Derivada al INBA o la policía'));
    expect(repo.estadosDenuncia.single, ('d1', 'referred'));
  });

  testWidgets('banners: imagen, enlace https y orden', (tester) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: repo),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Noticias'));
    await tester.tap(find.widgetWithText(Tab, 'Banners'));
    await tester.pumpAndSettle();
    expect(find.text('Jornada de adopción'), findsOneWidget);
    expect(find.textContaining('Publicado · orden 0'), findsOneWidget);

    await tester.tap(find.text('Nuevo banner'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(
        TextField,
        'Título (también lo lee el lector de pantalla)',
      ),
      'Baño y corte',
    );
    await _tocar(tester, find.text('Guardar'));
    expect(find.text('Falta la imagen.'), findsWidgets);
    expect(repo.bannersGuardados, isEmpty);

    await _tocar(tester, find.text('Elegir imagen'));
    expect(find.text('Imagen lista'), findsOneWidget);
    await _tocar(tester, find.text('No hace nada'));
    await _tocar(tester, find.text('Abre un enlace').last);
    await tester.enterText(
      find.widgetWithText(TextField, 'Enlace (https://…)'),
      'http://x.uy',
    );
    await _tocar(tester, find.text('Guardar'));
    expect(
      find.text('Elegí la noticia o poné un enlace que empiece con https://.'),
      findsOneWidget,
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Enlace (https://…)'),
      'https://petpando.uy',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Orden (el más bajo va primero)'),
      '2',
    );
    await _tocar(tester, find.text('Guardar'));
    expect(repo.bannersSubidos.single, (2048, 'image/png'));
    final guardado = repo.bannersGuardados.single;
    expect(guardado['image_path'], 'banner-2.jpg');
    expect(guardado['link'], 'https://petpando.uy');
    expect(guardado['news_id'], isNull);
    expect(guardado['sort_order'], 2);
    expect(guardado['status'], 'draft');
  });

  testWidgets('noticias: una patrocinada necesita la marca', (tester) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: repo),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Noticias'));
    expect(find.text('Campaña de vacunación'), findsOneWidget);
    expect(find.textContaining('Todas las especies'), findsOneWidget);

    // Sin ensureVisible: movería las pestañas (TabBarView) y no el botón.
    await tester.tap(find.text('Nueva noticia'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.widgetWithText(TextField, 'Título'),
      'Alimento para cachorros',
    );
    await tester.enterText(
      find.widgetWithText(TextField, 'Texto'),
      'Una guía para elegir el alimento.',
    );
    await _tocar(tester, find.widgetWithText(FilterChip, 'Perro'));
    await _tocar(
      tester,
      find.text('Patrocinada (se ve "Promocionado · marca")'),
    );
    await _tocar(tester, find.text('Guardar'));
    expect(
      find.text('Una noticia patrocinada necesita la marca.'),
      findsOneWidget,
    );
    expect(repo.noticiasGuardadas, isEmpty);

    await tester.enterText(find.widgetWithText(TextField, 'Marca'), 'Perruna');
    await _tocar(tester, find.text('Guardar'));
    final guardada = repo.noticiasGuardadas.single;
    expect(guardada['sponsor_name'], 'Perruna');
    expect(guardada['species_ids'], [1]);
    expect(guardada['status'], 'draft');
  });

  testWidgets('comunidad: se puede ocultar una novedad', (tester) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: repo),
    );
    await tester.pumpAndSettle();
    await _tocar(tester, find.text('Noticias'));
    await _tocar(tester, find.text('Comunidad'));
    expect(find.text('Reencuentro: Lola'), findsOneWidget);
    await _tocar(tester, find.byType(Switch));
    expect(repo.novedadesCambiadas.single, ('c1', false));
  });

  test('el CSV de un lote lleva el código y el enlace de la página del QR', () {
    expect(
      csvDeLote(['ABCD2345'], 'https://sosmascotas.uy/'),
      'codigo,enlace\nABCD2345,https://sosmascotas.uy/m/ABCD2345',
    );
  });

  testWidgets('chapitas: crear un lote y descargar sus códigos', (
    tester,
  ) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    final descargas = <(String, String)>[];
    await tester.pumpWidget(
      _portal(
        sesion: SesionFalsa('admin@sosmascotas.uy'),
        repo: repo,
        descargas: descargas,
      ),
    );
    await _tocar(tester, find.text('Chapitas'));
    expect(find.textContaining('Todavía no hay lotes'), findsOneWidget);

    await _tocar(tester, find.text('Nuevo lote'));
    final campos = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(campos.at(0), '501');
    await _tocar(tester, find.text('Crear'));
    expect(repo.lotesCreados, isEmpty, reason: 'más de 500 no');

    await tester.enterText(campos.at(0), '30');
    await tester.enterText(campos.at(1), 'Impresiones 3D Pando');
    await tester.enterText(campos.at(3), '45,5');
    await _tocar(tester, find.text('Crear'));
    expect(repo.lotesCreados.single, {
      'cantidad': 30,
      'productor': 'Impresiones 3D Pando',
      'material': null,
      'costo': 45.5,
    });
    expect(
      find.text('30 chapitas · 0 activadas · 0 escaneos · 0 reencuentros'),
      findsOneWidget,
    );

    await _tocar(tester, find.text('Descargar CSV'));
    expect(descargas.single.$1, 'chapitas-2026-10-22-2.csv');
    expect(
      descargas.single.$2,
      'codigo,enlace\n'
      'ABCD2345,https://web.ejemplo.uy/m/ABCD2345\n'
      'WXYZ6789,https://web.ejemplo.uy/m/WXYZ6789',
    );
  });

  testWidgets('chapitas: mandar un pedido con un código libre', (tester) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@sosmascotas.uy'), repo: repo),
    );
    await _tocar(tester, find.text('Chapitas'));
    expect(find.text('N.º 7 · Toby · grabado «Toby»'), findsOneWidget);
    // Los entregados no se listan.
    expect(find.textContaining('N.º 8'), findsNothing);

    await _tocar(tester, find.widgetWithText(FilledButton, 'Enviar'));
    final campo = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(campo, 'ZZZZ2222');
    await _tocar(
      tester,
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Enviar'),
      ),
    );
    expect(find.textContaining('ya se usó'), findsOneWidget);

    await tester.enterText(campo, 'ABCD2345');
    await _tocar(
      tester,
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.widgetWithText(FilledButton, 'Enviar'),
      ),
    );
    expect(repo.enviados.single, ('o1', 'ABCD2345'));
    expect(find.textContaining('Enviado a la veterinaria'), findsOneWidget);
  });

  test('el reporte del sponsor como planilla, una fila por lote', () {
    expect(
      csvReporteSponsor({
        'lotes': [
          {
            'created_at': '2026-10-22T12:00:00Z',
            'quantity': 50,
            'material': 'PLA "mate"',
            'activadas': 31,
            'escaneos': 12,
            'reencuentros': 2,
          },
        ],
      }),
      'lote,chapitas,material,activadas,escaneos,reencuentros\n'
      '2026-10-22,50,"PLA ""mate""",31,12,2',
    );
  });

  testWidgets('chapitas: sponsor con logo, ponerlo en un lote y su reporte', (
    tester,
  ) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await repo.crearLote(cantidad: 50);
    final descargas = <(String, String)>[];
    await tester.pumpWidget(
      _portal(
        sesion: SesionFalsa('admin@sosmascotas.uy'),
        repo: repo,
        descargas: descargas,
      ),
    );
    await _tocar(tester, find.text('Chapitas'));
    expect(find.text('Todavía no hay sponsors.'), findsOneWidget);

    await _tocar(tester, find.text('Nuevo sponsor'));
    await _tocar(tester, find.text('Guardar'));
    expect(find.text('Falta el nombre.'), findsOneWidget);
    final campos = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(campos.at(0), 'Marca');
    await tester.enterText(campos.at(1), 'Contacto: Ana');
    await _tocar(tester, find.text('Elegir logo'));
    expect(find.text('Logo cargado'), findsOneWidget);
    await _tocar(tester, find.text('Guardar'));
    expect(repo.logosSubidos.single, (2048, 'image/png'));
    expect(repo.sponsorsGuardados.single, {
      'name': 'Marca',
      'notes': 'Contacto: Ana',
      'active': true,
      'logo_path': 'logo-1.png',
      'business_id': null,
    });
    expect(find.text('0 lotes · 0 chapitas'), findsOneWidget);

    await _tocar(tester, find.byType(PopupMenuButton<String>));
    await _tocar(tester, find.text('Sponsor del lote…'));
    await _tocar(tester, find.widgetWithText(SimpleDialogOption, 'Marca'));
    expect(repo.sponsorsDeLote.single, ('l0', 's0'));

    await _tocar(tester, find.text('Reporte'));
    expect(
      find.text(
        'Lote del 2026-10-22: 50 chapitas · 31 activadas · 12 escaneos · '
        '2 reencuentros',
      ),
      findsOneWidget,
    );
    await _tocar(tester, find.text('Descargar CSV').last);
    expect(descargas.single.$1, 'reporte-marca.csv');
  });

  testWidgets('chapitas: pasar al stock de una veterinaria verificada', (
    tester,
  ) async {
    _pantallaGrande(tester);
    final repo = RepoFalso()
      ..lugaresExtra.add(
        LugarAdmin.fromJson({
          'id': 'v9',
          'business_type': 'vet',
          'kind': 'local',
          'name': 'Vete Verificada',
          'lat': -34.71,
          'lng': -55.95,
          'hours': <String, Object?>{},
          'verification': 'verified',
          'renac_operator': false,
          'status': 'active',
        }),
      );
    await repo.crearLote(cantidad: 50);
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@sosmascotas.uy'), repo: repo),
    );
    await _tocar(tester, find.text('Chapitas'));
    expect(
      find.text('Ninguna veterinaria tiene chapitas todavía.'),
      findsOneWidget,
    );
    await _tocar(tester, find.byType(PopupMenuButton<String>));
    await _tocar(tester, find.text('Pasar a una veterinaria…'));
    // La que no está verificada no aparece.
    await _tocar(tester, find.byType(DropdownButtonFormField<String>));
    expect(find.text('Veterinaria Centro'), findsNothing);
    await _tocar(tester, find.text('Vete Verificada').last);
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      '3',
    );
    await _tocar(tester, find.text('Pasar'));
    expect(repo.stockAsignado.single, ('l0', 'v9', 3));
    expect(find.textContaining('STK00002'), findsOneWidget);
    await _tocar(tester, find.text('Cerrar'));
    expect(
      find.text('3 recibidas · 3 disponibles · 0 activadas'),
      findsOneWidget,
    );

    await _tocar(tester, find.text('Quitar una'));
    await tester.enterText(
      find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextField),
      ),
      'STK00001',
    );
    await _tocar(tester, find.text('Quitar'));
    expect(repo.stockQuitado.single, 'STK00001');
  });

  testWidgets('cada rol ve solo sus secciones', (tester) async {
    _pantallaGrande(tester);
    await tester.pumpWidget(
      _portal(
        sesion: SesionFalsa('mod@x.uy'),
        repo: RepoFalso(rol: 'moderator'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Moderación'), findsWidgets);
    expect(find.text('Denuncias'), findsOneWidget);
    expect(find.text('Panel'), findsNothing);
    expect(find.text('Lugares'), findsNothing);
    expect(find.text('Equipo'), findsNothing);

    await tester.pumpWidget(
      _portal(
        sesion: SesionFalsa('ventas@x.uy'),
        repo: RepoFalso(rol: 'sales'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Lugares'), findsWidgets);
    expect(find.text('Prospectos'), findsOneWidget);
    expect(find.text('Propuestas'), findsOneWidget);
    expect(find.text('Moderación'), findsNothing);
    expect(find.text('Planes'), findsNothing);
  });

  testWidgets('moderación y ventas ven el aviso de sus zonas', (tester) async {
    _pantallaGrande(tester);
    await tester.pumpWidget(
      _portal(
        sesion: SesionFalsa('mod@x.uy'),
        repo: RepoFalso(rol: 'moderator')..misZonasFalsas = const [],
      ),
    );
    await tester.pumpAndSettle();
    expect(
      find.textContaining('Todavía no tenés zonas asignadas'),
      findsOneWidget,
    );

    await tester.pumpWidget(
      _portal(
        sesion: SesionFalsa('ventas@x.uy'),
        repo: RepoFalso(rol: 'sales')..misZonasFalsas = const ['Pando'],
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Ves solo lo de tus zonas: Pando.'), findsOneWidget);

    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: RepoFalso()),
    );
    await tester.pumpAndSettle();
    expect(find.textContaining('tus zonas'), findsNothing);
  });

  testWidgets('equipo: asignar zonas a un integrante', (tester) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@sosmascotas.uy'), repo: repo),
    );
    await _tocar(tester, find.text('Equipo'));
    expect(find.textContaining('Sin zonas: no ve nada'), findsOneWidget);

    await _tocar(tester, find.byTooltip('Zonas de mod@sosmascotas.uy'));
    await _tocar(tester, find.widgetWithText(CheckboxListTile, 'Pando'));
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));
    expect(repo.zonasDe['u7'], [1]);
    expect(find.textContaining('Zonas: Pando'), findsOneWidget);
  });

  testWidgets('equipo: dar un rol por correo', (tester) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@sosmascotas.uy'), repo: repo),
    );
    await _tocar(tester, find.text('Equipo'));
    expect(find.text('admin@sosmascotas.uy (vos)'), findsOneWidget);

    await _tocar(tester, find.text('Sumar o cambiar rol'));
    final correo = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(correo, 'nadie@x.uy');
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));
    expect(
      find.textContaining('primero tiene que registrarse'),
      findsOneWidget,
    );

    await tester.enterText(correo, 'ana@x.uy');
    await _tocar(tester, find.byType(DropdownButtonFormField<String>));
    await _tocar(
      tester,
      find.text('Ventas (lugares, prospectos y propuestas)').last,
    );
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));
    expect(repo.rolesPuestos.single, ('ana@x.uy', 'sales'));
    expect(find.text('ana@x.uy'), findsOneWidget);
  });

  testWidgets('zonas: crear una con su rectángulo y la auditoría', (
    tester,
  ) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@sosmascotas.uy'), repo: repo),
    );
    await _tocar(tester, find.text('Zonas'));
    expect(
      find.text('120 usuarios · 150 mascotas · 30 lugares · 2 SOS activos'),
      findsOneWidget,
    );

    await _tocar(tester, find.text('Nueva zona'));
    final campos = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(TextField),
    );
    await tester.enterText(campos.at(0), 'las-piedras');
    await tester.enterText(campos.at(1), 'Las Piedras');
    await tester.enterText(campos.at(2), '-34,70');
    await tester.enterText(campos.at(3), '-34,75');
    await tester.enterText(campos.at(4), '-56,25');
    await tester.enterText(campos.at(5), '-56,18');
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));
    expect(find.textContaining('El rectángulo no es válido'), findsOneWidget);

    await tester.enterText(campos.at(2), '-34,75');
    await tester.enterText(campos.at(3), '-34,70');
    await _tocar(tester, find.widgetWithText(FilledButton, 'Guardar'));
    expect(repo.zonasGuardadas.single, {
      'slug': 'las-piedras',
      'name': 'Las Piedras',
      'lat_min': -34.75,
      'lat_max': -34.70,
      'lng_min': -56.25,
      'lng_max': -56.18,
    });

    await _tocar(tester, find.text('Auditoría'));
    expect(find.text('poner_rol · admin@sosmascotas.uy'), findsOneWidget);
    expect(find.text('moderar_aprobar · mod@sosmascotas.uy'), findsOneWidget);
  });

  testWidgets('lugares: los sin reclamar con su tracción', (tester) async {
    _pantallaGrande(tester);
    final enlaces = <String>[];
    await tester.pumpWidget(
      _portal(
        sesion: SesionFalsa('admin@x.uy'),
        repo: RepoFalso(),
        enlaces: enlaces,
      ),
    );
    await _tocar(tester, find.text('Lugares'));
    await _tocar(tester, find.text('Sin reclamar con tracción (1)'));
    expect(
      find.text(
        'Peluquería · marcado por 23 personas · 140 aperturas (30 días)',
      ),
      findsOneWidget,
    );
    await _tocar(tester, find.text('Ver en Google Maps'));
    expect(enlaces.single, contains('query=-34.72%2C-55.95'));
  });

  testWidgets('espacios: vistas y toques de promociones y banners (3.2)', (
    tester,
  ) async {
    _pantallaGrande(tester);
    final repo = RepoFalso();
    await tester.pumpWidget(
      _portal(sesion: SesionFalsa('admin@x.uy'), repo: repo),
    );
    await _tocar(tester, find.text('Espacios'));
    expect(find.text('10% en alimento'), findsOneWidget);
    expect(find.text('Pet Shop Pando'), findsOneWidget);
    expect(find.text('6.0 %'), findsOneWidget);
    expect(find.text('Jornada de adopción'), findsOneWidget);
    await _tocar(tester, find.text('90 días'));
    expect(repo.espaciosPedidos, [30, 90]);
  });
}
