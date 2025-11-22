import 'package:flutter/material.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

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
  final List<PDFDocument> _documents = [];
  final _pdfService = PDFNativeService();
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
        setState(() => _isLoading = true);
        
        final filePath = result.files.single.path!;
        final document = await _pdfService.openPDF(filePath);
        
        setState(() {
          _documents.add(document);
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showError('PDF açılamadı: $e');
    }
  }

  void _openPDF(PDFDocument document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewScreen(document: document),
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
                        subtitle: Text('${doc.pageCount} sayfa • ${doc.filePath.split('/').last}'),
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

class PDFViewScreen extends StatelessWidget {
  final PDFDocument document;

  const PDFViewScreen({super.key, required this.document});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(document.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('PDF Bilgisi'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Başlık: ${document.title}'),
                      Text('Sayfa: ${document.pageCount}'),
                      Text('Yol: ${document.filePath}'),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Tamam'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 100, color: Colors.red),
            const SizedBox(height: 20),
            Text(
              document.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '${document.pageCount} sayfa',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.green),
              ),
              child: const Column(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 40),
                  SizedBox(height: 10),
                  Text(
                    'PDF Başarıyla Açıldı!',
                    style: TextStyle(fontSize: 16, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    'MuPDF motoru çalışıyor',
                    style: TextStyle(fontSize: 12, color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PDFDocument {
  final String title;
  final int pageCount;
  final String filePath;

  PDFDocument({
    required this.title,
    required this.pageCount,
    required this.filePath,
  });
}

class PDFNativeService {
  static DynamicLibrary? _nativeLib;
  
  DynamicLibrary get _lib {
    _nativeLib ??= DynamicLibrary.open('libpdf_renderer.so');
    return _nativeLib!;
  }

  late final int Function() _initContext = 
      _lib.lookupFunction<Int64 Function(), int Function()>(
          'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_initContext');
  
  late final int Function(int, Pointer<Utf8>) _openDocument = 
      _lib.lookupFunction<Int64 Function(Int64, Pointer<Utf8>), int Function(int, Pointer<Utf8>)>(
          'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_openDocument');
  
  late final int Function(int, int) _getPageCount = 
      _lib.lookupFunction<Int32 Function(Int64, Int64), int Function(int, int)>(
          'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getPageCount');
  
  late final Pointer<Utf8> Function(int, int) _getDocumentTitle = 
      _lib.lookupFunction<Pointer<Utf8> Function(Int64, Int64), Pointer<Utf8> Function(int, int)>(
          'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getDocumentTitle');

  late final Pointer<Utf8> Function(int, int) _getFilePath = 
      _lib.lookupFunction<Pointer<Utf8> Function(Int64, Int64), Pointer<Utf8> Function(int, int)>(
          'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getFilePath');

  late final void Function(int, int) _closeDocument = 
      _lib.lookupFunction<Void Function(Int64, Int64), void Function(int, int)>(
          'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_closeDocument');

  Future<PDFDocument> openPDF(String filePath) async {
    try {
      // Context oluştur
      final context = _initContext();
      
      // PDF aç
      final pathPtr = filePath.toNativeUtf8();
      final documentPtr = _openDocument(context, pathPtr);
      
      if (documentPtr == 0) {
        throw Exception('PDF açılamadı: $filePath');
      }
      
      // Bilgileri al
      final pageCount = _getPageCount(context, documentPtr);
      final titlePtr = _getDocumentTitle(context, documentPtr);
      final filePathPtr = _getFilePath(context, documentPtr);
      
      final document = PDFDocument(
        title: titlePtr.toDartString(),
        pageCount: pageCount,
        filePath: filePathPtr.toDartString(),
      );
      
      // Temizlik
      _closeDocument(context, documentPtr);
      malloc.free(pathPtr);
      
      return document;
      
    } catch (e) {
      rethrow;
    }
  }
}
