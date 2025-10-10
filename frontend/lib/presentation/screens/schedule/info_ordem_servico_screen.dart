import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tcc/data/models/ordem_servico.dart';
import 'package:flutter_tcc/presentation/screens/schedule/iniciar_ordem_servico_screen.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class InfoOrdemServicoScreen extends StatefulWidget {
  // A tela agora recebe apenas o ID da O.S. que precisa de buscar
  final int ordemServicoId;

  const InfoOrdemServicoScreen({super.key, required this.ordemServicoId});

  @override
  State<InfoOrdemServicoScreen> createState() => _InfoOrdemServicoScreenState();
}

class _InfoOrdemServicoScreenState extends State<InfoOrdemServicoScreen> {
  // Variáveis de estado para gerir a UI
  bool _isLoading = true;
  OrdemServico? _ordemServico;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrdemServicoDetails();
  }

  // Função para buscar os detalhes da O.S. na API
  Future<void> _fetchOrdemServicoDetails() async {
    final String apiUrl =
        'http://localhost:8000/api/ordens-servico/${widget.ordemServicoId}/';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        setState(() {
          _ordemServico = OrdemServico.fromJson(data);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Falha ao carregar os detalhes da O.S.';
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

  // Constrói o corpo da tela com base no estado
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }
    if (_ordemServico == null) {
      return const Center(child: Text('Ordem de Serviço não encontrada.'));
    }

    // Se os dados foram carregados, constrói a UI com as informações
    final os = _ordemServico!;
    final dateFormatter = DateFormat('dd/MM/yyyy');

    final statusData = {
      StatusOS.pendente: {
        'text': 'Pendente',
        'color': Colors.orange.shade800},
      StatusOS.finalizada: {
        'text': 'Finalizada',
        'color': Colors.green.shade800,
      },
      StatusOS.cancelada: {
        'text': 'Cancelada', 
        'color': Colors.grey.shade600},
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            os.titulo,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildTag(
                statusData[os.status]!['text'] as String,
                statusData[os.status]!['color'] as Color,
              ),
              const SizedBox(width: 12),
            ],
          ),
          const Divider(height: 32),
          _buildInfoRow('Ativo Relacionado', os.ativo),
          _buildInfoRow('Tipo de Manutenção', os.tipoManutencao),
          _buildInfoRow('Data Prevista', dateFormatter.format(os.dataPrevista)),
          _buildInfoRow(
            'Solicitante',
            os.usuarioSolicitante ?? 'Não informado',
          ),
          _buildInfoRow(
            'Data da Solicitação',
            dateFormatter.format(os.dataCriacao),
          ),
          if (os.descricao != null && os.descricao!.isNotEmpty)
            _buildInfoRow('Descrição', os.descricao!),
        ],
      ),
    );
  }

  // --- Widgets Auxiliares ---
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.black87, fontSize: 18),
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color, width: 1),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF12385D);
    return Scaffold(
      appBar: AppBar(
        title: Text('O.S. #${widget.ordemServicoId}'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(), // O corpo agora é dinâmico
      persistentFooterButtons: [
        if (!_isLoading &&
            _ordemServico !=
                null) // Só mostra os botões se os dados estiverem carregados
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.location_on_outlined),
                    label: const Text('IR PARA O ATIVO'),
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: primaryColor,
                      side: const BorderSide(color: primaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.play_circle_outline),
                    label: const Text('INICIAR O.S.'),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => IniciarOrdemServicoScreen(
                                ordemServico: _ordemServico!,
                              ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade700,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
