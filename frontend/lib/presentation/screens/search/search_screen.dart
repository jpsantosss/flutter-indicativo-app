import 'dart:async'; // Para usar o Timer do debounce
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
  // Controlador para o campo de pesquisa
  final _searchController = TextEditingController();
  Timer? _debounce;

  bool _isLoading = true;
  List<Ativo> _ativos = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAtivos(); // Busca inicial
    // Adiciona um "ouvinte" que é acionado sempre que o texto muda
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    // Limpa os recursos para evitar fugas de memória
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // Função chamada a cada alteração no campo de pesquisa
  void _onSearchChanged() {
    // Se já houver um timer a contar, cancela-o
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    // Cria um novo timer de 500ms. Se o utilizador não digitar mais nada
    // durante este tempo, a função _fetchAtivos será chamada.
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchAtivos(query: _searchController.text);
    });
  }

  // Função ATUALIZADA para aceitar um termo de pesquisa
  Future<void> _fetchAtivos({String? query}) async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    // Monta a URL base
    // Use 'localhost' para web/iOS e '10.0.2.2' para o emulador Android
    String apiUrl = 'http://localhost:8000/api/ativos/';

    // Se houver um termo de pesquisa, adiciona-o como parâmetro na URL
    if (query != null && query.isNotEmpty) {
      // Uri.encodeComponent garante que caracteres especiais na busca sejam tratados corretamente
      apiUrl += '?search=${Uri.encodeComponent(query)}';
    }

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final List<dynamic> features = data['features'];
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
    // Mostra uma mensagem diferente se a busca não retornou resultados
    if (_ativos.isEmpty && _searchController.text.isNotEmpty) {
      return const Center(
        child: Text('Nenhum ativo encontrado para a sua busca.'),
      );
    }
    if (_ativos.isEmpty) {
      return const Center(child: Text('Nenhum ativo cadastrado.'));
    }

    return RefreshIndicator(
      onRefresh: () => _fetchAtivos(),
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
            IconButton(
              onPressed: () {
                /* Ação para ver a rota no futuro */
              },
              icon: const Icon(Icons.directions),
              tooltip: 'Rota para o ativo',
              color: const Color(0xFF12385D),
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
          IconButton(
            icon: const Icon(Icons.refresh),
            color: Colors.white,
            onPressed: () => _fetchAtivos(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
        child: Column(
          children: [
            // O TextField agora está ligado ao nosso controlador
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar por nome do ativo...',
                prefixIcon: const Icon(Icons.search),
                // Adiciona um botão para limpar a pesquisa
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
              ),
            ),
            const SizedBox(height: 16),
            Expanded(child: _buildBody()),
          ],
        ),
      ),
      persistentFooterButtons: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () async {
              final bool? resultado = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (context) => const CadastroAtivoScreen(),
                ),
              );
              if (resultado == true) {
                // Ao voltar do cadastro, limpa a busca para mostrar todos os ativos, incluindo o novo
                _searchController.clear();
                _fetchAtivos();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF12385D),
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
