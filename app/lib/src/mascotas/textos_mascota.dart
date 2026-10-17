import 'package:sosmascota_core/sosmascota_core.dart';

import '../../l10n/l10n.dart';

/// "6 años y 2 meses", "2 meses", "Menos de un mes".
String textoEdad(AppLocalizations t, DateTime nacimiento, {DateTime? hoy}) {
  final e = edad(nacimiento, hoy ?? DateTime.now());
  if (e.anios == 0 && e.meses == 0) return t.edadMenosDeUnMes;
  if (e.anios == 0) return t.edadMeses(e.meses);
  if (e.meses == 0) return t.edadAnios(e.anios);
  return t.edadAniosYMeses(e.anios, e.meses);
}

String textoSexo(AppLocalizations t, Sexo sexo) => switch (sexo) {
  Sexo.male => t.sexoMacho,
  Sexo.female => t.sexoHembra,
  Sexo.unknown => t.noSe,
};

String textoTipoRegistro(AppLocalizations t, TipoRegistroSalud tipo) =>
    switch (tipo) {
      TipoRegistroSalud.vaccine => t.libretaTipoVacuna,
      TipoRegistroSalud.deworming => t.libretaTipoDesparasitacion,
      TipoRegistroSalud.checkup => t.libretaTipoControl,
      TipoRegistroSalud.allergy => t.libretaTipoAlergia,
      TipoRegistroSalud.other => t.libretaTipoOtro,
    };

String textoGrupoLibreta(AppLocalizations t, TipoRegistroSalud tipo) =>
    switch (tipo) {
      TipoRegistroSalud.vaccine => t.libretaGrupoVacunas,
      TipoRegistroSalud.deworming => t.libretaGrupoDesparasitaciones,
      TipoRegistroSalud.checkup => t.libretaGrupoControles,
      TipoRegistroSalud.allergy => t.libretaGrupoAlergias,
      TipoRegistroSalud.other => t.libretaGrupoOtros,
    };

String ayudaNombreRegistro(AppLocalizations t, TipoRegistroSalud tipo) =>
    switch (tipo) {
      TipoRegistroSalud.vaccine => t.libretaNombreAyudaVacuna,
      TipoRegistroSalud.deworming => t.libretaNombreAyudaDesparasitacion,
      TipoRegistroSalud.checkup => t.libretaNombreAyudaControl,
      TipoRegistroSalud.allergy => t.libretaNombreAyudaAlergia,
      TipoRegistroSalud.other => t.libretaNombreAyudaOtro,
    };
