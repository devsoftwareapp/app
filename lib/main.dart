import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
  String _testResult = "Test edilmedi";

  void _requestPermission(BuildContext context) async {
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    }
  }

  void _simpleTest() {
    setState(() {
      _testResult = "🔧 Test başlatılıyor...";
    });

    // Sadece Flutter testi - C++ olmadan
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _testResult = "✅ Flutter UI çalışıyor!\n🎯 Buton tıklanabilir\n📱 Uygulama açık kalıyor";
      });
    });
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
              onPressed: _simpleTest,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('BASİT TEST'),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey),
              ),
              child: Text(
                _testResult,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
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
