import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/cidade.dart';
import '../models/previsao.dart';

/// Exceção própria para erros de comunicação com a API.
class ApiException implements Exception {
  final String mensagem;
  const ApiException(this.mensagem);

  @override
  String toString() => mensagem;
}

/// Serviço que consulta as APIs do Open-Meteo.
class OpenMeteoService {
  static const _timeout = Duration(seconds: 10);

  final http.Client _client;
  OpenMeteoService({http.Client? client}) : _client = client ?? http.Client();

  /// Busca cidades pelo nome.
  /// API: https://geocoding-api.open-meteo.com/v1/search
  Future<List<Cidade>> buscarCidades(String nome) async {
    final url = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
      'name': nome,
      'count': '10',
      'language': 'pt',
      'format': 'json',
    });

    final json = await _get(url);
    // Quando nenhuma cidade é encontrada a API não envia "results".
    final resultados = json['results'] as List<dynamic>? ?? [];
    return resultados
        .map((item) => Cidade.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Busca a previsão do tempo para a cidade informada.
  /// API: https://api.open-meteo.com/v1/forecast
  Future<Previsao> buscarPrevisao(Cidade cidade) async {
    final url = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': cidade.latitude.toString(),
      'longitude': cidade.longitude.toString(),
      'current': 'temperature_2m,relative_humidity_2m,precipitation,rain,wind_speed_10m,weather_code',
      'hourly': 'temperature_2m,precipitation_probability,precipitation,rain',
      'daily': 'temperature_2m_max,temperature_2m_min,precipitation_sum,precipitation_probability_max,weather_code',
      'timezone': 'America/Sao_Paulo',
    });

    final json = await _get(url);
    return Previsao.fromJson(json);
  }

  Future<Map<String, dynamic>> _get(Uri url) async {
    final http.Response response;
    try {
      response = await _client.get(url).timeout(_timeout);
    } on TimeoutException {
      throw const ApiException('O servidor demorou para responder.');
    } on http.ClientException {
      throw const ApiException(
        'Não foi possível conectar ao servidor. Verifique sua internet.',
      );
    }

    final dynamic corpo;
    try {
      corpo = jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw ApiException('Resposta inválida (HTTP ${response.statusCode}).');
    }
    if (response.statusCode != 200) {
      final motivo = corpo is Map && corpo['reason'] != null
          ? ': ${corpo['reason']}'
          : '';
      throw ApiException('Erro ${response.statusCode}$motivo');
    }
    return corpo as Map<String, dynamic>;
  }
}
