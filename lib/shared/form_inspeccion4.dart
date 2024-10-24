import 'package:flutter/material.dart';
import '../entities/tareas.dart'; // Importa la entidad Tarea

class FormularioCalibracion extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar; // Callback para notificar el cambio

  const FormularioCalibracion({
    Key? key,
    required this.tarea,
    required this.onCompletar, // Recibe la función de callback
  }) : super(key: key);

  @override
  _FormularioCalibracionState createState() => _FormularioCalibracionState();
}

class _FormularioCalibracionState extends State<FormularioCalibracion> {
  String? opcionSeleccionada; // Almacena la opción seleccionada
  bool botonHabilitado = false; // Controla si el botón "Completar" está activo

  // Opciones de calibración
  final List<Map<String, dynamic>> opcionesCalibracion = [
    {"valor": 1, "texto": "1 - Descalibrado"},
    {"valor": 2, "texto": "2 - Ok"},
    {"valor": 3, "texto": "3 - No aplica"},
  ];

  void _completarTarea() {
    setState(() {
      widget.tarea.completada = true; // Marca la tarea como completada
    });

    widget.onCompletar(); // Notifica a MyDayScreen para actualizar la lista
    Navigator.pop(context); // Cierra el modal
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la tarea
          Text(
            widget.tarea.titulo,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),

          // Objetivo de la tarea
          Text(
            'Objetivo:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            widget.tarea.objetivo ?? 'Sin objetivo definido.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),

          // Tiempo estimado
          Text(
            'Tiempo estimado: ${widget.tarea.tiempoEstimado} minutos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 16),

          // Selección de Calibración
          Text(
            'Estado de Calibración:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),

          // Dropdown con opciones de calibración
          DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Selecciona una opción',
            ),
            items: opcionesCalibracion.map((opcion) {
              return DropdownMenuItem<String>(
                value: opcion["valor"].toString(),
                child: Text(opcion["texto"]),
              );
            }).toList(),
            onChanged: (valor) {
              setState(() {
                opcionSeleccionada = valor;
                botonHabilitado = true; // Habilita el botón "Completar"
              });
            },
            validator: (valor) {
              if (valor == null || valor.isEmpty) {
                return 'Por favor selecciona una opción';
              }
              return null;
            },
          ),
          SizedBox(height: 16),

          // Botón "Completar"
          Center(
            child: ElevatedButton(
              onPressed: botonHabilitado ? _completarTarea : null,
              child: Text(
                'Completar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 226, 81, 98),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
