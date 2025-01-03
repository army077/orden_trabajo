import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PrevDayScreen extends StatefulWidget {
  final String tecnicoEmail;

  const PrevDayScreen({Key? key, required this.tecnicoEmail}) : super(key: key);

  @override
  _PrevDayScreenState createState() => _PrevDayScreenState();
}

class _PrevDayScreenState extends State<PrevDayScreen> {
  int? selectedId;
  List<Map<String, dynamic>> ordenes = [];
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    fetchOrdenes();
  }

  Future<void> fetchOrdenes() async {
    final String url =
        'https://teknia.app/api/ordenes_agendadas_tecnico/${widget.tecnicoEmail}';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);

        setState(() {
          ordenes = data
              .map((orden) => {
                    'id': orden['id_tabla'],
                    'id_real': orden['id'],
                    'razon_social': orden['razon_social'],
                    'orden_numero': orden['orden_numero'],
                    'prioridad': orden['prioridad'],
                    'titulo': orden['titulo'],
                  })
              .toList();
          if (ordenes.isNotEmpty) {
            selectedId = ordenes.first['id'];
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
      body: Stack(
        children: [
          // Fondo
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF8B0000), Color(0xFFFFA07A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                //  Titulo
                Container(
                  margin: const EdgeInsets.only(top: 40),
                  child: const Text(
                    'Selecciona una Orden de Trabajo',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : hasError
                          ? const Center(
                              child: Text(
                                'Error al cargar las órdenes. Intente nuevamente.',
                                style:
                                    TextStyle(fontSize: 16, color: Colors.red),
                              ),
                            )
                          : ordenes.isEmpty
                              ? const Center(
                                  child: Text(
                                    'No hay órdenes asignadas.',
                                    style: TextStyle(fontSize: 18),
                                  ),
                                )
                              : Card(
                                  color: Colors.white,
                                  elevation: 8,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      children: [
                                        const Text(
                                          'Selecciona una orden para cargar las tareas:',
                                          style: TextStyle(fontSize: 18),
                                        ),
                                        const SizedBox(height: 20),
                                        DropdownButton<int>(
                                          value: selectedId,
                                          isExpanded: true,
                                          items: ordenes.map((orden) {
                                            final String razonSocial =
                                                orden['razon_social']
                                                        ?.toString() ??
                                                    '';
                                            final String tituloAlternativo =
                                                orden['titulo']?.toString() ??
                                                    'Título no disponible';
                                            final String text =
                                                '#: ${orden['id']}  - ${razonSocial.isEmpty ? tituloAlternativo : razonSocial}';
                                            return DropdownMenuItem<int>(
                                              value: orden['id'],
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      text,
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                      ),
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                ],
                                              ),
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
                                                  // Filtramos las órdenes para obtener solo la que coincide con selectedId
                                                  final ordenesFiltradas =
                                                      ordenes
                                                          .where((orden) =>
                                                              orden['id']
                                                                  .toString() ==
                                                              selectedId
                                                                  .toString())
                                                          .toList();
                                                  print(ordenesFiltradas);
                                                  if (ordenesFiltradas
                                                      .isNotEmpty) {
                                                    // Extraemos 'id_real' y 'id_tabla' de la primera orden filtrada
                                                    final String? idReal =
                                                        ordenesFiltradas
                                                            .first['id_real']
                                                            ?.toString();
                                                    final String? idTabla =
                                                        ordenesFiltradas
                                                            .first['id']
                                                            ?.toString();
                                                    print(
                                                        'ID Real: $idReal, ID Tabla: $idTabla');

                                                    if (idReal != null && idTabla != null) {
                                                      Navigator.of(context)
                                                          .pushNamed(
                                                        '/my_day_screen',
                                                        arguments: 
                                                        {'id_tabla': int.parse(idTabla),
                                                        'id_real': int.parse(idReal)},

                                                      );
                                                    } else {
                                                      // Manejo de error si 'id_real' no existe
                                                      print(
                                                          'Error: El ID real no está disponible.');
                                                    }
                                                  } else {
                                                    // Manejo de error si no hay coincidencias
                                                    print(
                                                        'Error: No se encontraron órdenes con el ID seleccionado.');
                                                  }
                                                }
                                              : null,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                const Color(0xFF8B0000),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: const Text(
                                            'Ir a Orden de Trabajo',
                                            style: TextStyle(
                                              fontSize: 16,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
