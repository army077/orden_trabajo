import 'package:flutter/material.dart';
import '../entities/tareas.dart'; // Importa la entidad Tarea

class FormularioLimpieza extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar; // Callback para notificar el cambio

  const FormularioLimpieza({
    Key? key,
    required this.tarea,
    required this.onCompletar, // Recibe la función de callback
  }) : super(key: key);

  @override
  _FormularioLimpiezaState createState() => _FormularioLimpiezaState();
}

class _FormularioLimpiezaState extends State<FormularioLimpieza> {
  final TextEditingController _componenteController = TextEditingController();
  String? opcionSeleccionada; // Almacena el estatus seleccionado
  bool botonHabilitado = false; // Controla el estado del botón "Completar"

  // Opciones de estatus de limpieza
  final List<Map<String, dynamic>> opcionesEstatus = [
    {"valor": 1, "texto": "1 - No Aplica"},
    {"valor": 2, "texto": "2 - Pendiente (no iniciada)"},
    {"valor": 3, "texto": "3 - Incompleta"},
    {"valor": 4, "texto": "4 - Terminada"},
  ];

  // Método para completar la tarea
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

          // Campo de texto para el componente o equipo
          Text(
            'Componente o equipo limpiado:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),

          TextFormField(
            controller: _componenteController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Nombre del componente o equipo',
            ),
            onChanged: (value) {
              setState(() {
                botonHabilitado =
                    value.isNotEmpty && opcionSeleccionada != null;
              });
            },
          ),
          SizedBox(height: 16),

          // Selección del estatus de limpieza
          Text(
            'Estatus de la limpieza:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),

          DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Selecciona un estatus',
            ),
            items: opcionesEstatus.map((opcion) {
              return DropdownMenuItem<String>(
                value: opcion["valor"].toString(),
                child: Text(opcion["texto"]),
              );
            }).toList(),
            onChanged: (valor) {
              setState(() {
                opcionSeleccionada = valor;
                botonHabilitado =
                    _componenteController.text.isNotEmpty && valor != null;
              });
            },
            validator: (valor) {
              if (valor == null || valor.isEmpty) {
                return 'Por favor selecciona un estatus';
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

  @override
  void dispose() {
    _componenteController.dispose(); // Liberar el controlador al cerrar
    super.dispose();
  }
}
