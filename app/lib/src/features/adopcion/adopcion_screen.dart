import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../adopcion/adopcion_repositorio.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../fotos/elegir_foto.dart';
import '../../legal/legal.dart';
import '../../mascotas/catalogo.dart';
import '../../mascotas/mascotas_repositorio.dart';
import '../../metricas/metricas.dart';
import '../../recordatorios/recordatorios_repositorio.dart';
import '../../router.dart';
import '../../utiles/enlaces.dart';
import '../../widgets/explicacion_corta.dart';
import '../../widgets/volver.dart';
import '../legal/legal_screen.dart';
import 'pack_screen.dart';

String textoEtapa(AppLocalizations t, EtapaAdopcion e) => switch (e) {
  EtapaAdopcion.interest => t.etapaInterest,
  EtapaAdopcion.questionnaire => t.etapaQuestionnaire,
  EtapaAdopcion.interview => t.etapaInterview,
  EtapaAdopcion.visit => t.etapaVisit,
  EtapaAdopcion.agreement => t.etapaAgreement,
  EtapaAdopcion.adopted => t.etapaAdopted,
  EtapaAdopcion.rejected => t.etapaRejected,
  EtapaAdopcion.withdrawn => t.etapaWithdrawn,
};

String textoCompat(AppLocalizations t, AvisoCompatibilidad a) => switch (a) {
  AvisoCompatibilidad.necesitaPatio => t.compatPatio,
  AvisoCompatibilidad.noConNinos => t.compatNinos,
  AvisoCompatibilidad.noConOtrosAnimales => t.compatAnimales,
  AvisoCompatibilidad.muchoTiempoSolo => t.compatSolo,
  AvisoCompatibilidad.casaNoDeAcuerdo => t.compatCasa,
  AvisoCompatibilidad.sinExperienciaConNecesidades => t.compatExperiencia,
};

String textoEdadAdopcion(AppLocalizations t, int meses) =>
    meses >= 24 ? t.adopcionEdadAnios(meses ~/ 12) : t.adopcionEdad(meses);

String? _textoTamano(AppLocalizations t, String? v) => switch (v) {
  'chico' => t.adopcionChico,
  'mediano' => t.adopcionMediano,
  'grande' => t.adopcionGrande,
  _ => null,
};

String? _textoEnergia(AppLocalizations t, String? v) => switch (v) {
  'baja' => t.adopcionEnergiaBaja,
  'media' => t.adopcionEnergiaMedia,
  'alta' => t.adopcionEnergiaAlta,
  _ => null,
};

String _mensajeError(AppLocalizations t, AdopcionException e) =>
    switch (e.motivo) {
      ErrorAdopcion.limite => t.adopcionLimite,
      ErrorAdopcion.noDisponible => t.adopcionNoDisponible,
      ErrorAdopcion.datos => t.publicarDatos,
      ErrorAdopcion.sinConexion => t.errorSinConexion,
    };

/// Adopción responsable (2.0, D79): Adoptar · Mis solicitudes · Dar en adopción.
class AdopcionScreen extends ConsumerWidget {
  const AdopcionScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final conectado = ref.watch(conectadoProvider);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: volverSiNoHayAtras(context),
          title: Text(t.adopcionTitulo),
          actions: [
            IconButton(
              tooltip: t.adopcionGuia,
              onPressed: () => context.push('${Rutas.adopcion}/guia'),
              icon: const Icon(Icons.menu_book_outlined),
            ),
            IconButton(
              tooltip: t.adopcionCalculadora,
              onPressed: () => context.push('${Rutas.adopcion}/calculadora'),
              icon: const Icon(Icons.calculate_outlined),
            ),
            if (conectado)
              IconButton(
                tooltip: t.transitoTitulo,
                onPressed: () => context.push(Rutas.hogarTransito),
                icon: const Icon(Icons.house_outlined),
              ),
            if (conectado)
              IconButton(
                tooltip: t.adopcionMiPerfil,
                onPressed: () => context.push('${Rutas.adopcion}/perfil'),
                icon: const Icon(Icons.badge_outlined),
              ),
          ],
          bottom: TabBar(
            tabs: [
              Tab(text: t.adopcionAdoptar),
              Tab(text: t.adopcionMias),
              Tab(text: t.adopcionPublicar),
            ],
          ),
        ),
        body: const TabBarView(
          children: [_Disponibles(), _MisSolicitudes(), _DarEnAdopcion()],
        ),
      ),
    );
  }
}

