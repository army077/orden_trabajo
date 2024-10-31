import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../entities/tareas.dart'; // Importa la entidad Tarea

class FormularioCondicion extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar; // Callback para notificar el cambio

  const FormularioCondicion({
    Key? key,
    required this.tarea,
    required this.onCompletar,
  }) : super(key: key);

  @override
  _FormularioCondicionState createState() => _FormularioCondicionState();
}

class _FormularioCondicionState extends State<FormularioCondicion> {
  String? opcionSeleccionada;
  bool botonHabilitado = false;
  Uint8List? _imageBytes; // Almacena la imagen seleccionada
  final TextEditingController _descripcionController = TextEditingController();

  final List<Map<String, dynamic>> opcionesCondicion = [
    {"valor": 2, "texto": "2 - Ok"},
    {"valor": 3, "texto": "3 - No aplica"},
  ];

  @override
  void initState() {
    super.initState();
    opcionSeleccionada = widget.tarea.estadoCondicion;
    botonHabilitado = opcionSeleccionada != null;
    _descripcionController.text = widget.tarea.descripcion ?? '';

    if (widget.tarea.base64 != null) {
      _imageBytes = base64Decode(widget.tarea.base64!);
    }
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
    if (opcionSeleccionada != null) {
      setState(() {
        widget.tarea.estadoCondicion = opcionSeleccionada;
        widget.tarea.descripcion = _descripcionController.text;
        widget.tarea.completada = true; // Marca la tarea como completada
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
          Text(
            widget.tarea.titulo,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
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
          Text(
            'Tiempo estimado: ${widget.tarea.tiempoEstimado} minutos',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Text(
            'Condición Actual:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<String>(
            value: opcionSeleccionada,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Selecciona una opción',
            ),
            items: opcionesCondicion.map((opcion) {
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
            validator: (valor) {
              if (valor == null || valor.isEmpty) {
                return 'Por favor selecciona una opción';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
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
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text('Seleccionar Imagen'),
          ),
          const SizedBox(height: 16),
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
          Center(
            child: ElevatedButton(
              onPressed: botonHabilitado ? _completarTarea : null,
              child: const Text(
                'Completar',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 226, 81, 98),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
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
