import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/comercios_repositorio.dart';
import '../../comercios/negocios_repositorio.dart';
import '../../comercios/textos_comercio.dart';
import '../../config/env_provider.dart';
import '../../fotos/elegir_foto.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../tienda/tienda_repositorio.dart';
import '../../utiles/enlaces.dart';
import '../../veterinarias/veterinarias_repositorio.dart';
import '../../widgets/volver.dart';
import '../adopcion/apadrinamiento_screen.dart';
import '../adopcion/pack_screen.dart';
import '../adopcion/transito_screen.dart';
import '../agenda/agenda_negocio.dart';
import '../chapitas/pedido_chapita.dart';
import '../resenas/resenas.dart';
import '../tienda/pedidos.dart';
import 'descuentos_screen.dart';
import 'formulario_negocio.dart';

/// Alta de un negocio (1.3.3, opción C).
class AltaNegocioScreen extends ConsumerWidget {
  const AltaNegocioScreen({this.precarga, super.key});

  final PrecargaNegocio? precarga;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.negocioAltaTitulo),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(t.negocioAltaExplicacion),
          const SizedBox(height: 16),
          FormularioNegocio(
            textoBoton: t.negocioCrear,
            precarga: precarga,
            onGuardar: (datos) async {
              await ref.read(negociosRepositorioProvider).alta(datos);
              ref
                ..read(metricasProvider).track(
                  Eventos.businessCreate,
                  props: {
                    'tipo': datos['business_type'],
                    'modalidad': datos['kind'],
                  },
                )
                ..invalidate(misNegociosProvider);
              if (!context.mounted) return;
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(t.negocioCreado)));
              context.go(Rutas.negocio);
            },
          ),
        ],
      ),
    );
  }
}

enum _Seccion { panel, agenda, catalogo, pedidos, negocio }

/// Modo comercio (1.3.5): barra Panel · Agenda · Catálogo · Pedidos · Negocio,
/// cabecera con nombre, tipo, plan e insignia, y vuelta al modo dueño.
class NegocioScreen extends ConsumerStatefulWidget {
  const NegocioScreen({this.seccion, super.key});

  /// Sección con la que abre (`pedidos` desde la push de un pedido, D100).
  final String? seccion;

  @override
  ConsumerState<NegocioScreen> createState() => _NegocioScreenState();
}

class _NegocioScreenState extends ConsumerState<NegocioScreen> {
  late var _seccion = _leer(widget.seccion) ?? _Seccion.panel;
  String? _elegido;

  static _Seccion? _leer(String? seccion) =>
      _Seccion.values.asNameMap()[seccion];

  @override
  void didUpdateWidget(NegocioScreen anterior) {
    super.didUpdateWidget(anterior);
    // Otra push con la pantalla ya abierta.
    if (widget.seccion != anterior.seccion) {
      _seccion = _leer(widget.seccion) ?? _seccion;
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return switch (ref.watch(misNegociosProvider)) {
      AsyncData(value: final lista) when lista.isEmpty =>
        const AltaNegocioScreen(),
      AsyncData(value: final lista) => () {
        final negocio =
            lista.where((n) => n.id == _elegido).firstOrNull ?? lista.first;
        return Scaffold(
          appBar: AppBar(
            leading: volverSiNoHayAtras(context),
            title: Text(t.modoComercio),
            actions: [
              if (lista.length > 1)
                PopupMenuButton<String>(
                  icon: const Icon(Icons.swap_horiz),
                  onSelected: (id) => setState(() => _elegido = id),
                  itemBuilder: (_) => [
                    for (final n in lista)
                      PopupMenuItem(
                        value: n.id,
                        child: Text(n.comercio.nombre),
                      ),
                  ],
                ),
              TextButton.icon(
                onPressed: () => context.go(Rutas.mapa),
                icon: const Icon(Icons.pets),
                label: Text(t.volverModoDueno),
              ),
            ],
          ),
          body: Column(
            children: [
              _Cabecera(negocio: negocio),
              const Divider(height: 1),
              Expanded(
                child: switch (_seccion) {
                  _Seccion.panel => _Panel(negocio: negocio),
                  _Seccion.agenda => _Agenda(negocio: negocio),
                  _Seccion.catalogo => _Tienda(negocio: negocio),
                  _Seccion.pedidos => _Tienda(negocio: negocio, pedidos: true),
                  _Seccion.negocio => _Ficha(negocio: negocio),
                },
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _seccion.index,
            onDestinationSelected: (i) =>
                setState(() => _seccion = _Seccion.values[i]),
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.insights_outlined),
                label: t.negocioPanel,
              ),
              NavigationDestination(
                icon: const Icon(Icons.event_outlined),
                label: t.negocioAgenda,
              ),
              NavigationDestination(
                icon: const Icon(Icons.inventory_2_outlined),
                label: t.negocioCatalogo,
              ),
              NavigationDestination(
                icon: const Icon(Icons.receipt_long_outlined),
                label: t.negocioPedidos,
              ),
              NavigationDestination(
                icon: const Icon(Icons.storefront_outlined),
                label: t.negocioFicha,
              ),
            ],
          ),
        );
      }(),
      AsyncLoading() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      _ => Scaffold(
        appBar: AppBar(leading: volverSiNoHayAtras(context)),
        body: Center(child: Text(t.errorSinConexion)),
      ),
    };
  }
}

