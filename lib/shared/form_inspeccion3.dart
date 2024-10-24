import 'package:flutter/material.dart';
import '../entities/tareas.dart'; // Importa la entidad Tarea

class FormularioIncompleto extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar; // Callback para notificar el cambio

  const FormularioIncompleto({
    Key? key,
    required this.tarea,
    required this.onCompletar, // Recibe la función de callback
  }) : super(key: key);

  @override
  _FormularioIncompletoState createState() => _FormularioIncompletoState();
}

class _FormularioIncompletoState extends State<FormularioIncompleto> {
  String opcionSeleccionada = "No"; // Valor por defecto

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

          // Selección Binaria: ¿Incompleto?
          Text(
            '¿Incompleto?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),

          // Radio Buttons para "Sí" / "No"
          Column(
            children: [
              RadioListTile<String>(
                title: Text('Sí'),
                value: 'Sí',
                groupValue: opcionSeleccionada,
                onChanged: (valor) {
                  setState(() {
                    opcionSeleccionada = valor!;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('No'),
                value: 'No',
                groupValue: opcionSeleccionada,
                onChanged: (valor) {
                  setState(() {
                    opcionSeleccionada = valor!;
                  });
                },
              ),
            ],
          ),

          SizedBox(height: 16),

          // Botón "Completar"
          Center(
            child: ElevatedButton(
              onPressed: _completarTarea,
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
