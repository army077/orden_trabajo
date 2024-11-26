import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app/shared/form_desviacion.dart';
import '../entities/tareas.dart'; // Modelo de entidad Tarea

class FormularioEstadoEstetico extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar;

  const FormularioEstadoEstetico({
    Key? key,
    required this.tarea,
    required this.onCompletar,
  }) : super(key: key);

  @override
  _FormularioEstadoEsteticoState createState() =>
      _FormularioEstadoEsteticoState();
}

class _FormularioEstadoEsteticoState extends State<FormularioEstadoEstetico> {
  String? opcionSeleccionada;
  bool botonHabilitado = false;
  Uint8List? _imageBytes;
  TextEditingController _descripcionController = TextEditingController();

  final List<Map<String, dynamic>> opcionesEstetico = [
    {"valor": 1, "texto": "1 - Con rayaduras y golpes fuertes"},
    {"valor": 2, "texto": "2 - Con rayaduras o golpes leves"},
    {"valor": 3, "texto": "3 - En buen estado"},
  ];

  @override
  void initState() {
    super.initState();
    opcionSeleccionada = widget.tarea.estadoEstetico;
    botonHabilitado = opcionSeleccionada != null;

    // Cargar la imagen si está guardada en la tarea
    if (widget.tarea.base64 != null) {
      _imageBytes = base64Decode(widget.tarea.base64!);
    }
    // Cargar la descripción si está guardada
    _descripcionController.text = widget.tarea.descripcion ?? '';
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Uint8List imageBytes = await pickedFile.readAsBytes();
      setState(() {
        _imageBytes = imageBytes;
        widget.tarea.base64 =
            base64Encode(imageBytes); // Guardar la imagen en la tarea.
      });
    }
  }

  void _completarTarea() {
    setState(() {
      widget.tarea.estadoEstetico = opcionSeleccionada;
      widget.tarea.descripcion = _descripcionController.text;
      widget.tarea.completada = true;
    });

    widget.onCompletar(); // Notificar cambios
    Navigator.pop(context); // Cerrar el modal
  }

  @override
  void dispose() {
    _descripcionController.dispose();
    super.dispose();
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true, // Ajusta el diseño cuando aparece el teclado
    appBar: AppBar(title: const Text('Formulario Estado Estético'), automaticallyImplyLeading: false,),
    body: GestureDetector(
      onTap: () {
        // Oculta el teclado al tocar fuera del campo de texto
        FocusScope.of(context).unfocus();
      },
      child: SingleChildScrollView(
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

            // Tiempo estimado
            Text(
              'Tiempo estimado: ${widget.tarea.tiempoEstimado} minutos',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),

            // Estado Estético
            const Text(
              'Estado Estético:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              isExpanded: true,
              value: opcionSeleccionada,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Selecciona una opción',
              ),
              items: opcionesEstetico.map((opcion) {
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

            // Botón para seleccionar imagen
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

            // Descripción de la foto
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

            // Botones "Completar" y "Desviación"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: botonHabilitado ? _completarTarea : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 226, 81, 98),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                  ),
                  child: const Text('Completar',
                      style: TextStyle(color: Colors.white)),
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
              width: double.infinity, // Usa todo el ancho disponible
              child: const Text(
                'Referencias',
                style: TextStyle(fontSize: 18),
                textAlign: TextAlign.center, // Centra el texto
              ),
            ),
          ],
        ),
      ),
    ),
  );
}



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
