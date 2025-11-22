class PDFNativeService {
  static DynamicLibrary? _nativeLib;
  
  DynamicLibrary get _lib {
    _nativeLib ??= DynamicLibrary.open('libpdf_renderer.so');
    return _nativeLib!;
  }

  // C++ fonksiyonları - LAZY INITIALIZATION
  int Function() get _initContext => 
      _lib.lookupFunction<Int64 Function(), int Function()>(
          'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_initContext');
  
  int Function(int, Pointer<Utf8>) get _openDocument => 
      _lib.lookupFunction<Int64 Function(Int64, Pointer<Utf8>), int Function(int, Pointer<Utf8>)>(
          'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_openDocument');
  
  int Function(int, int) get _getPageCount => 
      _lib.lookupFunction<Int32 Function(Int64, Int64), int Function(int, int)>(
          'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getPageCount');
  
  Pointer<Utf8> Function(int, int) get _getDocumentTitle => 
      _lib.lookupFunction<Pointer<Utf8> Function(Int64, Int64), Pointer<Utf8> Function(int, int)>(
          'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getDocumentTitle');

  void Function(int, int) get _closeDocument => 
      _lib.lookupFunction<Void Function(Int64, Int64), void Function(int, int)>(
          'Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_closeDocument');

  Future<String> openTestPDF() async {
    try {
      String result = '';

      // 1. Context oluştur
      result += '🔧 Context oluşturuluyor...\n';
      final context = _initContext();
      result += '✅ Context: 0x${context.toRadixString(16)}\n\n';

      // 2. PDF aç
      result += '📄 PDF açılıyor...\n';
      final assetPath = 'assets/test.pdf';
      final pathPtr = assetPath.toNativeUtf8();
      final document = _openDocument(context, pathPtr);
      result += '✅ Document: 0x${document.toRadixString(16)}\n\n';

      // 3. Sayfa sayısı al
      result += '📊 Sayfa sayısı alınıyor...\n';
      final pageCount = _getPageCount(context, document);
      result += '✅ Sayfa Sayısı: $pageCount\n\n';

      // 4. Başlık al
      result += '📝 Başlık alınıyor...\n';
      final titlePtr = _getDocumentTitle(context, document);
      final title = titlePtr.toDartString();
      result += '✅ Başlık: $title\n\n';

      result += '🎉 PDF BAŞARIYLA AÇILDI!\n';
      result += '🚀 C++ PDF Render ÇALIŞIYOR!';

      // Temizlik
      _closeDocument(context, document);
      malloc.free(pathPtr);

      return result;

    } catch (e) {
      return '❌ PDF Açma Hatası: $e';
    }
  }
}
