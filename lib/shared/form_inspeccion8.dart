import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../entities/tareas.dart'; // Importa la entidad Tarea

class FormularioConFugas extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar; // Callback para notificar el cambio

  const FormularioConFugas({
    Key? key,
    required this.tarea,
    required this.onCompletar,
  }) : super(key: key);

  @override
  _FormularioConFugasState createState() => _FormularioConFugasState();
}

class _FormularioConFugasState extends State<FormularioConFugas> {
  String? opcionSeleccionada; // Almacena la opción seleccionada
  bool botonHabilitado =
      false; // Controla si el botón "Completar" está habilitado
  Uint8List? _imageBytes; // Imagen seleccionada
  final TextEditingController _descripcionController = TextEditingController();

  final List<Map<String, dynamic>> opcionesFugas = [
    {"valor": 1, "texto": "1 - Fuga importante (no operar)"},
    {"valor": 2, "texto": "2 - Fuga ligera (se puede operar)"},
    {"valor": 3, "texto": "3 - Sin Fugas"},
  ];

  @override
  void initState() {
    super.initState();
    // Inicializa valores desde la tarea.
    opcionSeleccionada =
        widget.tarea.estadoFugas ?? opcionesFugas.first["valor"].toString();
    botonHabilitado = opcionSeleccionada != null;
    _descripcionController.text = widget.tarea.descripcion ?? '';

    // Decodifica la imagen si está almacenada.
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
        widget.tarea.base64 = base64Encode(imageBytes); // Guarda en la tarea
      });
    }
  }

  // Completa la tarea y guarda los datos
  void _completarTarea() {
    if (opcionSeleccionada != null) {
      setState(() {
        widget.tarea.estadoFugas = opcionSeleccionada;
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
    _descripcionController.dispose(); // Limpia los controladores
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

          // Estado de Fugas
          Text(
            'Estado de Fugas:',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Dropdown con opciones de fugas
          DropdownButtonFormField<String>(
            value: opcionSeleccionada,
            isExpanded: true,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Selecciona el estado de fugas',
            ),
            items: opcionesFugas.map((opcion) {
              return DropdownMenuItem<String>(
                value: opcion["valor"].toString(),
                child: Text(opcion["texto"]),
              );
            }).toList(),
            onChanged: (valor) {
              setState(() {
                opcionSeleccionada = valor;
                botonHabilitado = valor != null;
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

          // Botón "Completar"
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

  // Diálogo para mostrar la imagen seleccionada
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
