import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:math';
import 'package:path_provider/path_provider.dart';

void main() => runApp(const PDFReaderApp());

class PDFReaderApp extends StatelessWidget {
  const PDFReaderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PDF Reader + Arama',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      home: const PDFLibraryScreen(),
    );
  }
}

class PDFLibraryScreen extends StatefulWidget {
  const PDFLibraryScreen({super.key});

  @override
  State<PDFLibraryScreen> createState() => _PDFLibraryScreenState();
}

class _PDFLibraryScreenState extends State<PDFLibraryScreen> {
  final List<PDFDocument> _documents = [];
  final List<PDFDocument> _filteredDocuments = [];
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_searchPDFs);
  }

  void _searchPDFs() {
    final query = _searchController.text.toLowerCase();
    
    if (query.isEmpty) {
      setState(() {
        _filteredDocuments.clear();
        _filteredDocuments.addAll(_documents);
        _isSearching = false;
      });
    } else {
      setState(() {
        _filteredDocuments.clear();
        _filteredDocuments.addAll(
          _documents.where((doc) => 
            doc.name.toLowerCase().contains(query)
          ).toList()
        );
        _isSearching = true;
      });
    }
  }

  Future<void> _pickPDF() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() => _isLoading = true);
        
        for (var file in result.files) {
          if (file.path != null) {
            final document = PDFDocument(
              name: file.name,
              path: file.path!,
              dateAdded: DateTime.now(),
              fileSize: file.size,
            );
            
            _documents.add(document);
          }
        }
        
        _searchPDFs();
        setState(() => _isLoading = false);
        
        _showSnackBar('${result.files.length} PDF eklendi', Colors.green);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      _showSnackBar('Hata: $e', Colors.red);
    }
  }

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

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void _clearSearch() {
    _searchController.clear();
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'PDF ara...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: _clearSearch,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildPDFGrid() {
    final displayDocuments = _isSearching ? _filteredDocuments : _documents;
    
    if (displayDocuments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _isSearching ? Icons.search_off : Icons.folder_open,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 20),
            Text(
              _isSearching ? 'Arama sonucu bulunamadı' : 'Henüz PDF yok',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
            const SizedBox(height: 10),
            Text(
              _isSearching 
                  ? 'Farklı bir anahtar kelime deneyin'
                  : 'Sağ alttaki + butonuna tıkla\nve PDF ekle',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 0.7,
      ),
      itemCount: displayDocuments.length,
      itemBuilder: (context, index) => _buildPDFCard(displayDocuments[index]),
    );
  }

  Widget _buildPDFCard(PDFDocument document) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _openPDF(document),
        child: Column(
          children: [
            Expanded(
              child: Container(
                color: Colors.red[50],
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.picture_as_pdf, size: 50, color: Colors.red),
                    const SizedBox(height: 8),
                    const Text(
                      'PDF',
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    document.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatFileSize(document.fileSize),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
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

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return '0 B';
    const suffixes = ['B', 'KB', 'MB', 'GB'];
    var i = (log(bytes) / log(1024)).floor();
    return '${(bytes / pow(1024, i)).toStringAsFixed(1)} ${suffixes[i]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isSearching ? 'Arama Sonuçları' : 'PDF Kütüphanem'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildPDFGrid(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickPDF,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

class PDFDocument {
  final String name;
  final String path;
  final DateTime dateAdded;
  final int fileSize;

  PDFDocument({
    required this.name,
    required this.path,
    required this.dateAdded,
    required this.fileSize,
  });
}
