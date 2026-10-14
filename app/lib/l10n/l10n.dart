import 'package:flutter/widgets.dart';

import 'generated/app_localizations.dart';

export 'generated/app_localizations.dart';

/// Acceso corto a los textos: `context.t.pestanaMapa`.
extension TextosContext on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this);
}
