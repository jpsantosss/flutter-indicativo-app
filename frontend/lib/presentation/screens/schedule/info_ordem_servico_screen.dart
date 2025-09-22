import 'package:flutter/material.dart';
import 'package:flutter_tcc/data/models/ordem_servico.dart';
import 'package:flutter_tcc/presentation/screens/schedule/iniciar_ordem_servico_screen.dart';
import 'package:intl/intl.dart';

class InfoOrdemServicoScreen extends StatelessWidget {
  final OrdemServico ordemServico;

  const InfoOrdemServicoScreen({super.key, required this.ordemServico});

  //Converte o enum de Status em um Widget visual (tag colorida)
  Widget _buildStatusTag(StatusOS status) {
    String text;
    Color color;
    switch (status) {
      case StatusOS.pendente:
        text = 'Pendente';
        color = Colors.orange;
        break;
      case StatusOS.finalizada:
        text = 'Finalizada';
        color = Colors.green;
        break;
      case StatusOS.cancelada:
        text = 'Cancelada';
        color = Colors.red;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  //Converte o enum de Prioridade em um Widget visual (tag colorida)
  Widget _buildPrioridadeTag(PrioridadeOS prioridade) {
    String text;
    Color color;
    switch (prioridade) {
      case PrioridadeOS.baixa:
        text = 'Baixa';
        color = Colors.blue;
        break;
      case PrioridadeOS.media:
        text = 'Média';
        color = Colors.amber.shade800;
        break;
      case PrioridadeOS.alta:
        text = 'Alta';
        color = Colors.red.shade700;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(color: Colors.black87, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowWithTag({
    required IconData icon,
    required String label,
    required Widget tag,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey.shade600, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          tag,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormatter = DateFormat.yMd('pt_BR').add_Hm();
    return Scaffold(
      appBar: AppBar(
        title: Text(ordemServico.ativo, style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF12385D),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ordemServico.titulo,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),

            _buildInfoRowWithTag(
              icon: Icons.flag_outlined,
              label: 'Status',
              tag: _buildStatusTag(ordemServico.status),
            ),
            _buildInfoRowWithTag(
              icon: Icons.priority_high,
              label: 'Prioridade',
              tag: _buildPrioridadeTag(ordemServico.prioridade),
            ),
            const Divider(height: 32),

            _buildInfoRow(
              icon: Icons.person_outline,
              label: 'Solicitante',
              value: ordemServico.usuarioSolicitante,
            ),
            _buildInfoRow(
              icon: Icons.construction,
              label: 'Tipo de Manutenção',
              value: ordemServico.tipoManutencao,
            ),
            _buildInfoRow(
              icon: Icons.inventory_2_outlined,
              label: 'Ativo',
              value: ordemServico.ativo,
            ),
            _buildInfoRow(
              icon: Icons.edit_calendar_outlined,
              label: 'Data de Criação',
              value: dateFormatter.format(ordemServico.dataCriacao),
            ),
            _buildInfoRow(
              icon: Icons.event_available_outlined,
              label: 'Data Prevista',
              value: dateFormatter.format(ordemServico.inicio),
            ),
          ],
        ),
      ),
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.directions),
                  label: const Text('IR PARA O ATIVO'),
                  onPressed: () {
                    /* Ação para abrir mapa no futuro */
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF12385D),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('INICIAR O.S.'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (context) => IniciarOrdemServicoScreen(
                              ordemServico: ordemServico,
                            ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
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
