import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../cuenta/huellas_repositorio.dart';
import '../../metricas/metricas.dart';

(String, String, String) _textos(AppLocalizations t, Insignia i) => switch (i) {
  Insignia.perfil => ('🐾', t.huellaPerfil, t.huellaPerfilComo),
  Insignia.libreta => ('💉', t.huellaLibreta, t.huellaLibretaComo),
  Insignia.chapita => ('🏷️', t.huellaChapita, t.huellaChapitaComo),
  Insignia.difusor => ('📣', t.huellaDifusor, t.huellaDifusorComo),
  Insignia.respuesta => ('💬', t.huellaRespuesta, t.huellaRespuestaComo),
  Insignia.reencuentro => ('🏠', t.huellaReencuentro, t.huellaReencuentroComo),
};

/// «Tus huellas» en Mi perfil (plan de mejoras 3.3, D138): cuántas veces
/// ayudaste y las insignias. Las que faltan dicen cómo ganarlas. Solo las ve
/// la propia persona: no hay rankings.
class TarjetaHuellas extends ConsumerStatefulWidget {
  const TarjetaHuellas({super.key});

  @override
  ConsumerState<TarjetaHuellas> createState() => _TarjetaHuellasState();
}

class _TarjetaHuellasState extends ConsumerState<TarjetaHuellas> {
  @override
  void initState() {
    super.initState();
    ref.read(metricasProvider).track(Eventos.huellasOpen);
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final tema = Theme.of(context);
    final huellas = ref.watch(huellasProvider);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: switch (huellas) {
          AsyncData(value: final h) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.huellasTitulo, style: tema.textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                h.ayudas == 0 ? t.huellasSinAyudas : t.huellasAyudas(h.ayudas),
              ),
              const SizedBox(height: 12),
              for (final i in Insignia.values)
                () {
                  final (emoji, nombre, como) = _textos(t, i);
                  final ganada = h.ganadas.contains(i);
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Opacity(
                      opacity: ganada ? 1 : 0.35,
                      child: Text(emoji, style: const TextStyle(fontSize: 28)),
                    ),
                    title: Text(nombre),
                    subtitle: Text(ganada ? t.huellaGanada : como),
                    trailing: ganada
                        ? Icon(
                            Icons.check_circle,
                            color: tema.colorScheme.primary,
                            semanticLabel: t.huellaGanada,
                          )
                        : null,
                  );
                }(),
              Text(t.huellasPrivadas, style: tema.textTheme.bodySmall),
            ],
          ),
          AsyncError() => Text(t.errorSinConexion),
          _ => const Center(child: CircularProgressIndicator()),
        },
      ),
    );
  }
}
