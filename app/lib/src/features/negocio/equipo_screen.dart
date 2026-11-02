import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/equipo_repositorio.dart';
import '../../comercios/negocios_repositorio.dart';
import '../../hogar/hogar_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../widgets/explicacion_corta.dart';
import '../../widgets/volver.dart';

/// `https://…/equipo/<código>`: abre [UnirmeEquipoScreen].
String enlaceEquipo(String base, String codigo) =>
    '${base.replaceAll(RegExp(r'/+$'), '')}/equipo/$codigo';

String textoErrorEquipo(AppLocalizations t, ErrorEquipo e) => switch (e) {
  ErrorEquipo.soloPlus => t.equipoSoloPlus,
  ErrorEquipo.lleno => t.equipoLleno(maximoEquipo),
  ErrorEquipo.codigoInvalido => t.equipoErrorCodigo,
  ErrorEquipo.yaSosDuenio => t.equipoErrorDuenio,
  ErrorEquipo.sinConexion => t.errorSinConexion,
};

/// Modo comercio → Equipo (3.5, D117): el dueño invita y saca; el empleado
/// ve quiénes están y puede irse.
class EquipoScreen extends StatelessWidget {
  const EquipoScreen({required this.negocioId, super.key});

  final String negocioId;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      leading: volverSiNoHayAtras(context),
      title: Text(context.t.equipoTitulo),
    ),
    body: ListaEquipo(negocioId: negocioId),
  );
}

/// El contenido de [EquipoScreen]; también es la pestaña «Equipo» del modo
/// comercio para quien no es el dueño.
class ListaEquipo extends ConsumerWidget {
  const ListaEquipo({required this.negocioId, super.key});

  final String negocioId;

  Future<void> _invitar(
    BuildContext context,
    WidgetRef ref,
    MiNegocio? negocio,
  ) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      final codigo = await ref
          .read(equipoRepositorioProvider)
          .invitar(negocioId);
      ref
          .read(metricasProvider)
          .track(Eventos.teamInvite, businessId: negocioId);
      ref.invalidate(equipoNegocioProvider(negocioId));
      if (!context.mounted) return;
      await _mostrarInvitacion(context, ref, codigo, negocio);
    } on EquipoException catch (e) {
      mensajes.showSnackBar(
        SnackBar(content: Text(textoErrorEquipo(t, e.motivo))),
      );
    }
  }

  Future<void> _mostrarInvitacion(
    BuildContext context,
    WidgetRef ref,
    String codigo,
    MiNegocio? negocio,
  ) {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    final enlace = enlaceEquipo(ref.read(urlAppProvider), codigo);
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.equipoInvitacionTitulo),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(t.equipoInvitacionTexto(codigo)),
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
                ClipboardData(
                  text: t.equipoMensajeInvitacion(
                    negocio?.comercio.nombre ?? '',
                    enlace,
                  ),
                ),
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
  }

  Future<bool> _confirmar(
    BuildContext context,
    String texto,
    String boton,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(texto),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(context.t.cancelar),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(boton),
            ),
          ],
        ),
      ) ??
      false;

  Future<void> _quitar(
    BuildContext context,
    WidgetRef ref,
    PersonaEquipo p,
    MiNegocio? negocio,
  ) async {
    final t = context.t;
    final ok = p.soyYo
        ? await _confirmar(
            context,
            t.equipoIrmePregunta(negocio?.comercio.nombre ?? ''),
            t.equipoIrme,
          )
        : await _confirmar(
            context,
            t.equipoQuitarPregunta(p.nombre ?? t.hogarSinNombre),
            t.equipoQuitar,
          );
    if (!ok || !context.mounted) return;
    final mensajes = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      await ref.read(equipoRepositorioProvider).quitar(negocioId, p.userId);
      ref
          .read(metricasProvider)
          .track(
            Eventos.teamLeave,
            businessId: negocioId,
            props: {'quien': p.soyYo ? 'yo' : 'duenio'},
          );
      ref.invalidate(equipoNegocioProvider(negocioId));
      if (p.soyYo) {
        ref.invalidate(misNegociosProvider);
        router.go(Rutas.mapa);
      }
    } on EquipoException catch (e) {
      mensajes.showSnackBar(
        SnackBar(content: Text(textoErrorEquipo(t, e.motivo))),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final fecha = MaterialLocalizations.of(context).formatMediumDate;
    final negocio = (ref.watch(misNegociosProvider).value ?? const [])
        .where((n) => n.id == negocioId)
        .firstOrNull;
    return switch (ref.watch(equipoNegocioProvider(negocioId))) {
      AsyncData(value: final e) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ExplicacionCorta(
            id: e.soyTitular ? 'equipo_ayuda_duenio' : 'equipo_ayuda_empleado',
            corta: e.soyTitular
                ? t.equipoAyudaDuenioCorta
                : t.equipoAyudaEmpleadoCorta,
            larga: e.soyTitular ? t.equipoAyudaDuenio : t.equipoAyudaEmpleado,
            estilo: tema.textTheme.bodySmall,
          ),
          const SizedBox(height: 16),
          if (e.soyTitular) ...[
            if (negocio?.comercio.plan != PlanComercio.plus)
              Text(t.equipoSoloPlus)
            else if (e.lleno)
              Text(t.equipoLleno(maximoEquipo))
            else
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: FilledButton.icon(
                  onPressed: () => _invitar(context, ref, negocio),
                  icon: const Icon(Icons.person_add_alt_1_outlined),
                  label: Text(t.equipoInvitar),
                ),
              ),
            const SizedBox(height: 12),
            if (e.personas.isEmpty) Text(t.equipoVacio),
          ],
          for (final p in e.personas)
            Card(
              child: ListTile(
                key: ValueKey('equipo-${p.userId}'),
                leading: const Icon(Icons.badge_outlined),
                title: Text(
                  p.soyYo
                      ? t.hogarVos(p.nombre ?? t.hogarSinNombre)
                      : p.nombre ?? t.hogarSinNombre,
                ),
                subtitle: Text(t.equipoDesde(fecha(p.desde.toLocal()))),
                trailing: e.soyTitular || p.soyYo
                    ? TextButton(
                        onPressed: () => _quitar(context, ref, p, negocio),
                        child: Text(p.soyYo ? t.equipoIrme : t.equipoQuitar),
                      )
                    : null,
              ),
            ),
          if (e.invitaciones.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(t.equipoInvitaciones, style: tema.textTheme.titleSmall),
            for (final i in e.invitaciones)
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.mail_outline),
                title: Text(t.equipoVence(i.codigo, fecha(i.vence.toLocal()))),
                onTap: () =>
                    _mostrarInvitacion(context, ref, i.codigo, negocio),
                trailing: TextButton(
                  onPressed: () async {
                    try {
                      await ref
                          .read(equipoRepositorioProvider)
                          .anular(i.codigo);
                    } on EquipoException {
                      // Ya se usó o venció: la lista se actualiza igual.
                    }
                    ref.invalidate(equipoNegocioProvider(negocioId));
                  },
                  child: Text(t.equipoAnular),
                ),
              ),
          ],
        ],
      ),
      AsyncLoading() => const Center(child: CircularProgressIndicator()),
      _ => Center(child: Text(t.errorSinConexion)),
    };
  }
}

