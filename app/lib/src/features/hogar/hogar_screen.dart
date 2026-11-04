import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/plan_usuario_repositorio.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../hogar/hogar_repositorio.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../widgets/boton_ayuda.dart';
import '../../widgets/explicacion_corta.dart';
import '../../widgets/volver.dart';

String nombreIntegrante(AppLocalizations t, Integrante i) =>
    i.nombre?.trim().isNotEmpty ?? false ? i.nombre!.trim() : t.hogarSinNombre;

/// "Mi hogar": quiénes comparten las mascotas, invitar, sacar o irse (1.6.1).
class HogarScreen extends ConsumerWidget {
  const HogarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final yo = ref.watch(usuarioActualProvider).value?.id;
    final integrantes = ref.watch(integrantesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.hogarTitulo),
        actions: const [BotonAyuda()],
      ),
      body: switch (integrantes) {
        AsyncData(value: final lista) => _Contenido(lista: lista, yo: yo),
        AsyncLoading() => const Center(child: CircularProgressIndicator()),
        _ => Center(child: Text(t.errorSinConexion)),
      },
    );
  }
}

class _Contenido extends ConsumerWidget {
  const _Contenido({required this.lista, required this.yo});

  final List<Integrante> lista;
  final String? yo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    // Agrupado por hogar; primero el mío (donde soy quien lo creó).
    final hogares = <String, List<Integrante>>{};
    for (final i in lista) {
      hogares.putIfAbsent(i.hogarId, () => []).add(i);
    }
    String? miHogar;
    for (final MapEntry(:key, :value) in hogares.entries) {
      if (value.any((i) => i.esDueno && i.usuarioId == yo)) miHogar = key;
    }
    final otros = hogares.keys.where((h) => h != miHogar).toList();
    final mios = miHogar == null ? const <Integrante>[] : hogares[miHogar]!;
    final lleno = mios.where((i) => !i.esDueno).length >= maxIntegrantesHogar;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        ExplicacionCorta(
          id: 'hogar_explicacion',
          corta: t.hogarExplicacionCorta,
          larga: t.hogarExplicacion,
        ),
        const SizedBox(height: 16),
        Text(t.hogarMio, style: tema.textTheme.titleMedium),
        if (mios.where((i) => !i.esDueno).isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(t.hogarSoloVos),
          )
        else
          for (final i in mios)
            _Fila(integrante: i, yo: yo, puedoSacar: i.usuarioId != yo),
        const SizedBox(height: 8),
        FilledButton.icon(
          onPressed: lleno ? null : () => _invitar(context, ref),
          icon: const Icon(Icons.person_add_alt_1_outlined),
          label: Text(t.hogarInvitar),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: lleno ? null : () => _invitarCuidador(context, ref),
          icon: const Icon(Icons.schedule_outlined),
          label: Text(t.hogarInvitarCuidador),
        ),
        if (lleno)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(t.hogarLleno, style: tema.textTheme.bodySmall),
          ),
        for (final h in otros) ...[
          const SizedBox(height: 24),
          Text(
            t.hogarDe(
              nombreIntegrante(t, hogares[h]!.firstWhere((i) => i.esDueno)),
            ),
            style: tema.textTheme.titleMedium,
          ),
          for (final i in hogares[h]!)
            _Fila(integrante: i, yo: yo, puedoSacar: false),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _irme(context, ref, h),
            icon: const Icon(Icons.logout_outlined),
            label: Text(t.hogarIrme),
          ),
        ],
      ],
    );
  }

  Future<void> _invitarCuidador(BuildContext context, WidgetRef ref) async {
    final List<Mascota> todas;
    try {
      todas = await ref.read(misMascotasProvider.future);
    } on Exception {
      return;
    }
    final propias = todas.where((m) => m.esDe(yo)).toList();
    if (!context.mounted) return;
    final eleccion = await showModalBottomSheet<(int, List<String>)>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _FormularioCuidador(mascotas: propias),
    );
    if (eleccion == null || !context.mounted) return;
    await _invitar(context, ref, dias: eleccion.$1, mascotas: eleccion.$2);
  }

  Future<void> _invitar(
    BuildContext context,
    WidgetRef ref, {
    int? dias,
    List<String>? mascotas,
  }) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      final codigo = await ref
          .read(hogarRepositorioProvider)
          .invitar(diasCuidador: dias, mascotas: mascotas);
      ref
          .read(metricasProvider)
          .track(
            Eventos.householdInvite,
            props: {'rol': dias == null ? 'member' : 'temp_caregiver'},
          );
      ref.invalidate(integrantesProvider);
      if (!context.mounted) return;
      final enlace = enlaceInvitacion(ref.read(urlAppProvider), codigo);
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(t.hogarInvitacionTitulo),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.hogarInvitacionTexto),
              const SizedBox(height: 12),
              SelectableText(enlace),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(t.cancelar),
            ),
            FilledButton.icon(
              onPressed: () async {
                await Clipboard.setData(
                  ClipboardData(text: t.hogarMensajeInvitacion(enlace)),
                );
                if (context.mounted) Navigator.pop(context);
                mensajes.showSnackBar(SnackBar(content: Text(t.hogarCopiado)));
              },
              icon: const Icon(Icons.copy_outlined),
              label: Text(t.hogarCopiar),
            ),
          ],
        ),
      );
    } on Exception catch (e) {
      final familia = '$e'.contains('plan_familia');
      mensajes.showSnackBar(
        SnackBar(
          content: Text(familia ? t.miPlanHogarFamilia : t.errorSinConexion),
          action: familia
              ? SnackBarAction(
                  label: t.miPlanVerPlanes,
                  onPressed: () => context.push(Rutas.miPlan),
                )
              : null,
        ),
      );
    }
    // Una invitación puede abrir la prueba de Familia (D111).
    ref.invalidate(miPlanUsuarioProvider);
  }

  Future<void> _irme(BuildContext context, WidgetRef ref, String hogar) async {
    final t = context.t;
    final yo = this.yo;
    if (yo == null) return;
    final ok = await _confirmar(
      context,
      titulo: t.hogarIrmeTitulo,
      texto: t.hogarIrmeTexto,
      accion: t.hogarSalir,
    );
    if (!ok || !context.mounted) return;
    await _sacar(context, ref, hogar, yo, irme: true);
  }
}

