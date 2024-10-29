import 'package:flutter/material.dart';
import '../entities/tareas.dart'; // Importa la entidad Tarea

class FormularioConFugas extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar; // Callback para notificar el cambio

  const FormularioConFugas({
    Key? key,
    required this.tarea,
    required this.onCompletar, // Recibe la función de callback
  }) : super(key: key);

  @override
  _FormularioConFugasState createState() => _FormularioConFugasState();
}

class _FormularioConFugasState extends State<FormularioConFugas> {
  String? opcionSeleccionada; // Almacena la opción seleccionada
  bool botonHabilitado = false; // Controla si el botón "Completar" está habilitado

  // Opciones para evaluar las fugas
  final List<Map<String, dynamic>> opcionesFugas = [
    {"valor": 1, "texto": "1 - Fuga importante (no operar)"},
    {"valor": 2, "texto": "2 - Fuga ligera (se puede operar)"},
    {"valor": 3, "texto": "3 - Sin Fugas"},
  ];

  @override
  void initState() {
    super.initState();
    // Inicializa el valor seleccionado con el guardado en la tarea, si existe
    opcionSeleccionada = widget.tarea.estadoFugas ?? opcionesFugas.first["valor"].toString();
    botonHabilitado = opcionSeleccionada != null;
  }

  // Método para completar la tarea y guardar los datos
  void _completarTarea() {
    if (opcionSeleccionada != null) {
      setState(() {
        // Guardamos el valor seleccionado en la tarea
        widget.tarea.estadoFugas = opcionSeleccionada;
        widget.tarea.completada = true; // Marca la tarea como completada
      });

      widget.onCompletar(); // Notifica a MyDayScreen para actualizar la lista
      Navigator.pop(context); // Cierra el modal
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor selecciona una opción')),
      );
    }
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

          // Selección del estado de las fugas
          Text(
            'Estado de Fugas:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),

          // Dropdown con opciones de fugas
          DropdownButtonFormField<String>(
            value: opcionSeleccionada,
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Selecciona el estado de fugas',
            ),
            items: opcionesFugas.map((opcion) {
              return DropdownMenuItem<String>(
                value: opcion["valor"].toString(),
                child: Text(opcion["texto"]),
              );
            }).toList(),
            onChanged: (valor) {
              setState(() {
                opcionSeleccionada = valor;
                botonHabilitado = valor != null;
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
                style: TextStyle(color: Colors.white),
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
