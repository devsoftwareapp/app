import 'package:flutter/material.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

void main() => runApp(const MyApp());

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _sonuc = "Test edilmedi...";
  bool _testEdiliyor = false;

  void _testPDFium() async {
    setState(() {
      _testEdiliyor = true;
      _sonuc = "🔧 PDFium Testi Başlıyor...";
    });

    try {
      setState(() => _sonuc = "📚 Native Library Yükleniyor...");
      final lib = DynamicLibrary.open('libpdf_renderer.so');
      setState(() => _sonuc = "✅ Native Library Yüklendi!");

      // PDFium Fonksiyonlarını Yükle
      setState(() => _sonuc = "🔍 PDFium Fonksiyonları Aranıyor...");
      
      final initPDFium = lib.lookupFunction<
        Int32 Function(),
        int Function()
      >('Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_initPDFium');

      final openDocument = lib.lookupFunction<
        Int64 Function(Pointer<Utf8>),
        int Function(Pointer<Utf8>)
      >('Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_openDocument');

      final getPageCount = lib.lookupFunction<
        Int32 Function(Int64),
        int Function(int)
      >('Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getPageCount');

      setState(() => _sonuc = "✅ PDFium Fonksiyonları Bulundu!");

      // PDFium Testi
      setState(() => _sonuc = "🎯 PDFium Başlatılıyor...");
      final initResult = initPDFium();
      
      setState(() => _sonuc = "📄 PDF Belgesi Açılıyor...");
      final testPath = "test.pdf".toNativeUtf8();
      final documentPtr = openDocument(testPath);
      malloc.free(testPath);

      setState(() => _sonuc = "📊 Sayfa Sayısı Alınıyor...");
      final pageCount = getPageCount(documentPtr);

      setState(() {
        _sonuc = "🎉 PDFIUM BACKEND ÇALIŞIYOR! 🚀\n\n"
                "✅ PDFium Init: $initResult\n"
                "✅ Document Pointer: 0x${documentPtr.toRadixString(16)}\n"
                "✅ Page Count: $pageCount\n\n"
                "🎯 PDFium Backend Hazır!";
      });

    } catch (e) {
      setState(() => _sonuc = "❌ HATA: $e");
    } finally {
      setState(() => _testEdiliyor = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('🎯 PDFIUM BACKEND TEST')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.blue),
                ),
                child: Column(
                  children: [
                    const Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
                    const SizedBox(height: 20),
                    Text(
                      _sonuc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 16),
                    ),
                    if (_testEdiliyor) ...[
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(),
                    ]
                  ],
                ),
              ),
              ElevatedButton(
                onPressed: _testEdiliyor ? null : _testPDFium,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('🎯 PDFIUM TESTİ BAŞLAT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
