import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comunidad/comunidad_repositorio.dart';
import '../../cuenta/con_cuenta.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../fotos/elegir_foto.dart';
import '../../mascotas/catalogo.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../router.dart';
import '../../widgets/volver.dart';
import 'preguntas.dart';

String textoTipoPublicacion(AppLocalizations t, TipoPublicacion x) =>
    switch (x) {
      TipoPublicacion.pregunta => t.comunidadPregunta,
      TipoPublicacion.consejo => t.comunidadConsejo,
      TipoPublicacion.experiencia => t.comunidadExperiencia,
    };

String textoErrorComunidad(AppLocalizations t, Object e) => switch (e) {
  ComunidadException(motivo: ErrorComunidad.prohibido) => t.comunidadProhibido,
  ComunidadException(motivo: ErrorComunidad.noMiembro) => t.comunidadUnite,
  ComunidadException(motivo: ErrorComunidad.limite) => t.comunidadLimite,
  ComunidadException(motivo: ErrorComunidad.noQuiere) => t.comunidadNoQuiere,
  _ => t.errorSinConexion,
};

/// Entrada a los grupos desde Noticias → Comunidad (3.4, D116).
class TarjetaGrupos extends StatelessWidget {
  const TarjetaGrupos({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: ListTile(
        leading: const Icon(Icons.forum_outlined),
        title: Text(t.comunidadGrupos),
        subtitle: Text(t.comunidadGruposAyuda),
        trailing: const Icon(Icons.chevron_right_outlined),
        onTap: () => context.push(Rutas.grupos),
      ),
    );
  }
}

/// Las reglas, cortas, arriba de los grupos y al publicar.
class _Reglas extends StatelessWidget {
  const _Reglas();

  @override
  Widget build(BuildContext context) => Card(
    color: Theme.of(context).colorScheme.tertiaryContainer,
    child: ListTile(
      leading: const Icon(Icons.shield_outlined),
      title: Text(context.t.comunidadReglas),
    ),
  );
}

class GruposScreen extends ConsumerWidget {
  const GruposScreen({super.key});