class _Foto extends ConsumerWidget {
  const _Foto(this.ruta, {this.alto = 160});

  final String? ruta;
  final double alto;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final r = ruta;
    final vacio = SizedBox(
      height: alto,
      child: const Icon(Icons.volunteer_activism_outlined, size: 48),
    );
    if (r == null) return vacio;
    return Image.network(
      ref.watch(adopcionRepositorioProvider).urlFoto(r),
      height: alto,
      width: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => vacio,
    );
  }
}

class _Disponibles extends ConsumerWidget {
  const _Disponibles();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final especies = ref.watch(especiesProvider).value ?? const <Especie>[];
    final elegida = ref.watch(especieAdopcionProvider);
    return Column(
      children: [
        SizedBox(
          height: 52,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            children: [
              ChoiceChip(
                label: Text(t.adopcionTodas),
                selected: elegida == null,
                onSelected: (_) =>
                    ref.read(especieAdopcionProvider.notifier).elegir(null),
              ),
              for (final e in especies) ...[
                const SizedBox(width: 6),
                ChoiceChip(
                  label: Text('${e.icono} ${e.nombre}'),
                  selected: elegida == e.id,
                  onSelected: (_) =>
                      ref.read(especieAdopcionProvider.notifier).elegir(e.id),
                ),
              ],
            ],
          ),
        ),
        Expanded(
          child: switch (ref.watch(disponiblesProvider)) {
            AsyncData(value: final lista) when lista.isEmpty => Center(
              child: Text(t.adopcionVacio),
            ),
            AsyncData(value: final lista) => ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final a in lista)
                  Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () =>
                          context.push('${Rutas.adopcion}/animal/${a.id}'),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _Foto(a.fotos.firstOrNull),
                          ListTile(
                            title: Text(a.nombre ?? '🐾'),
                            subtitle: Text(
                              [
                                if (a.edadMeses case final m?)
                                  textoEdadAdopcion(t, m),
                                _textoTamano(t, a.tamano),
                                if (a.deRefugio) a.refugio,
                                if (a.enTransito) t.transitoEnUno,
                              ].nonNulls.join(' · '),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            AsyncLoading() => const Center(child: CircularProgressIndicator()),
            _ => Center(child: Text(t.errorSinConexion)),
          },
        ),
      ],
    );
  }
}

/// Ficha de un animal en adopción, con la compatibilidad (03 §11).
class AnimalAdopcionScreen extends ConsumerWidget {
  const AnimalAdopcionScreen({required this.animalId, super.key});

  final String animalId;

