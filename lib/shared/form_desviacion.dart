import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ReportDeviationForm extends StatefulWidget {
  const ReportDeviationForm({Key? key}) : super(key: key);

  @override
  _ReportDeviationFormState createState() => _ReportDeviationFormState();
}

class _ReportDeviationFormState extends State<ReportDeviationForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _ticketNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _medidasController = TextEditingController();

  Uint8List? _evidenceImage; // Variable para almacenar la imagen
  bool _isSubmitting = false;

  String? _selectedDesviacion; // Variable para la desviación seleccionada

  String? _selectedImpacto; // Variable para la desviación seleccionada

  String? _selectedDeviation; // Variable para la desviación seleccionada

  // Lista de desviaciones
  final List<String> _desviacionTypes = [
    'Crítica',
    'No Crítica',
  ];

  // Lista de desviaciones
  final List<String> _impactoTypes = [
    'Problema en Garantía',
    'Problema en Servicio Pagado',
    'Requiere Mantenimiento Correctivo',
  ];

  // Lista de desviaciones
  final List<String> _deviationTypes = [
    'Desalineación mecánica',
    'Juego excesivo',
    'Desgaste de piezas',
    'Errores de software',
    'Fugas en sistema hidráulico',
    'Herramienta desgastada',
    'Flujo inadecuado de refrigerante',
    'Material incorrecto',
    'Sensores defectuosos',
    'Problemas de calibración',
  ];

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _evidenceImage = bytes;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSubmitting = true;
      });

      // Crear el JSON con la información ingresada
      Map<String, dynamic> formData = {
        "ticket": _ticketNameController.text,
        "tipoDesviacion": _selectedDesviacion,
        "impacto": _selectedImpacto,
        "clasificacion": _selectedDeviation,
        "descripcion": _descriptionController.text,
        "medidas": _medidasController.text,
        "evidencia": _evidenceImage != null
            ? base64Encode(_evidenceImage!) // Convertir la imagen a Base64
            : null,
      };

      print("Formulario enviado:");
      print(jsonEncode(formData)); // Imprime el JSON en consola

      // Simular el envío de datos
      Future.delayed(const Duration(seconds: 2), () {
        setState(() {
          _isSubmitting = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Reporte enviado con éxito'),
          backgroundColor: Colors.green,
        ));
        // Limpia los campos después de enviar
        _ticketNameController.clear();
        _descriptionController.clear();
        setState(() {
          _evidenceImage = null;
          _selectedDeviation = null; // Resetea el Dropdown
        });
      });
    }
  }

  @override
  void dispose() {
    _ticketNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reporte de Desviación'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Nombre de la máquina
              TextFormField(
                controller: _ticketNameController,
                decoration: const InputDecoration(
                  labelText: 'Ticket',
                  border: OutlineInputBorder(),
                  hintText: 'Ingrese el ticket',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Seleccionar tipo de desviación
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Tipo de desviación',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDesviacion,
                items: _desviacionTypes.map((String desviacion) {
                  return DropdownMenuItem<String>(
                    value: desviacion,
                    child: Text(desviacion),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDesviacion = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleccione un tipo de desviación';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Seleccionar tipo de desviación
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Impacto en el mantenimiento',
                  border: OutlineInputBorder(),
                ),
                value: _selectedImpacto,
                items: _impactoTypes.map((String impacto) {
                  return DropdownMenuItem<String>(
                    value: impacto,
                    child: Text(impacto),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedImpacto = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleccione un tipo de desviación';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Seleccionar tipo de desviación
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Clasificación',
                  border: OutlineInputBorder(),
                ),
                value: _selectedDeviation,
                items: _deviationTypes.map((String deviation) {
                  return DropdownMenuItem<String>(
                    value: deviation,
                    child: Text(deviation),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedDeviation = newValue;
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Seleccione un tipo de desviación';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Descripción de la desviación
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Descripción de la desviación',
                  border: OutlineInputBorder(),
                  hintText: 'Describa brevemente la desviación',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              TextFormField(
                controller: _medidasController,
                decoration: const InputDecoration(
                  labelText: 'Medidas correctivas',
                  border: OutlineInputBorder(),
                  hintText: 'Describa brevemente las medidas (si aplica)',
                ),
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Este campo es obligatorio';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Subir evidencia
              ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.camera_alt),
                label: const Text('Subir evidencia'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueAccent,
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Mostrar imagen seleccionada
              if (_evidenceImage != null)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Evidencia seleccionada:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Image.memory(
                      _evidenceImage!,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Botón de enviar
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 226, 81, 98),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                child: _isSubmitting
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                      )
                    : const Text(
                        'Enviar Reporte',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}