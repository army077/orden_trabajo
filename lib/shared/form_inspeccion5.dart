import 'package:flutter/material.dart';
import '../entities/tareas.dart'; // Importa la entidad Tarea

class FormularioFueraDeRango extends StatefulWidget {
  final Tarea tarea;
  final VoidCallback onCompletar; // Callback para notificar el cambio

  const FormularioFueraDeRango({
    Key? key,
    required this.tarea,
    required this.onCompletar, // Recibe la función de callback
  }) : super(key: key);

  @override
  _FormularioFueraDeRangoState createState() => _FormularioFueraDeRangoState();
}

class _FormularioFueraDeRangoState extends State<FormularioFueraDeRango> {
  String opcionSeleccionada = "No"; // Valor predeterminado
  final TextEditingController _limiteSuperiorController =
      TextEditingController();
  final TextEditingController _limiteInferiorController =
      TextEditingController();
  final TextEditingController _unidadMedidaController = TextEditingController();

  bool botonHabilitado = false; // Controla el estado del botón "Completar"

  // Valida si el formulario está completo para habilitar el botón
  void _validarFormulario() {
    setState(() {
      botonHabilitado = _limiteSuperiorController.text.isNotEmpty &&
          _limiteInferiorController.text.isNotEmpty &&
          _unidadMedidaController.text.isNotEmpty;
    });
  }

  // Método para completar la tarea y cerrar el modal
  void _completarTarea() {
    if (botonHabilitado) {
      setState(() {
        widget.tarea.completada = true; // Marca la tarea como completada
      });
      widget.onCompletar(); // Notifica a MyDayScreen para actualizar la lista
      Navigator.pop(context); // Cierra el modal
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor completa todos los campos')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título de la tarea
          Text(
            widget.tarea.titulo,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),

          // Objetivo de la tarea
          Text(
            'Objetivo:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 4),
          Text(
            widget.tarea.objetivo ?? 'Sin objetivo definido.',
            style: TextStyle(fontSize: 16),
          ),
          SizedBox(height: 16),

          // Selección Binaria: ¿Fuera de Rango?
          Text(
            '¿Fuera de Rango?',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),

          // Radio Buttons para "Sí" / "No"
          Column(
            children: [
              RadioListTile<String>(
                title: Text('Sí'),
                value: 'Sí',
                groupValue: opcionSeleccionada,
                onChanged: (valor) {
                  setState(() {
                    opcionSeleccionada = valor!;
                  });
                },
              ),
              RadioListTile<String>(
                title: Text('No'),
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
          SizedBox(height: 16),

          // Campo de texto para Límite Superior
          Text(
            'Límite Superior:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _limiteSuperiorController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Ingrese el límite superior',
            ),
            onChanged: (_) => _validarFormulario(),
          ),
          SizedBox(height: 16),

          // Campo de texto para Límite Inferior
          Text(
            'Límite Inferior:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _limiteInferiorController,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Ingrese el límite inferior',
            ),
            onChanged: (_) => _validarFormulario(),
          ),
          SizedBox(height: 16),

          // Campo de texto para Unidad de Medida
          Text(
            'Unidad de Medida:',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          TextFormField(
            controller: _unidadMedidaController,
            decoration: InputDecoration(
              border: OutlineInputBorder(),
              labelText: 'Ingrese la unidad de medida',
            ),
            onChanged: (_) => _validarFormulario(),
          ),
          SizedBox(height: 16),

          // Botón "Completar"
          Center(
            child: ElevatedButton(
              onPressed: botonHabilitado ? _completarTarea : null,
              child: Text(
                'Completar',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 226, 81, 98),
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _limiteSuperiorController.dispose();
    _limiteInferiorController.dispose();
    _unidadMedidaController.dispose();
    super.dispose();
  }
}
