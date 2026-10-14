import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../l10n/l10n.dart';

import 'config/env_provider.dart';
import 'router.dart';
import 'theme/app_theme.dart';

class SosMascotaApp extends ConsumerWidget {
  const SosMascotaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final env = ref.watch(appEnvProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      onGenerateTitle: (context) => context.t.appNombre,
      // Español de Uruguay: fechas y números con formato local.
      locale: const Locale('es', 'UY'),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      debugShowCheckedModeBanner: false,
      theme: AppTheme.claro,
      darkTheme: AppTheme.oscuro,
      // Sigue el modo claro u oscuro del celular.
      themeMode: ThemeMode.system,
      routerConfig: router,
      builder: (context, child) =>
          env.isProd ? child! : Stack(children: [child!, const MarcaDev()]),
    );
  }
}

/// Etiqueta "DEV" arriba al centro, solo en desarrollo. No bloquea los toques.
class MarcaDev extends StatelessWidget {
  const MarcaDev({super.key});

  @override
  Widget build(BuildContext context) => const Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: SafeArea(
      child: Align(
        alignment: Alignment.topCenter,
        child: IgnorePointer(
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xCCB3261E),
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(6)),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              child: Text(
                'DEV', // i18n-ok: etiqueta técnica, solo en desarrollo
                style: TextStyle(
                  color: Color(0xFFFFFFFF),
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