  Future<void> _deMiRaza(BuildContext context, WidgetRef ref, int raza) async {
    final t = context.t;
    if (!await hayCuenta(
      context,
      ref,
      volverA: Rutas.grupos,
      motivo: t.comunidadIngresar,
    )) {
      return;
    }
    if (!context.mounted) return;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      final repo = ref.read(comunidadRepositorioProvider);
      final id = await repo.grupoDeRaza(raza);
      await repo.unirme(id, unirme: true);
      ref
        ..read(
          metricasProvider,
        ).track(Eventos.groupJoin, props: {'tipo': 'breed'})
        ..invalidate(gruposProvider);
      if (context.mounted) await context.push(Rutas.grupo(id));
    } on Object catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(textoErrorComunidad(t, e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final conectado = ref.watch(usuarioActualProvider).value != null;
    final pendientes = conectado
        ? (ref.watch(misSaludosProvider).value ?? const [])
              .where((s) => s.recibido && s.estado == EstadoSaludo.pendiente)
              .length
        : 0;
    final grupos = ref.watch(gruposProvider);
    final lista = grupos.value ?? const <Grupo>[];
    // Razas de mis mascotas que todavía no tienen mi grupo (no "Mestizo").
    final mascotas = conectado
        ? ref.watch(misMascotasProvider).value ?? const <Mascota>[]
        : const <Mascota>[];
    final misRazas = <int, String>{};
    for (final m in mascotas) {
      final id = m.razaId;
      if (id == null) continue;
      final nombre = (ref.watch(razasProvider(m.especieId)).value ?? const [])
          .where((r) => r.id == id)
          .firstOrNull
          ?.nombre;
      if (nombre == null || nombre.toLowerCase().startsWith('mestiz')) continue;
      if (lista.any((g) => g.razaId == id && g.soyMiembro)) continue;
      misRazas[id] = nombre;
    }

    Widget seccion(String titulo, Iterable<Grupo> grupos) => Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 4),
          child: Text(titulo, style: tema.textTheme.titleMedium),
        ),
        for (final g in grupos) _FilaGrupo(grupo: g),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.comunidadGrupos),
        actions: [
          if (conectado)
            IconButton(
              tooltip: t.comunidadSaludos,
              onPressed: () => context.push(Rutas.saludos),
              icon: Badge(
                isLabelVisible: pendientes > 0,
                label: Text('$pendientes'),
                child: const Icon(Icons.waving_hand_outlined),
              ),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(gruposProvider.future),
        child: switch (grupos) {
          AsyncError() when lista.isEmpty => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(t.errorSinConexion),
              ),
            ],
          ),
          AsyncLoading() when lista.isEmpty => const Center(
            child: CircularProgressIndicator(),
          ),
          _ => ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const _Reglas(),
              if (misRazas.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(t.comunidadTuRaza, style: tema.textTheme.titleMedium),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final MapEntry(key: id, value: nombre)
                        in misRazas.entries)
                      ActionChip(
                        avatar: const Icon(Icons.add_outlined, size: 18),
                        label: Text(nombre),
                        onPressed: () => _deMiRaza(context, ref, id),
                      ),
                  ],
                ),
              ],
              if (lista.any((g) => g.soyMiembro))
                seccion(t.comunidadMisGrupos, lista.where((g) => g.soyMiembro)),
              seccion(
                t.comunidadPorEspecie,
                lista.where((g) => g.tipo == TipoGrupo.especie),
              ),
              seccion(
                t.comunidadTemas,
                lista.where((g) => g.tipo == TipoGrupo.tema),
              ),
              if (lista.any((g) => g.tipo == TipoGrupo.raza))
                seccion(
                  t.comunidadPorRaza,
                  lista.where((g) => g.tipo == TipoGrupo.raza),
                ),
            ],
          ),
        },
      ),
    );
  }
}

class _FilaGrupo extends StatelessWidget {
  const _FilaGrupo({required this.grupo});

  final Grupo grupo;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Card(
      child: ListTile(
        leading: CircleAvatar(child: Text(grupo.icono ?? '🐾')),
        title: Text(grupo.nombre),
        subtitle: Text(
          [
            t.comunidadMiembros(grupo.miembros),
            if (grupo.publicacionesSemana > 0)
              t.comunidadActividad(grupo.publicacionesSemana),
          ].join(' · '),
        ),
        trailing: grupo.soyMiembro
            ? const Icon(Icons.check_circle_outline)
            : const Icon(Icons.chevron_right_outlined),
        onTap: () => context.push(Rutas.grupo(grupo.id)),
      ),
    );
  }
}

class GrupoScreen extends ConsumerWidget {
  const GrupoScreen({required this.grupoId, super.key});

  final String grupoId;

