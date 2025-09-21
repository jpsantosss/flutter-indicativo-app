import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF12385D),
        title: const Text('Ativos', style: TextStyle(color: Colors.white)),
      ),
      body: const Center(
        child: Text(
          'Aqui ficarão os ativos!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
