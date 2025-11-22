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

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

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
          ],
        ),
      ),
    );
  }

  void _requestPermission(BuildContext context) async {
    final status = await Permission.manageExternalStorage.request();
    if (status.isGranted) {
      Navigator.push(context, MaterialPageRoute(builder: (_) => const MainScreen()));
    }
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
