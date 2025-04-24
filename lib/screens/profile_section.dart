import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'login_screen.dart'; // Asegúrate de tener esta pantalla importada

class ProfileSection extends StatefulWidget {
  const ProfileSection({super.key, User? user, Map<String, dynamic>? userData});

  @override
  State<ProfileSection> createState() => _ProfileSectionState();
}

class _ProfileSectionState extends State<ProfileSection> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  User? _currentUser;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      _currentUser = _auth.currentUser;

      if (_currentUser != null) {
        // Obtener datos específicamente de la colección 'users'
        final userDoc = await _firestore.collection('users').doc(_currentUser!.uid).get();

        if (userDoc.exists) {
          setState(() {
            _userData = userDoc.data();
            _isLoading = false;
          });
        } else {
          setState(() {
            _userData = null;
            _isLoading = false;
          });
        }
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar datos: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Obtener fechaRegistro de userData (colección users)
    final formattedDate = _userData?['fechaRegistro']?.toDate() != null
        ? DateFormat('dd/MM/yyyy').format(_userData!['fechaRegistro'].toDate())
        : 'No disponible';

    // Obtener nombre de userData (colección users)
    final userName = _userData?['nombre'] ?? 'Usuario';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con foto de perfil
            Center(
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blue.shade800,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 60,
                      backgroundColor: Colors.blue.shade100,
                      child: Icon(
                        Icons.person,
                        size: 60,
                        color: Colors.blue.shade800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    userName, // Nombre desde Firestore
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currentUser?.email ?? '', // Email desde Auth
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),

            // Sección de información
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información de la cuenta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(height: 15),
                    _buildInfoRow(
                      icon: Icons.email,
                      title: 'Correo electrónico',
                      value: _currentUser?.email ?? 'No disponible', // Desde Auth
                    ),
                    const Divider(height: 30),
                    _buildInfoRow(
                      icon: Icons.person,
                      title: 'Nombre completo',
                      value: userName, // Desde Firestore
                    ),
                    const Divider(height: 30),
                    _buildInfoRow(
                      icon: Icons.calendar_today,
                      title: 'Fecha de registro',
                      value: formattedDate, // Desde Firestore
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Sección de acciones
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  _buildActionTile(
                    icon: Icons.exit_to_app,
                    title: 'Cerrar sesión',
                    color: Colors.red,
                    onTap: _confirmSignOut,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.blue.shade800, size: 24),
        const SizedBox(width: 15),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    Color color = Colors.blue,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      trailing: Icon(Icons.chevron_right, color: color),
      onTap: onTap,
    );
  }

  Future<void> _confirmSignOut() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20.0),
          ),
          elevation: 10,
          title: const Text(
            'Cerrar sesión',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.logout,
                size: 48,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              const Text(
                '¿Estás seguro de que quieres cerrar tu sesión?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        side: const BorderSide(color: Colors.grey),
                      ),
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );

    if (confirmed == true) {
      try {
        await _auth.signOut();
        // Navegar a la pantalla de login y eliminar el historial de navegación
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false,
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
        );
      }
    }
  }
}