import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tcc/data/models/ordem_servico.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class IniciarOrdemServicoScreen extends StatefulWidget {
  final OrdemServico ordemServico;

  const IniciarOrdemServicoScreen({super.key, required this.ordemServico});

  @override
  State<IniciarOrdemServicoScreen> createState() =>
      _IniciarOrdemServicoScreenState();
}

class _IniciarOrdemServicoScreenState extends State<IniciarOrdemServicoScreen> {
  DateTime? _dataHoraInicio;
  DateTime? _dataHoraFim;
  final _observacoesController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _selecionarDataHora(BuildContext context, {required bool isInicio}) async {
    const Color primaryColor = Color(0xFF12385D);
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(primary: primaryColor)),
          child: child!,
        );
      },
    );
    if (dataSelecionada == null) return;
    final TimeOfDay? horaSelecionada = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(DateTime.now()),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
              colorScheme: const ColorScheme.light(primary: primaryColor)),
          child: child!,
        );
      },
    );
    if (horaSelecionada == null) return;
    final DateTime dataHoraFinal = DateTime(
      dataSelecionada.year, dataSelecionada.month, dataSelecionada.day,
      horaSelecionada.hour, horaSelecionada.minute,
    );
    setState(() {
      if (isInicio) {
        _dataHoraInicio = dataHoraFinal;
      } else {
        _dataHoraFim = dataHoraFinal;
      }
    });
  }

  // <<< NOVA FUNÇÃO PARA FINALIZAR A O.S.
  Future<void> _finalizarOS() async {
    if (_dataHoraInicio == null || _dataHoraFim == null) {
      setState(() { _errorMessage = 'As datas de início e fim são obrigatórias.'; });
      return;
    }

    setState(() { _isLoading = true; _errorMessage = null; });

    // A URL agora aponta para o endpoint customizado 'finalizar'
    final String apiUrl = 'http://localhost:8000/api/ordens-servico/${widget.ordemServico.id}/finalizar/';

    try {
      final Map<String, dynamic> body = {
        'data_inicio_execucao': _dataHoraInicio!.toIso8601String(),
        'data_fim_execucao': _dataHoraFim!.toIso8601String(),
        'observacoes': _observacoesController.text,
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: { 'Content-Type': 'application/json' },
        body: json.encode(body),
      );

      // 200 OK é o código de sucesso para esta ação
      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true); // Retorna 'true' para indicar sucesso
      } else {
        final responseBody = json.decode(response.body);
        setState(() { _errorMessage = 'Falha ao finalizar: ${responseBody.toString()}'; });
      }
    } catch (e) {
      setState(() { _errorMessage = 'Não foi possível conectar ao servidor.'; });
    } finally {
      if (mounted) { setState(() { _isLoading = false; }); }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF12385D);
    final String dataExecucao = DateFormat.yMd('pt_BR').format(DateTime.now());
    final dateFormatter = DateFormat('dd/MM/y HH:mm');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Finalizar Ordem de Serviço'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Informações da Execução', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(children: [
              const Icon(Icons.person, color: Colors.grey),
              const SizedBox(width: 8),
              Text('Executor: Técnico 01', style: const TextStyle(fontSize: 16)), // Simplificado
            ]),
            const SizedBox(height: 12),
            Row(children: [
              const Icon(Icons.calendar_today, color: Colors.grey),
              const SizedBox(width: 8),
              Text('Data: $dataExecucao', style: const TextStyle(fontSize: 16)),
            ]),
            const Divider(height: 32),

            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Data/Hora Início', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => _selecionarDataHora(context, isInicio: true),
                        style: OutlinedButton.styleFrom(foregroundColor: primaryColor),
                        child: Text(_dataHoraInicio != null ? dateFormatter.format(_dataHoraInicio!) : 'Selecionar', style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Data/Hora Fim', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      OutlinedButton(
                        onPressed: () => _selecionarDataHora(context, isInicio: false),
                        style: OutlinedButton.styleFrom(foregroundColor: primaryColor),
                        child: Text(_dataHoraFim != null ? dateFormatter.format(_dataHoraFim!) : 'Selecionar', style: const TextStyle(fontSize: 16)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('Observações', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _observacoesController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Descreva o que foi realizado...',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 24),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16))),
              ),
          ],
        ),
      ),
      persistentFooterButtons: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.check_circle),
              label: const Text('FINALIZAR O.S.'),
              onPressed: _isLoading ? null : _finalizarOS, // <<< CHAMA A NOVA FUNÇÃO
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
