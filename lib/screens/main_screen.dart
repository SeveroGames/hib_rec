import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hib_rec/screens/chat_screen.dart';
import 'package:hib_rec/screens/map_screen.dart';
import 'add_concesion.dart';
import 'profile_section.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  User? _currentUser;
  Map<String, dynamic>? _userData;
  int _currentIndex = 0;
  bool _showChatButton = true;
  Offset _chatButtonPosition = Offset(20, 20);

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .get();

      if (userDoc.exists) {
        setState(() {
          _userData = userDoc.data()!;
        });
      }
    }
  }

  void _openChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatScreen(concessionName: 'Información')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'GESTIÓN HÍDRICA',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.blue.shade800,
        elevation: 8,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Stack(
        children: [
          _buildCurrentScreen(),
          if (_showChatButton)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 200),
              left: _chatButtonPosition.dx,
              top: _chatButtonPosition.dy,
              child: Draggable(
                feedback: Material(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade800.withOpacity(0.9),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chat,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
                childWhenDragging: Container(),
                onDragEnd: (details) {
                  final screenSize = MediaQuery.of(context).size;
                  double newX = details.offset.dx;
                  double newY = details.offset.dy;

                  // Efecto "imán" a los bordes
                  if (newX < screenSize.width / 4) {
                    newX = 20;
                  } else if (newX > 3 * screenSize.width / 4) {
                    newX = screenSize.width - 80;
                  }

                  setState(() {
                    _chatButtonPosition = Offset(
                      newX.clamp(20, screenSize.width - 80),
                      newY.clamp(20, screenSize.height - 200),
                    );
                  });
                },
                child: GestureDetector(
                  onTap: _openChatbot,
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade800.withOpacity(0.7),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 10,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.chat,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white.withOpacity(0.7),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.add),
              label: 'Añadir',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map_outlined),
              label: 'Mapa',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              label: 'Perfil',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentScreen() {
    switch (_currentIndex) {
      case 0:
        return const AgregarConcesionarioScreen();
      case 1:
        return const MapaConcesionariosScreen();
      case 2:
        return ProfileSection(
          user: _currentUser,
          userData: _userData,
        );
      default:
        return const AgregarConcesionarioScreen();
    }
  }
}