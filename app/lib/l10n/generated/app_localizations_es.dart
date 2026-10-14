// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appNombre => 'SOS Mascota';

  @override
  String get pestanaMapa => 'Mapa';

  @override
  String get pestanaSos => 'SOS';

  @override
  String get pestanaMascotas => 'Mis mascotas';

  @override
  String get pestanaAyuda => 'Ayuda';

  @override
  String get mapaDescripcion =>
      'Veterinarias de urgencia y mascotas perdidas cerca tuyo';

  @override
  String get sosDescripcion => 'Descripción';

  @override
  String get mascotasDescripcion => 'Tus mascotas, su ficha y su chapita QR';

  @override
  String get ayudaDescripcion =>
      'Urgencias, refugios y grupos de difusión de tu zona';

  @override
  String enConstruccionPaso(String paso) {
    return 'Llega en el paso $paso';
  }

  @override
  String get ajustes => 'Ajustes';

  @override
  String get ajustesPerfil => 'Perfil, avisos y cuenta';

  @override
  String get ajustesDesarrollo => 'Desarrollo';

  @override
  String get conexionConectado => 'Conectado a Supabase dev ✅';

  @override
  String get conexionSinConfigurar =>
      'Falta configurar Supabase (config/dev.json) ⚠️';

  @override
  String get conexionSinConexion => 'Sin conexión a Supabase ❌';

  @override
  String get conexionConectando => 'Conectando con Supabase…';

  @override
  String get ingresarTitulo => 'Ingresar';

  @override
  String get ingresarExplicacion =>
      'Ingresá o creá tu cuenta con tu correo. Te mandamos un código: no hace falta contraseña.';

  @override
  String get ingresarCorreo => 'Tu correo';

  @override
  String get ingresarEnviarCodigo => 'Enviarme el código';

  @override
  String ingresarRevisaCorreo(String email) {
    return 'Te mandamos un correo a $email. Tocá el enlace del correo o escribí acá el código de 6 números.';
  }

  @override
  String get ingresarCodigo => 'Código';

  @override
  String get ingresarConfirmar => 'Ingresar';

  @override
  String get ingresarOtroCorreo => 'Usar otro correo';

  @override
  String get ingresarEmailInvalido =>
      'Revisá el correo: parece que le falta algo.';

  @override
  String get ingresarCodigoInvalido => 'El código tiene 6 números.';

  @override
  String get ingresarAvisoTerminos =>
      'Al crear tu cuenta te vamos a pedir que aceptes los términos y la política de privacidad.';

  @override
  String get ingresarOCrearCuenta => 'Ingresar o crear cuenta';

  @override
  String get ingresarSubtitulo =>
      'Para reportar, guardar tus mascotas y recibir avisos';

  @override
  String get cerrarSesion => 'Cerrar sesión';

  @override
  String get errorDemasiadosIntentos =>
      'Hiciste muchos intentos seguidos. Esperá unos minutos y probá de nuevo.';

  @override
  String get errorCodigoInvalido =>
      'El código no es correcto o ya venció. Pedí uno nuevo.';

  @override
  String get errorSinConexion =>
      'No pudimos conectarnos. Revisá tu internet y probá de nuevo.';

  @override
  String get errorNoConfigurado =>
      'El ingreso no está disponible en este momento.';

  @override
  String get errorDesconocido => 'Algo salió mal. Probá de nuevo en un rato.';

  @override
  String get ingresarConGoogle => 'Continuar con Google';

  @override
  String get ingresarOConCorreo => 'o con tu correo';

  @override
  String get cuentaNecesariaTitulo => 'Necesitás una cuenta';

  @override
  String get ahoraNo => 'Ahora no';

  @override
  String get sosReportar => 'Reportar';

  @override
  String get sosMotivoCuenta =>
      'Para reportar necesitamos poder avisarte cuando alguien vea a la mascota. Tu teléfono nunca se muestra.';

  @override
  String get sosNuevoTitulo => 'Nuevo reporte';

  @override
  String get sosNuevoDescripcion =>
      'Foto, ubicación en el mapa y datos de la mascota';

  @override
  String get mascotasAgregar => 'Agregar mascota';

  @override
  String get mascotasMotivoCuenta =>
      'Para guardar tus mascotas, su ficha y su chapita QR, y recibir avisos si alguien la encuentra.';

  @override
  String get mascotaNuevaTitulo => 'Nueva mascota';

  @override
  String get mascotaNuevaDescripcion =>
      'Nombre, especie, raza y foto de tu mascota';

  @override
  String get legalTerminos => 'Términos y condiciones';

  @override
  String get legalPrivacidad => 'Política de privacidad';

  @override
  String get consentimientoTitulo => 'Antes de empezar';

  @override
  String get consentimientoExplicacion =>
      'Para usar tu cuenta necesitamos que leas y aceptes cómo funciona SOS Mascota y cómo cuidamos tus datos. En resumen:';

  @override
  String get consentimientoTelefono =>
      'Tu teléfono nunca se muestra a otras personas.';

  @override
  String get consentimientoUbicacion =>
      'Solo guardamos una zona aproximada, nunca tu ubicación exacta.';

  @override
  String get consentimientoMetricas =>
      'Medimos el uso de la app de forma anónima. No vendemos tus datos.';

  @override
  String get consentimientoBorrar => 'Podés borrar tu cuenta cuando quieras.';

  @override
  String get consentimientoCasilla =>
      'Leí y acepto los términos y la política de privacidad';

  @override
  String get consentimientoAceptar => 'Aceptar y continuar';

  @override
  String get consentimientoNoAcepto => 'No acepto (cerrar sesión)';

  @override
  String get ajustesNombreTitulo => 'Tu nombre';

  @override
  String get ajustesNombreAyuda =>
      'Así te ven los demás cuando hablás con ellos';

  @override
  String ajustesRadioAvisos(int km) {
    return 'Avisarme de mascotas perdidas hasta a $km km';
  }

  @override
  String ajustesKm(int km) {
    return '$km km';
  }

  @override
  String get guardar => 'Guardar';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get borrarCuenta => 'Borrar mi cuenta';

  @override
  String get borrarCuentaTitulo => '¿Borrar tu cuenta?';

  @override
  String get borrarCuentaExplicacion =>
      'Se borran para siempre tu perfil, tus datos de contacto y tus mascotas. No se puede deshacer.';

  @override
  String get borrarCuentaConfirmar => 'Sí, borrar todo';

  @override
  String get borrarCuentaHecho => 'Tu cuenta y tus datos se borraron.';

  @override
  String get mascotaEditarTitulo => 'Editar mascota';

  @override
  String get mascotaFoto => 'Foto';

  @override
  String get mascotaAgregarFoto => 'Agregar foto';

  @override
  String get mascotaCambiarFoto => 'Cambiar foto';

  @override
  String get mascotaSacarFoto => 'Sacar una foto';

  @override
  String get mascotaElegirFoto => 'Elegir de la galería';

  @override
  String get mascotaFotoAyuda =>
      'Una foto clara de cuerpo entero ayuda mucho si se pierde. Le quitamos la ubicación antes de subirla.';

  @override
  String get mascotaFotoInvalida =>
      'No pudimos leer esa imagen. Probá con otra.';

  @override
  String get mascotaNombre => 'Nombre';

  @override
  String get mascotaNombreFalta => 'Escribí el nombre de tu mascota.';

  @override
  String get mascotaEspecie => 'Especie';

  @override
  String get mascotaEspecieFalta => 'Elegí la especie.';

  @override
  String get mascotaRaza => 'Raza';

  @override
  String get mascotaRazaOtra => 'Otra / no está en la lista';

  @override
  String get mascotaRazaOtraCampo => '¿Qué raza es?';

  @override
  String get mascotaSexo => 'Sexo';

  @override
  String get sexoMacho => 'Macho';

  @override
  String get sexoHembra => 'Hembra';

  @override
  String get noSe => 'No sé';

  @override
  String get si => 'Sí';

  @override
  String get no => 'No';

  @override
  String get mascotaColor => 'Color';

  @override
  String get mascotaSenas => 'Señas particulares';

  @override
  String get mascotaSenasAyuda =>
      'Manchas, cicatrices, collar… lo que la distinga.';

  @override
  String get mascotaNacimiento => 'Fecha de nacimiento';

  @override
  String get mascotaNacimientoAyuda =>
      'Si no la sabés exacta, una aproximada sirve.';

  @override
  String get mascotaNacimientoElegir => 'Elegir fecha';

  @override
  String get mascotaMicrochip => 'Microchip';

  @override
  String get mascotaMicrochipAyuda =>
      '15 números. Está en el carné de la veterinaria.';

  @override
  String get mascotaMicrochipInvalido => 'El microchip tiene 15 números.';

  @override
  String get mascotaCastrada => '¿Está castrada/o?';

  @override
  String get mascotaNotas => 'Notas';

  @override
  String get mascotaNotasAyuda =>
      'Carácter, miedos, medicación… (solo lo ves vos).';

  @override
  String get mascotaBorrar => 'Borrar mascota';

  @override
  String mascotaBorrarTitulo(String nombre) {
    return '¿Borrar a $nombre?';
  }

  @override
  String get mascotaBorrarExplicacion =>
      'Se borran su ficha y su foto. No se puede deshacer.';

  @override
  String get borrar => 'Borrar';

  @override
  String get guardando => 'Guardando…';

  @override
  String get mascotasVacio =>
      'Todavía no cargaste ninguna mascota. Con su ficha y su foto vas a poder generar su chapita QR y reportarla rápido si se pierde.';

  @override
  String get edadMenosDeUnMes => 'Menos de un mes';

  @override
  String edadMeses(int meses) {
    String _temp0 = intl.Intl.pluralLogic(
      meses,
      locale: localeName,
      other: '$meses meses',
      one: '1 mes',
    );
    return '$_temp0';
  }

  @override
  String edadAnios(int anios) {
    String _temp0 = intl.Intl.pluralLogic(
      anios,
      locale: localeName,
      other: '$anios años',
      one: '1 año',
    );
    return '$_temp0';
  }

  @override
  String edadAniosYMeses(int anios, int meses) {
    String _temp0 = intl.Intl.pluralLogic(
      anios,
      locale: localeName,
      other: '$anios años',
      one: '1 año',
    );
    String _temp1 = intl.Intl.pluralLogic(
      meses,
      locale: localeName,
      other: '$meses meses',
      one: '1 mes',
    );
    return '$_temp0 y $_temp1';
  }

  @override
  String get fichaEditar => 'Editar';

  @override
  String get fichaEdad => 'Edad';

  @override
  String get fichaCastrada => 'Castrada/o';

  @override
  String get fichaMicrochipConsejo =>
      'Si se pierde, a quien la encuentre le vamos a sugerir llevarla a una veterinaria para leer el chip.';

  @override
  String get fichaSinMicrochip => 'Sin microchip cargado';

  @override
  String get fichaQrTitulo => 'Chapita QR';

  @override
  String get fichaQrDescripcion =>
      'Su código para que quien la encuentre pueda avisarte sin ver tu teléfono.';

  @override
  String qrExplicacion(String nombre) {
    return 'Este es el QR de $nombre. Quien lo escanee ve su foto y su nombre, y puede avisarte sin ver tu teléfono.';
  }

  @override
  String qrDe(String nombre) {
    return 'QR de $nombre';
  }

  @override
  String get qrCartelIndicacion => '¿Me encontraste? Escaneame 🐾';

  @override
  String get qrDescargar => 'Descargar para imprimir';

  @override
  String get qrDescargaNoDisponible =>
      'La descarga llega con la app para celulares. Mientras tanto, usá la versión web.';

  @override
  String get qrCopiarEnlace => 'Copiar enlace';

  @override
  String get qrEnlaceCopiado => 'Enlace copiado';

  @override
  String get qrVerPagina => 'Ver la página que ve quien lo escanea';

  @override
  String get qrNotaTitulo => 'Nota para quien la encuentre';

  @override
  String get qrNotaAyuda =>
      'Por ejemplo: \"Toma medicación\" o \"Es alérgica al pollo\". No pongas tu dirección ni tu teléfono.';

  @override
  String get qrNotaGuardada => 'Nota guardada';

  @override
  String get qrConsejoChapita =>
      'Imprimilo en papel adhesivo y protegelo con cinta transparente, o pedí una chapita resistente cuando esté disponible. Si el código circuló donde no querías, podés cambiarlo.';

  @override
  String get qrRegenerar => 'Cambiar el código';

  @override
  String get qrRegenerarTitulo => '¿Cambiar el código?';

  @override
  String get qrRegenerarExplicacion =>
      'El código actual deja de funcionar: vas a tener que imprimir el nuevo y reemplazar la chapita.';

  @override
  String get qrRegenerado => 'Listo: el código nuevo ya está activo.';

  @override
  String get avisosTitulo => 'Avisos';

  @override
  String get avisosVacio =>
      'Todavía no tenés avisos. Si alguien escanea el QR de tu mascota y te deja un mensaje, lo vas a ver acá.';

  @override
  String get avisosAntiEstafa =>
      'Nunca pagues por adelantado ni mandes plata para recuperar a tu mascota. Si te la piden, marcá el aviso como estafa.';

  @override
  String avisosDe(String nombre) {
    return 'Aviso de $nombre';
  }

  @override
  String avisosSobre(String mascota, String nombre) {
    return '$mascota: aviso de $nombre';
  }

  @override
  String get avisosNuevo => 'Nuevo';

  @override
  String get avisosMasOpciones => 'Más opciones';

  @override
  String get avisosYaContacte => 'Ya lo contacté';

  @override
  String get avisosEstafa => 'Es una estafa';

  @override
  String get avisosEstafaTitulo => '¿Marcar como estafa?';

  @override
  String get avisosEstafaExplicacion =>
      'Esa persona no va a poder mandarte más avisos. No le avisamos que la bloqueaste.';

  @override
  String get avisosMarcadoEstafa =>
      'Marcado como estafa: esa persona ya no puede mandarte avisos.';

  @override
  String avisosContacto(String contacto) {
    return 'Contacto: $contacto';
  }

  @override
  String get avisosRespondido => 'Ya lo contactaste';

  @override
  String get avisosLlamar => 'Llamar';

  @override
  String get avisosWhatsapp => 'WhatsApp';

  @override
  String get avisosVerUbicacion => 'Ver ubicación';

  @override
  String get qrEscaneosTitulo => 'Últimos escaneos';

  @override
  String get qrSinEscaneos => 'Todavía nadie escaneó este QR.';

  @override
  String get qrEscaneoConUbicacion => 'Compartió su ubicación: tocá para verla';

  @override
  String get qrEscaneoSinUbicacion => 'Abrieron la página';

  @override
  String get sosPerdi => 'Perdí una mascota';

  @override
  String get sosEncontre => 'Encontré una mascota';

  @override
  String get sosCualMascota => '¿Cuál?';

  @override
  String get sosOtraMascota => 'Otra';

  @override
  String get sosFotos => 'Fotos (al menos una)';

  @override
  String get sosFotoDeLaFicha => 'Foto de su ficha';

  @override
  String sosFotoN(int n) {
    return 'Foto $n';
  }

  @override
  String get sosDondePerdida => '¿Dónde la viste por última vez?';

  @override
  String get sosDondeEncontrada => '¿Dónde la encontraste o la viste?';

  @override
  String get sosUbicacionAyuda =>
      'Tocá el mapa en el lugar. Al publicar se muestra una zona aproximada, nunca el punto exacto.';

  @override
  String get sosUbicacionMarcada => 'Lugar marcado ✔';

  @override
  String get sosNombreSiLoSabes =>
      'Nombre (si lo sabés, por la chapita o el collar)';

  @override
  String get sosDescripcionAyudaPerdida =>
      '¿Cómo se perdió? ¿Tiene collar? ¿Es miedosa?';

  @override
  String get sosDescripcionAyudaEncontrada =>
      '¿Cómo está? ¿La tenés con vos o sigue suelta?';

  @override
  String get sosCuandoPerdida => '¿Cuándo se perdió?';

  @override
  String get sosCuandoEncontrada => '¿Cuándo la encontraste?';

  @override
  String get sosTieneMicrochip => 'Tiene microchip';

  @override
  String get sosRecompensa => 'Recompensa (opcional)';

  @override
  String get sosRecompensaAyuda =>
      'Si ofrecés una, ponela acá. Nunca pagues antes de tener a tu mascota.';

  @override
  String get sosPrivacidad =>
      'Tu teléfono no se publica: quien la vea te va a dejar un aviso con su contacto y vos decidís si respondés.';

  @override
  String get sosPublicar => 'Publicar';

  @override
  String get sosFaltaFoto => 'Agregá al menos una foto.';

  @override
  String get sosFaltaUbicacion => 'Marcá en el mapa dónde fue.';

  @override
  String get sosLimiteDiario =>
      'Ya publicaste 3 reportes hoy. Si es urgente, escribinos a soporte.';

  @override
  String get sosDetalleTitulo => 'Reporte';

  @override
  String get sosPublicado =>
      '¡Publicado! Los vecinos de la zona ya pueden verlo.';

  @override
  String get fichaReportarPerdida => 'Se perdió: reportarla';

  @override
  String get sosFiltroTodos => 'Todos';

  @override
  String get sosFiltroPerdidas => 'Perdidas';

  @override
  String get sosFiltroEncontradas => 'Encontradas';

  @override
  String get sosNingunoCerca =>
      'No hay reportes activos cerca. ¡Ojalá siga así! 🐾';

  @override
  String sosTituloPerdida(String nombre) {
    return 'Se perdió: $nombre';
  }

  @override
  String sosTituloEncontrada(String especie) {
    return 'Encontrada: $especie';
  }

  @override
  String sosDistanciaYTiempo(String distancia, String cuando) {
    return 'A $distancia · $cuando';
  }

  @override
  String get haceUnMomento => 'hace un momento';

  @override
  String haceMinutos(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'hace $n minutos',
      one: 'hace 1 minuto',
    );
    return '$_temp0';
  }

  @override
  String haceHoras(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'hace $n horas',
      one: 'hace 1 hora',
    );
    return '$_temp0';
  }

  @override
  String haceDias(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'hace $n días',
      one: 'hace 1 día',
    );
    return '$_temp0';
  }

  @override
  String elDia(int dia, int mes) {
    return 'el $dia/$mes';
  }
}
