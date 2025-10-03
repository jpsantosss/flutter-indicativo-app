import 'package:flutter/material.dart';
import 'package:flutter_tcc/data/models/ordem_servico.dart';
import 'package:intl/intl.dart';
import 'package:flutter_tcc/presentation/screens/schedule/info_ordem_servico_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  // Dados fictícios das Ordens de Serviço do dia
  final List<OrdemServico> _ordensDoDia = [
    OrdemServico(
      titulo: "Manutenção Corretiva",
      ativo: "ATIVO 002 - CÂMARA DE SEGURANÇA",
      inicio: DateTime.now().copyWith(hour: 9, minute: 0),
      fim: DateTime.now().copyWith(hour: 10, minute: 30),
      usuarioSolicitante: "João Pedro",
      dataCriacao: DateTime.now().subtract(const Duration(days: 2)),
      tipoManutencao: "Corretiva",
      status: StatusOS.pendente,
    ),
    OrdemServico(
      titulo: "Manutenção Preventiva",
      ativo: "ATIVO 001 - POSTE SOLAR",
      inicio: DateTime.now().copyWith(hour: 14, minute: 0),
      fim: DateTime.now().copyWith(hour: 15, minute: 0),
      usuarioSolicitante: "Admin (Automático)",
      dataCriacao: DateTime.now().subtract(const Duration(days: 5)),
      tipoManutencao: "Preventiva",
      status: StatusOS.pendente,
    ),
  ];

  // Cabeçalho para navegar entre os dias
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 30),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          Text(
            DateFormat.yMMMMEEEEd('pt_BR').format(_selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 30),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
            },
          ),
        ],
      ),
    );
  }

  // Widget que cria um card individual para cada Ordem de Serviço
  Widget _buildOSCard(OrdemServico os) {
    // Define um ícone e cor com base na prioridade da O.S.

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          os.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${os.ativo}\n${DateFormat('HH:mm').format(os.inicio)} - ${DateFormat('HH:mm').format(os.fim)}',
        ),
        trailing: const Icon(Icons.chevron_right),
        isThreeLine: true,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InfoOrdemServicoScreen(ordemServico: os),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF12385D);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text(
          'Agenda de Serviços',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          // A lista de O.S. ocupa todo o espaço restante
          Expanded(
            child: ListView.builder(
              itemCount: _ordensDoDia.length,
              itemBuilder: (context, index) {
                return _buildOSCard(_ordensDoDia[index]);
              },
            ),
          ),
        ],
      ),
      // Botão fixo no rodapé da tela
      persistentFooterButtons: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.route_outlined),
            label: const Text('TRAÇAR MELHOR ROTA'),
            onPressed: () {
              // Lógica futura para otimização de rota
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
