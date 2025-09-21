import 'package:flutter/material.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF12385D),
        title: const Text('Agenda', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text(
          'Aqui ficará o calendário!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
