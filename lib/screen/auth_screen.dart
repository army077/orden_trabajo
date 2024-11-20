import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/screen/my_day_screen.dart';
import 'package:todo_app/screen/login_screen.dart';

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
            // Usuario autenticado
            return FutureBuilder<int>(
              future: _getSelectedId(),
              builder: (context, idSnapshot) {
                if (idSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (idSnapshot.hasError) {
                  return const Center(child: Text('Error al cargar el ID'));
                } else {
                  final selectedId = idSnapshot.data!;
                  return MyDayScreen(selectedId: selectedId);
                }
              },
            );
          } else {
            // Usuario no autenticado
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
