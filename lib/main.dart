import 'dart:math';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

void main() => runApp(const PDFReaderApp());

class PDFReaderApp extends StatelessWidget {
  const PDFReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Reader',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PDFLibraryScreen(),
    );
  }
}

class PDFLibraryScreen extends StatefulWidget {
  const PDFLibraryScreen({super.key});

  @override
  State<PDFLibraryScreen> createState() => _PDFLibraryScreenState();
}

class _PDFLibraryScreenState extends State<PDFLibraryScreen> {
  final List<PDFDocument> _documents = [];
  bool _isLoading = false;

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _isLoading = true);
        
        for (var file in result.files) {
          if (file.path != null) {
            final document = PDFDocument(
              name: file.name,
              path: file.path!,
              dateAdded: DateTime.now(),
              pageCount: _getMockPageCount(file.name),
              fileSize: file.size,
            );
            
            _documents.add(document);
          }
        }
        
        setState(() => _isLoading = false);
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${result.files.length} PDF eklendi'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  int _getMockPageCount(String fileName) {
    return fileName.length % 20 + 5;
  }

  void _openPDF(PDFDocument document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFiumViewerScreen(document: document),
      ),
    );
  }

  Widget _buildPDFGrid() {
    if (_documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.folder_open, size: 80, color: Colors.grey[300]),
            const SizedBox(height: 20),
            Text(
              'Henüz PDF yok',
              style: TextStyle(fontSize: 18, color: Colors.grey[500]),
            ),
            const SizedBox(height: 10),
            Text(
              'Sağ alttaki + butonuna tıkla\nve PDF ekle',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: _documents.length,
      itemBuilder: (context, index) => _buildPDFCard(_documents[index]),
    );
  }

  Widget _buildPDFCard(PDFDocument document) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _openPDF(document),
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.red[50],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
                    const SizedBox(height: 8),
                    Text(
                      'PDF',
                      style: TextStyle(
                        color: Colors.red[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${document.pageCount} sayfa',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Kütüphanem'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildPDFGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickPDF,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PDFiumViewerScreen extends StatefulWidget {
  final PDFDocument document;

  const PDFiumViewerScreen({super.key, required this.document});

  @override
  State<PDFiumViewerScreen> createState() => _PDFiumViewerScreenState();
}

class _PDFiumViewerScreenState extends State<PDFiumViewerScreen> {
  int _currentPage = 1;

  void _nextPage() {
    if (_currentPage < widget.document.pageCount) {
      setState(() => _currentPage++);
    }
  }

  void _previousPage() {
    if (_currentPage > 1) {
      setState(() => _currentPage--);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.name),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Sayfa $_currentPage / ${widget.document.pageCount}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Row(
                  children: [
                    IconButton(
                      onPressed: _previousPage,
                      icon: const Icon(Icons.arrow_back),
                    ),
                    IconButton(
                      onPressed: _nextPage,
                      icon: const Icon(Icons.arrow_forward),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf, size: 100, color: Colors.grey),
                  const SizedBox(height: 20),
                  Text(
                    widget.document.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'PDFium Viewer - Sayfa $_currentPage',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      _testBackendConnection();
                    },
                    child: const Text('Backend Test'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _testBackendConnection() async {
    try {
      final lib = DynamicLibrary.open('libpdf_renderer.so');
      final initPDFium = lib.lookupFunction<Int32 Function(), int Function()>(
        'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_initPDFium'
      );
      
      final result = initPDFium();
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backend bağlantısı: ${result == 1 ? "BAŞARILI" : "HATA"}'),
          backgroundColor: result == 1 ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Backend hatası: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class PDFDocument {
  final String name;
  final String path;
  final DateTime dateAdded;
  final int pageCount;
  final int fileSize;

  PDFDocument({
    required this.name,
    required this.path,
    required this.dateAdded,
    required this.pageCount,
    required this.fileSize,
  });
}
