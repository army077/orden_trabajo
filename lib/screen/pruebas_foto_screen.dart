import 'package:flutter/material.dart';

class PruebasFotoScreen extends StatelessWidget {
  final String imageUrl; // Agrega una variable para la URL

  // Constructor que recibe la URL de la imagen
  const PruebasFotoScreen({Key? key, required this.imageUrl}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prueba de Foto"),
      ),
      body: Center(
        child: Image.network(
          imageUrl,
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
