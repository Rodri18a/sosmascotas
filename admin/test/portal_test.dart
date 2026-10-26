import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_admin/src/app.dart';
import 'package:sosmascota_admin/src/modelos.dart';
import 'package:sosmascota_admin/src/pantallas/chapitas.dart';
import 'package:sosmascota_admin/src/pantallas/lugares.dart';
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
  RepoFalso({this.admin = true});

  bool admin;
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
  Future<bool> esAdmin() async => admin;

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
    expect(find.text('30 chapitas · 0 activadas · 0 escaneos'), findsOneWidget);

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
}
