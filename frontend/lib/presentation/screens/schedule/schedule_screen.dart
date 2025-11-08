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
  List<OrdemServico> _todasAsOrdensPendentes = []; // Armazena todas as O.S. pendentes
  List<OrdemServico> _ordensFiltradas = []; // Armazena as O.S. para a data selecionada
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrdensServico();
  }

  // Função para buscar as O.S. da API
  Future<void> _fetchOrdensServico() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // <<< ALTERAÇÃO: Busca todas as O.S. com status 'pendente' de uma só vez
    const String apiUrl = 'http://localhost:8000/api/ordens-servico/?status=pendente';

    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final List<OrdemServico> ordens =
            data.map((json) => OrdemServico.fromJson(json)).toList();
        
        setState(() {
          _todasAsOrdensPendentes = ordens;
          // Após buscar, aplica o filtro inicial para a data atual
          _filtrarOrdensPorData();
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

  // <<< NOVA FUNÇÃO: Filtra a lista localmente sem precisar de chamar a API novamente
  void _filtrarOrdensPorData() {
    // Normaliza a data selecionada para ignorar as horas
    final dataSelecionadaSemHoras = DateUtils.dateOnly(_selectedDate);

    setState(() {
      _ordensFiltradas = _todasAsOrdensPendentes.where((os) {
        // Normaliza a data prevista da O.S.
        final dataPrevistaSemHoras = DateUtils.dateOnly(os.dataPrevista);
        // Mantém a O.S. se a sua data prevista for no mesmo dia ou depois da data selecionada
        return !dataPrevistaSemHoras.isBefore(dataSelecionadaSemHoras);
      }).toList();
    });
  }


  void _changeDate(int days) {
    setState(() {
      _selectedDate = _selectedDate.add(Duration(days: days));
      // <<< ALTERAÇÃO: Apenas aplica o filtro local, não chama a API
      _filtrarOrdensPorData();
    });
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left, size: 30),
            onPressed: () => _changeDate(-1),
          ),
          Text(
            DateFormat('EEEE, dd/MM/yyyy', 'pt_BR').format(_selectedDate),
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right, size: 30),
            onPressed: () => _changeDate(1),
          ),
        ],
      ),
    );
  }

  // O Widget do card permanece o mesmo
  Widget _buildOSCard(OrdemServico os) {
    final bool isFinalizada = os.status == StatusOS.finalizada;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      color: isFinalizada ? Colors.grey.shade200 : null,
      child: ListTile(
        title: Text(
          os.titulo,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isFinalizada ? TextDecoration.lineThrough : null,
            color: isFinalizada ? Colors.grey.shade600 : null,
          ),
        ),
        subtitle: Text('Ativo: ${os.ativo}\nData Prevista: ${DateFormat('dd/MM/yyyy').format(os.dataPrevista)}'),
        isThreeLine: true,
        trailing: Icon(
          isFinalizada ? Icons.check_circle : Icons.chevron_right,
          color: isFinalizada ? Colors.green : null,
        ),
        onTap: isFinalizada
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        InfoOrdemServicoScreen(ordemServicoId: os.id),
                  ),
                ).then((_) => _fetchOrdensServico());
              },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
      );
    }
    // <<< ALTERAÇÃO: Verifica a lista filtrada
    if (_ordensFiltradas.isEmpty) {
      return const Center(
        child: Text('Nenhuma O.S. pendente para esta data ou datas futuras.'),
      );
    }
    return ListView.builder(
      // <<< ALTERAÇÃO: Usa a lista filtrada
      itemCount: _ordensFiltradas.length,
      itemBuilder: (context, index) {
        return _buildOSCard(_ordensFiltradas[index]);
      },
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.white,
            onPressed: () => _fetchOrdensServico(),
          ),
        ],
      ),
      body: Column(children: [_buildHeader(), Expanded(child: _buildBody())]),
      // persistentFooterButtons: [
      //   Container(
      //     width: double.infinity,
      //     padding: const EdgeInsets.all(8.0),
      //     child: ElevatedButton.icon(
      //       icon: const Icon(Icons.route_outlined),
      //       label: const Text('TRAÇAR MELHOR ROTA'),
      //       onPressed: () {},
      //       style: ElevatedButton.styleFrom(
      //         backgroundColor: primaryColor,
      //         foregroundColor: Colors.white,
      //         padding: const EdgeInsets.symmetric(vertical: 16),
      //       ),
      //     ),
      //   ),
      // ],
    );
  }
}

