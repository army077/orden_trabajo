import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:todo_app/screen/my_day_screen.dart';
import 'package:todo_app/services/auth_service.dart';
import 'dart:io';
import 'package:intl/date_symbol_data_local.dart';

class PDFViewerPage extends StatefulWidget {
  final String pdfUrl;

  const PDFViewerPage({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  _PDFViewerPageState createState() => _PDFViewerPageState();
}

class _PDFViewerPageState extends State<PDFViewerPage> {
  late PdfController _pdfController;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePdfController();
  }

  Future<void> _initializePdfController() async {
    try {
      final pdfData = await fetchPdf(widget.pdfUrl);
      _pdfController = PdfController(
        document: PdfDocument.openData(pdfData),
      );
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error al cargar el PDF: $e";
      });
    }
  }

  Future<Uint8List> fetchPdf(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return response.bodyBytes;
    } else {
      throw Exception("No se pudo obtener el PDF. Estado: ${response.statusCode}");
    }
  }

Future<void> _sharePdf() async {
  try {
    // Inicializa la localización para la fecha
    await initializeDateFormatting('es', null);

    // Descarga el PDF
    final pdfData = await fetchPdf(widget.pdfUrl);

    // Obtiene el nombre del usuario o usa un nombre genérico
    final userName = user?.displayName ?? 'Usuario';

    // Obtiene la fecha actual en un formato válido para archivos
    final currentDate = DateFormat('dd-MMM-yyyy', 'es').format(DateTime.now());

    // Guarda el PDF en almacenamiento temporal con el nombre del usuario y la fecha
    final tempDir = await getTemporaryDirectory();
    final file = File('${tempDir.path}/${userName}_$currentDate.pdf');
    await file.writeAsBytes(pdfData);

    // Usa share_plus para compartir el PDF
    await Share.shareXFiles([XFile(file.path)], text: 'Aquí tienes el documento PDF.');
  } catch (e) {
    setState(() {
      _errorMessage = "Error al compartir el PDF: $e";
    });
  }
}

  @override
  void dispose() {
    _pdfController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Vista de PDF'),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share, color: Color(0xFF8B0000),),
            onPressed: _isLoading ? null : _sharePdf,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
              ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)))
              : PdfView(
                  controller: _pdfController,
                  onDocumentLoaded: (document) {
                    print("PDF cargado con ${document.pagesCount} páginas");
                  },
                  onPageChanged: (page) {
                    print("Página actual: $page");
                  },
                ),
    );
  }
}
