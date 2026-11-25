import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/cidade.dart';
import '../models/previsao.dart';
import '../services/open_meteo_service.dart';
import '../widgets/codigo_tempo.dart';

/// Mostra o clima atual, as próximas 24 horas e os próximos 7 dias.
class PrevisaoScreen extends StatefulWidget {
  final Cidade cidade;
  final OpenMeteoService service;

  const PrevisaoScreen({
    super.key,
    required this.cidade,
    required this.service,
  });

  @override
  State<PrevisaoScreen> createState() => _PrevisaoScreenState();
}

class _PrevisaoScreenState extends State<PrevisaoScreen> {
  late Future<Previsao> _futurePrevisao;

  @override
  void initState() {
    super.initState();
    _futurePrevisao = widget.service.buscarPrevisao(widget.cidade);
  }

  Future<void> _recarregar() async {
    final futuro = widget.service.buscarPrevisao(widget.cidade);
    setState(() => _futurePrevisao = futuro);
    try {
      await futuro;
    } catch (_) {
      // O erro é exibido pelo FutureBuilder.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.cidade.nome),
        actions: [
          IconButton(
            onPressed: _recarregar,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: FutureBuilder<Previsao>(
        future: _futurePrevisao,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.cloud_off,
                      size: 64,
                      color: Theme.of(context).colorScheme.error,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erro: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: _recarregar,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              ),
            );
          }

          final previsao = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _recarregar,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _CardAtual(cidade: widget.cidade, atual: previsao.atual),
                const SizedBox(height: 24),
                const _Titulo('Próximas 24 horas'),
                _ListaHoras(horas: previsao.proximasHoras()),
                const SizedBox(height: 24),
                const _Titulo('Próximos dias'),
                ...previsao.dias.map((d) => _ItemDia(dia: d)),
              ],
            ),
          );
        },
      ),
    );
  }
}

String _fmt(double v, [int casas = 0]) =>
    v.toStringAsFixed(casas).replaceAll('.', ',');

class _Titulo extends StatelessWidget {
  final String texto;
  const _Titulo(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(texto, style: Theme.of(context).textTheme.titleMedium),
    );
  }
}

class _CardAtual extends StatelessWidget {
  final Cidade cidade;
  final ClimaAtual atual;

  const _CardAtual({required this.cidade, required this.atual});

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);
    final info = infoTempo(atual.codigoTempo);

    return Card(
      color: tema.colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(cidade.descricao, style: tema.textTheme.bodyMedium),
            Text(
              'Atualizado às ${DateFormat.Hm().format(atual.hora)}',
              style: tema.textTheme.bodySmall,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(info.icone, size: 56),
                const SizedBox(width: 12),
                Text(
                  '${_fmt(atual.temperatura, 1)} °C',
                  style: tema.textTheme.displayMedium,
                ),
              ],
            ),
            Text(info.descricao, style: tema.textTheme.titleMedium),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 24,
              runSpacing: 12,
              children: [
                _Dado(
                  icone: Icons.water_drop_outlined,
                  rotulo: 'Umidade',
                  valor: '${_fmt(atual.umidade)}%',
                ),
                _Dado(
                  icone: Icons.air,
                  rotulo: 'Vento',
                  valor: '${_fmt(atual.vento, 1)} km/h',
                ),
                _Dado(
                  icone: Icons.grain,
                  rotulo: 'Precipitação',
                  valor: '${_fmt(atual.precipitacao, 1)} mm',
                ),
                _Dado(
                  icone: Icons.umbrella,
                  rotulo: 'Chuva',
                  valor: '${_fmt(atual.chuva, 1)} mm',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Dado extends StatelessWidget {
  final IconData icone;
  final String rotulo;
  final String valor;

  const _Dado({required this.icone, required this.rotulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icone),
        Text(valor, style: const TextStyle(fontWeight: FontWeight.bold)),
        Text(rotulo, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}

class _ListaHoras extends StatelessWidget {
  final List<PrevisaoHora> horas;
  const _ListaHoras({required this.horas});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: horas.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final h = horas[index];
          return Card(
            margin: EdgeInsets.zero,
            child: Container(
              width: 80,
              padding: const EdgeInsets.all(8),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(index == 0 ? 'Agora' : DateFormat.Hm().format(h.hora)),
                  Text(
                    '${_fmt(h.temperatura)}°',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.umbrella, size: 14, color: Colors.blue),
                      Text(' ${_fmt(h.probabilidadeChuva)}%'),
                    ],
                  ),
                  Text(
                    '${_fmt(h.precipitacao, 1)} mm',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ItemDia extends StatelessWidget {
  final PrevisaoDia dia;
  const _ItemDia({required this.dia});

  @override
  Widget build(BuildContext context) {
    final info = infoTempo(dia.codigoTempo);
    final hoje = DateTime.now();
    final ehHoje =
        dia.data.year == hoje.year &&
        dia.data.month == hoje.month &&
        dia.data.day == hoje.day;
    final nomeDia = ehHoje
        ? 'Hoje'
        : DateFormat('EEE, dd/MM', 'pt_BR').format(dia.data);

    return Card(
      child: ListTile(
        leading: Icon(info.icone, size: 32),
        title: Text(nomeDia),
        subtitle: Text(
          '${info.descricao}\n'
          'Chuva: ${_fmt(dia.probabilidadeChuvaMax)}% · ${_fmt(dia.precipitacaoTotal, 1)} mm',
        ),
        isThreeLine: true,
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${_fmt(dia.maxima)}°',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
                fontSize: 16,
              ),
            ),
            Text(
              '${_fmt(dia.minima)}°',
              style: const TextStyle(color: Colors.blue, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
