import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'pdf_native_service.dart';

void main() => runApp(const PDFReaderApp());

class PDFReaderApp extends StatelessWidget {
  const PDFReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Reader',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const PermissionScreen(),
    );
  }
}

class PermissionScreen extends StatefulWidget {
  const PermissionScreen({super.key});

  @override
  State<PermissionScreen> createState() => _PermissionScreenState();
}

class _PermissionScreenState extends State<PermissionScreen> {
  final PDFNativeService _pdfService = PDFNativeService();
  bool _isTesting = false;

  @override
  void initState() {
    super.initState();
    _initializeBackend();
  }

  void _initializeBackend() async {
    await _pdfService.initialize();
  }

  void _requestPermission(BuildContext context) async {
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }

  void _testBackend() async {
    setState(() => _isTesting = true);
    await _pdfService.testBackend();
    setState(() => _isTesting = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.folder, size: 80),
            const SizedBox(height: 20),
            const Text('Dosya Erişim İzni', style: TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _requestPermission(context),
              child: const Text('Tümüne İzin Ver'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _isTesting ? null : _testBackend,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: _isTesting 
                  ? const CircularProgressIndicator()
                  : const Text('Backend Test Et'),
            ),
          ],
        ),
      ),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('PDF Reader')),
      body: const Center(child: Text('PDF Listesi - C++ backend ile çalışıyor')),
    );
  }
}
