import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_tcc/data/models/ativo.dart';
import 'package:flutter_tcc/presentation/screens/search/cadastro_ativo_screen.dart';
import 'package:flutter_tcc/presentation/screens/search/info_ativo_screen.dart';
import 'package:flutter_tcc/presentation/screens/search/editar_ativo_screen.dart';
import 'package:http/http.dart' as http;

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // Variáveis de estado para gerir a UI
  bool _isLoading = true;
  List<Ativo> _ativos = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Busca os dados assim que o ecrã é carregado
    _fetchAtivos();
  }

  // Função para buscar os ativos da API Django
  Future<void> _fetchAtivos() async {
    // Garante que o ecrã mostre o loading ao recarregar
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    // Use 'localhost' para web/iOS e '10.0.2.2' para o emulador Android
    const String apiUrl = 'http://localhost:8000/api/ativos/';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        // Usamos utf8.decode para garantir o tratamento correto de caracteres especiais (acentos, etc.)
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );

        // A API GeoDjango retorna uma lista de 'features'
        final List<dynamic> features = data['features'];

        // Usa o método Ativo.fromJson para converter cada item da lista
        final List<Ativo> ativosCarregados =
            features.map((feature) => Ativo.fromJson(feature)).toList();

        setState(() {
          _ativos = ativosCarregados;
        });
      } else {
        setState(() {
          _errorMessage = 'Falha ao carregar os dados do servidor.';
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

  // Constrói a UI com base no estado (loading, erro ou sucesso)
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      );
    }
    if (_ativos.isEmpty) {
      return const Center(child: Text('Nenhum ativo encontrado.'));
    }

    return RefreshIndicator(
      onRefresh: _fetchAtivos, // Permite "puxar para recarregar"
      child: ListView.builder(
        itemCount: _ativos.length,
        itemBuilder: (context, index) {
          return _buildAtivoCard(_ativos[index]);
        },
      ),
    );
  }

  // Card individual para cada ativo
  Widget _buildAtivoCard(Ativo ativo) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                ativo.nome,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            //Botão de editar
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditarAtivoScreen(ativo: ativo),
                  ),
                );
              },
              icon: const Icon(Icons.edit),
              tooltip: 'Editar ativo',
              color: Colors.orange,
            ),
            //Botão de rota
            IconButton(
              onPressed: () {
                /* Ação para ver a rota no futuro */
              },
              icon: const Icon(Icons.directions),
              tooltip: 'Rota para o ativo',
              color: Color(0xFF12385D),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InfoAtivoScreen(ativo: ativo),
                  ),
                );
              },
              icon: const Icon(Icons.info_outline),
              tooltip: 'Informações do ativo',
              color: Colors.grey.shade600,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF12385D),
        title: const Text('Ativos', style: TextStyle(color: Colors.white)),
        actions: [
          // Botão para recarregar a lista manualmente
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.white,
            onPressed: _fetchAtivos,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou ID do ativo...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody()), // O corpo do ecrã agora é dinâmico
          ],
        ),
      ),
      persistentFooterButtons: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              // Navega para o ecrã de cadastro e espera um resultado
              final bool? resultado = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const CadastroAtivoScreen(),
                ),
              );
              // Se o resultado for 'true' (cadastro bem-sucedido), recarrega a lista
              if (resultado == true) {
                _fetchAtivos();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF12385D),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('CADASTRO DE ATIVO'),
          ),
        ),
      ],
    );
  }
}
