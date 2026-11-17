import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sosmascota_core/sosmascota_core.dart';

import '../../l10n/l10n.dart';
import '../cuenta/servicio_cuenta.dart';
import '../dos_apps/dos_apps.dart';
import '../metricas/metricas.dart';
import '../router.dart';
import '../utiles/enlaces.dart';
import '../widgets/ilustracion.dart';
import '../widgets/volver.dart';
import 'soporte_repositorio.dart';

/// Ayuda y soporte (0.8.6b, D160): correo, WhatsApp (solo si está cargado en
/// `app_settings`) y «Escribinos» desde la app. Sirve en las dos apps.
class SoporteScreen extends ConsumerStatefulWidget {
  const SoporteScreen({super.key});

  @override
  ConsumerState<SoporteScreen> createState() => _SoporteScreenState();
}

class _SoporteScreenState extends ConsumerState<SoporteScreen> {
  final _mensaje = TextEditingController();
  var _enviando = false;

  /// Aviso debajo del campo (no en un cartel: taparía el botón Enviar).
  String? _error;

  @override
  void initState() {
    super.initState();
    ref.read(metricasProvider).track(Eventos.supportOpen);
  }

  @override
  void dispose() {
    _mensaje.dispose();
    super.dispose();
  }

  Future<void> _abrir(String evento, Uri enlace) async {
    ref.read(metricasProvider).track(evento);
    await ref.read(abrirEnlaceProvider)(enlace);
  }

  Future<void> _enviar() async {
    final t = context.t;
    final aviso = ScaffoldMessenger.of(context);
    final texto = _mensaje.text.trim();
    if (texto.length < 5) {
      setState(() => _error = t.soporteMuyCorto);
      return;
    }
    setState(() {
      _enviando = true;
      _error = null;
    });
    try {
      await ref.read(soporteRepositorioProvider).enviar(texto);
      ref.read(metricasProvider).track(Eventos.supportMessage);
      _mensaje.clear();
      aviso.showSnackBar(SnackBar(content: Text(t.soporteEnviado)));
    } on SoporteException catch (e) {
      if (e.tipo == ErrorSoporte.muyCorto) {
        setState(() => _error = t.soporteMuyCorto);
        return;
      }
      aviso.showSnackBar(
        SnackBar(
          content: Text(switch (e.tipo) {
            ErrorSoporte.muyCorto => t.soporteMuyCorto,
            ErrorSoporte.demasiados => t.soporteDemasiados,
            ErrorSoporte.otro => t.errorSinConexion,
          }),
        ),
      );
    } on Exception {
      aviso.showSnackBar(SnackBar(content: Text(t.errorSinConexion)));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = context.t;
    final contacto =
        ref.watch(contactoSoporteProvider).value ?? const ContactoSoporte();
    final usuario = ref.watch(usuarioActualProvider).value;
    final personas = !ref.watch(esAppComercioProvider);
    final esquema = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.soporteTitulo),
        leading: volverSiNoHayAtras(context),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Ami con lentes (D162).
          const Center(
            child: ImagenIlustracion(Ilustracion.consejo, alto: 120),
          ),
          const SizedBox(height: 12),
          Text(t.soporteIntro),
          if (personas) ...[
            const SizedBox(height: 12),
            Card(
              color: esquema.errorContainer,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.soporteUrgencia,
                      style: TextStyle(color: esquema.onErrorContainer),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => context.go(Rutas.sos),
                        child: Text(t.soporteIrASos),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.mail_outline),
            title: Text(t.soporteCorreo),
            subtitle: Text(contacto.correo),
            onTap: () => _abrir(
              Eventos.supportEmail,
              Uri(
                scheme: 'mailto',
                path: contacto.correo,
                query: 'subject=${Uri.encodeComponent(t.soporteTitulo)}',
              ),
            ),
          ),
          if (contacto.whatsapp case final numero?)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.chat_outlined),
              title: Text(t.soporteWhatsapp),
              onTap: () => _abrir(
                Eventos.supportWhatsapp,
                Uri.https('wa.me', '/$numero'),
              ),
            ),
          const Divider(height: 32),
          Text(
            t.soporteFormTitulo,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (usuario == null)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.login_outlined),
              title: Text(t.soporteIngresar),
              onTap: () => context.push(Rutas.ingresarYVolverA(Rutas.soporte)),
            )
          else ...[
            TextField(
              controller: _mensaje,
              minLines: 4,
              maxLines: 8,
              maxLength: 2000,
              textCapitalization: TextCapitalization.sentences,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                labelText: t.soporteMensaje,
                helperText: t.soporteMensajeAyuda,
                helperMaxLines: 3,
                errorText: _error,
                errorMaxLines: 2,
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.icon(
                onPressed: _enviando ? null : _enviar,
                icon: const Icon(Icons.send_outlined),
                label: Text(t.soporteEnviar),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
