import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tcc/data/models/ativo.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:http_parser/http_parser.dart';

class EditarAtivoScreen extends StatefulWidget {
  final Ativo ativo;
  const EditarAtivoScreen({super.key, required this.ativo});

  @override
  State<EditarAtivoScreen> createState() => _EditarAtivoScreenState();
}

/*  
==================================== BLOCO 1 — controladores ====================================
Esta tela é responsável por **editar um ativo existente**.  
Ela recebe como parâmetro um objeto Ativo e pré-carrega todos os campos com os dados atuais.

1. Controladores:
   - São criados vários TextEditingController para controlar os campos de texto (nome, marca, modelo, endereço, latitude, longitude, MTBF, MTTR etc).
   - No initState, cada controlador é preenchido com os valores já cadastrados do ativo recebido.
   - O dispose garante que todos os controladores sejam liberados da memória.
*/
class _EditarAtivoScreenState extends State<EditarAtivoScreen> {
  // Controladores para cada campo do formulário
  late TextEditingController _nomeController;
  late TextEditingController _marcaController;
  late TextEditingController _modeloController;
  late TextEditingController _periodicidadeController;
  late TextEditingController _enderecoController;
  late TextEditingController _latitudeController;
  late TextEditingController _longitudeController;
  // late TextEditingController _mtbfController;
  // late TextEditingController _mttrController;

  PlatformFile? _manualFile;
  String? _nomeArquivoManualExistente;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    // Pré-preenche os controladores com os dados do ativo
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
    // _mtbfController = TextEditingController(text: widget.ativo.mtbf ?? '');
    // _mttrController = TextEditingController(text: widget.ativo.mttr ?? '');
    // if (widget.ativo.manualUrl != null && widget.ativo.manualUrl!.isNotEmpty) {
    //   _nomeArquivoManualExistente =
    //       Uri.parse(widget.ativo.manualUrl!).pathSegments.last;
    // }
  }

  @override
  void dispose() {
    // Limpeza dos controladores
    _nomeController.dispose();
    _marcaController.dispose();
    _modeloController.dispose();
    _periodicidadeController.dispose();
    _enderecoController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    // _mtbfController.dispose();
    // _mttrController.dispose();
    super.dispose();
  }

  // Função para o utilizador selecionar um novo manual
  Future<void> _selecionarManual() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result != null) {
      setState(() {
        _manualFile = result.files.first;
        _nomeArquivoManualExistente =
            null;
      });
    }
  }

  /*  
==================================== BLOCO 1 — ENVIO DOS DADOS PARA API (FUNÇÃO _editarAtivo) ====================================
1. Configuração da requisição:
   - Monta a URL baseada no ID do ativo → /api/ativos/{id}/.
   - Cria um MultipartRequest com método PUT para permitir envio de texto e arquivos juntos.

2. Campos enviados:
   - Envia dados básicos do ativo como nome, marca, modelo, periodicidade, endereço, MTBF e MTTR.
   - Constrói a localização em formato GeoJSON (Point com [longitude, latitude]).
   - Se o usuário escolheu um novo manual (PDF), o arquivo também é anexado à requisição:
     - No Web → usa fromBytes.
     - No Mobile/Desktop → usa fromPath.

3. Resposta:
   - A requisição é enviada e aguarda retorno.
   - Se statusCode == 200 → sucesso, a tela fecha retornando "true".
   - Caso contrário, extrai o corpo da resposta e mostra erro detalhado.
   - Se ocorrer exceção (como falha de rede ou parse inválido), mostra mensagem genérica.

4. Estados:
   - _isLoading: controla exibição do CircularProgressIndicator no botão.
   - _errorMessage: exibe mensagens de falha logo acima do botão de salvar.

Resumindo: a função é responsável por **construir a requisição PUT multipart, anexar arquivos se houver, enviar para a API Django e tratar os resultados**.  
*/

  // Função para enviar os dados atualizados para a API
  Future<void> _editarAtivo() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    // A URL agora inclui o ID do ativo para o método PUT
    final String apiUrl =
        'http://localhost:8000/api/ativos/${widget.ativo.id}/';
    var request = http.MultipartRequest('PUT', Uri.parse(apiUrl));

    try {
      final double latitude = double.parse(_latitudeController.text);
      final double longitude = double.parse(_longitudeController.text);

      // Adiciona os campos de texto à requisição
      request.fields['nome'] = _nomeController.text;
      request.fields['marca'] = _marcaController.text;
      request.fields['modelo'] = _modeloController.text;
      request.fields['periodicidade'] = _periodicidadeController.text;
      request.fields['endereco'] = _enderecoController.text;
      // request.fields['mtbf'] = _mtbfController.text;
      // request.fields['mttr'] = _mttrController.text;
      request.fields['localizacao'] = json.encode({
        'type': 'Point',
        'coordinates': [longitude, latitude],
      });

      // Adiciona o novo ficheiro de manual, se um foi selecionado
      if (_manualFile != null) {
        if (kIsWeb) {
          request.files.add(
            http.MultipartFile.fromBytes(
              'manual',
              _manualFile!.bytes!,
              filename: _manualFile!.name,
              contentType: MediaType('application', 'pdf'),
            ),
          );
        } else {
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

      // Envia a requisição
      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      // 200 OK é o código de sucesso para um PUT/PATCH
      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pop(context, true); // Retorna 'true' para indicar sucesso
      } else {
        final responseBody = json.decode(response.body);
        setState(() {
          _errorMessage = 'Falha ao atualizar: ${responseBody.toString()}';
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
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF12385D);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Editar Ativo'),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
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
                signed: true,
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
                signed: true,
              ),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // --- CAMPO MTBF ---
            // const Text(
            //   'MTBF (horas)',
            //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 8),
            // TextField(
            //   controller: _mtbfController,
            //   decoration: InputDecoration(
            //     hintText: 'Ex: 8760',
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 24),

            // // --- CAMPO MTTR ---
            // const Text(
            //   'MTTR (horas)',
            //   style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            // ),
            // const SizedBox(height: 8),
            // TextField(
            //   controller: _mttrController,
            //   decoration: InputDecoration(
            //     hintText: 'Ex: 48',
            //     border: OutlineInputBorder(
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //   ),
            // ),
            // const SizedBox(height: 24),

            // --- UPLOAD DE MANUAL ---
            const Text(
              'Manual (PDF - Opcional)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (_manualFile == null &&
                (_nomeArquivoManualExistente == null ||
                    _nomeArquivoManualExistente!.isEmpty))
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
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.red),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _manualFile?.name ?? _nomeArquivoManualExistente ?? '',
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _manualFile = null;
                          _nomeArquivoManualExistente = null;
                        });
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 40),

            // Mensagem de erro e botão de salvar
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
                onPressed: _isLoading ? null : _editarAtivo,
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
                          'SALVAR ALTERAÇÕES',
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
