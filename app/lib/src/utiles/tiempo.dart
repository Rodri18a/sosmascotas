import '../../l10n/l10n.dart';

/// "hace 5 minutos", "hace 3 horas", "hace 2 días", "el 3/10".
String textoHace(AppLocalizations t, DateTime fecha, {DateTime? ahora}) {
  final diferencia = (ahora ?? DateTime.now()).difference(fecha);
  if (diferencia.inMinutes < 1) return t.haceUnMomento;
  if (diferencia.inHours < 1) return t.haceMinutos(diferencia.inMinutes);
  if (diferencia.inDays < 1) return t.haceHoras(diferencia.inHours);
  if (diferencia.inDays < 30) return t.haceDias(diferencia.inDays);
  return t.elDia(fecha.day, fecha.month);
}
