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

  @override
  String get sosMostrarWhatsapp => 'Mostrar mi WhatsApp en este reporte';

  @override
  String get sosMostrarWhatsappRiesgo =>
      'No recomendado: cualquiera vería tu número y es la vía más usada para estafas. Sin esto, igual te llegan los avisos.';

  @override
  String get sosTuWhatsapp => 'Tu WhatsApp';

  @override
  String get sosWhatsappInvalido => 'Revisá el número (ej.: 099 123 456).';

  @override
  String get sosNoEncontrado =>
      'Este reporte no existe o ya no está disponible.';

  @override
  String get sosEnlaceCopiado =>
      'Enlace copiado: pegalo en WhatsApp o Facebook para compartirlo.';

  @override
  String get sosAvisarMotivoCuenta =>
      'Para avisar desde la app necesitamos una cuenta (así evitamos avisos falsos). También podés avisar desde la página web del reporte, sin cuenta.';

  @override
  String get sosAvisoEnviado => '¡Gracias! Tu aviso le llegó.';

  @override
  String get sosWhatsappAdvertenciaTitulo => 'Antes de escribir por WhatsApp';

  @override
  String get sosWhatsappAdvertencia =>
      'Nunca pidas ni mandes plata. Si alguien te pide un pago para devolver una mascota, es una estafa.';

  @override
  String get sosWhatsappAbrir => 'Abrir WhatsApp';

  @override
  String get sosEstadoResuelto => '¡Apareció! Este reporte ya está resuelto.';

  @override
  String get sosEstadoArchivado => 'Este reporte está archivado.';

  @override
  String get sosEstadoOculto =>
      'Este reporte está oculto mientras lo revisamos.';

  @override
  String sosRecompensaValor(String valor) {
    return 'Recompensa: $valor';
  }

  @override
  String get sosConsejoVeterinaria =>
      'Si la tenés con vos, llevala a una veterinaria: pueden leer si tiene microchip y avisar a su familia.';

  @override
  String get sosConsejoVista =>
      'Si la ves, no la persigas: avisá al dueño con el lugar y la hora. Una foto ayuda mucho.';

  @override
  String get sosConsejoDuenoRenac =>
      'Si tiene microchip, marcala como extraviada en el RENAC (consultá en tu veterinaria). Compartí este reporte en los grupos de la zona.';

  @override
  String get sosConsejoEncontradaPropia =>
      'Si la llevás a una veterinaria, pueden leer si tiene microchip y encontrar a su familia más rápido.';

  @override
  String get sosZonaAproximada => 'Zona aproximada';

  @override
  String get sosAvisarDueno => 'Avisar al dueño';

  @override
  String get sosAvisarQuienEncontro => 'Es mía / sé de quién es';

  @override
  String get sosCompartir => 'Compartir';

  @override
  String get sosPrivacidadDetalle =>
      'El teléfono del autor no se muestra: tu aviso le llega y decide cómo contactarte. La ubicación del mapa es aproximada.';

  @override
  String get sosAvisarTitulo => 'Dejale un aviso';

  @override
  String get sosAvisoMensaje => 'Mensaje (dónde y cuándo la viste)';

  @override
  String get sosAvisoNombre => 'Tu nombre';

  @override
  String get sosAvisoContacto => 'Tu teléfono o WhatsApp';

  @override
  String get sosAvisoConsentimiento =>
      'Acepto que reciba mi nombre y mi teléfono para contactarme.';

  @override
  String get sosAvisoFaltaConsentimiento =>
      'Para enviar el aviso tenés que aceptar compartir tu contacto.';

  @override
  String get sosAvisoEnviar => 'Enviar aviso';

  @override
  String get sosCampoObligatorio => 'Completá este dato.';

  @override
  String get sosAparecio => '¡Apareció!';

  @override
  String get sosAparecioTitulo => '¿Apareció?';

  @override
  String get sosAparecioExplicacion =>
      'El reporte deja de mostrarse en el mapa y la página de su QR deja de decir \"Estoy perdido\".';

  @override
  String get sosAparecioGracias => '¡Qué alegría! 💚 Gracias por avisar.';

  @override
  String get sosArchivar => 'Archivar';

  @override
  String get sosArchivarTitulo => '¿Archivar el reporte?';

  @override
  String get sosArchivarExplicacion =>
      'Deja de mostrarse en el mapa y en la lista. Usalo si ya no hace falta, aunque no haya aparecido.';

  @override
  String get sosMisReportes => 'Mis reportes';

  @override
  String get sosEstadoActivoCorto => 'Activo';

  @override
  String get sosEstadoResueltoCorto => 'Apareció';

  @override
  String get sosEstadoArchivadoCorto => 'Archivado';

  @override
  String get sosEstadoOcultoCorto => 'En revisión';

  @override
  String get sosReportarContenido => 'Reportar publicación';

  @override
  String get sosReportarContenidoMotivoCuenta =>
      'Para reportar una publicación necesitás una cuenta: así evitamos reportes falsos.';

  @override
  String get sosReportarContenidoExplicacion =>
      'Si varias personas la reportan, se oculta hasta que la revisemos. Quien la publicó no sabe quién la reportó.';

  @override
  String get sosReportarContenidoDetalle => 'Contanos más (opcional)';

  @override
  String get sosReportarContenidoEnviar => 'Enviar reporte';

  @override
  String get sosReportarContenidoFaltaMotivo => 'Elegí un motivo.';

  @override
  String get sosReportarContenidoGracias => 'Gracias, lo vamos a revisar.';

  @override
  String get sosReportarContenidoYaReportado =>
      'Ya habías reportado esta publicación. La estamos revisando.';

  @override
  String get sosMotivoFalso => 'Es falso';

  @override
  String get sosMotivoEstafa => 'Parece una estafa';

  @override
  String get sosMotivoSpam => 'Spam o publicidad';

  @override
  String get sosMotivoOfensivo => 'Ofensivo';

  @override
  String get sosMotivoOtro => 'Otro';

  @override
  String get pushInterruptor => 'Avisos en este dispositivo';

  @override
  String get pushDetalle =>
      'Te avisamos si alguien encuentra a tu mascota o escanea su QR.';

  @override
  String get pushNoDisponible =>
      'Este navegador no admite avisos. En iPhone, primero agregá SOS Mascota a la pantalla de inicio (Compartir → Agregar a inicio) y abrila desde ahí.';

  @override
  String get pushBloqueado =>
      'Los avisos están bloqueados en este navegador. Habilitalos desde el candado de la barra de direcciones → Notificaciones.';

  @override
  String get pushSinElegir =>
      'No se activaron los avisos. Podés hacerlo cuando quieras desde Ajustes.';

  @override
  String get pushTarjeta =>
      'Activá los avisos para enterarte al instante si alguien encuentra a tu mascota.';

  @override
  String get pushActivar => 'Activar avisos';

  @override
  String get pushActivados =>
      '¡Listo! Vas a recibir los avisos en este dispositivo.';

  @override
  String get pushError =>
      'No pudimos activar los avisos. Revisá tu conexión y probá de nuevo.';

  @override
  String get ubicacionDialogoTitulo =>
      '¿Te avisamos de mascotas perdidas cerca tuyo?';

  @override
  String get ubicacionDialogoTexto =>
      'Para eso guardamos una zona aproximada (unos 500 m), nunca tu ubicación exacta. Nadie más la ve y la podés borrar cuando quieras desde Ajustes.';

  @override
  String get ubicacionAhoraNo => 'Ahora no';

  @override
  String get ubicacionUsar => 'Usar mi zona';

  @override
  String get ubicacionTitulo => 'Zona para avisos de perdidos';

  @override
  String get ubicacionGuardada =>
      'Guardada: una zona aproximada (unos 500 m), nunca tu ubicación exacta.';

  @override
  String get ubicacionSinGuardar =>
      'Sin guardar: no te llegan avisos de mascotas perdidas cerca.';

  @override
  String get ubicacionBloqueada =>
      'La ubicación está bloqueada en este navegador. Habilitala desde el candado de la barra de direcciones → Ubicación.';

  @override
  String get ubicacionNoDisponible =>
      'Este dispositivo no nos da la ubicación.';

  @override
  String get ubicacionBorrar => 'Borrar';

  @override
  String get ubicacionGuardadaOk =>
      '¡Listo! Te vamos a avisar de las mascotas perdidas cerca de tu zona.';

  @override
  String get ubicacionBorradaOk =>
      'Borramos tu zona. Ya no te llegan avisos por cercanía.';

  @override
  String get ubicacionError =>
      'No pudimos obtener tu ubicación. Revisá tu conexión y probá de nuevo.';

  @override
  String get leyendaPerdido => 'Perdido';

  @override
  String get leyendaEncontrado => 'Encontrado';

  @override
  String get leyendaVeterinaria => 'Veterinaria';

  @override
  String get leyendaUrgencia => 'Urgencias / 24 h';

  @override
  String get comercioAbierto24h => 'Abierto las 24 h';

  @override
  String comercioAbiertoHasta(String hora) {
    return 'Abierto · cierra a las $hora';
  }

  @override
  String comercioCerradoHoy(String hora) {
    return 'Cerrado · abre hoy a las $hora';
  }

  @override
  String comercioCerradoManana(String hora) {
    return 'Cerrado · abre mañana a las $hora';
  }

  @override
  String comercioCerradoDia(String dia, String hora) {
    return 'Cerrado · abre el $dia a las $hora';
  }

  @override
  String get comercioSinHorario => 'Horario sin cargar';

  @override
  String get comercio24h => '24 h';

  @override
  String get comercioUrgencias => 'Urgencias';

  @override
  String get comercioEjemplo => 'Ejemplo';

  @override
  String get comercioEjemploAviso =>
      'Es un dato de ejemplo para probar la app: no es una veterinaria real.';

  @override
  String comercioAtiende(String especies) {
    return 'Atiende: $especies';
  }

  @override
  String get comercioHorarioSemana => 'Horario de la semana';

  @override
  String get comercioDiaCerrado => 'Cerrado';

  @override
  String get comercioLlamar => 'Llamar';

  @override
  String get comercioWhatsapp => 'WhatsApp';

  @override
  String get comercioComoLlegar => 'Cómo llegar';

  @override
  String get comercioWeb => 'Web';

  @override
  String get comercioInstagram => 'Instagram';

  @override
  String get diaLunes => 'lunes';

  @override
  String get diaMartes => 'martes';

  @override
  String get diaMiercoles => 'miércoles';

  @override
  String get diaJueves => 'jueves';

  @override
  String get diaViernes => 'viernes';

  @override
  String get diaSabado => 'sábado';

  @override
  String get diaDomingo => 'domingo';

  @override
  String get ayuda911Titulo => '¿Hay una persona en riesgo?';

  @override
  String get ayuda911Texto =>
      'Llamá al 911. SOS Mascota es solo para animales.';

  @override
  String get ayuda911Boton => 'Llamar al 911';

  @override
  String get ayudaUrgencias => 'Veterinarias de urgencia';

  @override
  String get ayudaSinUrgencias =>
      'Todavía no hay veterinarias de urgencia cargadas en tu zona.';

  @override
  String get ayudaRefugios => 'Refugios y protectoras';

  @override
  String get ayudaGrupos => 'Grupos para difundir';

  @override
  String get ayudaOrganismos => 'Organismos';

  @override
  String get ayudaAbrir => 'Abrir';

  @override
  String get ayudaDirectorioVacio =>
      'Todavía no hay refugios ni grupos cargados en tu zona.';

  @override
  String get ajustesTema => 'Tema de colores';

  @override
  String ajustesTemaPro(String nombre) {
    return '$nombre · beneficio de tu plan Pro';
  }

  @override
  String get temaElegirTitulo => 'Elegí cómo se ve la app';

  @override
  String get temaExplicacion =>
      'Cambia los colores y las letras de la app solo en este dispositivo. El mapa, la chapita y lo que ven los demás siguen igual.';

  @override
  String get temaCielo => 'Cielo';

  @override
  String get temaCieloDescripcion => 'Calma y confianza: el de SOS Mascota';

  @override
  String get temaFaro => 'Faro';

  @override
  String get temaFaroDescripcion => 'Naranja de rescate y azul noche';

  @override
  String get temaVecinos => 'Vecinos';

  @override
  String get temaVecinosDescripcion => 'Terracota y mostaza, de barrio';

  @override
  String get temaPop => 'Pop';

  @override
  String get temaPopDescripcion => 'Violeta y amarillo, tipo sticker';

  @override
  String get noDisponibleTitulo => 'Todavía no está disponible';

  @override
  String get noDisponibleTexto =>
      'Esta función se está probando de a poco y todavía no te llegó. Cuando esté lista para vos, la vas a ver en la app.';

  @override
  String get noDisponibleIrAlMapa => 'Ir al mapa';

  @override
  String get instalarTitulo => 'Instalar la app';

  @override
  String get instalarSubtitulo =>
      'Abrila desde la pantalla de inicio, más rápido y con avisos';

  @override
  String get instalarTarjetaTitulo => 'Instalá SOS Mascota';

  @override
  String get instalarTarjetaTexto =>
      'Queda en tu pantalla de inicio y te avisa enseguida si se pierde una mascota cerca.';

  @override
  String get instalarBoton => 'Instalar';

  @override
  String get instalarAhoraNo => 'Ahora no';

  @override
  String get instalarGracias =>
      '¡Listo! Ya podés abrir SOS Mascota desde la pantalla de inicio.';

  @override
  String get instalarIphoneTitulo => 'Instalar en el iPhone';

  @override
  String get instalarIphonePaso1 => 'Abrí esta página en Safari.';

  @override
  String get instalarIphonePaso2 =>
      'Tocá Compartir (el cuadrado con la flecha hacia arriba).';

  @override
  String get instalarIphonePaso3 =>
      'Elegí «Agregar a inicio» y después «Agregar».';

  @override
  String get instalarIphoneAvisos =>
      'En el iPhone, los avisos de mascotas perdidas solo llegan con la app instalada.';

  @override
  String get instalarEntendido => 'Entendido';

  @override
  String get libretaTitulo => 'Libreta sanitaria';

  @override
  String get libretaVacia =>
      'Anotá vacunas, desparasitaciones, controles y alergias para tenerlas siempre a mano.';

  @override
  String get libretaAgregar => 'Agregar a la libreta';

  @override
  String get libretaNuevoTitulo => 'Nuevo registro';

  @override
  String get libretaEditarTitulo => 'Editar registro';

  @override
  String get libretaTipo => 'Tipo';

  @override
  String get libretaTipoVacuna => 'Vacuna';

  @override
  String get libretaTipoDesparasitacion => 'Desparasitación';

  @override
  String get libretaTipoControl => 'Control';

  @override
  String get libretaTipoAlergia => 'Alergia';

  @override
  String get libretaTipoOtro => 'Otro';

  @override
  String get libretaGrupoVacunas => 'Vacunas';

  @override
  String get libretaGrupoDesparasitaciones => 'Desparasitaciones';

  @override
  String get libretaGrupoControles => 'Controles';

  @override
  String get libretaGrupoAlergias => 'Alergias';

  @override
  String get libretaGrupoOtros => 'Otros';

  @override
  String get libretaNombre => 'Nombre';

  @override
  String get libretaNombreAyudaVacuna =>
      'Por ejemplo: Antirrábica, Séxtuple, Triple felina.';

  @override
  String get libretaNombreAyudaDesparasitacion =>
      'Por ejemplo: pipeta, comprimido, interna o externa.';

  @override
  String get libretaNombreAyudaControl =>
      'Por ejemplo: control anual, análisis de sangre.';

  @override
  String get libretaNombreAyudaAlergia =>
      'Por ejemplo: pollo, un medicamento, picadura de pulga.';

  @override
  String get libretaNombreAyudaOtro => 'Cirugía, tratamiento, peso…';

  @override
  String get libretaNombreFalta => 'Escribí qué fue.';

  @override
  String get libretaNombreLargo => 'Usá hasta 80 letras.';

  @override
  String get libretaFecha => 'Fecha';

  @override
  String get libretaFechaElegir => 'Elegir';

  @override
  String get libretaFechaSin => 'Sin fecha';

  @override
  String get libretaProxima => 'Próxima dosis o control';

  @override
  String get libretaProximaAyuda =>
      'Opcional. Sirve para recordarte cuándo toca.';

  @override
  String get libretaProximaAntes =>
      'La próxima fecha no puede ser anterior a la fecha.';

  @override
  String get libretaQuitarFecha => 'Quitar';

  @override
  String get libretaNotas => 'Notas';

  @override
  String get libretaNotasAyuda =>
      'Lote, veterinaria, dosis… (solo lo ves vos).';

  @override
  String get libretaBorrar => 'Borrar registro';

  @override
  String libretaBorrarTitulo(String nombre) {
    return '¿Borrar «$nombre»?';
  }

  @override
  String get libretaBorrarExplicacion =>
      'Se borra de la libreta y no se puede recuperar.';

  @override
  String libretaProximaEl(String fecha) {
    return 'Próxima: $fecha';
  }

  @override
  String semaforoVencio(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: '$dias días',
      one: '1 día',
    );
    return 'Venció hace $_temp0';
  }

  @override
  String get semaforoHoy => 'Vence hoy';

  @override
  String semaforoFaltan(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: 'Faltan $dias días',
      one: 'Falta 1 día',
    );
    return '$_temp0';
  }

  @override
  String get libretaProximoUrgente => 'Lo próximo de la libreta';

  @override
  String get recordatoriosTitulo => 'Recordatorios';

  @override
  String get recordatoriosVacio =>
      'Programá remedios, comidas o vacunas y te avisamos a la hora.';

  @override
  String get recordatoriosAgregar => 'Agregar recordatorio';

  @override
  String get recordatorioNuevoTitulo => 'Nuevo recordatorio';

  @override
  String get recordatorioEditarTitulo => 'Editar recordatorio';

  @override
  String get recordatorioTipoMedicacion => 'Medicación';

  @override
  String get recordatorioTitulo => 'Remedio';

  @override
  String get recordatorioTituloAyuda =>
      'Por ejemplo: antibiótico, antiinflamatorio, gotas para los oídos.';

  @override
  String get recordatorioTituloFalta => 'Escribí de qué es el recordatorio.';

  @override
  String get recordatorioTituloLargo => 'Usá hasta 80 letras.';

  @override
  String get recordatorioDosis => 'Dosis (opcional)';

  @override
  String get recordatorioDosisAyuda => 'Por ejemplo: 1/2 comprimido, 5 gotas.';

  @override
  String get recordatorioFrecuencia => 'Cada cuánto';

  @override
  String get recordatorioCadaHoras => 'Cada X horas';

  @override
  String get recordatorioDiaria => 'Todos los días';

  @override
  String get recordatorioSemanal => 'Algunos días';

  @override
  String recordatorioCadaNHoras(int horas) {
    String _temp0 = intl.Intl.pluralLogic(
      horas,
      locale: localeName,
      other: 'Cada $horas horas',
      one: 'Cada 1 hora',
    );
    return '$_temp0';
  }

  @override
  String get recordatorioPrimeraToma => 'Primera toma';

  @override
  String get recordatorioInicio => 'Desde';

  @override
  String get recordatorioHorarios => 'Horarios';

  @override
  String get recordatorioAgregarHorario => 'Agregar horario';

  @override
  String recordatorioQuitarHorario(String hora) {
    return 'Quitar $hora';
  }

  @override
  String get recordatorioSinHorarios => 'Agregá al menos un horario.';

  @override
  String get recordatorioDias => 'Días';

  @override
  String get recordatorioSinDias => 'Elegí al menos un día.';

  @override
  String get recordatorioFin => 'Hasta';

  @override
  String get recordatorioFinSin => 'Sin fecha de fin';

  @override
  String get recordatorioFinAntes =>
      'La fecha de fin no puede ser anterior al inicio.';

  @override
  String get recordatorioActivo => 'Avisarme';

  @override
  String get recordatorioPausado => 'Pausado';

  @override
  String get recordatorioTerminado => 'Terminado';

  @override
  String recordatorioProxima(String cuando) {
    return 'Próxima: $cuando';
  }

  @override
  String recordatorioHoyA(String hora) {
    return 'hoy a las $hora';
  }

  @override
  String recordatorioMananaA(String hora) {
    return 'mañana a las $hora';
  }

  @override
  String recordatorioFechaA(String fecha, String hora) {
    return '$fecha a las $hora';
  }

  @override
  String get recordatorioBorrar => 'Borrar recordatorio';

  @override
  String recordatorioBorrarTitulo(String nombre) {
    return '¿Borrar «$nombre»?';
  }

  @override
  String get recordatorioBorrarExplicacion =>
      'Deja de avisarte y no se puede recuperar.';

  @override
  String recordatorioAvisoTitulo(String titulo, String mascota) {
    return '$titulo para $mascota';
  }

  @override
  String get recordatorioAvisoCuerpo => 'Es la hora.';

  @override
  String get recordatoriosAvisosWeb =>
      'En la web te avisamos mientras la app esté abierta (aunque esté minimizada). Instalada en Android o iPhone, te va a avisar siempre.';

  @override
  String get recordatoriosActivarAvisos => 'Activar avisos';

  @override
  String get recordatoriosAvisosBloqueados =>
      'Los avisos están bloqueados en este navegador. Habilitalos en la configuración del sitio.';

  @override
  String get recordatorioTipo => 'Tipo';

  @override
  String get recordatorioTipoComida => 'Comida';

  @override
  String get recordatorioTipoVacuna => 'Vacuna';

  @override
  String get recordatorioTipoControl => 'Control';

  @override
  String get recordatorioTituloComida => 'Comida';

  @override
  String get recordatorioTituloComidaAyuda =>
      'Por ejemplo: balanceado, comida húmeda.';

  @override
  String get recordatorioTituloVacuna => 'Vacuna';

  @override
  String get recordatorioTituloVacunaAyuda =>
      'Por ejemplo: Antirrábica, Séxtuple, Triple felina.';

  @override
  String get recordatorioTituloControl => 'Control';

  @override
  String get recordatorioTituloControlAyuda =>
      'Por ejemplo: control anual, análisis de sangre.';

  @override
  String get recordatorioPorcion => 'Porción (opcional)';

  @override
  String get recordatorioPorcionAyuda => 'Por ejemplo: 1 taza, 150 g.';

  @override
  String get recordatorioCuando => 'Cuándo';

  @override
  String get recordatorioYaPaso => 'Ya pasó';

  @override
  String libretaRecordarmeDe(String nombre) {
    return 'Recordarme $nombre';
  }

  @override
  String recordatorioYaSeLaDi(String hora) {
    return '✅ Ya se la di ($hora)';
  }

  @override
  String recordatorioYaComio(String hora) {
    return '✅ Ya comió ($hora)';
  }

  @override
  String recordatorioHecho(String hora) {
    return '✅ Hecho ($hora)';
  }

  @override
  String get recordatorioMarcado => 'Listo, quedó anotado.';

  @override
  String get recordatorioDeshacer => 'Deshacer';

  @override
  String get recordatorioHistorial => 'Historial';

  @override
  String get recordatorioHistorialVacio => 'Todavía no marcaste ninguna toma.';

  @override
  String recordatorioHistorialMarcada(String cuando) {
    return 'Marcada $cuando';
  }

  @override
  String get hogarTitulo => 'Mi hogar';

  @override
  String get hogarExplicacion =>
      'Compartí tus mascotas con tu familia: ven y editan la ficha, la libreta y los recordatorios, marcan «Ya se la di» y reciben los avisos del QR. Hasta 5 personas además de vos.';

  @override
  String get hogarInvitar => 'Invitar a alguien';

  @override
  String get hogarInvitacionTitulo => 'Invitación lista';

  @override
  String get hogarInvitacionTexto =>
      'Mandale este enlace por WhatsApp o como quieras. Sirve una sola vez y vence en 7 días.';

  @override
  String get hogarCopiar => 'Copiar enlace';

  @override
  String get hogarCopiado => 'Enlace copiado.';

  @override
  String hogarMensajeInvitacion(String enlace) {
    return 'Te invito a cuidar a mis mascotas en SOS Mascota: $enlace';
  }

  @override
  String get hogarCreador => 'Creó el hogar';

  @override
  String get hogarIntegrante => 'Integrante';

  @override
  String hogarCuidadorHasta(String fecha) {
    return 'Cuidador temporal hasta el $fecha';
  }

  @override
  String hogarVos(String nombre) {
    return '$nombre (vos)';
  }

  @override
  String get hogarSinNombre => 'Sin nombre';

  @override
  String get hogarSacar => 'Sacar del hogar';

  @override
  String hogarSacarTitulo(String nombre) {
    return '¿Sacar a $nombre?';
  }

  @override
  String get hogarSacarTexto => 'Deja de ver tus mascotas en ese momento.';

  @override
  String get hogarIrme => 'Salir de este hogar';

  @override
  String get hogarIrmeTitulo => '¿Salir del hogar?';

  @override
  String get hogarIrmeTexto =>
      'Dejás de ver sus mascotas. Para volver, te tienen que invitar de nuevo.';

  @override
  String get hogarSalir => 'Salir';

  @override
  String get hogarLleno => 'Ya son 5 integrantes: es el máximo.';

  @override
  String get hogarMio => 'Tu hogar';

  @override
  String hogarDe(String nombre) {
    return 'Hogar de $nombre';
  }

  @override
  String get hogarSoloVos => 'Todavía no invitaste a nadie.';

  @override
  String get unirmeTitulo => 'Invitación a un hogar';

  @override
  String get unirmeTexto =>
      'Te invitaron a cuidar mascotas en SOS Mascota. Vas a poder ver y editar sus fichas, la libreta y los recordatorios, y vas a recibir los avisos del QR. Las personas del hogar van a ver tu nombre (nunca tu correo).';

  @override
  String get unirmeBoton => 'Unirme';

  @override
  String get unirmeListo => '¡Listo! Ya ves sus mascotas en «Mis mascotas».';

  @override
  String get unirmeNoSirve =>
      'Esta invitación no existe, ya se usó o venció. Pedí una nueva.';

  @override
  String get unirmePropia =>
      'Este enlace es de tu propio hogar: mandáselo a quien quieras invitar.';

  @override
  String get unirmeYaSos => 'Ya sos parte de este hogar.';

  @override
  String get unirmeLleno => 'Ese hogar ya tiene 5 integrantes.';

  @override
  String mascotaCompartidaDe(String nombre) {
    return 'Compartida por $nombre';
  }

  @override
  String get mascotaCompartida => 'Compartida con vos';

  @override
  String recordatorioMarcadaPor(String nombre, String cuando) {
    return 'Marcada por $nombre $cuando';
  }

  @override
  String get perfilTitulo => 'Mi perfil';

  @override
  String get perfilAbrir => 'Mi perfil';

  @override
  String get perfilAbrirAyuda =>
      'Tu rol, tus mascotas y con quién compartís el cuidado.';

  @override
  String get perfilRol => 'Rol';

  @override
  String get perfilRolDueno => 'Dueño o dueña de mascotas';

  @override
  String get perfilRolAdmin => 'Administración de SOS Mascota';

  @override
  String get perfilPlan => 'Plan';

  @override
  String get perfilPlanGratis => 'Gratis';

  @override
  String get perfilPlanPro => 'Pro';

  @override
  String get perfilPlanFamilia => 'Familia';

  @override
  String get perfilMascotas => 'Mascotas a tu cargo';

  @override
  String get perfilSinMascotas =>
      'Todavía no tenés mascotas cargadas ni compartidas.';

  @override
  String perfilPropias(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad tuyas',
      one: '1 tuya',
    );
    return '$_temp0';
  }

  @override
  String perfilCompartidas(int cantidad) {
    String _temp0 = intl.Intl.pluralLogic(
      cantidad,
      locale: localeName,
      other: '$cantidad compartidas con vos',
      one: '1 compartida con vos',
    );
    return '$_temp0';
  }

  @override
  String get perfilCuidado => 'Con quién compartís el cuidado';

  @override
  String get perfilSinHogar =>
      'Por ahora cuidás solo/a. Podés invitar a tu familia desde «Mi hogar».';

  @override
  String get perfilVerHogar => 'Ver «Mi hogar»';

  @override
  String get ajustesHogar => 'Mi hogar';

  @override
  String get ajustesHogarAyuda => 'Compartí tus mascotas con tu familia.';

  @override
  String get tareasTitulo => 'Tareas de hoy';

  @override
  String get tareasVacio =>
      'Repartan el paseo, la comida o el baño: cada uno ve qué le toca y quién lo hizo.';

  @override
  String get tareasAgregar => 'Agregar tarea';

  @override
  String get tareaNueva => 'Nueva tarea';

  @override
  String get tareaPaseo => 'Paseo';

  @override
  String get tareaComida => 'Comida';

  @override
  String get tareaBano => 'Baño';

  @override
  String get tareaVeterinaria => 'Veterinaria';

  @override
  String get tareaOtra => 'Otra';

  @override
  String get tareaNota => 'Detalle (opcional)';

  @override
  String get tareaNotaAyuda => 'Por ejemplo: a la plaza, media porción.';

  @override
  String get tareaCuando => 'Cuándo';

  @override
  String get tareaHoy => 'Hoy';

  @override
  String get tareaManana => 'Mañana';

  @override
  String get tareaAsignar => 'Le toca a';

  @override
  String get tareaNadie => 'Cualquiera';

  @override
  String tareaLeToca(String nombre) {
    return 'Le toca a $nombre';
  }

  @override
  String get tareaTeToca => 'Te toca a vos';

  @override
  String get tareaSinAsignar => 'Cualquiera la puede hacer';

  @override
  String tareaHechaPor(String nombre, String cuando) {
    return 'Hecha por $nombre $cuando';
  }

  @override
  String tareaHechaPorVos(String cuando) {
    return 'La hiciste vos $cuando';
  }

  @override
  String get tareaMarcar => 'Marcar hecha';

  @override
  String get tareaDesmarcar => 'Marcar pendiente';

  @override
  String get tareaBorrar => 'Borrar tarea';

  @override
  String get tareaCrear => 'Agregar';

  @override
  String get hogarInvitarCuidador => 'Invitar a un cuidador temporal';

  @override
  String get cuidadorTitulo => 'Cuidador temporal';

  @override
  String get cuidadorExplicacion =>
      'Para vacaciones o guardería: solo ve las mascotas que elijas y durante los días que digas. Después deja de verlas solo.';

  @override
  String get cuidadorMascotas => 'Qué mascotas cuida';

  @override
  String get cuidadorDias => 'Durante';

  @override
  String cuidadorNDias(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: '$dias días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get cuidadorSinMascotas => 'Primero cargá una mascota.';

  @override
  String get cuidadorInvitar => 'Crear invitación';
}
