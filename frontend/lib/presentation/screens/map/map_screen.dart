import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_tcc/data/models/ativo.dart';
import 'package:flutter_tcc/presentation/screens/search/info_ativo_screen.dart';
import 'package:flutter_tcc/presentation/screens/search/solicitar_os_screen.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

// A chave de API foi corretamente removida do frontend

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};
  final Set<Circle> _circles = {};
  final Map<PolylineId, Polyline> _polylines = {};
  PolylinePoints polylinePoints = PolylinePoints();

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchAtivos();
  }

  // Função para obter a localização atual do utilizador
  Future<Position> _getCurrentLocation({bool updateUserMarker = false}) async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Serviços de localização estão desativados.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Permissão de localização negada.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'A permissão de localização foi negada permanentemente.');
    }

    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Se a flag for verdadeira, atualiza o círculo azul na UI
    if (updateUserMarker && mounted) {
      setState(() {
        _circles.clear();
        _circles.add(Circle(
          circleId: const CircleId('currentLocationHalo'),
          center: LatLng(position.latitude, position.longitude),
          radius: 100,
          fillColor: Colors.blue.withOpacity(0.15),
          strokeWidth: 0,
        ));
        _circles.add(Circle(
          circleId: const CircleId('currentLocationDot'),
          center: LatLng(position.latitude, position.longitude),
          radius: 30,
          fillColor: const Color(0xFF1a73e8),
          strokeColor: Colors.white,
          strokeWidth: 2,
          zIndex: 1,
        ));
      });
    }

    return position;
  }

  // Função para centralizar a câmara na localização do utilizador
  Future<void> _centerOnUser() async {
    try {
      // Pede para obter a localização e também para desenhar o marcador
      Position position = await _getCurrentLocation(updateUserMarker: true);
      _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: LatLng(position.latitude, position.longitude),
            zoom: 15.0,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Não foi possível obter a localização: $e')),
        );
      }
    }
  }

  // FUNÇÃO ATUALIZADA PARA ACEITAR LISTA DE WAYPOINTS (OPCIONAL)
  Future<void> _drawRoute(LatLng destination, {List<LatLng>? waypoints}) async {
     setState(() { _isLoading = true; }); // Mostra loading ao calcular rota
    try {
      Position startPosition = await _getCurrentLocation();
      // Usa 'localhost' para web e '10.0.2.2' para o emulador Android
      const String apiUrl = 'http://localhost:8000/api/get-route/';

      // Monta o corpo do pedido
      Map<String, dynamic> body = {
        'start_lat': startPosition.latitude,
        'start_lng': startPosition.longitude,
      };

      // Adiciona destino ou waypoints dependendo do caso
      if (waypoints != null && waypoints.isNotEmpty) {
        body['waypoints'] = waypoints.map((wp) => {'lat': wp.latitude, 'lng': wp.longitude}).toList();
        // Para rota otimizada, podemos definir o destino como a origem para um ciclo
        // body['end_lat'] = startPosition.latitude;
        // body['end_lng'] = startPosition.longitude;
      } else {
        body['end_lat'] = destination.latitude;
        body['end_lng'] = destination.longitude;
      }

      final response = await http.post(Uri.parse(apiUrl), headers: {'Content-Type': 'application/json'}, body: json.encode(body));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if ((data['routes'] as List).isNotEmpty) {
          // A lógica de desenho da polyline é a mesma
          final String encodedPolyline = data['routes'][0]['overview_polyline']['points'];
          List<PointLatLng> points = polylinePoints.decodePolyline(encodedPolyline);
          if (points.isNotEmpty) {
            List<LatLng> polylineCoordinates = points.map((p) => LatLng(p.latitude, p.longitude)).toList();
            Polyline polyline = Polyline(polylineId: const PolylineId('route'), color: Colors.blue, points: polylineCoordinates, width: 6);
            setState(() { _polylines.clear(); _polylines[const PolylineId('route')] = polyline; });
          }
        } else {
           if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Nenhuma rota encontrada.')));
        }
      } else {
         if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro do servidor ao calcular a rota: ${response.body}')));
      }
    } catch (e) {
      if(mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erro ao traçar a rota: $e')));
    } finally {
       if(mounted) setState(() { _isLoading = false; }); // Esconde loading
    }
  }

  // NOVA FUNÇÃO PARA TRAÇAR A ROTA OTIMIZADA POR TODOS OS MARCADORES
  Future<void> _drawOptimizedRouteForAllMarkers() async {
    if (_markers.isEmpty) {
       if(mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Não há marcadores no mapa para traçar a rota.')));
       return;
    }
    // Recolhe as posições de todos os marcadores
    List<LatLng> waypoints = _markers.map((marker) => marker.position).toList();
    // Chama a função _drawRoute passando a lista de waypoints
    // O 'destination' não é usado neste caso, podemos passar qualquer valor
    await _drawRoute(waypoints.first, waypoints: waypoints);
  }

  Future<void> _fetchAtivos() async {
    const String apiUrl = 'http://localhost:8000/api/ativos/';
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(utf8.decode(response.bodyBytes));
        final List<dynamic> features = data['features'];
        final List<Ativo> ativos = features.map((feature) => Ativo.fromJson(feature)).toList();
        Set<Marker> tempMarkers = {};
        for (var ativo in ativos) {
          tempMarkers.add(Marker(
            markerId: MarkerId(ativo.id),
            position: LatLng(ativo.latitude, ativo.longitude),
            onTap: () { _showInfoBottomSheet(ativo); },
          ));
        }
        setState(() {
          _markers.clear(); _markers.addAll(tempMarkers); _isLoading = false;
        });
      } else {
         setState(() { _errorMessage = 'Falha ao carregar os ativos.'; _isLoading = false; });
      }
    } catch (e) {
       setState(() { _errorMessage = 'Não foi possível conectar ao servidor.'; _isLoading = false; });
    }
  }

  void _showInfoBottomSheet(Ativo ativo) {
     showModalBottomSheet(
      context: context, backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(25))),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
          child: Column( mainAxisSize: MainAxisSize.min, children: [
              Text(ativo.nome, textAlign: TextAlign.center, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Row( mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  _buildActionButton(icon: Icons.build, label: 'Solicitar O.S.', onPressed: () {
                    Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => SolicitarOSScreen(ativo: ativo)));
                  }),
                  _buildActionButton(icon: Icons.directions, label: 'Rotas', onPressed: () {
                    Navigator.pop(context); _drawRoute(LatLng(ativo.latitude, ativo.longitude)); // Rota A->B
                  }),
                  _buildActionButton(icon: Icons.info_outline, label: 'Informações', onPressed: () {
                    Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context) => InfoAtivoScreen(ativo: ativo)));
                  }),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActionButton({required IconData icon, required String label, required VoidCallback onPressed}) {
     return Column( mainAxisSize: MainAxisSize.min, children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(shape: const CircleBorder(), padding: const EdgeInsets.all(16), backgroundColor: const Color(0xFF2E95AC), foregroundColor: Colors.white),
          child: Icon(icon, size: 30),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.black54)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF12385D);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: const Text('Mapa', style: TextStyle(color: Colors.white)),
        actions: [ if (!_isLoading) IconButton(icon: const Icon(Icons.refresh), color: Colors.white, onPressed: _fetchAtivos,) ],
      ),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (controller) { _mapController = controller; _centerOnUser(); },
            initialCameraPosition: const CameraPosition(target: LatLng(-22.4123, -42.9664), zoom: 13.5),
            markers: _markers,
            polylines: Set<Polyline>.of(_polylines.values),
            myLocationEnabled: false, // Desativa o ponto azul padrão
            myLocationButtonEnabled: false,
            circles: _circles, // Usa o nosso círculo customizado
          ),
          if (_isLoading) const Center(child: CircularProgressIndicator()),
          if (_errorMessage != null) Center( child: Container( padding: const EdgeInsets.all(16), color: Colors.white.withOpacity(0.8), child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)),),),
        ],
      ),
      // BOTÃO INFERIOR PARA A ROTA OTIMIZADA
      // persistentFooterButtons: [
      //   if (!_isLoading && _markers.isNotEmpty) // Só mostra o botão se houver marcadores
      //     Container(
      //       width: double.infinity,
      //       padding: const EdgeInsets.all(8.0),
      //       child: ElevatedButton.icon(
      //         icon: const Icon(Icons.route_outlined),
      //         label: const Text('TRAÇAR MELHOR ROTA'),
      //         onPressed: _drawOptimizedRouteForAllMarkers,
      //         style: ElevatedButton.styleFrom(
      //           backgroundColor: primaryColor,
      //           foregroundColor: Colors.white,
      //           padding: const EdgeInsets.symmetric(vertical: 16),
      //           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      //         ),
      //       ),
      //     )
      // ],
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnUser,
        backgroundColor: primaryColor,
        child: const Icon(Icons.my_location, color: Colors.white),
      ),
    );
  }
}

