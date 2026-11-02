import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/perfil_repositorio.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../dos_apps/dos_apps.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../mascotas/catalogo.dart';
import '../../mascotas/mascota_elegida.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../widgets/foto_mascota.dart';
import '../../widgets/logo.dart';

/// Menú ☰ de las pestañas (D88): mis datos y todas las secciones en grupos
/// con título (plan de mejoras 1.2). En Mis mascotas está la mascota elegida
/// (filtra Noticias, Comunidad y Adopción por su especie, con accesos a lo
/// suyo). Cada opción respeta su funcionalidad gradual.
class MenuPrincipal extends ConsumerStatefulWidget {
  const MenuPrincipal({super.key});

  @override
  ConsumerState<MenuPrincipal> createState() => _MenuPrincipalState();
}

class _MenuPrincipalState extends ConsumerState<MenuPrincipal> {
  @override
  void initState() {
    super.initState();
    // El cajón se construye recién al abrirlo.
    ref.read(metricasProvider).track(Eventos.menuOpen);
  }

  /// Cierra el menú, anota qué se tocó y hace [accion].
  void _tocar(String item, void Function() accion) {
    ref
        .read(metricasProvider)
        .track(Eventos.menuItemOpen, props: {'item': item});
    Navigator.pop(context);
    accion();
  }

  /// Abre [ruta] encima de la pestaña.
  void _ir(String ruta) => context.push(ruta);

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final conectado = ref.watch(conectadoProvider);
    bool activa(String clave) => ref.watch(funcionalidadActivaProvider(clave));
    final mascotas = conectado
        ? ref.watch(misMascotasProvider).value ?? const <Mascota>[]
        : const <Mascota>[];
    final elegida = ref.watch(mascotaElegidaProvider);

    Widget opcion(
      String item,
      IconData icono,
      String texto,
      void Function() accion,
    ) => ListTile(
      leading: Icon(icono),
      title: Text(texto),
      onTap: () => _tocar(item, accion),
    );
    // Las pestañas se cambian; el resto se abre encima.
    Widget pestana(String item, IconData icono, String texto, String ruta) =>
        opcion(item, icono, texto, () => context.go(ruta));
    Widget pantalla(String item, IconData icono, String texto, String ruta) =>
        opcion(item, icono, texto, () => _ir(ruta));

    // Grupos con título (paso 1.2 del plan de mejoras): todo a 2 toques.
    // Un grupo sin opciones prendidas no se muestra.
    final grupos = <(String, List<Widget>)>[
      (
        t.menuGrupoMascotas,
        [
          pestana(
            'mascotas',
            Icons.pets_outlined,
            t.pestanaMascotas,
            Rutas.mascotas,
          ),
          if (mascotas.isNotEmpty)
            _ElegirMascota(mascotas: mascotas, elegida: elegida),
          if (elegida != null) ...[
            pantalla(
              'ficha',
              Icons.badge_outlined,
              t.menuFicha,
              Rutas.fichaMascota(elegida.id),
            ),
            pantalla(
              'qr',
              Icons.qr_code_2_outlined,
              t.fichaQrTitulo,
              Rutas.qrMascota(elegida.id),
            ),
            if (elegida.esDe(ref.watch(usuarioActualProvider).value?.id))
              pantalla(
                'reportar',
                Icons.sos_outlined,
                t.menuReportarPerdida,
                Rutas.reportarMascota(elegida.id),
              ),
          ],
        ],
      ),
      (
        t.menuGrupoMapa,
        [
          pestana('mapa', Icons.map_outlined, t.pestanaMapa, Rutas.mapa),
          if (activa(Funcionalidades.busqueda))
            pantalla(
              'buscar',
              Icons.search_outlined,
              t.buscarLugares,
              Rutas.buscarLugares,
            ),
          if (conectado && activa(Funcionalidades.comercios))
            pantalla(
              'marcar_lugar',
              Icons.add_location_alt_outlined,
              t.marcarLugar,
              Rutas.marcarLugar,
            ),
        ],
      ),
      (
        t.menuGrupoComunidad,
        [
          pestana(
            'inicio',
            Icons.home_outlined,
            t.noticiasTitulo,
            Rutas.inicio,
          ),
          if (activa(Funcionalidades.eventos))
            pestana(
              'eventos',
              Icons.event_outlined,
              t.eventosProximos,
              Rutas.comunidad,
            ),
          if (activa(Funcionalidades.grupos))
            pantalla(
              'grupos',
              Icons.forum_outlined,
              t.comunidadGrupos,
              Rutas.grupos,
            ),
          if (conectado && activa(Funcionalidades.chat))
            pantalla(
              'mensajes',
              Icons.chat_bubble_outline,
              t.chatMensajes,
              Rutas.chats,
            ),
          if (conectado)
            pantalla(
              'avisos',
              Icons.notifications_outlined,
              t.avisosTitulo,
              Rutas.avisos,
            ),
        ],
      ),
      if (activa(Funcionalidades.adopcion))
        (
          t.menuGrupoAdopcion,
          [
            pantalla(
              'adopcion',
              Icons.volunteer_activism_outlined,
              t.adopcionEntrada,
              Rutas.adopcion,
            ),
            if (conectado)
              pantalla(
                'transito',
                Icons.night_shelter_outlined,
                t.transitoTitulo,
                Rutas.hogarTransito,
              ),
          ],
        ),
      if (conectado)
        (
          t.menuGrupoTurnos,
          [
            if (activa(Funcionalidades.agenda))
              pantalla(
                'turnos',
                Icons.event_available_outlined,
                t.misTurnos,
                Rutas.misTurnos,
              ),
            pantalla(
              'pedidos',
              Icons.shopping_bag_outlined,
              t.misPedidos,
              Rutas.misPedidos,
            ),
            if (activa(Funcionalidades.cuidados))
              pantalla(
                'cuidados',
                Icons.directions_walk_outlined,
                t.misCuidados,
                Rutas.misCuidados,
              ),
          ],
        ),
      (
        t.menuGrupoCuenta,
        [
          if (conectado && activa(Funcionalidades.comercios))
            // En la web abre Huellitas Comercios (D129).
            opcion(
              'negocio',
              Icons.storefront_outlined,
              t.negocioMi,
              () => irAMiNegocio(context, ref),
            ),
          if (conectado && activa(Funcionalidades.planesUsuario))
            pantalla(
              'mi_plan',
              Icons.workspace_premium_outlined,
              t.miPlanTitulo,
              Rutas.miPlan,
            ),
          if (conectado && activa(Funcionalidades.hogar))
            pantalla(
              'hogar',
              Icons.family_restroom_outlined,
              t.ajustesHogar,
              Rutas.hogar,
            ),
          pantalla(
            'ajustes',
            Icons.settings_outlined,
            t.ajustes,
            Rutas.ajustes,
          ),
        ],
      ),
    ];

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Logo de la marca arriba del menú (guía de marca, D122).
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 20, 16, 4),
              child: Align(
                alignment: Alignment.centerLeft,
                child: LogoHuellitas(horizontal: true, alto: 22),
              ),
            ),
            _Cabecera(onIr: (ruta) => _tocar('perfil', () => _ir(ruta))),
            for (final (titulo, opciones) in grupos)
              if (opciones.isNotEmpty) ...[
                const Divider(),
                _TituloGrupo(titulo),
                ...opciones,
              ],
          ],
        ),
      ),
    );
  }
}

