import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo_app/services/auth_service.dart';

class LoginScreen extends StatelessWidget {
   LoginScreen({super.key});



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B0000), // Fondo rojo oscuro (inspirado en NU)
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '¡Bienvenido!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
             const SizedBox(height: 40),
              const Text(
                'Por favor inicia sesión para continuar',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            


              const SizedBox(height: 250),

              // Opción de Login con Google
              TextButton.icon(
                onPressed: () {
                  AuthService().SignInWithGoogle();
                },
                icon: const Icon(Icons.login, color: Colors.white),
                label: const Text(
                  'Inicia sesión con Google',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  


  // Widget para los campos de texto
  Widget _buildTextField({
    required String hintText,
    required IconData icon,
    bool obscureText = false,
  }) {
    return TextField(
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
        prefixIcon: Icon(icon, color: Colors.white),
        filled: true,
        fillColor: Colors.white.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
          borderSide: BorderSide.none,
        ),
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 20.0),
      ),
    );
  }
}