  Future<void> _unirme(
    BuildContext context,
    WidgetRef ref, {
    required bool unirme,
  }) async {
    final t = context.t;
    if (!await hayCuenta(
      context,
      ref,
      volverA: Rutas.grupo(grupoId),
      motivo: t.comunidadIngresar,
    )) {
      return;
    }
    if (!context.mounted) return;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(comunidadRepositorioProvider)
          .unirme(grupoId, unirme: unirme);
      if (unirme) {
        ref.read(metricasProvider).track(Eventos.groupJoin);
      }
    } on Object catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(textoErrorComunidad(t, e))));
    }
    ref.invalidate(gruposProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final grupo = (ref.watch(gruposProvider).value ?? const <Grupo>[])
        .where((g) => g.id == grupoId)
        .firstOrNull;
    final miembro = grupo?.soyMiembro ?? false;
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(grupo?.nombre ?? t.comunidadGrupos),
        actions: [
          if (miembro)
            PopupMenuButton<void>(
              itemBuilder: (_) => [
                PopupMenuItem(
                  onTap: () => _unirme(context, ref, unirme: false),
                  child: Text(t.comunidadSalir),
                ),
              ],
            ),
        ],
      ),
      floatingActionButton: miembro
          ? FloatingActionButton.extended(
              onPressed: () => context.push(Rutas.publicarEnGrupo(grupoId)),
              icon: const Icon(Icons.edit_outlined),
              label: Text(t.comunidadPublicar),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(publicacionesProvider(grupoId).future),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
          children: [
            if (grupo?.descripcion case final d?)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(d),
              ),
            if (grupo != null && !miembro)
              FilledButton.icon(
                onPressed: () => _unirme(context, ref, unirme: true),
                icon: const Icon(Icons.group_add_outlined),
                label: Text(t.comunidadUnirme),
              ),
            switch (ref.watch(publicacionesProvider(grupoId))) {
              AsyncData(value: final lista) when lista.isEmpty => Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  t.comunidadSinPublicaciones,
                  textAlign: TextAlign.center,
                ),
              ),
              AsyncData(value: final lista) => Column(
                children: [
                  for (final p in lista) TarjetaPublicacion(publicacion: p),
                ],
              ),
              AsyncError() => Padding(
                padding: const EdgeInsets.all(24),
                child: Text(t.errorSinConexion),
              ),
              _ => const Padding(
                padding: EdgeInsets.all(24),
                child: Center(child: CircularProgressIndicator()),
              ),
            },
          ],
        ),
      ),
    );
  }
}

/// Fecha corta: «28 oct.».
String _cuando(BuildContext context, DateTime d) =>
    MaterialLocalizations.of(context).formatShortMonthDay(d);

class TarjetaPublicacion extends ConsumerWidget {
  const TarjetaPublicacion({
    required this.publicacion,
    this.completa = false,
    super.key,
  });

  final Publicacion publicacion;