class _Fila extends ConsumerWidget {
  const _Fila({
    required this.integrante,
    required this.yo,
    required this.puedoSacar,
  });

  final Integrante integrante;
  final String? yo;
  final bool puedoSacar;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final nombre = nombreIntegrante(t, integrante);
    final hasta = integrante.accesoHasta;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(child: Text(nombre.characters.first.toUpperCase())),
      title: Text(integrante.usuarioId == yo ? t.hogarVos(nombre) : nombre),
      subtitle: Text(switch (integrante.rol) {
        RolHogar.owner => t.hogarCreador,
        RolHogar.member => t.hogarIntegrante,
        RolHogar.tempCaregiver => t.hogarCuidadorHasta(
          hasta == null
              ? ''
              : MaterialLocalizations.of(context).formatMediumDate(hasta),
        ),
      }),
      trailing: puedoSacar
          ? IconButton(
              tooltip: t.hogarSacar,
              icon: const Icon(Icons.person_remove_outlined),
              onPressed: () async {
                final ok = await _confirmar(
                  context,
                  titulo: t.hogarSacarTitulo(nombre),
                  texto: t.hogarSacarTexto,
                  accion: t.hogarSacar,
                );
                if (!ok || !context.mounted) return;
                await _sacar(
                  context,
                  ref,
                  integrante.hogarId,
                  integrante.usuarioId,
                );
              },
            )
          : null,
    );
  }
}

Future<bool> _confirmar(
  BuildContext context, {
  required String titulo,
  required String texto,
  required String accion,
}) async =>
    await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(titulo),
        content: Text(texto),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.t.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(accion),
          ),
        ],
      ),
    ) ??
    false;

Future<void> _sacar(
  BuildContext context,
  WidgetRef ref,
  String hogar,
  String usuario, {
  bool irme = false,
}) async {
  final t = context.t;
  final mensajes = ScaffoldMessenger.of(context);
  try {
    await ref.read(hogarRepositorioProvider).sacar(hogar, usuario);
    if (irme) ref.read(metricasProvider).track(Eventos.householdLeave);
  } on Exception {
    mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
  }
  ref
    ..invalidate(integrantesProvider)
    ..invalidate(misMascotasProvider);
}

