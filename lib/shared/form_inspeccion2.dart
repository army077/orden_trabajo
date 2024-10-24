import 'package:flutter/material.dart';
import '../entities/tareas.dart'; // Importa la entidad Tarea

class FormularioEstadoEstetico extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar; // Callback para notificar el cambio

  const FormularioEstadoEstetico({
    Key? key,
    required this.tarea,
    required this.onCompletar, // Recibe la función de callback
  }) : super(key: key);

  @override
  _FormularioEstadoEsteticoState createState() =>
      _FormularioEstadoEsteticoState();
}

class _FormularioEstadoEsteticoState extends State<FormularioEstadoEstetico> {
  String? opcionSeleccionada; // Almacena la opción seleccionada
  bool botonHabilitado = false; // Controla el estado del botón "Completar"

  // Opciones para evaluar el estado estético
  final List<Map<String, dynamic>> opcionesEstetico = [
    {"valor": 1, "texto": "1 - Con rayaduras y golpes fuertes"},
    {"valor": 2, "texto": "2 - Con rayaduras o golpes leves"},
    {"valor": 3, "texto": "3 - En buen estado"},
  ];

  // Método para completar la tarea y cerrar el modal
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

          // Formulario de evaluación estética
          Text(
            'Estado Estético:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),

          DropdownButtonFormField<String>(
            isExpanded: true, // Asegura que ocupe todo el ancho
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Selecciona una opción',
            ),
            items: opcionesEstetico.map((opcion) {
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
