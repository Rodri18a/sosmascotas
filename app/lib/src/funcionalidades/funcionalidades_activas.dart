import 'dart:async';
import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota_core/sosmascota_core.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../config/supabase_providers.dart';
import '../config/version.dart';
import '../cuenta/servicio_cuenta.dart';
import '../metricas/metricas.dart';

/// Pregunta a la base qué funcionalidades están prendidas para quien usa la app
/// (D64, docs/15-funcionalidades-graduales.md §6). Se reemplaza en las pruebas.
abstract interface class FuncionalidadesRepositorio {
  Future<Set<String>> prendidas({
    required String anonId,
    required String plataforma,
    required String version,
  });
}

class SupabaseFuncionalidadesRepositorio implements FuncionalidadesRepositorio {
  SupabaseFuncionalidadesRepositorio(this._cliente);

  final SupabaseClient _cliente;

  @override
  Future<Set<String>> prendidas({
    required String anonId,
    required String plataforma,
    required String version,
  }) async {
    final respuesta = await _cliente.rpc<List<dynamic>>(
      'mis_funcionalidades',
      params: {
        'p_anon_id': anonId,
        'p_plataforma': plataforma,
        'p_version': version,
      },
    );
    return respuesta.cast<String>().toSet();
  }
}

/// Sin Supabase configurado (solo en desarrollo) no hay a quién preguntar.
class FuncionalidadesSinConfigurar implements FuncionalidadesRepositorio {
  const FuncionalidadesSinConfigurar();

  @override
  Future<Set<String>> prendidas({
    required String anonId,
    required String plataforma,
    required String version,
  }) async => Funcionalidades.prendidasPorDefecto;
}

final funcionalidadesRepositorioProvider = Provider<FuncionalidadesRepositorio>(
  (ref) {
    final cliente = ref.watch(supabaseClientProvider);
    return cliente == null
        ? const FuncionalidadesSinConfigurar()
        : SupabaseFuncionalidadesRepositorio(cliente);
  },
);

/// Lo último que respondió la base, para abrir sin conexión. Se guarda junto
/// con la cuenta a la que corresponde: otra cuenta (o un visitante) no lo usa.
abstract interface class CacheFuncionalidades {
  Future<Set<String>?> leer(String? usuarioId);
  Future<void> guardar(String? usuarioId, Set<String> prendidas);
}

class CacheFuncionalidadesLocal implements CacheFuncionalidades {
  const CacheFuncionalidadesLocal();

  static const _clave = 'funcionalidades.prendidas';

  @override
  Future<Set<String>?> leer(String? usuarioId) async {
    final texto = (await SharedPreferences.getInstance()).getString(_clave);
    if (texto == null) return null;
    final datos = jsonDecode(texto);
    if (datos is! Map || datos['usuario'] != usuarioId) return null;
    final claves = datos['claves'];
    return claves is List ? claves.whereType<String>().toSet() : null;
  }

  @override
  Future<void> guardar(String? usuarioId, Set<String> prendidas) async =>
      (await SharedPreferences.getInstance()).setString(
        _clave,
        jsonEncode({'usuario': usuarioId, 'claves': prendidas.toList()}),
      );
}

final cacheFuncionalidadesProvider = Provider<CacheFuncionalidades>(
  (ref) => const CacheFuncionalidadesLocal(),
);

/// Funcionalidades prendidas y si ya se sabe (de la base o de lo guardado).
/// Mientras no se sabe, solo están las [Funcionalidades.prendidasPorDefecto].
@immutable
class EstadoFuncionalidades {
  const EstadoFuncionalidades(this.prendidas, {this.conocidas = false});

  final Set<String> prendidas;

  /// `false` al abrir sin nada guardado, hasta que responde la base.
  final bool conocidas;

  bool activa(String clave) => prendidas.contains(clave);
}

/// Cada cuánto se vuelve a preguntar con la app abierta.
const refrescoFuncionalidades = Duration(hours: 3);

/// Al volver a la app se pregunta de nuevo si pasó al menos esto.
const refrescoAlVolver = Duration(minutes: 15);

final funcionalidadesProvider =
    NotifierProvider<FuncionalidadesActivas, EstadoFuncionalidades>(
      FuncionalidadesActivas.new,
    );

