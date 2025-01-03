import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:todo_app/shared/form_desviacion.dart';
import '../entities/tareas.dart'; // Importa la entidad Tarea

class FormularioComponente extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar; // Callback para notificar el cambio

  const FormularioComponente({
    Key? key,
    required this.tarea,
    required this.onCompletar,
  }) : super(key: key);

  @override
  _FormularioComponenteState createState() => _FormularioComponenteState();
}

class _FormularioComponenteState extends State<FormularioComponente> {
  String? opcionSeleccionada; // Almacena la opción seleccionada
  bool botonHabilitado = false; // Controla si el botón "Completar" está habilitado

  // Opciones para la tarea del componente o equipo
  final List<Map<String, dynamic>> opcionesComponente = [
    {"valor": 1, "texto": "1 - No Aplica"},
    {"valor": 2, "texto": "2 - Pendiente (no iniciada)"},
    {"valor": 3, "texto": "3 - Incompleta"},
    {"valor": 4, "texto": "4 - Terminada"},
  ];

  @override
  void initState() {
    super.initState();
    _loadTaskState(); // Carga el estado inicial de la tarea
  }

  // Cargar estado guardado de la tarea
  Future<void> _loadTaskState() async {
    final prefs = await SharedPreferences.getInstance();
    final tareaData = prefs.getString(widget.tarea.id.toString());

    if (tareaData != null) {
      final Map<String, dynamic> tareaMap = jsonDecode(tareaData);
      setState(() {
        opcionSeleccionada = tareaMap['estadoComponente'];
        widget.tarea.completada = tareaMap['completada'] ?? false;
        botonHabilitado = opcionSeleccionada != null;
      });
    }
  }

  // Guardar el estado de la tarea en SharedPreferences
  Future<void> _saveTaskState() async {
    final prefs = await SharedPreferences.getInstance();
    final tareaData = {
      'estadoComponente': opcionSeleccionada,
      'completada': widget.tarea.completada,
    };
    prefs.setString(widget.tarea.id.toString(), jsonEncode(tareaData));
  }

  // Método para completar la tarea
  void _completarTarea() {
    if (opcionSeleccionada != null) {
      setState(() {
        widget.tarea.completada = true; // Marca la tarea como completada
      });
      _saveTaskState(); // Guardar el estado al completar la tarea
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
    padding: const EdgeInsets.all(16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título de la tarea
        Text(
          widget.tarea.titulo,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Objetivo de la tarea
        const Text(
          'Objetivo:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 4),
        Text(
          widget.tarea.objetivo ?? 'Sin objetivo definido.',
          style: const TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 16),

        // Selección del estado del componente o equipo
        const Text(
          'Estado del Componente o Equipo:',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Dropdown con opciones del estado del componente
        DropdownButtonFormField<String>(
          value: opcionSeleccionada,
          isExpanded: true,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Selecciona el estado del componente',
          ),
          items: opcionesComponente.map((opcion) {
            return DropdownMenuItem<String>(
              value: opcion["valor"].toString(),
              child: Text(opcion["texto"]),
            );
          }).toList(),
          onChanged: (valor) {
            setState(() {
              opcionSeleccionada = valor;
              botonHabilitado = true;
              widget.tarea.estadoCondicion = valor; // Guarda la selección en la tarea
            });
            _saveTaskState(); // Guardar el estado cada vez que se cambia una opción
          },
          validator: (valor) {
            if (valor == null || valor.isEmpty) {
              return 'Por favor selecciona una opción';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Botones "Completar" y "Desviación"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: botonHabilitado ? _completarTarea : null,
              child: const Text(
                'Completar',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 226, 81, 98),
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 15),
              ),
            ),
               ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          ReportDeviationForm(tarea: widget.tarea),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 226, 81, 98),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  'Desviación',
                  style: TextStyle(color: Colors.white),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Contenedor de "Referencias"
        Container(
          padding: const EdgeInsets.all(8.0),
          color: const Color.fromARGB(255, 221, 221, 221),
          width: double.infinity,
          child: const Text(
            'Referencias',
            style: TextStyle(fontSize: 18),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}
}
