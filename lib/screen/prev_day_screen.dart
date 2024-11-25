import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PrevDayScreen extends StatefulWidget {
  final String tecnicoEmail; // Email del técnico logueado

  const PrevDayScreen({Key? key, required this.tecnicoEmail}) : super(key: key);

  @override
  _PrevDayScreenState createState() => _PrevDayScreenState();
}

class _PrevDayScreenState extends State<PrevDayScreen> {
  int? selectedId; // Valor seleccionado en el dropdown
  List<Map<String, dynamic>> ordenes = []; // Lista de órdenes obtenidas
  bool isLoading = true; // Indicador de carga
  bool hasError = false; // Indicador de error

  @override
  void initState() {
    super.initState();
    _fetchOrdenes(); // Cargar órdenes al iniciar
  }

  Future<void> _fetchOrdenes() async {
    final String url =
        'https://teknia.app/api/ordenes_agendadas_tecnico/${widget.tecnicoEmail}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        // Filtra las órdenes del técnico logueado y asigna `orden_numero` e `id`
        setState(() {
          ordenes = data
              .map((orden) => {
                    'orden_numero': orden['orden_numero'],
                    'id': orden['id'],
                  })
              .toList();
          if (ordenes.isNotEmpty) {
            selectedId = int.tryParse(ordenes.first['orden_numero']);
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Seleccionar Orden de Trabajo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF8B0000),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : hasError
                ? const Center(
                    child: Text(
                      'Error al cargar las órdenes. Intente nuevamente.',
                      style: TextStyle(fontSize: 16, color: Colors.red),
                    ),
                  )
                : ordenes.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay órdenes asignadas.',
                          style: TextStyle(fontSize: 18),
                        ),
                      )
                    : Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Selecciona una orden para cargar las tareas:',
                            style: TextStyle(fontSize: 18),
                          ),
                          const SizedBox(height: 20),
                          DropdownButton<int>(
                            value: selectedId,
                            items: ordenes.map((orden) {
                              return DropdownMenuItem<int>(
                                value: int.tryParse(orden['orden_numero']),
                                child: Text('Orden ${orden['orden_numero']}'),
                              );
                            }).toList(),
                            onChanged: (int? value) {
                              setState(() {
                                selectedId = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: selectedId != null
                                ? () {
                                    Navigator.of(context).pushNamed(
                                      '/my_day_screen',
                                      arguments: selectedId,
                                    );
                                  }
                                : null,
                            child: const Text('Ir a Orden de Trabajo'),
                          ),
                        ],
                      ),
      ),
    );
  }
}
