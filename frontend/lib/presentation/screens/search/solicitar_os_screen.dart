import 'package:flutter/material.dart';
import 'package:flutter_tcc/data/models/ativo.dart';

enum TipoOS { corretiva, preditiva }

class SolicitarOSScreen extends StatefulWidget {
  final Ativo ativo;
  const SolicitarOSScreen({super.key, required this.ativo});

  @override
  State<SolicitarOSScreen> createState() =>
      _SolicitarOSScreenState();
}

class _SolicitarOSScreenState extends State<SolicitarOSScreen> {
  TipoOS? _tipoSelecionado = TipoOS.corretiva;
  final _observacaoController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF12385D);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Solicitar Ordem de Serviço'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ativo: ${widget.ativo.nome}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Colors.black54,
                ),
              ),
              const Divider(height: 32),

              const Text(
                'Tipo de Ordem de Serviço',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              RadioListTile<TipoOS>(
                title: const Text('Corretiva'),
                subtitle: const Text('O ativo apresenta uma falha.'),
                value: TipoOS.corretiva,
                groupValue: _tipoSelecionado,
                onChanged: (value) {
                  setState(() {
                    _tipoSelecionado = value;
                  });
                },
              ),
              RadioListTile<TipoOS>(
                title: const Text('Preditiva'),
                subtitle: const Text(
                  'O ativo apresenta sinais de possível falha futura.',
                ),
                value: TipoOS.preditiva,
                groupValue: _tipoSelecionado,
                onChanged: (value) {
                  setState(() {
                    _tipoSelecionado = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              const Text(
                'Observação',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _observacaoController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Descreva o problema ou o sintoma observado...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Lógica para enviar a solicitação no futuro, por enquanto, apenas fecha a tela
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'CONFIRMAR SOLICITAÇÃO',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}