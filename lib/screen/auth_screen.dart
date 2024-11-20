import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/screen/my_day_screen.dart';
import 'package:todo_app/screen/login_screen.dart';
import 'package:todo_app/screen/prev_day_screen.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  Future<int> _getSelectedId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('selectedId') ?? 10; // ID predeterminado si no está configurado
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
  stream: FirebaseAuth.instance.authStateChanges(),
  builder: (context, snapshot) {
    if (snapshot.hasData) {
      // Redirige según la lógica de selección de ID
      return FutureBuilder<int?>(
        future: _getSelectedId(), // Obtén el ID seleccionado (puede ser null)
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.data == null) {
            return const PrevDayScreen(); // Si no hay ID, redirige a seleccionar
          } else {
            return MyDayScreen(selectedId: snapshot.data!); // Si hay ID, carga `MyDayScreen`
          }
        },
      );
    } else {
      return const LoginScreen();
    }
  },
),

    );
  }
}
