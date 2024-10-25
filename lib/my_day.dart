import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:todo_app/services/auth_service.dart';
import 'entities/tareas.dart';
import 'shared/form_inspeccion1.dart';
import 'shared/form_inspeccion2.dart';
import 'shared/form_inspeccion3.dart';
import 'shared/form_inspeccion4.dart';
import 'shared/form_inspeccion5.dart';
import 'shared/form_limpieza6.dart';
import 'shared/form_inspeccion7.dart';
import 'shared/form_inspeccion8.dart';
import 'shared/form_inspeccion9.dart';
import 'shared/form_reemplazo10.dart';
import 'shared/form_ajuste11.dart';
import 'shared/form_inspeccion12.dart';

class MyDayScreen extends StatefulWidget {
  @override
  _MyDayScreenState createState() => _MyDayScreenState();
}

final user = FirebaseAuth.instance.currentUser;

class _MyDayScreenState extends State<MyDayScreen> with WidgetsBindingObserver {
  late Future<List<Tarea>> futureTareas;
  final AuthService _authService = AuthService();
  Map<int, bool> checkboxHabilitado = {}; // Controla si el checkbox está habilitado por tarea

  @override
  void initState() {
    super.initState();
    futureTareas = fetchTareas();
    WidgetsBinding.instance.addObserver(this); // Observa el ciclo de vida.
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Elimina el observador.
    super.dispose();
  }

  /// Redirige a LoginScreen si la app vuelve del segundo plano.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      Navigator.pushReplacementNamed(context, '/login_screen');
    }
  }

  Future<void> signOut() async {
    await _authService.signOut(); // Cierra sesión en Firebase y Google.
    Navigator.pushReplacementNamed(context, '/login_screen'); // Redirige a LoginScreen.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: signOut,
          ),
        ],
        title: Text(
          'Orden Trabajo de ${user?.displayName ?? 'Usuario'}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color.fromARGB(255, 221, 87, 78),
      ),
      body: FutureBuilder<List<Tarea>>(
        future: futureTareas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay tareas disponibles'));
          } else {
            List<Tarea> tareas = snapshot.data!;
            List<Tarea> completadas = tareas.where((t) => t.completada).toList();
            List<Tarea> noCompletadas = tareas.where((t) => !t.completada).toList();

            return ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                if (completadas.isNotEmpty) ...[
                  _buildSectionTitle('Completadas', Icons.check_circle),
                  ..._buildTaskList(completadas),
                  const SizedBox(height: 20),
                ],
                _buildSectionTitle('Pendientes', Icons.pending_actions),
                ..._buildTaskList(noCompletadas),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildTaskList(List<Tarea> tareas) {
    tareas.sort((a, b) => a.posicion.compareTo(b.posicion));

    return tareas.map((tarea) {
      int index = tareas.indexOf(tarea);
      bool canComplete = index == 0 || tareas[index - 1].completada;
      bool isCheckboxEnabled = checkboxHabilitado[tarea.id] ?? false;

      return ListTile(
        title: Text(
          '${tarea.posicion}. ${tarea.titulo}',
          style: TextStyle(
            color: tarea.completada
                ? Colors.amber[900]
                : canComplete
                    ? Colors.black
                    : Colors.black38,
          ),
        ),
        subtitle: Row(
          children: [
            Icon(getIconForCategory(tarea.categoria), size: 20, color: Colors.grey),
            const SizedBox(width: 8),
            Text(tarea.categoria),
          ],
        ),
        trailing: Checkbox(
          value: tarea.completada,
          onChanged: isCheckboxEnabled
              ? (bool? value) {
                  setState(() {
                    tarea.completada = value ?? false;
                  });
                }
              : null,
        ),
        onTap: () => _showTaskDetails(tarea),
      );
    }).toList();
  }

  void _showTaskDetails(Tarea tarea) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _getFormularioPorTipo(tarea),
          ),
        );
      },
    );
  }

  Widget _getFormularioPorTipo(Tarea tarea) {
    switch (tarea.noFormulario) {
      case 1:
        return FormularioConDetalles(tarea: tarea, onCompletar: () => setState(() {}));
      case 2:
        return FormularioEstadoEstetico(tarea: tarea, onCompletar: () => setState(() {}));
      case 3:
        return FormularioIncompleto(tarea: tarea, onCompletar: () => setState(() {}));
      case 4:
        return FormularioCalibracion(tarea: tarea, onCompletar: () => setState(() {}));
      case 5:
        return FormularioFueraDeRango(tarea: tarea, onCompletar: () => setState(() {}));
      case 6:
        return FormularioLimpieza(tarea: tarea, onCompletar: () => setState(() {}));
      case 7:
        return FormularioDesgaste(tarea: tarea, onCompletar: () => setState(() {}));
      case 8:
        return FormularioConFugas(tarea: tarea, onCompletar: () => setState(() {}));
      case 9:
        return FormularioConexiones(tarea: tarea, onCompletar: () => setState(() {}));
      case 10:
        return FormularioPreventivo(tarea: tarea, onCompletar: () => setState(() {}));
      case 11:
        return FormularioComponente(tarea: tarea, onCompletar: () => setState(() {}));
      case 12:
        return FormularioCondicion(tarea: tarea, onCompletar: () => setState(() {}));
      default:
        return const Center(
          child: Text(
            'Formulario no disponible',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        );
    }
  }
}

IconData getIconForCategory(String categoria) {
  switch (categoria.toLowerCase()) {
    case 'mantenimiento':
      return Icons.build;
    case 'inspección':
      return Icons.search;
    case 'verificación':
      return Icons.check;
    default:
      return Icons.task_alt;
  }
}
