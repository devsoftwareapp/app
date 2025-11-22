import 'package:flutter/material.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';
import 'package:flutter/services.dart';

void main() => runApp(const PDFReaderApp());

class PDFReaderApp extends StatelessWidget {
  const PDFReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PDFTestScreen(),
    );
  }
}

class PDFTestScreen extends StatefulWidget {
  @override
  State<PDFTestScreen> createState() => _PDFTestScreenState();
}

class _PDFTestScreenState extends State<PDFTestScreen> {
  final _pdfService = PDFNativeService();
  String _sonuc = "PDF Testi Bekleniyor...";
  bool _isLoading = false;

  Future<void> _openPDF() async {
    setState(() {
      _isLoading = true;
      _sonuc = "📚 PDF Açılıyor...";
    });

    try {
      final result = await _pdfService.openTestPDF();
      setState(() {
        _sonuc = result;
      });
    } catch (e) {
      setState(() {
        _sonuc = "❌ HATA: $e";
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Reader - TEST')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.picture_as_pdf, size: 80, color: Colors.red),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.red),
              ),
              child: Column(
                children: [
                  const Text(
                    'PDF TEST SONUCU',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    _sonuc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (_isLoading) ...[
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(),
                  ]
                ],
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _isLoading ? null : _openPDF,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
              ),
              child: const Text('📄 PDF AÇ'),
            ),
          ],
        ),
      ),
    );
  }
}

class PDFNativeService {
  static DynamicLibrary? _nativeLib;
  
  DynamicLibrary get _lib {
    _nativeLib ??= DynamicLibrary.open('libpdf_renderer.so');
    return _nativeLib!;
  }

  // C++ fonksiyonları
  final int Function() _initContext = 
      _lib.lookupFunction<Int64 Function(), int Function()>(
          'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_initContext');
  
  final int Function(int, Pointer<Utf8>) _openDocument = 
      _lib.lookupFunction<Int64 Function(Int64, Pointer<Utf8>), int Function(int, Pointer<Utf8>)>(
          'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_openDocument');
  
  final int Function(int, int) _getPageCount = 
      _lib.lookupFunction<Int32 Function(Int64, Int64), int Function(int, int)>(
          'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getPageCount');
  
  final Pointer<Utf8> Function(int, int) _getDocumentTitle = 
      _lib.lookupFunction<Pointer<Utf8> Function(Int64, Int64), Pointer<Utf8> Function(int, int)>(
          'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getDocumentTitle');

  final void Function(int, int) _closeDocument = 
      _lib.lookupFunction<Void Function(Int64, Int64), void Function(int, int)>(
          'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_closeDocument');

  Future<String> openTestPDF() async {
    try {
      String result = '';

      // 1. Context oluştur
      result += '🔧 Context oluşturuluyor...\n';
      final context = _initContext();
      result += '✅ Context: 0x${context.toRadixString(16)}\n\n';

      // 2. PDF aç
      result += '📄 PDF açılıyor...\n';
      final assetPath = 'assets/test.pdf';
      final pathPtr = assetPath.toNativeUtf8();
      final document = _openDocument(context, pathPtr);
      result += '✅ Document: 0x${document.toRadixString(16)}\n\n';

      // 3. Sayfa sayısı al
      result += '📊 Sayfa sayısı alınıyor...\n';
      final pageCount = _getPageCount(context, document);
      result += '✅ Sayfa Sayısı: $pageCount\n\n';

      // 4. Başlık al
      result += '📝 Başlık alınıyor...\n';
      final titlePtr = _getDocumentTitle(context, document);
      final title = titlePtr.toDartString();
      result += '✅ Başlık: $title\n\n';

      result += '🎉 PDF BAŞARIYLA AÇILDI!\n';
      result += '🚀 C++ PDF Render ÇALIŞIYOR!';

      // Temizlik
      _closeDocument(context, document);
      malloc.free(pathPtr);

      return result;

    } catch (e) {
      return '❌ PDF Açma Hatası: $e';
    }
  }
}
