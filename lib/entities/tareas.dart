import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Tarea>> fetchTareas(int id) async {
  print('fetchTareas llamada con ID: $id');
  final url =
      Uri.parse('https://teknia.app/api3/obtener_planes_trabajo_por_orden/$id');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);

    // Imprime la respuesta para ver si los datos están llegando correctamente
    print('Respuesta de la API para ID $id: $data');

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
  final String? maquina;

  // Nuevos campos para guardar datos de los formularios
  String? componente; // Nombre del componente o equipo limpiado
  String? estatus; // Estado del trabajo realizado
  String? opcionDanio; // Opción seleccionada para daño
  String? estadoEstetico; // Estado estético
  String? fueraDeRango; // ¿Está fuera de rango?
  double? limiteSuperior; // Límite superior (numérico)
  double? limiteInferior; // Límite inferior (numérico)
  String? unidadMedida; // Unidad de medida
  String? estadoConexion;
  String? estadoCondicion;
  String? incompleto;
  String? estadoCalibracion;
  String? estadoDesgaste;
  String? estadoFugas; // Estado de las fugas
  String? descripcion;
  String? base64;
  
   // Nueva propiedad para la imagen en Base64.

  // Nuevos campos para desviaciones
  String? tipoDesviacion; // Tipo de desviación (Crítica, No Crítica)
  String? impacto; // Impacto en el mantenimiento
  String? clasificacionDesviacion; // Clasificación de la desviación
  String? descripcionDesviacion; // Descripción de la desviación
  String? medidasCorrectivas; // Medidas correctivas
  String? evidenciaBase64; // Imagen en Base64 como evidencia

  Tarea({
    required this.id,
    required this.titulo,
    required this.categoria,
    required this.maquina,
    this.objetivo,
    this.tiempoEstimado = 0,
    required this.posicion,
    required this.noFormulario,
    this.completada = false,
    required this.fechaCreacion,
    this.componente,
    this.estatus,
    this.opcionDanio,
    this.estadoEstetico,
    this.fueraDeRango,
    this.limiteSuperior,
    this.limiteInferior,
    this.unidadMedida,
    this.estadoConexion,
    this.estadoCondicion,
    this.incompleto,
    this.estadoCalibracion,
    this.estadoDesgaste,
    this.estadoFugas,
    this.descripcion,
    this.base64, // Inicializa en null por defecto.
    this.tipoDesviacion,
    this.impacto,
    this.clasificacionDesviacion,
    this.descripcionDesviacion,
    this.medidasCorrectivas,
    this.evidenciaBase64,
  });

  // Deserialización de JSON a Tarea.
  factory Tarea.fromJson(Map<String, dynamic> json) {
    return Tarea(
      id: json['id'] ?? 0, // Asignar 0 si el valor es null
      titulo: json['titulo'] ??
          'Sin título', // Asignar texto por defecto si es null
      categoria: json['clasificacion'] ?? 'Sin categoría',
      objetivo: json['objetivo'],
      tiempoEstimado: json['tiempo_estimado'] ?? 0, // Asignar 0 si es null
      posicion: json['posicion'] ?? 0, // Asignar 0 si es null
      noFormulario: json['no_formulario'] ?? 0, // Asignar 0 si es null
      completada: json['completada'] ?? false, // Asignar false si es null
      fechaCreacion: json['fecha_creacion'] != null
          ? DateTime.parse(json['fecha_creacion'])
          : DateTime.now(), // Usar la fecha actual si es null
      componente: json['componente'],
      estatus: json['estatus'],
      opcionDanio: json['opcion_danio'],
      estadoEstetico: json['estado_estetico'],
      fueraDeRango: json['fuera_de_rango'],
      limiteSuperior: (json['limite_superior'] != null)
          ? double.parse(json['limite_superior'].toString())
          : null,
      limiteInferior: (json['limite_inferior'] != null)
          ? double.parse(json['limite_inferior'].toString())
          : null,
      unidadMedida: json['unidad_medida'],
      maquina: json['maquina'] ,
      estadoConexion: json['estado_conexion'],
      incompleto: json['incompleto'],
      estadoCalibracion: json['estado_calibracion'],
      estadoDesgaste: json['estado_desgaste'],
      estadoFugas: json['estado_fugas'],
      descripcion: json['descripcion'],
      base64: json['base64'],
      estadoCondicion: json['estadoCondicion'],
      tipoDesviacion: json['tipo_desviacion'],
      impacto: json['impacto'],
      clasificacionDesviacion: json['clasificacion_desviacion'],
      descripcionDesviacion: json['descripcion_desviacion'],
      medidasCorrectivas: json['medidas_correctivas'],
      evidenciaBase64: json['evidencia_base64'],
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
      'maquina': maquina,
      'posicion': posicion,
      'no_formulario': noFormulario,
      'completada': completada,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'componente': componente,
      'estatus': estatus,
      'opcion_danio': opcionDanio,
      'estado_estetico': estadoEstetico,
      'fuera_de_rango': fueraDeRango,
      'limite_superior': limiteSuperior,
      'limite_inferior': limiteInferior,
      'unidad_medida': unidadMedida,
      'estado_conexion': estadoConexion,
      'incompleto': incompleto,
      'estado_calibracion': estadoCalibracion,
      'estado_fugas': estadoFugas,
      'descripcion': descripcion,
      'base64': base64,
      'estadoCondicion': estadoCondicion,
      'tipo_desviacion': tipoDesviacion,
      'impacto': impacto,
      'clasificacion_desviacion': clasificacionDesviacion,
      'descripcion_desviacion': descripcionDesviacion,
      'medidas_correctivas': medidasCorrectivas,
      'evidencia_base64': evidenciaBase64,
    };
  }
}
