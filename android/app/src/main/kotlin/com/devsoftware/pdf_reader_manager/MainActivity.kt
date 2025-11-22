package com.devsoftware.pdf_reader_manager

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.util.Log

class MainActivity: FlutterActivity() {
    private val TAG = "MainActivity"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "MainActivity created - PDFRenderer native library will auto-load")
        
        // The PDFRenderer companion object automatically loads the native library
        // when the class is first accessed
        try {
            // Force load the PDFRenderer class to trigger native library loading
            Class.forName("com.devsoftware.pdf_reader_manager.PDFRenderer")
            Log.d(TAG, "PDFRenderer native library loaded successfully")
        } catch (e: Exception) {
            Log.e(TAG, "Failed to load PDFRenderer native library: ${e.message}")
        }
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "MainActivity destroyed")
    }
}