  /// En el detalle: todo el texto y sin ir a otro lado al tocar.
  final bool completa;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final p = publicacion;
    final repo = ref.watch(comunidadRepositorioProvider);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: completa
            ? null
            : () => context.push(Rutas.publicacionComunidad(p.id)),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                [
                  textoTipoPublicacion(t, p.tipo),
                  p.autor ?? t.comunidadAlguien,
                  _cuando(context, p.creada),
                ].join(' · '),
                style: tema.textTheme.labelMedium,
              ),
              const SizedBox(height: 4),
              Text(
                p.texto,
                maxLines: completa ? null : 5,
                overflow: completa ? null : TextOverflow.ellipsis,
              ),
              if (p.fotos.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  height: completa ? 220 : 120,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: [
                      for (final f in p.fotos)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              repo.urlFoto(f),
                              fit: BoxFit.cover,
                              semanticLabel: t.comunidadFoto,
                              errorBuilder: (_, _, _) => const SizedBox(
                                width: 120,
                                child: Icon(Icons.broken_image_outlined),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
              if (!completa) ...[
                const SizedBox(height: 6),
                Text(
                  t.comunidadComentarios(p.cantidadComentarios),
                  style: tema.textTheme.bodySmall,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Reportar, saludar o borrar una publicación o un comentario.
Future<void> _acciones(
  BuildContext context,
  WidgetRef ref, {
  required String tipo,
  required String id,
  required bool esMio,
  required VoidCallback despues,
}) async {
  final t = context.t;
  final accion = await showModalBottomSheet<String>(
    context: context,
    useRootNavigator: true,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => SafeArea(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (esMio)
              ListTile(
                leading: const Icon(Icons.delete_outline),
                title: Text(t.comunidadBorrar),
                onTap: () => Navigator.pop(context, 'borrar'),
              )
            else ...[
              ListTile(
                leading: const Icon(Icons.waving_hand_outlined),
                title: Text(t.comunidadSaludar),
                subtitle: Text(t.comunidadSaludarAyuda),
                onTap: () => Navigator.pop(context, 'saludar'),
              ),
              for (final (clave, texto) in [
                ('venta', t.comunidadMotivoVenta),
                ('ofensivo', t.chatMotivoOfensivo),
                ('ubicacion', t.comunidadMotivoUbicacion),
                ('otro', t.chatMotivoOtro),
              ])
                ListTile(
                  leading: const Icon(Icons.flag_outlined),
                  title: Text(t.comunidadReportar(texto)),
                  onTap: () => Navigator.pop(context, 'reportar:$clave'),
                ),
            ],
          ],
        ),
      ),
    ),
  );
  if (accion == null || !context.mounted) return;
  final repo = ref.read(comunidadRepositorioProvider);
  final mensajes = ScaffoldMessenger.of(context);
  try {
    if (accion == 'borrar') {
      await repo.borrar(tipo, id);
      mensajes.showSnackBar(SnackBar(content: Text(t.comunidadBorrado)));
    } else if (accion == 'saludar') {
      final mensaje = await _pedirSaludo(context);
      if (mensaje == null) return;
      await repo.saludar(tipo, id, mensaje);
      ref
        ..read(metricasProvider).track(Eventos.greetingSend)
        ..invalidate(misSaludosProvider);
      mensajes.showSnackBar(SnackBar(content: Text(t.comunidadSaludado)));
    } else {
      final motivo = accion.substring('reportar:'.length);
      await repo.reportar(tipo, id, motivo);
      ref
          .read(metricasProvider)
          .track(
            Eventos.contentFlag,
            props: {'target_type': tipo, 'motivo': motivo},
          );
      mensajes.showSnackBar(SnackBar(content: Text(t.chatReportado)));
    }
    despues();
  } on Object catch (e) {
    mensajes.showSnackBar(SnackBar(content: Text(textoErrorComunidad(t, e))));
  }
}

Future<String?> _pedirSaludo(BuildContext context) async {
  final t = context.t;
  final texto = TextEditingController(text: t.comunidadSaludoInicial);
  final mensaje = await showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(t.comunidadSaludar),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(controller: texto, maxLength: 200, maxLines: 3),
          Text(
            t.comunidadSaludarAyuda,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(t.cancelar),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, texto.text.trim()),
          child: Text(t.comunidadMandarSaludo),
        ),
      ],
    ),
  );
  texto.dispose();
  return (mensaje?.isEmpty ?? true) ? null : mensaje;
}

class PublicacionScreen extends ConsumerStatefulWidget {
  const PublicacionScreen({required this.publicacionId, super.key});

  final String publicacionId;

  @override
  ConsumerState<PublicacionScreen> createState() => _PublicacionScreenState();
}

class _PublicacionScreenState extends ConsumerState<PublicacionScreen> {
  final _comentario = TextEditingController();
  var _enviando = false;

  @override
  void dispose() {
    _comentario.dispose();
    super.dispose();
  }

  void _recargar(String? grupoId) {
    ref.invalidate(publicacionProvider(widget.publicacionId));
    if (grupoId != null) ref.invalidate(publicacionesProvider(grupoId));
  }

