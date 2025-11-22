import 'package:flutter/material.dart';
import 'dart:ffi';
import 'package:ffi/ffi.dart';

void main() => runApp(const PDFReaderApp());

class PDFReaderApp extends StatelessWidget {
  const PDFReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('C++ Test')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: _testCpp,
                child: const Text('TEST C++'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _testCpp() async {
    try {
      print('🔧 Testing C++...');
      final lib = DynamicLibrary.open('libpdf_renderer.so');
      print('✅ Library loaded');
      
      final simpleAdd = lib.lookupFunction<
        Int32 Function(Int32, Int32),
        int Function(int, int)
      >('Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_simpleAdd');
      
      final result = simpleAdd(2, 3);
      print('🎉 C++ Result: 2 + 3 = $result');
    } catch (e) {
      print('❌ C++ Error: $e');
    }
  }
}
