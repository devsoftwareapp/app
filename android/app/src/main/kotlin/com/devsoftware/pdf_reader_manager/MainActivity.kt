package com.devsoftware.pdf_reader_manager

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.util.Log

class MainActivity: FlutterActivity() {
    private val TAG = "PDFReaderMainActivity"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "🎬 MainActivity created - Starting PDF Reader Manager")
        Log.d(TAG, "✅ MainActivity setup completed")
    }
    
    override fun onStart() {
        super.onStart()
        Log.d(TAG, "🚀 MainActivity started - App is now visible")
    }
    
    override fun onResume() {
        super.onResume()
        Log.d(TAG, "📱 MainActivity resumed - App is in foreground")
    }
    
    override fun onPause() {
        super.onPause()
        Log.d(TAG, "⏸️ MainActivity paused - App is in background")
    }
    
    override fun onStop() {
        super.onStop()
        Log.d(TAG, "🛑 MainActivity stopped - App is no longer visible")
    }
    
    override fun onDestroy() {
        super.onDestroy()
        Log.d(TAG, "💀 MainActivity destroyed - App is closing")
        Log.d(TAG, "👋 PDF Reader Manager shutting down")
    }
    
    override fun onBackPressed() {
        Log.d(TAG, "↩️ Back button pressed")
        super.onBackPressed()
    }
}
