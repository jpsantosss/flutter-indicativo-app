import 'package:flutter/material.dart';
import 'package:flutter_tcc/data/models/ativo.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
//Lista de dados estáticos para popular a tela
  final List<Ativo> _ativosFicticios = [
    Ativo(id: '001', nome: 'ATIVO 001 - POSTE SOLAR'),
    Ativo(id: '002', nome: 'ATIVO 002 - CÂMERA DE SEGURANÇA'),
    Ativo(id: '003', nome: 'ATIVO 003 - SENSOR DE MOVIMENTO'),
  ];

//Widget para construir cada card da lista de ativos
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
//Botão de rota
            IconButton(
              onPressed: () {
                /* Ação para ver a rota no futuro */
              },
              icon: const Icon(Icons.directions),
              tooltip: 'Rota para o ativo',
              color: Theme.of(context).primaryColor,
            ),
//Botão de informações
            IconButton(
              onPressed: () {
                /* Ação para ver informações no futuro */
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
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          16.0,
          16.0,
          16.0,
          0,
        ),
        child: Column(
          children: [
//Barra de busca
            TextField(
              decoration: InputDecoration(
                hintText: 'Buscar por nome ou ID do ativo...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    /* Ação para limpar a busca no futuro */
                  },
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _ativosFicticios.length,
                itemBuilder: (context, index) {
                  return _buildAtivoCard(_ativosFicticios[index]);
                },
              ),
            ),
          ],
        ),
      ),
      // -- BOTÃO NO RODAPÉ --
      persistentFooterButtons: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              /* Ação para ir para a tela de cadastro no futuro */
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade300,
              foregroundColor: Colors.black87,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Cadastro de ativo'),
          ),
        ),
      ],
    );
  }
}
