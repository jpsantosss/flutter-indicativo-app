import 'dart:convert';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Para diferenciar web de mobile
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';

class CadastroAtivoScreen extends StatefulWidget {
  const CadastroAtivoScreen({super.key});

  @override
  State<CadastroAtivoScreen> createState() => _CadastroAtivoScreenState();
}

/*  
==================================== BLOCO 1 — ESTRUTURA DA TELA E FORMULÁRIOS ====================================
Esta tela implementa o cadastro de um novo ativo.  
Ela é formada por vários campos de entrada e um seletor de arquivo opcional (manual em PDF).  

1. Controladores:
   - Criados para cada campo de entrada: nome, marca, modelo, periodicidade, endereço, latitude e longitude.
   - São instâncias de TextEditingController que capturam o texto digitado pelo usuário.

2. Upload de manual:
   - O usuário pode selecionar um arquivo PDF através do FilePicker.
   - O arquivo escolhido é armazenado em _manualFile.
   - Caso nenhum arquivo seja selecionado, é exibido um botão para upload.
   - Se o arquivo existir, ele aparece em uma caixa com ícone de PDF, nome e opção de remover.
*/
class _CadastroAtivoScreenState extends State<CadastroAtivoScreen> {
  final _nomeController = TextEditingController();
  final _marcaController = TextEditingController();
  final _modeloController = TextEditingController();
  final _periodicidadeController = TextEditingController();
  final _enderecoController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  // Variável para guardar o ficheiro selecionado
  PlatformFile? _manualFile;

  bool _isLoading = false;
  String? _errorMessage;

  // Função para o utilizador selecionar o ficheiro PDF
  Future<void> _selecionarManual() async {
    // Usamos o file_picker para abrir o seletor de ficheiros do sistema
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Permite apenas a seleção de PDFs
    );

    if (result != null) {
      setState(() {
        _manualFile = result.files.first; // Guarda o ficheiro selecionado
      });
    }
  }

  /*  
==================================== BLOCO 1 — ENVIO DOS DADOS PARA API (FUNÇÃO _cadastrarAtivo) ====================================
O método _cadastrarAtivo é responsável por enviar os dados preenchidos para a API Django via POST.

1. Validação inicial:
   - Verifica se os campos obrigatórios (nome, latitude e longitude) estão preenchidos.
   - Se não estiverem, exibe mensagem de erro e não envia requisição.

2. Montagem da requisição:
   - Cria um http.MultipartRequest com método POST para /api/ativos/.
   - Adiciona os campos de texto básicos (nome, marca, modelo, periodicidade, endereço).
   - Constrói a localização no formato GeoJSON (Point → coordinates [longitude, latitude]) e envia como string JSON.

3. Upload do manual:
   - Se o usuário escolheu um PDF, ele é adicionado na requisição.
   - No Web → usa fromBytes com os bytes do arquivo.
   - No Mobile/Desktop → usa fromPath com o caminho do arquivo.

4. Resposta do servidor:
   - Se statusCode == 201 → cadastro bem-sucedido, tela é fechada retornando "true".
   - Se status diferente, pega o corpo da resposta e mostra mensagem de erro detalhada.
   - Em caso de exceção (rede/dados inválidos), mostra mensagem genérica de falha.

5. Estados:
   - _isLoading controla exibição do CircularProgressIndicator no botão.
   - _errorMessage guarda os erros para exibição na interface.

Resumindo: este método faz toda a **comunicação com a API Django para cadastrar o ativo**,  
tratando envio de texto, coordenadas geográficas e manual em PDF.  
*/

  Future<void> _cadastrarAtivo() async {
    if (_nomeController.text.isEmpty ||
        _latitudeController.text.isEmpty ||
        _longitudeController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Por favor, preencha todos os campos obrigatórios.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    const String apiUrl = 'http://localhost:8000/api/ativos/';
    var request = http.MultipartRequest('POST', Uri.parse(apiUrl));

    try {
      final double latitude = double.parse(_latitudeController.text);
      final double longitude = double.parse(_longitudeController.text);

      // 1. Adiciona os campos de texto à requisição
      request.fields['nome'] = _nomeController.text;
      request.fields['marca'] = _marcaController.text;
      request.fields['modelo'] = _modeloController.text;
      request.fields['periodicidade'] = _periodicidadeController.text;
      request.fields['endereco'] = _enderecoController.text;
      // O GeoJSON é enviado como uma string de texto
      request.fields['localizacao'] = json.encode({
        'type': 'Point',
        'coordinates': [longitude, latitude],
      });

      // 2. Adiciona o ficheiro à requisição (se um foi selecionado)
      if (_manualFile != null) {
        if (kIsWeb) {
          // Para a web, usamos os bytes do ficheiro
          request.files.add(
            http.MultipartFile.fromBytes(
              'manual', // O nome do campo que o Django espera
              _manualFile!.bytes!,
              filename: _manualFile!.name,
              contentType: MediaType('application', 'pdf'),
            ),
          );
        } else {
          // Para mobile (Android/iOS), usamos o caminho do ficheiro
          request.files.add(
            await http.MultipartFile.fromPath(
              'manual',
              _manualFile!.path!,
              filename: _manualFile!.name,
              contentType: MediaType('application', 'pdf'),
            ),
          );
        }
      }

      // 3. Envia a requisição completa
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        if (!mounted) return;
        Navigator.pop(context, true);
      } else {
        final responseBody = json.decode(response.body);
        final errorDetail = responseBody.toString();
        setState(() {
          _errorMessage = 'Falha ao cadastrar: $errorDetail';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage =
            'Não foi possível conectar ao servidor ou dados inválidos.';
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
        title: const Text('Cadastro de Ativo'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
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
                hintText: 'Ex: Câmara Portão Principal',
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
              'Periodicidade da Manutenção (em dias)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _periodicidadeController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                hintText: 'Ex: 30',
                suffixText: 'dias',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Endereço',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _enderecoController,
              decoration: InputDecoration(
                hintText: 'Ex: Rua Principal, 123',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Latitude',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _latitudeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: InputDecoration(
                hintText: 'Ex: -22.414351',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Longitude',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _longitudeController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: InputDecoration(
                hintText: 'Ex: -42.969638',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- UPLOAD DE MANUAL (AGORA FUNCIONAL) ---
            const Text(
              'Manual (PDF - Opcional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_manualFile == null)
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
                onPressed: _selecionarManual,
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
                        _manualFile!.name,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _manualFile = null;
                        });
                      },
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 40),

            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Center(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _cadastrarAtivo,
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child:
                    _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text(
                          'SALVAR ATIVO',
                          style: TextStyle(fontSize: 16),
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
