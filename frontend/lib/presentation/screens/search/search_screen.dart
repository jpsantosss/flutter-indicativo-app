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

/*  
==================================== BLOCO 1 — CHAMADA DE API ====================================
Este arquivo implementa a tela de busca de ativos (SearchScreen), que permite 
pesquisar ativos cadastrados no backend Django por meio de uma API.

1. O campo de busca (TextField) está ligado a um TextEditingController 
   (_searchController). Sempre que o texto muda, o listener _onSearchChanged() 
   é acionado.

2. Para evitar muitas requisições, foi implementado um "debounce" com Timer: 
   - A cada tecla digitada, cancela o Timer anterior.
   - Aguarda 500ms sem novas digitações → chama _fetchAtivos(query: ...).

3. _fetchAtivos():
   - Monta a URL base da API (/api/ativos/).
   - Caso exista texto de busca, adiciona "?search=<termo>" na query.
   - Faz uma requisição HTTP GET.
   - Se sucesso (status 200), decodifica o JSON, extrai "features" e cria 
     objetos Ativo a partir deles, armazenando no estado _ativos.
   - Caso contrário, define mensagens de erro (_errorMessage).
   - Usa os estados _isLoading, _errorMessage e _ativos para controlar o que 
     aparece na tela.
*/
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
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _fetchAtivos(query: _searchController.text);
    });
  }

  Future<void> _fetchAtivos({String? query}) async {
    if (!_isLoading) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    // Use 'localhost' para web/iOS e '10.0.2.2' para o emulador Android
    String apiUrl = 'http://localhost:8000/api/ativos/';

    if (query != null && query.isNotEmpty) {
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


/*  
==================================== BLOCO 1 — INTERFACE DO USUÁRIO E INTERAÇÕES ====================================
A tela é construída em cima de Scaffold, com barra superior, campo de busca, 
lista de resultados e botão fixo para cadastrar novos ativos.

1. AppBar:
   - Título "Ativos" estilizado.
   - Botão de "refresh" manual que chama _fetchAtivos() novamente.

2. Campo de busca (TextField):
   - Mostra ícone de lupa.
   - Tem botão para limpar a pesquisa (ícone "X").
   - Ligado ao _searchController, que dispara a pesquisa com debounce.

3. Corpo (_buildBody):
   - Se está carregando → mostra CircularProgressIndicator.
   - Se houve erro → mostra mensagem em vermelho.
   - Se não há resultados → mostra mensagens diferentes para "nenhum ativo 
     encontrado" (quando buscou) ou "nenhum ativo cadastrado" (quando não há dados).
   - Caso contrário, exibe lista de ativos com RefreshIndicator.

4. _buildAtivoCard():
   - Cria um Card estilizado para cada ativo da lista.
   - Mostra o nome e três botões de ação:
       a) Editar ativo (leva para EditarAtivoScreen).
       b) Rota (futuro).
       c) Informações do ativo (leva para InfoAtivoScreen).

5. persistentFooterButtons:
   - Botão fixo no rodapé chamado "CADASTRO DE ATIVO".
   - Ao clicar, abre CadastroAtivoScreen.
   - Se o usuário cadastrar com sucesso (retorno true), a tela limpa a busca 
     e recarrega os ativos para incluir o novo.

Resumindo: esta tela combina lógica de busca eficiente (debounce) com integração 
à API e UI amigável para listar, editar, visualizar e cadastrar ativos.
*/
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
