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
    external fun calculate(operation: String): String

    // PDF fonksiyonları
    external fun initContext(): Long
    external fun openDocument(context: Long, path: String): Long
    external fun getPageCount(context: Long, document: Long): Int
    external fun closeDocument(context: Long, document: Long)
    external fun destroyContext(context: Long)
}
