import 'package:flutter/material.dart';
import 'package:flutter_tcc/data/models/ativo.dart';
import 'package:flutter_tcc/presentation/screens/search/editar_ativo_screen.dart';
import 'package:flutter_tcc/presentation/screens/search/solicitar_os_screen.dart';
import 'package:flutter_tcc/presentation/screens/search/historico_os_ativo_screen.dart';

class InfoAtivoScreen extends StatelessWidget {
  final Ativo ativo;
  const InfoAtivoScreen({super.key, required this.ativo});

  // Widget para os quadrados de indicadores (MTBF e MTTR)
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
                style: const TextStyle(
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

  // Widget para cada linha de informação
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
    const Color primaryColor = Color(0xFF12385D);

    // Lógica de fallback: se MTBF/MTTR == 0 → mostrar periodicidade
    final mtbfValue =
        (ativo.mtbf != 0)
            ? '${(ativo.mtbf / 60).toStringAsFixed(1)} horas'
            : '${ativo.periodicidade} dias';

    final mttrValue =
        (ativo.mttr != 0)
            ? '${(ativo.mttr / 60).toStringAsFixed(1)} horas'
            : '0 horas';

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        title: Text(ativo.nome),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -- INDICADORES MTBF e MTTR --
            Row(
              children: [
                _buildIndicatorCard('MTBF', mtbfValue, Colors.green.shade700),
                const SizedBox(width: 16),
                _buildIndicatorCard('MTTR', mttrValue, Colors.orange.shade800),
              ],
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.history),
                label: const Text('HISTÓRICO DE MANUTENÇÕES'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => HistoricoOsAtivoScreen(
                            ativoId: ativo.id,
                            ativoNome: ativo.nome,
                          ),
                    ),
                  );
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // -- DETALHES DO ATIVO --
            const Text(
              'Detalhes do Ativo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            _buildInfoRow('Nome Completo', ativo.nome),
            _buildInfoRow('Marca', ativo.marca),
            _buildInfoRow('Modelo', ativo.modelo),
            _buildInfoRow(
              'Periodicidade da Manutenção',
              '${ativo.periodicidade} dias',
            ),
            _buildInfoRow('Endereço', ativo.endereco),
            _buildInfoRow('Latitude', ativo.latitude.toString()),
            _buildInfoRow('Longitude', ativo.longitude.toString()),
            _buildInfoRow(
              'Manual',
              ativo.manualUrl ?? 'Nenhum manual cadastrado',
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
                  icon: const Icon(Icons.build_circle_outlined),
                  label: const Text('SOLICITAR O.S.'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SolicitarOSScreen(ativo: ativo),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange.shade800,
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
