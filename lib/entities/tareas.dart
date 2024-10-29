import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Tarea>> fetchTareas() async {
  final url = Uri.parse('https://teknia.app/api3/obtener_planes_trabajo_por_orden/10');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    return data.map((json) => Tarea.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las tareas');
  }
}

class Tarea {
  final int id;
  final String titulo;
  final String categoria;
  final String? objetivo;
  final int tiempoEstimado;
  final int posicion;
  final int noFormulario;
  bool completada;
  final DateTime fechaCreacion;

  // Nuevos campos para los datos ingresados en los formularios
  String? componente;  // Nombre del componente o equipo limpiado
  String? estatus;      // Estatus del trabajo realizado

  Tarea({
    required this.id,
    required this.titulo,
    required this.categoria,
    this.objetivo,
    this.tiempoEstimado = 0,
    required this.posicion,
    required this.noFormulario,
    this.completada = false,
    required this.fechaCreacion,
    this.componente,  // Inicializamos con valor nulo
    this.estatus,     // Inicializamos con valor nulo
  });

  // Deserialización de JSON a Tarea.
  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'],
      titulo: json['titulo'],
      categoria: json['clasificacion'],
      objetivo: json['objetivo'],
      tiempoEstimado: json['tiempo_estimado'] ?? 0,
      posicion: json['posicion'],
      noFormulario: json['no_formulario'],
      completada: json['completada'] ?? false,
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
      componente: json['componente'],  // Cargamos el nombre del componente (si existe)
      estatus: json['estatus'],        // Cargamos el estatus (si existe)
    );
  }

  // Serialización de Tarea a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'clasificacion': categoria,
      'objetivo': objetivo,
      'tiempo_estimado': tiempoEstimado,
      'posicion': posicion,
      'no_formulario': noFormulario,
      'completada': completada,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'componente': componente,  // Guardamos el nombre del componente
      'estatus': estatus,        // Guardamos el estatus
    };
  }
}
