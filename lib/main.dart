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
}        void Function(int)
      >('Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_closeDocument');
      
      // PDF'i aç
      final pathPtr = filePath.toNativeUtf8();
      final documentPtr = openDocument(pathPtr);
      malloc.free(pathPtr);
      
      if (documentPtr == 0) {
        print('❌ PDF açılamadı: $filePath');
        return 1; // Varsayılan sayfa sayısı
      }
      
      // Sayfa sayısını al
      final pageCount = getPageCount(documentPtr);
      
      // PDF'i kapat
      closeDocument(documentPtr);
      
      print('📊 PDF sayfa sayısı: $pageCount');
      return pageCount > 0 ? pageCount : 1;
    } catch (e) {
      print('❌ Sayfa sayısı alma hatası: $e');
      return 1; // Varsayılan değer
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _openPDF(PDFDocument document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFiumViewerScreen(document: document),
      ),
    );
  }

  void _deletePDF(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('PDF Sil'),
        content: Text('"${_documents[index].name}" silinsin mi?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _documents.removeAt(index));
              Navigator.pop(context);
              _showSnackBar('PDF silindi', Colors.orange);
            },
            child: const Text('Sil', style: TextStyle(color: Colors.red)),
          ),
        ],
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
      itemBuilder: (context, index) => _buildPDFCard(_documents[index], index),
    );
  }

  Widget _buildPDFCard(PDFDocument document, int index) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _openPDF(document),
        onLongPress: () => _deletePDF(index),
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // PDF Thumbnail
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Colors.red[100]!, Colors.red[300]!],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.picture_as_pdf, size: 40, color: Colors.red[700]),
                          const SizedBox(height: 8),
                          Text(
                            'PDF',
                            style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${document.pageCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // PDF Info
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
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _formatFileSize(document.fileSize),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${document.dateAdded.day}.${document.dateAdded.month}.${document.dateAdded.year}',
                    style: TextStyle(
                      fontSize: 10,
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

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PDF Kütüphanem'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          if (_documents.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                _showSnackBar('Arama özelliği yakında eklenecek', Colors.blue);
              },
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('PDF yükleniyor...'),
                ],
              ),
            )
          : _buildPDFGrid(),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickPDF,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        tooltip: 'PDF Ekle',
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
  bool _isLoading = true;
  final PDFNativeService _pdfService = PDFNativeService();

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  Future<void> _loadPDF() async {
    try {
      // Backend ile PDF'i aç
      final documentPtr = await _pdfService.openDocument(widget.document.path);
      
      if (documentPtr != 0) {
        print('🎯 PDF başarıyla açıldı: ${widget.document.path}');
        // Burada PDF render işlemleri yapılacak
      }
      
      setState(() => _isLoading = false);
    } catch (e) {
      print('❌ PDF yükleme hatası: $e');
      setState(() => _isLoading = false);
    }
  }

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

  void _goToPage(int page) {
    if (page >= 1 && page <= widget.document.pageCount) {
      setState(() => _currentPage = page);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.document.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Paylaşım özelliği yakında eklenecek')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.bookmark_border),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Yer işareti eklendi')),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Page Info & Controls
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page Navigation
                      Row(
                        children: [
                          IconButton(
                            onPressed: _previousPage,
                            icon: const Icon(Icons.arrow_back_ios, size: 16),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey[300]!),
                            ),
                            child: Text(
                              '$_currentPage / ${widget.document.pageCount}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: _nextPage,
                            icon: const Icon(Icons.arrow_forward_ios, size: 16),
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      // File Info
                      Text(
                        _formatFileSize(widget.document.fileSize),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                // PDF Content Area
                Expanded(
                  child: Container(
                    color: Colors.grey[100],
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.picture_as_pdf,
                            size: 80,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 20),
                          Text(
                            widget.document.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Sayfa $_currentPage / ${widget.document.pageCount}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.blue[100]!),
                            ),
                            child: const Column(
                              children: [
                                Icon(Icons.auto_awesome, color: Colors.blue, size: 32),
                                SizedBox(height: 8),
                                Text(
                                  'PDFium Viewer Aktif!\n\nBackend bağlantısı hazır.\nPDF render motoru entegre edilecek.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Quick Page Navigation
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.grey[50],
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        widget.document.pageCount,
                        (index) => Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 2),
                          child: InkWell(
                            onTap: () => _goToPage(index + 1),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: _currentPage == index + 1 ? Colors.blue : Colors.white,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: _currentPage == index + 1 ? Colors.blue : Colors.grey[300]!,
                                ),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: _currentPage == index + 1 ? Colors.white : Colors.grey[700],
                                  fontSize: 12,
                                  fontWeight: _currentPage == index + 1 ? FontWeight.bold : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
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

class PDFNativeService {
  DynamicLibrary? _nativeLib;
  
  DynamicLibrary get _lib {
    _nativeLib ??= DynamicLibrary.open('libpdf_renderer.so');
    return _nativeLib!;
  }

  late final int Function() _initPDFium = 
      _lib.lookupFunction<Int32 Function(), int Function()>(
          'Java_com_devsoftware_pdf_reader_manager_PDFRenderer_initPDFium');
  
  late final int Function(Pointer<Utf8>) _openDocument = 
      _lib.lookupFunction<Int64 Function(Pointer<Utf8>), int Function(Pointer<Utf8>)>(
          'Java_com_devsoftware_pdf_reader_manager_PDFRenderer_openDocument');
  
  late final int Function(int) _getPageCount = 
      _lib.lookupFunction<Int32 Function(Int64), int Function(int)>(
          'Java_com_devsoftware_pdf_reader_manager_PDFRenderer_getPageCount');

  late final void Function(int) _closeDocument = 
      _lib.lookupFunction<Void Function(Int64), void Function(int)>(
          'Java_com_devsoftware_pdf_reader_manager_PDFRenderer_closeDocument');

  Future<bool> initialize() async {
    try {
      final result = _initPDFium();
      print('🎯 PDFium init result: $result');
      return result == 1;
    } catch (e) {
      print('❌ PDFium initialization error: $e');
      return false;
    }
  }

  Future<int> openDocument(String filePath) async {
    try {
      final pathPtr = filePath.toNativeUtf8();
      final documentPtr = _openDocument(pathPtr);
      malloc.free(pathPtr);
      return documentPtr;
    } catch (e) {
      print('❌ PDF open error: $e');
      return 0;
    }
  }
}
