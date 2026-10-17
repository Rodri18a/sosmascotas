import 'mascota.dart';

/// Tipo de recordatorio (valores iguales a la base: `reminders.kind`).
enum TipoRecordatorio { medication, food, vaccine, checkup }

/// Hora del día de un recordatorio, en la hora local del dispositivo.
class HoraDelDia implements Comparable<HoraDelDia> {
  const HoraDelDia(this.hora, this.minuto)
    : assert(hora >= 0 && hora < 24),
      assert(minuto >= 0 && minuto < 60);

  /// `08:30` → 8:30. Devuelve `null` si el texto no es una hora válida.
  static HoraDelDia? leer(Object? texto) {
    if (texto is! String) return null;
    final m = RegExp(r'^([01][0-9]|2[0-3]):([0-5][0-9])$').firstMatch(texto);
    if (m == null) return null;
    return HoraDelDia(int.parse(m[1]!), int.parse(m[2]!));
  }

  final int hora;
  final int minuto;

  String get texto =>
      '${hora.toString().padLeft(2, '0')}:${minuto.toString().padLeft(2, '0')}';

  DateTime en(DateTime dia) =>
      DateTime(dia.year, dia.month, dia.day, hora, minuto);

  @override
  int compareTo(HoraDelDia otra) =>
      (hora * 60 + minuto) - (otra.hora * 60 + otra.minuto);

  @override
  bool operator ==(Object other) =>
      other is HoraDelDia && other.hora == hora && other.minuto == minuto;

  @override
  int get hashCode => Object.hash(hora, minuto);

  @override
  String toString() => texto;
}

/// Cada cuánto suena un recordatorio (columna `reminders.schedule`).
sealed class Frecuencia {
  const Frecuencia();

  /// Lee el JSON de la base. Devuelve `null` si no es válido.
  static Frecuencia? leer(Object? json) {
    if (json is! Map) return null;
    List<HoraDelDia>? horarios() {
      final lista = json['horarios'];
      if (lista is! List || lista.isEmpty || lista.length > 12) return null;
      final horas = lista.map(HoraDelDia.leer).toList();
      if (horas.contains(null)) return null;
      return (horas.cast<HoraDelDia>().toSet().toList())..sort();
    }

    switch (json['tipo']) {
      case 'cada_horas':
        final horas = json['horas'];
        return horas is int && horas >= 1 && horas <= 72
            ? CadaHoras(horas)
            : null;
      case 'diaria':
        final h = horarios();
        return h == null ? null : Diaria(h);
      case 'semanal':
        final h = horarios();
        final dias = json['dias'];
        if (h == null || dias is! List || dias.isEmpty) return null;
        if (dias.any((d) => d is! int || d < 1 || d > 7)) return null;
        return Semanal(dias.cast<int>().toSet(), h);
      case 'una_vez':
        return const UnaVez();
    }
    return null;
  }

  Map<String, Object?> toJson();
}

/// Cada [horas] horas, desde la primera toma (`starts_at`).
class CadaHoras extends Frecuencia {
  const CadaHoras(this.horas);
  final int horas;

  @override
  Map<String, Object?> toJson() => {'tipo': 'cada_horas', 'horas': horas};
}

/// Todos los días a los [horarios].
class Diaria extends Frecuencia {
  const Diaria(this.horarios);
  final List<HoraDelDia> horarios;

  @override
  Map<String, Object?> toJson() => {
    'tipo': 'diaria',
    'horarios': [for (final h in horarios) h.texto],
  };
}

/// Los [dias] de la semana (1 = lunes … 7 = domingo) a los [horarios].
class Semanal extends Frecuencia {
  const Semanal(this.dias, this.horarios);
  final Set<int> dias;
  final List<HoraDelDia> horarios;

  @override
  Map<String, Object?> toJson() => {
    'tipo': 'semanal',
    'dias': dias.toList()..sort(),
    'horarios': [for (final h in horarios) h.texto],
  };
}

/// Una sola vez, en `starts_at` (vacunas y controles, paso 1.5.4).
class UnaVez extends Frecuencia {
  const UnaVez();

  @override
  Map<String, Object?> toJson() => {'tipo': 'una_vez'};
}

