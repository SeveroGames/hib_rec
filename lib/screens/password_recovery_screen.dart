import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendPasswordResetEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _auth.sendPasswordResetEmail(email: _emailController.text.trim());
      setState(() {
        _emailSent = true;
        _isLoading = false;
      });
    } on FirebaseAuthException catch (e) {
      setState(() => _isLoading = false);
      String errorMessage;
      switch (e.code) {
        case 'user-not-found':
          errorMessage = 'No existe una cuenta con este correo electrónico.';
          break;
        case 'invalid-email':
          errorMessage = 'El correo electrónico no tiene un formato válido.';
          break;
        default:
          errorMessage = 'Ocurrió un error. Por favor inténtalo de nuevo.';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ocurrió un error inesperado.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo o imagen de la aplicación
              Container(
                margin: const EdgeInsets.only(top: 40, bottom: 30),
                child: Icon(
                  Icons.lock_reset,
                  size: 100,
                  color: Colors.blue.shade800,
                ),
              ),

              // Card con el formulario (similar al login)
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        if (!_emailSent) ...[
                          Text(
                            'Recuperar Contraseña',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Ingresa tu correo electrónico para recibir un enlace de recuperación',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          const SizedBox(height: 30),
                          TextFormField(
                            controller: _emailController,
                            decoration: InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: Icon(Icons.email, color: Colors.blue.shade800),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.blue.shade800,
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Por favor ingresa tu correo electrónico';
                              }
                              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                                  .hasMatch(value)) {
                                return 'Ingresa un correo electrónico válido';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 25),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _sendPasswordResetEmail,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade800,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                                  : const Text(
                                'Enviar enlace',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ] else ...[
                          const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 80,
                          ),
                          const SizedBox(height: 20),
                          Text(
                            '¡Correo enviado!',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade800,
                            ),
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Hemos enviado un enlace para restablecer tu contraseña a ${_emailController.text}.',
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'Por favor revisa tu bandeja de entrada.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 30),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue.shade800,
                                padding: const EdgeInsets.symmetric(vertical: 15),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: const Text(
                                'Volver al inicio',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),

              // Enlace para volver al login
              if (!_emailSent) ...[
                const SizedBox(height: 20),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    'Volver al inicio de sesión',
                    style: TextStyle(
                      color: Colors.blue.shade800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}