import 'dart:convert';
import 'package:http/http.dart' as http;

Future<List<Orden>> fetchOrdenes(String correoTecnico) async {
  final url =
      Uri.parse('https://teknia.app/api/ordenes_agendadas_tecnico/$correoTecnico');
  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);

    // Imprime la respuesta para depuración
    print('Respuesta de la API para técnico $correoTecnico: $data');

    return data.map((json) => Orden.fromJson(json)).toList();
  } else {
    throw Exception('Error al cargar las órdenes');
  }
}

class Orden {
  final int id;
  final String titulo;
  final String prioridad;
  final DateTime fechaEstimada;
  final int reservaId;
  final String ordenNumero;
  final int tiempoTotal;
  final String creadoPor;
  final String familia;
  final String maquina;
  final String razonSocial;
  final String username;
  final String email;
  final String contacto;
  final String? correoCliente;
  final String modelo;
  final String noSerie;
  final String tecnicoAsignado;
  final String correoTecnicoAsignado;
  final DateTime createdAt;
  final DateTime updatedAt;

  Orden({
    required this.id,
    required this.titulo,
    required this.prioridad,
    required this.fechaEstimada,
    required this.reservaId,
    required this.ordenNumero,
    required this.tiempoTotal,
    required this.creadoPor,
    required this.familia,
    required this.maquina,
    required this.razonSocial,
    required this.username,
    required this.email,
    required this.contacto,
    this.correoCliente,
    required this.modelo,
    required this.noSerie,
    required this.tecnicoAsignado,
    required this.correoTecnicoAsignado,
    required this.createdAt,
    required this.updatedAt,
  });

  // Deserialización de JSON a Orden.
  factory Orden.fromJson(Map<String, dynamic> json) {
    return Orden(
      id: json['id'] ?? 0,
      titulo: json['titulo'] ?? 'Sin título',
      prioridad: json['prioridad'] ?? 'Sin prioridad',
      fechaEstimada: DateTime.parse(json['fecha_estimada']),
      reservaId: json['reserva_id'] ?? 0,
      ordenNumero: json['orden_numero'] ?? '0',
      tiempoTotal: json['tiempo_total'] ?? 0,
      creadoPor: json['creado_por'] ?? 'Desconocido',
      familia: json['familia'] ?? 'Sin familia',
      maquina: json['maquina'] ?? 'Sin máquina',
      razonSocial: json['razon_social'] ?? 'Sin razón social',
      username: json['username'] ?? 'Desconocido',
      email: json['email'] ?? 'Sin email',
      contacto: json['contacto'] ?? 'Sin contacto',
      correoCliente: json['correo_cliente'],
      modelo: json['modelo'] ?? 'Sin modelo',
      noSerie: json['no_serie'] ?? 'Sin número de serie',
      tecnicoAsignado: json['tecnico_asignado'] ?? 'Sin técnico asignado',
      correoTecnicoAsignado:
          json['correo_tecnico_asignado'] ?? 'Sin correo técnico',
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  // Serialización de Orden a JSON.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'prioridad': prioridad,
      'fecha_estimada': fechaEstimada.toIso8601String(),
      'reserva_id': reservaId,
      'orden_numero': ordenNumero,
      'tiempo_total': tiempoTotal,
      'creado_por': creadoPor,
      'familia': familia,
      'maquina': maquina,
      'razon_social': razonSocial,
      'username': username,
      'email': email,
      'contacto': contacto,
      'correo_cliente': correoCliente,
      'modelo': modelo,
      'no_serie': noSerie,
      'tecnico_asignado': tecnicoAsignado,
      'correo_tecnico_asignado': correoTecnicoAsignado,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
