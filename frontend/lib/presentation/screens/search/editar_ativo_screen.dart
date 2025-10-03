import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tcc/data/models/ativo.dart';

class EditarAtivoScreen extends StatefulWidget {
  final Ativo ativo;

  const EditarAtivoScreen({super.key, required this.ativo});

  @override
  State<EditarAtivoScreen> createState() => _EditarAtivoScreenState();
}

class _EditarAtivoScreenState extends State<EditarAtivoScreen> {
  // Controladores para cada campo do formulário
  late TextEditingController _nomeController;
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _periodicidadeController;
  late TextEditingController _enderecoController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;

  String? _nomeArquivoManual;

  @override
  void initState() {
    super.initState();
    _nomeController = TextEditingController(text: widget.ativo.nome);
    _marcaController = TextEditingController(text: widget.ativo.marca);
    _modeloController = TextEditingController(text: widget.ativo.modelo);
    _periodicidadeController = TextEditingController(
      text: widget.ativo.periodicidade.toString(),
    );
    _enderecoController = TextEditingController(text: widget.ativo.endereco);
    _latitudeController = TextEditingController(
      text: widget.ativo.latitude.toString(),
    );
    _longitudeController = TextEditingController(
      text: widget.ativo.longitude.toString(),
    );
    _nomeArquivoManual = widget.ativo.nomeArquivoManual;
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _periodicidadeController.dispose();
    _enderecoController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF12385D);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Ativo'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- CAMPO NOME ---
            const Text(
              'Nome',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nomeController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- CAMPO MARCA ---
            const Text(
              'Marca',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _marcaController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- CAMPO MODELO ---
            const Text(
              'Modelo',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _modeloController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- CAMPO PERIODICIDADE ---
            const Text(
              'Periodicidade da Manutenção (em dias)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _periodicidadeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                suffixText: 'dias',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- UPLOAD DE MANUAL (SIMULAÇÃO) ---
            const Text(
              'Manual (PDF - Opcional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_nomeArquivoManual == null)
              OutlinedButton.icon(
                icon: const Icon(Icons.upload_file),
                label: const Text('Selecionar ficheiro'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: primaryColor,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {
                  setState(() {
                    _nomeArquivoManual = 'manual_atualizado.pdf';
                  });
                },
              )
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
                        setState(() {
                          _nomeArquivoManual = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),

            // --- CAMPO ENDEREÇO ---
            const Text(
              'Endereço',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _enderecoController,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- CAMPO LATITUDE ---
            const Text(
              'Latitude',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _latitudeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- CAMPO LONGITUDE ---
            const Text(
              'Longitude',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _longitudeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- BOTÃO DE SALVAR ---
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // Lógica para salvar as alterações no futuro
                  Navigator.pop(context); // Por enquanto, apenas fecha a tela
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'SALVAR ALTERAÇÕES',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
