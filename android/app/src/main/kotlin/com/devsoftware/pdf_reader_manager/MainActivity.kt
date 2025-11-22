package com.devsoftware.pdf_reader_manager

import io.flutter.embedding.android.FlutterActivity
import android.os.Bundle
import android.util.Log

class MainActivity: FlutterActivity() {
    private val TAG = "PDFReaderMainActivity"
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "🎬 MainActivity created - Starting PDF Reader Manager")
        Log.d(TAG, "🔧 Attempting to load native PDFRenderer library")
        
        // Test native library loading
        testNativeLibraryLoading()
        
        Log.d(TAG, "✅ MainActivity setup completed")
    }
    
    private fun testNativeLibraryLoading() {
        try {
            Log.d(TAG, "📦 Loading PDFRenderer class...")
            
            // Force load the PDFRenderer class to trigger native library loading
            val pdfRendererClass = Class.forName("com.devsoftware.pdf_reader_manager.PDFRenderer")
            Log.d(TAG, "✅ PDFRenderer class loaded successfully: ${pdfRendererClass.simpleName}")
            
            // Test if native methods are accessible
            testNativeMethods()
            
        } catch (e: ClassNotFoundException) {
            Log.e(TAG, "❌ PDFRenderer class not found: ${e.message}")
        } catch (e: UnsatisfiedLinkError) {
            Log.e(TAG, "❌ Native library loading failed: ${e.message}")
            Log.e(TAG, "🔍 Check if libpdf_renderer.so exists in APK")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Unexpected error loading native library: ${e.message}")
        }
    }
    
    private fun testNativeMethods() {
        try {
            Log.d(TAG, "🧪 Testing native method accessibility...")
            
            // Create PDFRenderer instance to test native methods
            val pdfRenderer = PDFRenderer()
            Log.d(TAG, "✅ PDFRenderer instance created successfully")
            
            // Test initialization method - YENİ FONKSİYONLARI KULLAN
            Log.d(TAG, "🔧 Testing initPDFium() method...")
            val initSuccess = pdfRenderer.initPDFium()
            Log.d(TAG, "✅ initPDFium() successful - returned: $initSuccess")
            
            if (initSuccess) {
                Log.d(TAG, "🎯 PDFium initialized successfully")
                
                // Test document opening with dummy path - YENİ FONKSİYON
                Log.d(TAG, "📄 Testing openDocument() method...")
                val docPtr = pdfRenderer.openDocument("/test/dummy.pdf")
                Log.d(TAG, "✅ openDocument() successful - returned: $docPtr")
                
                if (docPtr != 0L) {
                    // Test page count - YENİ FONKSİYON
                    Log.d(TAG, "📊 Testing getPageCount() method...")
                    val pageCount = pdfRenderer.getPageCount(docPtr) // SADECE 1 PARAMETRE
                    Log.d(TAG, "✅ getPageCount() successful - returned: $pageCount")
                    
                    // Test cleanup - YENİ FONKSİYON
                    Log.d(TAG, "🧹 Testing closeDocument() method...")
                    pdfRenderer.closeDocument(docPtr) // SADECE 1 PARAMETRE
                    Log.d(TAG, "✅ closeDocument() successful")
                }
                
                // Test PDFium destruction - YENİ FONKSİYON
                Log.d(TAG, "🧹 Testing destroyPDFium() method...")
                pdfRenderer.destroyPDFium()
                Log.d(TAG, "✅ destroyPDFium() successful")
            }
            
            // Basit test fonksiyonlarını da test et
            Log.d(TAG, "🧮 Testing simpleAdd() method...")
            val addResult = pdfRenderer.simpleAdd(2, 3)
            Log.d(TAG, "✅ simpleAdd(2, 3) = $addResult")
            
            Log.d(TAG, "📝 Testing getVersion() method...")
            val version = pdfRenderer.getVersion()
            Log.d(TAG, "✅ getVersion() = $version")
            
            Log.d(TAG, "🎉 ALL NATIVE METHODS TESTED SUCCESSFULLY!")
            
        } catch (e: UnsatisfiedLinkError) {
            Log.e(TAG, "❌ Native method call failed: ${e.message}")
            Log.e(TAG, "🔍 Native library may not be properly loaded")
        } catch (e: Exception) {
            Log.e(TAG, "❌ Error testing native methods: ${e.message}")
        }
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
