import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'dart:convert';

// Import PDF.js Dart wrappers - CORRECT NAMES
import 'build/pdf.mjs.dart' as pdf_js;
import 'build/pdf.worker.mjs.dart' as pdf_worker_js;
import 'web/viewer.html.dart' as viewer_html;
import 'web/viewer.mjs.dart' as viewer_js;
import 'web/viewer.css.dart' as viewer_css;

void main() => runApp(const PDFReaderApp());

class PDFReaderApp extends StatelessWidget {
  const PDFReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Reader',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PDFListScreen(),
    );
  }
}

class PDFListScreen extends StatefulWidget {
  const PDFListScreen({super.key});

  @override
  State<PDFListScreen> createState() => _PDFListScreenState();
}

class _PDFListScreenState extends State<PDFListScreen> {
  final List<FileDocument> _documents = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    final status = await Permission.manageExternalStorage.request();
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

  Future<void> _importPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );

      if (result != null && result.files.single.path != null) {
        final filePath = result.files.single.path!;
        final fileName = result.files.single.name;
        
        setState(() => _isLoading = true);

        final document = FileDocument(
          title: fileName,
          filePath: filePath,
        );
        
        setState(() {
          _documents.add(document);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('PDF eklenemedi: ${e.toString()}');
    }
  }

  void _openPDF(FileDocument document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(pdfPath: document.filePath),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Reader'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _importPDF,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _documents.isEmpty
              ? const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.folder_open, size: 80, color: Colors.grey),
                      SizedBox(height: 20),
                      Text(
                        'Henüz PDF yok',
                        style: TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Sağ üstten PDF ekleyin',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: _documents.length,
                  itemBuilder: (context, index) {
                    final doc = _documents[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      child: ListTile(
                        leading: const Icon(Icons.picture_as_pdf, color: Colors.red),
                        title: Text(doc.title),
                        subtitle: Text(doc.filePath.split('/').last),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _openPDF(doc),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _importPDF,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PDFViewerScreen extends StatefulWidget {
  final String pdfPath;

  const PDFViewerScreen({super.key, required this.pdfPath});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  String _generatePDFViewerHTML() {
    // Tüm PDF.js kodlarını tek HTML'de birleştir
    return '''
<!DOCTYPE html>
<html>
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>PDF Viewer</title>
  <style>
    ${viewer_css.viewerCss}
  </style>
</head>
<body>
  <div id="viewerContainer">
    <div id="viewer" class="pdfViewer"></div>
  </div>
  
  <script>
    // PDF.js Core
    ${pdf_js.pdfMjs}
    
    // PDF.js Worker
    ${pdf_worker_js.pdfWorkerMjs}
    
    // PDF.js Viewer
    ${viewer_js.viewerMjs}
    
    // PDF'yi yükle
    window.addEventListener('load', function() {
      const pdfUrl = "${widget.pdfPath}";
      pdfjsLib.getDocument(pdfUrl).promise.then(function(pdf) {
        window.pdfViewer.setDocument(pdf);
      });
    });
  </script>
</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF - ${widget.pdfPath.split('/').last}'),
        backgroundColor: Colors.red,
      ),
      body: InAppWebView(
        initialData: InAppWebViewInitialData(
          data: _generatePDFViewerHTML(),
          mimeType: "text/html",
          encoding: "utf-8",
        ),
        onWebViewCreated: (controller) {
          print("PDF Viewer opened: ${widget.pdfPath}");
        },
        onLoadError: (controller, url, code, message) {
          print("PDF Load Error: $message");
        },
      ),
    );
  }
}

class FileDocument {
  final String title;
  final String filePath;

  FileDocument({
    required this.title,
    required this.filePath,
  });
}
