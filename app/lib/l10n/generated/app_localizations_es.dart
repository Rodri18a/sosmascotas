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
  String get sosDescripcion => 'Reportá una mascota perdida o encontrada';

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
      'Al ingresar vas a poder leer y aceptar los términos y la política de privacidad de SOS Mascota.';

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
}
