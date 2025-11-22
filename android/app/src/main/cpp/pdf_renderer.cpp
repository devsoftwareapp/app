#include <jni.h>
#include <android/log.h>
#include <string>

#define LOG_TAG "PDFRenderer"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TG, __VA_ARGS__)

// Basit PDF yapısı (test için)
struct PDFDocument {
    int pageCount;
    const char* title;
};

extern "C" {

JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_initContext(JNIEnv* env, jobject thiz) {
    LOGI("🎯 PDF Context initializing...");
    // Basit context pointer (test için)
    return (jlong) 0x12345678;
}

JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_openDocument(JNIEnv* env, jobject thiz, jlong context, jstring filePath) {
    const char* path = env->GetStringUTFChars(filePath, 0);
    LOGI("📄 Opening PDF: %s", path);
    
    // Test için sabit değerler
    PDFDocument* doc = new PDFDocument();
    doc->pageCount = 5;  // Test için 5 sayfa
    doc->title = "Test PDF";
    
    LOGI("✅ PDF opened successfully - Pages: %d", doc->pageCount);
    env->ReleaseStringUTFChars(filePath, path);
    
    return (jlong) doc;
}

JNIEXPORT jint JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getPageCount(JNIEnv* env, jobject thiz, jlong context, jlong document) {
    PDFDocument* doc = (PDFDocument*) document;
    LOGI("📊 Getting page count: %d", doc->pageCount);
    return doc->pageCount;
}

JNIEXPORT jstring JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getDocumentTitle(JNIEnv* env, jobject thiz, jlong context, jlong document) {
    PDFDocument* doc = (PDFDocument*) document;
    LOGI("📝 Getting title: %s", doc->title);
    return env->NewStringUTF(doc->title);
}

JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_closeDocument(JNIEnv* env, jobject thiz, jlong context, jlong document) {
    PDFDocument* doc = (PDFDocument*) document;
    LOGI("🧹 Closing document: %s", doc->title);
    delete doc;
}

JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_destroyContext(JNIEnv* env, jobject thiz, jlong context) {
    LOGI("🧹 Destroying context");
}

}