  Future<void> _comentar(Publicacion p) async {
    final t = context.t;
    final texto = _comentario.text.trim();
    if (texto.isEmpty) return;
    if (textoProhibidoComunidad(texto)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.comunidadProhibido)));
      return;
    }
    setState(() => _enviando = true);
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref.read(comunidadRepositorioProvider).comentar(p.id, texto);
      ref.read(metricasProvider).track(Eventos.commentCreate);
      if (p.tipo == TipoPublicacion.pregunta) {
        ref.read(metricasProvider).track(Eventos.questionAnswer);
      }
      _comentario.clear();
      _recargar(p.grupoId);
    } on Object catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(textoErrorComunidad(t, e))));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  /// Quien preguntó marca (o desmarca) la respuesta que le sirvió (D134).
  Future<void> _marcar(Publicacion p, Comentario c) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    final marcar = p.respuestaMarcadaId != c.id;
    try {
      await ref
          .read(comunidadRepositorioProvider)
          .marcarRespuesta(p.id, marcar ? c.id : null);
      if (marcar) ref.read(metricasProvider).track(Eventos.questionSolved);
      _recargar(p.grupoId);
      ref.invalidate(preguntasProvider);
    } on Object catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(textoErrorComunidad(t, e))));
    }
  }

  /// En una pregunta, unirse al grupo para responder sin salir (D134).
  Future<void> _unirmeYResponder(Publicacion p) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    if (!await hayCuenta(
      context,
      ref,
      volverA: Rutas.publicacionComunidad(p.id),
      motivo: t.preguntasMotivoCuenta,
    )) {
      return;
    }
    try {
      await ref
          .read(comunidadRepositorioProvider)
          .unirme(p.grupoId!, unirme: true);
      ref.invalidate(gruposProvider);
      _recargar(p.grupoId);
    } on Object catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(textoErrorComunidad(t, e))));
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final conectado = ref.watch(usuarioActualProvider).value != null;
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(
          ref
                  .watch(publicacionProvider(widget.publicacionId))
                  .value
                  ?.grupoNombre ??
              t.comunidadGrupos,
        ),
      ),
      body: switch (ref.watch(publicacionProvider(widget.publicacionId))) {
        AsyncData(value: final p?) => Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  TarjetaPublicacion(publicacion: p, completa: true),
                  if (p.tema case final tm?)
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          avatar: Icon(iconoTema(tm), size: 18),
                          label: Text(textoTema(t, tm)),
                        ),
                        if (p.resuelta)
                          Chip(
                            avatar: const Icon(Icons.check_circle_outline),
                            label: Text(t.preguntasResuelta),
                          ),
                      ],
                    ),
                  if (conectado)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        onPressed: () => _acciones(
                          context,
                          ref,
                          tipo: 'post',
                          id: p.id,
                          esMio: p.esMia,
                          despues: () {
                            _recargar(p.grupoId);
                            if (p.esMia && context.mounted) context.pop();
                          },
                        ),
                        icon: const Icon(Icons.more_horiz_outlined),
                        label: Text(t.comunidadOpciones),
                      ),
                    ),
                  Text(
                    t.comunidadComentarios(p.comentarios.length),
                    style: tema.textTheme.titleSmall,
                  ),
                  for (final c in p.comentarios)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: c.id == p.respuestaMarcadaId
                          ? Icon(
                              Icons.check_circle,
                              color: tema.colorScheme.primary,
                              semanticLabel: t.preguntasLeSirvio,
                            )
                          : null,
                      title: Text(c.texto),
                      subtitle: Text(
                        [
                          c.autor ?? t.comunidadAlguien,
                          _cuando(context, c.creado),
                          if (c.id == p.respuestaMarcadaId) t.preguntasLeSirvio,
                        ].join(' · '),
                      ),
                      trailing: conectado
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Solo quien preguntó, en las respuestas de otros.
                                if (p.esMia &&
                                    p.tipo == TipoPublicacion.pregunta &&
                                    !c.esMio)
                                  TextButton(
                                    onPressed: () => _marcar(p, c),
                                    child: Text(
                                      c.id == p.respuestaMarcadaId
                                          ? t.preguntasDesmarcar
                                          : t.preguntasMeSirvio,
                                    ),
                                  ),
                                IconButton(
                                  tooltip: t.comunidadOpciones,
                                  icon: const Icon(Icons.more_vert_outlined),
                                  onPressed: () => _acciones(
                                    context,
                                    ref,
                                    tipo: 'comment',
                                    id: c.id,
                                    esMio: c.esMio,
                                    despues: () => _recargar(p.grupoId),
                                  ),
                                ),
                              ],
                            )
                          : null,
                    ),
                ],
              ),
            ),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 8, 8),
                child: p.soyMiembro
                    ? Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _comentario,
                              maxLength: 1000,
                              minLines: 1,
                              maxLines: 4,
                              decoration: InputDecoration(
                                hintText: t.comunidadComentar,
                                counterText: '',
                              ),
                            ),
                          ),
                          IconButton(
                            tooltip: t.comunidadComentar,
                            onPressed: _enviando ? null : () => _comentar(p),
                            icon: const Icon(Icons.send_outlined),
                          ),
                        ],
                      )
                    : p.tipo == TipoPublicacion.pregunta && p.grupoId != null
                    // En las preguntas se responde sin salir (D134).
                    ? OutlinedButton(
                        onPressed: () => _unirmeYResponder(p),
                        child: Text(t.preguntasUnirmeResponder),
                      )
                    : OutlinedButton(
                        onPressed: p.grupoId == null
                            ? null
                            : () => context.push(Rutas.grupo(p.grupoId!)),
                        child: Text(t.comunidadUnite),
                      ),
              ),
            ),
          ],
        ),
        AsyncData() => Center(child: Text(t.comunidadNoDisponible)),
        AsyncError() => Center(child: Text(t.errorSinConexion)),
        _ => const Center(child: CircularProgressIndicator()),
      },
    );
  }
}

