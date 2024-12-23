import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../entities/tareas.dart';

class FormularioEnsamble extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar;

  const FormularioEnsamble({
    Key? key,
    required this.tarea,
    required this.onCompletar,
  }) : super(key: key);

  @override
  _FormularioEnsambleState createState() => _FormularioEnsambleState();
}

class _FormularioEnsambleState extends State<FormularioEnsamble> {
  TextEditingController _comentariosController = TextEditingController();
  Uint8List? _imageBytes;

  @override
  void initState() {
    super.initState();
    // Cargar los comentarios existentes (si los hay).
    _comentariosController.text = widget.tarea.descripcion ?? '';

    // Cargar una imagen existente (si está guardada en base64).
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
        widget.tarea.base64 = base64Encode(imageBytes); // Guardar imagen como base64.
      });
    }
  }

  void _completarTarea() async {
    // Actualiza la tarea localmente.
    setState(() {
      widget.tarea.descripcion = _comentariosController.text;
      widget.tarea.completada = true;
      widget.tarea.fechaCreacion = DateTime.now(); // Marca la fecha de completado.
    });

    // Llama la API para actualizar la tarea.
    try {
      final response = await _actualizarEstadoTarea(widget.tarea);
      if (response) {
        print('Tarea de ensamble actualizada correctamente.');
      } else {
        print('Error al actualizar la tarea de ensamble.');
      }
    } catch (e) {
      print('Error en la llamada a la API: $e');
    }

    // Notifica la finalización y cierra el formulario.
    widget.onCompletar();
    Navigator.pop(context);
  }

  Future<bool> _actualizarEstadoTarea(Tarea tarea) async {
    final url = Uri.parse('https://teknia.app/api3/actualizar_tarea/${tarea.id}');
    try {
      final response = await HttpClient().putUrl(url)
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({
          'id': tarea.id,
          'completada': true,
          'estatus': 'En proceso',
          'avance': '',
          'fecha_creacion': tarea.fechaCreacion?.toIso8601String()
        }));

      final result = await response.close();
      return result.statusCode == 200;
    } catch (e) {
      print('Error en la solicitud PUT: $e');
      return false;
    }
  }

  @override
  void dispose() {
    _comentariosController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Formulario Ensamble'),
        automaticallyImplyLeading: false,
      ),
      body: GestureDetector(
        onTap: () {
          // Oculta el teclado al tocar fuera del campo de texto.
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Título de la tarea.
              Text(
                widget.tarea.titulo,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Campo de comentarios.
              const Text(
                'Comentarios:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              TextField(
                controller: _comentariosController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Agrega notas o comentarios sobre el ensamble.',
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Botón para seleccionar una imagen.
              ElevatedButton(
                onPressed: _pickImage,
                child: const Text('Seleccionar Imagen'),
              ),
              const SizedBox(height: 16),

              // Mostrar imagen seleccionada.
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

              // Botón para completar la tarea.
              ElevatedButton(
                onPressed: _completarTarea,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                ),
                child: const Text(
                  'Completar Ensamble',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Mostrar imagen en un diálogo.
  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.memory(_imageBytes!, fit: BoxFit.contain),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cerrar'),
            ),
          ],
        ),
      ),
    );
  }
}
