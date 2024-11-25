import 'package:flutter/material.dart';
import 'package:todo_app/shared/form_desviacion.dart';
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

  @override
  void initState() {
    super.initState();
    // Inicializa los campos con valores existentes si los hay
    _componenteController.text = widget.tarea.componente ?? '';
    opcionSeleccionada = widget.tarea.estatus;
    botonHabilitado = _componenteController.text.isNotEmpty && opcionSeleccionada != null;
  }

  // Método para completar la tarea y guardar los datos ingresados
  void _completarTarea() {
    setState(() {
      // Guardamos los datos ingresados en la tarea
      widget.tarea.componente = _componenteController.text;
      widget.tarea.estatus = opcionSeleccionada;
      widget.tarea.completada = true; // Marcamos la tarea como completada
    });

    widget.onCompletar(); // Notificamos al widget principal para actualizar y guardar
    Navigator.pop(context); // Cerramos el modal
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true, // Ajusta el diseño al aparecer el teclado
    appBar: AppBar(title: const Text('Formulario Limpieza')),
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

            // Campo de texto para el componente o equipo
            const Text(
              'Componente o equipo limpiado:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            TextFormField(
              controller: _componenteController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Nombre del componente o equipo',
              ),
              onChanged: (value) {
                setState(() {
                  botonHabilitado = value.isNotEmpty && opcionSeleccionada != null;
                });
              },
            ),
            const SizedBox(height: 16),

            // Selección del estatus de limpieza
            const Text(
              'Estatus de la limpieza:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),

            DropdownButtonFormField<String>(
              isExpanded: true,
              value: opcionSeleccionada,
              decoration: const InputDecoration(
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
              validator: (valor) =>
                  valor == null ? 'Por favor selecciona un estatus' : null,
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
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
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
      ),
    ),
  );
}


  @override
  void dispose() {
    _componenteController.dispose(); // Liberamos el controlador al cerrar
    super.dispose();
  }
}
