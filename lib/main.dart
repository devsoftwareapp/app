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

  final PDFNativeService _nativeService = PDFNativeService();

  void _runCppTests() async {
    setState(() {
      _isTesting = true;
      _testResult = "🔧 C++ Backend Testi Başlatılıyor...\n";
    });

    await _nativeService.testBackend();
  }

  void _testSimpleMath() async {
    setState(() {
      _isTesting = true;
      _testResult = "🧮 Basit Matematik Testi...\n";
    });

    try {
      final result = await _nativeService.testSimpleMath();
      setState(() {
        _testResult = result;
      });
    } catch (e) {
      setState(() {
        _testResult = "❌ Matematik Testi Hatası: $e";
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
              'Flutter ↔ C++ Bağlantısını Test Ediyoruz',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 30),
            
            // Test Butonları
            ElevatedButton(
              onPressed: _isTesting ? null : _runCppTests,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('🎯 C++ BACKEND TESTİ'),
            ),
            const SizedBox(height: 15),
            
            ElevatedButton(
              onPressed: _isTesting ? null : _testSimpleMath,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
              ),
              child: const Text('🧮 MATEMATİK TESTİ (2+2)'),
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
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
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
                      ? const CircularProgressIndicator()
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
  
  static DynamicLibrary get _lib {
    try {
      _nativeLib ??= DynamicLibrary.open('libpdf_renderer.so');
      print('✅ Native library loaded successfully');
      return _nativeLib!;
    } catch (e) {
      print('❌ Failed to load native library: $e');
      rethrow;
    }
  }

  // Yeni test fonksiyonları
  final int Function(int, int) _simpleAdd = 
      _lib.lookupFunction<Int32 Function(Int32, Int32), int Function(int, int)>(
          'Java_com_devsoftware_pdf_reader_manager_PDFRenderer_simpleAdd');
  
  final Pointer<Utf8> Function() _getVersion = 
      _lib.lookupFunction<Pointer<Utf8> Function(), Pointer<Utf8> Function()>(
          'Java_com_devsoftware_pdf_reader_manager_PDFRenderer_getVersion');
  
  final Pointer<Utf8> Function(Pointer<Utf8>) _calculate = 
      _lib.lookupFunction<
          Pointer<Utf8> Function(Pointer<Utf8>),
          Pointer<Utf8> Function(Pointer<Utf8>)>(
          'Java_com_devsoftware_pdf_reader_manager_PDFRenderer_calculate');

  // Mevcut PDF fonksiyonları
  final int Function() _initContext = 
      _lib.lookupFunction<Int64 Function(), int Function()>(
          'Java_com_devsoftware_pdf_reader_manager_PDFRenderer_initContext');

  Future<void> testBackend() async {
    print('\n=== 🧪 C++ BACKEND TESTİ BAŞLIYOR ===');
    
    try {
      // Test 1: Basit matematik
      print('1. 🧮 Basit Matematik Testi...');
      final mathResult = _simpleAdd(2, 2);
      print('   ✅ 2 + 2 = $mathResult');

      // Test 2: String dönen fonksiyon
      print('2. 📝 String Fonksiyon Testi...');
      final versionPtr = _getVersion();
      final version = versionPtr.toDartString();
      print('   ✅ Version: $version');

      // Test 3: Hesaplama testi
      print('3. 🔢 Hesaplama Testi...');
      final calcPtr = '2+2'.toNativeUtf8();
      final resultPtr = _calculate(calcPtr);
      final calculation = resultPtr.toDartString();
      print('   ✅ Hesaplama: $calculation');

      malloc.free(calcPtr);

      print('🎉 TÜM C++ TESTLERİ BAŞARILI!');
      print('✅ Flutter ↔ C++ bağlantısı çalışıyor!');

    } catch (e) {
      print('❌ C++ Test Hatası: $e');
      rethrow;
    }
  }

  Future<String> testSimpleMath() async {
    try {
      String result = '🧮 C++ MATEMATİK TESTİ SONUÇLARI:\n\n';
      
      // Toplama testi
      final addResult = _simpleAdd(2, 2);
      result += '✅ 2 + 2 = $addResult\n';
      
      // Versiyon testi
      final versionPtr = _getVersion();
      final version = versionPtr.toDartString();
      result += '✅ $version\n';
      
      // Çeşitli hesaplamalar
      final calc1Ptr = '2+2'.toNativeUtf8();
      final calc1ResultPtr = _calculate(calc1Ptr);
      result += '✅ ${calc1ResultPtr.toDartString()}\n';
      malloc.free(calc1Ptr);

      final calc2Ptr = '5*3'.toNativeUtf8();
      final calc2ResultPtr = _calculate(calc2Ptr);
      result += '✅ ${calc2ResultPtr.toDartString()}\n';
      malloc.free(calc2Ptr);

      final calc3Ptr = '10/2'.toNativeUtf8();
      final calc3ResultPtr = _calculate(calc3Ptr);
      result += '✅ ${calc3ResultPtr.toDartString()}\n';
      malloc.free(calc3Ptr);

      result += '\n🎉 C++ BACKEND BAŞARIYLA ÇALIŞIYOR!';
      return result;

    } catch (e) {
      return '❌ C++ Matematik Testi Hatası: $e';
    }
  }
}
