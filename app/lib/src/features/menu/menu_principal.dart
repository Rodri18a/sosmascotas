import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/perfil_repositorio.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../mascotas/catalogo.dart';
import '../../mascotas/mascota_elegida.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../widgets/foto_mascota.dart';

/// Menú ☰ de las pestañas (D88): mis datos, la mascota elegida (filtra
/// Noticias, Comunidad y Adopción por su especie, con accesos a lo suyo) y
/// el resto de las secciones. Cada opción respeta su funcionalidad gradual.
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

  /// Cierra el menú y abre [ruta] encima de la pestaña.
  void _ir(String ruta) {
    Navigator.pop(context);
    context.push(ruta);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final conectado = ref.watch(conectadoProvider);
    bool activa(String clave) => ref.watch(funcionalidadActivaProvider(clave));
    final mascotas = conectado
        ? ref.watch(misMascotasProvider).value ?? const <Mascota>[]
        : const <Mascota>[];
    final elegida = ref.watch(mascotaElegidaProvider);

    Widget opcion(IconData icono, String texto, String ruta) => ListTile(
      leading: Icon(icono),
      title: Text(texto),
      onTap: () => _ir(ruta),
    );

    return Drawer(
      child: SafeArea(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            _Cabecera(onIr: _ir),
            if (mascotas.isNotEmpty) ...[
              const Divider(),
              _ElegirMascota(mascotas: mascotas, elegida: elegida),
              if (elegida != null) ...[
                opcion(
                  Icons.badge_outlined,
                  t.menuFicha,
                  Rutas.fichaMascota(elegida.id),
                ),
                opcion(
                  Icons.qr_code_2,
                  t.fichaQrTitulo,
                  Rutas.qrMascota(elegida.id),
                ),
                if (elegida.esDe(ref.watch(usuarioActualProvider).value?.id))
                  opcion(
                    Icons.sos,
                    t.menuReportarPerdida,
                    Rutas.reportarMascota(elegida.id),
                  ),
              ],
            ],
            const Divider(),
            if (activa(Funcionalidades.noticias))
              opcion(
                Icons.newspaper_outlined,
                t.noticiasTitulo,
                Rutas.noticias,
              ),
            if (activa(Funcionalidades.adopcion))
              opcion(
                Icons.volunteer_activism_outlined,
                t.adopcionEntrada,
                Rutas.adopcion,
              ),
            if (conectado) ...[
              if (activa(Funcionalidades.chat))
                opcion(Icons.chat_bubble_outline, t.chatMensajes, Rutas.chats),
              opcion(
                Icons.notifications_outlined,
                t.avisosTitulo,
                Rutas.avisos,
              ),
              if (activa(Funcionalidades.hogar))
                opcion(Icons.family_restroom, t.ajustesHogar, Rutas.hogar),
              opcion(
                Icons.shopping_bag_outlined,
                t.misPedidos,
                Rutas.misPedidos,
              ),
              if (activa(Funcionalidades.comercios))
                opcion(Icons.storefront_outlined, t.negocioMi, Rutas.negocio),
            ],
            const Divider(),
            opcion(Icons.settings_outlined, t.ajustes, Rutas.ajustes),
          ],
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
      trailing: const Icon(Icons.chevron_right),
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
