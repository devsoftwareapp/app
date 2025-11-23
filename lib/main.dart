import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';
import 'dart:math';
import 'package:pdfx/pdfx.dart';
import 'package:flutter_pdf_text/flutter_pdf_text.dart';

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

  void _openPDF(PDFDocument document) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(document: document),
      ),
    );
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

class PDFViewerScreen extends StatefulWidget {
  final PDFDocument document;

  const PDFViewerScreen({super.key, required this.document});

  @override
  State<PDFViewerScreen> createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  late PdfController _pdfController;
  bool _isLoading = true;
  final TextEditingController _textSearchController = TextEditingController();
  bool _isTextSearching = false;
  List<TextSearchResult> _searchResults = [];
  int _currentSearchIndex = 0;
  PDFDoc? _pdfDoc;

  @override
  void initState() {
    super.initState();
    _loadPDF();
    _loadPDFText();
  }

  Future<void> _loadPDF() async {
    try {
      final controller = PdfController(
        document: PdfDocument.openFile(widget.document.path),
      );
      setState(() {
        _pdfController = controller;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      print('PDF yükleme hatası: $e');
    }
  }

  Future<void> _loadPDFText() async {
    try {
      _pdfDoc = await PDFDoc.fromFile(File(widget.document.path));
      print('PDF text yüklendi: ${_pdfDoc!.length} sayfa');
    } catch (e) {
      print('PDF text yükleme hatası: $e');
    }
  }

  Future<void> _searchText(String query) async {
    if (query.isEmpty || _pdfDoc == null) {
      setState(() {
        _isTextSearching = false;
        _searchResults.clear();
        _currentSearchIndex = 0;
      });
      return;
    }

    try {
      setState(() => _isLoading = true);
      
      final results = <TextSearchResult>[];
      final searchQuery = query.toLowerCase();
      
      // Tüm sayfalarda arama yap
      for (int pageNum = 1; pageNum <= _pdfDoc!.length; pageNum++) {
        try {
          final pageText = await _pdfDoc!.pageAt(pageNum).text;
          if (pageText.toLowerCase().contains(searchQuery)) {
            results.add(TextSearchResult(
              pageNumber: pageNum,
              text: pageText,
            ));
          }
        } catch (e) {
          print('Sayfa $pageNum okunamadı: $e');
        }
      }
      
      setState(() {
        _searchResults = results;
        _isTextSearching = true;
        _currentSearchIndex = 0;
        _isLoading = false;
      });

      if (_searchResults.isNotEmpty) {
        _jumpToSearchResult(_currentSearchIndex);
        _showSnackBar('${results.length} sonuç bulundu', Colors.green);
      } else {
        _showSnackBar('Arama sonucu bulunamadı', Colors.orange);
      }
    } catch (e) {
      setState(() => _isLoading = false);
      print('Arama hatası: $e');
      _showSnackBar('Arama yapılamadı', Colors.red);
    }
  }

  void _jumpToSearchResult(int index) {
    if (_searchResults.isEmpty) return;
    
    final result = _searchResults[index];
    _pdfController.jumpToPage(result.pageNumber);
    
    setState(() {
      _currentSearchIndex = index;
    });
    
    _showSnackBar('Sayfa ${result.pageNumber} bulundu', Colors.blue);
  }

  void _nextSearchResult() {
    if (_searchResults.isEmpty) return;
    
    final nextIndex = (_currentSearchIndex + 1) % _searchResults.length;
    _jumpToSearchResult(nextIndex);
  }

  void _previousSearchResult() {
    if (_searchResults.isEmpty) return;
    
    final prevIndex = (_currentSearchIndex - 1) % _searchResults.length;
    _jumpToSearchResult(prevIndex);
  }

  void _clearTextSearch() {
    _textSearchController.clear();
    setState(() {
      _isTextSearching = false;
      _searchResults.clear();
      _currentSearchIndex = 0;
    });
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _pdfController.dispose();
    _textSearchController.dispose();
    super.dispose();
  }

  void _nextPage() {
    _pdfController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  void _previousPage() {
    _pdfController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.document.name),
        actions: [
          // Metin Arama Butonu
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('PDF İçinde Ara'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: _textSearchController,
                        decoration: const InputDecoration(
                          hintText: 'Aranacak metni yazın...',
                          border: OutlineInputBorder(),
                        ),
                        autofocus: true,
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.only(top: 8.0),
                          child: LinearProgressIndicator(),
                        ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _clearTextSearch();
                      },
                      child: const Text('İptal'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _searchText(_textSearchController.text);
                      },
                      child: const Text('Ara'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _previousPage,
          ),
          PdfPageNumber(
            controller: _pdfController,
            builder: (_, state, loadingState, pagesCount) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              child: Text(
                '${_pdfController.page} / ${pagesCount ?? 0}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward),
            onPressed: _nextPage,
          ),
        ],
      ),
      body: Column(
        children: [
          // Arama Sonuçları Gösterimi
          if (_isTextSearching && _searchResults.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(8),
              color: Colors.blue[50],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentSearchIndex + 1}/${_searchResults.length} sonuç - Sayfa ${_searchResults[_currentSearchIndex].pageNumber}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios, size: 16),
                        onPressed: _previousSearchResult,
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios, size: 16),
                        onPressed: _nextSearchResult,
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 16),
                        onPressed: _clearTextSearch,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          // PDF Görüntüleyici
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : PdfView(
                    controller: _pdfController,
                    scrollDirection: Axis.vertical,
                    physics: const BouncingScrollPhysics(),
                  ),
          ),
        ],
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

class TextSearchResult {
  final int pageNumber;
  final String text;

  TextSearchResult({
    required this.pageNumber,
    required this.text,
  });
}