/// Recordatorio de una mascota (tabla `reminders`, paso 1.5.3).
class Recordatorio {
  const Recordatorio({
    required this.id,
    required this.mascotaId,
    required this.tipo,
    required this.titulo,
    required this.frecuencia,
    required this.inicio,
    this.dosis,
    this.fin,
    this.activo = true,
  });

  /// Devuelve `null` si la fila no se puede usar (frecuencia inválida).
  static Recordatorio? fromJson(Map<String, Object?> json) {
    final frecuencia = Frecuencia.leer(json['schedule']);
    if (frecuencia == null) return null;
    return Recordatorio(
      id: json['id']! as String,
      mascotaId: json['pet_id']! as String,
      tipo:
          TipoRecordatorio.values.asNameMap()[json['kind']] ??
          TipoRecordatorio.medication,
      titulo: json['title']! as String,
      dosis: json['dose'] as String?,
      frecuencia: frecuencia,
      inicio: DateTime.parse(json['starts_at']! as String).toLocal(),
      fin: switch (json['ends_on']) {
        final String fecha => DateTime.parse(fecha),
        _ => null,
      },
      activo: json['active'] as bool? ?? true,
    );
  }

  final String id;
  final String mascotaId;
  final TipoRecordatorio tipo;
  final String titulo;
  final String? dosis;
  final Frecuencia frecuencia;

  /// Primera toma (o el momento, si es una sola vez). Hora local.
  final DateTime inicio;

  /// Último día (inclusive) en que suena, o `null` si no termina.
  final DateTime? fin;
  final bool activo;

  /// Columnas editables (sin `id`, que pone la base).
  Map<String, Object?> toJson() {
    final dosisLimpia = dosis?.trim();
    return {
      'pet_id': mascotaId,
      'kind': tipo.name,
      'title': titulo.trim(),
      'dose': dosisLimpia == null || dosisLimpia.isEmpty ? null : dosisLimpia,
      'schedule': frecuencia.toJson(),
      'starts_at': inicio.toUtc().toIso8601String(),
      'ends_on': fin == null ? null : fechaIso(fin!),
      'active': activo,
    };
  }

  Recordatorio copyWith({bool? activo}) => Recordatorio(
    id: id,
    mascotaId: mascotaId,
    tipo: tipo,
    titulo: titulo,
    dosis: dosis,
    frecuencia: frecuencia,
    inicio: inicio,
    fin: fin,
    activo: activo ?? this.activo,
  );

  bool _antesDelFin(DateTime momento) {
    final f = fin;
    return f == null || momento.isBefore(DateTime(f.year, f.month, f.day + 1));
  }

  /// Tomas desde [desde] (inclusive) hasta [hasta] (exclusive), en orden.
  /// Un recordatorio pausado no tiene tomas.
  List<DateTime> tomasEntre(DateTime desde, DateTime hasta) {
    if (!activo || !hasta.isAfter(desde)) return const [];
    final tomas = <DateTime>[];
    bool sirve(DateTime t) =>
        !t.isBefore(desde) &&
        t.isBefore(hasta) &&
        !t.isBefore(inicio) &&
        _antesDelFin(t);

    switch (frecuencia) {
      case CadaHoras(:final horas):
        final paso = Duration(hours: horas);
        var t = inicio;
        if (desde.isAfter(inicio)) {
          final saltos = (desde.difference(inicio).inMinutes / paso.inMinutes)
              .ceil();
          t = inicio.add(paso * saltos);
        }
        while (t.isBefore(hasta) && _antesDelFin(t)) {
          if (sirve(t)) tomas.add(t);
          t = t.add(paso);
        }
      case Diaria(:final horarios):
        _porDia(desde, hasta, (_) => true, horarios, sirve, tomas);
      case Semanal(:final dias, :final horarios):
        _porDia(
          desde,
          hasta,
          (d) => dias.contains(d.weekday),
          horarios,
          sirve,
          tomas,
        );
      case UnaVez():
        if (sirve(inicio)) tomas.add(inicio);
    }
    return tomas;
  }

