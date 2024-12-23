import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:todo_app/screen/my_day_screen.dart';
import 'package:todo_app/screen/prev_day_screen.dart';
import 'package:todo_app/screen/login_screen.dart';
import 'package:todo_app/firebase/firebase_options.dart';
import 'package:todo_app/shared/form_desviacion.dart'; // Asegúrate de tener este archivo
import 'package:todo_app/entities/tareas.dart'; // Asegúrate de tener este archivo
import 'package:firebase_auth/firebase_auth.dart';

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
      initialRoute: '/login_screen',
      onGenerateRoute: (settings) {
        final currentUser = FirebaseAuth.instance.currentUser;

        if (settings.name == '/my_day_screen') {
          // Verifica si los argumentos son válidos
          if (settings.arguments == null || settings.arguments is! Map<String, int>) {
            return MaterialPageRoute(
              builder: (context) => PrevDayScreen(
                tecnicoEmail: currentUser?.email ?? 'sin-email',
              ),
            );
          }

          // Obtén los argumentos válidos
          final arguments = settings.arguments as Map<String, int>;
          return MaterialPageRoute(
            builder: (context) => MyDayScreen(arguments: arguments),
          );
        }

        if (settings.name == '/desviacion_screen') {
          // Verifica si hay un argumento válido para la tarea
          if (settings.arguments == null || settings.arguments is! Tarea) {
            return MaterialPageRoute(
              builder: (context) => PrevDayScreen(
                tecnicoEmail: currentUser?.email ?? 'sin-email',
              ),
            );
          }

          // Obtén la tarea válida
          final tarea = settings.arguments as Tarea;
          return MaterialPageRoute(
            builder: (context) => ReportDeviationForm(tarea: tarea),
          );
        }

        // Retorna null para rutas no manejadas
        return null;
      },
      routes: {
        '/login_screen': (context) => const LoginScreen(),
        '/prev_day_screen': (context) {
          final currentUser = FirebaseAuth.instance.currentUser;
          return PrevDayScreen(
            tecnicoEmail: currentUser?.email ?? 'sin-email',
          );
        },
      },
    );
  }
}
