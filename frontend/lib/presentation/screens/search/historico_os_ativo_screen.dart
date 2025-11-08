import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tcc/data/models/ordem_servico.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class HistoricoOsAtivoScreen extends StatefulWidget {
  final String ativoId;
  final String ativoNome;

  const HistoricoOsAtivoScreen(
      {super.key, required this.ativoId, required this.ativoNome});

  @override
  State<HistoricoOsAtivoScreen> createState() => _HistoricoOsAtivoScreenState();
}

class _HistoricoOsAtivoScreenState extends State<HistoricoOsAtivoScreen> {
  bool _isLoading = true;
  List<OrdemServico> _historico = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchHistorico();
  }

  // Função para buscar o histórico de O.S. finalizadas na API
  Future<void> _fetchHistorico() async {
    final String apiUrl =
        'http://localhost:8000/api/ativos/${widget.ativoId}/historico/';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        setState(() {
          _historico = data.map((item) => OrdemServico.fromJson(item)).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Falha ao carregar o histórico.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Não foi possível conectar ao servidor.';
        _isLoading = false;
      });
    }
  }

  // Função auxiliar para formatar a Duração em "HH:MM:SS"
  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "${twoDigits(duration.inHours)}:$twoDigitMinutes:$twoDigitSeconds";
  }

  // Widget ATUALIZADO para mostrar um card com todos os detalhes da manutenção
  Widget _buildHistoricoCard(OrdemServico os) {
    final dateFormatter = DateFormat('dd/MM/yyyy HH:mm');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título da Ordem de Serviço
            Text(os.titulo,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Tipo: ${os.tipoManutencao}',
                style: const TextStyle(color: Colors.grey, fontStyle: FontStyle.italic)),

            // Mostra os detalhes da manutenção apenas se existirem
            if (os.manutencao != null) ...[
              const Divider(height: 24),
              const Text('Detalhes da Execução',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                    'Executor: Técnico 02'),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.timer_outlined, size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text('Tempo Gasto: ${_formatDuration(os.manutencao!.tempoGasto)}'),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.play_arrow_outlined,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                    'Início: ${dateFormatter.format(os.manutencao!.dataInicioExecucao.toLocal())}'),
              ]),
              const SizedBox(height: 8),
              Row(children: [
                const Icon(Icons.check_circle_outline,
                    size: 16, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                    'Fim: ${dateFormatter.format(os.manutencao!.dataFimExecucao.toLocal())}'),
              ]),

              // Mostra as observações apenas se existirem
              if (os.manutencao!.observacoes != null &&
                  os.manutencao!.observacoes!.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Text('Observações:',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(os.manutencao!.observacoes!),
              ]
            ] else
              const Padding(
                padding: EdgeInsets.only(top: 16.0),
                child: Text('Detalhes da manutenção não disponíveis.'),
              ),
          ],
        ),
      ),
    );
  }

  // Constrói o corpo da tela com base no estado (loading, erro, etc.)
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
          child: Text(_errorMessage!,
              style: const TextStyle(color: Colors.red)));
    }
    if (_historico.isEmpty) {
      return const Center(
          child: Text('Nenhum histórico de manutenção para este ativo.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 16),
      itemCount: _historico.length,
      itemBuilder: (context, index) {
        return _buildHistoricoCard(_historico[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Histórico de ${widget.ativoNome}'),
        backgroundColor: const Color(0xFF12385D),
        foregroundColor: Colors.white,
      ),
      body: _buildBody(),
    );
  }
}

