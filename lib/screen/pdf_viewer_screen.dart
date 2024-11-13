import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';
import 'package:http/http.dart' as http;

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
