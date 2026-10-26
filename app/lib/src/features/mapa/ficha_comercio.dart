import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../comercios/comercios_repositorio.dart';
import '../../comercios/mis_lugares.dart';
import '../../comercios/textos_comercio.dart';
import '../../cuenta/servicio_cuenta.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../mascotas/catalogo.dart';
import '../../metricas/metricas.dart';
import '../../theme/paleta.dart';
import '../../utiles/enlaces.dart';
import '../adopcion/apadrinamiento_screen.dart';
import '../agenda/reservar_turno.dart';
import '../chat/chat_screen.dart';
import '../resenas/resenas.dart';
import '../tienda/catalogo_screen.dart';
import '../tienda/servicios.dart';
import 'marcar_lugar.dart';

/// Abre la ficha de un lugar desde abajo (al tocar su pin o en la lista).
Future<void> mostrarFichaComercio(
  BuildContext context,
  WidgetRef ref,
  Comercio comercio,
) {
  ref.read(metricasProvider).track(Eventos.placeOpen, businessId: comercio.id);
  return showModalBottomSheet<void>(
    context: context,
    useRootNavigator: true,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (_) => FichaComercio(comercio: comercio),
  );
}

String _hora(int minutos) =>
    '${(minutos ~/ 60).toString().padLeft(2, '0')}:'
    '${(minutos % 60).toString().padLeft(2, '0')}';

String _dia(AppLocalizations t, int dia) => switch (dia) {
  0 => t.diaLunes,
  1 => t.diaMartes,
  2 => t.diaMiercoles,
  3 => t.diaJueves,
  4 => t.diaViernes,
  5 => t.diaSabado,
  _ => t.diaDomingo,
};

/// "Abierto · cierra a las 20:00", "Cerrado · abre mañana a las 09:00"…
String textoApertura(AppLocalizations t, EstadoApertura e) {
  if (e.es24h) return t.comercioAbierto24h;
  final minutos = e.minutos;
  if (minutos == null) return t.comercioSinHorario;
  final hora = _hora(minutos);
  if (e.abierto) return t.comercioAbiertoHasta(hora);
  return switch (e.diasHasta) {
    0 => t.comercioCerradoHoy(hora),
    1 => t.comercioCerradoManana(hora),
    _ => t.comercioCerradoDia(_dia(t, e.dia ?? 0), hora),
  };
}

class FichaComercio extends ConsumerWidget {
  const FichaComercio({required this.comercio, super.key});

  final Comercio comercio;

