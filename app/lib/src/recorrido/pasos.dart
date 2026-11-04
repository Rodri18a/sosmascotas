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

  /// Los pasos de [pantalla]. Las pantallas de adentro tienen una
  /// explicación, a veces su acción principal, y el botón ? (D144).
  static List<PasoRecorrido> de(
    BuildContext context,
    PantallaRecorrido pantalla,
  ) {
    final t = context.t;
    return switch (pantalla) {
      PantallaRecorrido.inicio => inicio(context),
      PantallaRecorrido.sos => sos(context),
      PantallaRecorrido.mapa => mapa(context),
      PantallaRecorrido.mascotas => mascotas(context),
      PantallaRecorrido.urgencias => urgencias(context),
      PantallaRecorrido.negocio => negocio(context),
      PantallaRecorrido.ficha => [
        PasoRecorrido(titulo: t.recFichaTitulo, texto: t.recFichaTexto),
        _ayuda(t),
      ],
      PantallaRecorrido.chapitaQr => [
        PasoRecorrido(titulo: t.recChapitaQrTitulo, texto: t.recChapitaQrTexto),
        _ayuda(t),
      ],
      PantallaRecorrido.sosDetalle => [
        PasoRecorrido(
          titulo: t.recSosDetalleTitulo,
          texto: t.recSosDetalleTexto,
        ),
        _ayuda(t),
      ],
      PantallaRecorrido.preguntas => [
        PasoRecorrido(titulo: t.recPreguntasTitulo, texto: t.recPreguntasTexto),
        PasoRecorrido(
          marca: 'accion',
          titulo: t.recPreguntasAccionTitulo,
          texto: t.recPreguntasAccionTexto,
        ),
        _ayuda(t),
      ],
      PantallaRecorrido.grupos => [
        PasoRecorrido(titulo: t.recGruposTitulo, texto: t.recGruposTexto),
        _ayuda(t),
      ],
      PantallaRecorrido.grupo => [
        PasoRecorrido(titulo: t.recGrupoTitulo, texto: t.recGrupoTexto),
        PasoRecorrido(
          marca: 'accion',
          titulo: t.recGrupoAccionTitulo,
          texto: t.recGrupoAccionTexto,
        ),
        _ayuda(t),
      ],
      PantallaRecorrido.mensajes => [
        PasoRecorrido(titulo: t.recMensajesTitulo, texto: t.recMensajesTexto),
        _ayuda(t),
      ],
      PantallaRecorrido.avisos => [
        PasoRecorrido(titulo: t.recAvisosTitulo, texto: t.recAvisosTexto),
        _ayuda(t),
      ],
      PantallaRecorrido.adopcion => [
        PasoRecorrido(titulo: t.recAdopcionTitulo, texto: t.recAdopcionTexto),
        _ayuda(t),
      ],
      PantallaRecorrido.transito => [
        PasoRecorrido(titulo: t.recTransitoTitulo, texto: t.recTransitoTexto),
        _ayuda(t),
      ],
      PantallaRecorrido.turnos => [
        PasoRecorrido(titulo: t.recTurnosTitulo, texto: t.recTurnosTexto),
        _ayuda(t),
      ],
      PantallaRecorrido.pedidos => [
        PasoRecorrido(titulo: t.recPedidosTitulo, texto: t.recPedidosTexto),
        _ayuda(t),
      ],
      PantallaRecorrido.cuidados => [
        PasoRecorrido(titulo: t.recCuidadosTitulo, texto: t.recCuidadosTexto),
        _ayuda(t),
      ],
      PantallaRecorrido.perfil => [
        PasoRecorrido(titulo: t.recPerfilTitulo, texto: t.recPerfilTexto),
        _ayuda(t),
      ],
      PantallaRecorrido.hogar => [
        PasoRecorrido(titulo: t.recHogarTitulo, texto: t.recHogarTexto),
        _ayuda(t),
      ],
      PantallaRecorrido.ajustes => [
        PasoRecorrido(titulo: t.recAjustesTitulo, texto: t.recAjustesTexto),
        _ayuda(t),
      ],
      PantallaRecorrido.negocioAgenda => [
        PasoRecorrido(
          titulo: t.recNegocioAgendaTitulo,
          texto: t.recNegocioAgendaTexto,
        ),
        _ayuda(t),
      ],
      PantallaRecorrido.negocioCatalogo => [
        PasoRecorrido(
          titulo: t.recNegocioCatalogoTitulo,
          texto: t.recNegocioCatalogoTexto,
        ),
        _ayuda(t),
      ],
      PantallaRecorrido.negocioPedidos => [
        PasoRecorrido(
          titulo: t.recNegocioPedidosTitulo,
          texto: t.recNegocioPedidosTexto,
        ),
        _ayuda(t),
      ],
      PantallaRecorrido.negocioFicha => [
        PasoRecorrido(
          titulo: t.recNegocioFichaTitulo,
          texto: t.recNegocioFichaTexto,
        ),
        _ayuda(t),
      ],
      PantallaRecorrido.negocioEquipo => [
        PasoRecorrido(
          titulo: t.recNegocioEquipoTitulo,
          texto: t.recNegocioEquipoTexto,
        ),
        _ayuda(t),
      ],
    };
  }

  static PasoRecorrido _ayuda(AppLocalizations t) => PasoRecorrido(
    marca: 'ayuda',
    titulo: t.recAyudaTitulo,
    texto: t.recAyudaTexto,
  );
}
