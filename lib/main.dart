import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:convert';

// Import PDF.js Dart wrappers
import 'package:app/web/viewer.html.dart' as viewer_html;
import 'package:app/web/viewer.mjs.dart' as viewer_js;
import 'package:app/web/viewer.css.dart' as viewer_css;
import 'package:app/build/pdf.mjs.dart' as pdf_js;
import 'package:app/build/pdf.worker.mjs.dart' as pdf_worker_js;

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

class PDFViewerScreen extends StatelessWidget {
  final String pdfPath;

  const PDFViewerScreen({super.key, required this.pdfPath});

  String _generatePDFViewerHTML() {
    // HTML template oluştur
    String html = viewer_html.viewerHtml;
    
    // PDF yolunu HTML'e embed et
    html = html.replaceAll(
      '<!-- PDF_URL_PLACEHOLDER -->',
      '''
      <script>
        // PDF dosyasını yükle
        window.pdfUrl = "$pdfPath";
        
        // PDF.js'i başlat
        pdfjsLib.getDocument(window.pdfUrl).promise.then(function(pdf) {
          window.pdfViewer.setDocument(pdf);
        });
      </script>
      '''
    );
    
    return html;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Viewer - ${pdfPath.split('/').last}'),
        backgroundColor: Colors.red,
      ),
      body: WebView(
        initialUrl: 'data:text/html;charset=utf-8,${Uri.encodeComponent(_generatePDFViewerHTML())}',
        javascriptMode: JavascriptMode.unrestricted,
        onWebViewCreated: (WebViewController webViewController) {
          print('PDF Viewer opened: $pdfPath');
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
