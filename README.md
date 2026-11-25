# Previsão do Tempo

App em Flutter que busca uma cidade e mostra a previsão do tempo usando as APIs gratuitas do [Open-Meteo](https://open-meteo.com/) (não precisa de chave).

Atividade avaliativa da aula **009 – APIs Remotas**.

## Funcionalidades

- **Busca de cidade** pelo nome (até 10 resultados, em português), com estado e país.
- **Clima atual**: temperatura, condição do tempo, umidade, vento, precipitação e chuva.
- **Próximas 24 horas**: temperatura, probabilidade de chuva e precipitação.
- **Próximos 7 dias**: máxima, mínima, probabilidade máxima de chuva e precipitação total.
- Estados de **carregando**, **erro** (com botão *Tentar novamente*) e **nenhum resultado**.
- *Pull-to-refresh* e botão de atualizar na tela de previsão.

## APIs utilizadas

| Uso | Endpoint |
| --- | --- |
| Geocodificação | `https://geocoding-api.open-meteo.com/v1/search?name={cidade}&count=10&language=pt&format=json` |
| Previsão | `https://api.open-meteo.com/v1/forecast?latitude={lat}&longitude={lon}&current=...&hourly=...&daily=...&timezone=America/Sao_Paulo` |

Na previsão são pedidos os mesmos campos do enunciado, mais `weather_code` (para mostrar ícone e descrição do tempo).

## Estrutura

```
lib/
├── main.dart                         # inicialização do app
├── models/
│   ├── cidade.dart                   # model da geocodificação
│   └── previsao.dart                 # models do clima atual, por hora e por dia
├── services/
│   └── open_meteo_service.dart       # chamadas HTTP + ApiException
├── screens/
│   ├── busca_cidade_screen.dart      # busca e lista de cidades
│   └── previsao_screen.dart          # previsão da cidade escolhida
└── widgets/
    └── codigo_tempo.dart             # código WMO → descrição e ícone
```

## Como rodar

```bash
flutter pub get
flutter run
```

## Testes

```bash
flutter test
```

Os testes usam respostas reais das APIs salvas em `test/fixtures/` e um `MockClient`, então rodam sem internet.