class NuevaPublicacionScreen extends ConsumerStatefulWidget {
  const NuevaPublicacionScreen({required this.grupoId, super.key});

  final String grupoId;

  @override
  ConsumerState<NuevaPublicacionScreen> createState() =>
      _NuevaPublicacionState();
}

class _NuevaPublicacionState extends ConsumerState<NuevaPublicacionScreen> {
  var _tipo = TipoPublicacion.pregunta;
  final _texto = TextEditingController();
  final _fotos = <String>[];
  var _enviando = false;
  String? _error;

  @override
  void dispose() {
    _texto.dispose();
    super.dispose();
  }

  Future<void> _agregarFoto() async {
    final original = await elegirFoto(context, ref);
    if (original == null) return;
    // Achica y borra el EXIF (D28): nunca se sube la ubicación de la foto.
    final preparada = prepararFoto(original);
    if (preparada == null) return;
    setState(() => _enviando = true);
    try {
      final ruta = await ref
          .read(comunidadRepositorioProvider)
          .subirFoto(preparada);
      setState(() => _fotos.add(ruta));
    } on Object {
      if (mounted) setState(() => _error = context.t.errorSinConexion);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  Future<void> _publicar() async {
    final t = context.t;
    final texto = _texto.text.trim();
    if (texto.isEmpty) return;
    if (textoProhibidoComunidad(texto)) {
      setState(() => _error = t.comunidadProhibido);
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      final id = await ref
          .read(comunidadRepositorioProvider)
          .publicar(
            grupoId: widget.grupoId,
            tipo: _tipo,
            texto: texto,
            fotos: _fotos,
          );
      ref
        ..read(metricasProvider).track(
          Eventos.postCreate,
          props: {'tipo': _tipo.base, 'fotos': _fotos.length},
        )
        ..invalidate(publicacionesProvider(widget.grupoId))
        ..invalidate(gruposProvider);
      if (mounted) context.pushReplacement(Rutas.publicacionComunidad(id));
    } on Object catch (e) {
      if (mounted) setState(() => _error = textoErrorComunidad(t, e));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final repo = ref.watch(comunidadRepositorioProvider);
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.comunidadPublicar),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _Reglas(),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              for (final x in TipoPublicacion.values)
                ChoiceChip(
                  label: Text(textoTipoPublicacion(t, x)),
                  selected: _tipo == x,
                  onSelected: (_) => setState(() => _tipo = x),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _texto,
            maxLength: 2000,
            minLines: 4,
            maxLines: 10,
            decoration: InputDecoration(labelText: t.comunidadTexto),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final f in _fotos)
                InputChip(
                  avatar: CircleAvatar(
                    backgroundImage: NetworkImage(repo.urlFoto(f)),
                  ),
                  label: Text(t.comunidadFoto),
                  onDeleted: () => setState(() => _fotos.remove(f)),
                ),
              if (_fotos.length < 4)
                OutlinedButton.icon(
                  onPressed: _enviando ? null : _agregarFoto,
                  icon: const Icon(Icons.add_a_photo_outlined),
                  label: Text(t.comunidadAgregarFoto),
                ),
            ],
          ),
          if (_error case final e?)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                e,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _enviando ? null : _publicar,
            child: Text(t.comunidadPublicar),
          ),
        ],
      ),
    );
  }
}

