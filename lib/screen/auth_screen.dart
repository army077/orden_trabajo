import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/screen/my_day_screen.dart';
import 'package:todo_app/screen/login_screen.dart';
import 'package:todo_app/screen/prev_day_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  Future<int?> _getSelectedId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selectedId'); // Devuelve null si no está configurado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data != null) {
            final userEmail = snapshot.data!.email ?? ''; // Obtén el email del usuario logueado

            return FutureBuilder<int?>(
              future: _getSelectedId(), // Obtén el ID seleccionado
              builder: (context, idSnapshot) {
                if (idSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                // Si no hay ID seleccionado, redirige a `PrevDayScreen`
                if (idSnapshot.data == null) {
                  return PrevDayScreen(tecnicoEmail: userEmail);
                }

                // Si hay un ID seleccionado, construye los argumentos y redirige a `MyDayScreen`
                return MyDayScreen(
                  arguments: {
                    'id_real': idSnapshot.data!, // Supongamos que `id_real` es el ID seleccionado
                    'id_tabla': idSnapshot.data!, // Usa el mismo ID o ajusta según sea necesario
                  },
                );
              },
            );
          } else {
            // Si no hay un usuario logueado, redirige a `LoginScreen`
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