  Future<void> _meInteresa(
    BuildContext context,
    WidgetRef ref,
    AnimalAdopcion a,
  ) async {
    final t = context.t;
    if (!ref.read(conectadoProvider)) {
      await context.push(
        Rutas.ingresarYVolverA('${Rutas.adopcion}/animal/${a.id}'),
      );
      return;
    }
    final perfil = await ref.read(perfilAdoptanteProvider.future);
    if (!context.mounted) return;
    if (perfil == null || !perfil.completo) {
      // El perfil explica arriba para qué se usa (un aviso abajo taparía
      // el botón de guardar).
      await context.push('${Rutas.adopcion}/perfil');
      return;
    }
    final mensaje = TextEditingController();
    final enviar = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(t.adopcionMeInteresa),
        content: TextField(
          controller: mensaje,
          maxLength: 1000,
          minLines: 2,
          maxLines: 5,
          decoration: InputDecoration(labelText: t.adopcionMensaje),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.cancelar),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.adopcionMeInteresa),
          ),
        ],
      ),
    );
    if (!(enviar ?? false) || !context.mounted) return;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(adopcionRepositorioProvider)
          .meInteresa(
            a.id,
            mensaje: mensaje.text.trim().isEmpty ? null : mensaje.text.trim(),
          );
      ref.read(metricasProvider).track(Eventos.adoptionInterest);
      ref.invalidate(misSolicitudesProvider);
      mensajes.showSnackBar(SnackBar(content: Text(t.adopcionEnviado)));
    } on AdopcionException catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(_mensajeError(t, e))));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final a = (ref.watch(disponiblesProvider).value ?? const <AnimalAdopcion>[])
        .where((x) => x.id == animalId)
        .firstOrNull;
    if (a == null) {
      return Scaffold(
        appBar: AppBar(leading: volverSiNoHayAtras(context)),
        body: Center(
          child: ref.watch(disponiblesProvider).isLoading
              ? const CircularProgressIndicator()
              : Text(t.adopcionNoDisponible),
        ),
      );
    }
    final perfil = ref.watch(perfilAdoptanteProvider).value;
    final avisos = perfil == null ? null : compatibilidad(perfil, a);
    final datos = [
      if (a.castrado == true) t.adopcionCastrado,
      if (a.vacunado == true) t.adopcionVacunado,
      if (a.microchip == true) t.adopcionConChip,
      if (a.conNinos == true) t.adopcionConNinos,
      if (a.conPerros == true) t.adopcionConPerros,
      if (a.conGatos == true) t.adopcionConGatos,
      if (a.necesitaPatio) t.adopcionNecesitaPatio,
      if (a.camada) t.adopcionCamada,
    ];
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(a.nombre ?? t.adopcionTitulo),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 240,
            child: PageView(
              children: [for (final f in a.fotos) _Foto(f, alto: 240)],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  [
                    if (a.edadMeses case final m?) textoEdadAdopcion(t, m),
                    _textoTamano(t, a.tamano),
                    _textoEnergia(t, a.energia),
                    ?a.raza,
                  ].nonNulls.join(' · '),
                  style: tema.textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  a.deRefugio
                      ? t.adopcionRefugio(a.refugio ?? '')
                      : t.adopcionParticular,
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [for (final d in datos) Chip(label: Text(d))],
                ),
                if (a.descripcion case final d?) ...[
                  const SizedBox(height: 12),
                  Text(d),
                ],
                if (a.necesidades case final n?) ...[
                  const SizedBox(height: 12),
                  Text(t.adopcionNecesidades, style: tema.textTheme.titleSmall),
                  Text(n),
                ],
                if (a.requisitos case final r?) ...[
                  const SizedBox(height: 12),
                  Text(t.adopcionRequisitos, style: tema.textTheme.titleSmall),
                  Text(r),
                ],
                if (a.aporte case final monto?) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.volunteer_activism_outlined),
                      title: Text(
                        t.adopcionAporte('$monto', a.aporteCubre ?? ''),
                      ),
                      subtitle: Text(t.adopcionAporteAyuda),
                    ),
                  ),
                ],
                if (avisos != null) ...[
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (avisos.isEmpty)
                            Text(t.compatBuena)
                          else
                            for (final aviso in avisos)
                              Text(textoCompat(t, aviso)),
                          const SizedBox(height: 4),
                          Text(t.compatNota, style: tema.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                if (!a.mio)
                  FilledButton.icon(
                    onPressed: () => _meInteresa(context, ref, a),
                    icon: const Icon(Icons.favorite_border),
                    label: Text(t.adopcionMeInteresa),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MisSolicitudes extends ConsumerWidget {
  const _MisSolicitudes();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final hoy = ref.watch(relojProvider)();
    final seguimientos =
        (ref.watch(misSeguimientosProvider).value ?? const <Seguimiento>[])
            .where((s) => s.disponible(hoy))
            .toList();
    return switch (ref.watch(misSolicitudesProvider)) {
      AsyncData(value: final lista)
          when lista.isEmpty && seguimientos.isEmpty =>
        Center(child: Text(t.adopcionSinSolicitudes)),
      AsyncData(value: final lista) => ListView(
        padding: const EdgeInsets.all(12),
        children: [
          for (final s in seguimientos)
            Card(
              child: ListTile(
                leading: const Icon(Icons.favorite_outline),
                title: Text(t.adopcionSeguimiento(s.animal ?? '')),
                subtitle: Text(t.adopcionSeguimientoDia(s.dia)),
                trailing: const Icon(Icons.chevron_right_outlined),
                onTap: () => _responderSeguimiento(context, ref, s),
              ),
            ),
          if (lista.any((s) => s.etapa == EtapaAdopcion.adopted))
            const TarjetaPackAdopcion(),
          for (final s in lista)
            Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      s.nombre ?? '🐾',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Text(textoEtapa(t, s.etapa)),
                    if (s.etapa == EtapaAdopcion.agreement)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: FilledButton(
                          onPressed: () => context.push(
                            '${Rutas.adopcion}/compromiso/${s.id}',
                          ),
                          child: Text(t.adopcionVerCompromiso),
                        ),
                      )
                    else if (!s.etapa.terminada)
                      TextButton(
                        onPressed: () async {
                          await ref
                              .read(adopcionRepositorioProvider)
                              .avanzar(s.id, EtapaAdopcion.withdrawn);
                          ref.invalidate(misSolicitudesProvider);
                        },
                        child: Text(t.adopcionRetirar),
                      ),
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

  Future<void> _responderSeguimiento(
    BuildContext context,
    WidgetRef ref,
    Seguimiento s,
  ) async {
    final t = context.t;
    final texto = TextEditingController();
    String? foto;
    final enviar = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(t.adopcionSeguimiento(s.animal ?? '')),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.adopcionSeguimientoTexto),
              TextField(controller: texto, maxLength: 1000, maxLines: 4),
              TextButton.icon(
                onPressed: () async {
                  final original = await elegirFoto(context, ref);
                  if (original == null) return;
                  final preparada = prepararFoto(original);
                  if (preparada == null) return;
                  final ruta = await ref
                      .read(adopcionRepositorioProvider)
                      .subirFoto(preparada);
                  setState(() => foto = ruta);
                },
                icon: Icon(
                  foto == null
                      ? Icons.add_a_photo_outlined
                      : Icons.check_outlined,
                ),
                label: Text(t.publicarFoto),
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
              child: Text(t.adopcionSeguimientoEnviar),
            ),
          ],
        ),
      ),
    );
    if (!(enviar ?? false) || !context.mounted) return;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(adopcionRepositorioProvider)
          .responderSeguimiento(s.id, texto.text, foto: foto);
      ref
        ..read(
          metricasProvider,
        ).track(Eventos.adoptionFollowup, props: {'dia': s.dia})
        ..invalidate(misSeguimientosProvider);
      mensajes.showSnackBar(
        SnackBar(content: Text(t.adopcionSeguimientoListo)),
      );
    } on AdopcionException catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(_mensajeError(t, e))));
    }
  }
}