/// Abrir un enlace de invitación: `/unirme/<código>` (1.6.1).
class UnirmeScreen extends ConsumerStatefulWidget {
  const UnirmeScreen({required this.codigo, super.key});

  final String codigo;

  @override
  ConsumerState<UnirmeScreen> createState() => _UnirmeScreenState();
}

class _UnirmeScreenState extends ConsumerState<UnirmeScreen> {
  bool _uniendo = false;
  String? _error;

  Future<void> _unirme() async {
    final t = context.t;
    setState(() {
      _uniendo = true;
      _error = null;
    });
    try {
      await ref.read(hogarRepositorioProvider).unirme(widget.codigo);
      ref.read(metricasProvider).track(Eventos.householdJoin);
      ref
        ..invalidate(integrantesProvider)
        ..invalidate(misMascotasProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.unirmeListo)));
      context.go(Rutas.mascotas);
    } on InvitacionFallida catch (e) {
      setState(
        () => _error = switch (e.motivo) {
          ErrorInvitacion.noSirve => t.unirmeNoSirve,
          ErrorInvitacion.propia => t.unirmePropia,
          ErrorInvitacion.yaSos => t.unirmeYaSos,
          ErrorInvitacion.lleno => t.unirmeLleno,
          ErrorInvitacion.sinConexion => t.errorSinConexion,
        },
      );
    } finally {
      if (mounted) setState(() => _uniendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final valido = codigoInvitacionValido(widget.codigo);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.unirmeTitulo),
        leading: volverSiNoHayAtras(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.family_restroom_outlined, size: 64),
          const SizedBox(height: 16),
          ExplicacionCorta(
            id: 'unirme_texto',
            corta: t.unirmeTextoCorta,
            larga: t.unirmeTexto,
          ),
          const SizedBox(height: 24),
          if (!valido)
            Text(
              t.unirmeNoSirve,
              style: TextStyle(color: tema.colorScheme.error),
            )
          else
            FilledButton(
              onPressed: _uniendo ? null : _unirme,
              child: Text(t.unirmeBoton),
            ),
          if (_error case final error?) ...[
            const SizedBox(height: 12),
            Text(error, style: TextStyle(color: tema.colorScheme.error)),
          ],
        ],
      ),
    );
  }
}

/// Elegir mascotas y días para un cuidador temporal (1.6.4, D72).
class _FormularioCuidador extends StatefulWidget {
  const _FormularioCuidador({required this.mascotas});

  final List<Mascota> mascotas;

  @override
  State<_FormularioCuidador> createState() => _FormularioCuidadorState();
}

class _FormularioCuidadorState extends State<_FormularioCuidador> {
  static const _opcionesDias = [1, 3, 7, 14, 30];
  late final _elegidas = {for (final m in widget.mascotas) m.id};
  var _dias = 7;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(t.cuidadorTitulo, style: tema.textTheme.titleLarge),
            const SizedBox(height: 8),
            ExplicacionCorta(
              id: 'cuidador_explicacion',
              corta: t.cuidadorExplicacionCorta,
              larga: t.cuidadorExplicacion,
            ),
            const SizedBox(height: 16),
            Text(t.cuidadorMascotas, style: tema.textTheme.titleSmall),
            if (widget.mascotas.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(t.cuidadorSinMascotas),
              ),
            for (final m in widget.mascotas)
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(m.nombre),
                value: _elegidas.contains(m.id),
                onChanged: (si) => setState(
                  () => (si ?? false)
                      ? _elegidas.add(m.id)
                      : _elegidas.remove(m.id),
                ),
              ),
            const SizedBox(height: 8),
            DropdownButtonFormField<int>(
              initialValue: _dias,
              decoration: InputDecoration(labelText: t.cuidadorDias),
              items: [
                for (final d in _opcionesDias)
                  DropdownMenuItem(value: d, child: Text(t.cuidadorNDias(d))),
              ],
              onChanged: (d) => setState(() => _dias = d ?? _dias),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _elegidas.isEmpty
                  ? null
                  : () => Navigator.pop(context, (_dias, _elegidas.toList())),
              child: Text(t.cuidadorInvitar),
            ),
          ],
        ),
      ),
    );
  }
}
