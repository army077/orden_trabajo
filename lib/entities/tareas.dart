import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Tarea>> fetchTareas() async {
  final url =
      Uri.parse('https://teknia.app/api3/obtener_planes_trabajo_por_orden/10');
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
  final int noFormulario; // Nueva propiedad
  bool completada;
  final DateTime fechaCreacion;

  Tarea({
    required this.id,
    required this.titulo,
    required this.categoria,
    this.objetivo,
    this.tiempoEstimado = 0,
    required this.posicion,
    required this.noFormulario, // Inicialización
    this.completada = false,
    required this.fechaCreacion,
  });

  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'],
      titulo: json['titulo'],
      categoria: json['clasificacion'],
      objetivo: json['objetivo'],
      tiempoEstimado: json['tiempo_estimado'] ?? 0,
      posicion: json['posicion'],
      noFormulario: json['no_formulario'], // Mapeo de la nueva propiedad
      completada: false,
      fechaCreacion: DateTime.parse(json['fecha_creacion']),
    );
  }
}
