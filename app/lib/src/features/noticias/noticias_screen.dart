import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/promociones_repositorio.dart';
import '../../comercios/textos_comercio.dart';
import '../../cuenta/con_cuenta.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../eventos/eventos_repositorio.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../mapa/mapa_vista.dart';
import '../../metricas/metricas.dart';
import '../../noticias/noticias_repositorio.dart';
import '../../recorrido/pasos.dart';
import '../../recorrido/recorrido.dart';
import '../../router.dart';
import '../../utiles/enlaces.dart';
import '../../widgets/boton_ayuda.dart';
import '../../widgets/ilustracion.dart';
import '../../widgets/volver.dart';
import '../adopcion/acceso_adopcion.dart';
import '../comunidad/comunidad_screen.dart';
import '../comunidad/preguntas.dart';
import '../eventos/eventos.dart';
import '../menu/menu_principal.dart';
import '../sos/sos_detalle_screen.dart';
import 'carrusel_banners.dart';
import 'saludo_inicio.dart';
import 'tarjeta_promocion.dart';

/// Inicio (D139): arriba, el carrusel de banners que maneja la
/// administración (D128; un banner puede abrir una noticia) y, abajo, la
/// Comunidad (D86): próximos eventos, el resumen de los últimos 30 días y lo
/// que pasa en la app (reencuentros, adopciones, lugares verificados, eventos
/// y las perdidas que se siguen buscando), sin filtros. A las novedades se
/// puede reaccionar (D87). Es la primera pestaña y la ve cualquiera;
/// reaccionar pide ingresar (D94).
class NoticiasScreen extends ConsumerStatefulWidget {
  const NoticiasScreen({super.key});

  @override
  ConsumerState<NoticiasScreen> createState() => _NoticiasScreenState();
}

class _NoticiasScreenState extends ConsumerState<NoticiasScreen> {
  @override
  void initState() {
    super.initState();
    // Los totales de reacciones se traen de a tanda, al llegar la lista.
    ref.listenManual(novedadesProvider, (_, s) {
      if (s.value case final lista?) {
        ref.read(reaccionesProvider.notifier).cargar([
          for (final n in lista)
            if (n.admiteReacciones) n.id,
        ]);
      }
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return ZonaRecorrido(
      pantalla: PantallaRecorrido.inicio,
      pasos: PasosRecorrido.inicio,
      child: Scaffold(
        drawer: const MenuPrincipal(),
        appBar: AppBar(
          leading: botonMenu,
          title: TituloPestana(t.noticiasTitulo),
          actions: accionesPestana(),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(reaccionesProvider)
              ..invalidate(bannersProvider)
              ..invalidate(promocionesCercaProvider)
              ..invalidate(novedadesProvider)
              ..invalidate(resumenComunidadProvider)
              ..invalidate(eventosCercanosProvider);
            await ref.read(novedadesProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: const [
              // «¡Hola!» y tus mascotas, o la bienvenida (D162).
              SaludoInicio(),
              // Banners del carrusel (D128).
              MarcaRecorrido('carrusel', child: CarruselBanners()),
              // Próximos eventos de la zona, arriba de las novedades (D94).
              Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: SeccionEventos(),
              ),
              MarcaRecorrido('secciones', child: _Comunidad()),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Promocionado · «marca»": siempre visible en las patrocinadas.
class EtiquetaPromocionado extends StatelessWidget {
  const EtiquetaPromocionado({required this.marca, super.key});

  final String? marca;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: tema.colorScheme.tertiaryContainer,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        context.t.noticiasPromocionado(marca ?? ''),
        style: tema.textTheme.labelSmall?.copyWith(
          color: tema.colorScheme.onTertiaryContainer,
        ),
      ),
    );
  }
}

class TarjetaNoticia extends ConsumerWidget {
  const TarjetaNoticia({required this.noticia, super.key});

  final Noticia noticia;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final n = noticia;
    final pie = [
      MaterialLocalizations.of(context).formatMediumDate(n.publicada),
      ?n.fuente,
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: InkWell(
        onTap: () => abrirNoticia(context, ref, n),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (n.patrocinada) ...[
                EtiquetaPromocionado(marca: n.marca),
                const SizedBox(height: 8),
              ],
              Text(n.titulo, style: tema.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(n.resumen),
              const SizedBox(height: 8),
              Text(pie, style: tema.textTheme.bodySmall),
              TotalesReacciones(id: n.id),
            ],
          ),
        ),
      ),
    );
  }
}

/// La noticia completa, con "Leer más" si tiene enlace.
Future<void> abrirNoticia(BuildContext context, WidgetRef ref, Noticia n) {
  ref
      .read(metricasProvider)
      .track(Eventos.newsOpen, props: {'patrocinada': n.patrocinada});
  // Se abre desde un banner: los totales de reacciones se traen acá.
  unawaited(ref.read(reaccionesProvider.notifier).cargar([n.id]));
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final t = context.t;
      final tema = Theme.of(context);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (n.patrocinada) ...[
                Align(
                  alignment: Alignment.centerLeft,
                  child: EtiquetaPromocionado(marca: n.marca),
                ),
                const SizedBox(height: 8),
              ],
              Text(n.titulo, style: tema.textTheme.titleLarge),
              const SizedBox(height: 4),
              Text(
                [
                  MaterialLocalizations.of(
                    context,
                  ).formatMediumDate(n.publicada),
                  ?n.fuente,
                ].join(' · '),
                style: tema.textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              Text(n.cuerpo),
              if (n.enlace case final enlace?) ...[
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () {
                    ref
                        .read(metricasProvider)
                        .track(
                          Eventos.newsLink,
                          props: {'patrocinada': n.patrocinada},
                        );
                    ref.read(abrirEnlaceProvider)(Uri.parse(enlace));
                  },
                  icon: const Icon(Icons.open_in_new_outlined),
                  label: Text(t.noticiasLeerMas),
                ),
              ],
              const SizedBox(height: 20),
              BarraReacciones(id: n.id),
            ],
          ),
        ),
      );
    },
  );
}