String textoPlan(AppLocalizations t, PlanComercio p) => switch (p) {
  PlanComercio.basic => t.planBasico,
  PlanComercio.featured => t.planDestacado,
  PlanComercio.plus => t.planPlus,
};

String textoVerificacion(AppLocalizations t, Verificacion v) => switch (v) {
  Verificacion.unverified => t.verifNo,
  Verificacion.pending => t.verifPendiente,
  Verificacion.verified => t.verifSi,
};

class _Cabecera extends StatelessWidget {
  const _Cabecera({required this.negocio});

  final MiNegocio negocio;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final c = negocio.comercio;
    return ListTile(
      title: Text(c.nombre, style: tema.textTheme.titleLarge),
      subtitle: Text(
        [
          textoCategoria(t, c.categoria),
          textoPlan(t, c.plan),
          textoVerificacion(t, negocio.verificacion),
          if (c.operadorRenac) t.comercioRenac,
          if (negocio.fundadorHasta case final f?)
            t.socioFundadorHasta(
              MaterialLocalizations.of(context).formatMediumDate(f),
            ),
        ].join(' · '),
      ),
    );
  }
}

/// Panel básico con los contadores de `events` (1.3.6).
class _Panel extends ConsumerWidget {
  const _Panel({required this.negocio});

  final MiNegocio negocio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    return switch (ref.watch(panelNegocioProvider(negocio.id))) {
      AsyncData(value: final p) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Plan, vencimiento y pagos (2.2, D103).
          if (ref.watch(funcionalidadActivaProvider(Funcionalidades.planes)))
            Card(
              child: ListTile(
                leading: const Icon(Icons.workspace_premium_outlined),
                title: Text(
                  '${t.planTitulo}: ${textoPlan(t, negocio.comercio.plan)}',
                ),
                subtitle: Text(t.planAbrirAyuda),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Rutas.planNegocio(negocio.id)),
              ),
            ),
          // Estadísticas mes a mes y reporte mensual (2.3, D101).
          if (ref.watch(
            funcionalidadActivaProvider(Funcionalidades.estadisticas),
          ))
            Card(
              child: ListTile(
                leading: const Icon(Icons.bar_chart),
                title: Text(t.estadisticasAbrir),
                subtitle: Text(t.estadisticasAbrirAyuda),
                trailing: const Icon(Icons.chevron_right),
                onTap: () =>
                    context.push(Rutas.estadisticasNegocio(negocio.id)),
              ),
            ),
          Text(t.panelUltimos30, style: tema.textTheme.titleMedium),
          const SizedBox(height: 8),
          Card(
            child: ListTile(
              leading: const Icon(Icons.visibility_outlined),
              title: Text(p.entero('aperturas').toString()),
              subtitle: Text(
                '${t.panelAperturas} · ${t.panelAntes(p.entero('aperturas_antes'))}',
              ),
            ),
          ),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.panelContactos, style: tema.textTheme.titleSmall),
                  if (p.clics.isEmpty) Text(t.panelSinContactos),
                  for (final MapEntry(:key, :value) in p.clics.entries)
                    Text(
                      '${switch (key) {
                        'llamar' => t.clicLlamar,
                        'whatsapp' => t.clicWhatsapp,
                        'como_llegar' => t.clicComoLlegar,
                        'web' => t.clicWeb,
                        'instagram' => t.clicInstagram,
                        _ => key,
                      }}: $value',
                    ),
                ],
              ),
            ),
          ),
          for (final (icono, clave, texto) in [
            (Icons.chat_bubble_outline, 'chats', t.panelChats),
            (Icons.favorite_border, 'favoritos', t.panelFavoritos),
            (Icons.where_to_vote_outlined, 'visitas', t.panelVisitas),
            if (negocio.comercio.categoria == Categoria.vet)
              (Icons.verified_outlined, 'socios', t.panelSocios),
          ])
            Card(
              child: ListTile(
                leading: Icon(icono),
                title: Text(p.entero(clave).toString()),
                subtitle: Text(texto),
              ),
            ),
          // Socios y "Busco veterinaria" (2.6, D81).
          if (negocio.comercio.categoria == Categoria.vet &&
              ref.watch(
                funcionalidadActivaProvider(Funcionalidades.veterinarias),
              ))
            Card(
              child: ListTile(
                leading: const Icon(Icons.groups_outlined),
                title: Text(t.sociosAbrir),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push(Rutas.sociosNegocio(negocio.id)),
              ),
            ),
          // Punto de retiro de chapitas (1.8b.4, D98).
          if (negocio.comercio.categoria == Categoria.vet &&
              ref.watch(
                funcionalidadActivaProvider(Funcionalidades.pedidoChapitas),
              ))
            TarjetaRetiroChapitas(negocio: negocio),
          // Hogares de tránsito (3.4b, D106): solo refugios verificados.
          if (negocio.comercio.categoria == Categoria.shelter &&
              negocio.verificacion == Verificacion.verified &&
              ref.watch(funcionalidadActivaProvider(Funcionalidades.adopcion)))
            TarjetaTransitoRefugio(negocioId: negocio.id),
          // Pack adopción (3.4b, D107): gratis, para rubros verificados.
          if (const {
                Categoria.vet,
                Categoria.petshop,
                Categoria.agro,
                Categoria.grooming,
              }.contains(negocio.comercio.categoria) &&
              negocio.verificacion == Verificacion.verified &&
              ref.watch(funcionalidadActivaProvider(Funcionalidades.adopcion)))
            TarjetaPackNegocio(negocioId: negocio.id),
          // Descuentos para Pro (2.11, D113): verificados, menos refugios.
          if (negocio.verificacion == Verificacion.verified &&
              negocio.comercio.categoria != Categoria.shelter &&
              ref.watch(
                funcionalidadActivaProvider(Funcionalidades.planesUsuario),
              ))
            TarjetaDescuentosNegocio(negocioId: negocio.id),
          // Apadrinamiento (3.4b, D108): comercios y refugios verificados.
          if (negocio.verificacion == Verificacion.verified &&
              ref.watch(funcionalidadActivaProvider(Funcionalidades.adopcion)))
            TarjetaApadrinar(
              negocioId: negocio.id,
              esRefugio: negocio.comercio.categoria == Categoria.shelter,
            ),
          // Reputación y respuestas (1.7): el comercio responde una vez.
          if (ref.watch(funcionalidadActivaProvider(Funcionalidades.resenas)))
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      t.panelSinResponder(p.entero('sin_responder')),
                      style: tema.textTheme.bodySmall,
                    ),
                    SeccionResenas(comercioId: negocio.id, comoComercio: true),
                  ],
                ),
              ),
            ),
        ],
      ),
      AsyncLoading() => const Center(child: CircularProgressIndicator()),
      _ => Center(child: Text(t.errorSinConexion)),
    };
  }
}

