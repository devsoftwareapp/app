import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
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
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData.dark(),
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
  final PDFNativeService _pdfService = PDFNativeService();
  bool _backendReady = false;

  @override
  void initState() {
    super.initState();
    _initializeBackend();
  }

  Future<void> _initializeBackend() async {
    try {
      setState(() => _isLoading = true);
      
      // Native backend'i başlat
      final lib = DynamicLibrary.open('libpdf_renderer.so');
      final initPDFium = lib.lookupFunction<Int32 Function(), int Function()>(
        'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_initPDFium'
      );
      
      final result = initPDFium();
      
      setState(() {
        _backendReady = result == 1;
        _isLoading = false;
      });
      
      if (_backendReady) {
        print('🎯 PDFium backend başarıyla başlatıldı!');
      } else {
        print('❌ PDFium backend başlatılamadı');
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('❌ Backend başlatma hatası: $e');
    }
  }

  Future<void> _pickPDF() async {
    if (!_backendReady) {
      _showSnackBar('Backend hazır değil!', Colors.red);
      return;
    }

    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
        allowCompression: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _isLoading = true);
        
        for (var file in result.files) {
          if (file.path != null) {
            // Backend ile PDF bilgilerini al
            final pageCount = await _getPDFPageCount(file.path!);
            
            final document = PDFDocument(
              name: file.name,
              path: file.path!,
              dateAdded: DateTime.now(),
              pageCount: pageCount,
              fileSize: file.size,
            );
            
            _documents.add(document);
          }
        }
        
        setState(() => _isLoading = false);
        
        _showSnackBar('${result.files.length} PDF eklendi', Colors.green);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Hata: $e', Colors.red);
    }
  }

  Future<int> _getPDFPageCount(String filePath) async {
    try {
      final lib = DynamicLibrary.open('libpdf_renderer.so');
      
      final openDocument = lib.lookupFunction<
        Int64 Function(Pointer<Utf8>),
        int Function(Pointer<Utf8>)
      >('Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_openDocument');
      
      final getPageCount = lib.lookupFunction<
        Int32 Function(Int64),
        int Function(int)
      >('Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getPageCount');
      
      final closeDocument = lib.lookupFunction<
        Void Function(Int64),
        void Function(int)
      >('Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_closeDocument');
      
      // PDF'i aç
      final pathPtr = filePath.toNativeUtf8();
      final documentPtr = openDocument(pathPtr);
      malloc.free(pathPtr);
      
      if (documentPtr == 0) {
        return 0; // PDF açılamadı
      }
      
      // Sayfa sayısını al
      final pageCount = getPageCount(documentPtr);
      
      // PDF'i kapat
      closeDocument(documentPtr);
      
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
        builder: (context) => PDFViewerScreen(document: document),
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
            Icon(
              Icons.folder_open, 
              size: 80, 
              color: Colors.grey[300]
            ),
            const SizedBox(height: 20),
            Text(
              'Henüz PDF yok',
              style: TextStyle(
                fontSize: 18, 
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Sağ alttaki + butonuna tıkla\nve PDF ekle',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14, 
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            if (!_backendReady)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.warning, color: Colors.orange[700], size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Backend hazır değil',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
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
                    // PDF Icon
                    Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.picture_as_pdf, 
                              size: 40, 
                              color: Colors.red[700]),
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
                    // Page Count Badge
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
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
                  Row(
                    children: [
                      Icon(Icons.description, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _formatFileSize(document.fileSize),
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 12, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        '${document.dateAdded.day}.${document.dateAdded.month}.${document.dateAdded.year}',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
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
                // Search functionality
                _showSnackBar('Arama özelliği yakında eklenecek', Colors.blue);
              },
            ),
          if (_documents.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.sort),
              onPressed: () {
                // Sort functionality
                _showSnackBar('Sıralama özelliği yakında eklenecek', Colors.blue);
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

class PDFViewerScreen extends StatefulWidget {
  final PDFDocument document;

  const PDFViewerScreen({super.key, required this.document});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  int _currentPage = 1;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  Future<void> _loadPDF() async {
    await Future.delayed(const Duration(seconds: 1)); // Simüle edilmiş yükleme
    setState(() => _isLoading = false);
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
                // Page Info
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Sayfa $_currentPage / ${widget.document.pageCount}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
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
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.picture_as_pdf,
                          size: 120,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          widget.document.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          '${widget.document.pageCount} sayfa • ${_formatFileSize(widget.document.fileSize)}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          'PDF içeriği burada gösterilecek\n(Backend render entegrasyonu ile)',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Navigation Controls
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Colors.grey[50],
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _previousPage,
                        icon: const Icon(Icons.arrow_back),
                        label: const Text('Önceki'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                      ),
                      ElevatedButton.icon(
                        onPressed: _nextPage,
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text('Sonraki'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.blue,
                        ),
                      ),
                    ],
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
    this.fileSize = 0,
  });
}

// Native Service Class
class PDFNativeService {
  DynamicLibrary? _nativeLib;
  
  DynamicLibrary get _lib {
    _nativeLib ??= DynamicLibrary.open('libpdf_renderer.so');
    return _nativeLib!;
  }

  // Native function signatures
  final int Function() _initPDFium = 
      _lib.lookupFunction<Int32 Function(), int Function()>(
          'Java_com_devsoftware_pdf_reader_manager_PDFRenderer_initPDFium');
  
  final int Function(Pointer<Utf8>) _openDocument = 
      _lib.lookupFunction<Int64 Function(Pointer<Utf8>), int Function(Pointer<Utf8>)>(
          'Java_com_devsoftware_pdf_reader_manager_PDFRenderer_openDocument');
  
  final int Function(int) _getPageCount = 
      _lib.lookupFunction<Int32 Function(Int64), int Function(int)>(
          'Java_com_devsoftware_pdf_reader_manager_PDFRenderer_getPageCount');

  final void Function(int) _closeDocument = 
      _lib.lookupFunction<Void Function(Int64), void Function(int)>(
          'Java_com_devsoftware_pdf_reader_manager_PDFRenderer_closeDocument');

  Future<bool> initialize() async {
    try {
      final result = _initPDFium();
      return result == 1;
    } catch (e) {
      print('❌ PDFium initialization error: $e');
      return false;
    }
  }
}