class _DarEnAdopcion extends ConsumerWidget {
  const _DarEnAdopcion();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final disponibles =
        ref.watch(disponiblesProvider).value ?? const <AnimalAdopcion>[];
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        FilledButton.icon(
          onPressed: () => context.push('${Rutas.adopcion}/publicar'),
          icon: const Icon(Icons.add_outlined),
          label: Text(t.publicarTitulo),
        ),
        const SizedBox(height: 16),
        Text(t.adopcionRecibidas, style: tema.textTheme.titleMedium),
        switch (ref.watch(recibidasProvider)) {
          AsyncData(value: final lista) when lista.isEmpty => Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(t.adopcionSinRecibidas),
          ),
          AsyncData(value: final lista) => Column(
            children: [
              for (final r in lista)
                _Recibida(
                  solicitud: r,
                  animal: disponibles
                      .where((a) => a.id == r.animalId)
                      .firstOrNull,
                ),
            ],
          ),
          AsyncLoading() => const LinearProgressIndicator(),
          _ => Text(t.errorSinConexion),
        },
      ],
    );
  }
}

class _Recibida extends ConsumerWidget {
  const _Recibida({required this.solicitud, this.animal});

  final SolicitudRecibida solicitud;
  final AnimalAdopcion? animal;

  Future<void> _avanzar(WidgetRef ref, EtapaAdopcion etapa) async {
    await ref.read(adopcionRepositorioProvider).avanzar(solicitud.id, etapa);
    ref
      ..read(
        metricasProvider,
      ).track(Eventos.adoptionStage, props: {'etapa': etapa.name})
      ..invalidate(recibidasProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final r = solicitud;
    final perfil = r.perfil;
    final a = animal;
    final avisos = perfil == null || a == null
        ? null
        : compatibilidad(perfil, a);
    final nota = TextEditingController(text: r.nota);
    return Card(
      child: ExpansionTile(
        title: Text([r.animal ?? '🐾', t.adopcionDe(r.adoptante)].join(' · ')),
        subtitle: Text(textoEtapa(t, r.etapa)),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (r.mensaje case final m?) Text('«$m»'),
          if (avisos != null) ...[
            const SizedBox(height: 8),
            if (avisos.isEmpty)
              Text(t.compatBuena)
            else
              for (final aviso in avisos) Text(textoCompat(t, aviso)),
          ],
          const SizedBox(height: 8),
          TextField(
            controller: nota,
            maxLength: 4000,
            maxLines: 3,
            decoration: InputDecoration(labelText: t.adopcionNotaPrivada),
            onSubmitted: (v) async {
              await ref.read(adopcionRepositorioProvider).nota(r.id, v);
              if (context.mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text(t.adopcionNotaGuardada)));
              }
            },
          ),
          if (!r.etapa.terminada)
            Wrap(
              spacing: 8,
              children: [
                if (r.etapa.siguiente case final s?)
                  FilledButton(
                    onPressed: () => _avanzar(ref, s),
                    child: Text(t.adopcionAvanzarA(textoEtapa(t, s))),
                  ),
                OutlinedButton(
                  onPressed: () => _avanzar(ref, EtapaAdopcion.rejected),
                  child: Text(t.adopcionRechazar),
                ),
              ],
            ),
          if (r.seguimiento.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              t.adopcionSeguimientoRespuestas,
              style: tema.textTheme.titleSmall,
            ),
            for (final s in r.seguimiento)
              Text(
                '${t.adopcionSeguimientoDia(s.dia)}: '
                '${s.respuesta ?? t.adopcionSeguimientoSin}',
              ),
          ],
        ],
      ),
    );
  }
}

