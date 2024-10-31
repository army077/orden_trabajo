import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../entities/tareas.dart'; // Importa la entidad Tarea

class FormularioDesgaste extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar; // Callback para notificar el cambio

  const FormularioDesgaste({
    Key? key,
    required this.tarea,
    required this.onCompletar,
  }) : super(key: key);

  @override
  _FormularioDesgasteState createState() => _FormularioDesgasteState();
}

class _FormularioDesgasteState extends State<FormularioDesgaste> {
  String? opcionSeleccionada;
  bool botonHabilitado = false;
  Uint8List? _imageBytes; // Imagen seleccionada
  final TextEditingController _descripcionController = TextEditingController();

  final List<Map<String, dynamic>> opcionesDesgaste = [
    {"valor": 1, "texto": "1 - Reemplazo inmediato sugerido"},
    {"valor": 2, "texto": "2 - Reemplazar próximamente"},
    {"valor": 3, "texto": "3 - Ligero desgaste"},
    {"valor": 4, "texto": "4 - En buen estado"},
  ];

  @override
  void initState() {
    super.initState();
    // Inicializa los valores con los existentes en la tarea.
    opcionSeleccionada = widget.tarea.estadoDesgaste;
    botonHabilitado = opcionSeleccionada != null;
    _descripcionController.text = widget.tarea.descripcion ?? '';

    // Decodifica la imagen si existe en la tarea.
    if (widget.tarea.base64 != null) {
      _imageBytes = base64Decode(widget.tarea.base64!);
    }
  }

  // Selección de imagen desde la galería
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

  // Completar la tarea y guardar datos
  void _completarTarea() {
    if (opcionSeleccionada != null) {
      setState(() {
        widget.tarea.estadoDesgaste = opcionSeleccionada;
        widget.tarea.descripcion = _descripcionController.text;
        widget.tarea.completada = true;
      });

      widget.onCompletar(); // Notifica los cambios
      Navigator.pop(context); // Cierra el modal
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor selecciona una opción')),
      );
    }
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
          // Título de la tarea
          Text(
            widget.tarea.titulo,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Objetivo de la tarea
          Text(
            'Objetivo:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            widget.tarea.objetivo ?? 'Sin objetivo definido.',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),

          // Estado de Desgaste
          Text(
            'Estado de Desgaste:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Dropdown de opciones de desgaste
          DropdownButtonFormField<String>(
            isExpanded: true,
            value: opcionSeleccionada,
            decoration: const InputDecoration(
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
                botonHabilitado = true; // Habilita el botón
              });
            },
            validator: (valor) =>
                valor == null ? 'Por favor selecciona una opción' : null,
          ),
          const SizedBox(height: 16),

          // Descripción
          TextField(
            controller: _descripcionController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Descripción',
              hintText: 'Escribe una descripción detallada',
            ),
            maxLines: 3,
          ),
          const SizedBox(height: 16),

          // Selección de Imagen
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text('Seleccionar Imagen'),
          ),
          const SizedBox(height: 16),

          // Mostrar Imagen Seleccionada
          if (_imageBytes != null)
            GestureDetector(
              onTap: () => _showImageDialog(context),
              child: Image.memory(
                _imageBytes!,
                width: double.infinity,
                height: 300,
                fit: BoxFit.cover,
              ),
            ),
          const SizedBox(height: 16),

          // Botón Completar
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

  // Diálogo para mostrar la imagen
  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Image.memory(
          _imageBytes!,
          width: MediaQuery.of(context).size.width * 0.75,
          height: MediaQuery.of(context).size.height * 0.75,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
