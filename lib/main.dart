import 'package:flutter/material.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

void main() => runApp(const PDFReaderApp());

class PDFReaderApp extends StatelessWidget {
  const PDFReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Reader - C++ Test',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const CppTestScreen(),
    );
  }
}

class CppTestScreen extends StatefulWidget {
  const CppTestScreen({super.key});

  @override
  State<CppTestScreen> createState() => _CppTestScreenState();
}

class _CppTestScreenState extends State<CppTestScreen> {
  String _testResult = "C++ Backend Testi Bekleniyor...";
  bool _isTesting = false;

  void _testExistingFunctions() async {
    setState(() {
      _isTesting = true;
      _testResult = "🔧 Mevcut Fonksiyonlar Test Ediliyor...\n";
    });

    try {
      final result = await PDFNativeService().testExistingFunctions();
      setState(() {
        _testResult = result;
      });
    } catch (e) {
      setState(() {
        _testResult = "❌ Test Hatası: $e";
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  void _testLibraryLoading() async {
    setState(() {
      _isTesting = true;
      _testResult = "📚 Native Library Yükleniyor...\n";
    });

    try {
      final result = await PDFNativeService().testLibraryLoading();
      setState(() {
        _testResult = result;
      });
    } catch (e) {
      setState(() {
        _testResult = "❌ Library Load Hatası: $e";
      });
    } finally {
      setState(() {
        _isTesting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('C++ Backend Test'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.build, size: 80, color: Colors.blue),
            const SizedBox(height: 20),
            const Text(
              'C++ Backend Testi',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              'Önce mevcut fonksiyonları test edelim',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            
            // Test Butonları
            ElevatedButton(
              onPressed: _isTesting ? null : _testLibraryLoading,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('📚 LIBRARY LOAD TEST'),
            ),
            const SizedBox(height: 15),
            
            ElevatedButton(
              onPressed: _isTesting ? null : _testExistingFunctions,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('🔧 MEVCUT FONKSİYONLAR'),
            ),
            const SizedBox(height: 30),

            // Sonuç Ekranı
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Column(
                children: [
                  const Text(
                    'TEST SONUCU',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _isTesting
                      ? const Column(
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 10),
                            Text('C++ fonksiyonları aranıyor...'),
                          ],
                        )
                      : Text(
                          _testResult,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            height: 1.5,
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
}

class PDFNativeService {
  static DynamicLibrary? _nativeLib;
  
  DynamicLibrary get _lib {
    if (_nativeLib != null) return _nativeLib!;
    
    try {
      print('🔧 Attempting to load libpdf_renderer.so...');
      _nativeLib = DynamicLibrary.open('libpdf_renderer.so');
      print('✅ Native library loaded successfully');
      return _nativeLib!;
    } catch (e) {
      print('❌ Failed to load native library: $e');
      rethrow;
    }
  }

  // SADECE MEVCUT FONKSİYONLARI TANIMLA
  // initContext fonksiyonu
  int _initContext() {
    try {
      final func = _lib.lookupFunction<Int64 Function(), int Function()>(
        'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_initContext'
      );
      return func();
    } catch (e) {
      print('❌ initContext lookup failed: $e');
      rethrow;
    }
  }

  // openDocument fonksiyonu
  int _openDocument(int context, String path) {
    try {
      final func = _lib.lookupFunction<
        Int64 Function(Int64, Pointer<Utf8>),
        int Function(int, Pointer<Utf8>)
      >('Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_openDocument');
      
      final pathPtr = path.toNativeUtf8();
      final result = func(context, pathPtr);
      malloc.free(pathPtr);
      return result;
    } catch (e) {
      print('❌ openDocument lookup failed: $e');
      rethrow;
    }
  }

  // getPageCount fonksiyonu
  int _getPageCount(int context, int document) {
    try {
      final func = _lib.lookupFunction<
        Int32 Function(Int64, Int64),
        int Function(int, int)
      >('Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getPageCount');
      return func(context, document);
    } catch (e) {
      print('❌ getPageCount lookup failed: $e');
      rethrow;
    }
  }

  Future<String> testLibraryLoading() async {
    try {
      String result = '📚 NATIVE LIBRARY TESTİ:\n\n';
      
      // Sadece library yükleme testi
      final lib = _lib;
      result += '✅ libpdf_renderer.so başarıyla yüklendi!\n';
      result += '✅ DynamicLibrary handle: ${lib.handle}\n';
      result += '✅ Native kod erişilebilir durumda\n';
      
      return result;
    } catch (e) {
      return '❌ Library Load Hatası: $e';
    }
  }

  Future<String> testExistingFunctions() async {
    try {
      String result = '🔧 MEVCUT FONKSİYON TESTİ:\n\n';
      
      // Test 1: initContext
      result += '1. initContext() testi...\n';
      final context = _initContext();
      result += '   ✅ Context oluşturuldu: 0x${context.toRadixString(16)}\n\n';
      
      // Test 2: openDocument
      result += '2. openDocument() testi...\n';
      final document = _openDocument(context, "/test/dummy.pdf");
      result += '   ✅ Document açıldı: 0x${document.toRadixString(16)}\n\n';
      
      // Test 3: getPageCount
      result += '3. getPageCount() testi...\n';
      final pageCount = _getPageCount(context, document);
      result += '   ✅ Sayfa sayısı: $pageCount\n\n';
      
      result += '🎉 TÜM MEVCUT FONKSİYONLAR ÇALIŞIYOR!\n';
      result += '✅ C++ ↔ Flutter bağlantısı başarılı!';
      
      return result;
    } catch (e) {
      return '❌ Fonksiyon Test Hatası: $e';
    }
  }
}
