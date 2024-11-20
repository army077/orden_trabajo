import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todo_app/screen/my_day_screen.dart';
import 'package:todo_app/screen/prev_day_screen.dart';
import 'package:todo_app/screen/login_screen.dart';
import 'package:todo_app/firebase/firebase_options.dart'; // Asegúrate de tener este archivo

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Necesario para operaciones asíncronas
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // Configuración generada automáticamente
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/prev_day_screen',
      onGenerateRoute: (settings) {
        if (settings.name == '/my_day_screen') {
          final selectedId = settings.arguments as int;
          return MaterialPageRoute(
            builder: (context) => MyDayScreen(selectedId: selectedId),
          );
        }
        return null;
      },
      routes: {
        '/login_screen': (context) => const LoginScreen(),
        '/prev_day_screen': (context) => const PrevDayScreen(),
      },
    );
  }
}
