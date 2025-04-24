import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MapaConcesionariosScreen extends StatefulWidget {
  const MapaConcesionariosScreen({super.key});

  @override
  State<MapaConcesionariosScreen> createState() => _MapaConcesionariosScreenState();
}

class _MapaConcesionariosScreenState extends State<MapaConcesionariosScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};
  bool _isLoading = true;
  String? _errorMessage;

  // Variables de filtro
  String _searchUso = '';
  String _searchNombre = '';
  String _searchNumeroProceso = '';

  @override
  void initState() {
    super.initState();
    _cargarConcesionarios();
  }

  Future<void> _cargarConcesionarios() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final querySnapshot = await _firestore.collection('concesionarios').get();

      if (querySnapshot.docs.isEmpty) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'No se encontraron concesionarios';
        });
        return;
      }

      final markers = <Marker>{};

      for (final doc in querySnapshot.docs) {
        final data = doc.data();
        final coordenadas = data['coordenadas'] as Map<String, dynamic>?;

        // Verificar si las coordenadas existen
        if (coordenadas == null) {
          debugPrint('Documento ${doc.id} no tiene coordenadas');
          continue;
        }

        final lat = coordenadas['lat'] as double?;
        final lng = coordenadas['lng'] as double?;

        if (lat == null || lng == null) {
          debugPrint('Documento ${doc.id} tiene coordenadas inválidas');
          continue;
        }

        // Filtrar por los criterios de búsqueda
        final uso = data['uso']?.toString() ?? '';
        final nombreConcesionario = data['nombreConcesionario']?.toString() ?? '';
        final numeroProceso = data['numeroProceso']?.toString() ?? '';

        if (_searchUso.isNotEmpty && !uso.toLowerCase().contains(_searchUso.toLowerCase())) {
          continue;
        }
        if (_searchNombre.isNotEmpty && !nombreConcesionario.toLowerCase().contains(_searchNombre.toLowerCase())) {
          continue;
        }
        if (_searchNumeroProceso.isNotEmpty && !numeroProceso.toLowerCase().contains(_searchNumeroProceso.toLowerCase())) {
          continue;
        }

        markers.add(
          Marker(
            markerId: MarkerId(doc.id),
            position: LatLng(lat, lng),
            icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
            onTap: () {
              _mostrarDetallesConcesionario(context, data);
            },
          ),
        );
      }

      setState(() {
        _markers.clear();
        _markers.addAll(markers);
        _isLoading = false;
      });

      // Si hay marcadores, centrar el mapa en el primero
      if (markers.isNotEmpty && _mapController != null) {
        final firstMarker = markers.first;
        _mapController!.animateCamera(
          CameraUpdate.newLatLngZoom(firstMarker.position, 10),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error al cargar concesionarios: ${e.toString()}';
      });
      debugPrint('Error al cargar concesionarios: $e');
    }
  }

  void _mostrarDetallesConcesionario(BuildContext context, Map<String, dynamic> data) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(
                  'Concesionario: ${data['nombreConcesionario'] ?? 'No disponible'}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)
              ),
              const SizedBox(height: 8),
              Text('Fuente: ${data['nombreFuente'] ?? 'No disponible'}'),
              Text('Uso: ${data['uso'] ?? 'No disponible'}'),
              Text('Fecha de inicio: ${data['fechaInicioConcesion'] ?? 'No disponible'}'),
              Text('N° de proceso: ${data['numeroProceso'] ?? 'No disponible'}'),
              Text('Caudal: ${data['caudal']?.toString() ?? 'No disponible'} l/s'),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Filtros en un Card
          Card(
            margin: const EdgeInsets.all(8),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchUso = value;
                            });
                            _cargarConcesionarios();
                          },
                          decoration: InputDecoration(
                            labelText: 'Filtrar por Uso',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.filter_alt, color: Colors.blue.shade800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          onChanged: (value) {
                            setState(() {
                              _searchNombre = value;
                            });
                            _cargarConcesionarios();
                          },
                          decoration: InputDecoration(
                            labelText: 'Filtrar por Nombre',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: Icon(Icons.search, color: Colors.blue.shade800),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _searchNumeroProceso = value;
                      });
                      _cargarConcesionarios();
                    },
                    decoration: InputDecoration(
                      labelText: 'Filtrar por N° de Proceso',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: Icon(Icons.numbers, color: Colors.blue.shade800),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Mapa
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                    if (_markers.isNotEmpty) {
                      _mapController!.animateCamera(
                        CameraUpdate.newLatLngZoom(_markers.first.position, 10),
                      );
                    }
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(-0.2298, -78.5249),
                    zoom: 10,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  mapToolbarEnabled: true,
                ),
                if (_isLoading)
                  const Center(child: CircularProgressIndicator()),
                if (_errorMessage != null)
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _errorMessage!,
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    ),
                  ),
                if (!_isLoading && _markers.isEmpty && _errorMessage == null)
                  const Center(
                    child: Text('No hay concesionarios para mostrar'),
                  ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _cargarConcesionarios,
        backgroundColor: Colors.blue.shade800,
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}