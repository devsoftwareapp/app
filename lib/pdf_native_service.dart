import 'dart:ffi';
import 'package:ffi/ffi.dart';

class PDFNativeService {
  static DynamicLibrary? _nativeLib;
  
  static DynamicLibrary get _lib {
    _nativeLib ??= DynamicLibrary.open('libpdf_renderer.so');
    return _nativeLib!;
  }

  // Native function signatures
  final Pointer<Void> Function() _initContext = 
      _lib.lookupFunction<Pointer<Void> Function(), Pointer<Void> Function()>(
          'Java_com_devsoftware_pdf_reader_manager_PDFRenderer_initContext');
  
  final Pointer<Void> Function(Pointer<Void>, Pointer<Utf8>) _openDocument = 
      _lib.lookupFunction<
          Pointer<Void> Function(Pointer<Void>, Pointer<Utf8>),
          Pointer<Void> Function(Pointer<Void>, Pointer<Utf8>)>(
          'Java_com_devsoftware_pdf_reader_manager_PDFRenderer_openDocument');
  
  final int Function(Pointer<Void>, Pointer<Void>) _getPageCount = 
      _lib.lookupFunction<
          Int32 Function(Pointer<Void>, Pointer<Void>),
          int Function(Pointer<Void>, Pointer<Void>)>(
          'Java_com_devsoftware_pdf_reader_manager_PDFRenderer_getPageCount');

  final void Function(Pointer<Void>, Pointer<Void>) _closeDocument = 
      _lib.lookupFunction<
          Void Function(Pointer<Void>, Pointer<Void>),
          void Function(Pointer<Void>, Pointer<Void>)>(
          'Java_com_devsoftware_pdf_reader_manager_PDFRenderer_closeDocument');

  final void Function(Pointer<Void>) _destroyContext = 
      _lib.lookupFunction<
          Void Function(Pointer<Void>),
          void Function(Pointer<Void>)>(
          'Java_com_devsoftware_pdf_reader_manager_PDFRenderer_destroyContext');

  late Pointer<Void> _context;
  late Pointer<Void> _document;
  bool _isInitialized = false;

  Future<bool> initialize() async {
    try {
      _context = _initContext();
      _isInitialized = _context.address != 0;
      if (_isInitialized) {
        print('🎯 MuPDF initialized successfully - Context: ${_context.address}');
      } else {
        print('❌ Failed to initialize MuPDF');
      }
      return _isInitialized;
    } catch (e) {
      print('❌ Error initializing MuPDF: $e');
      return false;
    }
  }

  Future<bool> openDocument(String filePath) async {
    if (!_isInitialized) {
      print('❌ PDFNativeService not initialized');
      return false;
    }

    try {
      // Basit test - JNI string göndermeden
      final pathPtr = "test.pdf".toNativeUtf8();
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

  int getPageCount() {
    if (!_isInitialized || _document.address == 0) {
      return 0;
    }
    try {
      return _getPageCount(_context, _document);
    } catch (e) {
      print('❌ Error getting page count: $e');
      return 0;
    }
  }

  Future<void> testBackend() async {
    print('\n=== 🧪 TESTING PDF BACKEND ===');
    
    // Test 1: Initialization
    print('1. Testing initialization...');
    final initSuccess = await initialize();
    print('   ✅ Initialization: $initSuccess');
    
    if (initSuccess) {
      // Test 2: Document operations
      print('2. Testing document operations...');
      
      final openSuccess = await openDocument("/dummy/path.pdf");
      print('   ✅ Document open: $openSuccess');
      
      if (openSuccess) {
        final pageCount = getPageCount();
        print('   📊 Page count: $pageCount');
      }
    }
    
    print('=== ✅ BACKEND TEST COMPLETE ===\n');
  }

  void dispose() {
    if (_document.address != 0) {
      _closeDocument(_context, _document);
      _document = nullptr;
      print('📄 Document closed');
    }
    
    if (_isInitialized) {
      _destroyContext(_context);
      _isInitialized = false;
      print('🎯 MuPDF context destroyed');
    }
  }
}