/// Sección Comunidad (D86): resumen de los últimos 30 días y novedades.
class _Comunidad extends ConsumerWidget {
  const _Comunidad();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final resumen = ref.watch(resumenComunidadProvider).value;
    final hayResumen =
        resumen != null &&
        (resumen.reencuentros > 0 || resumen.perdidasActivas > 0);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Preguntas y Grupos arriba del resumen (D141).
        // Preguntas de la comunidad (2.3, D134).
        if (ref.watch(funcionalidadActivaProvider(Funcionalidades.preguntas)))
          const TarjetaPreguntas(),
        // Grupos por raza y especie (3.4, D116).
        if (ref.watch(funcionalidadActivaProvider(Funcionalidades.grupos)))
          const TarjetaGrupos(),
        // Adopción y tránsito, fuera del menú (D154).
        const AccesoAdopcion(desde: 'inicio'),
        // Solo reencuentros y perdidas, uno al lado del otro (D141).
        if (hayResumen) _Resumen(resumen: resumen),
        // Solo las últimas 5, con título y «Ver todas» (D147).
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text(
            t.comunidadUltimasTitulo,
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ),
        const ListaNovedades(limite: NovedadesScreen.enInicio),
      ],
    );
  }
}

/// Novedades de la comunidad con promociones intercaladas. Con [limite],
/// solo las más recientes, una promoción después de la 3.ª y el botón
/// «Ver todas» si hay más (Inicio, D147); sin él, todas, con una promoción
/// cada 6 (D137).
class ListaNovedades extends ConsumerWidget {
  const ListaNovedades({this.limite, super.key});