/// Agenda, catálogo y pedidos: "No aplica" si el tipo no lo admite; si no,
/// llegan con el plan Plus (Fase 3).
class _Modulo extends StatelessWidget {
  const _Modulo({required this.negocio, required this.modulo});

  final MiNegocio negocio;
  final Modulo modulo;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final c = negocio.comercio;
    final admitido = moduloAdmitido(c.categoria, c.modalidad, modulo);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          admitido ? t.moduloSoloPlus : t.moduloNoAplica,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Agenda de turnos (3.1, D104), detrás de `agenda`: con plan Plus y si el
/// tipo lo admite; si no, el aviso de [_Modulo].
class _Agenda extends ConsumerWidget {
  const _Agenda({required this.negocio});

  final MiNegocio negocio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = negocio.comercio;
    if (!ref.watch(funcionalidadActivaProvider(Funcionalidades.agenda)) ||
        c.plan != PlanComercio.plus ||
        !moduloAdmitido(c.categoria, c.modalidad, Modulo.agenda)) {
      return _Modulo(negocio: negocio, modulo: Modulo.agenda);
    }
    return AgendaNegocio(negocioId: negocio.id);
  }
}

/// Catálogo y pedidos (2.5 y 3.2, D85), detrás de `catalogo`: con plan Plus
/// y si el tipo lo admite; si no, el aviso de [_Modulo].
class _Tienda extends ConsumerWidget {
  const _Tienda({required this.negocio, this.pedidos = false});

