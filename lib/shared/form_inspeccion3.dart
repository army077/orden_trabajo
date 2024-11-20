import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../entities/tareas.dart'; // Importa la entidad Tarea.

class FormularioIncompleto extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar;

  const FormularioIncompleto({
    Key? key,
    required this.tarea,
    required this.onCompletar,
  }) : super(key: key);

  @override
  _FormularioIncompletoState createState() => _FormularioIncompletoState();
}

class _FormularioIncompletoState extends State<FormularioIncompleto> {
  String? opcionSeleccionada;
  Uint8List? _imageBytes;
  TextEditingController _descripcionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Inicializa la opción seleccionada
    opcionSeleccionada = widget.tarea.incompleto ?? "No";

    // Cargar imagen si ya existe en la tarea.
    if (widget.tarea.base64 != null) {
      _imageBytes = base64Decode(widget.tarea.base64!);
    }

    // Cargar descripción si ya existe en la tarea.
    _descripcionController.text = widget.tarea.descripcion ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
        widget.tarea.base64 = base64Encode(imageBytes); // Guardar imagen.
      });
    }
  }

  void _completarTarea() {
    setState(() {
      widget.tarea.incompleto = opcionSeleccionada;
      widget.tarea.descripcion = _descripcionController.text;
      widget.tarea.completada = true; // Marca la tarea como completada.
    });

    widget.onCompletar(); // Notifica los cambios.
    Navigator.pop(context); // Cierra el modal.
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
          // Título de la tarea.
          Text(
            widget.tarea.titulo,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),

          // Objetivo de la tarea.
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

          // Tiempo estimado.
          Text(
            'Tiempo estimado: ${widget.tarea.tiempoEstimado} minutos',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),

          // Selección binaria: ¿Incompleto?
          const Text(
            '¿Incompleto?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Column(
            children: [
              RadioListTile<String>(
                title: const Text('Sí'),
                value: 'Sí',
                groupValue: opcionSeleccionada,
                onChanged: (valor) {
                  setState(() {
                    opcionSeleccionada = valor;
                  });
                },
              ),
              RadioListTile<String>(
                title: const Text('No'),
                value: 'No',
                groupValue: opcionSeleccionada,
                onChanged: (valor) {
                  setState(() {
                    opcionSeleccionada = valor;
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Botón para seleccionar imagen.
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

          // Botón "Completar".
          Row(
            children: [
              Center(
                child: ElevatedButton(
                  onPressed: _completarTarea,
                  child: const Text('Completar',
                      style: TextStyle(color: Colors.white)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 226, 81, 98),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ),
              SizedBox(width: 50,),
               Center(
                child: ElevatedButton(
                  onPressed:  _completarTarea ,
                  child: const Text(
                    'Desviación',
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 226, 81, 98),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                ),
              ),   
              Row(
              children: [
                Container(
                  color: const Color.fromARGB(255, 221, 221, 221),
                  height: 80,
                  width: 320,
                
                  child: Text(
                    
                    'Referencias', style: TextStyle(fontSize: 18, ),
                    ),
                  
                )
              
            ],
          )
            ],
          ),
        ],
      ),
    );
  }

  // Mostrar imagen en un diálogo.
  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: LayoutBuilder(
          builder: (context, constraints) {
            double width = constraints.maxWidth * 0.75;
            double height = constraints.maxHeight * 0.75;

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.memory(
                  _imageBytes!,
                  width: width,
                  height: height,
                  fit: BoxFit.contain,
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
