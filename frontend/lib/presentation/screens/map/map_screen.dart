import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tcc/data/models/ativo.dart';
import 'package:flutter_tcc/presentation/screens/search/info_ativo_screen.dart';
import 'package:flutter_tcc/presentation/screens/search/solicitar_os_screen.dart';
import 'package:geolocator/geolocator.dart'; // 1. Importação adicionada

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

/*  
==================================== BLOCO 1 — CHAMADA DE API ====================================
Este arquivo implementa a tela do mapa principal (MapScreen), que utiliza o 
Google Maps para exibir os "ativos" vindos da API em formato de marcadores.

1. No initState(), duas coisas acontecem:
   - _fetchAtivos() → busca os ativos no backend Django (endpoint /api/ativos/) 
     usando http.get. A resposta JSON é decodificada, convertida em objetos Ativo 
     e cada ativo vira um Marker no mapa.
   - _getCurrentLocation() → obtém a localização atual do usuário com Geolocator, 
     verificando se o serviço de localização está ativo e se as permissões foram 
     concedidas. Caso positivo, a câmera do mapa é movida para a posição do usuário.

2. Os marcadores (_markers) representam os ativos no mapa e possuem um onTap, que 
   abre um BottomSheet (_showInfoBottomSheet) com ações rápidas sobre o ativo.

3. O mapa em si é renderizado via GoogleMap(), com:
   - myLocationEnabled = true → mostra o ponto azul da localização.
   - myLocationButtonEnabled = false → remove o botão padrão, pois foi criado um
     FloatingActionButton customizado para centralizar a câmera no usuário.
   - initialCameraPosition → define um ponto inicial padrão antes de obter a localização real.

4. Há também lógica de estado (_isLoading e _errorMessage) para exibir um 
   indicador de carregamento ou mensagens de erro caso a API falhe.
*/
class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAtivos();
    _getCurrentLocation();
  }

  // Função para obter a localização atual do usuário e mover a câmera
  Future<void> _getCurrentLocation() async {
    try {
      // Verifica se o serviço de localização está ativo
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        // Você pode mostrar um diálogo ou snackbar aqui
        return Future.error('Serviços de localização estão desativados.');
      }

      // Verifica as permissões
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return Future.error('Permissão de localização negada.');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return Future.error(
          'A permissão de localização foi negada permanentemente.',
        );
      }

      // Obtém a posição atual
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Move a câmera do mapa para a localização do usuário
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0, // Zoom mais próximo para a localização atual
          ),
        ),
      );
    } catch (e) {
      // Trata possíveis erros
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível obter a localização: $e')),
        );
      }
    }
  }

  Future<void> _fetchAtivos() async {
    // const String apiUrl = 'http://26.183.189.133:8000/api/ativos/';
    const String apiUrl = 'http://localhost:8000/api/ativos/';


    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(
          utf8.decode(response.bodyBytes),
        );
        final List<dynamic> features = data['features'];
        final List<Ativo> ativos =
            features.map((feature) => Ativo.fromJson(feature)).toList();

        Set<Marker> tempMarkers = {};
        for (var ativo in ativos) {
          tempMarkers.add(
            Marker(
              markerId: MarkerId(ativo.id),
              position: LatLng(ativo.latitude, ativo.longitude),
              onTap: () {
                _showInfoBottomSheet(ativo);
              },
            ),
          );
        }

        setState(() {
          _markers.clear();
          _markers.addAll(tempMarkers);
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Falha ao carregar os ativos.';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Não foi possível conectar ao servidor.';
        _isLoading = false;
      });
    }
  }


/*  
==================================== BLOCO 1 — INTERAÇÕES DO USUÁRIO E UI ====================================
O foco aqui está na experiência do usuário com os ativos mostrados no mapa.

1. _showInfoBottomSheet(ativo):
   - Quando o usuário clica em um marcador, abre-se um modal na parte inferior 
     da tela com informações do ativo.
   - Dentro do modal, existem 3 botões circulares (construídos com _buildActionButton):
        a) Solicitar O.S. → leva o usuário para a tela de solicitação de ordem de serviço.
        b) Rotas → espaço reservado para futura implementação de rotas até o ativo.
        c) Informações → leva para uma tela de detalhes do ativo selecionado.
   - Este BottomSheet melhora a navegação sem poluir a tela principal do mapa.

2. _buildActionButton():
   - Cria botões padronizados com ícone, label e ação, estilizados em formato circular.
   - Usado no BottomSheet para manter a consistência visual.

3. Scaffold + AppBar:
   - AppBar estilizada com cor personalizada e botão de refresh, que chama _fetchAtivos()
     novamente para atualizar os marcadores.
   - Body: um Stack com o mapa, o loading spinner ou mensagens de erro sobrepostos.
   - FloatingActionButton: botão para centralizar a câmera na localização atual do usuário.

No geral, este código integra a API de ativos com a exibição no Google Maps, 
permitindo interação rápida com cada ativo diretamente pelo mapa.  
*/

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(16),
            backgroundColor: const Color(0xFF2E95AC),
            foregroundColor: Colors.white,
          ),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }

  void _showInfoBottomSheet(Ativo ativo) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                ativo.nome,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildActionButton(
                    icon: Icons.build,
                    label: 'Solicitar O.S.',
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SolicitarOSScreen(ativo: ativo),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.directions,
                    label: 'Rotas',
                    onPressed: () {
                      /* Lógica futura para abrir a rota */
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.info_outline,
                    label: 'Informações',
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InfoAtivoScreen(ativo: ativo),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF12385D),
        title: const Text('Mapa', style: TextStyle(color: Colors.white)),
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.refresh),
              color: Colors.white,
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _errorMessage = null;
                });
                _fetchAtivos();
              },
            ),
        ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) => _mapController = controller,
            initialCameraPosition: const CameraPosition(
              target: LatLng(-22.4123, -42.9664), // Posição inicial padrão
              zoom: 13.5,
            ),
            markers: _markers,
            myLocationEnabled: true, // 3. Habilita o ponto azul da localização
            myLocationButtonEnabled:
                false, // 4. Desabilita o botão padrão (usaremos o nosso)
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_errorMessage != null)
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                color: Colors.white.withOpacity(0.8),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
            ),
        ],
      ),
      // 5. Botão para centralizar na localização do usuário
      floatingActionButton: FloatingActionButton(
        onPressed: _getCurrentLocation,
        backgroundColor: const Color(0xFF12385D),
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}
