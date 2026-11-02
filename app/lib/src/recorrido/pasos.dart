import 'package:flutter/widgets.dart';

import '../../l10n/l10n.dart';
import 'recorrido.dart';

/// Los pasos de cada recorrido (D130). Los que apuntan a algo que no está a la
/// vista (por ejemplo, Avisos para un visitante) se saltean solos.
abstract final class PasosRecorrido {
  static List<PasoRecorrido> inicio(BuildContext context) {
    final t = context.t;
    return [
      PasoRecorrido(titulo: t.recInicioTitulo, texto: t.recInicioTexto),
      PasoRecorrido(
        marca: 'menu',
        titulo: t.recMenuTitulo,
        texto: t.recMenuTexto,
      ),
      PasoRecorrido(
        marca: 'avisos',
        titulo: t.recAvisosTitulo,
        texto: t.recAvisosTexto,
      ),
      PasoRecorrido(
        marca: 'carrusel',
        titulo: t.recCarruselTitulo,
        texto: t.recCarruselTexto,
      ),
      PasoRecorrido(
        marca: 'secciones',
        titulo: t.recSeccionesTitulo,
        texto: t.recSeccionesTexto,
      ),
      PasoRecorrido(
        marca: 'barra',
        titulo: t.recBarraTitulo,
        texto: t.recBarraTexto,
      ),
      _ayuda(t),
    ];
  }

  static List<PasoRecorrido> sos(BuildContext context) {
    final t = context.t;
    return [
      PasoRecorrido(titulo: t.recSosTitulo, texto: t.recSosTexto),
      PasoRecorrido(
        marca: 'filtros',
        titulo: t.recSosFiltrosTitulo,
        texto: t.recSosFiltrosTexto,
      ),
      PasoRecorrido(
        marca: 'reportar',
        titulo: t.recSosReportarTitulo,
        texto: t.recSosReportarTexto,
      ),
      _ayuda(t),
    ];
  }

  static List<PasoRecorrido> mapa(BuildContext context) {
    final t = context.t;
    return [
      PasoRecorrido(titulo: t.recMapaTitulo, texto: t.recMapaTexto),
      PasoRecorrido(
        marca: 'vistas',
        titulo: t.recMapaVistasTitulo,
        texto: t.recMapaVistasTexto,
      ),
      PasoRecorrido(
        marca: 'filtros',
        titulo: t.recMapaFiltrosTitulo,
        texto: t.recMapaFiltrosTexto,
      ),
      PasoRecorrido(
        marca: 'buscar',
        titulo: t.recMapaBuscarTitulo,
        texto: t.recMapaBuscarTexto,
      ),
      PasoRecorrido(
        marca: 'marcar',
        titulo: t.recMapaMarcarTitulo,
        texto: t.recMapaMarcarTexto,
      ),
      _ayuda(t),
    ];
  }

  static List<PasoRecorrido> mascotas(BuildContext context) {
    final t = context.t;
    return [
      PasoRecorrido(titulo: t.recMascotasTitulo, texto: t.recMascotasTexto),
      PasoRecorrido(
        marca: 'lista',
        titulo: t.recMascotasListaTitulo,
        texto: t.recMascotasListaTexto,
      ),
      PasoRecorrido(
        marca: 'agregar',
        titulo: t.recMascotasAgregarTitulo,
        texto: t.recMascotasAgregarTexto,
      ),
      _ayuda(t),
    ];
  }

  static List<PasoRecorrido> urgencias(BuildContext context) {
    final t = context.t;
    return [
      PasoRecorrido(titulo: t.recUrgenciasTitulo, texto: t.recUrgenciasTexto),
      PasoRecorrido(
        marca: '911',
        titulo: t.recUrgencias911Titulo,
        texto: t.recUrgencias911Texto,
      ),
      PasoRecorrido(
        marca: 'guardia',
        titulo: t.recUrgenciasGuardiaTitulo,
        texto: t.recUrgenciasGuardiaTexto,
      ),
      _ayuda(t),
    ];
  }

  static List<PasoRecorrido> negocio(BuildContext context) {
    final t = context.t;
    return [
      PasoRecorrido(titulo: t.recNegocioTitulo, texto: t.recNegocioTexto),
      PasoRecorrido(
        marca: 'secciones',
        titulo: t.recNegocioSeccionesTitulo,
        texto: t.recNegocioSeccionesTexto,
      ),
      PasoRecorrido(
        marca: 'volver',
        titulo: t.recNegocioVolverTitulo,
        texto: t.recNegocioVolverTexto,
      ),
      _ayuda(t),
    ];
  }

  static PasoRecorrido _ayuda(AppLocalizations t) => PasoRecorrido(
    marca: 'ayuda',
    titulo: t.recAyudaTitulo,
    texto: t.recAyudaTexto,
  );
}