  void _porDia(
    DateTime desde,
    DateTime hasta,
    bool Function(DateTime dia) diaSirve,
    List<HoraDelDia> horarios,
    bool Function(DateTime) sirve,
    List<DateTime> tomas,
  ) {
    final arranque = desde.isAfter(inicio) ? desde : inicio;
    var dia = DateTime(arranque.year, arranque.month, arranque.day);
    while (dia.isBefore(hasta) && _antesDelFin(dia)) {
      if (diaSirve(dia)) {
        for (final h in horarios) {
          final t = h.en(dia);
          if (sirve(t)) tomas.add(t);
        }
      }
      dia = DateTime(dia.year, dia.month, dia.day + 1);
    }
  }

  /// La próxima toma desde [ahora] (inclusive), o `null` si ya terminó.
  DateTime? proximaToma(DateTime ahora) {
    final desde = ahora.isAfter(inicio) ? ahora : inicio;
    // Ocho días alcanzan para cualquier frecuencia diaria o semanal; las
    // demás se calculan directo.
    final hasta = switch (frecuencia) {
      CadaHoras(:final horas) => desde.add(Duration(hours: horas + 1)),
      UnaVez() => inicio.add(const Duration(minutes: 1)),
      _ => desde.add(const Duration(days: 8)),
    };
    return tomasEntre(desde, hasta).firstOrNull;
  }
}

/// Resultado de validar un recordatorio antes de guardarlo.
enum ValidacionRecordatorio {
  valido,
  sinTitulo,
  tituloLargo,
  sinHorarios,
  sinDias,
  finAntesDelInicio,
}

ValidacionRecordatorio validarRecordatorio({
  required String titulo,
  required Frecuencia frecuencia,
  required DateTime inicio,
  DateTime? fin,
}) {
  final limpio = titulo.trim();
  if (limpio.isEmpty) return ValidacionRecordatorio.sinTitulo;
  if (limpio.length > 80) return ValidacionRecordatorio.tituloLargo;
  switch (frecuencia) {
    case Diaria(:final horarios) when horarios.isEmpty:
      return ValidacionRecordatorio.sinHorarios;
    case Semanal(:final horarios) when horarios.isEmpty:
      return ValidacionRecordatorio.sinHorarios;
    case Semanal(:final dias) when dias.isEmpty:
      return ValidacionRecordatorio.sinDias;
    default:
  }
  if (fin != null &&
      DateTime(
        fin.year,
        fin.month,
        fin.day,
      ).isBefore(DateTime(inicio.year, inicio.month, inicio.day))) {
    return ValidacionRecordatorio.finAntesDelInicio;
  }
  return ValidacionRecordatorio.valido;
}

/// Una toma marcada como hecha ("✅ Ya se la di", tabla `reminder_logs`,
/// paso 1.5.5).
class TomaHecha {
  const TomaHecha({
    required this.id,
    required this.recordatorioId,
    required this.prevista,
    required this.hecha,
  });

  factory TomaHecha.fromJson(Map<String, Object?> json) => TomaHecha(
    id: json['id']! as String,
    recordatorioId: json['reminder_id']! as String,
    prevista: DateTime.parse(json['due_at']! as String).toLocal(),
    hecha: DateTime.parse(json['done_at']! as String).toLocal(),
  );

  final String id;
  final String recordatorioId;

  /// La toma que se marcó (hora local).
  final DateTime prevista;

  /// Cuándo se marcó (hora local).
  final DateTime hecha;
}

/// Desde cuánto antes de la hora se puede marcar una toma.
const anticipoToma = Duration(minutes: 30);

/// Hasta cuánto después se sigue ofreciendo una toma sin marcar.
const esperaToma = Duration(hours: 12);

/// La toma que toca marcar ahora: la más reciente entre las últimas 12 h y
/// los próximos 30 minutos que todavía no se marcó. `null` si no hay ninguna.
DateTime? tomaPendiente(
  Recordatorio recordatorio,
  DateTime ahora,
  Iterable<TomaHecha> hechas,
) {
  final marcadas = {
    for (final h in hechas)
      if (h.recordatorioId == recordatorio.id)
        h.prevista.millisecondsSinceEpoch,
  };
  return recordatorio
      // +1 µs: la que es justo dentro de 30 minutos también cuenta.
      .tomasEntre(
        ahora.subtract(esperaToma),
        ahora.add(anticipoToma + const Duration(microseconds: 1)),
      )
      .where((t) => !marcadas.contains(t.millisecondsSinceEpoch))
      .lastOrNull;
}
