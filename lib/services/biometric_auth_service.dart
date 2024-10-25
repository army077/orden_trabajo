import 'package:local_auth/local_auth.dart';

class BiometricAuthService {
  final LocalAuthentication auth = LocalAuthentication();

  Future<bool> checkBiometrics() async {
    return await auth.canCheckBiometrics;
  }

  Future<bool> authenticateUser() async {
    try {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Por favor autentícate para acceder',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      return authenticated;
    } catch (e) {
      print('Error en la autenticación: $e');
      return false;
    }
  }
}
