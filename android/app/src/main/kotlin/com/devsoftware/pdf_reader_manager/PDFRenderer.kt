package com.devsoftware.pdf_reader_manager

class PDFRenderer {
    companion object {
        init {
            System.loadLibrary("pdf_renderer")
        }
    }

    external fun initContext(): Long
    external fun openDocument(context: Long, filePath: String): Long
    external fun getPageCount(context: Long, document: Long): Int
    external fun getDocumentTitle(context: Long, document: Long): String
    external fun closeDocument(context: Long, document: Long)
    external fun destroyContext(context: Long)
}
