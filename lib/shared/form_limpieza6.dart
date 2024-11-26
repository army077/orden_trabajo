import 'package:flutter/material.dart';
import 'package:todo_app/shared/form_desviacion.dart';
import '../entities/tareas.dart';

class FormularioLimpieza extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar;

  const FormularioLimpieza({
    Key? key,
    required this.tarea,
    required this.onCompletar,
  }) : super(key: key);

  @override
  _FormularioLimpiezaState createState() => _FormularioLimpiezaState();
}

class _FormularioLimpiezaState extends State<FormularioLimpieza> {
  final TextEditingController _componenteController = TextEditingController();
  String? opcionSeleccionada;
  bool botonHabilitado = false;

  final List<Map<String, dynamic>> opcionesEstatus = [
    {"valor": 1, "texto": "1 - No Aplica"},
    {"valor": 2, "texto": "2 - Pendiente (no iniciada)"},
    {"valor": 3, "texto": "3 - Incompleta"},
    {"valor": 4, "texto": "4 - Terminada"},
  ];

  @override
  void initState() {
    super.initState();
    _componenteController.text = widget.tarea.componente ?? '';
    opcionSeleccionada = widget.tarea.estatus;
    botonHabilitado =
        _componenteController.text.isNotEmpty && opcionSeleccionada != null;
  }

  void _completarTarea() {
    setState(() {
      widget.tarea.componente = _componenteController.text;
      widget.tarea.estatus = opcionSeleccionada;
      widget.tarea.completada = true;
            widget.tarea.fechaCreacion = DateTime.now();
    });
    widget.onCompletar();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: const Text('Formulario Limpieza'),
        automaticallyImplyLeading: false,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título de la Tarea
                _buildSectionTitle(widget.tarea.titulo),

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

                // Campo de Texto
                const Text(
                  'Componente o equipo limpiado:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _componenteController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Nombre del componente o equipo',
                  ),
                  onChanged: (value) {
                    setState(() {
                      botonHabilitado = value.isNotEmpty && opcionSeleccionada != null;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Dropdown para Estatus
                const Text(
                  'Estatus de la limpieza:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  isExpanded: true,
                  value: opcionSeleccionada,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Selecciona un estatus',
                  ),
                  items: opcionesEstatus.map((opcion) {
                    return DropdownMenuItem<String>(
                      value: opcion["valor"].toString(),
                      child: Text(opcion["texto"]),
                    );
                  }).toList(),
                  onChanged: (valor) {
                    setState(() {
                      opcionSeleccionada = valor;
                      botonHabilitado =
                          _componenteController.text.isNotEmpty && valor != null;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Botones
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
                  child: const Text(
                    'Completar',
                    style: TextStyle(color: Colors.white),
                  ),
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

                // Referencias
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  width: double.infinity,
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
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _componenteController.dispose();
    super.dispose();
  }
}