/// Compromiso de adopción (03 §11.5): se lee, se acepta y la mascota pasa a
/// la cuenta con sus recordatorios.
class CompromisoAdopcionScreen extends ConsumerStatefulWidget {
  const CompromisoAdopcionScreen({required this.solicitudId, super.key});

  final String solicitudId;

  @override
  ConsumerState<CompromisoAdopcionScreen> createState() =>
      _CompromisoAdopcionScreenState();
}

class _CompromisoAdopcionScreenState
    extends ConsumerState<CompromisoAdopcionScreen> {
  var _acepto = false;
  var _enviando = false;

  Future<void> _aceptar() async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    setState(() => _enviando = true);
    try {
      final mascota = await ref
          .read(adopcionRepositorioProvider)
          .aceptarCompromiso(widget.solicitudId, versionCompromisoAdopcion);
      ref
        ..read(metricasProvider).track(Eventos.adoptionCommit)
        ..invalidate(misSolicitudesProvider)
        ..invalidate(misSeguimientosProvider)
        ..invalidate(misMascotasProvider)
        ..invalidate(misRecordatoriosProvider);
      mensajes.showSnackBar(SnackBar(content: Text(t.adopcionBienvenida)));
      if (mounted) context.go(Rutas.fichaMascota(mascota));
    } on AdopcionException catch (e) {
      mensajes.showSnackBar(SnackBar(content: Text(_mensajeError(t, e))));
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.adopcionCompromisoTitulo),
      ),
      body: Column(
        children: [
          Expanded(
            child: switch (ref.watch(
              textoLegalProvider(DocumentoLegal.compromisoAdopcion),
            )) {
              AsyncData(:final value) => TextoMarkdown(value),
              AsyncError() => Center(child: Text(t.errorDesconocido)),
              _ => const Center(child: CircularProgressIndicator()),
            },
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: _acepto,
                    onChanged: (v) => setState(() => _acepto = v ?? false),
                    title: Text(t.adopcionAcepto),
                  ),
                  FilledButton(
                    onPressed: _acepto && !_enviando ? _aceptar : null,
                    child: Text(t.adopcionAceptar),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Perfil de adoptante (se completa una vez y se reutiliza).
class PerfilAdoptanteScreen extends ConsumerStatefulWidget {
  const PerfilAdoptanteScreen({super.key});

  @override
  ConsumerState<PerfilAdoptanteScreen> createState() =>
      _PerfilAdoptanteScreenState();
}

class _PerfilAdoptanteScreenState extends ConsumerState<PerfilAdoptanteScreen> {
  PerfilAdoptante? _p;

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final guardado = ref.watch(perfilAdoptanteProvider);
    final p =
        _p ??
        guardado.value ??
        const PerfilAdoptante(
          vivienda: 'casa',
          patio: false,
          horasSolo: 4,
          ninos: false,
        );
    void cambiar(PerfilAdoptante n) => setState(() => _p = n);
    PerfilAdoptante con({
      String? vivienda,
      bool? patio,
      int? horas,
      String? experiencia,
      bool? otros,
      bool? ninos,
      bool? acuerdo,
    }) => PerfilAdoptante(
      vivienda: vivienda ?? p.vivienda,
      patio: patio ?? p.patio,
      horasSolo: horas ?? p.horasSolo,
      experiencia: experiencia ?? p.experiencia,
      otrosAnimales: otros ?? p.otrosAnimales,
      ninos: ninos ?? p.ninos,
      casaDeAcuerdo: acuerdo ?? p.casaDeAcuerdo,
    );
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.adopcionMiPerfil),
      ),
      body: guardado.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(t.adopcionPerfilPrimero),
                const SizedBox(height: 16),
                Text(t.perfilVivienda, style: tema.textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(value: 'casa', label: Text(t.perfilCasa)),
                    ButtonSegment(
                      value: 'apartamento',
                      label: Text(t.perfilApartamento),
                    ),
                    ButtonSegment(value: 'otro', label: Text(t.perfilOtra)),
                  ],
                  selected: {p.vivienda ?? 'casa'},
                  onSelectionChanged: (s) => cambiar(con(vivienda: s.first)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.perfilPatio),
                  value: p.patio ?? false,
                  onChanged: (v) => cambiar(con(patio: v)),
                ),
                Text(
                  '${t.perfilHorasSolo}: ${t.perfilHoras(p.horasSolo ?? 4)}',
                ),
                Slider(
                  value: (p.horasSolo ?? 4).toDouble(),
                  max: 12,
                  divisions: 12,
                  label: t.perfilHoras(p.horasSolo ?? 4),
                  onChanged: (v) => cambiar(con(horas: v.round())),
                ),
                Text(t.perfilExperiencia, style: tema.textTheme.titleSmall),
                const SizedBox(height: 8),
                SegmentedButton<String>(
                  segments: [
                    ButtonSegment(
                      value: 'ninguna',
                      label: Text(t.perfilExpNinguna),
                    ),
                    ButtonSegment(
                      value: 'alguna',
                      label: Text(t.perfilExpAlguna),
                    ),
                    ButtonSegment(
                      value: 'mucha',
                      label: Text(t.perfilExpMucha),
                    ),
                  ],
                  selected: {p.experiencia ?? 'alguna'},
                  onSelectionChanged: (s) => cambiar(con(experiencia: s.first)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.perfilOtrosAnimales),
                  value: p.otrosAnimales ?? false,
                  onChanged: (v) => cambiar(con(otros: v)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.perfilNinos),
                  value: p.ninos ?? false,
                  onChanged: (v) => cambiar(con(ninos: v)),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(t.perfilCasaDeAcuerdo),
                  value: p.casaDeAcuerdo ?? true,
                  onChanged: (v) => cambiar(con(acuerdo: v)),
                ),
                const SizedBox(height: 16),
                FilledButton(
                  onPressed: () async {
                    final mensajes = ScaffoldMessenger.of(context);
                    final completo = con(
                      experiencia: p.experiencia ?? 'alguna',
                      otros: p.otrosAnimales ?? false,
                      acuerdo: p.casaDeAcuerdo ?? true,
                    );
                    try {
                      await ref
                          .read(adopcionRepositorioProvider)
                          .guardarPerfil(completo);
                      ref.invalidate(perfilAdoptanteProvider);
                      mensajes.showSnackBar(
                        SnackBar(content: Text(t.perfilGuardado)),
                      );
                      if (context.mounted && context.canPop()) context.pop();
                    } on Exception {
                      mensajes.showSnackBar(
                        SnackBar(content: Text(t.errorSinConexion)),
                      );
                    }
                  },
                  child: Text(t.perfilGuardar),
                ),
              ],
            ),
    );
  }
}