  final MiNegocio negocio;
  final bool pedidos;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = negocio.comercio;
    if (!ref.watch(funcionalidadActivaProvider(Funcionalidades.catalogo)) ||
        c.plan != PlanComercio.plus ||
        !moduloAdmitido(c.categoria, c.modalidad, Modulo.catalogo)) {
      return _Modulo(negocio: negocio, modulo: Modulo.catalogo);
    }
    if (pedidos) return PedidosNegocio(negocioId: negocio.id);
    final prendido =
        ref
            .watch(modulosPrendidosProvider(negocio.id))
            .value
            ?.contains(Modulo.catalogo) ??
        false;
    return CatalogoNegocio(
      negocioId: negocio.id,
      prendido: prendido,
      onPrender: (si) async {
        final mensajes = ScaffoldMessenger.of(context);
        final t = context.t;
        try {
          await ref
              .read(veterinariasRepositorioProvider)
              .prenderModulo(negocio.id, Modulo.catalogo, si);
          ref.read(metricasProvider).track(Eventos.moduleToggle);
        } on Object {
          mensajes.showSnackBar(SnackBar(content: Text(t.errorDesconocido)));
        }
        ref
          ..invalidate(modulosPrendidosProvider(negocio.id))
          ..invalidate(catalogoDeProvider(negocio.id));
      },
    );
  }
}

/// "Negocio": editar la ficha, fotos e insignias.
class _Ficha extends ConsumerWidget {
  const _Ficha({required this.negocio});

  final MiNegocio negocio;

  String _urlPagina(WidgetRef ref) =>
      urlPaginaComercio(negocio.id, base: ref.read(appEnvProvider).urlPublica);

