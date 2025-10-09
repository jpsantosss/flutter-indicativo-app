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

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAtivos();
    _getCurrentLocation(); // 2. Chamada para obter a localização atual
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
