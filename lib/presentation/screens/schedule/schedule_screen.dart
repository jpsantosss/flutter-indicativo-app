import 'package:flutter/material.dart';
import 'package:flutter_tcc/data/models/ordem_servico.dart';
import 'package:intl/intl.dart';
import 'dart:math' as math;

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
      titulo: "Manutenção Corretiva",
      cliente: "Poste Solar",
      inicio: DateTime.now().copyWith(hour: 9, minute: 0),
      fim: DateTime.now().copyWith(hour: 11, minute: 30),
      cor: Colors.purple.shade300,
    ),
    OrdemServico(
      titulo: "Manutenção Preventiva",
      cliente: "Câmera de Segurança",
      inicio: DateTime.now().copyWith(hour: 14, minute: 0),
      fim: DateTime.now().copyWith(hour: 15, minute: 0),
      cor: Colors.orange.shade300,
    ),
    OrdemServico(
      titulo: "Manutenção Preditiva",
      cliente: "Sensor de movimento",
      inicio: DateTime.now().copyWith(hour: 15, minute: 30),
      fim: DateTime.now().copyWith(hour: 16, minute: 0),
      cor: Colors.teal.shade300,
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
        child: Card(
          clipBehavior: Clip.hardEdge,
          color: os.cor,
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
                  os.cliente,
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
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
        title: const Text('Agenda de Serviços', style: TextStyle(color: Colors.white)),
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
