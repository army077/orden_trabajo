import 'package:flutter/material.dart';
import '../entities/tareas.dart'; // Importa la entidad Tarea

class FormularioConDetalles extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar; // Callback para notificar el cambio

  const FormularioConDetalles({
    Key? key,
    required this.tarea,
    required this.onCompletar, // Recibe la función de callback
  }) : super(key: key);

  @override
  _FormularioConDetallesState createState() => _FormularioConDetallesState();
}

class _FormularioConDetallesState extends State<FormularioConDetalles> {
  String? opcionSeleccionada;
  bool botonHabilitado = false;

  final List<Map<String, dynamic>> opcionesDanio = [
    {"valor": 1, "texto": "1 - No funcional"},
    {
      "valor": 2,
      "texto": "2 - Falla próxima inminente (riesgo de otros daños/accidente)"
    },
    {
      "valor": 3,
      "texto": "3 - Falla próxima inminente (sin consecuencias graves)"
    },
    {"valor": 4, "texto": "4 - 100% Funcional"}
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
          Text(
            widget.tarea.titulo,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
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
          Text(
            'Tiempo estimado: ${widget.tarea.tiempoEstimado} minutos',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          SizedBox(height: 16),
          Text(
            '¿Con Daño?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Selecciona una opción',
            ),
            items: opcionesDanio.map((opcion) {
              return DropdownMenuItem<String>(
                value: opcion["valor"].toString(),
                child: Text(opcion["texto"]),
              );
            }).toList(),
            onChanged: (valor) {
              setState(() {
                opcionSeleccionada = valor;
                botonHabilitado = true;
              });
            },
          ),
          SizedBox(height: 16),
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
