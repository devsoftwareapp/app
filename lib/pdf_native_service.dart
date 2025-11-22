Future<bool> openDocument(String filePath) async {
  if (!_isInitialized) {
    print('❌ PDFNativeService not initialized');
    return false;
  }

  try {
    // JNI string göndermeden test et
    final pathPtr = "test.pdf".toNativeUtf8(); // Sabit string kullan
    _document = _openDocument(_context, pathPtr);
    final success = _document.address != 0;
    
    if (success) {
      print('📄 Document opened (simulated)');
      print('📖 Page count: ${getPageCount()}');
    } else {
      print('❌ Failed to open document');
    }
    
    malloc.free(pathPtr);
    return success;
  } catch (e) {
    print('❌ Error opening document: $e');
    return false;
  }
}
