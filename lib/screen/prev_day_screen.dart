import 'package:flutter/material.dart';

class PrevDayScreen extends StatefulWidget {
  const PrevDayScreen({Key? key}) : super(key: key);

  @override
  _PrevDayScreenState createState() => _PrevDayScreenState();
}

class _PrevDayScreenState extends State<PrevDayScreen> {
  int selectedId = 10; // Valor predeterminado para el dropdown

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seleccionar Orden de Trabajo', style: TextStyle(color: Colors.white),),
          backgroundColor: const Color(0xFF8B0000),
          
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Selecciona un ID para cargar las tareas:',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            DropdownButton<int>(
              value: selectedId,
              items: const [
                DropdownMenuItem(
                  value: 10,
                  child: Text('ID 10'),
                ),
                DropdownMenuItem(
                  value: 11,
                  child: Text('ID 11'),
                ),
                 DropdownMenuItem(
                  value: 12,
                  child: Text('ID 12'),
                ),
                 DropdownMenuItem(
                  value: 13,
                  child: Text('ID 13'),
                ),
              ],
              onChanged: (int? value) {
                if (value != null) {
                  setState(() {
                    selectedId = value;
                  });
                }
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/my_day_screen',
                  arguments: selectedId,
                );
              },
              child: const Text('Ir a Orden de Trabajo'),
            ),
          ],
        ),
      ),
    );
  }
}
