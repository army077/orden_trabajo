import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:todo_app/firebase/firebase_options.dart';
import 'package:todo_app/screen/my_day_screen.dart';
import 'package:todo_app/screen/auth_screen.dart';
import 'package:todo_app/screen/login_screen.dart';
import 'package:todo_app/screen/pruebas_foto_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializa Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicializa intl con el locale en español
  Intl.defaultLocale = 'es';
  await initializeDateFormatting('es', null); // Inicializa datos de fecha para español
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/prueba_foto': (context) => const PruebasFotoScreen(imageUrl: ''),
        '/': (context) => const AuthScreen(),
        '/my_day_screen': (context) => MyDayScreen(),
        '/login_screen': (context) => const LoginScreen(),
      },
    );
  }
}
