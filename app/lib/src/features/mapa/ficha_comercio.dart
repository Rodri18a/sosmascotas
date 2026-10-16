import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../mascotas/catalogo.dart';
import '../../metricas/metricas.dart';
import '../../theme/paleta.dart';
import '../../utiles/enlaces.dart';

/// Abre la ficha de una veterinaria desde abajo (al tocar su pin).
Future<void> mostrarFichaComercio(
  BuildContext context,
  WidgetRef ref,
  Comercio comercio,
) {
  ref.read(metricasProvider).track(Eventos.placeOpen, businessId: comercio.id);
  return showModalBottomSheet<void>(
    context: context,
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
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
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
                FilledButton.tonalIcon(
                  onPressed: () => _abrir(
                    ref,
                    'como_llegar',
                    Uri.https('www.google.com', '/maps/dir/', {
                      'api': '1',
                      'destination': '${c.punto.lat},${c.punto.lng}',
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
