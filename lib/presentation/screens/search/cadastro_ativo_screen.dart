import 'package:flutter/material.dart';

class CadastroAtivoScreen extends StatefulWidget {
  const CadastroAtivoScreen({super.key});

  @override
  State<CadastroAtivoScreen> createState() => _CadastroAtivoScreenState();
}

class _CadastroAtivoScreenState extends State<CadastroAtivoScreen> {
  final _nomeController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  String? _periodicidadeSelecionada;
  String? _nomeArquivoManual;

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF12385D);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF12385D),
        title: const Text(
          'Cadastro de Ativo',
          style: TextStyle(color: Colors.white),
        ),
        iconTheme: const IconThemeData(
          color: Colors.white, // Cor da "setinha" para branco
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nome',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nomeController,
                decoration: InputDecoration(
                  hintText: 'Ex: Câmera Portão Principal',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Marca',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _marcaController,
                decoration: InputDecoration(
                  hintText: 'Ex: Intelbras',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Modelo',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _modeloController,
                decoration: InputDecoration(
                  hintText: 'Ex: VHD 3230 B G4',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Periodicidade da Manutenção',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _periodicidadeSelecionada,
                hint: const Text('Selecione a frequência'),
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                items:
                    [
                          'Nenhuma',
                          'Diária',
                          'Semanal',
                          'Quinzenal',
                          'Mensal',
                          'Anual',
                        ]
                        .map(
                          (label) => DropdownMenuItem(
                            value: label,
                            child: Text(label),
                          ),
                        )
                        .toList(),
                onChanged: (value) {
                  setState(() {
                    _periodicidadeSelecionada = value;
                  });
                },
              ),
              const SizedBox(height: 24),
              const Text(
                'Manual (PDF - Opcional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              if (_nomeArquivoManual == null)
                OutlinedButton.icon(
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Selecionar arquivo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: primaryColor,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    // Lógica para upload de arquivo no futuro, apenas para simulação
                    setState(() {
                      _nomeArquivoManual = 'manual_camera_intelbras.pdf';
                    });
                  },
                )
              // Se um arquivo já foi selecionado, mostra o nome dele com um botão para remover
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade400),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.picture_as_pdf, color: Colors.red),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _nomeArquivoManual!,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.red),
                        onPressed: () {
                          // Simula a remoção do arquivo
                          setState(() {
                            _nomeArquivoManual = null;
                          });
                        },
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 40),

              //Botão de salvar
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF12385D),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'SALVAR ATIVO',
                    style: TextStyle(fontSize: 16, color: Colors.white),
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
