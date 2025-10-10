import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tcc/data/models/ordem_servico.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_tcc/presentation/screens/schedule/info_ordem_servico_screen.dart';

class ScheduleScreen extends StatefulWidget {
  const ScheduleScreen({super.key});
  @override
  State<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  DateTime _selectedDate = DateTime.now();

  // Variáveis de estado
  bool _isLoading = true;
  List<OrdemServico> _ordensDoDia = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrdensServico();
  }

  // Função para buscar as O.S. da API para a data selecionada
  Future<void> _fetchOrdensServico() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // Formata a data para o formato YYYY-MM-DD que o backend espera
    final String formattedDate = DateFormat('yyyy-MM-dd').format(_selectedDate);
    // Usa 'localhost' para web e '10.0.2.2' para o emulador Android
    final String apiUrl =
        'http://localhost:8000/api/ordens-servico/?data_prevista=$formattedDate';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final List<OrdemServico> ordens =
            data.map((json) => OrdemServico.fromJson(json)).toList();
        setState(() {
          _ordensDoDia = ordens;
        });
      } else {
        setState(() {
          _errorMessage = 'Falha ao carregar as Ordens de Serviço.';
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

  // Função para mudar a data e buscar os novos dados
  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
    });
    _fetchOrdensServico();
  }

  // Cabeçalho para navegar entre os dias
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              icon: const Icon(Icons.chevron_left, size: 30),
              onPressed: () => _changeDate(-1)),
          Text(DateFormat.yMMMMEEEEd('pt_BR').format(_selectedDate),
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          IconButton(
              icon: const Icon(Icons.chevron_right, size: 30),
              onPressed: () => _changeDate(1)),
        ],
      ),
    );
  }

  // Widget que cria um card para cada O.S.
  Widget _buildOSCard(OrdemServico os) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      child: ListTile(
        title:
            Text(os.titulo, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('Ativo: ${os.ativo}'),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    InfoOrdemServicoScreen(ordemServicoId: os.id)),
          ).then((_) =>
              _fetchOrdensServico()); // Recarrega a lista ao voltar
        },
      ),
    );
  }

  // Constrói o corpo da tela com base no estado
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
          child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)));
    }
    if (_ordensDoDia.isEmpty) {
      return const Center(
          child: Text('Nenhuma Ordem de Serviço para esta data.'));
    }
    return ListView.builder(
      itemCount: _ordensDoDia.length,
      itemBuilder: (context, index) {
        return _buildOSCard(_ordensDoDia[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF12385D);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Agenda de Serviços',
            style: TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(child: _buildBody()),
        ],
      ),
      persistentFooterButtons: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton.icon(
            icon: const Icon(Icons.route_outlined),
            label: const Text('TRAÇAR MELHOR ROTA'),
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        )
      ],
    );
  }
}

