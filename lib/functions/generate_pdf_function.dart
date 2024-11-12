import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:todo_app/entities/tareas.dart';
import 'package:todo_app/screen/pdf_viewer_screen.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> sendTasksToGeneratePdf(BuildContext context, List<Tarea> tasks) async {
  final url = Uri.parse('https://us-central1-loginfirebase-9d539.cloudfunctions.net/generatePdfFromTasksv2');
  final headers = {"Content-Type": "application/json"};

  final response = await http.post(
    url,
    headers: headers,
    body: jsonEncode(tasks.map((task) => task.toJson()).toList()),
  );

  if (response.statusCode == 200) {
    final jsonResponse = jsonDecode(response.body);
    final pdfUrl = jsonResponse['fileUrl'];
    print("PDF generado y guardado en Firebase Storage: $pdfUrl");

    if (pdfUrl != null && pdfUrl.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PDFViewerPage(pdfUrl: pdfUrl),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: La URL del PDF no está disponible')),
      );
    }
  } else {
    print("Error al generar el PDF: ${response.body}");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error al generar el PDF: ${response.body}')),
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