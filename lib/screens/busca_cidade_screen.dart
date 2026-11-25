import 'package:flutter/material.dart';

import '../models/cidade.dart';
import '../services/open_meteo_service.dart';
import 'previsao_screen.dart';

/// Tela inicial: o usuário digita o nome da cidade e escolhe um resultado.
class BuscaCidadeScreen extends StatefulWidget {
  const BuscaCidadeScreen({super.key});

  @override
  State<BuscaCidadeScreen> createState() => _BuscaCidadeScreenState();
}

class _BuscaCidadeScreenState extends State<BuscaCidadeScreen> {
  final _service = OpenMeteoService();
  final _controller = TextEditingController();

  // null = nenhuma busca feita ainda
  Future<List<Cidade>>? _futureCidades;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _buscar() {
    final nome = _controller.text.trim();
    if (nome.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite pelo menos 2 letras.')),
      );
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _futureCidades = _service.buscarCidades(nome);
    });
  }

  void _abrirPrevisao(Cidade cidade) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PrevisaoScreen(cidade: cidade, service: _service),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Previsão do Tempo')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => _buscar(),
                    decoration: const InputDecoration(
                      labelText: 'Cidade',
                      hintText: 'Ex.: São Sebastião do Paraíso',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: _buscar,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
              ],
            ),
          ),
          Expanded(child: _resultado()),
        ],
      ),
    );
  }

  Widget _resultado() {
    if (_futureCidades == null) {
      return const _Mensagem(
        icone: Icons.travel_explore,
        texto: 'Busque uma cidade para ver a previsão do tempo.',
      );
    }

    return FutureBuilder<List<Cidade>>(
      future: _futureCidades,
      builder: (context, snapshot) {
        // 1) Carregando
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // 2) Erro
        if (snapshot.hasError) {
          return _Mensagem(
            icone: Icons.cloud_off,
            cor: Theme.of(context).colorScheme.error,
            texto: 'Erro: ${snapshot.error}',
            acao: FilledButton.icon(
              onPressed: _buscar,
              icon: const Icon(Icons.refresh),
              label: const Text('Tentar novamente'),
            ),
          );
        }

        // 3) Lista vazia
        final cidades = snapshot.data ?? [];
        if (cidades.isEmpty) {
          return const _Mensagem(
            icone: Icons.search_off,
            texto: 'Nenhuma cidade encontrada.',
          );
        }

        // 4) Dados
        return ListView.separated(
          itemCount: cidades.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final cidade = cidades[index];
            return ListTile(
              leading: const Icon(Icons.place),
              title: Text(cidade.nome),
              subtitle: Text(cidade.descricao),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _abrirPrevisao(cidade),
            );
          },
        );
      },
    );
  }
}

class _Mensagem extends StatelessWidget {
  final IconData icone;
  final String texto;
  final Color? cor;
  final Widget? acao;

  const _Mensagem({
    required this.icone,
    required this.texto,
    this.cor,
    this.acao,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icone, size: 64, color: cor ?? Colors.grey),
            const SizedBox(height: 16),
            Text(texto, textAlign: TextAlign.center),
            if (acao != null) ...[const SizedBox(height: 16), acao!],
          ],
        ),
      ),
    );
  }
}
