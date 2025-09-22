import 'package:flutter/material.dart';
import 'package:flutter_tcc/data/models/ativo.dart';
import 'package:flutter_tcc/presentation/screens/search/cadastro_ativo_screen.dart';
import 'package:flutter_tcc/presentation/screens/search/info_ativo_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  //Lista de dados estáticos para popular a tela
  final List<Ativo> _ativosFicticios = [
    Ativo(
      id: '001',
      nome: 'ATIVO 001 - POSTE SOLAR',
      marca: 'SunPower',
      modelo: 'X22-360',
      periodicidade: 'Anual',
      nomeArquivoManual: 'manual_poste_solar.pdf',
      endereco: 'Rua Tiête',
      latitude: '-22.431986',
      longitude: '-42.978299',
      mtbf: '8760 horas', // 1 ano
      mttr: '48 horas',
    ),
    Ativo(
      id: '002',
      nome: 'ATIVO 002 - CÂMERA DE SEGURANÇA',
      marca: 'Intelbras',
      modelo: 'VHD 3230 B G4',
      periodicidade: 'Mensal',
      nomeArquivoManual: null, // Sem manual
      endereco: 'Rua Tiête',
      latitude: '-22.431986',
      longitude: '-42.978299',
      mtbf: '1250 horas',
      mttr: '6 horas',
    ),
    Ativo(
      id: '003',
      nome: 'ATIVO 003 - SENSOR DE MOVIMENTO',
      marca: 'Bosch',
      modelo: 'DS-930',
      periodicidade: 'Semestral',
      nomeArquivoManual: 'bosch_ds930.pdf',
      endereco: 'Rua Tiête',
      latitude: '-22.431986',
      longitude: '-42.978299',
      mtbf: '4380 horas', // 6 meses
      mttr: '2 horas',
    ),
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
              color: Color(0xFF12385D),
            ),
            //Botão de informações
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => InfoAtivoScreen(ativo: ativo),
                  ),
                );
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
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CadastroAtivoScreen(),
                ),
              );
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
