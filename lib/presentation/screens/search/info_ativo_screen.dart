import 'package:flutter/material.dart';
import 'package:flutter_tcc/data/models/ativo.dart';

class InfoAtivoScreen extends StatelessWidget {
  final Ativo ativo;
  const InfoAtivoScreen({super.key, required this.ativo});

  //Widget para os quadrados de indicadores (MTBF e MTTR)
  Widget _buildIndicatorCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        color: color.withOpacity(0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: color, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Widget para cada linha de informação
  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(color: Colors.black87, fontSize: 18),
          ),
          const Divider(height: 24),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF12385D),
        title: Text(ativo.nome, style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildIndicatorCard(
                    'MTBF',
                    ativo.mtbf,
                    Colors.green.shade700,
                  ),
                  const SizedBox(width: 16),
                  _buildIndicatorCard(
                    'MTTR',
                    ativo.mttr,
                    Colors.orange.shade800,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              //Detalhes do ativo
              const Text(
                'Detalhes do Ativo',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildInfoRow('Nome Completo', ativo.nome),
              _buildInfoRow('Marca', ativo.marca),
              _buildInfoRow('Modelo', ativo.modelo),
              _buildInfoRow('Periodicidade da Manutenção', ativo.periodicidade),
              _buildInfoRow(
                'Manual',
                ativo.nomeArquivoManual ?? 'Nenhum manual cadastrado',
              ),
              _buildInfoRow('Endereco', ativo.endereco),
            ],
          ),
        ),
      ),
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              //Botão 1: Ir para o Ativo
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
              //Botão 2: Solicitar Manutenção
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.build),
                  label: const Text('SOLICITAR MANUTENÇÃO'),
                  onPressed: () {
                    /* Ação para solicitar manutenção no futuro */
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade800,
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
