import 'dart:convert';
import 'dart:io';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/entities/orden.dart';
import 'package:todo_app/functions/generate_pdf_function.dart';
import 'package:todo_app/services/auth_service.dart';
import 'package:todo_app/shared/form_ensamble.dart';
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
// import 'package:path_provider/path_provider.dart';
// import 'package:url_launcher/url_launcher.dart';

class MyDayScreen extends StatefulWidget {
  final Map<String, int> arguments;

  const MyDayScreen({Key? key, required this.arguments}) : super(key: key);

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
    print(
        'Cargando tareas para ID: ${widget.arguments['id_real']}, la orden agendada es: ${widget.arguments['id_tabla']}');
    super.initState();
    final int idReal = widget.arguments['id_real']!;
    final int idTabla = widget.arguments['id_tabla']!;
    futureTareas = _loadTareas(idReal, idTabla);
    WidgetsBinding.instance.addObserver(this); // Observamos el ciclo de vida
  }

  @override
  void dispose() {
    final int idReal = widget.arguments['id_real']!;
    final int idTabla = widget.arguments['id_tabla']!;
    _saveTareas(tareas, idReal, idTabla);
    WidgetsBinding.instance.removeObserver(this); // Quitamos el observer
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      final int idReal = widget.arguments['id_real']!;
      final int idTabla = widget.arguments['id_tabla']!;
      _saveTareas(tareas, idReal, idTabla); // Proporcionar los argumentos necesarios
      Navigator.pushReplacementNamed(context, '/login_screen');
    }
  }

  Future<List<Tarea>> _loadTareas(int idReal, int idTabla) async {
    print(
        'Llamando a _loadTareas con ID de actividades: $idReal y ID de orden agendada: $idTabla');
    final prefs = await SharedPreferences.getInstance();
    final llaveCache = 'tareas_${idReal}_$idTabla';
    String? tareasJson = prefs.getString(llaveCache);
    // Si hay datos en caché, los devuelve
    if (tareasJson != null) {
      print(
          'Tareas cargadas desde cache con ID de actividades: $idReal y ID de orden agendada: $idTabla');
      List<dynamic> data = json.decode(tareasJson);
      List<Tarea> tareas = data.map((json) => Tarea.fromJson(json)).toList();

      // Verificar si al menos una tarea está completada
      bool algunaCompletada = tareas.any((tarea) => tarea.completada);
      if (algunaCompletada) {
        return tareas;
      } else {
        print('Ninguna tarea está completada, reiniciando JSON.');
        List<Tarea> apiTareas = await fetchTareas(idReal);
        await _saveTareas(apiTareas, idReal, idTabla);
        return apiTareas;
      }
    }
  // Si no hay datos en caché, llama a la API
  print('Cargando tareas desde la API para ID real: $idReal y tabla: $idTabla');
  try {
    List<Tarea> apiTareas = await fetchTareas(idReal);
    await _saveTareas(apiTareas, idReal, idTabla); // Guarda las tareas en caché
    return apiTareas;
  } catch (e) {
    print('Error al cargar tareas: $e');
    return [];
  }
}

  Future<List<Tarea>> _resetTareas(int idReal, int idTabla) async {
    List<Tarea> apiTareas = await fetchTareas(idReal);
    await _saveTareas(apiTareas, idReal, idTabla);
    return apiTareas;
  }

  Future<void> _saveTareas(List<Tarea>? updatedTareas, int idReal, int idTabla) async {
    final prefs = await SharedPreferences.getInstance();
    final cacheKey = 'tareas_${idReal}_$idTabla';
    String tareasJson = json.encode(
      (updatedTareas ?? tareas).map((tarea) => tarea.toJson()).toList(),
    );
    await prefs.setString(cacheKey,
        tareasJson); // Prefijo con el ID
  }

  Future<void> signOut() async {
    await _authService.signOut();
    Navigator.pushReplacementNamed(context, '/login_screen');
  }

  int conteoCompletados = 0;
  int conteoTotal = 0;

  Future<void> _updateTareasPonderacion() async {
    setState(() {
      conteoCompletados = tareas.where((t) => t.completada).length;
      conteoTotal = tareas.length;
    });

    double avance =
        conteoTotal > 0 ? (conteoCompletados / conteoTotal) * 100 : 0.0;

    try {
      final response =
          await _apiProgreso(conteoCompletados, conteoTotal, avance);
      if (response) {
        print(
            'Progreso enviado correctamente: $conteoCompletados/$conteoTotal ($avance)');
      } else {
        print('Error al enviar el progreso.');
      }
    } catch (e) {
      print('Error en la API: $e');
    }
  }

  Future<bool> _apiProgreso(int completed, int total, double avance) async {
    try {
      List<Orden> ordenes = await fetchOrdenes(user!.email!);
      print(
          'Órdenes obtenidas: ${ordenes.map((o) => 'id: ${o.id_agenda}, numero: ${o.ordenNumero}').join(', ')}');
      Orden? ordenSeleccionada = ordenes.firstWhereOrNull((orden) =>
          orden.id == widget.arguments['id_real'] &&
          orden.id_agenda == widget.arguments['id_tabla']);
      print(
          'Orden agendada seleccionada:${ordenSeleccionada?.id_agenda} con actividades para orden:${ordenSeleccionada?.id}');

      if (ordenSeleccionada == null) {
        print(
            'no se encontró la orden con numero_orden: ${widget.arguments['id_real']}');
        return false;
      }
      final url = Uri.parse(
          'https://teknia.app/api3/actualizar_stavance/${ordenSeleccionada.id_agenda}');
      print('Enviando solicitud PUT a: $url');

      final response = await HttpClient().putUrl(url)
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'estatus': 'En progreso', 'avance': avance}));

      final result = await response.close();
      return result.statusCode == 200;
    } catch (e) {
      print('Error en la solicitud PUT: $e');
      return false;
    }
  }

  Future<void> sendTasksToGeneratePdfWithLoading() async {
    setState(() {
      _isLoading = true; // Activa el indicador de carga
    });

    try {
      // Llamamos a fetchOrdenes para obtener las órdenes asociadas al técnico
      List<Orden> ordenes = await fetchOrdenes(user!.email!);

      // Filtramos las órdenes para obtener solo la que coincide con el widget.selectedId
      List<Orden> ordenesFiltradas = ordenes
          .where((orden) => orden.id == widget.arguments['id_real'])
          .toList();

      // Asignamos solo la propiedad de ordenes al valor con el ID
      if (ordenesFiltradas.isNotEmpty) {
        Orden ordenSeleccionada = ordenesFiltradas.first;
        // Ejemplo de extracción del correo si necesitas usarlo

        print('Orden encontrada para el ID seleccionado: ${ordenSeleccionada}');
        print('Correo del cliente: ${ordenSeleccionada.correoCliente}');
        print('Nombre del cliente: ${ordenSeleccionada.contacto}');
        print('Nombre del cliente: ${ordenSeleccionada.noSerie}');
        print('Nombre del cliente: ${ordenSeleccionada.modelo}');
        print('Nombre del cliente: ${ordenSeleccionada.tecnicoAsignado}');
        await sendTasksToGeneratePdf(context, tareas,
            ordenSeleccionada.correoCliente ?? "", ordenSeleccionada);
      } else {
        print(
            'No se encontró ninguna orden con el ID: ${widget.arguments['id_real']}');
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
    final idReal = widget.arguments['id_real']!;
    final idTabla = widget.arguments['id_tabla']!;
    final cacheKey = 'tareas_${idReal}_$idTabla';
    await prefs.remove(cacheKey); // Elimina todo el contenido almacenado
    print('Caché limpiado para ID real: $idReal y tabla: $idTabla');
    setState(() {
      futureTareas = _resetTareas(idReal, idTabla);
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
          '${user?.displayName ?? ''}',
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
            _markAsCompleted(tarea, value ?? false);
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
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea, true));
      case 2:
        return FormularioEstadoEstetico(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea, true));
      case 3:
        return FormularioIncompleto(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea, true));
      case 4:
        return FormularioCalibracion(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea, true));
      case 5:
        return FormularioFueraDeRango(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea, true));
      case 6:
        return FormularioLimpieza(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea, true));
      case 7:
        return FormularioDesgaste(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea, true));
      case 8:
        return FormularioConFugas(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea, true));
      case 9:
        return FormularioConexiones(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea, true));
      case 10:
        return FormularioPreventivo(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea, true));
      case 11:
        return FormularioComponente(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea, true));
      case 12:
        return FormularioCondicion(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea, true));
      case 13:
        return FormularioEnsamble(
            tarea: tarea, onCompletar: () => _markAsCompleted(tarea, true));
      default:
        return const Center(
            child: Text('Formulario no disponible',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
    }
  }

  void _markAsCompleted(Tarea tarea, bool isCompleted) async {
    setState(() {
      tarea.completada = isCompleted;
    });
     
    try {
      final int idReal = widget.arguments['id_real']!;
      final int idTabla = widget.arguments['id_tabla']!;
      await _saveTareas(tareas, idReal, idTabla);
      await _updateTareasPonderacion();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(isCompleted
                ? 'Tarea marcada como completada.'
                : 'Tarea marcada como pendiente.')),
      );
    } catch (e) {
      print('Error al actualizar progreso: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error al actualizar el progreso.')),
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
    case 'limpieza':
      return Icons.cleaning_services;
    default:
      return Icons.task_alt;
  }
}
