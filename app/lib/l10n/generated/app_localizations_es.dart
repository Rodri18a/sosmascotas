// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appNombre => 'Huellitas';

  @override
  String get appNombreComercios => 'Huellitas Comercios';

  @override
  String get logoNombre => 'Huellitas';

  @override
  String get logoFrase => 'La comunidad que deja huella';

  @override
  String get pestanaMapa => 'Mapa';

  @override
  String get pestanaSos => 'SOS';

  @override
  String get pestanaMascotas => 'Mis mascotas';

  @override
  String get pestanaAyuda => 'Urgencias';

  @override
  String get barraMascotas => 'Mascotas';

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
  String get cuentaParaPedir =>
      'Para armar un pedido necesitás una cuenta: así el comercio sabe quién le pide y vos lo seguís en «Mis pedidos».';

  @override
  String get cuentaParaConsultar =>
      'Para consultarle al comercio necesitás una cuenta: así evitamos mensajes falsos y te puede responder.';

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
      'Para usar tu cuenta necesitamos que leas y aceptes cómo funciona Huellitas y cómo cuidamos tus datos. En resumen:';

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
  String get mascotaSalirTitulo => '¿Salir sin guardar?';

  @override
  String get mascotaSalirExplicacion =>
      'Si salís ahora, se pierden los cambios (también la foto). Para que queden, tocá Guardar.';

  @override
  String get mascotaSalirSeguir => 'Seguir editando';

  @override
  String get mascotaSalirDescartar => 'Salir sin guardar';

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
  String get qrDescargar => 'Descargar la etiqueta para el collar';

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
  String get chapitasTitulo => 'Chapitas físicas';

  @override
  String chapitasExplicacion(Object nombre) {
    return 'Si tenés una chapita de Huellitas, vinculala con $nombre: escaneala con la cámara del celular o escribí el código que tiene impreso.';
  }

  @override
  String get chapitasNinguna => 'Todavía no vinculaste ninguna chapita.';

  @override
  String get chapitaActivar => 'Activar una chapita';

  @override
  String get chapitaCodigo => 'Código de la chapita';

  @override
  String get chapitaCodigoAyuda =>
      'Son 8 letras y números, impresos en la chapita.';

  @override
  String get chapitaCodigoInvalido =>
      'Revisá el código: son 8 letras y números.';

  @override
  String chapitaActivada(Object nombre) {
    return '¡Listo! Quien escanee la chapita va a ver a $nombre.';
  }

  @override
  String get chapitaInexistente =>
      'No encontramos una chapita con ese código. Revisá que esté bien escrito.';

  @override
  String get chapitaUsada =>
      'Esta chapita ya está vinculada o se dio de baja, y no se puede volver a usar.';

  @override
  String get chapitaLimite =>
      'Activaste muchas chapitas hoy. Probá de nuevo mañana.';

  @override
  String get chapitaDesvincular => 'Desvincular';

  @override
  String get chapitaDesvincularTitulo => '¿Desvincular la chapita?';

  @override
  String chapitaDesvincularTexto(Object codigo, Object nombre) {
    return 'La chapita $codigo deja de mostrar a $nombre y no se puede volver a usar. Hacelo si la perdiste o la vas a reemplazar.';
  }

  @override
  String get chapitaDesvinculada => 'Chapita desvinculada.';

  @override
  String get activarChapitaTitulo => 'Activar chapita';

  @override
  String get activarChapitaTexto =>
      'Elegí qué mascota va a llevar esta chapita. Quien la escanee va a ver su foto y su nombre, y va a poder avisarte sin ver tu teléfono.';

  @override
  String get activarChapitaSinMascotas =>
      'Primero cargá a tu mascota y después volvé a escanear la chapita.';

  @override
  String get activarChapitaBoton => 'Activar';

  @override
  String get avisosTitulo => 'Avisos';

  @override
  String get avisosVacio =>
      'Todavía no tenés avisos. Si alguien escanea el QR de tu mascota y te deja un mensaje, lo vas a ver acá.';

  @override
  String get avisosAntiEstafa =>
      'Nunca pagues por adelantado ni mandes plata para recuperar a tu mascota. Si te la piden, marcá el aviso como estafa. Si encontraste una mascota y alguien dice que es suya, antes de entregarla pedile fotos de antes con ella o el carné de vacunas y una seña que no publicaste, y encuéntrense en un lugar público.';

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
  String get fichaVerReportePerdida => 'Ver su reporte de perdida';

  @override
  String get sosYaReportada =>
      'Esta mascota ya tiene un reporte de perdida abierto. Lo encontrás en su ficha o en SOS.';

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
  String get sosSenasAyudaEncontrada =>
      'Guardate una seña sin publicar: te sirve para comprobar quién es su familia.';

  @override
  String get sosCartel => 'Imprimir cartel';

  @override
  String get sosCartelExplicacion =>
      'Un cartel A4 para pegar en el barrio, con la foto y un QR: quien la vea avisa desde el celular, sin la app. No lleva tu teléfono.';

  @override
  String get sosCartelDondePerdida =>
      '¿Dónde la vieron por última vez? (opcional)';

  @override
  String get sosCartelDondeEncontrada => '¿Dónde la encontraste? (opcional)';

  @override
  String get sosCartelDondeAyuda =>
      'Un barrio o una referencia, por ejemplo: Centro, cerca de la plaza. Nunca tu dirección.';

  @override
  String get sosCartelArmar => 'Armar el cartel';

  @override
  String get sosCartelSeBusca => 'SE BUSCA';

  @override
  String get sosCartelSeEncontro => 'SE ENCONTRÓ';

  @override
  String get sosCartelEsTuyo => '¿Es tuyo?';

  @override
  String sosCartelSenas(String senas) {
    return 'Señas: $senas';
  }

  @override
  String sosCartelFaltaDesde(String fecha) {
    return 'Falta desde el $fecha';
  }

  @override
  String sosCartelEncontradaEl(String fecha) {
    return 'Encontrada el $fecha';
  }

  @override
  String sosCartelVistaEn(String lugar) {
    return 'Vista por última vez: $lugar';
  }

  @override
  String sosCartelEncontradaEn(String lugar) {
    return 'Encontrada en: $lugar';
  }

  @override
  String get sosCartelEscaneaPerdida =>
      '¿La viste? Escaneá el QR con la cámara del celular.';

  @override
  String get sosCartelEscaneaEncontrada =>
      '¿Es tuyo o sabés de quién es? Escaneá el QR con la cámara del celular.';

  @override
  String get sosCartelPrivacidadPerdida =>
      'Vas a ver su reporte y podés dejarle un mensaje a su familia con dónde y cuándo la viste. Huellitas es la comunidad que deja huella.';

  @override
  String get sosCartelPrivacidadEncontrada =>
      'Vas a ver el reporte y podés dejarle un mensaje a quien lo encontró. Huellitas es la comunidad que deja huella.';

  @override
  String sosCartelPie(String enlace) {
    return 'Huellitas · la comunidad que deja huella: encontrar, adoptar, eventos y servicios · $enlace';
  }

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
      'Este navegador no admite avisos. En iPhone, primero agregá Huellitas a la pantalla de inicio (Compartir → Agregar a inicio) y abrila desde ahí.';

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
  String get ayuda911Texto => 'Llamá al 911. Huellitas es solo para animales.';

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
  String get temaCielo => 'Huellitas';

  @override
  String get temaCieloDescripcion => 'Celeste y alegre: el de la marca';

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
  String get temaBlancoNegro => 'Blanco y negro';

  @override
  String get temaBlancoNegroDescripcion =>
      'Sin colores, con las barras blancas';

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
  String get instalarTarjetaTitulo => 'Instalá Huellitas';

  @override
  String get instalarTarjetaTexto =>
      'Queda en tu pantalla de inicio y te avisa enseguida si se pierde una mascota cerca.';

  @override
  String get instalarBoton => 'Instalar';

  @override
  String get instalarAhoraNo => 'Ahora no';

  @override
  String get instalarGracias =>
      '¡Listo! Ya podés abrir Huellitas desde la pantalla de inicio.';

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
    return 'Te invito a cuidar a mis mascotas en Huellitas: $enlace';
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
      'Te invitaron a cuidar mascotas en Huellitas. Vas a poder ver y editar sus fichas, la libreta y los recordatorios, y vas a recibir los avisos del QR. Las personas del hogar van a ver tu nombre (nunca tu correo).';

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
  String get perfilRolAdmin => 'Administración de Huellitas';

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

  @override
  String get chatMensajes => 'Mensajes';

  @override
  String get chatVacio =>
      'Todavía no tenés conversaciones. Desde un reporte de mascota perdida o encontrada podés escribirle a quien lo publicó.';

  @override
  String chatFamiliaDe(String nombre) {
    return 'Familia de $nombre';
  }

  @override
  String get chatFamiliaSinNombre => 'Familia de la mascota perdida';

  @override
  String get chatQuienEncontro => 'Quien la encontró';

  @override
  String get chatSinNombre => 'Persona de Huellitas';

  @override
  String chatSobreReporte(String nombre) {
    return 'Sobre el reporte de $nombre';
  }

  @override
  String get chatEscribir => 'Escribí un mensaje';

  @override
  String get chatEnviar => 'Enviar';

  @override
  String get chatFoto => 'Mandar una foto';

  @override
  String get chatUbicacion => 'Mandar mi ubicación';

  @override
  String get chatUbicacionTitulo => '¿Mandar tu ubicación exacta?';

  @override
  String get chatUbicacionTexto =>
      'La otra persona va a ver en el mapa dónde estás ahora. Mandala solo si hace falta, por ejemplo para encontrarse con la mascota.';

  @override
  String get chatUbicacionMandar => 'Mandar';

  @override
  String get chatUbicacionNoDisponible =>
      'No pudimos saber tu ubicación. Revisá los permisos del navegador.';

  @override
  String get chatVerEnMapa => 'Ver en el mapa';

  @override
  String get chatEscribirPorChat => 'Escribir por chat';

  @override
  String get chatSeguridad =>
      'Seguridad: nunca pagues por adelantado ni pases códigos, contraseñas o datos de tarjetas. Si alguien pide plata para devolver una mascota, reportalo.';

  @override
  String get chatPosibleEstafa =>
      'Ojo: este mensaje habla de plata o códigos. Nunca pagues por adelantado.';

  @override
  String get chatBloquear => 'Bloquear';

  @override
  String get chatDesbloquear => 'Desbloquear';

  @override
  String get chatBloquearTitulo => '¿Bloquear esta conversación?';

  @override
  String get chatBloquearTexto =>
      'No van a poder escribirse más. Podés desbloquearla después.';

  @override
  String get chatBloqueadaPorVos => 'Bloqueaste esta conversación.';

  @override
  String get chatBloqueadaPorOtro => 'Esta conversación ya no recibe mensajes.';

  @override
  String get chatReportar => 'Reportar mensaje';

  @override
  String get chatReportado => 'Gracias. Lo vamos a revisar.';

  @override
  String get chatMotivoEstafa => 'Me pide plata o datos';

  @override
  String get chatMotivoOfensivo => 'Es ofensivo o me acosa';

  @override
  String get chatMotivoOtro => 'Otro motivo';

  @override
  String get chatNoPuedo => 'Este reporte ya no está activo o es tuyo.';

  @override
  String get chatDemasiados => 'Abriste muchos chats hoy. Probá mañana.';

  @override
  String get sosSeguir => 'Seguir este reporte';

  @override
  String get sosDejarDeSeguir => 'Dejar de seguir';

  @override
  String get sosSiguiendo => 'Te vamos a avisar cuando vuelva a casa.';

  @override
  String get catVeterinarias => 'Veterinarias';

  @override
  String get catPetshops => 'Petshops';

  @override
  String get catFarmacias => 'Farmacias';

  @override
  String get catPeluquerias => 'Peluquerías';

  @override
  String get catPaseadores => 'Paseadores';

  @override
  String get catHoteles => 'Hoteles y guarderías';

  @override
  String get catAdiestradores => 'Adiestradores';

  @override
  String get catAceptan => 'Aceptan mascotas';

  @override
  String get catRefugios => 'Refugios';

  @override
  String get catAgros => 'Agropecuarias';

  @override
  String get catVeterinaria => 'Veterinaria';

  @override
  String get catPetshop => 'Petshop';

  @override
  String get catFarmacia => 'Farmacia veterinaria';

  @override
  String get catPeluqueria => 'Peluquería';

  @override
  String get catPaseador => 'Paseador';

  @override
  String get catHotel => 'Hotel o guardería';

  @override
  String get catAdiestrador => 'Adiestrador';

  @override
  String get catAcepta => 'Acepta mascotas';

  @override
  String get catRefugio => 'Refugio';

  @override
  String get catAgro => 'Agropecuaria / agroveterinaria';

  @override
  String get mapaVistaMapa => 'Mapa';

  @override
  String get mapaVistaLista => 'Lista';

  @override
  String get mapaVistaSinLocal => 'Sin local';

  @override
  String get mapaPerdidos => 'Perdidos y encontrados';

  @override
  String get mapaFiltros => 'Filtros';

  @override
  String get mapaDistancia => 'Distancia';

  @override
  String get mapaDist300 => '300 m';

  @override
  String get mapaDist800 => '800 m';

  @override
  String get mapaDist2500 => '2,5 km';

  @override
  String get mapaDistTodo => 'Todo';

  @override
  String get mapaAbiertoAhora => 'Abierto ahora';

  @override
  String get mapaSoloFavoritos => 'Solo mis favoritos';

  @override
  String get mapaGrupoSalud => 'Salud';

  @override
  String get mapaGrupoTiendas => 'Tiendas';

  @override
  String get mapaGrupoCuidado => 'Cuidado';

  @override
  String get mapaGrupoSalidas => 'Salidas';

  @override
  String get mapaGrupoRefugios => 'Refugios';

  @override
  String get mapaGrupoQuitar => 'Quitar';

  @override
  String mapaGrupoParcial(String grupo, int cantidad) {
    return '$grupo · $cantidad';
  }

  @override
  String get leyendaTitulo => 'Referencias';

  @override
  String get leyendaMostrar => 'Mostrar las referencias';

  @override
  String get leyendaOcultar => 'Ocultar las referencias';

  @override
  String get mapaColocaMicrochip => 'Coloca microchip (Operador RENAC)';

  @override
  String get mapaEspecie => 'Para qué mascota';

  @override
  String mapaEspecieActiva(String nombre) {
    return 'Para $nombre';
  }

  @override
  String get mapaEspecieActivaSinNombre => 'Para mi mascota activa';

  @override
  String get mapaEspecieTodas => 'Para todas mis mascotas';

  @override
  String get mapaFiltrosLimpiar => 'Limpiar';

  @override
  String get mapaFiltrosListo => 'Listo';

  @override
  String get mapaListaVacia =>
      'No hay nada con estos filtros en esta zona. Mové el mapa o cambiá los filtros.';

  @override
  String get mapaSinLocalVacio =>
      'Todavía no hay tiendas online ni servicios a domicilio cargados.';

  @override
  String mapaA(String distancia) {
    return 'a $distancia';
  }

  @override
  String get modalidadOnline => 'Tienda online';

  @override
  String get modalidadDomicilio => 'A domicilio';

  @override
  String get leyendaComercio => 'Comercios y servicios';

  @override
  String get leyendaAcepta => 'Aceptan mascotas';

  @override
  String get fichaFavorito => 'Favorito';

  @override
  String get fichaQuitarFavorito => 'Quitar de favoritos';

  @override
  String get fichaFui => 'Fui';

  @override
  String fichaFuiEl(String fecha) {
    return 'Fuiste el $fecha';
  }

  @override
  String get fichaMiVeterinaria => 'Es mi veterinaria';

  @override
  String get fichaEsTuVeterinaria => 'Tu veterinaria';

  @override
  String get comercioRenac => 'Operador RENAC · coloca microchip';

  @override
  String get marcarLugar => 'Marcar un lugar';

  @override
  String get marcarExplicacion =>
      '¿Conocés un lugar que no está en el mapa? Elegí el rubro y tocá dónde queda. No hace falta el nombre: si varias personas lo marcan, se suma.';

  @override
  String get marcarRubro => 'Rubro';

  @override
  String get marcarToca => 'Tocá el mapa donde queda el lugar.';

  @override
  String get marcarEnlace => 'Enlace de Google Maps (opcional)';

  @override
  String get marcarEnlaceAyuda =>
      'Pegalo si lo tenés: ayuda a confirmar el lugar.';

  @override
  String get marcarGuardar => 'Marcar';

  @override
  String get marcarListo => '¡Gracias! Quedó marcado.';

  @override
  String get marcarYa => 'Ya marcaste este lugar.';

  @override
  String get marcarDemasiados => 'Marcaste muchos lugares hoy. Probá mañana.';

  @override
  String get marcarInvalido =>
      'Revisá el enlace: tiene que ser de Google Maps.';

  @override
  String get marcarFaltaPunto => 'Tocá el mapa para marcar dónde queda.';

  @override
  String sinReclamarTitulo(String rubro) {
    return '$rubro sin reclamar';
  }

  @override
  String sinReclamarMarcas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Marcado por $n personas',
      one: 'Marcado por 1 persona',
    );
    return '$_temp0';
  }

  @override
  String get sinReclamarEsTuyo => '¿Es tu negocio? Dalo de alta';

  @override
  String get sinReclamarVerGoogle => 'Ver en Google Maps';

  @override
  String get leyendaSinReclamar => 'Sin reclamar';

  @override
  String get reclamarEsTuyo => '¿Es tu negocio? Reclamalo';

  @override
  String get reclamarTitulo => 'Reclamar este lugar';

  @override
  String get reclamarTexto =>
      'Contanos que es tuyo. Para la insignia ✔️ el equipo valida el RUT. Si ya tiene a alguien a cargo, se revisa como disputa.';

  @override
  String get reclamarRut => 'RUT (12 números)';

  @override
  String get reclamarRutInvalido => 'El RUT tiene 12 números.';

  @override
  String get reclamarNota => '¿Cómo lo podemos comprobar? (opcional)';

  @override
  String get reclamarEnviar => 'Enviar reclamo';

  @override
  String get reclamarListo =>
      'Recibimos tu reclamo. Te avisamos cuando lo revisemos.';

  @override
  String get fichaPromo => 'Promoción';

  @override
  String get fichaFacebook => 'Facebook';

  @override
  String fichaCobertura(String zona) {
    return 'Trabaja en: $zona';
  }

  @override
  String get negocioMi => 'Mi negocio';

  @override
  String get negocioMiAyuda => 'Sumá tu comercio o servicio al mapa (gratis).';

  @override
  String get negocioAltaTitulo => 'Sumar mi negocio';

  @override
  String get negocioAltaExplicacion =>
      'Aparece al instante en el mapa como «no verificado». Para la insignia ✔️ pedís la verificación con tu RUT.';

  @override
  String get negocioNombre => 'Nombre del negocio';

  @override
  String get negocioNombreFalta => 'Escribí el nombre (2 letras o más).';

  @override
  String get negocioModalidad => 'Cómo atendés';

  @override
  String get negocioModalidadLocal => 'Con local';

  @override
  String get negocioModalidadOnline => 'Online';

  @override
  String get negocioModalidadDomicilio => 'A domicilio';

  @override
  String get negocioUbicacionToca => 'Tocá el mapa donde está tu local.';

  @override
  String get negocioCobertura => 'Zona donde trabajás';

  @override
  String get negocioCoberturaAyuda => 'Por ejemplo: Pando y alrededores.';

  @override
  String get negocioTelefono => 'Teléfono';

  @override
  String get negocioWhatsapp => 'WhatsApp (opcional)';

  @override
  String get negocioDescripcion => 'Descripción (opcional)';

  @override
  String get negocioWeb => 'Web (https://…)';

  @override
  String get negocioInstagram => 'Instagram (sin @)';

  @override
  String get negocioFacebook => 'Facebook (opcional)';

  @override
  String get negocioCrear => 'Sumar al mapa';

  @override
  String get negocioCreado => '¡Listo! Tu negocio ya está en el mapa.';

  @override
  String get negocioFaltaUbicacion => 'Tocá el mapa para marcar dónde está.';

  @override
  String get negocioDatosInvalidos =>
      'Revisá los datos (teléfono, web o Instagram).';

  @override
  String get modoComercio => 'Modo comercio';

  @override
  String get volverModoDueno => 'Volver al modo dueño';

  @override
  String get irAHuellitas => 'Ir a Huellitas';

  @override
  String get negocioPanel => 'Panel';

  @override
  String get negocioAgenda => 'Agenda';

  @override
  String get negocioCatalogo => 'Catálogo';

  @override
  String get negocioPedidos => 'Pedidos';

  @override
  String get negocioFicha => 'Negocio';

  @override
  String get moduloNoAplica => 'No aplica para tu tipo de negocio.';

  @override
  String get moduloSoloPlus => 'Llega con el plan Plus (Fase 3).';

  @override
  String get planBasico => 'Básico';

  @override
  String get planDestacado => 'Destacado';

  @override
  String get planPlus => 'Plus';

  @override
  String get verifNo => 'No verificado';

  @override
  String get verifPendiente => 'Verificación pendiente';

  @override
  String get verifSi => 'Verificado ✔️';

  @override
  String socioFundadorHasta(String fecha) {
    return 'Socio Fundador hasta el $fecha';
  }

  @override
  String get panelAperturas => 'Aperturas de tu ficha';

  @override
  String panelAntes(int n) {
    return '$n en los 30 días anteriores';
  }

  @override
  String get panelContactos => 'Contactos';

  @override
  String get panelFavoritos => 'Te guardaron en favoritos';

  @override
  String get panelVisitas => 'Dijeron «Fui»';

  @override
  String get panelSocios => 'Te eligieron como su veterinaria';

  @override
  String get panelUltimos30 => 'Últimos 30 días';

  @override
  String get panelSinContactos => 'Todavía nadie tocó un contacto.';

  @override
  String get clicLlamar => 'Llamar';

  @override
  String get clicWhatsapp => 'WhatsApp';

  @override
  String get clicComoLlegar => 'Cómo llegar';

  @override
  String get clicWeb => 'Web';

  @override
  String get clicInstagram => 'Instagram';

  @override
  String get negocioGuardar => 'Guardar cambios';

  @override
  String get negocioGuardado => 'Cambios guardados.';

  @override
  String get negocioVisible => 'Visible en el mapa';

  @override
  String get negocioPromo => 'Promoción';

  @override
  String get negocioPromoSoloPago =>
      'La promoción se muestra con los planes Destacado y Plus.';

  @override
  String get negocioFotos => 'Fotos';

  @override
  String get negocioAgregarFoto => 'Agregar foto';

  @override
  String get negocioFotosTope => 'Llegaste al máximo de fotos de tu plan.';

  @override
  String get negocioQuitarFoto => 'Quitar foto';

  @override
  String get negocioPedirVerificacion => 'Pedir la insignia ✔️';

  @override
  String get negocioPedirVerificacionTexto =>
      'Ingresá el RUT del negocio. El equipo lo valida y te avisa.';

  @override
  String get negocioVerificacionPedida =>
      'Pedido enviado. Te avisamos cuando lo revisemos.';

  @override
  String get negocioPedirRenac => 'Pedir la insignia Operador RENAC';

  @override
  String get negocioRenacTexto =>
      'Si colocás microchip y estás en el listado oficial del MGAP, aparece la insignia y el filtro «Coloca microchip».';

  @override
  String get negocioRenacPedido => 'Insignia RENAC pedida.';

  @override
  String get negocioHorario => 'Horario';

  @override
  String get negocioCerrado => 'Cerrado';

  @override
  String get negocio24h => 'Abierto 24 h';

  @override
  String get negocioUrgencias => 'Atiende urgencias';

  @override
  String negocioDe(String desde, String hasta) {
    return 'De $desde a $hasta';
  }

  @override
  String get negocioEspecies => 'Especies que atendés';

  @override
  String get negocioEspeciesAyuda =>
      'Si no elegís ninguna, se entiende que atendés a todas.';

  @override
  String get negocioOtro => 'Sumar otro negocio';

  @override
  String get negocioDireccion => 'Dirección (opcional)';

  @override
  String get resenasTitulo => 'Reseñas';

  @override
  String get resenasVacio => 'Todavía no tiene reseñas.';

  @override
  String resenasPromedio(String promedio, int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n reseñas',
      one: '1 reseña',
    );
    return '$promedio ★ · $_temp0';
  }

  @override
  String get resenaEscribir => 'Escribir una reseña';

  @override
  String get resenaEditar => 'Editar mi reseña';

  @override
  String get resenaSoloConContacto =>
      'Podés dejar una reseña después de escribirle, llamar o ir.';

  @override
  String resenaEstrellas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n estrellas',
      one: '1 estrella',
    );
    return '$_temp0';
  }

  @override
  String get resenaComentario => 'Contá cómo te fue (opcional)';

  @override
  String get resenaPublicar => 'Publicar';

  @override
  String get resenaPublicada => '¡Gracias por tu reseña!';

  @override
  String get resenaRespuesta => 'Respuesta del comercio';

  @override
  String get resenaResponder => 'Responder';

  @override
  String get resenaRespuestaCampo =>
      'Tu respuesta (es pública y se puede dar una sola vez)';

  @override
  String get resenaRespondida => 'Respuesta publicada.';

  @override
  String get resenaReportar => 'Reportar reseña';

  @override
  String get resenaReportada => 'Gracias. La vamos a revisar.';

  @override
  String get resenaMia => 'Tu reseña';

  @override
  String resenaDe(String autor) {
    return '$autor';
  }

  @override
  String get fichaEscribirChat => 'Escribir por chat';

  @override
  String get panelResenas => 'Reseñas';

  @override
  String get panelPromedio => 'Promedio';

  @override
  String panelSinResponder(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n sin responder',
      one: '1 sin responder',
      zero: 'Todas respondidas',
    );
    return '$_temp0';
  }

  @override
  String get panelChats => 'Chats nuevos';

  @override
  String get adopcionTitulo => 'Adopción responsable';

  @override
  String get catalogoTitulo => 'Catálogo';

  @override
  String get catalogoVacio => 'Este comercio todavía no cargó productos.';

  @override
  String get catalogoPagoDirecto =>
      'El pago y la entrega los arreglás directo con el comercio.';

  @override
  String catalogoVerPedido(int cantidad, String total) {
    return 'Ver pedido · $cantidad · $total';
  }

  @override
  String catalogoConsultaTexto(String producto) {
    return 'Hola, te escribo desde Huellitas. Quería consultar por: $producto';
  }

  @override
  String get catalogoSinContacto => 'Este comercio no dejó cómo contactarlo.';

  @override
  String get catalogoConsultarPrecio => 'Consultar precio';

  @override
  String get catalogoConsultar => 'Consultar';

  @override
  String get catalogoAgregar => 'Agregar';

  @override
  String get catalogoQuitarUno => 'Quitar uno';

  @override
  String get catalogoSumarUno => 'Sumar uno';

  @override
  String catalogoVer(int cantidad) {
    return 'Ver catálogo ($cantidad)';
  }

  @override
  String get catalogoPrender => 'Catálogo y pedidos';

  @override
  String get catalogoPrendidoAyuda =>
      'Prendido: tus productos se ven en tu ficha y te pueden hacer pedidos.';

  @override
  String get catalogoApagadoAyuda =>
      'Apagado: podés cargar productos; nadie los ve hasta que lo prendas.';

  @override
  String get catalogoSinProductos =>
      'Todavía no cargaste productos. Tocá «Agregar producto».';

  @override
  String get pedidoTitulo => 'Tu pedido';

  @override
  String get pedidoTotal => 'Total';

  @override
  String get pedidoNota => 'Nota para el comercio (opcional)';

  @override
  String get pedidoNotaAyuda => 'Por ejemplo: paso a retirarlo a las 18';

  @override
  String get pedidoHacer => 'Hacer pedido';

  @override
  String get pedidoIngresar => 'Ingresá para hacer el pedido';

  @override
  String get pedidoHecho => '¡Listo! El comercio recibió tu pedido.';

  @override
  String get pedidoDemasiados => 'Hiciste muchos pedidos hoy. Probá mañana.';

  @override
  String get pedidoCambio =>
      'Algún producto cambió o ya no está. Revisá el catálogo y probá de nuevo.';

  @override
  String get pedidoSinModulo => 'Este comercio ya no está tomando pedidos.';

  @override
  String get pedidoNuevo => 'Nuevo';

  @override
  String get pedidoPreparando => 'Preparando';

  @override
  String get pedidoListo => 'Listo para retirar';

  @override
  String get pedidoEntregado => 'Entregado';

  @override
  String get pedidoCancelado => 'Cancelado';

  @override
  String get pedidoCancelar => 'Cancelar pedido';

  @override
  String pedidoNumero(int numero) {
    return 'Pedido #$numero';
  }

  @override
  String pedidoNotaDe(String nota) {
    return 'Nota: $nota';
  }

  @override
  String pedidoPasarA(String estado) {
    return 'Pasar a «$estado»';
  }

  @override
  String get misPedidos => 'Mis pedidos';

  @override
  String get misPedidosAyuda =>
      'Lo que pediste a los comercios y en qué estado está.';

  @override
  String get misPedidosVacio =>
      'Todavía no hiciste pedidos. Los comercios con catálogo tienen el botón «Ver catálogo» en su ficha.';

  @override
  String get pedidosNegocioVacio => 'Todavía no te hicieron pedidos.';

  @override
  String get pagoTitulo => 'Forma de pago';

  @override
  String get pagoEfectivo => 'Efectivo';

  @override
  String get pagoTransferencia => 'Transferencia';

  @override
  String get pagoTarjeta => 'Débito o crédito';

  @override
  String get pagoMercadoPago => 'Mercado Pago';

  @override
  String get entregaTitulo => 'Entrega';

  @override
  String get entregaRetiro => 'Retiro en el local';

  @override
  String get entregaEnvio => 'Envío a domicilio';

  @override
  String get pedidoSubtotal => 'Subtotal';

  @override
  String get pedidoEnvio => 'Envío';

  @override
  String get pedidoEnvioGratis => 'Gratis';

  @override
  String get pedidoDireccionAyuda =>
      'La dirección se la pasás directo al comercio: no la guardamos en la app.';

  @override
  String get pedidoElegiPagoYEntrega => 'Elegí la forma de pago y la entrega.';

  @override
  String get pedidoEnviarWhatsapp => 'Enviar pedido por WhatsApp';

  @override
  String get pedidoGuardadoWhatsapp =>
      'Ahora mandale el mensaje al comercio por WhatsApp para que lo vea enseguida. También le queda en la app.';

  @override
  String get pedidoAbrirWhatsapp => 'Abrir WhatsApp';

  @override
  String get pedidoAhoraNo => 'Ahora no';

  @override
  String get pedidoMensajeDireccion => 'Te paso la dirección por acá.';

  @override
  String get condicionesTitulo => 'Cómo cobrás y entregás';

  @override
  String get condicionesSinConfigurar =>
      'Sin configurar: quien pide arregla el pago y la entrega con vos.';

  @override
  String get condicionesPagos => 'Formas de pago que aceptás';

  @override
  String get condicionesRetiro => 'Retiro en el local';

  @override
  String get condicionesEnvio => 'Hacés envíos';

  @override
  String get condicionesCosto => 'Costo del envío';

  @override
  String get condicionesCostoAyuda => 'Vacío o 0: envío gratis.';

  @override
  String get condicionesGratisDesde => 'Envío gratis desde (opcional)';

  @override
  String get condicionesUnaEntrega => 'Elegí al menos retiro o envío.';

  @override
  String get condicionesMontosInvalidos => 'Revisá los montos.';

  @override
  String get condicionesEnvioGratis => 'Envío gratis';

  @override
  String pedidoEnvioGratisDesde(String monto) {
    return 'Envío gratis desde $monto';
  }

  @override
  String pedidoGuardadoTitulo(int numero) {
    return '¡Pedido #$numero guardado!';
  }

  @override
  String pedidoMensajeSaludo(int numero) {
    return 'Hola, te hago un pedido desde Huellitas (#$numero):';
  }

  @override
  String pedidoMensajeRenglon(int cantidad, String producto, String precio) {
    return '• $cantidad × $producto — $precio';
  }

  @override
  String pedidoMensajeTotales(String subtotal, String envio, String total) {
    return 'Subtotal: $subtotal · Envío: $envio · Total: $total';
  }

  @override
  String pedidoMensajeTotal(String total) {
    return 'Total: $total';
  }

  @override
  String pedidoMensajePago(String pago) {
    return 'Pago: $pago';
  }

  @override
  String pedidoMensajeEntrega(String entrega) {
    return 'Entrega: $entrega';
  }

  @override
  String condicionesEnvioCosto(String costo) {
    return 'Envío $costo';
  }

  @override
  String get productoNuevo => 'Agregar producto';

  @override
  String get productoEditar => 'Editar producto';

  @override
  String get productoNombre => 'Nombre';

  @override
  String get productoDescripcion => 'Descripción (opcional)';

  @override
  String get productoPrecio => 'Precio';

  @override
  String get productoPrecioAyuda =>
      'Vacío: se muestra «Consultar precio» y no se puede pedir.';

  @override
  String get productoDisponible => 'Disponible';

  @override
  String get productoNoDisponible => 'No disponible';

  @override
  String get productoFoto => 'Agregar foto';

  @override
  String get productoCambiarFoto => 'Cambiar foto';

  @override
  String get productoBorrar => 'Borrar';

  @override
  String get productoDatosInvalidos =>
      'Revisá el nombre (2 letras o más) y el precio.';

  @override
  String get productoLimite => 'Llegaste al máximo de 200 productos.';

  @override
  String get serviciosTitulo => 'Servicios';

  @override
  String get paginaCompartir => 'Compartir mi página';

  @override
  String get paginaCompartirAyuda =>
      'Tu página con fotos, servicios, productos y horario, para poner en Instagram, Facebook o WhatsApp.';

  @override
  String get paginaEnlaceCopiado =>
      'Enlace copiado: pegalo en tus redes o en WhatsApp.';

  @override
  String get paginaVer => 'Ver';

  @override
  String get serviciosAbrir => 'Tus servicios';

  @override
  String get serviciosAbrirAyuda =>
      'Baño, consulta, paseo… con precio o «Consultar precio».';

  @override
  String get serviciosAyuda =>
      'Lo que cargues acá se ve en tu ficha, con «Consultar». Si tu plan deja de ser Plus, se ocultan (no se borran).';

  @override
  String get serviciosSoloPlus => 'Los servicios se publican con el plan Plus.';

  @override
  String get serviciosSinCargar =>
      'Todavía no cargaste servicios. Tocá «Agregar servicio».';

  @override
  String get servicioNuevo => 'Agregar servicio';

  @override
  String get servicioEditar => 'Editar servicio';

  @override
  String get servicioNombreAyuda => 'Por ejemplo: Baño y corte';

  @override
  String get servicioPrecioAyuda => 'Vacío: se muestra «Consultar precio».';

  @override
  String get servicioPrecioDesde =>
      'Es un precio «desde» (cambia según el caso)';

  @override
  String get servicioDuracion => 'Duración';

  @override
  String get servicioSinDuracion => 'Sin indicar';

  @override
  String get servicioVisible => 'Se ve en mi ficha';

  @override
  String get servicioOculto => 'Oculto';

  @override
  String get servicioLimite => 'Llegaste al máximo de 50 servicios.';

  @override
  String servicioDesde(String precio) {
    return 'desde $precio';
  }

  @override
  String duracionMinutos(int minutos) {
    return '$minutos min';
  }

  @override
  String duracionHoras(int horas) {
    return '$horas h';
  }

  @override
  String duracionHorasMinutos(int horas, int minutos) {
    return '$horas h $minutos min';
  }

  @override
  String get noticiasTitulo => 'Inicio';

  @override
  String get noticiasEntradaAyuda =>
      'Novedades, campañas y consejos para tus mascotas.';

  @override
  String get noticiasTodas => 'Todas';

  @override
  String get noticiasVacio => 'Todavía no hay noticias para mostrarte.';

  @override
  String get noticiasLeerMas => 'Leer más';

  @override
  String noticiasPromocionado(String marca) {
    return 'Promocionado · $marca';
  }

  @override
  String get noticiasSeccionNoticias => 'Noticias';

  @override
  String get noticiasSeccionComunidad => 'Comunidad';

  @override
  String get comunidadExplicacion =>
      'Se arma sola con lo que pasa en la app. Nunca mostramos ubicaciones ni datos de personas.';

  @override
  String get comunidadVacio =>
      'Todavía no hay novedades. Cuando una mascota vuelva a casa o haya un evento cerca, lo vas a ver acá.';

  @override
  String get comunidadResumenTitulo => 'Últimos 30 días en la comunidad';

  @override
  String comunidadResumenReencuentros(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n mascotas volvieron a casa',
      one: '1 mascota volvió a casa',
    );
    return '$_temp0';
  }

  @override
  String comunidadResumenAdopciones(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n adopciones concretadas',
      one: '1 adopción concretada',
    );
    return '$_temp0';
  }

  @override
  String comunidadResumenPerdidas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n mascotas perdidas siguen buscando su casa',
      one: '1 mascota perdida sigue buscando su casa',
    );
    return '$_temp0';
  }

  @override
  String comunidadResumenLugares(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n lugares verificados en el mapa',
      one: '1 lugar verificado en el mapa',
    );
    return '$_temp0';
  }

  @override
  String comunidadVolvioACasa(String nombre) {
    return '¡$nombre volvió a casa! 🎉';
  }

  @override
  String get comunidadVolvioACasaSinNombre =>
      '¡Una mascota perdida volvió a casa! 🎉';

  @override
  String comunidadDiasPerdida(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: 'Estuvo $dias días perdida.',
      one: 'Estuvo 1 día perdida.',
      zero: 'La encontraron el mismo día.',
    );
    return '$_temp0';
  }

  @override
  String comunidadVolvioConSuFamilia(String nombre) {
    return '¡$nombre volvió con su familia! 🏡';
  }

  @override
  String get comunidadVolvioConSuFamiliaSinNombre =>
      'Una mascota encontrada volvió con su familia 🏡';

  @override
  String get comunidadGracias => 'Gracias a todos los que ayudaron a difundir.';

  @override
  String comunidadAdoptado(String nombre) {
    return '¡$nombre encontró un hogar! 💛';
  }

  @override
  String comunidadAdoptados(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n mascotas encontraron un hogar 💛',
      one: 'Una mascota encontró un hogar 💛',
    );
    return '$_temp0';
  }

  @override
  String get comunidadAdopcionDetalle => 'Adopción responsable en Huellitas.';

  @override
  String comunidadLugarNuevo(String nombre) {
    return 'Nuevo lugar verificado: $nombre';
  }

  @override
  String comunidadEvento(String nombre) {
    return 'Evento: $nombre';
  }

  @override
  String get comunidadCompartirTitulo => '¿Compartís la buena noticia?';

  @override
  String get comunidadCompartirExplicacion =>
      'Se publica en Inicio → Comunidad con el nombre, la especie y la primera foto del reporte. Nunca la ubicación ni tus datos. La podés quitar cuando quieras.';

  @override
  String get comunidadCompartir => 'Compartir';

  @override
  String get comunidadCompartida => '¡Listo! Ya está en Comunidad.';

  @override
  String get comunidadInterruptor => 'Compartido en Comunidad';

  @override
  String get comunidadInterruptorDetalle =>
      'Nombre, especie y foto; nunca la ubicación ni tus datos.';

  @override
  String get menuAbrir => 'Menú';

  @override
  String get menuIngresar => 'Ingresá o creá tu cuenta';

  @override
  String get menuIngresarAyuda => 'Para cargar tus mascotas y recibir avisos.';

  @override
  String get menuVerPara => 'Ver todo para';

  @override
  String get menuTodas => 'Todas';

  @override
  String get menuTodasAyuda =>
      'Noticias y adopción muestran lo de todas tus mascotas.';

  @override
  String menuElegidaAyuda(String nombre) {
    return 'Noticias y adopción se muestran para la especie de $nombre.';
  }

  @override
  String get menuFicha => 'Ver su ficha';

  @override
  String get menuGrupoMascotas => 'Mis mascotas';

  @override
  String get menuGrupoMapa => 'Mapa y lugares';

  @override
  String get menuGrupoComunidad => 'Comunidad';

  @override
  String get menuGrupoAdopcion => 'Adopción';

  @override
  String get menuGrupoTurnos => 'Turnos y pedidos';

  @override
  String get menuGrupoCuenta => 'Mi cuenta';

  @override
  String get recorridoBoton => 'Cómo funciona esta pantalla';

  @override
  String get recorridoSiguiente => 'Siguiente';

  @override
  String get recorridoAtras => 'Atrás';

  @override
  String get recorridoSaltar => 'Saltar';

  @override
  String get recorridoListo => 'Listo';

  @override
  String recorridoPaso(int actual, int total) {
    return 'Paso $actual de $total';
  }

  @override
  String get recInicioTitulo => '¡Te damos la bienvenida a Huellitas!';

  @override
  String get recInicioTexto => 'En pocos pasos te mostramos cómo se usa.';

  @override
  String get recMenuTitulo => 'El menú';

  @override
  String get recMenuTexto =>
      'Todas las secciones: tus mascotas, adopción, turnos, tu cuenta y más.';

  @override
  String get recAvisosTitulo => 'Mensajes y avisos';

  @override
  String get recAvisosTexto =>
      'Acá te llegan los mensajes y los avisos, por ejemplo si alguien escanea la chapita QR de tu mascota.';

  @override
  String get recCarruselTitulo => 'Destacados';

  @override
  String get recCarruselTexto =>
      'Novedades y promociones de la zona. Tocá una para ver más.';

  @override
  String get recSeccionesTitulo => 'Noticias y Comunidad';

  @override
  String get recSeccionesTexto =>
      'Noticias para cuidar a tu mascota, y lo que pasa cerca: eventos, perdidos y reencuentros.';

  @override
  String get recBarraTitulo => 'Lo principal, abajo';

  @override
  String get recBarraTexto =>
      'SOS para perdidos y encontrados, el Mapa en el medio, tus mascotas y Urgencias.';

  @override
  String get recAyudaTitulo => '¿Alguna duda?';

  @override
  String get recAyudaTexto =>
      'Tocá ? en cualquier pantalla para ver de nuevo cómo funciona.';

  @override
  String get recSosTitulo => 'Perdidos y encontrados';

  @override
  String get recSosTexto =>
      'Las mascotas perdidas y encontradas cerca tuyo, de la más cercana a la más lejana.';

  @override
  String get recSosFiltrosTitulo => 'Filtrá';

  @override
  String get recSosFiltrosTexto =>
      'Mirá solo las perdidas o solo las encontradas.';

  @override
  String get recSosReportarTitulo => 'Reportá';

  @override
  String get recSosReportarTexto =>
      'Si se perdió la tuya o encontraste una, publicalo acá. Tu teléfono y tu casa nunca se muestran: quien la vea te deja sus datos.';

  @override
  String get recMapaTitulo => 'El mapa';

  @override
  String get recMapaTexto =>
      'Veterinarias, tiendas, servicios y lugares que aceptan mascotas, cerca tuyo.';

  @override
  String get recMapaVistasTitulo => 'Mapa o lista';

  @override
  String get recMapaVistasTexto =>
      'Pasá a una lista, o mirá los servicios sin local que van a tu casa.';

  @override
  String get recMapaFiltrosTitulo => 'Qué ver';

  @override
  String get recMapaFiltrosTexto =>
      'Elegí los rubros: salud, tiendas, cuidado, salidas o refugios.';

  @override
  String get recMapaBuscarTitulo => 'Buscar';

  @override
  String get recMapaBuscarTexto =>
      'Encontrá un lugar por su nombre o por su rubro.';

  @override
  String get recMapaMarcarTitulo => '¿Falta un lugar?';

  @override
  String get recMapaMarcarTexto => 'Marcalo en el mapa y lo sumamos.';

  @override
  String get recMascotasTitulo => 'Tus mascotas';

  @override
  String get recMascotasTexto =>
      'Su ficha, la libreta de salud, los recordatorios y la chapita QR, todo junto.';

  @override
  String get recMascotasListaTitulo => 'Su ficha';

  @override
  String get recMascotasListaTexto =>
      'Tocá una mascota para ver su ficha, sus vacunas y su chapita QR.';

  @override
  String get recMascotasAgregarTitulo => 'Agregá una mascota';

  @override
  String get recMascotasAgregarTexto => 'Con una foto y sus datos. Es gratis.';

  @override
  String get recUrgenciasTitulo => 'Urgencias';

  @override
  String get recUrgenciasTexto => 'Para cuando hace falta ayuda ya.';

  @override
  String get recUrgencias911Titulo => 'Si hay una persona en riesgo';

  @override
  String get recUrgencias911Texto =>
      'Llamá al 911. Huellitas es solo para animales.';

  @override
  String get recUrgenciasGuardiaTitulo => 'Veterinarias de urgencia';

  @override
  String get recUrgenciasGuardiaTexto =>
      'Las que atienden urgencias cerca tuyo. Más abajo, refugios y organismos.';

  @override
  String get recNegocioTitulo => 'Tu negocio en Huellitas';

  @override
  String get recNegocioTexto =>
      'Desde acá manejás tu ficha, tu agenda, tu catálogo y tus pedidos.';

  @override
  String get recNegocioSeccionesTitulo => 'Las secciones';

  @override
  String get recNegocioSeccionesTexto =>
      'Panel con tus números, Agenda de turnos, Catálogo, Pedidos y la Ficha del negocio.';

  @override
  String get recNegocioVolverTitulo => 'Volver a Huellitas';

  @override
  String get recNegocioVolverTexto =>
      'Para usar la app como dueño o dueña de mascotas.';

  @override
  String get explicacionVerMas => 'Ver más';

  @override
  String get explicacionVerMenos => 'Ver menos';

  @override
  String get atajoLibreta => 'Agregar a la libreta';

  @override
  String get atajoRecordatorio => 'Nuevo recordatorio';

  @override
  String get vidaVida => 'Historial de vida';

  @override
  String get vidaVacio =>
      'Operaciones, accidentes, enfermedades y tratamientos, con fecha y sus estudios.';

  @override
  String get vidaAgregar => 'Agregar al historial';

  @override
  String vidaAdjuntoN(int n) {
    return 'Adjunto $n';
  }

  @override
  String get vidaTipoOperacion => 'Operación';

  @override
  String get vidaTipoAccidente => 'Accidente';

  @override
  String get vidaTipoEnfermedad => 'Enfermedad';

  @override
  String get vidaTipoTratamiento => 'Tratamiento';

  @override
  String get vidaTipoDiagnostico => 'Diagnóstico';

  @override
  String get vidaTipoOtro => 'Otro';

  @override
  String get vidaNuevo => 'Nuevo en el historial';

  @override
  String get vidaEditar => 'Editar del historial';

  @override
  String get vidaTipo => '¿Qué pasó?';

  @override
  String get vidaTitulo => 'Título';

  @override
  String get vidaTituloAyuda =>
      'Por ejemplo: castración, fractura de pata, otitis.';

  @override
  String get vidaTituloFalta => 'Escribí un título.';

  @override
  String get vidaFecha => 'Fecha';

  @override
  String get vidaNotasAyuda =>
      'Lo que quieras recordar: qué dijo la veterinaria, cómo siguió.';

  @override
  String vidaAdjuntos(int n) {
    return 'Fotos y documentos ($n de 4)';
  }

  @override
  String vidaAdjuntoNuevo(int n) {
    return 'Adjunto $n (sin guardar)';
  }

  @override
  String get vidaAgregarFoto => 'Foto';

  @override
  String get vidaAgregarPdf => 'PDF';

  @override
  String get vidaAdjuntosTope => 'Llegaste a 4: quitá uno para sumar otro.';

  @override
  String get vidaAdjuntoInvalido => 'Ese archivo no se puede usar.';

  @override
  String get vidaAdjuntoGrande => 'El PDF pesa más de 5 MB.';

  @override
  String get vidaBorrar => 'Borrar del historial';

  @override
  String vidaBorrarTitulo(String titulo) {
    return '¿Borrar «$titulo»?';
  }

  @override
  String get vidaBorrarExplicacion =>
      'Se borran también sus fotos y documentos.';

  @override
  String get vidaQuitarAdjunto => 'Quitar';

  @override
  String get vidaPdfTitulo => 'Historial de vida';

  @override
  String vidaPdfAdjuntos(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n adjuntos en la app',
      one: '1 adjunto en la app',
    );
    return '$_temp0';
  }

  @override
  String get atajoHistorial => 'Agregar al historial';

  @override
  String get pasarTitulo => 'Pasar a otra persona';

  @override
  String get pasarSubtitulo => 'Con su libreta, su historial y su chapita QR.';

  @override
  String pasarHojaTitulo(String nombre) {
    return 'Pasar a $nombre';
  }

  @override
  String get pasarExplicacion =>
      'Generá un código y mandáselo a la persona que la va a cuidar. Cuando lo acepte, la mascota pasa a su cuenta con todo su historial y deja de estar en la tuya. El código vence en 7 días y sirve una sola vez.';

  @override
  String get pasarGenerar => 'Generar código';

  @override
  String pasarVence(String fecha) {
    return 'Vence el $fecha';
  }

  @override
  String get pasarCopiar => 'Copiar para mandar';

  @override
  String get pasarCopiado => 'Copiado. Pegalo en un mensaje.';

  @override
  String pasarMensaje(String nombre, String codigo) {
    return 'Te paso a $nombre en Huellitas. En Mis mascotas tocá «Tengo un código» y escribí: $codigo';
  }

  @override
  String get pasarCancelar => 'Cancelar el código';

  @override
  String get pasarSosAbierto =>
      'Tiene un SOS abierto: cerralo antes de pasarla.';

  @override
  String get pasarCodigoInvalido =>
      'El código no es válido, venció o ya se usó.';

  @override
  String get pasarTengoCodigo => 'Tengo un código';

  @override
  String get pasarRecibirTitulo => 'Recibir una mascota';

  @override
  String get pasarRecibirExplicacion => 'Escribí el código que te pasaron.';

  @override
  String get pasarCodigo => 'Código';

  @override
  String get pasarBuscar => 'Buscar';

  @override
  String get pasarRecibirConfirmar => 'Pasa a tu cuenta con todo su historial.';

  @override
  String get pasarAceptar => 'Aceptar';

  @override
  String get pasarRecibida => '¡Listo! Ya está en tus mascotas.';

  @override
  String get compartirHistorialTitulo => 'Compartir historial';

  @override
  String get compartirHistorialSubtitulo =>
      'Con su veterinaria o quien la cuide, solo para leer.';

  @override
  String compartirHistorialHoja(String nombre) {
    return 'Compartir el historial de $nombre';
  }

  @override
  String get compartirHistorialExplicacion =>
      'Se crea un enlace que muestra sus datos, la libreta y el historial de vida, sin tu teléfono ni tu dirección. Quien lo abre no puede cambiar nada. Lo podés cortar cuando quieras.';

  @override
  String get compartirHistorialDuracion => '¿Por cuánto tiempo?';

  @override
  String compartirHistorialDias(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: '$dias días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get compartirHistorialCrear => 'Crear y copiar el enlace';

  @override
  String get compartirHistorialCopiado =>
      'Enlace copiado. Pegalo en un mensaje.';

  @override
  String get compartirHistorialVigentes =>
      'Enlaces vigentes (tocá uno para copiarlo)';

  @override
  String compartirHistorialVence(String fecha) {
    return 'Vence el $fecha';
  }

  @override
  String compartirHistorialVistas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Se abrió $n veces',
      one: 'Se abrió 1 vez',
      zero: 'Nadie lo abrió todavía',
    );
    return '$_temp0';
  }

  @override
  String get compartirHistorialCortar => 'Cortar';

  @override
  String get temaViajes => 'Viajes';

  @override
  String get temaSalud => 'Salud';

  @override
  String get temaAlimentacion => 'Alimentación';

  @override
  String get temaAdopcion => 'Adopción';

  @override
  String get temaTramites => 'Trámites';

  @override
  String get temaOtros => 'Otros';

  @override
  String get preguntasTitulo => 'Preguntas';

  @override
  String get preguntasTarjeta => '¿Tenés una duda?';

  @override
  String get preguntasTarjetaAyuda =>
      'Preguntale a la comunidad o buscá si ya la respondieron.';

  @override
  String get preguntasPreguntar => 'Preguntar';

  @override
  String get preguntasMotivoCuenta =>
      'Para preguntar o responder necesitás una cuenta.';

  @override
  String get preguntasBuscar => 'Buscar en las preguntas…';

  @override
  String get preguntasTodas => 'Todas';

  @override
  String get preguntasVacio =>
      'Todavía no hay preguntas de este tema. ¡Hacé la primera!';

  @override
  String get preguntasSinResultados =>
      'No encontramos preguntas con eso. Probá con otras palabras o hacé la tuya.';

  @override
  String preguntasRespuestas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n respuestas',
      one: '1 respuesta',
      zero: 'Sin respuestas',
    );
    return '$_temp0';
  }

  @override
  String get preguntasResuelta => 'Resuelta';

  @override
  String get preguntasNueva => 'Nueva pregunta';

  @override
  String get preguntasTema => '¿De qué es?';

  @override
  String get preguntasTexto => 'Tu pregunta';

  @override
  String get preguntasTextoAyuda =>
      'Contá lo necesario. No pongas tu teléfono ni tu dirección.';

  @override
  String get preguntasDonde => '¿Dónde la publicás?';

  @override
  String get preguntasGenerales => 'Preguntas generales';

  @override
  String get preguntasFaltan => 'Elegí un tema y escribí tu pregunta.';

  @override
  String get preguntasPublicar => 'Publicar pregunta';

  @override
  String get preguntasMeSirvio => 'Me sirvió';

  @override
  String get preguntasDesmarcar => 'Quitar';

  @override
  String get preguntasLeSirvio => 'Le sirvió a quien preguntó';

  @override
  String get preguntasUnirmeResponder => 'Unirme al grupo para responder';

  @override
  String profesionalRespuesta(String veterinaria) {
    return 'Respuesta de profesional · $veterinaria';
  }

  @override
  String get profesionalFirmar => 'Firmar como profesional';

  @override
  String get profesionalQuitar => 'Quitar firma';

  @override
  String get profesionalElegir => '¿Con qué veterinaria firmás?';

  @override
  String get preguntasConProfesional => 'Responde una veterinaria';

  @override
  String promoEtiqueta(String negocio) {
    return 'Promocionado · $negocio';
  }

  @override
  String get promoReportarTitulo => 'Reportar esta promoción';

  @override
  String get promoReportarCuenta => 'Para reportar necesitás una cuenta.';

  @override
  String get promoMotivoEngano => 'Es engañosa';

  @override
  String get promoMotivoAnimales => 'Vende o cruza animales';

  @override
  String get promoMotivoOtro => 'Otro motivo';

  @override
  String get promoReportada => 'Gracias, la vamos a revisar.';

  @override
  String get promoPanelTitulo => 'Promoción en el muro';

  @override
  String get promoSoloPlanes =>
      'Con Destacado o Plus, tu promoción sale en el Inicio de quienes están cerca, marcada «Promocionado».';

  @override
  String promoPanelAyuda(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other:
          'Sale en el Inicio de quienes están cerca. Tenés hasta $n vigentes.',
      one: 'Sale en el Inicio de quienes están cerca. Tenés 1 vigente.',
    );
    return '$_temp0';
  }

  @override
  String promoHasta(String fecha) {
    return 'Hasta el $fecha';
  }

  @override
  String get promoTerminar => 'Terminar';

  @override
  String get promoNueva => 'Nueva promoción';

  @override
  String get promoEditar => 'Editar promoción';

  @override
  String get promoTitulo => 'Título (por ejemplo: 10% en alimento)';

  @override
  String get promoTexto => 'Detalle';

  @override
  String get promoDuracion => '¿Cuánto dura?';

  @override
  String promoDias(int dias) {
    return '$dias días';
  }

  @override
  String get promoFoto => 'Foto de tu ficha';

  @override
  String get promoSinFoto => 'Sin foto';

  @override
  String promoFotoN(int n) {
    return 'Foto $n';
  }

  @override
  String get promoFaltan => 'Completá el título y el detalle.';

  @override
  String get promoTope =>
      'Ya tenés las promociones que permite tu plan. Terminá una para publicar otra.';

  @override
  String get promoPublicar => 'Publicar';

  @override
  String get huellasTitulo => 'Tus huellas';

  @override
  String get huellasSinAyudas =>
      'Todavía no ayudaste a nadie en la app. ¡Ya va a llegar!';

  @override
  String huellasAyudas(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Ayudaste $n veces: avisos, respuestas y difusión.',
      one: 'Ayudaste 1 vez: avisos, respuestas y difusión.',
    );
    return '$_temp0';
  }

  @override
  String get huellasPrivadas => 'Solo vos ves tus huellas. No hay rankings.';

  @override
  String get huellaGanada => '¡Ganada!';

  @override
  String get huellaPerfil => 'Perfil completo';

  @override
  String get huellaPerfilComo =>
      'Poné tu nombre, tu zona y una mascota con foto.';

  @override
  String get huellaLibreta => 'Libreta al día';

  @override
  String get huellaLibretaComo =>
      'Cargá las vacunas y que ninguna esté vencida.';

  @override
  String get huellaChapita => 'Chapita activa';

  @override
  String get huellaChapitaComo => 'Vinculá una chapita QR a tu mascota.';

  @override
  String get huellaDifusor => 'Difusor';

  @override
  String get huellaDifusorComo => 'Compartí el aviso de una mascota perdida.';

  @override
  String get huellaRespuesta => 'Buena respuesta';

  @override
  String get huellaRespuestaComo =>
      'Respondé una pregunta y que a alguien le sirva.';

  @override
  String get huellaReencuentro => 'Reencuentro';

  @override
  String get huellaReencuentroComo =>
      'Avisale a una familia y ayudá a que su mascota vuelva.';

  @override
  String get estadisticasPromoVistas => 'Vistas de tu promoción';

  @override
  String get estadisticasPromoToques => 'Toques en tu promoción';

  @override
  String atajosMas(String nombre) {
    return 'Más opciones de $nombre';
  }

  @override
  String get hogarExplicacionCorta =>
      'Compartí tus mascotas con tu familia: hasta 5 personas.';

  @override
  String get unirmeTextoCorta => 'Te invitaron a cuidar mascotas en Huellitas.';

  @override
  String get transitoIntroCorta =>
      'Cuidá un animal de un refugio hasta que encuentre familia.';

  @override
  String get equipoAyudaDuenioCorta =>
      'Tu equipo atiende pedidos, turnos y el catálogo. Lo demás es tuyo.';

  @override
  String get equipoAyudaEmpleadoCorta =>
      'Atendés los pedidos, los turnos y el catálogo de este negocio.';

  @override
  String get unirmeEquipoTextoCorta =>
      'Te invitaron al equipo de un negocio en Huellitas.';

  @override
  String get planillaAyudaCorta =>
      'Pegá las filas de tu planilla: nombre, descripción, precio, disponible.';

  @override
  String get qrConsejoChapitaCorta =>
      'Imprimilo en papel adhesivo y protegelo con cinta.';

  @override
  String chapitasExplicacionCorta(String nombre) {
    return '¿Tenés una chapita de Huellitas? Vinculala con $nombre.';
  }

  @override
  String get marcarExplicacionCorta => 'Elegí el rubro y tocá dónde queda.';

  @override
  String get temaExplicacionCorta =>
      'Cambia los colores solo en este dispositivo.';

  @override
  String get publicarExplicacionCorta => 'Es gratis y nunca es una venta.';

  @override
  String get calcExplicacionCorta =>
      'Poné cuánto pensás gastar y la app te da el total.';

  @override
  String get apadrinarAyudaCorta =>
      'Elegí un refugio de tu zona y contá qué aportás.';

  @override
  String get apadrinarRefugioAyudaCorta =>
      'Si aceptás, tu ficha muestra «Apadrinado por».';

  @override
  String get descuentosNegocioAyudaCorta =>
      'Quien tiene Pro te muestra su código. Es gratis para vos.';

  @override
  String get serviciosAyudaCorta => 'Se ven en tu ficha, con «Consultar».';

  @override
  String get pedidoChapitaExplicacionCorta =>
      'La retirás en una veterinaria y queda vinculada sola.';

  @override
  String get cuidadorExplicacionCorta =>
      'Ve solo las mascotas que elijas, los días que digas.';

  @override
  String get vetBuscasAyudaCorta =>
      'Las veterinarias cercanas te mandan propuestas, sin saber quién sos.';

  @override
  String get packNegocioAyudaCorta =>
      'Quien adoptó por la app te trae su código.';

  @override
  String get demandaAyudaCorta =>
      'Dueños cerca que buscan veterinaria, sin saber quiénes son.';

  @override
  String get negocioRenacTextoCorta =>
      'Si colocás microchip y estás en el listado del MGAP, sale la insignia.';

  @override
  String get menuReportarPerdida => 'Reportar que se perdió';

  @override
  String comunidadReaccionesTuyo(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'A $n personas les alegró la noticia ❤️',
      one: 'A 1 persona le alegró la noticia ❤️',
    );
    return '$_temp0';
  }

  @override
  String comunidadSeBusca(String nombre) {
    return 'Se busca a $nombre';
  }

  @override
  String get comunidadSeBuscaSinNombre => 'Se busca una mascota perdida';

  @override
  String comunidadPerdidaDias(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: 'Lleva $dias días perdida.',
      one: 'Lleva 1 día perdida.',
      zero: 'Se perdió hoy.',
    );
    return '$_temp0';
  }

  @override
  String get comunidadPerdidaAyuda =>
      'Entrá al reporte para avisar si la viste o seguirlo.';

  @override
  String get comunidadVerReporte => 'Ver el reporte';

  @override
  String get reaccionAlegra => 'Me alegra';

  @override
  String get reaccionFestejo => '¡Qué bueno!';

  @override
  String get reaccionGracias => 'Gracias';

  @override
  String get reaccionesMotivoCuenta =>
      'Para reaccionar a las noticias necesitás una cuenta.';

  @override
  String get reaccionesTitulo => '¿Qué te pareció?';

  @override
  String get adopcionEntrada => 'Adoptar o dar en adopción';

  @override
  String get adopcionEntradaAyuda =>
      'Siempre gratis. Con guía, compatibilidad y seguimiento.';

  @override
  String get adopcionAdoptar => 'Adoptar';

  @override
  String get adopcionMias => 'Mis solicitudes';

  @override
  String get adopcionPublicar => 'Dar en adopción';

  @override
  String get adopcionGuia => '¿Estoy listo para adoptar?';

  @override
  String get adopcionCalculadora => 'Calculadora de costos';

  @override
  String get adopcionMiPerfil => 'Mi perfil de adoptante';

  @override
  String get adopcionVacio => 'No hay animales en adopción con este filtro.';

  @override
  String get adopcionTodas => 'Todas';

  @override
  String adopcionEdad(int meses) {
    String _temp0 = intl.Intl.pluralLogic(
      meses,
      locale: localeName,
      other: '$meses meses',
      one: '1 mes',
      zero: 'Menos de 1 mes',
    );
    return '$_temp0';
  }

  @override
  String adopcionEdadAnios(int anios) {
    String _temp0 = intl.Intl.pluralLogic(
      anios,
      locale: localeName,
      other: '$anios años',
      one: '1 año',
    );
    return '$_temp0';
  }

  @override
  String get adopcionChico => 'Chico';

  @override
  String get adopcionMediano => 'Mediano';

  @override
  String get adopcionGrande => 'Grande';

  @override
  String get adopcionEnergiaBaja => 'Tranquilo';

  @override
  String get adopcionEnergiaMedia => 'Energía media';

  @override
  String get adopcionEnergiaAlta => 'Mucha energía';

  @override
  String get adopcionCastrado => 'Castrado';

  @override
  String get adopcionVacunado => 'Vacunado';

  @override
  String get adopcionConChip => 'Con microchip';

  @override
  String get adopcionConNinos => 'Se lleva bien con niños';

  @override
  String get adopcionConPerros => 'Se lleva bien con perros';

  @override
  String get adopcionConGatos => 'Se lleva bien con gatos';

  @override
  String get adopcionNecesitaPatio => 'Necesita patio';

  @override
  String get adopcionNecesidades => 'Necesidades especiales';

  @override
  String get adopcionRequisitos => 'Requisitos';

  @override
  String adopcionAporte(String monto, String cubre) {
    return 'Aporte: \$$monto — cubre $cubre';
  }

  @override
  String get adopcionAporteAyuda =>
      'Es un aporte transparente del refugio, no una venta. Los particulares no pueden pedir dinero.';

  @override
  String adopcionRefugio(String nombre) {
    return 'Refugio verificado: $nombre';
  }

  @override
  String get adopcionParticular => 'Lo da en adopción un particular';

  @override
  String get adopcionCamada => 'Parte de una camada';

  @override
  String get adopcionMeInteresa => 'Me interesa';

  @override
  String get adopcionMensaje => 'Contale algo de vos (opcional)';

  @override
  String get adopcionEnviado =>
      '¡Listo! Quien lo publicó va a ver tu solicitud.';

  @override
  String get adopcionLimite =>
      'Ya tenés 3 solicitudes activas. Retirá alguna para pedir otra.';

  @override
  String get adopcionNoDisponible => 'Ya no está disponible.';

  @override
  String get adopcionPerfilPrimero =>
      'Completalo una vez: se usa para orientarte sobre la compatibilidad con cada animal y lo ve quien publica cuando le escribís.';

  @override
  String get compatBuena => 'Buena compatibilidad con tu perfil.';

  @override
  String get compatPatio => 'Ojo: necesita patio y vos indicaste que no tenés.';

  @override
  String get compatNinos => 'Ojo: no se lleva bien con niños y en tu casa hay.';

  @override
  String get compatAnimales =>
      'Ojo: no se lleva bien con otros animales y vos tenés.';

  @override
  String get compatSolo =>
      'Ojo: tiene mucha energía y estaría muchas horas solo.';

  @override
  String get compatCasa =>
      'Ojo: indicaste que no todos en tu casa están de acuerdo.';

  @override
  String get compatExperiencia =>
      'Ojo: tiene necesidades especiales y no tenés experiencia.';

  @override
  String get compatNota =>
      'Es una orientación: la decisión es de quien adopta y de quien lo da.';

  @override
  String get perfilVivienda => 'Vivienda';

  @override
  String get perfilCasa => 'Casa';

  @override
  String get perfilApartamento => 'Apartamento';

  @override
  String get perfilOtra => 'Otra';

  @override
  String get perfilPatio => 'Tengo patio';

  @override
  String get perfilHorasSolo => 'Horas que estaría solo por día';

  @override
  String perfilHoras(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n horas',
      one: '1 hora',
    );
    return '$_temp0';
  }

  @override
  String get perfilExperiencia => 'Experiencia con mascotas';

  @override
  String get perfilExpNinguna => 'Ninguna';

  @override
  String get perfilExpAlguna => 'Alguna';

  @override
  String get perfilExpMucha => 'Mucha';

  @override
  String get perfilOtrosAnimales => 'Tengo otros animales';

  @override
  String get perfilNinos => 'Hay niños en casa';

  @override
  String get perfilCasaDeAcuerdo => 'Todos en casa están de acuerdo';

  @override
  String get perfilGuardar => 'Guardar perfil';

  @override
  String get perfilGuardado => 'Perfil guardado.';

  @override
  String get etapaInterest => 'Me interesa';

  @override
  String get etapaQuestionnaire => 'Cuestionario';

  @override
  String get etapaInterview => 'Chat / entrevista';

  @override
  String get etapaVisit => 'Visita';

  @override
  String get etapaAgreement => 'Compromiso';

  @override
  String get etapaAdopted => 'Adoptado';

  @override
  String get etapaRejected => 'No avanzó';

  @override
  String get etapaWithdrawn => 'Retirada';

  @override
  String adopcionAvanzarA(String etapa) {
    return 'Pasar a «$etapa»';
  }

  @override
  String get adopcionRechazar => 'No avanzar';

  @override
  String get adopcionRetirar => 'Retirar mi solicitud';

  @override
  String get adopcionNotaPrivada => 'Nota privada (solo la ves vos)';

  @override
  String get adopcionNotaGuardada => 'Nota guardada.';

  @override
  String get adopcionSinSolicitudes => 'Todavía no pediste adoptar.';

  @override
  String get adopcionSinRecibidas => 'Todavía no recibiste solicitudes.';

  @override
  String get adopcionRecibidas => 'Solicitudes recibidas';

  @override
  String adopcionDe(String nombre) {
    return 'De $nombre';
  }

  @override
  String get adopcionVerCompromiso => 'Ver y aceptar el compromiso';

  @override
  String get adopcionCompromisoTitulo => 'Compromiso de adopción';

  @override
  String get adopcionAcepto => 'Leí y acepto el compromiso';

  @override
  String get adopcionAceptar => 'Adoptar';

  @override
  String get adopcionBienvenida =>
      '¡Bienvenida a casa! Ya está en «Mis mascotas» con sus recordatorios.';

  @override
  String adopcionSeguimiento(String nombre) {
    return 'Seguimiento: ¿cómo va $nombre?';
  }

  @override
  String adopcionSeguimientoDia(int dia) {
    return 'A los $dia días';
  }

  @override
  String get adopcionSeguimientoTexto =>
      'Contale a quien te lo dio en adopción cómo va (y si querés, mandá una foto).';

  @override
  String get adopcionSeguimientoEnviar => 'Enviar';

  @override
  String get adopcionSeguimientoListo => '¡Gracias por contar cómo va!';

  @override
  String get adopcionSeguimientoRespuestas => 'Seguimiento';

  @override
  String get adopcionSeguimientoSin => 'Sin respuesta todavía';

  @override
  String get publicarTitulo => 'Dar en adopción';

  @override
  String get publicarExplicacion =>
      'Es gratis y nunca es una venta. Como particular podés tener hasta 2 publicaciones activas; una camada cuenta como una.';

  @override
  String publicarAnimal(int n) {
    return 'Animal $n';
  }

  @override
  String get publicarAgregarAnimal => 'Sumar otro de la camada';

  @override
  String get publicarNombre => 'Nombre (opcional)';

  @override
  String get publicarEdadMeses => 'Edad aproximada en meses';

  @override
  String get publicarTamano => 'Tamaño';

  @override
  String get publicarEnergia => 'Energía';

  @override
  String get publicarFoto => 'Agregar foto';

  @override
  String get publicarFaltaFoto => 'Cada animal necesita al menos una foto.';

  @override
  String get publicarDescripcion => 'Descripción';

  @override
  String get publicarRequisitos => 'Requisitos (opcional)';

  @override
  String get publicarComoRefugio => 'Publicar como refugio verificado';

  @override
  String get publicarAporteMonto => 'Aporte (pesos, opcional)';

  @override
  String get publicarAporteCubre => 'Qué cubre el aporte';

  @override
  String get publicarEnviar => 'Publicar';

  @override
  String get publicarListo =>
      '¡Publicado! Te avisamos cuando alguien se interese.';

  @override
  String get publicarLimite =>
      'Ya tenés 2 publicaciones activas. Marcá alguna como adoptada o pausala.';

  @override
  String get publicarRevision =>
      'Publicaste dos camadas en un año: la publicación queda en revisión. Castrar evita camadas no deseadas.';

  @override
  String get publicarDatos => 'Revisá los datos.';

  @override
  String get guiaTitulo => '¿Estoy listo para adoptar?';

  @override
  String get guiaTexto =>
      'Adoptar es un compromiso de muchos años. Antes de decidir, pensá en:\n\n• **Tiempo:** paseos, juego y compañía todos los días.\n• **Espacio:** que tenga lugar para moverse y descansar.\n• **Acuerdo de toda la casa:** que todos quieran y se comprometan.\n• **Vacaciones y mudanzas:** quién lo cuida y si podés llevarlo.\n• **Costos:** comida, vacunas, antiparasitarios, castración y veterinaria (probá la calculadora).\n• **Paciencia:** al principio puede tener miedo o romper cosas.\n\nSi todo esto te cierra, ¡adelante! Y si dudás, también podés ayudar como hogar de tránsito o apadrinando en un refugio.';

  @override
  String get calcExplicacion =>
      'Poné cuánto pensás gastar en cada cosa (los precios cambian según la zona y el tamaño). La app suma y te da el total.';

  @override
  String get calcComida => 'Comida (por mes)';

  @override
  String get calcArena => 'Arena o piedritas (por mes)';

  @override
  String get calcAntiparasitarios => 'Antiparasitarios (por mes)';

  @override
  String get calcVacunas => 'Vacunas (por año)';

  @override
  String get calcCastracion => 'Castración (una vez, la dividimos en 12 meses)';

  @override
  String get calcVeterinaria => 'Consultas veterinarias (por año)';

  @override
  String get calcImprevistos => 'Imprevistos (por mes)';

  @override
  String calcTotal(String mes, String anio) {
    return 'Total: \$$mes por mes · \$$anio por año';
  }

  @override
  String get eventoCastracion => 'Jornada de castración';

  @override
  String get eventoAdopcion => 'Feria de adopción';

  @override
  String get eventoEncuentro => 'Encuentro';

  @override
  String get eventoOtro => 'Evento';

  @override
  String get eventosProximos => 'Próximos eventos';

  @override
  String get eventosVacio => 'No hay eventos próximos en la zona.';

  @override
  String eventoCuando(String desde, String hasta) {
    return '$desde a $hasta';
  }

  @override
  String eventoOrganiza(String nombre) {
    return 'Organiza: $nombre';
  }

  @override
  String get eventoEnCurso => '¡Está pasando ahora!';

  @override
  String get eventoMasInfo => 'Más información';

  @override
  String get eventoCancelar => 'Cancelar el evento';

  @override
  String get eventoCancelado => 'Evento cancelado.';

  @override
  String get eventoPublicar => 'Publicar un evento';

  @override
  String get eventoTitulo => 'Título';

  @override
  String get eventoDescripcion => 'Descripción (opcional)';

  @override
  String get eventoTipo => 'Tipo';

  @override
  String get eventoDesde => 'Empieza';

  @override
  String get eventoHasta => 'Termina';

  @override
  String get eventoLugar => 'Tocá el mapa donde es (o queda en tu local).';

  @override
  String get eventoDireccion => 'Dirección (opcional)';

  @override
  String get eventoEnlace => 'Enlace con más información (https://…, opcional)';

  @override
  String get eventoPublicado => '¡Evento publicado! Ya aparece en el mapa.';

  @override
  String get eventoSoloVerificados =>
      'Los eventos los publican comercios y refugios verificados ✔️.';

  @override
  String get eventoDatos =>
      'Revisá los datos: el evento dura como máximo 14 días y el título lleva 3 letras o más.';

  @override
  String get leyendaEvento => 'Eventos';

  @override
  String get denunciaTitulo => 'Denunciar maltrato';

  @override
  String get denunciaEntradaAyuda =>
      'Contanos qué pasa; la revisa el equipo y te orienta.';

  @override
  String get denunciaInfo =>
      'Esta denuncia **no reemplaza la denuncia oficial**. Podés hacerla ante el **INBA** (Instituto Nacional de Bienestar Animal) o en la seccional policial. Si hay una persona en riesgo, llamá al **911**.';

  @override
  String get denunciaDescripcion => 'Qué pasa (cuanto más detalle, mejor)';

  @override
  String get denunciaDescripcionCorta => 'Contá un poco más (10 letras o más).';

  @override
  String get denunciaUbicacion =>
      'Ubicación (opcional, solo la ve el equipo): tocá el mapa.';

  @override
  String get denunciaDireccion => 'Dirección o referencia (opcional)';

  @override
  String get denunciaFoto => 'Agregar foto';

  @override
  String get denunciaEnviar => 'Enviar denuncia';

  @override
  String get denunciaEnviada => 'Recibimos tu denuncia. La vamos a revisar.';

  @override
  String get denunciaMias => 'Mis denuncias';

  @override
  String get denunciaNueva => 'Recibida';

  @override
  String get denunciaDerivada => 'Derivada';

  @override
  String get denunciaCerrada => 'Cerrada';

  @override
  String get denunciaDemasiadas =>
      'Hiciste muchas denuncias hoy. Probá mañana.';

  @override
  String get vetTitulo => 'Su veterinaria';

  @override
  String vetCompartirCon(String negocio) {
    return 'Compartir con $negocio';
  }

  @override
  String get vetCompartirAyuda =>
      'Ve el nombre, la especie, tu primer nombre y el próximo control de la libreta; nunca tu teléfono. Te puede mandar recordatorios. Lo podés dejar de compartir cuando quieras.';

  @override
  String vetSinMiVeterinaria(String nombre) {
    return 'Si marcás tu veterinaria en el mapa (ficha → «Es mi veterinaria»), le vas a poder compartir a $nombre.';
  }

  @override
  String vetBuscasPregunta(String nombre) {
    return '¿Buscás veterinaria para $nombre?';
  }

  @override
  String get vetBuscasAyuda =>
      'Las veterinarias cercanas te pueden mandar propuestas (como máximo 3 por mes). No saben quién sos hasta que aceptás una.';

  @override
  String get vetBuscarSi => 'Sí, quiero propuestas';

  @override
  String get vetAhoraNo => 'Ahora no';

  @override
  String get vetBuscando =>
      'Estás recibiendo propuestas de veterinarias cercanas.';

  @override
  String get vetDejarDeBuscar => 'Dejar de buscar';

  @override
  String vetPropuestaDe(String negocio) {
    return 'Propuesta de $negocio';
  }

  @override
  String get vetAceptar => 'Aceptar';

  @override
  String get vetRechazar => 'No, gracias';

  @override
  String vetAceptada(String negocio) {
    return 'Aceptada: ahora $negocio es su veterinaria.';
  }

  @override
  String get vetRechazada => 'La rechazaste.';

  @override
  String get sociosTitulo => 'Socios';

  @override
  String get sociosAbrir => 'Socios y «Busco veterinaria»';

  @override
  String get sociosModulo => 'Módulo Socios';

  @override
  String get sociosModuloAyuda =>
      'Tus clientes te comparten su mascota y les podés recordar los controles.';

  @override
  String get sociosSoloPlus => 'Socios necesita el plan Plus.';

  @override
  String get sociosVacio => 'Todavía nadie te compartió su mascota.';

  @override
  String sociosProximo(String que, String fecha) {
    return 'Próximo: $que · $fecha';
  }

  @override
  String get sociosSinProximo => 'Sin controles próximos en la libreta';

  @override
  String sociosDeDuenio(String nombre) {
    return 'De $nombre';
  }

  @override
  String get sociosRecordar => 'Recordar';

  @override
  String sociosRecordarTitulo(String nombre) {
    return 'Recordatorio para $nombre';
  }

  @override
  String get sociosRecordarQue => '¿Qué hay que recordar?';

  @override
  String sociosRecordarFecha(String fecha) {
    return 'Día: $fecha';
  }

  @override
  String get sociosElegirFecha => 'Cambiar día';

  @override
  String get sociosRecordado => 'Listo: le va a sonar en el celular del dueño.';

  @override
  String get sociosDemasiados =>
      'Ya le mandaste muchos recordatorios esta semana.';

  @override
  String get demandaTitulo => 'Busco veterinaria';

  @override
  String get demandaAyuda =>
      'Mascotas a menos de 2 km cuyos dueños buscan veterinaria. Solo se muestran grupos de 5 o más, y nunca quiénes son.';

  @override
  String get demandaVacia =>
      'Por ahora no hay suficientes mascotas buscando cerca.';

  @override
  String demandaFila(String especie, int cantidad) {
    return '$especie: $cantidad';
  }

  @override
  String get propuestaMensaje =>
      'Tu propuesta (por ejemplo: primera consulta sin cargo)';

  @override
  String get propuestaEnviar => 'Enviar propuesta';

  @override
  String propuestaEnviada(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Le llegó a $n mascotas.',
      one: 'Le llegó a 1 mascota.',
      zero: 'No le llegó a nadie: este mes ya recibieron sus 3 propuestas.',
    );
    return '$_temp0';
  }

  @override
  String get propuestaLimite =>
      'Como máximo podés mandar 2 propuestas por semana.';

  @override
  String propuestaResultado(int enviadas, int vistas, int aceptadas) {
    return '$enviadas enviadas · $vistas vistas · $aceptadas aceptadas';
  }

  @override
  String get mascotaRenac => '¿Está registrada en el RENAC?';

  @override
  String get mascotaRenacAyuda =>
      'Es el registro oficial de perros y gatos con microchip. Si no sabés, elegí \"No sé\".';

  @override
  String get renacTitulo => 'Registro RENAC';

  @override
  String get renacRegistrada => 'Registrada en el RENAC';

  @override
  String get renacNoRegistrada => 'No está registrada en el RENAC';

  @override
  String get renacNoSabe => 'No sabés si está registrada en el RENAC';

  @override
  String get renacSinResponder => '¿Está registrada en el RENAC?';

  @override
  String get renacDeclarado => 'Lo indicaste vos: la app no lo verifica.';

  @override
  String renacAviso(String nombre) {
    return 'Registrar a $nombre con microchip es obligatorio por ley y ayuda a que vuelva a casa si se pierde.';
  }

  @override
  String get renacCachorro => 'Se registra a partir de los 90 días de vida.';

  @override
  String get renacComoRegistrar => 'Cómo registrarla';

  @override
  String get renacVerificar => 'Verificar en el RENAC';

  @override
  String get renacYaLaRegistre => 'Ya la registré';

  @override
  String get renacGuardado => 'Listo, quedó como registrada.';

  @override
  String get renacGuiaTitulo => 'Cómo registrar a tu mascota';

  @override
  String get renacGuiaTexto =>
      '## Qué es el RENAC\nEs el **Registro Nacional de Animales de Compañía** del MGAP (Ley 18.471). Los perros y gatos se identifican con un **microchip** y se registran a nombre de quien los tiene a cargo. Es obligatorio.\n## Cuándo\nA partir de los **90 días de vida**.\n## Cómo se hace\n- Andá a una veterinaria que sea **operador RENAC** (veterinarios acreditados por el INBA).\n- Te coloca el microchip, si no tiene, y carga los datos de tu mascota y los tuyos.\n- Te dan una **constancia** con esos datos. Guardala.\n- El costo lo fija cada veterinaria: preguntá antes.\n## Si se muda o cambia de dueño\nPedile a tu veterinaria que actualice los datos en el RENAC.\n## Si se pierde\nAdemás de publicar el SOS en la app, pedí que la marquen como **extraviada** en el RENAC.\n## Chip y chapita QR\nEl chip solo lo lee una veterinaria con un lector. La chapita QR la lee cualquier celular. **Se complementan.**\n> Huellitas no es parte del RENAC ni del MGAP. Esta guía es orientativa: ante cualquier duda, consultá con tu veterinaria o con el INBA.';

  @override
  String get renacVerVeterinarias => 'Ver veterinarias que colocan microchip';

  @override
  String get renacVerificarAyuda =>
      'Para consultar necesitás el número de chip y tu documento. Se abre la página oficial.';

  @override
  String get buscarLugares => 'Buscar lugares';

  @override
  String get buscarPista => 'Nombre o rubro…';

  @override
  String get buscarBorrar => 'Borrar';

  @override
  String get buscarAyuda =>
      'Buscá por nombre o por rubro: veterinaria, peluquería, guardería, refugio…';

  @override
  String buscarIncluyeRubro(String rubro) {
    return 'Incluye $rubro cerca';
  }

  @override
  String buscarSinRubro(String rubro) {
    return 'Todavía no hay $rubro cerca en Huellitas.';
  }

  @override
  String buscarSinResultados(String texto) {
    return 'No encontramos lugares con «$texto».';
  }

  @override
  String get buscarConocesUno =>
      '¿Conocés uno? Marcalo en el mapa y lo sumamos.';

  @override
  String get pedidoChapitaPedir => 'Pedir una chapita';

  @override
  String get pedidoChapitaTitulo => 'Pedir una chapita';

  @override
  String pedidoChapitaExplicacion(String nombre) {
    return 'Te hacemos una chapita con el QR de $nombre y la retirás en una veterinaria. Cuando te la den, queda vinculada sola.';
  }

  @override
  String get pedidoChapitaPrecio => 'Sin cargo durante el lanzamiento.';

  @override
  String get pedidoChapitaGrabado => 'Texto grabado';

  @override
  String get pedidoChapitaGrabadoAyuda =>
      'Lo que va escrito en la chapita (hasta 20 letras).';

  @override
  String get pedidoChapitaDonde => '¿Dónde la retirás?';

  @override
  String get pedidoChapitaSinPuntos =>
      'Todavía no hay veterinarias de retiro cerca. Probá más adelante.';

  @override
  String get pedidoChapitaTuVeterinaria => 'Tu veterinaria';

  @override
  String get pedidoChapitaConfirmar => 'Pedirla';

  @override
  String get pedidoChapitaPidiendo => 'Pidiendo…';

  @override
  String get pedidoChapitaHecho =>
      'Listo, la pediste. Te avisamos acá cuando esté para retirar.';

  @override
  String pedidoChapitaNumero(int numero, String nombre) {
    return 'Pedido N.º $numero · $nombre';
  }

  @override
  String get pedidoChapitaNuevo => 'Pedida: la estamos preparando.';

  @override
  String pedidoChapitaEnviado(String veterinaria) {
    return 'En camino a $veterinaria.';
  }

  @override
  String pedidoChapitaListo(String veterinaria, int numero) {
    return '¡Lista para retirar en $veterinaria! Decí el pedido N.º $numero.';
  }

  @override
  String get pedidoChapitaEntregado => 'Entregada y vinculada.';

  @override
  String get pedidoChapitaCancelado => 'Pedido cancelado.';

  @override
  String get pedidoChapitaYaHayUno =>
      'Ya hay un pedido abierto para esta mascota.';

  @override
  String pedidoChapitaDemasiados(int n) {
    return 'Podés tener hasta $n pedidos abiertos a la vez.';
  }

  @override
  String get pedidoChapitaNoEsPunto =>
      'Esa veterinaria ya no entrega chapitas. Elegí otra.';

  @override
  String get retiroTitulo => 'Chapitas: punto de retiro';

  @override
  String get retiroTarjetaAyuda => 'Entregá chapitas QR a tus clientes.';

  @override
  String get retiroSerPunto => 'Ser punto de retiro de chapitas';

  @override
  String get retiroSerPuntoAyuda =>
      'Los dueños eligen tu veterinaria para retirar la chapita de su mascota. Te la mandamos nosotros.';

  @override
  String get retiroSoloVerificadas => 'Solo para veterinarias verificadas.';

  @override
  String get retiroPedidos => 'Pedidos';

  @override
  String get retiroSinPedidos => 'Todavía no hay pedidos.';

  @override
  String retiroPara(String nombre) {
    return 'Para $nombre';
  }

  @override
  String retiroGrabado(String texto) {
    return 'Grabado: $texto';
  }

  @override
  String retiroCodigo(String codigo) {
    return 'Código $codigo';
  }

  @override
  String get retiroEnPreparacion => 'La estamos preparando.';

  @override
  String get retiroEnCamino => 'En camino: marcá «Llegó» cuando la recibas.';

  @override
  String get retiroEsperando => 'Esperando que la retiren.';

  @override
  String get retiroEntregadaYa => 'Entregada.';

  @override
  String get retiroLlego => 'Llegó';

  @override
  String get retiroEntregada => 'Entregada';

  @override
  String get retiroEntregarTitulo => '¿La entregaste?';

  @override
  String retiroEntregarTexto(int numero, String nombre) {
    return 'Pedido N.º $numero: la chapita queda vinculada a $nombre.';
  }

  @override
  String stockResumen(int disponibles, int activadas) {
    String _temp0 = intl.Intl.pluralLogic(
      disponibles,
      locale: localeName,
      other: 'chapitas',
      one: 'chapita',
    );
    String _temp1 = intl.Intl.pluralLogic(
      activadas,
      locale: localeName,
      other: 'activadas',
      one: 'activada',
    );
    return 'Tu stock: $disponibles $_temp0 sin usar · $activadas $_temp1';
  }

  @override
  String get stockAyuda =>
      'Chapitas en blanco para tus clientes: la activan con la app escaneándola, o se la das a quien la pidió para retirar acá.';

  @override
  String stockEntregarNumero(int numero) {
    return 'Entregar el N.º $numero de mi stock';
  }

  @override
  String get stockEntregarTitulo => 'Entregar una chapita de tu stock';

  @override
  String stockEntregarTexto(int numero, String nombre, String grabado) {
    return 'Pedido N.º $numero para $nombre (grabado «$grabado»). Escribí el código que viene en la chapita: queda vinculada a $nombre al tocar Entregada.';
  }

  @override
  String get stockCodigo => 'Código de la chapita';

  @override
  String get transitoTitulo => 'Hogar de tránsito';

  @override
  String get transitoIntro =>
      'Cuidá por un tiempo a un animal de un refugio hasta que encuentre familia. Vos decidís qué animales recibís, por cuánto tiempo y a qué pedido decís que sí.';

  @override
  String get transitoPrivacidad =>
      'Solo los refugios y protectoras verificados de tu zona ven tu primer nombre, tu barrio y lo que recibís. Nunca tu dirección ni tu teléfono: si aceptás un pedido, se abre un chat con el refugio.';

  @override
  String get transitoPedidos => 'Pedidos que te llegaron';

  @override
  String get transitoActivo => 'Puedo recibir animales ahora';

  @override
  String get transitoActivoAyuda => 'Apagado, los refugios no te ven.';

  @override
  String get transitoEspecies => 'Qué animales recibís';

  @override
  String get transitoTamanos => 'De qué tamaño';

  @override
  String get transitoMaxDias => 'Por cuántos días como máximo (1 a 365)';

  @override
  String get transitoPatio => 'Tengo patio';

  @override
  String get transitoOtros => 'Hay otros animales en casa';

  @override
  String get transitoBarrio => 'Tu barrio';

  @override
  String get transitoBarrioAyuda => 'Solo el barrio, sin calle ni número.';

  @override
  String get transitoNotas => 'Algo más que quieras contar (opcional)';

  @override
  String get transitoAnotarme => 'Anotarme como hogar de tránsito';

  @override
  String get transitoGuardado =>
      '¡Listo! Ya figurás para los refugios de tu zona.';

  @override
  String get transitoFaltanDatos =>
      'Completá qué animales recibís, el tamaño, los días y tu barrio.';

  @override
  String get transitoBorrar => 'Dejar de ser hogar de tránsito';

  @override
  String get transitoBorrarTitulo => '¿Dejás de ser hogar de tránsito?';

  @override
  String get transitoBorrarTexto =>
      'Se borran tus datos y los pedidos que te llegaron. Los chats con los refugios quedan.';

  @override
  String transitoPedidoDe(String refugio, String nombre) {
    return '$refugio te pide recibir a $nombre';
  }

  @override
  String transitoDias(int dias) {
    String _temp0 = intl.Intl.pluralLogic(
      dias,
      locale: localeName,
      other: '$dias días',
      one: '1 día',
    );
    return '$_temp0';
  }

  @override
  String get transitoAceptar => 'Puedo recibirlo';

  @override
  String get transitoRechazar => 'Ahora no';

  @override
  String get transitoAceptado => 'Aceptado';

  @override
  String get transitoAbrirChat => 'Abrir el chat';

  @override
  String get transitoRechazado => 'Dijiste que ahora no.';

  @override
  String get transitoCancelado => 'Cancelado';

  @override
  String get transitoTerminado => 'Terminó el tránsito. ¡Gracias!';

  @override
  String get transitoEnUno => 'En un hogar de tránsito';

  @override
  String get transitoRefugioTitulo => 'Hogares de tránsito';

  @override
  String get transitoRefugioTarjeta =>
      'Personas de tu zona que cuidan animales hasta que se adopten.';

  @override
  String get transitoRefugioAyuda =>
      'Ves solo el primer nombre y el barrio. Si el hogar acepta, se abre un chat para coordinar.';

  @override
  String get transitoTusPedidos => 'Tus pedidos';

  @override
  String transitoPedidoA(String nombre, String hogar) {
    return '$nombre → $hogar';
  }

  @override
  String get transitoEsperando => 'Esperando respuesta';

  @override
  String transitoChatCon(String nombre) {
    return 'Chat con $nombre';
  }

  @override
  String transitoCancelarPedido(String nombre) {
    return 'Cancelar el de $nombre';
  }

  @override
  String transitoTerminar(String nombre) {
    return 'Terminó el de $nombre';
  }

  @override
  String get transitoHogares => 'Hogares de tu zona';

  @override
  String get transitoSinHogares =>
      'Todavía no hay hogares de tránsito en tu zona.';

  @override
  String transitoHasta(int dias) {
    return 'hasta $dias días';
  }

  @override
  String get transitoConPatio => 'con patio';

  @override
  String get transitoConOtros => 'con otros animales';

  @override
  String get transitoConAnimal => 'Ahora tiene un animal en tránsito.';

  @override
  String get transitoYaPediste => 'Ya le pediste';

  @override
  String get transitoPedir => 'Pedir';

  @override
  String transitoPedirA(String nombre) {
    return 'Pedirle a $nombre';
  }

  @override
  String get transitoNombreAnimal => 'Nombre del animal';

  @override
  String get transitoEspecie => 'Especie';

  @override
  String get transitoTamano => 'Tamaño';

  @override
  String get transitoTamanoSinDecir => 'Sin decir';

  @override
  String transitoCuantosDias(int dias) {
    return 'Cuántos días (hasta $dias)';
  }

  @override
  String get transitoMensaje => 'Mensaje (opcional)';

  @override
  String get transitoPedidoEnviado =>
      'Pedido enviado. Te avisamos acá cuando responda.';

  @override
  String get transitoSoloRefugios =>
      'Solo para refugios y protectoras verificados.';

  @override
  String get transitoNoDisponible => 'Ese hogar ya no está disponible.';

  @override
  String get transitoNoRecibe => 'Ese hogar no recibe ese animal.';

  @override
  String get transitoMasDias => 'Son más días de los que puede ese hogar.';

  @override
  String get transitoYaHayUno => 'Ya le pediste algo que todavía no respondió.';

  @override
  String get transitoLimite => 'Llegaste al máximo de pedidos por hoy.';

  @override
  String get listo => 'Listo';

  @override
  String get packTitulo => 'Pack adopción';

  @override
  String get packTarjeta =>
      'Beneficios de comercios de tu zona por haber adoptado.';

  @override
  String get packTarjetaNegocio =>
      'Un beneficio para quien adopta por la app. Es gratis.';

  @override
  String get packIntro =>
      'Por haber adoptado por la app, estos comercios te dan un beneficio. Pedí el código y mostralo en el local.';

  @override
  String get packSinAdopcion =>
      'El pack adopción es para quien adoptó por la app en los últimos 6 meses.';

  @override
  String get packSinBeneficios => 'Todavía no hay beneficios en tu zona.';

  @override
  String get packQuiero => 'Quiero este beneficio';

  @override
  String get packTuCodigo => 'Tu código:';

  @override
  String get packMostralo => 'Mostralo en el local. Se usa una sola vez.';

  @override
  String packUsado(String codigo) {
    return 'Ya lo usaste (código $codigo).';
  }

  @override
  String get packNegocioAyuda =>
      'Quien adoptó por la app pide el código y lo trae. Al canjearlo ves solo su primer nombre y el animal que adoptó.';

  @override
  String get packCanjear => 'Canjear un código';

  @override
  String get packCodigo => 'Código de 6 letras y números';

  @override
  String get packCanjearBoton => 'Canjear';

  @override
  String get packCanjeado => '¡Código canjeado!';

  @override
  String packPara(String nombre) {
    return 'Para $nombre';
  }

  @override
  String packAnimal(String nombre) {
    return 'Adoptó a $nombre';
  }

  @override
  String get packTusBeneficios => 'Tus beneficios';

  @override
  String get packNuevo => 'Nuevo beneficio';

  @override
  String get packEditar => 'Editar beneficio';

  @override
  String get packSinPropios => 'Todavía no cargaste ninguno.';

  @override
  String packResumen(int pedidos, int usados) {
    return '$pedidos lo pidieron · $usados lo usaron';
  }

  @override
  String get packTituloCampo => 'Qué le das';

  @override
  String get packTituloEjemplo => 'Primera consulta con 20 % de descuento';

  @override
  String get packDescripcion => 'Condiciones (opcional)';

  @override
  String get packSoloVerificados =>
      'Solo para veterinarias, pet shops, agroveterinarias y peluquerías verificadas.';

  @override
  String get packDemasiados => 'Podés tener hasta 5 beneficios activos.';

  @override
  String get packNoDisponible => 'Ese beneficio ya no está disponible.';

  @override
  String get packCodigoInexistente =>
      'Ese código no es de un beneficio de tu comercio.';

  @override
  String get packCodigoUsado => 'Ese código ya se usó.';

  @override
  String get apadrinarTitulo => 'Apadrinar un refugio';

  @override
  String get apadrinarPadrinos => 'Padrinos del refugio';

  @override
  String get apadrinarTarjeta =>
      'Ayudá a un refugio de tu zona y que se vea en su ficha.';

  @override
  String get apadrinarTarjetaRefugio =>
      'Comercios que se ofrecen a apadrinarte.';

  @override
  String get apadrinarAyuda =>
      'Elegí un refugio verificado de tu zona (o una feria suya) y contá qué aportás. Si el refugio acepta, su ficha muestra «Apadrinado por» con tu nombre.';

  @override
  String get apadrinarRefugioAyuda =>
      'Si aceptás, tu ficha (o la del evento) muestra «Apadrinado por» con el nombre del comercio y lo que aporta. Lo podés terminar cuando quieras.';

  @override
  String get apadrinarSinRecibidos => 'Todavía no recibiste ofrecimientos.';

  @override
  String get apadrinarTuyos => 'Lo que ofreciste';

  @override
  String get apadrinarRefugios => 'Refugios de tu zona';

  @override
  String get apadrinarSinRefugios =>
      'Todavía no hay refugios verificados en tu zona.';

  @override
  String apadrinarEventos(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n eventos próximos',
      one: '1 evento próximo',
    );
    return '$_temp0';
  }

  @override
  String get apadrinarOfrecer => 'Ofrecer';

  @override
  String apadrinarA(String nombre) {
    return 'Apadrinar a $nombre';
  }

  @override
  String get apadrinarQue => 'Qué apadrinás';

  @override
  String get apadrinarAlRefugio => 'Al refugio';

  @override
  String get apadrinarAporte => 'Qué aportás';

  @override
  String get apadrinarAporteEjemplo => 'Alimento para 20 perros por mes';

  @override
  String get apadrinarFaltaAporte => 'Contá qué aportás.';

  @override
  String get apadrinarAceptar => 'Aceptar';

  @override
  String get apadrinarRechazar => 'No, gracias';

  @override
  String get apadrinarTerminar => 'Terminar';

  @override
  String get apadrinarRetirar => 'Retirar';

  @override
  String get apadrinarPendiente => 'Esperando que el refugio responda';

  @override
  String get apadrinarActivo => 'Activo: se ve en la ficha';

  @override
  String get apadrinarRechazado => 'El refugio dijo que no';

  @override
  String get apadrinarTerminado => 'Terminado';

  @override
  String apadrinadoPor(String nombres) {
    return 'Apadrinado por $nombres';
  }

  @override
  String get apadrinarSoloVerificados =>
      'Solo los comercios verificados pueden apadrinar.';

  @override
  String get apadrinarNoDisponible =>
      'Ese refugio o evento ya no está disponible.';

  @override
  String get apadrinarYaHayUno => 'Ya ofreciste apadrinar eso.';

  @override
  String get apadrinarLimite => 'Llegaste al máximo de ofrecimientos por hoy.';

  @override
  String get stockNoEsTuya =>
      'Ese código no está entre las chapitas sin usar de tu stock.';

  @override
  String get estadisticasTitulo => 'Estadísticas';

  @override
  String get estadisticasAbrir => 'Ver estadísticas';

  @override
  String get estadisticasAbrirAyuda =>
      'Cuántas personas te ven y te contactan, mes a mes';

  @override
  String get estadisticasEsteMes => 'Este mes';

  @override
  String get estadisticasSinDatos =>
      'Todavía no hay movimiento para mostrar. Cuando la gente abra tu ficha, lo vas a ver acá.';

  @override
  String get estadisticasAperturas => 'Vieron tu ficha';

  @override
  String get estadisticasPersonas => 'Personas distintas';

  @override
  String get estadisticasContactos => 'Te contactaron';

  @override
  String get estadisticasContactosAyuda =>
      'WhatsApp, llamadas, cómo llegar, web, Instagram, chats, consultas y pedidos';

  @override
  String get estadisticasFavoritos => 'Te guardaron en favoritos';

  @override
  String get estadisticasVisitas => 'Dijeron «Fui»';

  @override
  String get estadisticasChats => 'Chats nuevos';

  @override
  String get estadisticasCatalogo => 'Abrieron tu catálogo';

  @override
  String get estadisticasConsultas => 'Consultas de productos y servicios';

  @override
  String get estadisticasPedidos => 'Pedidos';

  @override
  String get estadisticasPagina => 'Visitas a tu página';

  @override
  String get estadisticasResenas => 'Reseñas nuevas';

  @override
  String estadisticasMasQue(int p) {
    return '$p % más que el mes anterior';
  }

  @override
  String estadisticasMenosQue(int p) {
    return '$p % menos que el mes anterior';
  }

  @override
  String get estadisticasIgual => 'Igual que el mes anterior';

  @override
  String estadisticasNuevo(int n) {
    return 'El mes anterior: $n';
  }

  @override
  String get estadisticasPorSemana => 'Últimas 12 semanas';

  @override
  String get estadisticasPorMes => 'Mes a mes';

  @override
  String get estadisticasClics => 'Qué tocaron en tu ficha';

  @override
  String get estadisticasSoloResumen =>
      'Con el plan Básico ves este resumen. Con Destacado o Plus ves todas las métricas, 6 meses y la evolución semana a semana.';

  @override
  String get estadisticasPrivacidad =>
      'Son cantidades: nunca se muestra quién fue.';

  @override
  String estadisticasSemanaDe(String fecha) {
    return 'Semana del $fecha';
  }

  @override
  String get planTitulo => 'Tu plan';

  @override
  String get planAbrirAyuda => 'Qué incluye, cuándo vence y tus pagos';

  @override
  String planActual(String plan) {
    return 'Plan $plan';
  }

  @override
  String planVence(String fecha) {
    return 'Vence el $fecha';
  }

  @override
  String planVencido(String fecha) {
    return 'Venció el $fecha. Tenés 7 días para pagarlo antes de volver a Básico.';
  }

  @override
  String planCancelado(String fecha) {
    return 'Diste de baja el plan: sigue hasta el $fecha.';
  }

  @override
  String planFundador(String fecha) {
    return 'Socio Fundador hasta el $fecha: sin costo hasta esa fecha.';
  }

  @override
  String planPrecio(String precio) {
    return 'Precio: \$ $precio por mes';
  }

  @override
  String get planIncluyeBasico =>
      'Tu ficha en el mapa, hasta 3 fotos, responder reseñas y un resumen de tus estadísticas.';

  @override
  String get planIncluyeDestacado =>
      'Pin naranja y prioridad en el mapa y las búsquedas, galería de fotos, promoción, web, Instagram y WhatsApp, estadísticas completas y reporte mensual.';

  @override
  String get planIncluyePlus =>
      'Todo lo de Destacado, más catálogo y pedidos, agenda, socios, servicios publicados y tu página propia.';

  @override
  String get planMejorar => 'Mejorá tu plan';

  @override
  String planQuiero(String plan) {
    return 'Quiero $plan';
  }

  @override
  String get planPedido => '¡Listo! Te vamos a contactar para activarlo.';

  @override
  String get planPedidoAbierto => 'Ya pediste un plan: te vamos a contactar.';

  @override
  String get planComoSePaga =>
      'Por ahora se paga por transferencia o link de pago, de mes a mes. Te mandamos los datos cuando te contactemos.';

  @override
  String get planPagos => 'Tus pagos';

  @override
  String planPago(String fecha, String monto, int meses) {
    String _temp0 = intl.Intl.pluralLogic(
      meses,
      locale: localeName,
      other: '$meses meses',
      one: '1 mes',
    );
    return '$fecha · \$ $monto · $_temp0';
  }

  @override
  String get planAntesDespues => 'Desde que pasaste al plan pago';

  @override
  String planAntesDespuesTexto(
    int dias,
    int despues,
    int contactosDespues,
    int antes,
    int contactosAntes,
  ) {
    return 'En $dias días: $despues aperturas de tu ficha y $contactosDespues contactos. En los $dias días anteriores: $antes y $contactosAntes.';
  }

  @override
  String get turnoReservar => 'Reservar turno';

  @override
  String get turnoReservarTitulo => 'Reservar un turno';

  @override
  String get turnoServicio => '¿Qué servicio?';

  @override
  String get turnoSinServicio => 'Consulta general';

  @override
  String get turnoDia => '¿Qué día?';

  @override
  String get turnoHorario => '¿A qué hora?';

  @override
  String get turnoSinHorarios =>
      'No quedan horarios libres ese día. Probá con otro.';

  @override
  String get turnoMascota => '¿Para qué mascota?';

  @override
  String get turnoSinMascotas =>
      'Primero agregá a tu mascota en la pestaña Mascotas.';

  @override
  String get turnoNota => 'Algo que el comercio tenga que saber (opcional)';

  @override
  String get turnoConfirmar => 'Pedir el turno';

  @override
  String get turnoPedido => '¡Listo! El comercio te va a confirmar el turno.';

  @override
  String get turnoOcupado => 'Ese horario se acaba de ocupar. Elegí otro.';

  @override
  String get turnoLimite =>
      'Llegaste al máximo de turnos por ahora (3 por comercio, 10 por día).';

  @override
  String get turnoNoSePuede => 'No se pudo hacer ese cambio.';

  @override
  String get turnoIngresar => 'Ingresá para reservar un turno';

  @override
  String turnoDuracion(int min) {
    return '$min min';
  }

  @override
  String get misTurnos => 'Mis turnos';

  @override
  String get misTurnosAyuda => 'Los turnos que pediste y su estado';

  @override
  String get misTurnosVacio =>
      'Todavía no pediste turnos. Los comercios con agenda tienen «Reservar turno» en su ficha.';

  @override
  String get turnoCancelar => 'Cancelar el turno';

  @override
  String get turnoCancelarTexto =>
      'Se avisa al comercio. Se puede cancelar hasta 2 horas antes.';

  @override
  String get turnoCancelado => 'Turno cancelado.';

  @override
  String get turnoNoCancelable =>
      'Falta menos de 2 horas: si no podés ir, avisale al comercio por el chat.';

  @override
  String get turnoPendiente => 'Esperando confirmación';

  @override
  String get turnoConfirmado => 'Confirmado';

  @override
  String get turnoRechazado => 'No disponible';

  @override
  String get turnoCanceladoEstado => 'Cancelado';

  @override
  String get turnoAtendido => 'Atendido';

  @override
  String turnoCuando(String dia, String hora) {
    return '$dia · $hora';
  }

  @override
  String get agendaModulo => 'Tomar turnos desde la app';

  @override
  String get agendaModuloAyuda =>
      'Aparece «Reservar turno» en tu ficha. Vos confirmás o rechazás cada pedido.';

  @override
  String get agendaConfigurar => 'Cómo das los turnos';

  @override
  String get agendaDuracion => 'Duración de cada turno';

  @override
  String get agendaALaVez => 'Turnos al mismo tiempo';

  @override
  String get agendaAnticipacion => 'Con cuánta anticipación';

  @override
  String get agendaDiasAdelante => 'Hasta cuántos días adelante';

  @override
  String agendaMinutos(int n) {
    return '$n min';
  }

  @override
  String agendaHoras(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n horas antes',
      one: '1 hora antes',
      zero: 'Sin anticipación',
    );
    return '$_temp0';
  }

  @override
  String agendaDias(int n) {
    return '$n días';
  }

  @override
  String get agendaHorarioAyuda =>
      'Se usan el horario de tu ficha y la duración de cada servicio (si la tiene).';

  @override
  String get agendaGuardar => 'Guardar';

  @override
  String get agendaGuardada => 'Agenda guardada.';

  @override
  String get agendaBloqueados => 'Días sin turnos';

  @override
  String get agendaBloquear => 'Agregar un día sin turnos';

  @override
  String get agendaSinBloqueados => 'Ninguno por ahora.';

  @override
  String get agendaTurnos => 'Turnos';

  @override
  String get agendaSinTurnos => 'Todavía no te pidieron turnos.';

  @override
  String get agendaConfirmar => 'Confirmar';

  @override
  String get agendaRechazar => 'Rechazar';

  @override
  String get agendaAtendido => 'Atendido';

  @override
  String get agendaCancelar => 'Cancelar';

  @override
  String agendaCliente(String nombre, String mascota) {
    return '$nombre · $mascota';
  }

  @override
  String get miPlanTitulo => 'Mi plan';

  @override
  String get miPlanAyuda => 'Gratis, Pro o Familia: qué incluye cada uno';

  @override
  String get miPlanGratis => 'Gratis';

  @override
  String get miPlanPro => 'Pro';

  @override
  String get miPlanFamilia => 'Familia';

  @override
  String get miPlanIncluyeGratis =>
      'Todo lo que cuida a tu mascota: SOS, avisos por zona, chapita QR, foto, mapa, chat y recordatorios de medicación, comida y vacunas. Hasta 2 mascotas.';

  @override
  String get miPlanIncluyePro =>
      'Todo lo de Gratis, más mascotas ilimitadas, sin publicidad, filtros y favoritos guardados, descuentos en comercios adheridos, historial de salud en PDF y temas de color.';

  @override
  String get miPlanIncluyeFamilia =>
      'Todo lo de Pro, más el hogar compartido: hasta 5 personas cuidan a las mismas mascotas, con tareas y cuidador temporal. Las personas de tu hogar también tienen Pro.';

  @override
  String get miPlanSiempreGratis =>
      'Lo que hace a la seguridad y la salud de tu mascota es gratis siempre, con cualquier plan.';

  @override
  String get miPlanPorHogar =>
      'Tenés Familia porque sos parte de un hogar con ese plan.';

  @override
  String miPlanPrueba(String fecha) {
    return 'Prueba gratis de Familia hasta el $fecha.';
  }

  @override
  String miPlanVencido(String fecha) {
    return 'Venció el $fecha. Tenés 7 días para pagarlo antes de volver a Gratis.';
  }

  @override
  String miPlanVolverGratis(String fecha) {
    return 'Diste de baja el plan: sigue hasta el $fecha. Después volvés a Gratis y no perdés nada de lo cargado.';
  }

  @override
  String miPlanMascotas(int n, int limite) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n mascotas',
      one: '1 mascota',
    );
    return '$_temp0 de $limite';
  }

  @override
  String get miPlanPruebaFamilia =>
      'Al invitar a la primera persona a tu hogar, tenés 30 días gratis de Familia.';

  @override
  String miPlanPedido(String plan) {
    return 'Ya pediste $plan: te vamos a contactar.';
  }

  @override
  String get miPlanLimiteMascotas =>
      'Con el plan Gratis podés tener hasta 2 mascotas. Con Pro o Familia, todas las que quieras.';

  @override
  String get miPlanVerPlanes => 'Ver planes';

  @override
  String get miPlanHogarFamilia =>
      'El hogar compartido es del plan Familia y ya usaste la prueba gratis de 30 días.';

  @override
  String get historialPdf => 'Historial en PDF';

  @override
  String historialTitulo(String nombre) {
    return 'Historial de salud de $nombre';
  }

  @override
  String historialPie(String fecha) {
    return 'Hecho con Huellitas el $fecha';
  }

  @override
  String get historialSi => 'Sí';

  @override
  String get historialNo => 'No';

  @override
  String get historialNoDisponible =>
      'En este dispositivo todavía no se puede descargar. Probá desde la web.';

  @override
  String get mapaFiltrosGuardar => 'Guardar como mis filtros';

  @override
  String get mapaFiltrosGuardados =>
      'Listo: el mapa va a abrir con estos filtros.';

  @override
  String get ajustesLetra => 'Tamaño de letra';

  @override
  String get letraNormal => 'Normal';

  @override
  String get letraGrande => 'Grande';

  @override
  String get letraMuyGrande => 'Muy grande';

  @override
  String get descuentosTitulo => 'Descuentos Pro';

  @override
  String get descuentosTarjeta =>
      'Descuentos en comercios de tu zona para Pro y Familia';

  @override
  String get descuentosTarjetaNegocio =>
      'Ofrecé un descuento a quienes tienen Pro: te traen clientes y es gratis';

  @override
  String get descuentosIntroPro =>
      'Pedí tu código y mostralo en el local. Sirve cada vez que vuelvas (una vez por día).';

  @override
  String get descuentosIntroGratis =>
      'Estos comercios tienen descuentos para quienes tienen Pro o Familia.';

  @override
  String get descuentosSinDescuentos => 'Todavía no hay descuentos en tu zona.';

  @override
  String get descuentoQuiero => 'Quiero mi código';

  @override
  String get descuentoMostralo => 'Mostralo en el local antes de pagar.';

  @override
  String get descuentoSinPro =>
      'Los descuentos son para quienes tienen Pro o Familia.';

  @override
  String get descuentoSoloVerificados =>
      'Para ofrecer descuentos, tu negocio tiene que estar verificado.';

  @override
  String get descuentoDemasiados => 'Podés tener hasta 5 descuentos activos.';

  @override
  String get descuentoNoDisponible => 'Ese descuento ya no está disponible.';

  @override
  String get descuentoUsadoHoy =>
      'Ese código ya se usó hoy. Vale de nuevo mañana.';

  @override
  String get descuentoVencido => 'Ese descuento venció o está apagado.';

  @override
  String get descuentoCanjeado => 'Descuento válido';

  @override
  String get descuentosNegocioAyuda =>
      'Quien tiene Pro pide su código en la app y te lo muestra. Al canjearlo, la app confirma que su plan sigue vigente. Es gratis para tu negocio.';

  @override
  String get descuentosTuyos => 'Tus descuentos';

  @override
  String get descuentoNuevo => 'Nuevo descuento';

  @override
  String get descuentoEditar => 'Editar descuento';

  @override
  String get descuentosSinPropios => 'Todavía no cargaste descuentos.';

  @override
  String get descuentoTituloEjemplo => 'Por ejemplo: 10 % en baños';

  @override
  String descuentoResumen(int pedidos, int usados) {
    String _temp0 = intl.Intl.pluralLogic(
      pedidos,
      locale: localeName,
      other: '$pedidos códigos pedidos',
      one: '1 código pedido',
    );
    String _temp1 = intl.Intl.pluralLogic(
      usados,
      locale: localeName,
      other: '$usados veces',
      one: '1 vez',
    );
    return '$_temp0 · usado $_temp1';
  }

  @override
  String get panelParaAtender => 'Para atender';

  @override
  String panelPedidosNuevos(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n pedidos nuevos',
      one: '1 pedido nuevo',
    );
    return '$_temp0';
  }

  @override
  String panelTurnosPendientes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n turnos por confirmar',
      one: '1 turno por confirmar',
    );
    return '$_temp0';
  }

  @override
  String get planillaTitulo => 'Cargar desde una planilla';

  @override
  String get planillaTarjeta =>
      'Pegá tu lista de productos desde Excel o Google Sheets';

  @override
  String get planillaAyuda =>
      'Columnas, en este orden: nombre, descripción, precio y disponible (si o no). Copiá las filas de tu planilla y pegalas acá. Si un producto ya existe con el mismo nombre, se actualiza y conserva su foto.';

  @override
  String get planillaModelo => 'Descargar el modelo';

  @override
  String get planillaPegar => 'Pegá acá las filas';

  @override
  String get planillaRevisar => 'Revisar';

  @override
  String planillaResumen(int nuevos, int actualizados, int errores) {
    String _temp0 = intl.Intl.pluralLogic(
      nuevos,
      locale: localeName,
      other: '$nuevos productos nuevos',
      one: '1 producto nuevo',
    );
    String _temp1 = intl.Intl.pluralLogic(
      actualizados,
      locale: localeName,
      other: '$actualizados se actualizan',
      one: '1 se actualiza',
    );
    String _temp2 = intl.Intl.pluralLogic(
      errores,
      locale: localeName,
      other: '$errores filas con error',
      one: '1 fila con error',
      zero: 'sin errores',
    );
    return '$_temp0 · $_temp1 · $_temp2';
  }

  @override
  String planillaErrorFila(int fila, String motivo) {
    return 'Fila $fila: $motivo';
  }

  @override
  String get planillaSinNombre => 'falta el nombre';

  @override
  String get planillaNombreLargo => 'el nombre tiene más de 80 letras';

  @override
  String get planillaPrecioInvalido => 'el precio no es un número';

  @override
  String get planillaRepetido => 'el nombre está repetido en la planilla';

  @override
  String planillaCargar(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Cargar $n productos',
      one: 'Cargar 1 producto',
    );
    return '$_temp0';
  }

  @override
  String planillaLimite(int n) {
    return 'Se llegó al máximo de 200 productos. Se cargaron $n.';
  }

  @override
  String get reporteDescargar => 'Descargar el reporte del mes en PDF';

  @override
  String reporteTitulo(String mes) {
    return 'Reporte de $mes';
  }

  @override
  String get cuidadoPaseo => 'Paseo';

  @override
  String get cuidadoGuarderia => 'Guardería de día';

  @override
  String get cuidadoEstadia => 'Estadía';

  @override
  String get cuidadoVisitas => 'Visitas a domicilio';

  @override
  String get cuidadoManana => 'De mañana';

  @override
  String get cuidadoTarde => 'De tarde';

  @override
  String get cuidadoNoche => 'De noche';

  @override
  String get cuidadoPendiente => 'Esperando respuesta';

  @override
  String get cuidadoAceptado => 'Aceptado: coordinen por el chat';

  @override
  String get cuidadoRechazado => 'No disponible';

  @override
  String get cuidadoCanceladoEstado => 'Cancelado';

  @override
  String get cuidadoTerminado => 'Terminado';

  @override
  String cuidadoElDia(String dia) {
    return 'el $dia';
  }

  @override
  String cuidadoDelAl(String desde, String hasta) {
    return 'del $desde al $hasta';
  }

  @override
  String get cuidadoSinLugar =>
      'No le queda lugar en alguno de esos días. Probá con otras fechas.';

  @override
  String get cuidadoLimite =>
      'Llegaste al máximo de pedidos por ahora (3 por prestador, 10 por día).';

  @override
  String get cuidadoFueraDeRango => 'Esas fechas no se pueden pedir todavía.';

  @override
  String cuidadoContratar(String servicios) {
    return 'Contratar: $servicios';
  }

  @override
  String get cuidadoIngresar => 'Ingresá para contratar un paseo o una estadía';

  @override
  String get cuidadoTitulo => 'Contratar';

  @override
  String get cuidadoCondiciones => 'Condiciones del prestador';

  @override
  String get cuidadoQue => '¿Qué necesitás?';

  @override
  String get cuidadoFechas => '¿Qué días?';

  @override
  String get cuidadoElegirFechas => 'Elegir las fechas';

  @override
  String cuidadoMaximoDias(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: 'Hasta $n días seguidos por pedido.',
      one: 'Un día por pedido.',
    );
    return '$_temp0';
  }

  @override
  String get cuidadoFranja => '¿En qué momento del día?';

  @override
  String get cuidadoSinFranja => 'Me da igual';

  @override
  String get cuidadoMascotas => '¿Para qué mascotas? (hasta 5)';

  @override
  String get cuidadoNota =>
      'Lo que tenga que saber: horarios, comida, medicación, carácter (opcional)';

  @override
  String get cuidadoComoSigue =>
      'Si acepta, se abre el chat para acordar la dirección, el precio y el pago. Tu teléfono y tu dirección no se comparten.';

  @override
  String get cuidadoEnviar => 'Enviar el pedido';

  @override
  String get cuidadoPedido => '¡Listo! Te avisamos cuando responda.';

  @override
  String get misCuidados => 'Mis paseos y estadías';

  @override
  String get misCuidadosAyuda =>
      'Lo que pediste a paseadores, hoteles y cuidadores';

  @override
  String get misCuidadosVacio =>
      'Todavía no pediste nada. Los paseadores y hoteles que toman pedidos tienen «Contratar» en su ficha.';

  @override
  String get cuidadoChat => 'Abrir el chat';

  @override
  String get cuidadoCancelar => 'Cancelar el pedido';

  @override
  String get cuidadoCancelarTexto =>
      'Se avisa al prestador. Un pedido aceptado se cancela hasta el día anterior.';

  @override
  String get cuidadoCancelado => 'Pedido cancelado.';

  @override
  String get cuidadoNoCancelable =>
      'Ya empezó: si necesitás cambiar algo, escribile por el chat.';

  @override
  String get cuidadosTab => 'Paseos y estadías';

  @override
  String get cuidadosTurnosTab => 'Turnos';

  @override
  String get cuidadosQueOfreces => 'Qué ofrecés';

  @override
  String get cuidadosQueOfrecesAyuda =>
      'Aparece «Contratar» en tu ficha. Vos aceptás o rechazás cada pedido; al aceptar se abre el chat.';

  @override
  String get cuidadosCupo => 'Mascotas por día (guardería y estadía)';

  @override
  String get cuidadosMaximoDias => 'Días seguidos como máximo';

  @override
  String get cuidadosCondiciones => 'Condiciones (vacunas, tamaño, qué traer…)';

  @override
  String get cuidadosPedidos => 'Pedidos';

  @override
  String get cuidadosSinPedidos => 'Todavía no te pidieron nada.';

  @override
  String get cuidadosAceptar => 'Aceptar y abrir el chat';

  @override
  String get cuidadosTerminado => 'Terminado';

  @override
  String panelCuidadosPendientes(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n pedidos de paseo o estadía',
      one: '1 pedido de paseo o estadía',
    );
    return '$_temp0';
  }

  @override
  String get cuidadosPrenderAgenda =>
      'Para que aparezca «Contratar» en tu ficha, prendé «Tomar turnos desde la app» en Turnos.';

  @override
  String get comunidadPregunta => 'Pregunta';

  @override
  String get comunidadConsejo => 'Consejo';

  @override
  String get comunidadExperiencia => 'Experiencia';

  @override
  String get comunidadProhibido =>
      'En la comunidad no se publican ventas ni cruzas de animales. Para dar en adopción está la sección Adopción.';

  @override
  String get comunidadUnite => 'Unite al grupo para participar';

  @override
  String get comunidadLimite => 'Llegaste al máximo por hoy. Probá mañana.';

  @override
  String get comunidadNoQuiere => 'Esa persona no quiere chatear por ahora.';

  @override
  String get comunidadGrupos => 'Grupos';

  @override
  String get comunidadGruposAyuda =>
      'Por raza, especie y temas: preguntas, consejos y experiencias';

  @override
  String get comunidadReglas =>
      'Sin ventas ni cruzas de animales, y sin datos de dónde vive tu mascota. De cada persona se ve solo el primer nombre.';

  @override
  String get comunidadIngresar => 'Ingresá para participar en los grupos';

  @override
  String get comunidadSaludos => 'Saludos';

  @override
  String get comunidadTuRaza => 'Sumate al grupo de la raza de tu mascota';

  @override
  String get comunidadMisGrupos => 'Tus grupos';

  @override
  String get comunidadPorEspecie => 'Por especie';

  @override
  String get comunidadTemas => 'Temas';

  @override
  String get comunidadPorRaza => 'Por raza';

  @override
  String comunidadMiembros(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n integrantes',
      one: '1 integrante',
      zero: 'Sin integrantes todavía',
    );
    return '$_temp0';
  }

  @override
  String comunidadActividad(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n publicaciones esta semana',
      one: '1 publicación esta semana',
    );
    return '$_temp0';
  }

  @override
  String get comunidadSalir => 'Salir del grupo';

  @override
  String get comunidadPublicar => 'Publicar';

  @override
  String get comunidadUnirme => 'Unirme al grupo';

  @override
  String get comunidadSinPublicaciones =>
      'Todavía no hay publicaciones. ¡Hacé la primera pregunta!';

  @override
  String get comunidadAlguien => 'Alguien';

  @override
  String get comunidadFoto => 'Foto';

  @override
  String comunidadComentarios(int n) {
    String _temp0 = intl.Intl.pluralLogic(
      n,
      locale: localeName,
      other: '$n comentarios',
      one: '1 comentario',
      zero: 'Sin comentarios',
    );
    return '$_temp0';
  }

  @override
  String get comunidadBorrar => 'Borrar';

  @override
  String get comunidadSaludar => 'Saludar';

  @override
  String get comunidadSaludarAyuda =>
      'Si acepta, se abre el chat. No compartas tu dirección ni tu teléfono.';

  @override
  String get comunidadMotivoVenta => 'vende o cruza animales';

  @override
  String get comunidadMotivoUbicacion => 'muestra dónde vive una mascota';

  @override
  String comunidadReportar(String motivo) {
    return 'Reportar: $motivo';
  }

  @override
  String get comunidadBorrado => 'Borrado.';

  @override
  String get comunidadSaludado =>
      'Saludo enviado. Si acepta, lo vas a ver en Saludos y en tus chats.';

  @override
  String get comunidadSaludoInicial =>
      '¡Hola! Vi lo que escribiste en el grupo y me gustaría charlar.';

  @override
  String get comunidadMandarSaludo => 'Mandar el saludo';

  @override
  String get comunidadOpciones => 'Opciones';

  @override
  String get comunidadComentar => 'Escribí un comentario';

  @override
  String get comunidadNoDisponible => 'Esta publicación ya no está disponible.';

  @override
  String get comunidadTexto => '¿Qué querés contar o preguntar?';

  @override
  String get comunidadAgregarFoto => 'Agregar foto';

  @override
  String get comunidadSinSaludos =>
      'Todavía no hay saludos. Desde una publicación o un comentario podés saludar a quien lo escribió.';

  @override
  String comunidadSaludoDe(String nombre) {
    return '$nombre te saluda';
  }

  @override
  String comunidadSaludoA(String nombre) {
    return 'Saludaste a $nombre';
  }

  @override
  String comunidadSobre(String texto) {
    return 'Sobre: «$texto»';
  }

  @override
  String get comunidadAceptarSaludo => 'Aceptar y abrir el chat';

  @override
  String get comunidadAhoraNo => 'Ahora no';

  @override
  String get comunidadEsperando => 'Esperando respuesta';

  @override
  String get comunidadNoAhora => 'No aceptó por ahora';

  @override
  String get equipoTitulo => 'Equipo';

  @override
  String get equipoAbrirAyuda =>
      'Sumá personas para que atiendan pedidos, turnos y el catálogo';

  @override
  String get equipoAyudaDuenio =>
      'Las personas del equipo atienden pedidos, turnos, paseos y estadías, socios, canjes y el catálogo. La ficha, el plan, las estadísticas y la configuración siguen siendo solo tuyos. Entre ustedes se ven solo el primer nombre.';

  @override
  String get equipoAyudaEmpleado =>
      'Sos parte del equipo de este negocio: atendés pedidos, turnos, paseos y estadías, socios, canjes y el catálogo. La ficha, el plan, las estadísticas y la configuración los maneja el dueño.';

  @override
  String get equipoSoloPlus => 'El equipo es del plan Plus.';

  @override
  String get equipoVacio => 'Todavía no sumaste a nadie.';

  @override
  String get equipoInvitar => 'Invitar a alguien';

  @override
  String equipoLleno(int n) {
    return 'El equipo ya tiene $n personas.';
  }

  @override
  String equipoDesde(String fecha) {
    return 'Desde el $fecha';
  }

  @override
  String get equipoQuitar => 'Sacar del equipo';

  @override
  String equipoQuitarPregunta(String nombre) {
    return '¿Sacar a $nombre del equipo? Va a dejar de ver los pedidos y la agenda del negocio.';
  }

  @override
  String get equipoIrme => 'Dejar el equipo';

  @override
  String equipoIrmePregunta(String negocio) {
    return '¿Dejar el equipo de $negocio? Para volver, el dueño te tiene que invitar de nuevo.';
  }

  @override
  String get equipoInvitaciones => 'Invitaciones sin usar';

  @override
  String equipoVence(String codigo, String fecha) {
    return '$codigo · vence el $fecha';
  }

  @override
  String get equipoAnular => 'Anular';

  @override
  String get equipoInvitacionTitulo => 'Invitación al equipo';

  @override
  String equipoInvitacionTexto(String codigo) {
    return 'Mandale este enlace a quien quieras sumar. Sirve una sola vez y vence en 7 días. También puede escribir el código en la app: $codigo';
  }

  @override
  String equipoMensajeInvitacion(String negocio, String enlace) {
    return 'Te invito al equipo de $negocio en Huellitas: $enlace';
  }

  @override
  String get equipoTengoCodigo => 'Tengo un código de equipo';

  @override
  String get equipoCodigo => 'Código o enlace';

  @override
  String get unirmeEquipoTitulo => 'Invitación a un equipo';

  @override
  String get unirmeEquipoTexto =>
      'Te invitaron a ser parte del equipo de un negocio en Huellitas. Vas a atender pedidos, turnos y el catálogo desde el modo comercio. El dueño y el equipo van a ver tu primer nombre (nunca tu correo).';

  @override
  String get unirmeEquipoBoton => 'Unirme al equipo';

  @override
  String get unirmeEquipoListo => '¡Listo! Ya sos parte del equipo.';

  @override
  String get equipoErrorCodigo =>
      'Este código no existe, ya se usó o venció. Pedile uno nuevo al dueño.';

  @override
  String get equipoErrorDuenio =>
      'Este código es de tu propio negocio: mandáselo a quien quieras sumar.';
}
