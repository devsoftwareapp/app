package com.devsoftware.pdf_reader_manager

import android.graphics.Bitmap

class PDFRenderer {

    external fun initContext(): Long

    external fun openDocument(ctxPtr: Long, path: String): Long

    external fun getPageCount(ctxPtr: Long, docPtr: Long): Int

    external fun closeDocument(ctxPtr: Long, docPtr: Long)

    external fun destroyContext(ctxPtr: Long)

    companion object {
        init {
            System.loadLibrary("pdf_renderer")
        }
    }
}
