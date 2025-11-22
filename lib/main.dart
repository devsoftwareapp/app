import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';

void _openPDF(PDFDocument document) async {
  try {
    final file = File(document.path);
    if (await file.exists()) {
      // FileProvider ile güvenli URI oluştur
      final tempDir = await getTemporaryDirectory();
      final tempFile = await _copyToTemp(file, tempDir);
      
      final uri = Uri.file(tempFile.path);
      
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        _showSnackBar('PDF görüntüleyici bulunamadı', Colors.orange);
      }
    } else {
      _showSnackBar('PDF dosyası bulunamadı', Colors.red);
    }
  } catch (e) {
    _showSnackBar('PDF açılamadı: $e', Colors.red);
  }
}

Future<File> _copyToTemp(File originalFile, Directory tempDir) async {
  final tempFile = File('${tempDir.path}/${originalFile.uri.pathSegments.last}');
  if (await tempFile.exists()) {
    await tempFile.delete();
  }
  return await originalFile.copy(tempFile.path);
}
