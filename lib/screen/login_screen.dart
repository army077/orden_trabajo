import 'package:flutter/material.dart';
import 'package:todo_app/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _authService = AuthService();
  bool _isAuthenticating = false;

  /// Biometric authentication logic triggered by button press.
  Future<void> _checkBiometricAndAuthenticate() async {
    setState(() => _isAuthenticating = true);

    try {
      bool authenticated = await _authService.authenticateWithBiometrics();
      if (authenticated && mounted) {
        Navigator.pushReplacementNamed(context, '/my_day_screen');
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Autenticación fallida. Inténtalo de nuevo.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;

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
                    const SizedBox(height: 20,),
                    Text(
                      user != null
                          ? '¡Bienvenido, ${user.displayName}!'
                          : '¡Bienvenido!',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Image.asset('lib/images/dragon.png', height: 100,),
                    const SizedBox(height: 40),
                    const Text(
                      'Por favor inicia sesión para continuar',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                      ),
                    ),
                    
                    const SizedBox(height: 150),
                    if (user != null)
                      ElevatedButton.icon(
                        onPressed: _checkBiometricAndAuthenticate,
                        icon: const Icon(Icons.fingerprint),
                        label: const Text('Ingresar con huella o rostro'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.black,
                          backgroundColor: Colors.white,
                        ),
                      ),
                    const SizedBox(height: 20),
                    TextButton.icon(
                      onPressed: () async {
                        final user = await _authService.signInWithGoogle();
                        if (user != null && mounted) {
                          Navigator.pushReplacementNamed(
                              context, '/prev_day_screen');
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Error en la autenticación. Inténtalo de nuevo.'),
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
