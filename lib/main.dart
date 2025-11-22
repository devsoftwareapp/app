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

  void _testCpp() async {
    setState(() {
      _testEdiliyor = true;
      _sonuc = "🔧 Test başlıyor...";
    });

    await Future.delayed(const Duration(milliseconds: 100));

    try {
      setState(() => _sonuc = "📚 Library yükleniyor...");
      final lib = DynamicLibrary.open('libpdf_renderer.so');
      setState(() => _sonuc = "✅ Library yüklendi!");

      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() => _sonuc = "🔍 Fonksiyon aranıyor...");
      final simpleAdd = lib.lookupFunction<
        Int32 Function(Int32, Int32),
        int Function(int, int)
      >('Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_simpleAdd');
      setState(() => _sonuc = "✅ Fonksiyon bulundu!");

      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() => _sonuc = "🎯 Fonksiyon çağrılıyor...");
      final result = simpleAdd(2, 3);
      
      setState(() => _sonuc = "🎉 BAŞARILI! 2 + 3 = $result\n\nC++ ÇALIŞIYOR! 🚀");

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
        appBar: AppBar(title: const Text('C++ Test - EKRAN')),
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
                    const Icon(Icons.build, size: 50, color: Colors.blue),
                    const SizedBox(height: 20),
                    Text(
                      _sonuc,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 18),
                    ),
                    if (_testEdiliyor) ...[
                      const SizedBox(height: 20),
                      const CircularProgressIndicator(),
                    ]
                  ],
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _testEdiliyor ? null : _testCpp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                ),
                child: const Text('🎯 C++ TESTİ BAŞLAT'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
