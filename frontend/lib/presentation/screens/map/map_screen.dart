import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_tcc/data/models/ativo.dart';
import 'package:flutter_tcc/presentation/screens/search/info_ativo_screen.dart';
import 'package:flutter_tcc/presentation/screens/search/solicitar_os_screen.dart';

class MapAtivo {
  final Ativo ativo;
  final LatLng position;

  MapAtivo({required this.ativo, required this.position});
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController _mapController;
  final Set<Marker> _markers = {};

  final List<MapAtivo> _ativosNoMapa = [
    MapAtivo(
      ativo: Ativo(
        id: '001',
        nome: 'ATIVO 001 - POSTE SOLAR',
        marca: 'SunPower',
        modelo: 'X22-360',
        periodicidade: 'Anual',
        mtbf: '8760 horas',
        mttr: '48 horas',
        endereco: 'Rua das Flores, 123',
        latitude: '-22.4088',
        longitude: '-42.9645',
        nomeArquivoManual: 'manual_poste_solar.pdf',
      ),
      position: const LatLng(-22.4165, -42.9712),
    ),
    MapAtivo(
      ativo: Ativo(
        id: '002',
        nome: 'ATIVO 002 - CÂMARA DE SEGURANÇA',
        marca: 'Intelbras',
        modelo: 'VHD 3230',
        periodicidade: 'Mensal',
        mtbf: '1250 horas',
        mttr: '6 horas',
        endereco: 'Av. Principal, 456',
        latitude: '-22.4088',
        longitude: '-42.9645',
        nomeArquivoManual: null,
      ),
      position: const LatLng(-22.4088, -42.9645),
    ),
    MapAtivo(
      ativo: Ativo(
        id: '003',
        nome: 'ATIVO 003 - SENSOR DE MOVIMENTO',
        marca: 'Bosch',
        modelo: 'DS-930',
        periodicidade: 'Semestral',
        mtbf: '4380 horas',
        mttr: '2 horas',
        endereco: 'Praça da Matriz, 789',
        latitude: '-22.4088',
        longitude: '-42.9645',
        nomeArquivoManual: 'bosch_ds930.pdf',
      ),
      position: const LatLng(-22.4190, -42.9599),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _setMarkers();
  }

  void _setMarkers() {
    for (var mapAtivo in _ativosNoMapa) {
      _markers.add(
        Marker(
          markerId: MarkerId(mapAtivo.ativo.id),
          position: mapAtivo.position,
          onTap: () {
            _showInfoBottomSheet(mapAtivo);
          },
        ),
      );
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 100,
        child: Column(
          children: [
            Container(
              width: 70,
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF2E95AC),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 36),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  void _showInfoBottomSheet(MapAtivo mapAtivo) {
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
                mapAtivo.ativo.nome,
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
                    label: 'Solicitar\nOrdem de Serviço',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  SolicitarOSScreen(ativo: mapAtivo.ativo),
                        ),
                      );
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.directions_outlined,
                    label: 'Rotas',
                    onTap: () {
                      /* Lógica futura para abrir a rota */
                    },
                  ),
                  _buildActionButton(
                    icon: Icons.info_outline,
                    label: 'Informações',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) =>
                                  InfoAtivoScreen(ativo: mapAtivo.ativo),
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
      ),
      body: GoogleMap(
        onMapCreated: (controller) => _mapController = controller,
        initialCameraPosition: const CameraPosition(
          target: LatLng(-22.4123, -42.9664),
          zoom: 13.5,
        ),
        markers: _markers,
      ),
    );
  }
}