/// «Tengo un código de equipo»: pide el código (o el enlace) y abre
/// [UnirmeEquipoScreen].
Future<void> pedirCodigoEquipo(BuildContext context) async {
  final t = context.t;
  final texto = TextEditingController();
  final codigo = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.equipoTengoCodigo),
      content: TextField(
        controller: texto,
        autofocus: true,
        textCapitalization: TextCapitalization.characters,
        decoration: InputDecoration(labelText: t.equipoCodigo),
        onSubmitted: (v) => Navigator.pop(context, v),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancelar),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, texto.text),
          child: Text(t.unirmeEquipoBoton),
        ),
      ],
    ),
  );
  texto.dispose();
  if (codigo == null || !context.mounted) return;
  // Inválido también abre la pantalla, que explica qué pasó.
  await context.push(Rutas.unirmeEquipo(codigoEquipo(codigo) ?? codigo.trim()));
}

/// `/equipo/<código>`: sumarse al equipo de un negocio (D117).
class UnirmeEquipoScreen extends ConsumerStatefulWidget {
  const UnirmeEquipoScreen({required this.codigo, super.key});

  final String codigo;

  @override
  ConsumerState<UnirmeEquipoScreen> createState() => _UnirmeEquipoState();
}

class _UnirmeEquipoState extends ConsumerState<UnirmeEquipoScreen> {
  bool _uniendo = false;
  String? _error;

  Future<void> _unirme(String codigo) async {
    final t = context.t;
    setState(() {
      _uniendo = true;
      _error = null;
    });
    try {
      final negocio = await ref.read(equipoRepositorioProvider).unirme(codigo);
      ref.read(metricasProvider).track(Eventos.teamJoin, businessId: negocio);
      ref.invalidate(misNegociosProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.unirmeEquipoListo)));
      context.go(Rutas.negocio);
    } on EquipoException catch (e) {
      setState(() => _error = textoErrorEquipo(t, e.motivo));
    } finally {
      if (mounted) setState(() => _uniendo = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final codigo = codigoEquipo(widget.codigo);
    return Scaffold(
      appBar: AppBar(
        title: Text(t.unirmeEquipoTitulo),
        leading: volverSiNoHayAtras(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Icon(Icons.storefront_outlined, size: 64),
          const SizedBox(height: 16),
          ExplicacionCorta(
            id: 'unirme_equipo_texto',
            corta: t.unirmeEquipoTextoCorta,
            larga: t.unirmeEquipoTexto,
          ),
          const SizedBox(height: 24),
          if (codigo == null)
            Text(
              t.equipoErrorCodigo,
              style: TextStyle(color: tema.colorScheme.error),
            )
          else
            FilledButton(
              onPressed: _uniendo ? null : () => _unirme(codigo),
              child: Text(t.unirmeEquipoBoton),
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
