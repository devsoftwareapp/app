#include <jni.h>
#include <android/log.h>
#include <string>

#define LOG_TAG "PDFRenderer"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

// Basit PDF yapısı
struct PDFDocument {
    int pageCount;
    std::string title;
};

extern "C" {

JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_initContext(JNIEnv* env, jobject thiz) {
    LOGI("🎯 PDF Context initializing...");
    return (jlong) 0x12345678;
}

JNIEXPORT jlong JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_openDocument(JNIEnv* env, jobject thiz, jlong context, jstring filePath) {
    LOGI("📄 Opening PDF...");
    
    // NULL kontrolü
    if (filePath == nullptr) {
        LOGE("❌ File path is NULL");
        return 0;
    }
    
    const char* path = env->GetStringUTFChars(filePath, nullptr);
    if (path == nullptr) {
        LOGE("❌ Failed to get string chars");
        return 0;
    }
    
    LOGI("📄 Path: %s", path);
    
    // Test için sabit değerler
    PDFDocument* doc = new PDFDocument();
    doc->pageCount = 5;
    doc->title = "Test PDF";
    
    LOGI("✅ PDF opened - Pages: %d", doc->pageCount);
    
    // String'i serbest bırak
    env->ReleaseStringUTFChars(filePath, path);
    
    return (jlong) doc;
}

JNIEXPORT jint JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getPageCount(JNIEnv* env, jobject thiz, jlong context, jlong document) {
    if (document == 0) {
        LOGE("❌ Invalid document");
        return 0;
    }
    
    PDFDocument* doc = (PDFDocument*) document;
    LOGI("📊 Page count: %d", doc->pageCount);
    return doc->pageCount;
}

JNIEXPORT jstring JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_getDocumentTitle(JNIEnv* env, jobject thiz, jlong context, jlong document) {
    if (document == 0) {
        LOGE("❌ Invalid document");
        return env->NewStringUTF("Invalid Document");
    }
    
    PDFDocument* doc = (PDFDocument*) document;
    LOGI("📝 Title: %s", doc->title.c_str());
    return env->NewStringUTF(doc->title.c_str());
}

JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_closeDocument(JNIEnv* env, jobject thiz, jlong context, jlong document) {
    if (document != 0) {
        PDFDocument* doc = (PDFDocument*) document;
        LOGI("🧹 Closing document: %s", doc->title.c_str());
        delete doc;
    }
}

JNIEXPORT void JNICALL
Java_com_devsoftware_pdf_1reader_1manager_PDFRenderer_destroyContext(JNIEnv* env, jobject thiz, jlong context) {
    LOGI("🧹 Destroying context");
}

}
