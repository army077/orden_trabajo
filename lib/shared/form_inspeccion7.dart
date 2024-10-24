import 'package:flutter/material.dart';
import '../entities/tareas.dart'; // Importa la entidad Tarea

class FormularioDesgaste extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar; // Callback para notificar el cambio

  const FormularioDesgaste({
    Key? key,
    required this.tarea,
    required this.onCompletar, // Recibe la función de callback
  }) : super(key: key);

  @override
  _FormularioDesgasteState createState() => _FormularioDesgasteState();
}

class _FormularioDesgasteState extends State<FormularioDesgaste> {
  String? opcionSeleccionada; // Almacena la opción seleccionada
  bool botonHabilitado =
      false; // Controla si el botón "Completar" está habilitado

  // Opciones para evaluar el desgaste
  final List<Map<String, dynamic>> opcionesDesgaste = [
    {"valor": 1, "texto": "1 - Reemplazo inmediato sugerido"},
    {"valor": 2, "texto": "2 - Reemplazar próximamente"},
    {"valor": 3, "texto": "3 - Ligero desgaste"},
    {"valor": 4, "texto": "4 - En buen estado"},
  ];

  // Método para completar la tarea
  void _completarTarea() {
    if (opcionSeleccionada != null) {
      setState(() {
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

          // Selección del estado de desgaste
          Text(
            'Estado de Desgaste:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),

          // Dropdown con opciones de desgaste
          DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Selecciona el estado de desgaste',
            ),
            items: opcionesDesgaste.map((opcion) {
              return DropdownMenuItem<String>(
                value: opcion["valor"].toString(),
                child: Text(opcion["texto"]),
              );
            }).toList(),
            onChanged: (valor) {
              setState(() {
                opcionSeleccionada = valor;
                botonHabilitado =
                    true; // Habilita el botón al seleccionar una opción
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