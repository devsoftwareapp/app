package com.devsoftware.pdf_reader_manager

import android.util.Log

class PDFRenderer {
    companion object {
        init {
            try {
                System.loadLibrary("pdf_renderer")
                Log.d("PDFRenderer", "✅ Native library loaded: libpdf_renderer.so")
            } catch (e: UnsatisfiedLinkError) {
                Log.e("PDFRenderer", "❌ Native library load failed: ${e.message}")
            } catch (e: Exception) {
                Log.e("PDFRenderer", "❌ Error loading native library: ${e.message}")
            }
        }
    }

    // Basit test fonksiyonları
    external fun simpleAdd(a: Int, b: Int): Int
    external fun getVersion(): String

    // PDFium fonksiyonları
    external fun initPDFium(): Boolean
    external fun openDocument(filePath: String): Long
    external fun getPageCount(documentPtr: Long): Int
    external fun closeDocument(documentPtr: Long)
    external fun destroyPDFium()
    external fun getPageSize(documentPtr: Long, pageIndex: Int): IntArray
}
