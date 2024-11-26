import 'package:flutter/material.dart';
import 'package:todo_app/shared/form_desviacion.dart';
import '../entities/tareas.dart'; // Importa la entidad Tarea

class FormularioPreventivo extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar; // Callback para notificar el cambio

  const FormularioPreventivo({
    Key? key,
    required this.tarea,
    required this.onCompletar,
  }) : super(key: key);

  @override
  _FormularioPreventivoState createState() => _FormularioPreventivoState();
}

class _FormularioPreventivoState extends State<FormularioPreventivo> {
  String? opcionSeleccionada; // Almacena la opción seleccionada
  bool botonHabilitado = false; // Controla el estado del botón "Completar"

  // Opciones para la tarea preventiva
  final List<Map<String, dynamic>> opcionesPreventivo = [
    {"valor": 1, "texto": "1 - No Aplica"},
    {"valor": 2, "texto": "2 - Pendiente (no iniciada)"},
    {"valor": 3, "texto": "3 - Incompleta"},
    {"valor": 4, "texto": "4 - Terminada"},
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
        const SnackBar(content: Text('Por favor selecciona una opción')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true, // Ajusta el diseño al aparecer el teclado
      appBar: AppBar(title: const Text('Formulario Preventivo'), automaticallyImplyLeading: false,),
      body: GestureDetector(
        onTap: () {
          // Oculta el teclado al tocar fuera de los campos interactivos
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
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

              // Selección del estado preventivo
              const Text(
                'Estado Preventivo:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Dropdown con opciones preventivas
              DropdownButtonFormField<String>(
                isExpanded: true,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Selecciona el estado preventivo',
                ),
                items: opcionesPreventivo.map((opcion) {
                  return DropdownMenuItem<String>(
                    value: opcion["valor"].toString(),
                    child: Text(opcion["texto"]),
                  );
                }).toList(),
                onChanged: (valor) {
                  setState(() {
                    opcionSeleccionada = valor;
                    botonHabilitado = true; // Habilita el botón al seleccionar una opción
                  });
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
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: botonHabilitado ? _completarTarea : null,
                    child: const Text(
                      'Completar',
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 226, 81, 98),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ReportDeviationForm(tarea: widget.tarea),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 226, 81, 98),
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    child: const Text(
                      'Desviación',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Contenedor de "Referencias"
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 221, 221, 221),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: const Text(
                  'Referencias',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
