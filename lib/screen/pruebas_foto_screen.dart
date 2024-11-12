import 'package:flutter/material.dart';

class PruebasFotoScreen extends StatelessWidget {
  const PruebasFotoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prueba de Foto"),
      ),
      body: Center(
        child: Image.network(
          'https://firebasestorage.googleapis.com/v0/b/loginfirebase-9d539.firebasestorage.app/o/reports%2FMaximiliano-1731425526866.jpg?alt=media&token=0afc4f33-6380-4091-8e36-85a18ec7534f',
          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
            if (loadingProgress == null) {
              return child;
            }
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                    : null,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) => Text('Error al cargar la imagen'),
        ),
      ),
    );
  }
}
