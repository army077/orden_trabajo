import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import '../entities/tareas.dart'; // Importa tu modelo de entidad Tarea.

class FormularioConDetalles extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar;

  const FormularioConDetalles({
    Key? key,
    required this.tarea,
    required this.onCompletar,
  }) : super(key: key);

  @override
  _FormularioConDetallesState createState() => _FormularioConDetallesState();
}

class _FormularioConDetallesState extends State<FormularioConDetalles> {
  String? opcionSeleccionada;
  bool botonHabilitado = false;
  Uint8List? _imageBytes;
  TextEditingController _descripcionController = TextEditingController();

  final List<Map<String, dynamic>> opcionesDanio = [
    {"valor": 1, "texto": "1 - No funcional"},
    {"valor": 2, "texto": "2 - Falla inminente con riesgo"},
    {"valor": 3, "texto": "3 - Falla sin riesgo grave"},
    {"valor": 4, "texto": "4 - 100% Funcional"}
  ];

  @override
  void initState() {
    super.initState();
    opcionSeleccionada = widget.tarea.opcionDanio;
    botonHabilitado = opcionSeleccionada != null;
    if (widget.tarea.base64 != null) {
      _imageBytes = base64Decode(widget.tarea.base64!);
    }
    _descripcionController.text = widget.tarea.descripcion ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
        widget.tarea.base64 = base64Encode(imageBytes); // Guardar en la tarea.
      });
    }
  }

  void _completarTarea() {
    setState(() {
      widget.tarea.opcionDanio = opcionSeleccionada;
      widget.tarea.completada = true;
      widget.tarea.descripcion = _descripcionController.text;
    });
    widget.onCompletar(); // Notificar la actualización.
    Navigator.pop(context); // Cerrar el modal.
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.tarea.titulo,
              style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text('Objetivo:',
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(widget.tarea.descripcion ?? 'Sin objetivo definido.',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          Text('Tiempo estimado: ${widget.tarea.tiempoEstimado} minutos',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          const Text('¿Con Daño?',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: opcionSeleccionada,
            decoration: const InputDecoration(
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
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text('Seleccionar Imagen'),
          ),
          const SizedBox(height: 16),
          if (_imageBytes != null)
            GestureDetector(
              onTap: () => _showImageDialog(context),
              child: Image.memory(_imageBytes!,
                  width: double.infinity, height: 300, fit: BoxFit.cover),
            ),
          const SizedBox(height: 16),
          // Campo de descripción.
          TextField(
            controller: _descripcionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Descripción de la foto',
              hintText: 'Escribe una descripción detallada',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          Center(
            child: ElevatedButton(
              onPressed: botonHabilitado ? _completarTarea : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 226, 81, 98),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('Completar',
                  style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Calcula el 75% del ancho y alto disponibles.
            double width = constraints.maxWidth * 0.75;
            double height = constraints.maxHeight * 0.75;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Escala la imagen al 75% del tamaño disponible.
                Image.memory(
                  _imageBytes!,
                  width: width,
                  height: height,
                  fit: BoxFit
                      .contain, // Usa contain para mantener la proporción.
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cerrar'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
