import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../l10n/l10n.dart';
import '../funcionalidades/funcionalidades_activas.dart';
import '../mascotas/mascotas_repositorio.dart';
import '../utiles/enlaces.dart';
import 'avisador_otro.dart'
    if (dart.library.js_interop) 'avisador_web.dart'
    as plataforma;
import 'recordatorios_repositorio.dart';

/// Permiso del dispositivo para mostrar los avisos de los recordatorios.
enum PermisoAvisos { concedido, sinPedir, bloqueado, noDisponible }

/// Un aviso que el dispositivo tiene que mostrar en [cuando].
class AvisoProgramado {
  const AvisoProgramado({
    required this.id,
    required this.cuando,
    required this.titulo,
    required this.cuerpo,
    required this.ruta,
  });

  /// Único por recordatorio y toma: el mismo aviso no se muestra dos veces.
  final String id;
  final DateTime cuando;
  final String titulo;
  final String cuerpo;

  /// A dónde lleva al tocarlo.
  final String ruta;

  @override
  bool operator ==(Object other) =>
      other is AvisoProgramado &&
      other.id == id &&
      other.cuando == cuando &&
      other.titulo == titulo &&
      other.cuerpo == cuerpo &&
      other.ruta == ruta;

  @override
  int get hashCode => Object.hash(id, cuando, titulo, cuerpo, ruta);
}

/// Muestra los avisos de los recordatorios en el dispositivo (notificaciones
/// locales, sin servidor). Se reemplaza en las pruebas.
///
/// En la web (Fase 0/1, D67) solo suenan **con la app abierta** (aunque esté
/// en otra pestaña o minimizada): el navegador no deja programar avisos para
/// más tarde. En Android y iPhone (paso 1.1) suenan siempre.
abstract interface class AvisadorRecordatorios {
  Future<PermisoAvisos> permiso();

  Future<PermisoAvisos> pedirPermiso();

  /// Reemplaza todo lo programado por [avisos].
  void programar(List<AvisoProgramado> avisos);
}

class AvisosNoDisponibles implements AvisadorRecordatorios {
  const AvisosNoDisponibles();

  @override
  Future<PermisoAvisos> permiso() async => PermisoAvisos.noDisponible;

  @override
  Future<PermisoAvisos> pedirPermiso() async => PermisoAvisos.noDisponible;

  @override
  void programar(List<AvisoProgramado> avisos) {}
}

final avisadorRecordatoriosProvider = Provider<AvisadorRecordatorios>(
  (ref) => plataforma.crearAvisador(),
);

/// Cuánto hacia adelante se programan los avisos (se recalcula antes).
const ventanaAvisos = Duration(hours: 24);

/// Avisos de las próximas 24 h de todos mis recordatorios activos.
List<AvisoProgramado> avisosDe(
  List<Recordatorio> recordatorios,
  Map<String, String> nombresDeMascotas,
  DateTime ahora,
  AppLocalizations t,
) => [
  for (final r in recordatorios)
    for (final toma in r.tomasEntre(ahora, ahora.add(ventanaAvisos)))
      AvisoProgramado(
        id: '${r.id}@${toma.toIso8601String()}',
        cuando: toma,
        titulo: t.recordatorioAvisoTitulo(
          r.titulo,
          nombresDeMascotas[r.mascotaId] ?? '',
        ),
        cuerpo: r.dosis ?? t.recordatorioAvisoCuerpo,
        ruta: '/mascotas/${r.mascotaId}',
      ),
]..sort((a, b) => a.cuando.compareTo(b.cuando));

/// Mantiene programados los avisos de los recordatorios mientras la app está
/// abierta: al cambiar los recordatorios y cada hora. Lo escucha la raíz de
/// la app.
final programadorRecordatoriosProvider = Provider<void>((ref) {
  final avisador = ref.watch(avisadorRecordatoriosProvider);
  final activa = ref.watch(
    funcionalidadActivaProvider(Funcionalidades.recordatorios),
  );
  if (!activa) {
    avisador.programar(const []);
    return;
  }
  final recordatorios = ref.watch(misRecordatoriosProvider).value ?? const [];
  final mascotas = ref.watch(misMascotasProvider).value ?? const <Mascota>[];
  final nombres = {for (final m in mascotas) m.id: m.nombre};
  final reloj = ref.watch(relojProvider);
  final t = lookupAppLocalizations(const Locale('es'));

  void reprogramar() =>
      avisador.programar(avisosDe(recordatorios, nombres, reloj(), t));
  reprogramar();
  final cadaHora = Timer.periodic(
    const Duration(hours: 1),
    (_) => reprogramar(),
  );
  ref.onDispose(cadaHora.cancel);
});