  void _abrir(WidgetRef ref, String tipo, Uri enlace) {
    ref
        .read(metricasProvider)
        .track(
          Eventos.placeClick,
          businessId: comercio.id,
          props: {'tipo': tipo},
        );
    ref.read(abrirEnlaceProvider)(enlace);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final tema = Theme.of(context);
    final estado = comercio.estadoEn(ref.watch(relojProvider)());
    final especies = ref.watch(especiesProvider).value ?? const [];
    final nombresEspecies = [
      for (final e in especies)
        if (comercio.especieIds.contains(e.id)) e.nombre,
    ];
    final whatsapp = comercio.whatsapp == null
        ? null
        : telefonoInternacionalUy(comercio.whatsapp!);
    final c = comercio;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(c.nombre, style: tema.textTheme.titleLarge),
            Text(
              [
                textoCategoria(t, c.categoria),
                switch (c.modalidad) {
                  Modalidad.online => t.modalidadOnline,
                  Modalidad.domicilio => t.modalidadDomicilio,
                  Modalidad.local => null,
                },
              ].nonNulls.join(' · '),
              style: tema.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (c.operadorRenac)
                  _Etiqueta(t.comercioRenac, context.marca.exito),
                if (c.es24h) _Etiqueta(t.comercio24h, context.marca.urgencia),
                if (c.urgencias && !c.es24h)
                  _Etiqueta(t.comercioUrgencias, context.marca.urgencia),
                if (c.esEjemplo)
                  _Etiqueta(t.comercioEjemplo, tema.colorScheme.outline),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 20,
                  color: estado.abierto
                      ? context.marca.exito
                      : tema.colorScheme.error,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    textoApertura(t, estado),
                    style: tema.textTheme.titleSmall?.copyWith(
                      color: estado.abierto
                          ? context.marca.exito
                          : tema.colorScheme.error,
                    ),
                  ),
                ),
              ],
            ),
            if (c.esEjemplo) ...[
              const SizedBox(height: 8),
              Text(t.comercioEjemploAviso, style: tema.textTheme.bodySmall),
            ],
            if (c.fotos.isNotEmpty) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 120,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (final f in c.fotos)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            ref.watch(comerciosRepositorioProvider).urlFoto(f),
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (_, _, _) => const SizedBox(
                              width: 120,
                              child: Icon(Icons.photo_outlined),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            if (c.promo case final promo?) ...[
              const SizedBox(height: 12),
              Card(
                child: ListTile(
                  leading: const Icon(Icons.local_offer_outlined),
                  title: Text(promo),
                  subtitle: Text(t.fichaPromo),
                ),
              ),
            ],
            if (c.cobertura case final zona?) ...[
              const SizedBox(height: 8),
              Text(t.fichaCobertura(zona)),
            ],
            if (c.direccion != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.place_outlined, size: 20),
                  const SizedBox(width: 8),
                  Expanded(child: Text(c.direccion!)),
                ],
              ),
            ],
            if (nombresEspecies.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(t.comercioAtiende(nombresEspecies.join(', '))),
            ],
            if (c.descripcion != null) ...[
              const SizedBox(height: 8),
              Text(c.descripcion!, style: tema.textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (c.telefono != null)
                  FilledButton.icon(
                    onPressed: () => _abrir(
                      ref,
                      'llamar',
                      Uri(scheme: 'tel', path: c.telefono!.replaceAll(' ', '')),
                    ),
                    icon: const Icon(Icons.call),
                    label: Text(t.comercioLlamar),
                  ),
                if (whatsapp != null)
                  FilledButton.tonalIcon(
                    onPressed: () => _abrir(
                      ref,
                      'whatsapp',
                      Uri.https('wa.me', '/$whatsapp'),
                    ),
                    icon: const Icon(Icons.chat_outlined),
                    label: Text(t.comercioWhatsapp),
                  ),
                // Enlace común a Google Maps: sin API ni costo (regla del mapa).
                if (c.punto case final p?)
                  FilledButton.tonalIcon(
                    onPressed: () => _abrir(
                      ref,
                      'como_llegar',
                      Uri.https('www.google.com', '/maps/dir/', {
                        'api': '1',
                        'destination': '${p.lat},${p.lng}',
                      }),
                    ),
                    icon: const Icon(Icons.directions_outlined),
                    label: Text(t.comercioComoLlegar),
                  ),
                if (c.web != null)
                  OutlinedButton.icon(
                    onPressed: () => _abrir(ref, 'web', Uri.parse(c.web!)),
                    icon: const Icon(Icons.language),
                    label: Text(t.comercioWeb),
                  ),
                if (c.facebook != null)
                  OutlinedButton.icon(
                    onPressed: () => _abrir(
                      ref,
                      'facebook',
                      Uri.https('www.facebook.com', '/${c.facebook}'),
                    ),
                    icon: const Icon(Icons.facebook),
                    label: Text(t.fichaFacebook),
                  ),
                if (c.instagram != null)
                  OutlinedButton.icon(
                    onPressed: () => _abrir(
                      ref,
                      'instagram',
                      Uri.https('www.instagram.com', '/${c.instagram}/'),
                    ),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(t.comercioInstagram),
                  ),
              ],
            ),
            // Quién apadrina al refugio (3.4b, D108).
            if (c.categoria == Categoria.shelter)
              LineaPadrinos(negocioId: c.id),
            // Catálogo (2.5, D85): solo si el comercio lo tiene prendido.
            BotonCatalogo(comercio: c),
            // Servicios (2.10a, D90): solo con plan Plus.
            SeccionServicios(comercio: c),
            // Turnos (3.1, D104): solo si el comercio toma turnos.
            BotonReservar(comercio: c),
            // Favorito, "fui" y "es mi veterinaria" (1.2.8), con sesión y
            // con el mapa completo.
            if (ref.watch(conectadoProvider) &&
                ref.watch(
                  funcionalidadActivaProvider(Funcionalidades.mapaCompleto),
                ))
              _MisBotones(comercio: c),
            // Chat con el comercio (1.4.3), si tiene a alguien a cargo.
            if (c.tieneDuenio &&
                ref.watch(conectadoProvider) &&
                ref.watch(funcionalidadActivaProvider(Funcionalidades.chat)))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: OutlinedButton.icon(
                  onPressed: () => abrirChatConNegocio(context, ref, c.id),
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: Text(t.fichaEscribirChat),
                ),
              ),
            // Reseñas (1.7), con la funcionalidad `resenas`.
            if (ref.watch(funcionalidadActivaProvider(Funcionalidades.resenas)))
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: SeccionResenas(comercioId: c.id),
              ),
            // "¿Es tu negocio?" en los lugares sin cuenta a cargo (1.3.4).
            if (!c.tieneDuenio &&
                !c.esEjemplo &&
                ref.watch(conectadoProvider) &&
                ref.watch(
                  funcionalidadActivaProvider(Funcionalidades.comercios),
                ))
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: TextButton.icon(
                  onPressed: () => reclamarLugar(context, ref, c),
                  icon: const Icon(Icons.storefront_outlined),
                  label: Text(t.reclamarEsTuyo),
                ),
              ),
            if (!c.es24h && !c.horario.vacio)
              ExpansionTile(
                tilePadding: EdgeInsets.zero,
                title: Text(t.comercioHorarioSemana),
                children: [
                  for (var d = 0; d < 7; d++)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        children: [
                          SizedBox(width: 110, child: Text(_dia(t, d))),
                          Expanded(
                            child: Text(
                              c.horario.delDia(d).isEmpty
                                  ? t.comercioDiaCerrado
                                  : c.horario
                                        .delDia(d)
                                        .map(
                                          (f) =>
                                              '${_hora(f.desde)}–${_hora(f.hasta)}',
                                        )
                                        .join(' · '),
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class _Etiqueta extends StatelessWidget {
  const _Etiqueta(this.texto, this.color);

  final String texto;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      border: Border.all(color: color),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Text(
      texto,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
    ),
  );
}

class _MisBotones extends ConsumerWidget {
  const _MisBotones({required this.comercio});

  final Comercio comercio;

  Future<void> _marcar(
    BuildContext context,
    WidgetRef ref, {
    bool? favorito,
    bool? fui,
    bool? miVeterinaria,
  }) async {
    final t = context.t;
    final mensajes = ScaffoldMessenger.of(context);
    try {
      await ref
          .read(misLugaresRepositorioProvider)
          .marcar(
            comercio.id,
            favorito: favorito,
            fui: fui,
            miVeterinaria: miVeterinaria,
          );
      final metricas = ref.read(metricasProvider);
      if (favorito ?? false) {
        metricas.track(Eventos.favoriteAdd, businessId: comercio.id);
      }
      if (fui ?? false) {
        metricas.track(Eventos.placeVisit, businessId: comercio.id);
      }
      if (miVeterinaria ?? false) {
        metricas.track(Eventos.myVetSet, businessId: comercio.id);
      }
    } on Exception {
      mensajes.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
    }
    ref.invalidate(misLugaresProvider);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final mio = (ref.watch(misLugaresProvider).value ?? const {})[comercio.id];
    final fuiEn = mio?.fuiEn;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          FilterChip(
            avatar: Icon(
              (mio?.favorito ?? false) ? Icons.favorite : Icons.favorite_border,
              size: 18,
            ),
            label: Text(
              (mio?.favorito ?? false)
                  ? t.fichaQuitarFavorito
                  : t.fichaFavorito,
            ),
            selected: mio?.favorito ?? false,
            showCheckmark: false,
            onSelected: (si) => _marcar(context, ref, favorito: si),
          ),
          ActionChip(
            avatar: const Icon(Icons.where_to_vote_outlined, size: 18),
            label: Text(
              fuiEn == null
                  ? t.fichaFui
                  : t.fichaFuiEl(
                      MaterialLocalizations.of(context).formatShortDate(fuiEn),
                    ),
            ),
            onPressed: () => _marcar(context, ref, fui: true),
          ),
          if (comercio.categoria == Categoria.vet)
            FilterChip(
              avatar: const Icon(Icons.verified_outlined, size: 18),
              label: Text(
                (mio?.miVeterinaria ?? false)
                    ? t.fichaEsTuVeterinaria
                    : t.fichaMiVeterinaria,
              ),
              selected: mio?.miVeterinaria ?? false,
              onSelected: (si) => _marcar(context, ref, miVeterinaria: si),
            ),
        ],
      ),
    );
  }
}
