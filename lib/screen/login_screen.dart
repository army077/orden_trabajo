import 'package:flutter/material.dart';
import 'package:todo_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isAuthenticating = false; // Para mostrar un loader durante la autenticación.

  @override
  void initState() {
    super.initState();
    // Si deseas que la autenticación se retrase automáticamente después de un tiempo:
    Future.delayed(const Duration(minutes: 1), _checkBiometricAndAuthenticate);
  }

  /// Lógica para verificar si hay usuario y activar la biometría.
  Future<void> _checkBiometricAndAuthenticate() async {
    final user = _authService.currentUser;
    if (user != null) {
      bool authenticated = await _authService.authenticateWithBiometrics();
      if (authenticated && context.mounted) {
        Navigator.pushReplacementNamed(context, '/my_day_screen');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    final welcomeMessage = user != null
        ? '¡Bienvenido, ${user.email ?? user.displayName}!'
        : '¡Bienvenido!';

    return Scaffold(
      backgroundColor: const Color(0xFF8B0000),
      body: Center(
        child: _isAuthenticating
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      welcomeMessage,
                      style: const TextStyle(
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
                    if (user != null) ...[
                      ElevatedButton.icon(
                        onPressed: _checkBiometricAndAuthenticate,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Ingresar con huella o rostro'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black, backgroundColor: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    TextButton.icon(
                      onPressed: () async {
                        final user = await _authService.signInWithGoogle();
                        if (user != null && context.mounted) {
                          Navigator.pushReplacementNamed(
                              context, '/my_day_screen');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Error en la autenticación. Inténtalo de nuevo.',
                              ),
                            ),
                          );
                        }
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
}