  Future<void> _pedirVerificacion(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    final rut = TextEditingController(text: negocio.rut);
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.negocioPedirVerificacion),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.negocioPedirVerificacionTexto),
            TextField(
              controller: rut,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: t.reclamarRut),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.reclamarEnviar),
          ),
        ],
      ),
    );
    if (!(ok ?? false) || !context.mounted) return;
    final mensajes = ScaffoldMessenger.of(context);
    if (!rutValido(rut.text)) {
      mensajes.showSnackBar(SnackBar(content: Text(t.reclamarRutInvalido)));
      return;
    }
    try {
      await ref
          .read(negociosRepositorioProvider)
          .pedirVerificacion(negocio.id, rut.text);
      ref.read(metricasProvider).track(Eventos.verificationRequest);
      mensajes.showSnackBar(
        SnackBar(content: Text(t.negocioVerificacionPedida)),
      );
    } on Exception {
      mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
    }
    ref.invalidate(misNegociosProvider);
  }

  Future<void> _agregarFoto(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    final original = await elegirFoto(context, ref);
    if (original == null) return;
    final preparada = prepararFoto(original);
    if (preparada == null) return;
    try {
      await ref
          .read(negociosRepositorioProvider)
          .subirFoto(negocio.id, preparada);
    } on Exception {
      mensajes.showSnackBar(SnackBar(content: Text(t.negocioFotosTope)));
    }
    ref.invalidate(misNegociosProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final c = negocio.comercio;
    final repoLugares = ref.watch(comerciosRepositorioProvider);
    return ListView(
      key: ValueKey('ficha-${negocio.id}'),
      padding: const EdgeInsets.all(16),
      children: [
        Text(t.negocioFotos, style: tema.textTheme.titleSmall),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final f in c.fotos)
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      repoLugares.urlFoto(f),
                      width: 96,
                      height: 96,
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const SizedBox(
                        width: 96,
                        height: 96,
                        child: Icon(Icons.photo_outlined),
                      ),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: IconButton.filledTonal(
                      tooltip: t.negocioQuitarFoto,
                      iconSize: 16,
                      onPressed: () async {
                        await ref
                            .read(negociosRepositorioProvider)
                            .borrarFoto(negocio.id, f);
                        ref.invalidate(misNegociosProvider);
                      },
                      icon: const Icon(Icons.close),
                    ),
                  ),
                ],
              ),
            ActionChip(
              avatar: const Icon(Icons.add_a_photo_outlined, size: 18),
              label: Text(t.negocioAgregarFoto),
              onPressed: () => _agregarFoto(context, ref),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (negocio.verificacion != Verificacion.verified)
              OutlinedButton.icon(
                onPressed: negocio.verificacion == Verificacion.pending
                    ? null
                    : () => _pedirVerificacion(context, ref),
                icon: const Icon(Icons.verified_outlined),
                label: Text(
                  negocio.verificacion == Verificacion.pending
                      ? t.verifPendiente
                      : t.negocioPedirVerificacion,
                ),
              ),
            if (c.categoria == Categoria.vet && !c.operadorRenac)
              OutlinedButton.icon(
                onPressed: negocio.renacPedido
                    ? null
                    : () async {
                        final mensajes = ScaffoldMessenger.of(context);
                        await ref
                            .read(negociosRepositorioProvider)
                            .pedirInsigniaRenac(negocio.id);
                        mensajes.showSnackBar(
                          SnackBar(content: Text(t.negocioRenacPedido)),
                        );
                        ref.invalidate(misNegociosProvider);
                      },
                icon: const Icon(Icons.memory_outlined),
                label: Text(
                  negocio.renacPedido
                      ? t.negocioRenacPedido
                      : t.negocioPedirRenac,
                ),
              ),
          ],
        ),
        if (c.categoria == Categoria.vet && !c.operadorRenac)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(t.negocioRenacTexto, style: tema.textTheme.bodySmall),
          ),
        if (negocio.verificacion == Verificacion.verified &&
            ref.watch(funcionalidadActivaProvider(Funcionalidades.eventos)))
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: OutlinedButton.icon(
              onPressed: () => context.push(
                Uri(
                  path: Rutas.nuevoEvento,
                  queryParameters: {
                    'negocio': negocio.id,
                    if (c.punto case final p?) 'lat': '${p.lat}',
                    if (c.punto case final p?) 'lng': '${p.lng}',
                  },
                ).toString(),
              ),
              icon: const Icon(Icons.event_outlined),
              label: Text(t.eventoPublicar),
            ),
          ),
        // Página pública (2.10b, D90): solo con plan Plus.
        if (c.plan == PlanComercio.plus &&
            ref.watch(funcionalidadActivaProvider(Funcionalidades.catalogo)))
          Card(
            margin: const EdgeInsets.only(top: 16),
            child: ListTile(
              key: const ValueKey('compartir-pagina'),
              leading: const Icon(Icons.share_outlined),
              title: Text(t.paginaCompartir),
              subtitle: Text(t.paginaCompartirAyuda),
              trailing: TextButton(
                onPressed: () =>
                    ref.read(abrirEnlaceProvider)(Uri.parse(_urlPagina(ref))),
                child: Text(t.paginaVer),
              ),
              onTap: () async {
                final mensajes = ScaffoldMessenger.of(context);
                await Clipboard.setData(ClipboardData(text: _urlPagina(ref)));
                ref
                    .read(metricasProvider)
                    .track(Eventos.businessPageShare, businessId: negocio.id);
                mensajes.showSnackBar(
                  SnackBar(content: Text(t.paginaEnlaceCopiado)),
                );
              },
            ),
          ),
        // Servicios (2.10a, D90), con la funcionalidad `catalogo`.
        if (ref.watch(funcionalidadActivaProvider(Funcionalidades.catalogo)))
          Card(
            margin: const EdgeInsets.only(top: 16),
            child: ListTile(
              key: const ValueKey('abrir-servicios'),
              leading: const Icon(Icons.design_services_outlined),
              title: Text(t.serviciosAbrir),
              subtitle: Text(
                c.plan == PlanComercio.plus
                    ? t.serviciosAbrirAyuda
                    : t.serviciosSoloPlus,
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Rutas.serviciosNegocio(negocio.id)),
            ),
          ),
        const Divider(height: 32),
        FormularioNegocio(
          key: ValueKey('form-${negocio.id}'),
          original: negocio,
          textoBoton: t.negocioGuardar,
          onGuardar: (datos) async {
            await ref
                .read(negociosRepositorioProvider)
                .editar(negocio.id, datos);
            ref.invalidate(misNegociosProvider);
            if (context.mounted) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(t.negocioGuardado)));
            }
          },
        ),
        const SizedBox(height: 16),
        TextButton.icon(
          onPressed: () => context.push(Rutas.altaNegocio()),
          icon: const Icon(Icons.add_business_outlined),
          label: Text(t.negocioOtro),
        ),
      ],
    );
  }
}
