import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AgregarConcesionarioScreen extends StatefulWidget {
  const AgregarConcesionarioScreen({super.key});

  @override
  State<AgregarConcesionarioScreen> createState() => _AgregarConcesionarioScreenState();
}

class _AgregarConcesionarioScreenState extends State<AgregarConcesionarioScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreConcesionarioController = TextEditingController();
  final TextEditingController _nombreFuenteController = TextEditingController();
  final TextEditingController _usoController = TextEditingController();
  final TextEditingController _caudalController = TextEditingController();
  final TextEditingController _fechaInicioController = TextEditingController();
  final TextEditingController _numeroProcesoController = TextEditingController();
  final TextEditingController _coordenadaXController = TextEditingController();
  final TextEditingController _coordenadaYController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  LatLng? _selectedPosition;
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _nombreConcesionarioController.dispose();
    _nombreFuenteController.dispose();
    _usoController.dispose();
    _caudalController.dispose();
    _fechaInicioController.dispose();
    _numeroProcesoController.dispose();
    _coordenadaXController.dispose();
    _coordenadaYController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  void _actualizarPosicionDesdeCoordenadas() {
    final x = double.tryParse(_coordenadaXController.text);
    final y = double.tryParse(_coordenadaYController.text);

    if (x != null && y != null) {
      setState(() {
        _selectedPosition = LatLng(y, x); // Y es latitud, X es longitud
      });
      _mapController?.animateCamera(
        CameraUpdate.newLatLng(_selectedPosition!),
      );
    }
  }

  Future<void> _guardarConcesionario() async {
    if (_formKey.currentState!.validate()) {
      final x = double.tryParse(_coordenadaXController.text);
      final y = double.tryParse(_coordenadaYController.text);

      if (x == null || y == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor ingrese coordenadas válidas')),
        );
        return;
      }

      try {
        await _firestore.collection('concesionarios').add({
          'nombreConcesionario': _nombreConcesionarioController.text,
          'nombreFuente': _nombreFuenteController.text,
          'uso': _usoController.text,
          'caudal': double.parse(_caudalController.text),
          'fechaInicioConcesion': _fechaInicioController.text,
          'numeroProceso': _numeroProcesoController.text,
          'coordenadas': {
            'lat': y, // Latitud (Y)
            'lng': x, // Longitud (X)
          },
          'fechaCreacion': FieldValue.serverTimestamp(),
        });

        // Limpiar formulario
        _nombreConcesionarioController.clear();
        _nombreFuenteController.clear();
        _usoController.clear();
        _caudalController.clear();
        _fechaInicioController.clear();
        _numeroProcesoController.clear();
        _coordenadaXController.clear();
        _coordenadaYController.clear();
        setState(() => _selectedPosition = null);

        // Mostrar diálogo de éxito
        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            // Configurar temporizador para cerrar automáticamente
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted) {
                Navigator.of(context).pop();
                // Cerrar la pantalla
                Navigator.of(context).pop();
              }
            });

            return Dialog(
              backgroundColor: Colors.transparent,
              insetAnimationDuration: const Duration(milliseconds: 300),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 60),
                    const SizedBox(height: 16),
                    const Text(
                      'Éxito',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Concesionario guardado exitosamente',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.green[400]!),
                    ),
                  ],
                ),
              ),
            );
          },
        );

        // Cerrar la pantalla después de confirmar
        if (mounted) {
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agregar Concesionario'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Sección de información básica
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const Text(
                        'Información Básica',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _nombreConcesionarioController,
                        label: 'Nombre del Concesionario',
                        icon: Icons.business,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _nombreFuenteController,
                        label: 'Nombre de la Fuente',
                        icon: Icons.water_damage,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _usoController,
                        label: 'Uso',
                        icon: Icons.eco,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _caudalController,
                        label: 'Caudal',
                        icon: Icons.waves,
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _fechaInicioController,
                        label: 'Fecha de Inicio de Concesión',
                        icon: Icons.calendar_today,
                      ),
                      const SizedBox(height: 16),
                      _buildTextField(
                        controller: _numeroProcesoController,
                        label: 'Número de Proceso',
                        icon: Icons.numbers,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Sección de coordenadas
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ubicación Geográfica',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ingrese las coordenadas:',
                        style: TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTextField(
                              controller: _coordenadaXController,
                              label: 'X (Longitud)',
                              icon: Icons.pin_drop,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _buildTextField(
                              controller: _coordenadaYController,
                              label: 'Y (Latitud)',
                              icon: Icons.pin_drop,
                              keyboardType: TextInputType.numberWithOptions(decimal: true),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: _actualizarPosicionDesdeCoordenadas,
                          icon: const Icon(Icons.map),
                          label: const Text('Mostrar en mapa'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange.shade600,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 300,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: GoogleMap(
                            onMapCreated: (controller) => _mapController = controller,
                            initialCameraPosition: const CameraPosition(
                              target: LatLng(-0.2298, -78.5249), // Coordenadas iniciales (Quito)
                              zoom: 10,
                            ),
                            markers: _selectedPosition == null
                                ? {}
                                : {
                              Marker(
                                markerId: const MarkerId('selected_location'),
                                position: _selectedPosition!,
                                infoWindow: const InfoWindow(title: 'Ubicación seleccionada'),
                              ),
                            },
                          ),
                        ),
                      ),
                      if (_selectedPosition != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            'Ubicación actual: Lat: ${_selectedPosition!.latitude.toStringAsFixed(6)}, Lng: ${_selectedPosition!.longitude.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Botón de guardar
              Center(
                child: ElevatedButton.icon(
                  onPressed: _guardarConcesionario,
                  icon: const Icon(Icons.save),
                  label: const Text(
                    'GUARDAR CONCESIONARIO',
                    style: TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade800,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.blue.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      keyboardType: keyboardType,
      validator: validator ?? (value) {
        if (value == null || value.isEmpty) {
          return 'Este campo es obligatorio';
        }
        if (keyboardType == TextInputType.number && double.tryParse(value) == null) {
          return 'Ingrese un número válido';
        }
        return null;
      },
    );
  }
}