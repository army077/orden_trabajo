import 'dart:convert';
import 'dart:io';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/entities/orden.dart';
import 'package:todo_app/functions/generate_pdf_function.dart';
import 'package:todo_app/services/auth_service.dart';
import '../entities/tareas.dart';
import '../shared/form_inspeccion1.dart';
import '../shared/form_inspeccion2.dart';
import '../shared/form_inspeccion3.dart';
import '../shared/form_inspeccion4.dart';
import '../shared/form_inspeccion5.dart';
import '../shared/form_limpieza6.dart';
import '../shared/form_inspeccion7.dart';
import '../shared/form_inspeccion8.dart';
import '../shared/form_inspeccion9.dart';
import '../shared/form_reemplazo10.dart';
import '../shared/form_ajuste11.dart';
import '../shared/form_inspeccion12.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MyDayScreen extends StatefulWidget {
  final int selectedId;

  const MyDayScreen({Key? key, required this.selectedId}) : super(key: key);

  @override
  _MyDayScreenState createState() => _MyDayScreenState();
}

final user = FirebaseAuth.instance.currentUser;

class _MyDayScreenState extends State<MyDayScreen> with WidgetsBindingObserver {
  late Future<List<Tarea>> futureTareas;
  final AuthService _authService = AuthService();
  List<Tarea> tareas = [];
  bool _isLoading = false; // Variable de estado para el indicador de carga

  @override
  void initState() {
    print('Cargando tareas para ID: ${widget.selectedId}');
    super.initState();
    futureTareas = _loadTareas(widget.selectedId);
    WidgetsBinding.instance.addObserver(this); // Observamos el ciclo de vida
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this); // Quitamos el observer
    _saveTareas(); // Guardamos las tareas antes de cerrar
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _saveTareas(); // Guardamos las tareas al salir
      Navigator.pushReplacementNamed(context, '/login_screen');
    }
  }

  Future<List<Tarea>> _loadTareas(int id) async {
    print('Llamando a _loadTareas con ID: $id');

    final prefs = await SharedPreferences.getInstance();
    String? tareasJson = prefs.getString('tareas_$id');

    // Si hay datos en caché, los devuelve
    if (tareasJson != null) {
      print('Tareas cargadas desde cache para ID: $id');
      List<dynamic> data = json.decode(tareasJson);
      List<Tarea> tareas = data.map((json) => Tarea.fromJson(json)).toList();

      // Verificar si al menos una tarea está completada
      bool algunaCompletada = tareas.any((tarea) => tarea.completada);
      if (!algunaCompletada) {
        print('Ninguna tarea está completada, reiniciando JSON.');
        List<Tarea> apiTareas = await fetchTareas(id);
        await _saveTareas(apiTareas);
        return apiTareas;
      }
      return tareas;
    }

    //d
    // Si no hay datos en cache, llama a la API
    print('Cargando tareas desde la API para ID: $id');
    try {
      List<Tarea> apiTareas = await fetchTareas(id);
      await _saveTareas(apiTareas); // Guarda las tareas en cache
      return apiTareas;
    } catch (e) {
      print('Error al cargar tareas: $e');
      return []; // Si ocurre un error, devuelve una lista vacía
    }
  }

  Future<List<Tarea>> _resetTareas(int id) async {
    List<Tarea> apiTareas = await fetchTareas(id);
    await _saveTareas(apiTareas);
    return apiTareas;
  }

  Future<void> _saveTareas([List<Tarea>? updatedTareas]) async {
    final prefs = await SharedPreferences.getInstance();
    String tareasJson = json.encode(
      (updatedTareas ?? tareas).map((tarea) => tarea.toJson()).toList(),
    );
    await prefs.setString(
        'tareas_${widget.selectedId}', tareasJson); // Prefijo con el ID
  }

  Future<void> signOut() async {
    await _authService.signOut();
    Navigator.pushReplacementNamed(context, '/login_screen');
  }

Future<void> sendTasksToGeneratePdfWithLoading() async {
  setState(() {
    _isLoading = true; // Activa el indicador de carga
  });

  try {
    // Llamamos a fetchOrdenes para obtener las órdenes asociadas al técnico
    List<Orden> ordenes = await fetchOrdenes(user!.email!);

    // Extraemos los correos de los clientes (pueden incluir nulos)
    List<String?> correosClientes = ordenes.map((orden) => orden.correoCliente).toList();

    // Filtramos valores nulos y duplicados
    List<String> correosFiltrados = correosClientes.whereType<String>().toSet().toList();

    print('Correos de clientes encontrados: $correosFiltrados');

    // Llamamos a la función de generación de PDF con cada correo
    for (String correoCliente in correosFiltrados) {
      await sendTasksToGeneratePdf(context, tareas, correoCliente);
    }
  } catch (e) {
    print("Error al generar el PDF: $e");
  } finally {
    setState(() {
      _isLoading = false; // Desactiva el indicador de carga
    });
  }
}



  Future<void> _clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Elimina todo el contenido almacenado
    print('Resetear el JSON. ---------------------------------');
    setState(() {
      futureTareas = _resetTareas(widget.selectedId);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Formulario limpiado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.white),
            onPressed:
                _clearPreferences, // Llama a la función para limpiar el formulario
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: signOut,
          ),
        ],
        title: Text(
          'Orden Trabajo de ${user?.displayName ?? 'Usuario'}',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF8B0000),
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
            tareas = snapshot.data!;
            List<Tarea> completadas =
                tareas.where((t) => t.completada).toList();
            List<Tarea> noCompletadas =
                tareas.where((t) => !t.completada).toList();

          

           return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Máquina: ${tareas.isNotEmpty ? tareas.first.maquina : 'Desconocida'}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
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
                  ),
                ),
              ],
            );

          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isLoading ? null : sendTasksToGeneratePdfWithLoading,
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
        child: _isLoading
            ? const CircularProgressIndicator(
                color: Colors.white,
              )
            : const Icon(Icons.send),
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
    return tareas.map((tarea) {
      return ListTile(
        leading: SizedBox(
          width: 46, // Define un ancho para que el contenido no desborde
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Icon(
                getIconForCategory(tarea.categoria),
                size: 22,
              ),
              const SizedBox(width: 3), // Espacio entre el ícono y el texto
              Text("${tarea.posicion}."),
            ],
          ),
        ),
        title: Text(tarea.titulo),
        trailing: Checkbox(
          value: tarea.completada,
          onChanged: (bool? value) {
            setState(() {
              tarea.completada = value ?? false;
            });
            _saveTareas();
          },
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
        return FormularioConDetalles(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea));
      case 2:
        return FormularioEstadoEstetico(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea));
      case 3:
        return FormularioIncompleto(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea));
      case 4:
        return FormularioCalibracion(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea));
      case 5:
        return FormularioFueraDeRango(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea));
      case 6:
        return FormularioLimpieza(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea));
      case 7:
        return FormularioDesgaste(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea));
      case 8:
        return FormularioConFugas(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea));
      case 9:
        return FormularioConexiones(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea));
      case 10:
        return FormularioPreventivo(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea));
      case 11:
        return FormularioComponente(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea));
      case 12:
        return FormularioCondicion(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea));
      default:
        return const Center(
            child: Text('Formulario no disponible',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
    }
  }

  void _markAsCompleted(Tarea tarea) async {
    setState(() {
      tarea.completada = true;
    });
    await _saveTareas();
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
    case 'limpieza':
      return Icons.cleaning_services;
    default:
      return Icons.task_alt;
  }
}
