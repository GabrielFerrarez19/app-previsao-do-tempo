import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:previsao_tempo/models/cidade.dart';
import 'package:previsao_tempo/services/open_meteo_service.dart';

/// Respostas reais das APIs salvas em test/fixtures.
String _fixture(String nome) => File('test/fixtures/$nome').readAsStringSync();

http.Response _json(String corpo, [int status = 200]) => http.Response.bytes(
  utf8.encode(corpo),
  status,
  headers: {'content-type': 'application/json'},
);

void main() {
  test('buscarCidades converte a resposta da geocodificação', () async {
    final service = OpenMeteoService(
      client: MockClient((req) async {
        expect(req.url.host, 'geocoding-api.open-meteo.com');
        expect(req.url.queryParameters['name'], 'Sao Sebastiao do Paraiso');
        return _json(_fixture('geocoding.json'));
      }),
    );

    final cidades = await service.buscarCidades('Sao Sebastiao do Paraiso');

    expect(cidades, isNotEmpty);
    expect(cidades.first.nome, 'São Sebastião do Paraíso');
    expect(cidades.first.estado, 'Minas Gerais');
    expect(cidades.first.descricao, 'Minas Gerais, Brasil');
  });

  test('buscarCidades retorna lista vazia quando não há "results"', () async {
    final service = OpenMeteoService(
      client: MockClient((_) async => _json('{"generationtime_ms":0.1}')),
    );
    expect(await service.buscarCidades('xyzxyz'), isEmpty);
  });

  test('buscarPrevisao converte clima atual, horas e dias', () async {
    final service = OpenMeteoService(
      client: MockClient((req) async {
        expect(req.url.host, 'api.open-meteo.com');
        return _json(_fixture('forecast.json'));
      }),
    );
    const cidade = Cidade(
      id: 1,
      nome: 'São Sebastião do Paraíso',
      latitude: -20.917101,
      longitude: -46.991779,
    );

    final previsao = await service.buscarPrevisao(cidade);

    expect(previsao.dias, hasLength(7));
    expect(previsao.horas, hasLength(7 * 24));
    expect(previsao.proximasHoras(), hasLength(24));
    expect(previsao.proximasHoras().first.hora.hour, previsao.atual.hora.hour);
    for (final d in previsao.dias) {
      expect(d.maxima, greaterThanOrEqualTo(d.minima));
    }
  });

  test('erro HTTP vira ApiException com o motivo', () async {
    final service = OpenMeteoService(
      client: MockClient(
        (_) async => _json('{"error":true,"reason":"Latitude inválida"}', 400),
      ),
    );
    expect(
      () => service.buscarCidades('abc'),
      throwsA(
        isA<ApiException>().having(
          (e) => e.mensagem,
          'mensagem',
          contains('Latitude inválida'),
        ),
      ),
    );
  });
}