  final int? limite;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final limite = this.limite;
    return switch (ref.watch(novedadesProvider)) {
      AsyncData(value: final todas) => () {
        if (todas.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(32),
            child: VacioIlustrado(Ilustracion.comunidad, t.comunidadVacio),
          );
        }
        final lista = limite == null ? todas : todas.take(limite).toList();
        final promociones =
            ref.watch(funcionalidadActivaProvider(Funcionalidades.promociones))
            ? ref.watch(promocionesCercaProvider).value ?? const <Promocion>[]
            : const <Promocion>[];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final x in intercalarPromociones(
              lista,
              promociones,
              cada: limite == null ? 6 : 3,
              maximo: limite == null ? 3 : 1,
            ))
              switch (x) {
                final Promocion p => TarjetaPromocion(
                  key: ValueKey('promo-c-${p.id}'),
                  promocion: p,
                ),
                final Novedad n => TarjetaNovedad(novedad: n),
                _ => const SizedBox.shrink(),
              },
            if (limite != null && todas.length > limite)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                child: OutlinedButton.icon(
                  onPressed: () {
                    ref.read(metricasProvider).track(Eventos.communitySeeAll);
                    context.push(Rutas.novedades);
                  },
                  icon: const Icon(Icons.list_alt_outlined),
                  label: Text(t.comunidadVerTodas),
                ),
              ),
          ],
        );
      }(),
      AsyncError() => Padding(
        padding: const EdgeInsets.all(32),
        child: Text(t.errorSinConexion, textAlign: TextAlign.center),
      ),
      _ => const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

/// Todas las novedades de la comunidad, desde «Ver todas» del Inicio (D147).
class NovedadesScreen extends ConsumerStatefulWidget {
  const NovedadesScreen({super.key});

  /// Cuántas se ven en el Inicio.
  static const enInicio = 5;

  @override
  ConsumerState<NovedadesScreen> createState() => _NovedadesScreenState();
}

class _NovedadesScreenState extends ConsumerState<NovedadesScreen> {
  @override
  void initState() {
    super.initState();
    // Si se entra por un enlace, los totales de reacciones no están cargados.
    ref.listenManual(novedadesProvider, (_, s) {
      if (s.value case final lista?) {
        ref.read(reaccionesProvider.notifier).cargar([
          for (final n in lista)
            if (n.admiteReacciones) n.id,
        ]);
      }
    }, fireImmediately: true);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: volverSiNoHayAtras(context),
      title: Text(context.t.comunidadUltimasTitulo),
    ),
    body: RefreshIndicator(
      onRefresh: () async {
        ref
          ..invalidate(reaccionesProvider)
          ..invalidate(promocionesCercaProvider)
          ..invalidate(novedadesProvider);
        await ref.read(novedadesProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: const [ListaNovedades()],
      ),
    ),
  );
}

/// «Últimos 30 días»: las que volvieron a casa a la izquierda y las que se
/// siguen buscando a la derecha, con el ícono y el número grandes (D141).
class _Resumen extends StatelessWidget {
  const _Resumen({required this.resumen});

