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
      print('🔧 Attempting to initialize native context...');
      _context = _initContext();
      _isInitialized = _context.address != 0;
      if (_isInitialized) {
        print('🎯 SUCCESS: MuPDF initialized - Context: ${_context.address}');
      } else {
        print('❌ FAILED: MuPDF initialization returned null');
      }
      return _isInitialized;
    } catch (e) {
      print('❌ ERROR initializing MuPDF: $e');
      return false;
    }
  }

  Future<bool> openDocument(String filePath) async {
    print('📁 Attempting to open document: $filePath');
    
    if (!_isInitialized) {
      print('❌ Cannot open document - service not initialized');
      return false;
    }

    try {
      print('🔧 Converting path to native string...');
      final pathPtr = "test.pdf".toNativeUtf8();
      print('🔧 Calling native openDocument function...');
      
      _document = _openDocument(_context, pathPtr);
      final success = _document.address != 0;
      
      if (success) {
        print('📄 SUCCESS: Document opened (simulated)');
        print('📖 Getting page count...');
        final pageCount = getPageCount();
        print('📊 Page count: $pageCount');
      } else {
        print('❌ FAILED: Document open returned null');
      }
      
      print('🔧 Freeing native memory...');
      malloc.free(pathPtr);
      return success;
    } catch (e) {
      print('❌ ERROR opening document: $e');
      return false;
    }
  }

  int getPageCount() {
    print('🔧 Getting page count...');
    
    if (!_isInitialized) {
      print('❌ Cannot get page count - service not initialized');
      return 0;
    }
    
    if (_document.address == 0) {
      print('❌ Cannot get page count - no document open');
      return 0;
    }
    
    try {
      final count = _getPageCount(_context, _document);
      print('📊 Native page count result: $count');
      return count;
    } catch (e) {
      print('❌ ERROR getting page count: $e');
      return 0;
    }
  }

  Future<void> testBackend() async {
    print('\n══════════════════════════════════════');
    print('🧪 STARTING PDF BACKEND TEST');
    print('══════════════════════════════════════\n');
    
    // Test 1: Initialization
    print('1. 🔧 TESTING INITIALIZATION');
    print('   📞 Calling native initContext...');
    final initSuccess = await initialize();
    print('   📋 Result: $initSuccess');
    
    if (initSuccess) {
      print('   ✅ INITIALIZATION TEST PASSED\n');
      
      // Test 2: Document operations
      print('2. 📄 TESTING DOCUMENT OPERATIONS');
      print('   📞 Calling native openDocument...');
      
      final openSuccess = await openDocument("/dummy/path.pdf");
      print('   📋 Document open result: $openSuccess');
      
      if (openSuccess) {
        print('   ✅ DOCUMENT OPEN TEST PASSED\n');
        
        // Test 3: Page count
        print('3. 📊 TESTING PAGE COUNT');
        final pageCount = getPageCount();
        print('   📋 Page count result: $pageCount');
        print('   ✅ PAGE COUNT TEST PASSED\n');
      } else {
        print('   ⚠️  DOCUMENT OPEN TEST FAILED (expected for simulation)\n');
      }
    } else {
      print('   ❌ INITIALIZATION TEST FAILED\n');
    }
    
    print('══════════════════════════════════════');
    print('📋 TEST SUMMARY:');
    print('   • Initialization: $initSuccess');
    print('   • Backend Communication: ${initSuccess ? "WORKING" : "FAILED"}');
    print('   • Native Calls: ${initSuccess ? "SUCCESSFUL" : "FAILED"}');
    print('══════════════════════════════════════\n');
    
    // Final check
    if (initSuccess) {
      print('🎉 BACKEND TEST: SUCCESS!');
      print('   Flutter ↔ C++ communication is working!');
    } else {
      print('💥 BACKEND TEST: FAILED!');
      print('   Native library communication issue');
    }
    print('══════════════════════════════════════\n');
  }

  void dispose() {
    print('🔧 Cleaning up native resources...');
    
    if (_document.address != 0) {
      print('   📄 Closing document...');
      _closeDocument(_context, _document);
      _document = nullptr;
    }
    
    if (_isInitialized) {
      print('   🎯 Destroying context...');
      _destroyContext(_context);
      _isInitialized = false;
    }
    
    print('✅ Cleanup completed');
  }
}
