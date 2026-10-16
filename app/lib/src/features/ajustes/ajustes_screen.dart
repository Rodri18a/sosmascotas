import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../config/env_provider.dart';
import '../../cuenta/perfil_repositorio.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../metricas/metricas.dart';
import '../../push/control_push.dart';
import '../../push/servicio_push.dart';
import '../../router.dart';
import '../../theme/tema_elegido.dart';
import '../../ubicacion/control_ubicacion.dart';
import '../ingresar/ingresar_screen.dart';
import 'estado_conexion.dart';
import 'tile_tema.dart';

class AjustesScreen extends ConsumerWidget {
  const AjustesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(appEnvProvider);
    final usuario = ref.watch(usuarioActualProvider).value;
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.ajustes),
        // Si se entró por un enlace directo no hay a dónde volver: ir al mapa.
        leading: context.canPop()
            ? null
            : BackButton(onPressed: () => context.go(Rutas.mapa)),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          if (usuario == null)
            ListTile(
              leading: const Icon(Icons.login),
              title: Text(t.ingresarOCrearCuenta),
              subtitle: Text(t.ingresarSubtitulo),
              onTap: () => context.push(Rutas.ingresarYVolverA(Rutas.ajustes)),
            )
          else
            _SeccionCuenta(usuario: usuario),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: Text(t.legalTerminos),
            onTap: () => context.push(Rutas.terminos),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: Text(t.legalPrivacidad),
            onTap: () => context.push(Rutas.privacidad),
          ),
          if (usuario != null) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(t.cerrarSesion),
              onTap: () => _salir(ref),
            ),
            ListTile(
              leading: Icon(
                Icons.delete_forever_outlined,
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                t.borrarCuenta,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              onTap: () => _borrarCuenta(context, ref),
            ),
          ],
          if (!env.isProd) ...[
            const Divider(),
            ListTile(title: Text(t.ajustesDesarrollo)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: EstadoConexionChip(),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Cierra la sesión; antes, este dispositivo deja de recibir sus avisos.
  Future<void> _salir(WidgetRef ref) async {
    try {
      await ref.read(servicioPushProvider).olvidarDispositivo();
    } on Exception catch (e) {
      debugPrint('No se pudo borrar el token de push: $e');
    }
    await ref.read(servicioCuentaProvider).salir();
  }

  Future<void> _borrarCuenta(BuildContext context, WidgetRef ref) async {
    final t = context.t;
    final confirmado = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.warning_amber_rounded),
        title: Text(t.borrarCuentaTitulo),
        content: Text(t.borrarCuentaExplicacion),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelar),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.borrarCuentaConfirmar),
          ),
        ],
      ),
    );
    if (!(confirmado ?? false) || !context.mounted) return;

    final mensajero = ScaffoldMessenger.of(context);
    try {
      ref.read(metricasProvider).track(Eventos.accountDelete);
      await ref.read(servicioCuentaProvider).borrarCuenta();
      mensajero.showSnackBar(SnackBar(content: Text(t.borrarCuentaHecho)));
      if (context.mounted) context.go(Rutas.mapa);
    } on CuentaException catch (e) {
      mensajero.showSnackBar(
        SnackBar(content: Text(mensajeDeError(t, e.tipo))),
      );
    }
  }
}

/// Nombre, correo y radio de avisos de la persona con sesión.
class _SeccionCuenta extends ConsumerWidget {
  const _SeccionCuenta({required this.usuario});

  final Usuario usuario;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final perfil = ref.watch(perfilProvider).value;
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person_outline),
          title: Text(
            perfil == null || perfil.nombre.isEmpty
                ? t.ajustesPerfil
                : perfil.nombre,
          ),
          subtitle: Text(usuario.email ?? ''),
          trailing: const Icon(Icons.edit_outlined),
          onTap: perfil == null
              ? null
              : () => _editarNombre(context, ref, perfil),
        ),
        const InterruptorPush(),
        if (perfil != null) TileZonaAvisos(perfil: perfil),
        if (perfil != null) _RadioAvisos(perfil: perfil),
        if (ref.watch(puedeElegirTemaProvider)) const TileTema(),
      ],
    );
  }

  Future<void> _editarNombre(
    BuildContext context,
    WidgetRef ref,
    Perfil perfil,
  ) async {
    final nombre = await showDialog<String>(
      context: context,
      builder: (context) => _DialogoNombre(inicial: perfil.nombre),
    );
    final limpio = nombre?.trim() ?? '';
    if (limpio.isEmpty || limpio == perfil.nombre || !context.mounted) return;
    await _guardar(context, ref, () {
      return ref
          .read(perfilRepositorioProvider)
          .actualizar(perfil.id, nombre: limpio);
    });
  }
}

/// Pide el nombre. Es dueño de su controlador: se libera cuando termina la
/// animación de cierre (liberarlo antes rompe el campo mientras se cierra).
class _DialogoNombre extends StatefulWidget {
  const _DialogoNombre({required this.inicial});

  final String inicial;

  @override
  State<_DialogoNombre> createState() => _DialogoNombreState();
}

class _DialogoNombreState extends State<_DialogoNombre> {
  late final _controlador = TextEditingController(text: widget.inicial);

  @override
  void dispose() {
    _controlador.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return AlertDialog(
      title: Text(t.ajustesNombreTitulo),
      content: TextField(
        controller: _controlador,
        autofocus: true,
        maxLength: 40,
        textCapitalization: TextCapitalization.words,
        decoration: InputDecoration(helperText: t.ajustesNombreAyuda),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancelar),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _controlador.text),
          child: Text(t.guardar),
        ),
      ],
    );
  }
}

/// Distancia máxima a la que se reciben avisos de mascotas perdidas.
class _RadioAvisos extends ConsumerStatefulWidget {
  const _RadioAvisos({required this.perfil});

  final Perfil perfil;

  @override
  ConsumerState<_RadioAvisos> createState() => _RadioAvisosState();
}

class _RadioAvisosState extends ConsumerState<_RadioAvisos> {
  late double _km = widget.perfil.radioAvisosKm.toDouble();

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return ListTile(
      leading: const Icon(Icons.notifications_active_outlined),
      title: Text(t.ajustesRadioAvisos(_km.round())),
      subtitle: Slider(
        value: _km,
        min: radioAvisosMinKm.toDouble(),
        max: radioAvisosMaxKm.toDouble(),
        divisions: radioAvisosMaxKm - radioAvisosMinKm,
        label: t.ajustesKm(_km.round()),
        semanticFormatterCallback: (v) => t.ajustesKm(v.round()),
        onChanged: (v) => setState(() => _km = v),
        onChangeEnd: (v) => _guardar(
          context,
          ref,
          () => ref
              .read(perfilRepositorioProvider)
              .actualizar(widget.perfil.id, radioAvisosKm: v.round()),
        ),
      ),
    );
  }
}

/// Guarda un cambio del perfil, lo recarga y avisa si falló.
Future<void> _guardar(
  BuildContext context,
  WidgetRef ref,
  Future<void> Function() cambio,
) async {
  final mensajero = ScaffoldMessenger.of(context);
  final t = context.t;
  try {
    await cambio();
    ref.invalidate(perfilProvider);
  } on Exception {
    mensajero.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
  }
}
