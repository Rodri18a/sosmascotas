import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../cuenta/perfil_repositorio.dart';
import '../funcionalidades/funcionalidades_activas.dart';
import '../metricas/metricas.dart';
import 'paleta.dart';

/// Dónde se guarda el tema elegido (en el dispositivo, D62).
abstract interface class AlmacenTema {
  Future<String?> leer();
  Future<void> guardar(String id);
}

class AlmacenTemaLocal implements AlmacenTema {
  const AlmacenTemaLocal();

  static const _clave = 'tema.paleta';

  @override
  Future<String?> leer() async =>
      (await SharedPreferences.getInstance()).getString(_clave);

  @override
  Future<void> guardar(String id) async =>
      (await SharedPreferences.getInstance()).setString(_clave, id);
}

final almacenTemaProvider = Provider<AlmacenTema>(
  (ref) => const AlmacenTemaLocal(),
);

/// Elegir otro tema es del plan Pro (también lo incluye Familia).
final tienePlanConTemasProvider = Provider<bool>((ref) {
  final plan = ref.watch(perfilProvider).value?.plan;
  return plan == Plan.pro || plan == Plan.family;
});

/// Además del plan, la funcionalidad `temas_pro` tiene que estar prendida
/// (D64): mientras no haya cobro está en beta, solo para invitados.
final puedeElegirTemaProvider = Provider<bool>(
  (ref) =>
      ref.watch(tienePlanConTemasProvider) &&
      ref.watch(funcionalidadActivaProvider(Funcionalidades.temasPro)),
);

/// Id del tema que la persona eligió en este dispositivo (Cielo si nunca eligió).
final temaElegidoProvider = NotifierProvider<TemaElegido, String>(
  TemaElegido.new,
);

class TemaElegido extends Notifier<String> {
  @override
  String build() {
    unawaited(_cargar());
    return Paleta.cielo.id;
  }

  Future<void> _cargar() async {
    try {
      final guardado = await ref.read(almacenTemaProvider).leer();
      if (guardado != null) state = Paleta.porId(guardado).id;
    } on Exception catch (e) {
      debugPrint('No se pudo leer el tema guardado: $e');
    }
  }

  Future<void> elegir(Paleta paleta) async {
    if (paleta.id == state) return;
    state = paleta.id;
    ref
        .read(metricasProvider)
        .track(Eventos.themeChange, props: {'theme': paleta.id});
    await ref.read(almacenTemaProvider).guardar(paleta.id);
  }
}

/// La paleta con la que se dibuja la app. Si el plan Pro vence (o se apaga la
/// funcionalidad), vuelve a Cielo sin borrar la elección guardada.
final paletaActivaProvider = Provider<Paleta>((ref) {
  if (!ref.watch(puedeElegirTemaProvider)) return Paleta.cielo;
  return Paleta.porId(ref.watch(temaElegidoProvider));
});

/// Descarga las tipografías de un tema Pro (Cielo ya viene con la app).
abstract interface class CargadorFuentes {
  Future<void> cargar(Paleta paleta);
}

/// En la web se descargan de `fuentes/` (mismo sitio que la app). Hasta que la
/// app nativa tenga de dónde bajarlas (Fase 1), ahí se usa la letra del sistema.
class CargadorFuentesWeb implements CargadorFuentes {
  final _cargadas = <String>{};

  @override
  Future<void> cargar(Paleta paleta) async {
    if (!kIsWeb) return;
    final porFamilia = <String, List<ArchivoFuente>>{};
    for (final a in paleta.fuentesADescargar) {
      if (_cargadas.contains(a.archivo)) continue;
      (porFamilia[a.familia] ??= []).add(a);
    }
    for (final MapEntry(key: familia, value: archivos) in porFamilia.entries) {
      final cargador = FontLoader(familia);
      for (final a in archivos) {
        cargador.addFont(_bajar(a.archivo));
      }
      try {
        await cargador.load();
        _cargadas.addAll(archivos.map((a) => a.archivo));
      } on Object catch (e) {
        // Sin la tipografía se ve con la letra por defecto: no es grave.
        debugPrint('No se pudo cargar la tipografía $familia: $e');
      }
    }
  }

  Future<ByteData> _bajar(String archivo) async {
    final respuesta = await http.get(Uri.base.resolve('/fuentes/$archivo'));
    if (respuesta.statusCode != 200) {
      throw Exception('HTTP ${respuesta.statusCode} al bajar $archivo');
    }
    return ByteData.sublistView(respuesta.bodyBytes);
  }
}

final cargadorFuentesProvider = Provider<CargadorFuentes>(
  (ref) => CargadorFuentesWeb(),
);

/// Cuando cambia el tema activo, baja sus tipografías (una sola vez cada una).
final fuentesDelTemaProvider = Provider<void>((ref) {
  final paleta = ref.watch(paletaActivaProvider);
  if (paleta.fuentesADescargar.isEmpty) return;
  unawaited(ref.read(cargadorFuentesProvider).cargar(paleta));
});
