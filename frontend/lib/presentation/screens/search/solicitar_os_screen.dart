import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tcc/data/models/ativo.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

// Enum para os tipos de manutenção que podem ser criados manualmente
enum TipoOS { corretiva, preditiva }

class SolicitarOSScreen extends StatefulWidget {
  final Ativo ativo;
  const SolicitarOSScreen({super.key, required this.ativo});

  @override
  State<SolicitarOSScreen> createState() => _SolicitarOSScreenState();
}

class _SolicitarOSScreenState extends State<SolicitarOSScreen> {
  // Controladores e variáveis de estado para o formulário
  final _tituloController = TextEditingController();
  final _descricaoController = TextEditingController();
  TipoOS? _tipoSelecionado = TipoOS.corretiva;
  DateTime? _dataPrevista;
  bool _isLoading = false;
  String? _errorMessage;

  // Função para abrir o seletor de data
  Future<void> _selecionarData(BuildContext context) async {
    const Color primaryColor = Color(0xFF12385D);
    final DateTime? dataSelecionada = await showDatePicker(
      context: context,
      initialDate: _dataPrevista ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      locale: const Locale('pt', 'BR'),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(primary: primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (dataSelecionada != null) {
      setState(() {
        _dataPrevista = dataSelecionada;
      });
    }
  }

  // Função para enviar os dados para a API
  Future<void> _confirmarSolicitacao() async {
    if (_tituloController.text.isEmpty) {
      setState(() {
        _errorMessage = 'O título é obrigatório.';
      });
      return;
    }
    if (_dataPrevista == null) {
      setState(() {
        _errorMessage = 'A data prevista é obrigatória.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Usa 'localhost' para web/iOS e '10.0.2.2' para o emulador Android
    const String apiUrl = 'http://localhost:8000/api/ordens-servico/';

    try {
      final Map<String, dynamic> body = {
        'titulo': _tituloController.text,
        'tipo':
            _tipoSelecionado == TipoOS.corretiva ? 'corretiva' : 'preditiva',
        'descricao': _descricaoController.text,
        'ativo': widget.ativo.id,
        // Envia a data no formato ISO 8601 que o Django entende
        if (_dataPrevista != null)
          'data_prevista': _dataPrevista!.toIso8601String(),
      };

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Content-Type': 'application/json',
          // O cabeçalho de autorização foi removido para o modo de desenvolvimento
        },
        body: json.encode(body),
      );

      if (response.statusCode == 201) {
        if (!mounted) return;
        Navigator.pop(context, true); // Retorna 'true' para indicar sucesso
      } else {
        final responseBody = json.decode(response.body);
        setState(() {
          _errorMessage = 'Falha ao criar O.S.: ${responseBody.toString()}';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Não foi possível conectar ao servidor.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF12385D);
    final dateFormatter = DateFormat('dd/MM/yyyy');

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
                ),
              ),
              const Divider(height: 32),

              // --- CAMPO TÍTULO ---
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Título da Solicitação',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    ' *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _tituloController,
                decoration: InputDecoration(
                  hintText: '...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- TIPO DE MANUTENÇÃO ---
              const Text(
                'Tipo de Ordem de Serviço',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              RadioListTile<TipoOS>(
                title: const Text('Corretiva'),
                subtitle: const Text('O ativo apresenta uma falha.'),
                value: TipoOS.corretiva,
                groupValue: _tipoSelecionado,
                fillColor: MaterialStateColor.resolveWith(
                  (states) => Color(0xFF12385D),
                ),
                onChanged: (value) {
                  setState(() {
                    _tipoSelecionado = value;
                  });
                },
              ),
              RadioListTile<TipoOS>(
                title: const Text('Preditiva'),
                subtitle: const Text('Sinais de possível falha futura.'),
                value: TipoOS.preditiva,
                groupValue: _tipoSelecionado,
                fillColor: MaterialStateColor.resolveWith(
                  (states) => Color(0xFF12385D),
                ),
                onChanged: (value) {
                  setState(() {
                    _tipoSelecionado = value;
                  });
                },
              ),
              const SizedBox(height: 24),

              // --- DATA PREVISTA ---
              Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text(
                    'Data Prevista',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    ' *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                child: OutlinedButton(
                  onPressed: () => _selecionarData(context),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                  ),
                  child: Text(
                    _dataPrevista != null
                        ? dateFormatter.format(_dataPrevista!)
                        : 'Selecionar Data',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          _dataPrevista == null ? primaryColor : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // --- DESCRIÇÃO ---
              const Text(
                'Descrição (Opcional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _descricaoController,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText: 'Descreva o problema ou o sintoma observado.',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 40),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Center(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _confirmarSolicitacao,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child:
                      _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
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
