import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../entities/tareas.dart'; // Importa la entidad Tarea

class FormularioCalibracion extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar; // Callback para notificar cambios

  const FormularioCalibracion({
    Key? key,
    required this.tarea,
    required this.onCompletar,
  }) : super(key: key);

  @override
  _FormularioCalibracionState createState() => _FormularioCalibracionState();
}

class _FormularioCalibracionState extends State<FormularioCalibracion> {
  String? opcionSeleccionada;
  bool botonHabilitado = false;
  Uint8List? _imageBytes;
  TextEditingController _descripcionController = TextEditingController();

  // Opciones de calibración
  final List<Map<String, dynamic>> opcionesCalibracion = [
    {"valor": 1, "texto": "1 - Descalibrado"},
    {"valor": 2, "texto": "2 - Ok"},
    {"valor": 3, "texto": "3 - No aplica"},
  ];

  @override
  void initState() {
    super.initState();
    // Cargar valores iniciales
    opcionSeleccionada = widget.tarea.estadoCalibracion;
    botonHabilitado = opcionSeleccionada != null;

    // Cargar imagen si existe
    if (widget.tarea.base64 != null) {
      _imageBytes = base64Decode(widget.tarea.base64!);
    }

    // Cargar descripción si existe
    _descripcionController.text = widget.tarea.descripcion ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
        widget.tarea.base64 = base64Encode(imageBytes); // Guardar en tarea
      });
    }
  }

  void _completarTarea() {
    setState(() {
      widget.tarea.estadoCalibracion = opcionSeleccionada;
      widget.tarea.descripcion = _descripcionController.text;
      widget.tarea.completada = true;
    });
    widget.onCompletar(); // Notificar cambios
    Navigator.pop(context); // Cerrar modal
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
        // Título
        Text(
          widget.tarea.titulo,
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        // Objetivo
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

        // Tiempo estimado
        Text(
          'Tiempo estimado: ${widget.tarea.tiempoEstimado} minutos',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        // Estado de calibración
        Text(
          'Estado de Calibración:',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          isExpanded: true,
          value: opcionSeleccionada,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            labelText: 'Selecciona una opción',
          ),
          items: opcionesCalibracion.map((opcion) {
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

        // Selección de imagen
        ElevatedButton(
          onPressed: _pickImage,
          child: const Text('Seleccionar Imagen'),
        ),
        const SizedBox(height: 16),

        // Mostrar imagen seleccionada
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

        // Descripción de la imagen
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

        // Botón "Completar" y "Desviación"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: botonHabilitado ? _completarTarea : null,
              child: const Text('Completar',
                  style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 226, 81, 98),
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
            ElevatedButton(
              onPressed: _completarTarea,
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
          ],
        ),
        const SizedBox(height: 16),

        // Contenedor de Referencias
        Container(
          padding: const EdgeInsets.all(8.0),
          color: const Color.fromARGB(255, 221, 221, 221),
          width: double.infinity, // Usa todo el ancho disponible
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

  // Mostrar imagen en un diálogo
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
