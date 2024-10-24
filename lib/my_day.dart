import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'entities/tareas.dart';
import 'shared/form_inspeccion1.dart'; // Importamos la clase pública
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


class _MyDayScreenState extends State<MyDayScreen> {
  late Future<List<Tarea>> futureTareas;
  Map<int, bool> checkboxHabilitado =
      {}; // Controla si el checkbox está habilitado por tarea

  @override
  void initState() {
    super.initState();
    futureTareas = fetchTareas();
  }

  Future <void> signOutWithGoogle () async {
    final googleSignIn = GoogleSignIn();
    await googleSignIn.signOut();
  }

  void signOut()async {
    FirebaseAuth.instance.signOut();
    await signOutWithGoogle();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          ElevatedButton(
            onPressed: signOut,
             child: Text('Cerrar'),
          ),
        ],

        title:  Text(
          'Orden Trabajo de  ${user?.displayName}',
          style: TextStyle(color: Colors.white),
        ), 
        backgroundColor: const Color.fromARGB(255, 221, 87, 78),
      ),
      body: FutureBuilder<List<Tarea>>(
        future: futureTareas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No hay tareas disponibles'));
          } else {
            List<Tarea> tareas = snapshot.data!;
            List<Tarea> completadas =
                tareas.where((t) => t.completada).toList();
            List<Tarea> noCompletadas =
                tareas.where((t) => !t.completada).toList();

            return ListView(
              padding: EdgeInsets.all(16.0),
              children: [
                if (completadas.isNotEmpty) ...[
                  _buildSectionTitle('Completadas', Icons.check_circle),
                  ..._buildTaskList(completadas),
                  SizedBox(height: 20),
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
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
            Icon(getIconForCategory(tarea.categoria),
                size: 20, color: Colors.grey),
            SizedBox(width: 8),
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
              : null, // Deshabilita si no se ha enviado el formulario
        ),
        onTap: () {
          _showTaskDetails(tarea);
        },
      );
    }).toList();
  }

  void _showTaskDetails(Tarea tarea) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return FractionallySizedBox(
          heightFactor: 0.8, // Ocupa el 80% de la pantalla
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: _getFormularioPorTipo(tarea), // Llamamos al switch-case
          ),
        );
      },
    );
  }

  Widget _getFormularioPorTipo(Tarea tarea) {
    switch (tarea.noFormulario) {
      case 1:
        return FormularioConDetalles(
          tarea: tarea,
          onCompletar: () {
            setState(() {}); // Actualiza la lista
          },
        );

      case 2:
        return FormularioEstadoEstetico(
          tarea: tarea,
          onCompletar: () {
            setState(() {}); // Actualiza la lista
          },
        );

      case 3:
        return FormularioIncompleto(
          tarea: tarea,
          onCompletar: () {
            setState(() {}); // Actualiza la lista
          },
        );

      case 4:
        return FormularioCalibracion(
          tarea: tarea,
          onCompletar: () {
            setState(() {}); // Actualiza la lista
          },
        );

      case 5:
        return FormularioFueraDeRango(
          tarea: tarea,
          onCompletar: () {
            setState(() {}); // Actualiza la lista
          },
        );

      case 6:
        return FormularioLimpieza(
          tarea: tarea,
          onCompletar: () {
            setState(() {}); // Actualiza la lista
          },
        );
      case 7:
        return FormularioDesgaste(
          tarea: tarea,
          onCompletar: () {
            setState(() {}); // Actualiza la lista
          },
        );

      case 8:
        return FormularioConFugas(
          tarea: tarea,
          onCompletar: () {
            setState(() {}); // Actualiza la lista
          },
        );

      case 9:
        return FormularioConexiones(
          tarea: tarea,
          onCompletar: () {
            setState(() {}); // Actualiza la lista
          },
        );

      case 10:
        return FormularioPreventivo(
          tarea: tarea,
          onCompletar: () {
            setState(() {}); // Actualiza la lista
          },
        );

      case 11:
        return FormularioComponente(
          tarea: tarea,
          onCompletar: () {
            setState(() {}); // Actualiza la lista
          },
        );

      case 12:
        return FormularioCondicion(
          tarea: tarea,
          onCompletar: () {
            setState(() {}); // Actualiza la lista
          },
        );

      default:
        return Center(
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
