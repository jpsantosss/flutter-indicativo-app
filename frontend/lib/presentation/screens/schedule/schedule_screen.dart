import 'package:flutter/material.dart';
import 'package:flutter_tcc/data/models/ordem_servico.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;
import 'package:flutter_tcc/presentation/screens/schedule/info_ordem_servico_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  //Criação das Ordens de Serviço conforme o modelo em models/ordem_servico.dart
  final List<OrdemServico> _ordensDoDia = [
    OrdemServico(
      titulo: "Verificar Câmera Sem Imagem",
      ativo: "ATIVO 002 - CÂMERA DE SEGURANÇA",
      inicio: DateTime.now().copyWith(hour: 9, minute: 0),
      fim: DateTime.now().copyWith(hour: 10, minute: 30),
      cor: Colors.purple.shade300,
      usuarioSolicitante: "João Pedro",
      dataCriacao: DateTime.now().subtract(const Duration(days: 2)),
      tipoManutencao: "Corretiva",
      status: StatusOS.pendente,
      prioridade: PrioridadeOS.alta,
    ),
    OrdemServico(
      titulo: "Manutenção Preventiva",
      ativo: "ATIVO 001 - POSTE SOLAR",
      inicio: DateTime.now().copyWith(hour: 14, minute: 0),
      fim: DateTime.now().copyWith(hour: 15, minute: 0),
      cor: Colors.orange.shade300,
      usuarioSolicitante: "Admin (Automático)",
      dataCriacao: DateTime.now().subtract(const Duration(days: 5)),
      tipoManutencao: "Preventiva",
      status: StatusOS.pendente,
      prioridade: PrioridadeOS.media,
    ),
  ];

  final double _hourHeight = 80.0;
  final double _minEventHeight = 60.0;

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

  //Método para construção da TimeLine
  Widget _buildTimelineBackground() {
    return Column(
      children: List.generate(24, (index) {
        return Container(
          height: _hourHeight,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: Colors.grey.shade300, width: 1.0),
            ),
          ),
          child: Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  '${index.toString().padLeft(2, '0')}:00',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(child: Container()),
            ],
          ),
        );
      }),
    );
  }

  // Widget que posiciona os cards de OS
  List<Widget> _buildEvents() {
    return _ordensDoDia.map((os) {
      final double top =
          os.inicio.hour * _hourHeight +
          (os.inicio.minute / 60.0) * _hourHeight;
      final double durationInMinutes =
          os.fim.difference(os.inicio).inMinutes.toDouble();

      final double calculatedHeight = durationInMinutes / 60.0 * _hourHeight;
      final double height = math.max(calculatedHeight, _minEventHeight);

      return Positioned(
        top: top,
        left: 60.0,
        right: 8.0,
        height: height,
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InfoOrdemServicoScreen(ordemServico: os),
              ),
            );
          },
          child: Card(
            clipBehavior: Clip.hardEdge,
            color: os.cor,
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Flexible(
                    child: Text(
                      os.titulo,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    os.ativo,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF12385D),
        title: const Text(
          'Agenda de Serviços',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              child: Stack(
                children: [_buildTimelineBackground(), ..._buildEvents()],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