/// "¿Estoy listo para adoptar?" (03 §11.1).
class GuiaAdopcionScreen extends StatelessWidget {
  const GuiaAdopcionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.guiaTitulo),
      ),
      body: TextoMarkdown(t.guiaTexto),
    );
  }
}

/// Calculadora de costos: la persona pone sus montos y la app suma (no
/// inventa precios).
class CalculadoraCostosScreen extends StatefulWidget {
  const CalculadoraCostosScreen({super.key});

  @override
  State<CalculadoraCostosScreen> createState() => _CalculadoraCostosState();
}

class _CalculadoraCostosState extends State<CalculadoraCostosScreen> {
  static const _items = [
    ('comida', false),
    ('arena', false),
    ('antiparasitarios', false),
    ('vacunas', true),
    ('castracion', true),
    ('veterinaria', true),
    ('imprevistos', false),
  ];
  final _montos = <String, int>{};

  String _etiqueta(AppLocalizations t, String clave) => switch (clave) {
    'comida' => t.calcComida,
    'arena' => t.calcArena,
    'antiparasitarios' => t.calcAntiparasitarios,
    'vacunas' => t.calcVacunas,
    'castracion' => t.calcCastracion,
    'veterinaria' => t.calcVeterinaria,
    _ => t.calcImprevistos,
  };

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final total = totalCostos([
      for (final (clave, anual) in _items)
        ItemCosto(clave: clave, monto: _montos[clave] ?? 0, anual: anual),
    ]);
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.adopcionCalculadora),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ExplicacionCorta(
            id: 'calc_explicacion',
            corta: t.calcExplicacionCorta,
            larga: t.calcExplicacion,
          ),
          const SizedBox(height: 12),
          for (final (clave, _) in _items)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TextField(
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: _etiqueta(t, clave),
                  prefixText: r'$ ',
                ),
                onChanged: (v) => setState(
                  () => _montos[clave] =
                      int.tryParse(v.replaceAll(RegExp('[^0-9]'), '')) ?? 0,
                ),
              ),
            ),
          const SizedBox(height: 8),
          Text(
            t.calcTotal('${total.mes}', '${total.anio}'),
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

/// Dar en adopción: uno o una camada (hasta 8), con fotos.
class PublicarAdopcionScreen extends ConsumerStatefulWidget {
  const PublicarAdopcionScreen({super.key});

  @override
  ConsumerState<PublicarAdopcionScreen> createState() =>
      _PublicarAdopcionScreenState();
}

class _Borrador {
  final nombre = TextEditingController();
  final edad = TextEditingController();
  int especieId = 1;
  String tamano = 'mediano';
  String energia = 'media';
  bool castrado = false;
  bool vacunado = false;
  bool microchip = false;
  bool conNinos = false;
  bool necesitaPatio = false;
  final fotos = <String>[];

  Map<String, Object?> toJson() => {
    'name': nombre.text.trim().isEmpty ? null : nombre.text.trim(),
    'species_id': especieId,
    'age_months': int.tryParse(edad.text),
    'size': tamano,
    'energy': energia,
    'neutered': castrado,
    'vaccinated': vacunado,
    'microchip': microchip,
    'good_with_kids': conNinos,
    'needs_yard': necesitaPatio,
    'photos': fotos,
  };
}

class _PublicarAdopcionScreenState
    extends ConsumerState<PublicarAdopcionScreen> {
  final _animales = [_Borrador()];
  final _descripcion = TextEditingController();
  final _requisitos = TextEditingController();
  var _enviando = false;
  String? _error;

  Future<void> _foto(_Borrador b) async {
    final original = await elegirFoto(context, ref);
    if (original == null) return;
    final preparada = prepararFoto(original);
    if (preparada == null) return;
    final ruta = await ref
        .read(adopcionRepositorioProvider)
        .subirFoto(preparada);
    setState(() => b.fotos.add(ruta));
  }

  Future<void> _publicar() async {
    final t = context.t;
    if (_animales.any((b) => b.fotos.isEmpty)) {
      setState(() => _error = t.publicarFaltaFoto);
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await ref
          .read(adopcionRepositorioProvider)
          .publicar(
            {
              'description': _descripcion.text.trim(),
              'requirements': _requisitos.text.trim(),
            },
            [for (final b in _animales) b.toJson()],
          );
      ref
        ..read(
          metricasProvider,
        ).track(Eventos.adoptionPublish, props: {'animales': _animales.length})
        ..invalidate(disponiblesProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(t.publicarListo)));
      context.pop();
    } on AdopcionException catch (e) {
      setState(
        () => _error = e.motivo == ErrorAdopcion.limite
            ? t.publicarLimite
            : _mensajeError(t, e),
      );
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final especies = ref.watch(especiesProvider).value ?? const <Especie>[];
    return Scaffold(
      appBar: AppBar(
        leading: volverSiNoHayAtras(context),
        title: Text(t.publicarTitulo),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExplicacionCorta(
              id: 'publicar_explicacion',
              corta: t.publicarExplicacionCorta,
              larga: t.publicarExplicacion,
            ),
            for (final (i, b) in _animales.indexed) ...[
              const SizedBox(height: 16),
              Text(t.publicarAnimal(i + 1), style: tema.textTheme.titleMedium),
              TextField(
                controller: b.nombre,
                decoration: InputDecoration(labelText: t.publicarNombre),
              ),
              Wrap(
                spacing: 6,
                children: [
                  for (final e in especies)
                    ChoiceChip(
                      label: Text('${e.icono} ${e.nombre}'),
                      selected: b.especieId == e.id,
                      onSelected: (_) => setState(() => b.especieId = e.id),
                    ),
                ],
              ),
              TextField(
                controller: b.edad,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: t.publicarEdadMeses),
              ),
              const SizedBox(height: 8),
              Text(t.publicarTamano),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(value: 'chico', label: Text(t.adopcionChico)),
                  ButtonSegment(
                    value: 'mediano',
                    label: Text(t.adopcionMediano),
                  ),
                  ButtonSegment(value: 'grande', label: Text(t.adopcionGrande)),
                ],
                selected: {b.tamano},
                onSelectionChanged: (s) => setState(() => b.tamano = s.first),
              ),
              const SizedBox(height: 8),
              Text(t.publicarEnergia),
              SegmentedButton<String>(
                segments: [
                  ButtonSegment(
                    value: 'baja',
                    label: Text(t.adopcionEnergiaBaja),
                  ),
                  ButtonSegment(
                    value: 'media',
                    label: Text(t.adopcionEnergiaMedia),
                  ),
                  ButtonSegment(
                    value: 'alta',
                    label: Text(t.adopcionEnergiaAlta),
                  ),
                ],
                selected: {b.energia},
                onSelectionChanged: (s) => setState(() => b.energia = s.first),
              ),
              for (final (texto, valor, cambiar) in [
                (t.adopcionCastrado, b.castrado, (bool v) => b.castrado = v),
                (t.adopcionVacunado, b.vacunado, (bool v) => b.vacunado = v),
                (t.adopcionConChip, b.microchip, (bool v) => b.microchip = v),
                (t.adopcionConNinos, b.conNinos, (bool v) => b.conNinos = v),
                (
                  t.adopcionNecesitaPatio,
                  b.necesitaPatio,
                  (bool v) => b.necesitaPatio = v,
                ),
              ])
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(texto),
                  value: valor,
                  onChanged: (v) => setState(() => cambiar(v)),
                ),
              Wrap(
                spacing: 8,
                children: [
                  for (final _ in b.fotos)
                    const Chip(label: Icon(Icons.photo_outlined)),
                  ActionChip(
                    avatar: const Icon(Icons.add_a_photo_outlined, size: 18),
                    label: Text(t.publicarFoto),
                    onPressed: () => _foto(b),
                  ),
                ],
              ),
            ],
            if (_animales.length < 8)
              TextButton.icon(
                onPressed: () => setState(() => _animales.add(_Borrador())),
                icon: const Icon(Icons.add_outlined),
                label: Text(t.publicarAgregarAnimal),
              ),
            const SizedBox(height: 8),
            TextField(
              controller: _descripcion,
              maxLength: 2000,
              maxLines: 4,
              decoration: InputDecoration(labelText: t.publicarDescripcion),
            ),
            TextField(
              controller: _requisitos,
              maxLength: 1000,
              maxLines: 3,
              decoration: InputDecoration(labelText: t.publicarRequisitos),
            ),
            if (_error case final e?) ...[
              const SizedBox(height: 8),
              Text(e, style: TextStyle(color: tema.colorScheme.error)),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _enviando ? null : _publicar,
              child: Text(t.publicarEnviar),
            ),
          ],
        ),
      ),
    );
  }
}