class _TituloGrupo extends StatelessWidget {
  const _TituloGrupo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Text(
        texto,
        style: tema.textTheme.titleSmall?.copyWith(
          color: tema.colorScheme.primary,
        ),
      ),
    );
  }
}

/// Mis datos (o "Ingresá" si es visitante). Tocarla abre Mi perfil (o
/// Ajustes, si el perfil todavía no está prendido).
class _Cabecera extends ConsumerWidget {
  const _Cabecera({required this.onIr});

  final void Function(String ruta) onIr;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final usuario = ref.watch(usuarioActualProvider).value;
    if (usuario == null) {
      return ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
        leading: const CircleAvatar(child: Icon(Icons.person_outline)),
        title: Text(t.menuIngresar),
        subtitle: Text(t.menuIngresarAyuda),
        onTap: () => onIr(Rutas.ingresar),
      );
    }
    final perfil = ref.watch(perfilProvider).value;
    final nombre = perfil?.nombre.trim() ?? '';
    final conPerfil = ref.watch(
      funcionalidadActivaProvider(Funcionalidades.perfil),
    );
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      leading: CircleAvatar(
        backgroundColor: tema.colorScheme.primaryContainer,
        child: Text(
          (nombre.isEmpty ? (usuario.email ?? '?') : nombre).characters.first
              .toUpperCase(),
        ),
      ),
      title: Text(nombre.isEmpty ? t.ajustesPerfil : nombre),
      subtitle: Text(usuario.email ?? ''),
      trailing: const Icon(Icons.chevron_right_outlined),
      onTap: () => onIr(conPerfil ? Rutas.perfil : Rutas.ajustes),
    );
  }
}

/// "Ver todo para": Todas o una de mis mascotas. Se guarda en el dispositivo.
class _ElegirMascota extends ConsumerWidget {
  const _ElegirMascota({required this.mascotas, required this.elegida});

  final List<Mascota> mascotas;
  final Mascota? elegida;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final especies = {
      for (final e in ref.watch(especiesProvider).value ?? const <Especie>[])
        e.id: e,
    };
    void elegir(Mascota? m) {
      ref.read(mascotaElegidaIdProvider.notifier).elegir(m?.id);
      ref
          .read(metricasProvider)
          .track(Eventos.petSelect, props: {'todas': m == null});
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.menuVerPara, style: tema.textTheme.titleSmall),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              ChoiceChip(
                label: Text(t.menuTodas),
                selected: elegida == null,
                onSelected: (_) => elegir(null),
              ),
              for (final m in mascotas)
                ChoiceChip(
                  avatar: FotoMascota(
                    ruta: m.fotoPath,
                    radio: 12,
                    icono: especies[m.especieId]?.icono,
                  ),
                  label: Text(m.nombre),
                  selected: elegida?.id == m.id,
                  onSelected: (_) => elegir(m),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            elegida == null
                ? t.menuTodasAyuda
                : t.menuElegidaAyuda(elegida!.nombre),
            style: tema.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}
