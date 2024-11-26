import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:todo_app/shared/form_desviacion.dart';
import '../entities/tareas.dart'; // Importa la entidad Tarea

class FormularioFueraDeRango extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar; // Callback para notificar el cambio

  const FormularioFueraDeRango({
    Key? key,
    required this.tarea,
    required this.onCompletar,
  }) : super(key: key);

  @override
  _FormularioFueraDeRangoState createState() => _FormularioFueraDeRangoState();
}

class _FormularioFueraDeRangoState extends State<FormularioFueraDeRango> {
  String opcionSeleccionada = "No"; // Valor predeterminado
  bool botonHabilitado = false;
  Uint8List? _imageBytes; // Imagen seleccionada

  final TextEditingController _limiteSuperiorController =
      TextEditingController();
  final TextEditingController _limiteInferiorController =
      TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();

  String? unidadMedidaSeleccionada; // Unidad de medida seleccionada

  @override
  void initState() {
    super.initState();
    // Inicializa los campos con los datos existentes de la tarea.
    opcionSeleccionada = widget.tarea.fueraDeRango ?? "No";
    _limiteSuperiorController.text =
        widget.tarea.limiteSuperior?.toString() ?? '';
    _limiteInferiorController.text =
        widget.tarea.limiteInferior?.toString() ?? '';
    unidadMedidaSeleccionada = widget.tarea.unidadMedida ?? '';
    _descripcionController.text = widget.tarea.descripcion ?? '';

    if (widget.tarea.base64 != null) {
      _imageBytes = base64Decode(widget.tarea.base64!);
    }
    _validarFormulario(); // Validamos al inicio.
  }

  // Validación de los campos
  void _validarFormulario() {
    setState(() {
      botonHabilitado = _esDouble(_limiteSuperiorController.text) &&
          _esDouble(_limiteInferiorController.text) &&
          unidadMedidaSeleccionada != null;
    });
  }

  // Verifica si un valor es convertible a double
  bool _esDouble(String value) {
    return double.tryParse(value) != null;
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
    if (botonHabilitado) {
      setState(() {
        widget.tarea.fueraDeRango = opcionSeleccionada;
        widget.tarea.limiteSuperior =
            double.parse(_limiteSuperiorController.text);
        widget.tarea.limiteInferior =
            double.parse(_limiteInferiorController.text);
        widget.tarea.unidadMedida = unidadMedidaSeleccionada;
        widget.tarea.descripcion = _descripcionController.text;
        widget.tarea.completada = true;
              widget.tarea.fechaCreacion = DateTime.now();
      });

      widget.onCompletar(); // Notificamos los cambios
      Navigator.pop(context); // Cerrar modal
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Por favor completa todos los campos correctamente')),
      );
    }
  }

  @override
  void dispose() {
    _limiteSuperiorController.dispose();
    _limiteInferiorController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
Widget build(BuildContext context) {
  return Scaffold(
    resizeToAvoidBottomInset: true, // Ajusta el diseño cuando aparece el teclado
    appBar: AppBar(title: const Text('Formulario Fuera de Rango'), automaticallyImplyLeading: false,),
    body: GestureDetector(
      onTap: () {
        // Oculta el teclado al tocar fuera de los campos de texto
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

            // ¿Fuera de Rango?
            const Text(
              '¿Fuera de Rango?',
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
                      opcionSeleccionada = valor!;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text('No'),
                  value: 'No',
                  groupValue: opcionSeleccionada,
                  onChanged: (valor) {
                    setState(() {
                      opcionSeleccionada = valor!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Límite Superior
            _buildTextField(
              controller: _limiteSuperiorController,
              label: 'Límite Superior',
              hint: 'Ingrese el límite superior',
            ),
            const SizedBox(height: 16),

            // Límite Inferior
            _buildTextField(
              controller: _limiteInferiorController,
              label: 'Límite Inferior',
              hint: 'Ingrese el límite inferior',
            ),
            const SizedBox(height: 16),

            // Unidad de Medida
            DropdownButtonFormField<String>(
              value: unidadMedidaSeleccionada,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Unidad de Medida',
                hintText: 'Seleccione una unidad de medida',
              ),
              items: const [
                DropdownMenuItem(value: '', child: Text('')),
                DropdownMenuItem(value: 'cm', child: Text('cm')),
                DropdownMenuItem(value: 'mts', child: Text('mts')),
                DropdownMenuItem(value: 'volts', child: Text('volts')),
                DropdownMenuItem(value: 'amp', child: Text('amp')),
                DropdownMenuItem(value: 'litros', child: Text('litros')),
              ],
              onChanged: (String? value) {
                setState(() {
                  unidadMedidaSeleccionada = value;
                });
                _validarFormulario();
              },
            ),
            const SizedBox(height: 16),

            // Descripción
            TextField(
              controller: _descripcionController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Descripción',
                hintText: 'Escriba una descripción detallada',
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

            // Botón Completar y Desviación
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: botonHabilitado ? _completarTarea : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 226, 81, 98),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
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
                    padding:
                        const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  ),
                  child: const Text(
                    'Desviación',
                    style: TextStyle(color: Colors.white),
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
      ),
    ),
  );
}


  // Método para construir TextFields reutilizables
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        labelText: label,
        hintText: hint,
      ),
      onChanged: (_) => _validarFormulario(),
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
