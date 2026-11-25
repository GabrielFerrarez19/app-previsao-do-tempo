/// Previsão completa retornada pela API de forecast do Open-Meteo.
class Previsao {
  final ClimaAtual atual;
  final List<PrevisaoHora> horas;
  final List<PrevisaoDia> dias;

  const Previsao({
    required this.atual,
    required this.horas,
    required this.dias,
  });

  factory Previsao.fromJson(Map<String, dynamic> json) {
    final atual = ClimaAtual.fromJson(json['current'] as Map<String, dynamic>);

    // Os dados horários e diários vêm em listas paralelas
    // (uma lista de horários, uma de temperaturas, etc.).
    final hourly = json['hourly'] as Map<String, dynamic>;
    final horasTime = hourly['time'] as List<dynamic>;
    final horas = <PrevisaoHora>[
      for (var i = 0; i < horasTime.length; i++)
        PrevisaoHora(
          hora: DateTime.parse(horasTime[i] as String),
          temperatura: _num(hourly['temperature_2m'], i),
          probabilidadeChuva: _num(hourly['precipitation_probability'], i),
          precipitacao: _num(hourly['precipitation'], i),
          chuva: _num(hourly['rain'], i),
        ),
    ];

    final daily = json['daily'] as Map<String, dynamic>;
    final diasTime = daily['time'] as List<dynamic>;
    final dias = <PrevisaoDia>[
      for (var i = 0; i < diasTime.length; i++)
        PrevisaoDia(
          data: DateTime.parse(diasTime[i] as String),
          maxima: _num(daily['temperature_2m_max'], i),
          minima: _num(daily['temperature_2m_min'], i),
          precipitacaoTotal: _num(daily['precipitation_sum'], i),
          probabilidadeChuvaMax: _num(
            daily['precipitation_probability_max'],
            i,
          ),
          codigoTempo: _num(daily['weather_code'], i).toInt(),
        ),
    ];

    return Previsao(atual: atual, horas: horas, dias: dias);
  }

  /// Próximas [quantidade] horas a partir da hora atual da medição.
  List<PrevisaoHora> proximasHoras([int quantidade = 24]) {
    final inicio = DateTime(
      atual.hora.year,
      atual.hora.month,
      atual.hora.day,
      atual.hora.hour,
    );
    return horas
        .where((h) => !h.hora.isBefore(inicio))
        .take(quantidade)
        .toList();
  }
}

/// Lê o valor da posição [i] de uma lista do JSON (valores podem ser null).
double _num(dynamic lista, int i) {
  if (lista is! List || i >= lista.length || lista[i] == null) return 0;
  return (lista[i] as num).toDouble();
}

class ClimaAtual {
  final DateTime hora;
  final double temperatura;
  final double umidade;
  final double precipitacao;
  final double chuva;
  final double vento;
  final int codigoTempo;

  const ClimaAtual({
    required this.hora,
    required this.temperatura,
    required this.umidade,
    required this.precipitacao,
    required this.chuva,
    required this.vento,
    required this.codigoTempo,
  });

  factory ClimaAtual.fromJson(Map<String, dynamic> json) {
    double n(String chave) => (json[chave] as num?)?.toDouble() ?? 0;
    return ClimaAtual(
      hora: DateTime.parse(json['time'] as String),
      temperatura: n('temperature_2m'),
      umidade: n('relative_humidity_2m'),
      precipitacao: n('precipitation'),
      chuva: n('rain'),
      vento: n('wind_speed_10m'),
      codigoTempo: n('weather_code').toInt(),
    );
  }
}

class PrevisaoHora {
  final DateTime hora;
  final double temperatura;
  final double probabilidadeChuva;
  final double precipitacao;
  final double chuva;

  const PrevisaoHora({
    required this.hora,
    required this.temperatura,
    required this.probabilidadeChuva,
    required this.precipitacao,
    required this.chuva,
  });
}

class PrevisaoDia {
  final DateTime data;
  final double maxima;
  final double minima;
  final double precipitacaoTotal;
  final double probabilidadeChuvaMax;
  final int codigoTempo;

  const PrevisaoDia({
    required this.data,
    required this.maxima,
    required this.minima,
    required this.precipitacaoTotal,
    required this.probabilidadeChuvaMax,
    required this.codigoTempo,
  });
}