class FuncionalidadesActivas extends Notifier<EstadoFuncionalidades> {
  String? _usuario;
  DateTime? _ultimaRespuesta;

  @override
  EstadoFuncionalidades build() {
    // Al abrir, al iniciar sesión y al cerrarla.
    ref.listen(usuarioActualProvider, (_, usuario) {
      if (usuario.isLoading) return;
      unawaited(_cambioDeCuenta(usuario.value?.id));
    }, fireImmediately: true);

    final reloj = Timer.periodic(refrescoFuncionalidades, (_) => refrescar());
    final ciclo = AppLifecycleListener(
      onResume: () {
        final ultima = _ultimaRespuesta;
        if (ultima == null ||
            DateTime.now().difference(ultima) >= refrescoAlVolver) {
          unawaited(refrescar());
        }
      },
    );
    ref.onDispose(() {
      reloj.cancel();
      ciclo.dispose();
    });
    return const EstadoFuncionalidades(Funcionalidades.prendidasPorDefecto);
  }

  Future<void> _cambioDeCuenta(String? usuario) async {
    _usuario = usuario;
    _ultimaRespuesta = null;
    try {
      final guardadas = await ref
          .read(cacheFuncionalidadesProvider)
          .leer(usuario);
      if (_usuario == usuario && _ultimaRespuesta == null) {
        state = guardadas == null
            ? const EstadoFuncionalidades(Funcionalidades.prendidasPorDefecto)
            : EstadoFuncionalidades(guardadas, conocidas: true);
      }
    } on Object catch (e) {
      debugPrint('No se pudieron leer las funcionalidades guardadas: $e');
    }
    await refrescar();
  }

  /// Vuelve a preguntar a la base. Si no responde, se queda con lo que había.
  Future<void> refrescar() async {
    final usuario = _usuario;
    try {
      final metricas = ref.read(metricasProvider);
      final prendidas = await ref
          .read(funcionalidadesRepositorioProvider)
          .prendidas(
            anonId: metricas.anonId,
            plataforma: metricas.plataforma,
            version: versionApp,
          );
      if (usuario != _usuario) return; // cambió la cuenta mientras tanto
      _ultimaRespuesta = DateTime.now();
      state = EstadoFuncionalidades(prendidas, conocidas: true);
      await ref.read(cacheFuncionalidadesProvider).guardar(usuario, prendidas);
    } on Object catch (e) {
      debugPrint('No se pudieron consultar las funcionalidades: $e');
    }
  }
}

/// ¿Está prendida [clave] para quien usa la app?
final funcionalidadActivaProvider = Provider.family<bool, String>(
  (ref, clave) => ref.watch(funcionalidadesProvider).activa(clave),
);

/// Anota `feature_exposure` una vez por sesión, marca y variante, cuando la
/// persona llega a donde está (o estaría) la funcionalidad.
class Exposiciones {
  Exposiciones(this._metricas);

  final Metricas _metricas;
  final _anotadas = <String>{};

  void anotar(String clave, {required bool prendida}) {
    final variante = prendida ? 'prendida' : 'apagada';
    if (!_anotadas.add('$clave:$variante')) return;
    _metricas.track(
      Eventos.featureExposure,
      props: {'key': clave, 'variante': variante},
    );
  }
}

final exposicionesProvider = Provider<Exposiciones>(
  (ref) => Exposiciones(ref.watch(metricasProvider)),
);

/// Muestra [child] solo si la funcionalidad [clave] está prendida; si no,
/// [sinoMostrar]. Ejemplo:
/// `SiFuncionalidad(Funcionalidades.temasPro, child: TileTema())`.
class SiFuncionalidad extends ConsumerWidget {
  const SiFuncionalidad(
    this.clave, {
    required this.child,
    this.sinoMostrar = const SizedBox.shrink(),
    super.key,
  });

  final String clave;
  final Widget child;
  final Widget sinoMostrar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = ref.watch(funcionalidadesProvider);
    final prendida = estado.activa(clave);
    // Antes de saber qué le tocó, la variante no dice nada: no se anota.
    if (estado.conocidas) {
      ref.read(exposicionesProvider).anotar(clave, prendida: prendida);
    }
    return prendida ? child : sinoMostrar;
  }
}
