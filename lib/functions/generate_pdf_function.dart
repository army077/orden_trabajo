import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/entities/tareas.dart';
import 'package:todo_app/screen/pdf_viewer_screen.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> sendTasksToGeneratePdf(
    BuildContext context, List<Tarea> tasks, String recipientEmail) async {
  final url = Uri.parse(
      'https://us-central1-loginfirebase-9d539.cloudfunctions.net/generatePdfFromTasksv4');
  final headers = {"Content-Type": "application/json"};

  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode({
      "tasks": tasks.map((task) => task.toJson()).toList(),
      "email": recipientEmail,
    }),
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final pdfUrl = jsonResponse['fileUrl'];
    print("PDF generado y guardado en Firebase Storage: $pdfUrl");

    if (pdfUrl != null && pdfUrl.isNotEmpty) {
      // Navega al visor de PDF en la app
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(pdfUrl: pdfUrl),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Error: La URL del PDF no está disponible')),
      );
    }
  } else {
    print("Error al generar el PDF: ${response.body}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al generar el PDF: ${response.body}')),
    );
  }
}

Future<void> sendTasksToGenerateTxt(
    BuildContext context, List<Tarea> tasks) async {
  // URL de la función de Firebase
  final url = Uri.parse(
      'https://us-central1-loginfirebase-9d539.cloudfunctions.net/saveJsonToTxt');

  // Cabeceras de la solicitud
  final headers = {"Content-Type": "application/json"};

  // Preparar el cuerpo de la solicitud
  final body = jsonEncode({
    "tareas": tasks.map((task) => task.toJson()).toList(),
  });

  try {
    // Realizar la solicitud POST
    final response = await http.post(url, headers: headers, body: body);

    if (response.statusCode == 200) {
      final jsonResponse = jsonDecode(response.body);
      final fileUrl = jsonResponse['fileUrl'];

      print("Archivo .txt generado y guardado en Firebase Storage: $fileUrl");

      if (fileUrl != null && fileUrl.isNotEmpty) {
        // Mostrar un mensaje de éxito y permitir abrir el archivo
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Archivo generado con éxito: $fileUrl')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Error: La URL del archivo no está disponible')),
        );
      }
    } else {
      print("Error al generar el archivo .txt: ${response.body}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error al generar el archivo: ${response.body}')),
      );
    }
  } catch (e) {
    print("Error al realizar la solicitud: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Error al realizar la solicitud')),
    );
  }
}

Future<void> abrirPDF(String url) async {
  final Uri uri = Uri.parse(url);
  if (await canLaunchUrl(uri)) {
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  } else {
    throw 'No se pudo abrir el enlace: $url';
  }
}