/// Los saludos que recibí (aceptar abre el chat) y los que mandé.
class SaludosScreen extends ConsumerWidget {
  const SaludosScreen({super.key});

  Future<void> _responder(
    BuildContext context,
    WidgetRef ref,
    Saludo s, {
    required bool aceptar,
  }) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      final chat = await ref
          .read(comunidadRepositorioProvider)
          .responderSaludo(s.id, aceptar: aceptar);
      ref
        ..read(
          metricasProvider,
        ).track(Eventos.greetingAnswer, props: {'acepta': aceptar})
        ..invalidate(misSaludosProvider);
      if (chat != null && context.mounted) await context.push(Rutas.chat(chat));
    } on Object catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(textoErrorComunidad(t, e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.comunidadSaludos),
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(misSaludosProvider.future),
        child: switch (ref.watch(misSaludosProvider)) {
          AsyncData(value: final lista) when lista.isEmpty => ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Text(t.comunidadSinSaludos, textAlign: TextAlign.center),
            ],
          ),
          AsyncData(value: final lista) => ListView(
            padding: const EdgeInsets.all(8),
            children: [
              for (final s in lista)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          s.recibido
                              ? t.comunidadSaludoDe(
                                  s.persona ?? t.comunidadAlguien,
                                )
                              : t.comunidadSaludoA(
                                  s.persona ?? t.comunidadAlguien,
                                ),
                          style: tema.textTheme.titleSmall,
                        ),
                        Text(s.mensaje),
                        if (s.publicacionTexto case final p?)
                          Text(
                            t.comunidadSobre(p),
                            style: tema.textTheme.bodySmall,
                          ),
                        const SizedBox(height: 4),
                        switch ((s.recibido, s.estado)) {
                          (true, EstadoSaludo.pendiente) => Wrap(
                            spacing: 8,
                            children: [
                              FilledButton(
                                onPressed: () =>
                                    _responder(context, ref, s, aceptar: true),
                                child: Text(t.comunidadAceptarSaludo),
                              ),
                              OutlinedButton(
                                onPressed: () =>
                                    _responder(context, ref, s, aceptar: false),
                                child: Text(t.comunidadAhoraNo),
                              ),
                            ],
                          ),
                          (_, EstadoSaludo.aceptado) when s.chatId != null =>
                            FilledButton.tonalIcon(
                              onPressed: () =>
                                  context.push(Rutas.chat(s.chatId!)),
                              icon: const Icon(Icons.chat_outlined),
                              label: Text(t.cuidadoChat),
                            ),
                          (false, EstadoSaludo.pendiente) => Text(
                            t.comunidadEsperando,
                            style: tema.textTheme.bodySmall,
                          ),
                          (_, EstadoSaludo.rechazado) => Text(
                            t.comunidadNoAhora,
                            style: tema.textTheme.bodySmall,
                          ),
                          _ => const SizedBox.shrink(),
                        },
                      ],
                    ),
                  ),
                ),
            ],
          ),
          AsyncError() => ListView(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(t.errorSinConexion),
              ),
            ],
          ),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
