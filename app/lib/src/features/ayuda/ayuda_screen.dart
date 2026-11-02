import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../../l10n/l10n.dart';
import '../../ayuda/ayuda_repositorio.dart';
import '../../funcionalidades/funcionalidades_activas.dart';
import '../../metricas/metricas.dart';
import '../../recorrido/pasos.dart';
import '../../recorrido/recorrido.dart';
import '../../router.dart';
import '../../utiles/enlaces.dart';
import '../../widgets/boton_ayuda.dart';
import '../mapa/ficha_comercio.dart';
import '../menu/menu_principal.dart';

/// Pestaña Ayuda (también para visitantes): 911, veterinarias de urgencia y
/// directorio de refugios, protectoras y grupos de la zona.
class AyudaScreen extends ConsumerWidget {
  const AyudaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final directorio = ref.watch(directorioAyudaProvider);
    final urgencias = ref.watch(veterinariasUrgenciaProvider);
    final entradas = directorio.value ?? const <EntradaAyuda>[];
    final secciones = [
      (t.ayudaRefugios, [TipoAyuda.refugio, TipoAyuda.protectora]),
      (t.ayudaGrupos, [TipoAyuda.grupo]),
      (t.ayudaOrganismos, [TipoAyuda.organismo]),
    ];

    return ZonaRecorrido(
      pantalla: PantallaRecorrido.urgencias,
      pasos: PasosRecorrido.urgencias,
      child: Scaffold(
        drawer: const MenuPrincipal(),
        appBar: AppBar(
          leading: botonMenu,
          title: Text(t.pestanaAyuda),
          actions: accionesPestana(),
        ),
        body: RefreshIndicator(
          onRefresh: () async {
            ref
              ..invalidate(directorioAyudaProvider)
              ..invalidate(veterinariasUrgenciaProvider);
            await ref.read(directorioAyudaProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const MarcaRecorrido('911', child: _Tarjeta911()),
              const SizedBox(height: 16),
              // Denuncias de maltrato (2.7, D80). Los próximos eventos están en
              // Noticias → Comunidad (D94).
              SiFuncionalidad(
                Funcionalidades.eventos,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.report_outlined),
                        title: Text(t.denunciaTitulo),
                        subtitle: Text(t.denunciaEntradaAyuda),
                        trailing: const Icon(Icons.chevron_right_outlined),
                        onTap: () => context.push(Rutas.denuncia),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
              // Noticias es pestaña (D94) y Adopción se abre desde el menú ☰
              // (D88): Ayuda queda para urgencias.
              MarcaRecorrido('guardia', child: _Titulo(t.ayudaUrgencias)),
              switch (urgencias) {
                AsyncData(value: final lista) when lista.isEmpty => Text(
                  t.ayudaSinUrgencias,
                ),
                AsyncData(value: final lista) => Column(
                  children: [for (final c in lista) _FilaUrgencia(comercio: c)],
                ),
                AsyncError() => Text(t.errorSinConexion),
                _ => const LinearProgressIndicator(),
              },
              const SizedBox(height: 16),
              if (directorio.hasError)
                Text(t.errorSinConexion)
              else if (directorio.isLoading)
                const LinearProgressIndicator()
              else if (entradas.isEmpty)
                Text(t.ayudaDirectorioVacio)
              else
                for (final (titulo, tipos) in secciones)
                  if (entradas.any((e) => tipos.contains(e.tipo))) ...[
                    _Titulo(titulo),
                    for (final e in entradas)
                      if (tipos.contains(e.tipo)) _FilaAyuda(entrada: e),
                    const SizedBox(height: 16),
                  ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Registra la métrica (sin datos de nadie) y abre el enlace.
void _abrir(WidgetRef ref, Uri enlace, String tipo, {String? kind}) {
  ref
      .read(metricasProvider)
      .track(Eventos.helpClick, props: {'tipo': tipo, 'kind': ?kind});
  ref.read(abrirEnlaceProvider)(enlace);
}

class _Tarjeta911 extends ConsumerWidget {
  const _Tarjeta911();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final colores = Theme.of(context).colorScheme;
    return Card(
      color: colores.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.ayuda911Titulo,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colores.onErrorContainer,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              t.ayuda911Texto,
              style: TextStyle(color: colores.onErrorContainer),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: colores.error,
                foregroundColor: colores.onError,
              ),
              onPressed: () =>
                  _abrir(ref, Uri(scheme: 'tel', path: '911'), '911'),
              icon: const Icon(Icons.call_outlined),
              label: Text(t.ayuda911Boton),
            ),
          ],
        ),
      ),
    );
  }
}

class _Titulo extends StatelessWidget {
  const _Titulo(this.texto);

  final String texto;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
  );
}

class _FilaUrgencia extends ConsumerWidget {
  const _FilaUrgencia({required this.comercio});

  final Comercio comercio;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final estado = comercio.estadoEn(ref.watch(relojProvider)());
    return Card(
      child: ListTile(
        leading: Icon(
          Icons.local_hospital_outlined,
          color: context.marca.urgencia,
        ),
        title: Text(comercio.nombre),
        subtitle: Text(textoApertura(context.t, estado)),
        trailing: const Icon(Icons.chevron_right_outlined),
        onTap: () => mostrarFichaComercio(context, ref, comercio),
      ),
    );
  }
}

class _FilaAyuda extends ConsumerWidget {
  const _FilaAyuda({required this.entrada});

  final EntradaAyuda entrada;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.t;
    final e = entrada;
    final whatsapp = e.whatsapp == null
        ? null
        : telefonoInternacionalUy(e.whatsapp!);
    final enlace = e.enlace == null ? null : Uri.tryParse(e.enlace!);
    final kind = e.tipo.name;
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    e.nombre,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
                if (e.esEjemplo)
                  Chip(
                    label: Text(t.comercioEjemplo),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            if (e.descripcion != null) ...[
              const SizedBox(height: 4),
              Text(e.descripcion!),
            ],
            Wrap(
              spacing: 4,
              children: [
                if (e.telefono != null)
                  TextButton.icon(
                    onPressed: () => _abrir(
                      ref,
                      Uri(scheme: 'tel', path: e.telefono!.replaceAll(' ', '')),
                      'llamar',
                      kind: kind,
                    ),
                    icon: const Icon(Icons.call_outlined),
                    label: Text(t.comercioLlamar),
                  ),
                if (whatsapp != null)
                  TextButton.icon(
                    onPressed: () => _abrir(
                      ref,
                      Uri.https('wa.me', '/$whatsapp'),
                      'whatsapp',
                      kind: kind,
                    ),
                    icon: const Icon(Icons.chat_outlined),
                    label: Text(t.comercioWhatsapp),
                  ),
                if (enlace != null)
                  TextButton.icon(
                    onPressed: () => _abrir(ref, enlace, 'enlace', kind: kind),
                    icon: const Icon(Icons.open_in_new_outlined),
                    label: Text(t.ayudaAbrir),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
