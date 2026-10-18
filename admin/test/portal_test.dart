import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sosmascota_admin/src/app.dart';
import 'package:sosmascota_admin/src/modelos.dart';
import 'package:sosmascota_admin/src/repositorio.dart';
import 'package:sosmascota_admin/src/sesion.dart';

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

  @override
  Future<void> guardarAyuda(Map<String, Object?> datos) async =>
      ayudaGuardada.add(datos);
}

Widget _portal({required SesionFalsa sesion, required RepoFalso repo}) =>
    ProviderScope(
      overrides: [
        sesionProvider.overrideWithValue(sesion),
        adminRepositorioProvider.overrideWithValue(repo),
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
}