  final ResumenComunidad resumen;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final color = tema.colorScheme.onPrimaryContainer;
    // Compacta (D170): ícono, número y texto en una línea por dato.
    Widget dato(IconData icono, int n, String texto) => Expanded(
      child: Semantics(
        container: true,
        label: '$n $texto',
        child: ExcludeSemantics(
          child: Row(
            children: [
              Icon(icono, size: 22, color: color),
              const SizedBox(width: 6),
              Text(
                '$n',
                style: tema.textTheme.titleLarge?.copyWith(color: color),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  texto,
                  style: tema.textTheme.bodySmall?.copyWith(color: color),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      color: tema.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.comunidadResumenTitulo,
              style: tema.textTheme.labelLarge?.copyWith(color: color),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                dato(
                  Icons.home_outlined,
                  resumen.reencuentros,
                  t.comunidadResumenVolvieron(resumen.reencuentros),
                ),
                const SizedBox(width: 12),
                dato(
                  Icons.search_outlined,
                  resumen.perdidasActivas,
                  t.comunidadResumenBuscando(resumen.perdidasActivas),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Bajada corta para la tarjeta del muro (D141): una línea, sin el
/// agradecimiento ni la invitación, que quedan en el detalle.
String bajadaBreve(BuildContext context, Novedad n) {
  final t = context.t;
  return switch (n.tipo) {
    TipoNovedad.reencuentro when n.eraPerdida =>
      n.cantidad == null ? '' : t.comunidadDiasPerdida(n.cantidad!),
    TipoNovedad.reencuentro || TipoNovedad.adopcion => '',
    TipoNovedad.perdida => t.comunidadPerdidaDias(n.cantidad ?? 0),
    _ => textosNovedad(context, n).$2,
  };
}

/// Título y bajada de una novedad, armados con los textos de la app.
(String, String) textosNovedad(BuildContext context, Novedad n) {
  final t = context.t;
  final nombre = n.nombre;
  return switch (n.tipo) {
    TipoNovedad.reencuentro when n.eraPerdida => (
      nombre == null
          ? t.comunidadVolvioACasaSinNombre
          : t.comunidadVolvioACasa(nombre),
      [
        if (n.cantidad case final dias?) t.comunidadDiasPerdida(dias),
        t.comunidadGracias,
      ].join(' '),
    ),
    TipoNovedad.reencuentro => (
      nombre == null
          ? t.comunidadVolvioConSuFamiliaSinNombre
          : t.comunidadVolvioConSuFamilia(nombre),
      t.comunidadGracias,
    ),
    TipoNovedad.adopcion => (
      nombre == null
          ? t.comunidadAdoptados(n.cantidad ?? 1)
          : t.comunidadAdoptado(nombre),
      t.comunidadAdopcionDetalle,
    ),
    TipoNovedad.comercio => (
      t.comunidadLugarNuevo(nombre ?? ''),
      switch (n.categoria) {
        final c? => textoCategoria(t, c),
        null => '',
      },
    ),
    TipoNovedad.evento => (
      t.comunidadEvento(nombre ?? ''),
      [
        if (n.tipoEvento case final e?) textoTipoEvento(t, e),
        if (n.desde case final d?)
          MaterialLocalizations.of(context).formatMediumDate(d),
      ].join(' · '),
    ),
    TipoNovedad.perdida => (
      nombre == null ? t.comunidadSeBuscaSinNombre : t.comunidadSeBusca(nombre),
      '${t.comunidadPerdidaDias(n.cantidad ?? 0)} ${t.comunidadPerdidaAyuda}',
    ),
  };
}

/// Pin de una novedad, con los colores e íconos del mapa (D168): perdida en
/// rojo y reencuentro en verde azulado con la huella, el lugar con el de su
/// rubro, el evento con el calendario. La adopción no está en el mapa: va con
/// el naranja de Ami.
AspectoPin aspectoNovedad(Novedad n) {
  if (n.tipo == TipoNovedad.adopcion) {
    const fondo = Color(0xFFE8923A);
    return AspectoPin(
      fondo: fondo,
      borde: bordePin,
      colorIcono: colorIconoSobre(fondo),
      icono: Icons.volunteer_activism,
      diametro: 26,
    );
  }
  final categoria = n.categoria;
  final tipo = switch (n.tipo) {
    TipoNovedad.perdida => TipoPin.perdido,
    TipoNovedad.reencuentro => TipoPin.encontrado,
    TipoNovedad.evento => TipoPin.evento,
    _ => switch (categoria) {
      Categoria.vet => TipoPin.veterinaria,
      Categoria.petFriendly => TipoPin.aceptaMascotas,
      _ => TipoPin.comercio,
    },
  };
  return aspectoDePin(
    Pin(id: n.id, tipo: tipo, punto: const Punto(0, 0), categoria: categoria),
  )!;
}

class TarjetaNovedad extends ConsumerWidget {
  const TarjetaNovedad({required this.novedad, super.key});

  final Novedad novedad;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tema = Theme.of(context);
    final n = novedad;
    final (titulo, _) = textosNovedad(context, n);
    final linea = [
      bajadaBreve(context, n),
      MaterialLocalizations.of(context).formatShortMonthDay(n.fecha),
    ].where((x) => x.isNotEmpty).join(' · ');
    final perdida = n.tipo == TipoNovedad.perdida;
    // La fecha y los días, sobre fondo rojo si se sigue buscando y verde
    // si volvió a casa (D167); lo demás, texto común.
    final fondoFecha = switch (n.tipo) {
      TipoNovedad.perdida => tema.colorScheme.error,
      TipoNovedad.reencuentro => context.marca.exito,
      _ => null,
    };
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: InkWell(
        // Una perdida abre su reporte (para avisar o "Seguirlo", D74); lo
        // demás, el detalle con las reacciones.
        onTap: switch (n.origenId) {
          // Encima de Noticias (la ruta /sos/:id está dentro de las pestañas
          // y empujarla desde acá duplica la barra): la flecha vuelve acá.
          final sos? when perdida => () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => SosDetalleScreen(sosId: sos),
            ),
          ),
          _ when perdida => null,
          _ => () => abrirNovedad(context, ref, n),
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              // El mismo pin que en el mapa (color e ícono), sin la foto: la
              // lista se lee igual que el mapa (D168).
              SizedBox(
                width: 40,
                child: Center(
                  child: MarcaPin(
                    aspectoNovedad(n),
                    tamanio: 32,
                    key: Key('novedad-pin-${n.tipo.name}'),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: tema.textTheme.titleSmall,
                    ),
                    if (fondoFecha == null)
                      Text(
                        linea,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: tema.textTheme.bodySmall,
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: DecoratedBox(
                          key: Key('novedad-fecha-${n.tipo.name}'),
                          decoration: BoxDecoration(
                            color: fondoFecha,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            child: Text(
                              linea,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: tema.textTheme.labelMedium?.copyWith(
                                color:
                                    ThemeData.estimateBrightnessForColor(
                                          fondoFecha,
                                        ) ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    if (n.admiteReacciones) TotalesReacciones(id: n.id),
                  ],
                ),
              ),
              if (perdida) const Icon(Icons.chevron_right_outlined),
            ],
          ),
        ),
      ),
    );
  }
}

/// Detalle de una novedad: la foto grande, el texto y las reacciones.
Future<void> abrirNovedad(BuildContext context, WidgetRef ref, Novedad n) {
  ref
      .read(metricasProvider)
      .track(Eventos.newsOpen, props: {'comunidad': n.tipo.name});
  final url = ref.read(noticiasRepositorioProvider).urlFoto(n.fotoPath);
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final tema = Theme.of(context);
      final (titulo, bajada) = textosNovedad(context, n);
      return SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (url != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AspectRatio(
                    aspectRatio: 4 / 3,
                    child: Image.network(
                      url,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              Text(titulo, style: tema.textTheme.titleLarge),
              if (bajada.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(bajada),
              ],
              const SizedBox(height: 4),
              Text(
                MaterialLocalizations.of(context).formatMediumDate(n.fecha),
                style: tema.textTheme.bodySmall,
              ),
              if (n.admiteReacciones) ...[
                const SizedBox(height: 20),
                BarraReacciones(id: n.id),
              ],
            ],
          ),
        ),
      );
    },
  );
}

String textoReaccion(AppLocalizations t, Reaccion r) => switch (r) {
  Reaccion.alegra => t.reaccionAlegra,
  Reaccion.festejo => t.reaccionFestejo,
  Reaccion.gracias => t.reaccionGracias,
};

/// Totales chicos para las tarjetas ("❤️ 3   🎉 1"); nada si no hay.
class TotalesReacciones extends ConsumerWidget {
  const TotalesReacciones({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ref.watch(reaccionesProvider.select((m) => m[id]));
    if (r == null || r.total == 0) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        [
          for (final x in Reaccion.values)
            if (r.cuantas(x) > 0) '${x.emoji} ${r.cuantas(x)}',
        ].join('   '),
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

/// Las reacciones para tocar (D87): una por persona; tocar la mía la quita.
/// Sin comentarios a propósito. Un visitante tiene que ingresar.
class BarraReacciones extends ConsumerWidget {
  const BarraReacciones({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final r =
        ref.watch(reaccionesProvider.select((m) => m[id])) ??
        const Reacciones();

    Future<void> tocar(Reaccion x) async {
      if (!ref.read(conectadoProvider)) {
        await abrirConCuenta(
          context,
          ref,
          destino: Rutas.noticias,
          motivo: t.reaccionesMotivoCuenta,
        );
        return;
      }
      final mensajes = ScaffoldMessenger.of(context);
      try {
        await ref.read(reaccionesProvider.notifier).tocar(id, x);
      } on Exception {
        mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(t.reaccionesTitulo, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final x in Reaccion.values)
              ChoiceChip(
                showCheckmark: false,
                label: Text(
                  [
                    '${x.emoji} ${textoReaccion(t, x)}',
                    if (r.cuantas(x) > 0) '${r.cuantas(x)}',
                  ].join(' · '),
                ),
                selected: r.mia == x,
                onSelected: (_) => tocar(x),
              ),
          ],
        ),
      ],
    );
  }
}
